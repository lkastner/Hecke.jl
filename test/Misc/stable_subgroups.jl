@testset "ZpnGModules" begin

  @testset "Minimal Submodules" begin
   
    F,a=Nemo.FiniteField(3,1,"a")
    R=ResidueRing(FlintZZ,9)
    
    V=DiagonalGroup([3,3,9,9])
    
    l=[1,1,3,0,2,1,3,3,1,1,1,1,0,0,0,1]
    l1=[1,1,1,0,2,1,1,1,0,0,1,1,0,0,0,1]
    A=MatrixSpace(R,4,4)(l)
    A1=MatrixSpace(F,4,4)(l1)
    
    M=ZpnGModule(V,[A])
    M1=FqGModule([A1])
    
    ls=minimal_submodules(M)
    ls1=minimal_submodules(M1)
    
    @test length(ls)==length(ls1)
    for x in ls
      @test Hecke.issubmodule(M,x)
    end
  end


  @testset "Dual Module" begin
  
    R=ResidueRing(FlintZZ,9)
    V=DiagonalGroup([3,3,9,9])
    V.issnf=true
    V.snf=[3,3,9,9]
    l=[1,1,3,0,2,1,3,3,1,1,1,1,0,0,0,1]
    A=MatrixSpace(R,4,4)(l)
    M=ZpnGModule(V,[A])
    N= Hecke.dual_module(M)
    ls=submodules(N)
    v=[3,3,1,1]
    for x in ls
      @test Hecke.issubmodule(M,_dualize(x,V,v))
    end
    
  end
  
  
  @testset "submodules with given structure" begin
  
    R=ResidueRing(FlintZZ,8)
    V=DiagonalGroup([2,4,8,8])
    V.issnf=true
    V.snf=[2,4,8,8]
    l=[1,2,4,0,1,1,0,2,1,1,1,1,0,2,0,1]
    l1=[1,0,0,0,0,3,4,2,1,0,0,1,0,0,1,0]
    l2=[1,0,0,4,1,1,0,0,0,2,1,0,1,1,1,1]
    A=MatrixSpace(R,4,4)(l)
    B=MatrixSpace(R,4,4)(l1)
    C=MatrixSpace(R,4,4)(l2)
    M=ZpnGModule(V,[A,B,C])
    ls=submodules(M,typesub=[2,3])
    y=subgroups(V,quotype=[4,8])
    
    mp1=Hecke.GrpAbFinGenMap(V,V,lift(A))
    mp2=Hecke.GrpAbFinGenMap(V,V,lift(B))
    mp3=Hecke.GrpAbFinGenMap(V,V,lift(C))
    act=[mp1,mp2,mp3]
    
    i=0
    for el in y
      if Hecke.is_stable(act,el[2])
        i+=1
      end
    end
    @test i==length(ls)
  
  end


end
