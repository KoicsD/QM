function myassert(StringExpr)
    if ~eval(StringExpr)
        error(['Assertion ''' StringExpr ''' failed.'])
    end
end