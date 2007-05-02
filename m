From: AK <amithl_prem@yahoo.com>
Subject: NFS & RPCBIND relation
Date: Wed, 2 May 2007 08:11:52 -0700 (PDT)
Message-ID: <206092.69095.qm@web56615.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0506743060=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjGUn-0006kB-Iy
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 08:12:00 -0700
Received: from web56615.mail.re3.yahoo.com ([66.196.97.59])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HjGUo-0004J5-77
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 08:12:00 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0506743060==
Content-Type: multipart/alternative; boundary="0-1581789353-1178118712=:69095"
Content-Transfer-Encoding: 7bit

--0-1581789353-1178118712=:69095
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Hi there,

OS: Solaris 9, NFS v3

*** At one point the "nfs.client" on our server was NOT turned ON. At thi=
s time we noticed that the rpcbind(process) was consistently about 12-13%=
 in CPU use. Which seemed strange but could not find an answer to this. N=
FSD stayed up 11%. The nfs.client as I found out, started lockd and other=
 programs "nlockmgr & status" important for NFS file locking from the cli=
ents perspective.=20

Q1) Is this normal for rpcbind ? If yes/no then can anyone explain, why d=
id our rpcbind cpu usage dropped to almost less then 1% consistently afte=
r we TUNRNED ON nfs.client on our server. Since I started NFS client on t=
he server I never saw it going up above 1%. ???

Q2) what does nfs.client have to do with RPCBIND's above described behavi=
our ???
  =20
  Any feedback will be greatly helpful!
  =20
  ~thanks ~al

      =20
---------------------------------
Ahhh...imagining that irresistible "new car" smell?
 Check outnew cars at Yahoo! Autos.
--0-1581789353-1178118712=:69095
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<div>Hi there,<BR><BR>OS: Solaris 9, NFS v3<BR><BR>*** At one point the "=
nfs.client" on&nbsp;our server was NOT turned ON. At this time we noticed=
 that the rpcbind(process) was consistently about 12-13% in CPU use. Whic=
h seemed strange but could not find an answer to this. NFSD stayed up 11%=
. The nfs.client as I found out, started lockd and other programs "nlockm=
gr &amp; status" important for NFS file locking from the clients perspect=
ive. <BR><BR>Q1) Is this normal for rpcbind ? If yes/no then can anyone e=
xplain, why did our rpcbind cpu usage dropped to almost less then 1% cons=
istently after we TUNRNED ON nfs.client on our server. Since I started NF=
S client on the server I never saw it going up above 1%. ???<BR><BR>Q2) w=
hat does nfs.client have to do with RPCBIND's above described behaviour ?=
??</div>  <div>&nbsp;</div>  <div>Any feedback will be greatly helpful!</=
div>  <div>&nbsp;</div>  <div>~thanks ~al</div><p>&#32;

      <hr size=3D1>Ahhh...imagining that irresistible "new car" smell?<br=
> Check out
<a href=3D"http://us.rd.yahoo.com/evt=3D48245/*http://autos.yahoo.com/new=
_cars.html;_ylc=3DX3oDMTE1YW1jcXJ2BF9TAzk3MTA3MDc2BHNlYwNtYWlsdGFncwRzbGs=
DbmV3LWNhcnM-">new cars at Yahoo! Autos.</a>

--0-1581789353-1178118712=:69095--


--===============0506743060==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0506743060==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0506743060==--
