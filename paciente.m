## -*- texinfo -*-
## @deftypefn  {} {} polynomial ()
## @deftypefnx {} {} polynomial (@var{a})
## Create a polynomial object representing the polynomial
##
## @example
## a0 + a1 * x + a2 * x^2 + @dots{} + an * x^n
## @end example
##
## @noindent
## from a vector of coefficients [a0 a1 a2 @dots{} an].
## @end deftypefn

function p = paciente (a)

  if (nargin > 1)
    print_usage ();
  endif

  if (nargin == 0)
    p.dir = [0];
    p = class (p, "paciente");
  else
    if (strcmp (class (a), "paciente"))
      p = a;
    elseif (isreal (a) && isvector (a))
      p.poly = a(:).';  # force row vector
      p = class (p, "paciente");
    else
      error ("@polynomial: A must be a real vector");
    endif
  endif

endfunction