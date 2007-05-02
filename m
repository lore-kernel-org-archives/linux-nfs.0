From: AK <amithl_prem@yahoo.com>
Subject: Understanding nfsstat output
Date: Wed, 2 May 2007 08:26:21 -0700 (PDT)
Message-ID: <953249.36987.qm@web56613.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1923323450=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjGip-0008GG-Lt
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 08:26:27 -0700
Received: from web56613.mail.re3.yahoo.com ([66.196.97.57])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HjGip-00033H-Rt
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 08:26:30 -0700
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

--===============1923323450==
Content-Type: multipart/alternative; boundary="0-657130747-1178119581=:36987"
Content-Transfer-Encoding: 7bit

--0-657130747-1178119581=:36987
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Hello everyone!
  =20
  I am trying to understand the output of nfsstat to better understand an=
d tweak NFS performance for our machines.=20
  =20
  Following is the output from our Solaris 9, NFSv3 running server:
  =20
  I am concerned about the "badcalls" for "Server nfs" output, is this no=
rmal or something is wrong. We have some of our clients mounting the expo=
rted File system with rsize & wsize =3D 32K,  Could this be the problem, =
is there a way to narrow it down?
  =20
  Any feedback is greatly appreciated!
  =20
  ~thanks ~al
  =20
  # nfsstat -s
  =20
  Server rpc:
Connection oriented:
calls        badcalls     nullrecv     badlen       xdrcall      dupcheck=
s
101090599    0            0            0            0            62704096
dupreqs
7038
Connectionless:
calls        badcalls     nullrecv     badlen       xdrcall      dupcheck=
s
17121084     0            0            0            0            7028935
dupreqs
69076
  =20
  Server nfs:
calls        badcalls
118266383    57138
Version 2: (0 calls)
null         getattr      setattr      root         lookup       readlink
0 0%         0 0%         0 0%         0 0%         0 0%         0 0%
read         wrcache      write        create       remove       rename
0 0%         0 0%         0 0%         0 0%         0 0%         0 0%
link         symlink      mkdir        rmdir        readdir      statfs
0 0%         0 0%         0 0%         0 0%         0 0%         0 0%
Version 3: (117965148 calls)
null         getattr      setattr      lookup       access       readlink
1 0%         185486 0%    1906 0%      41482 0%     24091 0%     487 0%
read         write        create       mkdir        symlink      mknod
47680376 40% 69594128 58% 2516 0%      2 0%         80 0%        0 0%
remove       rmdir        rename       link         readdir      readdirp=
lus
1658 0%      4 0%         126 0%       7 0%         1890 0%      2726 0%
fsstat       fsinfo       pathconf     commit
222331 0%    9 0%         2 0%         205840 0%
  =20
  Server nfs_acl:
Version 2: (0 calls)
null         getacl       setacl       getattr      access
0 0%         0 0%         0 0%         0 0%         0 0%
Version 3: (111 calls)
null         getacl       setacl
0 0%         73 65%       38 34%

      =20
---------------------------------
Ahhh...imagining that irresistible "new car" smell?
 Check outnew cars at Yahoo! Autos.
--0-657130747-1178119581=:36987
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<div>Hello everyone!</div>  <div>&nbsp;</div>  <div>I am trying to unders=
tand the output of nfsstat to better understand and tweak NFS performance=
 for our machines. </div>  <div>&nbsp;</div>  <div>Following is the outpu=
t from our Solaris 9, NFSv3 running server:</div>  <div>&nbsp;</div>  <di=
v>I am concerned about the "badcalls" for "Server nfs" output, is this no=
rmal or something is wrong. We have some of our clients mounting the expo=
rted File system with rsize &amp; wsize =3D 32K,&nbsp; Could this be the =
problem, is there a way to narrow it down?</div>  <div>&nbsp;</div>  <div=
>Any feedback is greatly appreciated!</div>  <div>&nbsp;</div>  <div>~tha=
nks ~al</div>  <div>&nbsp;</div>  <div># nfsstat -s</div>  <div>&nbsp;</d=
iv>  <div>Server rpc:<BR>Connection oriented:<BR>calls&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; badcalls&nbsp;&nbsp;&nbsp;&nbsp; nullrecv&nbsp;&n=
bsp;&nbsp;&nbsp; badlen&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; xdrcall&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
 dupchecks<BR>101090599&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; 62704096<BR>dupreqs<BR>7038<BR>Connectionless:<BR>c=
alls&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; badcalls&nbsp;&nbsp;&nbsp;=
&nbsp; nullrecv&nbsp;&nbsp;&nbsp;&nbsp; badlen&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; xdrcall&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dupchecks<BR>17121084&nbs=
p;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 7028935<BR>dupreqs<BR>69076</div>  <div>&nbsp;</div>  <div>Server
 nfs:<BR>calls&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; badcalls<BR>1182=
66383&nbsp;&nbsp;&nbsp; 57138<BR>Version 2: (0 calls)<BR>null&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; getattr&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
; setattr&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; lookup&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; readlink<B=
R>0 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; 0 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%<BR>read&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; wrcache&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; remove&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rename<BR>0=
 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0
 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; 0 0%<BR>link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
symlink&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; readdir&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; statfs<BR>0 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; 0 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp; 0 0%<BR>Version 3: (117965148 calls)<BR>null&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; getattr&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; setatt=
r&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; lookup&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
; access&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; readlink<BR>1 0%&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 185486 0%&nbsp;&nbsp;&nbsp; 1906 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 41482 =
0%&nbsp;&nbsp;&nbsp;&nbsp; 24091 0%&nbsp;&nbsp;&nbsp;&nbsp; 487 0%<BR>rea=
d&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; write&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp; create&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mkdir=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; symlink&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; mknod<BR>47680376 40% 69594128 58% 2516 0%&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; 2 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 80 0%&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%<BR>remove&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp; rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rename&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; readdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; readdirplus<BR>1658 0%&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; 126 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 7 0%&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1890
 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2726 0%<BR>fsstat&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; fsinfo&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pathconf&nbsp;&=
nbsp;&nbsp;&nbsp; commit<BR>222331 0%&nbsp;&nbsp;&nbsp; 9 0%&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; 205840 0%</div>  <div>&nbsp;</div>  <div>Server nfs_acl:<=
BR>Version 2: (0 calls)<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp; getacl&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; setacl&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; getattr&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; access<BR>0 0%&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; 0 0%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 0%<BR>Vers=
ion 3: (111 calls)<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
; getacl&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; setacl<BR>0 0%&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 73
 65%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 38 34%</div><p>&#32;



      <hr size=3D1>Ahhh...imagining that irresistible "new car" smell?<br=
> Check out
<a href=3D"http://us.rd.yahoo.com/evt=3D48245/*http://autos.yahoo.com/new=
_cars.html;_ylc=3DX3oDMTE1YW1jcXJ2BF9TAzk3MTA3MDc2BHNlYwNtYWlsdGFncwRzbGs=
DbmV3LWNhcnM-">new cars at Yahoo! Autos.</a>

--0-657130747-1178119581=:36987--


--===============1923323450==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1923323450==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1923323450==--
