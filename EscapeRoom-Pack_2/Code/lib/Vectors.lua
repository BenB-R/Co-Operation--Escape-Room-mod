--- Some arithmetic helpers for tables.

DirectionArray = {
	North = {  0, -1 },
	East =  {  1,  0 },
	South = {  0,  1 },
	West =  { -1,  0 },
}

function vectors_add(x, y)
	local z = {}
	if #x == #y then
		for i = 1, #x do
			z[i] = x[i] + y[i]
		end
	end
	return z
end
