From: <eh@dataconnection.com>
Subject: Problem with NLM on Fedora
Date: Tue, 12 Apr 2005 21:55:32 +0100
Message-ID: <9E621559095AA746B22B21CD4FAF99A50A4E76@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C53FA1.F7B9DD90"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DLSQ9-0007x5-Dg
	for nfs@lists.sourceforge.net; Tue, 12 Apr 2005 13:55:41 -0700
Received: from smtp.dataconnection.com ([192.91.191.4])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DLSQ8-0004Db-Af
	for nfs@lists.sourceforge.net; Tue, 12 Apr 2005 13:55:41 -0700
To: <nfs@lists.sourceforge.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.

------_=_NextPart_001_01C53FA1.F7B9DD90
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

> I've just installed Fedora, and am having problems with NFS. =20
>=20
> What I'm seeing is that NLM requests are not issued to the NFS server =
(which is a SNAP Server).  Instead the application hangs for about 7 =
seconds, and then returns successfully (i.e. the locks are ostensibly =
granted).  The delay happens both on locks and unlock requests.  Via =
tcpdump I see NFS requests/responses, but no RPC calls for NLM.
>=20
> Here's what uname -a says about my system.
>=20
> Linux rack10.datcon.co.uk 2.6.9-1.667smp #1 SMP Tue Nov 2 14:59:52 EST =
2004 i686 i686 i386 GNU/Linux
>=20
> Here's the mount point
>=20
> 172.19.15.109:/mngdata/keepalive on /opt/dcl/keepalive type nfs =
(rw,rsize=3D4096,wsize=3D4096,hard,intr,bg,lock,nfsvers=3D3,addr=3D172.19=
.15.109)
>=20
> pstack shows I'm hung here:
>=20
> 0x002447a2: _dl_sysinfo_int80 + 0x2 (b, e, fefe2080, 0, 0, 0) + 1400
>=20
> I downloaded nfsutils 1.0.7, but that didn't help.  I also saw this:
>=20
> A. There are permisions on the /var/lib/nfs/sm and /var/lib/nfs/sm.bak =
files that must be addressed. Whomever rpc.statd is running as must have =
ownership and rw access to those dirs. The permissions should be set to =
700 for both. In addition, etab, rmtab, and xtab all must exist and be =
writable by root.
>=20
> So I tried changing the permissions:
>=20
> /var/lib/nfs:
> total 32
> -rwxrwxrwx  1 root root    0 Apr 12 11:58 etab
> -rwxrwxrwx  1 root root    0 Apr 12 11:58 rmtab
> drwxr-xr-x  7 root root    0 Apr 12 12:29 rpc_pipefs
> drwx------  2 root root 4096 Apr 12 11:58 sm
> drwx------  2 root root 4096 Apr 12 11:58 sm.bak
> drwxrwxrwx  4 root root 4096 Apr 12 06:28 statd
> -rwxrwxrwx  1 root root    0 Apr 12 11:58 state
> -rwxrwxrwx  1 root root    0 Apr 12 11:58 xtab
>=20
> /var/lib/nfs/statd:
> total 12
> drwxrwxrwx  2 root root 4096 Apr 12 12:31 sm
> drwxrwxrwx  2 root root 4096 Apr 12 12:29 sm.bak
> -rwxrwxrwx  1 root root    4 Apr 12 12:29 state
>=20
> ...and I've rebooted.  None of this has helped.
>=20
> Any suggestions?
>=20
> Edward.

------_=_NextPart_001_01C53FA1.F7B9DD90
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7226.0">
<TITLE> Problem with NLM on Fedora </TITLE>
</HEAD>
<BODY>
<!-- Converted from text/rtf format -->

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">I've just installed =
Fedora, and am having problems with NFS.&nbsp; </FONT>
</P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">What I'm seeing is =
that NLM requests are not issued to the NFS server (which is a SNAP =
Server).&nbsp; Instead the application hangs for about 7 seconds, and =
then returns successfully (i.e. the locks are ostensibly granted).&nbsp; =
The delay happens both on locks and unlock requests.&nbsp; Via tcpdump I =
see NFS requests/responses, but no RPC calls for NLM.</FONT></P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">Here's what uname -a =
says about my system.</FONT>
</P>

<P><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Arial">Linux =
rack10.datcon.co.uk 2.6.9-1.667smp #1 SMP Tue Nov 2 14:59:52 EST 2004 =
i686 i686 i386 GNU/Linux</FONT>
</P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">Here's the mount =
point</FONT>
</P>

<P><FONT COLOR=3D"#000000" SIZE=3D2 =
FACE=3D"Arial">172.19.15.109:/mngdata/keepalive on /opt/dcl/keepalive =
type nfs =
(rw,rsize=3D4096,wsize=3D4096,hard,intr,bg,lock,nfsvers=3D3,addr=3D172.19=
.15.109)</FONT></P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">pstack shows I'm hung =
here:</FONT>
</P>

<P><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">0x002447a2: =
_dl_sysinfo_int80 + 0x2 (b, e, fefe2080, 0, 0, 0) + 1400</FONT>
</P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">I downloaded nfsutils =
1.0.7, but that didn't help.&nbsp; I also saw this:</FONT>
</P>

<P><B><FONT FACE=3D"Times New Roman">A.</FONT></B><FONT FACE=3D"Times =
New Roman"> There are permisions on the</FONT> <FONT SIZE=3D2 =
FACE=3D"Courier New">/var/lib/nfs/sm</FONT><FONT FACE=3D"Times New =
Roman"> and</FONT> <FONT SIZE=3D2 FACE=3D"Courier =
New">/var/lib/nfs/sm.bak</FONT><FONT FACE=3D"Times New Roman"> files =
that must be addressed. Whomever rpc.statd is running as must have =
ownership and rw access to those dirs. The permissions should be set to =
700 for both. In addition, etab, rmtab, and xtab all must exist and be =
writable by root.</FONT></P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">So I tried changing =
the permissions:</FONT>
</P>

<P><FONT COLOR=3D"#000000" SIZE=3D2 =
FACE=3D"Courier">/var/lib/nfs:</FONT>

<BR><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">total 32</FONT>

<BR><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">-rwxrwxrwx&nbsp; 1 =
root root&nbsp;&nbsp;&nbsp; 0 Apr 12 11:58 etab</FONT>

<BR><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">-rwxrwxrwx&nbsp; 1 =
root root&nbsp;&nbsp;&nbsp; 0 Apr 12 11:58 rmtab</FONT>

<BR><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">drwxr-xr-x&nbsp; 7 =
root root&nbsp;&nbsp;&nbsp; 0 Apr 12 12:29 rpc_pipefs</FONT>

<BR><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">drwx------&nbsp; 2 =
root root 4096 Apr 12 11:58 sm</FONT>

<BR><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">drwx------&nbsp; 2 =
root root 4096 Apr 12 11:58 sm.bak</FONT>

<BR><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">drwxrwxrwx&nbsp; 4 =
root root 4096 Apr 12 06:28 statd</FONT>

<BR><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">-rwxrwxrwx&nbsp; 1 =
root root&nbsp;&nbsp;&nbsp; 0 Apr 12 11:58 state</FONT>

<BR><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">-rwxrwxrwx&nbsp; 1 =
root root&nbsp;&nbsp;&nbsp; 0 Apr 12 11:58 xtab</FONT>
</P>

<P><FONT COLOR=3D"#000000" SIZE=3D2 =
FACE=3D"Courier">/var/lib/nfs/statd:</FONT>

<BR><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">total 12</FONT>

<BR><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">drwxrwxrwx&nbsp; 2 =
root root 4096 Apr 12 12:31 sm</FONT>

<BR><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">drwxrwxrwx&nbsp; 2 =
root root 4096 Apr 12 12:29 sm.bak</FONT>

<BR><FONT COLOR=3D"#000000" SIZE=3D2 FACE=3D"Courier">-rwxrwxrwx&nbsp; 1 =
root root&nbsp;&nbsp;&nbsp; 4 Apr 12 12:29 state</FONT>
</P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">...and I've =
rebooted.&nbsp; None of this has helped.</FONT>
</P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">Any =
suggestions?</FONT>
</P>

<P><FONT COLOR=3D"#FF00FF" SIZE=3D2 FACE=3D"Arial">Edward.</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C53FA1.F7B9DD90--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
