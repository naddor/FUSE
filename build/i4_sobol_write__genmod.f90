        !COMPILER-GENERATED INTERFACE MODULE: Thu Jul 14 22:23:02 2016
        MODULE I4_SOBOL_WRITE__genmod
          INTERFACE 
            SUBROUTINE I4_SOBOL_WRITE(M,N,SKIP,R,FILE_OUT_NAME)
              INTEGER(KIND=4) :: N
              INTEGER(KIND=4) :: M
              INTEGER(KIND=4) :: SKIP
              REAL(KIND=4) :: R(M,N)
              CHARACTER(*) :: FILE_OUT_NAME
            END SUBROUTINE I4_SOBOL_WRITE
          END INTERFACE 
        END MODULE I4_SOBOL_WRITE__genmod