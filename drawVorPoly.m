function drawVorPoly(vList,relList)

allVX = vList(:,1);
allVY = vList(:,2);
X = allVX(relList);
Y = allVY(relList);
plot(X,Y,'b-')
end