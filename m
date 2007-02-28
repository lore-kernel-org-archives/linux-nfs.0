From: AK <amithl_prem@yahoo.com>
Subject: Error inserting sunrpc  Error inserting nfs
Date: Wed, 28 Feb 2007 06:56:11 -0800 (PST)
Message-ID: <944755.15499.qm@web56604.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0230721991=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMQEA-00034g-Hn
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 06:56:25 -0800
Received: from web56604.mail.re3.yahoo.com ([66.196.97.48])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HMQE7-0007sB-Oz
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 06:56:21 -0800
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

--===============0230721991==
Content-Type: multipart/alternative; boundary="0-1873723473-1172674571=:15499"
Content-Transfer-Encoding: 7bit

--0-1873723473-1172674571=:15499
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Hi All,
  =20
  I get the following errors on bootup, reproduced by modprobe, as shown =
below.=20
  Everything was working fine until I changed the rsize and wsize to: 327=
68 and then rebooted the system.=20
  Now If I rechange it back to original 8192 value, it still fails.
  Any idea ???
  =20
  ~thanks in advance!!!
  =20
  modprobe nfs
FATAL: Error inserting sunrpc (/lib/modules/2.6.9-22.ELsmp/kernel/net/sun=
rpc/sunrpc.ko): Unknown symbol in module, or unknown parameter (see dmesg=
)
WARNING: Error running install command for sunrpc
WARNING: Error inserting lockd (/lib/modules/2.6.9-22.ELsmp/kernel/fs/loc=
kd/lockd.ko): Unknown symbol in module, or unknown parameter (see dmesg)
FATAL: Error inserting nfs (/lib/modules/2.6.9-22.ELsmp/kernel/fs/nfs/nfs=
.ko): Unknown symbol in module, or unknown parameter (see dmesg)

=20
---------------------------------
No need to miss a message. Get email on-the-go=20
with Yahoo! Mail for Mobile. Get started.
--0-1873723473-1172674571=:15499
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<div>Hi All,</div>  <div>&nbsp;</div>  <div>I get the following errors on=
 bootup, reproduced by modprobe, as shown below. </div>  <div>Everything =
was working fine until I changed the rsize and wsize to: 32768 and then r=
ebooted the system. </div>  <div>Now If I rechange it back to original 81=
92 value, it still fails.</div>  <div>Any idea ???</div>  <div>&nbsp;</di=
v>  <div>~thanks in advance!!!</div>  <div>&nbsp;</div>  <div>modprobe nf=
s<BR>FATAL: Error inserting sunrpc (/lib/modules/2.6.9-22.ELsmp/kernel/ne=
t/sunrpc/sunrpc.ko): Unknown symbol in module, or unknown parameter (see =
dmesg)<BR>WARNING: Error running install command for sunrpc<BR>WARNING: E=
rror inserting lockd (/lib/modules/2.6.9-22.ELsmp/kernel/fs/lockd/lockd.k=
o): Unknown symbol in module, or unknown parameter (see dmesg)<BR>FATAL: =
Error inserting nfs (/lib/modules/2.6.9-22.ELsmp/kernel/fs/nfs/nfs.ko): U=
nknown symbol in module, or unknown parameter (see dmesg)</div><p>&#32;

<hr size=3D1>No need to miss a message. <a href=3D"http://us.rd.yahoo.com=
/evt=3D43910/*http://mobile.yahoo.com/mail
">Get email on-the-go </a><br>with Yahoo! Mail for Mobile. <a href=3D"htt=
p://us.rd.yahoo.com/evt=3D43910/*http://mobile.yahoo.com/mail
">Get started.</a>
--0-1873723473-1172674571=:15499--


--===============0230721991==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0230721991==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0230721991==--
