  SUBROUTINE lnsrch(xold,fold,g,p,x,f,stpmax,check,func)
  USE nrtype; USE nrutil, ONLY : assert_eq,nrerror,vabs
  USE model_numerix, ONLY : ERR_ITER_DX,NUM_FUNCS  ! convergence criterion on dx
  USE limit_xtry_module ! provide access to limit_xtry
  IMPLICIT NONE
  REAL(SP), DIMENSION(:), INTENT(IN) :: xold,g
  REAL(SP), DIMENSION(:), INTENT(INOUT) :: p
  REAL(SP), INTENT(IN) :: fold,stpmax
  REAL(SP), DIMENSION(:), INTENT(OUT) :: x
  REAL(SP), INTENT(OUT) :: f
  LOGICAL(LGT), INTENT(OUT) :: check
  INTERFACE
    FUNCTION func(x)
    USE nrtype
    IMPLICIT NONE
    REAL(SP) :: func
    REAL(SP), DIMENSION(:), INTENT(IN) :: x
    END FUNCTION func
  END INTERFACE
  REAL(SP), PARAMETER :: ALF=1.0e-4_sp
  INTEGER(I4B) :: ndum
  REAL(SP) :: a,alam,alam2,alamin,b,disc,f2,fold2,pabs,rhs1,rhs2,slope,&
    tmplam
  ndum=assert_eq(size(g),size(p),size(x),size(xold),'lnsrch')
  check=.false.
  pabs=vabs(p(:))
  if (pabs > stpmax) p(:)=p(:)*stpmax/pabs
  slope=dot_product(g,p)
  alamin=ERR_ITER_DX/maxval(abs(p(:))/max(abs(xold(:)),1.0_sp))
  alam=1.0
  do
    x(:)=xold(:)+alam*p(:)
    !print *, 'alam = ', alam, alamin
    !print *, 'in lnsrch, x raw = ', x
    call limit_xtry(x) ! ensure that the value of x is physically reasonable
    f=func(x)          ! compute function evaluation (populate FVEC and DSDT)
    !print *, 'in lnsrch, x new = ', x, f
    !write(*,'(i4,1x20(f20.10,1x))') num_funcs, x
    if (alam < alamin) then
      x(:)=xold(:)
      check=.true.
      RETURN
    else if (f <= fold+ALF*alam*slope) then
      RETURN
    else
      if (alam == 1.0) then
        tmplam=-slope/(2.0_sp*(f-fold-slope))
      else
        rhs1=f-fold-alam*slope
        rhs2=f2-fold2-alam2*slope
        a=(rhs1/alam**2-rhs2/alam2**2)/(alam-alam2)
        b=(-alam2*rhs1/alam**2+alam*rhs2/alam2**2)/&
          (alam-alam2)
        if (a == 0.0) then
          tmplam=-slope/(2.0_sp*b)
        else
          disc=b*b-3.0_sp*a*slope
          !if (disc < 0.0) call nrerror('roundoff problem in lnsrch')
          ! MPC change -- this should only happen for small alam
          if (disc < 0.0) then
            x(:)=xold(:)
            check=.true.
            RETURN
          endif
          ! end MPC change
          tmplam=(-b+sqrt(disc))/(3.0_sp*a)
        end if
        if (tmplam > 0.5_sp*alam) tmplam=0.5_sp*alam
      end if
    end if
    alam2=alam
    f2=f
    fold2=fold
    alam=max(tmplam,0.1_sp*alam)
  end do
  END SUBROUTINE lnsrch
