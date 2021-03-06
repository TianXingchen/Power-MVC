%% Analytic Continuation
classdef Approximator < handle

	properties

	end

	methods

		%% pade: pade 近似
		function [num, den] = pade(self, c, l, m)
			% 校验参数的合法性
			l = floor(l);
			m = floor(m);
			assert(length(c) >= l+m+1 && l <= m);

			% 初始化
			den = zeros(m+1, 1);	% b0~bm
			den(1) = 1;
			% num = zeros(l+1, 1);	% a0~al

			% 计算分母 b
			C = zeros(m, m);	% 初始化系数矩阵 C 与索引
			Index = 1:m*m;
			index = floor((Index-1)/m) + mod((Index-1), m)+1;	% 
			C(Index) = c(l-m+1+index);
			den(m+1:-1:2) = -(C \ c((l+2):(l+m+1))');
			den = den';

			% 计算分子 a
			num = conv(den(1:l+1), c(1:l+1));
			num = num(1:l+1);
		end

		%% viskovatov: viskovatov 近似
		function [res] = viskovatov(self, c, order)
			if nargin == 2 || nargin == 3 && order > length(c) - 1
				order = length(c) - 1;
			end
			% 校验参数的合法性
			order = floor(order);
			assert(order < length(c));

			c = c(1:(order+1));
			res = zeros(1, order+1);
			res = c;
			for k = 1:(order)
				res((k+1):end) = getReciprocal(res((k+1):(order+1)));
			end

			res = self.cumdivsum(res);

			%% getReciprocal: 计算多项式的倒数
			function [r] = getReciprocal(coe)
				% if nargin == 2 || nargin == 3 && order > length(coe) - 1
				% 	order = length(coe) - 1;
				% end
				if length(coe) <= 0
					return;
				end
				
				r = zeros(size(coe));
				r(1) = 1./coe(1);
				for l = 2:length(r)
					r(l) = -sum(r((l-1):-1:1).*coe(2:l))/coe(1);
				end
			end

		end

		%% divsum: 用于 viskovatov 系数求和
		function [res] = divsum(self, c)
			if length(c) == 1
				res = c;
			else
				res = c(1) + 1./self.divsum(c(2:end));
			end
		end

		%% cumdivsum: 用于 viskovatov 系数求和累加
		function [res] = cumdivsum(self, c)
			res = zeros(size(c));
			for k = 1:length(c)
				res(k) = self.divsum(c(1:k));
			end
		end

		%% epsilon: epsilon 方法
		function [res] = epsilon(self, c)
			e = zeros(length(c) + 1);
			e(1:end-1, 2) = cumsum(c)';
			index = 1:(length(c)-2);

			for k = 3:(length(c) + 1)
				e(index, k) = e(index+1, k-2) + 1./(e(index+1, k-1) - e(index, k-1));
				index = index(1:(end-1));
			end

			objIndex = 2:2:length(c + 1);
			res = e(1, objIndex);
		end

	end

end