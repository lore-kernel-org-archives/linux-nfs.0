From: "Edward Hibbert" <Edward.Hibbert@dataconnection.com>
Subject: RE: Stale NFS mounts
Date: Tue, 1 Nov 2005 15:29:21 -0000
Message-ID: <9E621559095AA746B22B21CD4FAF99A54E3197@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5DEF9.085B485D"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EWy4s-0007yo-AG
	for nfs@lists.sourceforge.net; Tue, 01 Nov 2005 07:29:34 -0800
Received: from smtp.dataconnection.com ([192.91.191.4])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EWy4r-0006yB-7K
	for nfs@lists.sourceforge.net; Tue, 01 Nov 2005 07:29:34 -0800
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

------_=_NextPart_001_01C5DEF9.085B485D
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Bit more on this. =20
=20
If we export a directory X, then mount subdirectories within it (so from
a client, mount X/Y) then we see the problem.
If we export X/Y and mount X/Y then we don't.
=20
Can anyone suggest any reason for this?
=20
Regards,
=20
Edward.

________________________________

From: Edward Hibbert=20
Sent: 01 November 2005 10:58
To: 'nfs@lists.sourceforge.net'
Subject: RE: [NFS] Stale NFS mounts



>
> The NFS server is a Fedora system with kernel 2.6.9-1.667smp.  The NFS
> clients are RedHat AS 4.0 2.6.9-11.ELsmp.  Do ask for more details if
> needed.

On the server:
  cat /etc/exports
  cat /proc/fs/nfsd/exports
  grep . /proc/net/rpc/*/content

Ok, I've done this now while it's working - but what should I be looking
for here?  Maybe the last couple of lines changing?

root[vitorbelfort]:/var/log> cat /etc/exports=20
/opt/dcl/data/disk1 *(rw,sync,no_root_squash)
/opt/dcl/data/disk2 *(rw,sync,no_root_squash)
root[vitorbelfort]:/var/log> cd /proc/fs/nfsd/exports=20
-bash: cd: /proc/fs/nfsd/exports: Not a directory
root[vitorbelfort]:/var/log> cat /proc/fs/nfsd/exports =20
# Version 1.1
# Path Client(Flags) # IPs
/opt/dcl/data/disk1     *(rw,no_root_squash,sync,wdelay)
/opt/dcl/data/disk2     *(rw,no_root_squash,sync,wdelay)
root[vitorbelfort]:/var/log>   grep . /proc/net/rpc/*/content
/proc/net/rpc/auth.unix.ip/content:#class IP domain
/proc/net/rpc/auth.unix.ip/content:nfsd 172.19.15.102 *
/proc/net/rpc/auth.unix.ip/content:nfsd 172.19.15.101 *
/proc/net/rpc/auth.unix.ip/content:nfsd 172.19.15.97 *
/proc/net/rpc/auth.unix.ip/content:nfsd 172.19.15.91 *
/proc/net/rpc/auth.unix.ip/content:nfsd 172.19.15.92 *
/proc/net/rpc/auth.unix.ip/content:nfsd 172.19.15.89 *
/proc/net/rpc/nfs4.idtoname/content:#domain type id [name]
/proc/net/rpc/nfs4.nametoid/content:#domain type name [id]
/proc/net/rpc/nfsd.export/content:#path domain(flags)
/proc/net/rpc/nfsd.export/content:/opt/dcl/data/disk1
*(rw,no_root_squash,sync,wdelay)
/proc/net/rpc/nfsd.export/content:/opt/dcl/data/disk2
*(rw,no_root_squash,sync,wdelay)
/proc/net/rpc/nfsd.fh/content:#domain fsidtype fsid [path]
/proc/net/rpc/nfsd.fh/content:* 0 0x0300080000000080 /opt/dcl/data/disk1
/proc/net/rpc/nfsd.fh/content:* 0 0x1100080000000080 /opt/dcl/data/disk2

Regards,

Edward.


------_=_NextPart_001_01C5DEF9.085B485D
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD><TITLE></TITLE>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2800.1515" name=3DGENERATOR></HEAD>
<BODY>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#ff00ff =
size=3D2><SPAN=20
class=3D403102315-01112005>Bit more on this.&nbsp; </SPAN></FONT></DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#ff00ff =
size=3D2><SPAN=20
class=3D403102315-01112005></SPAN></FONT>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#ff00ff =
size=3D2><SPAN=20
class=3D403102315-01112005>If we export a directory X, then mount =
subdirectories=20
within it (so from a client, mount X/Y) then we see the=20
problem.</SPAN></FONT></DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#ff00ff =
size=3D2><SPAN=20
class=3D403102315-01112005>If we export X/Y and mount X/Y then we=20
don't.</SPAN></FONT></DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#ff00ff =
size=3D2><SPAN=20
class=3D403102315-01112005></SPAN></FONT>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#ff00ff =
size=3D2><SPAN=20
class=3D403102315-01112005>Can anyone suggest any reason for=20
this?</SPAN></FONT></DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#ff00ff =
size=3D2><SPAN=20
class=3D403102315-01112005></SPAN></FONT>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#ff00ff =
size=3D2><SPAN=20
class=3D403102315-01112005>Regards,</SPAN></FONT></DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#ff00ff =
size=3D2><SPAN=20
class=3D403102315-01112005></SPAN></FONT>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#ff00ff =
size=3D2><SPAN=20
class=3D403102315-01112005>Edward.</SPAN></FONT></DIV><BR>
<DIV class=3DOutlookMessageHeader lang=3Den-us dir=3Dltr align=3Dleft>
<HR tabIndex=3D-1>
<FONT face=3DTahoma size=3D2><B>From:</B> Edward Hibbert =
<BR><B>Sent:</B> 01=20
November 2005 10:58<BR><B>To:</B> =
'nfs@lists.sourceforge.net'<BR><B>Subject:</B>=20
RE: [NFS] Stale NFS mounts<BR></FONT><BR></DIV>
<DIV></DIV>
<P><FONT size=3D2>&gt;<BR>&gt; The NFS server is a Fedora system with =
kernel=20
2.6.9-1.667smp.&nbsp; The NFS<BR>&gt; clients are RedHat AS 4.0=20
2.6.9-11.ELsmp.&nbsp; Do ask for more details if<BR>&gt; =
needed.<BR><BR>On the=20
server:<BR>&nbsp; cat /etc/exports<BR>&nbsp; cat =
/proc/fs/nfsd/exports<BR>&nbsp;=20
grep . /proc/net/rpc/*/content<BR><BR><FONT face=3DArial =
color=3D#ff00ff>Ok, I've=20
done this now while it's working - but what should I be looking for =
here?&nbsp;=20
Maybe the last couple of lines changing?</FONT></FONT></P>
<P><FONT face=3DArial color=3D#ff00ff =
size=3D2>root[vitorbelfort]:/var/log&gt; cat=20
/etc/exports <BR>/opt/dcl/data/disk1=20
*(rw,sync,no_root_squash)<BR>/opt/dcl/data/disk2=20
*(rw,sync,no_root_squash)<BR>root[vitorbelfort]:/var/log&gt; cd=20
/proc/fs/nfsd/exports <BR>-bash: cd: /proc/fs/nfsd/exports: Not a=20
directory<BR>root[vitorbelfort]:/var/log&gt; cat =
/proc/fs/nfsd/exports&nbsp;=20
<BR># Version 1.1<BR># Path Client(Flags) #=20
IPs<BR>/opt/dcl/data/disk1&nbsp;&nbsp;&nbsp;&nbsp;=20
*(rw,no_root_squash,sync,wdelay)<BR>/opt/dcl/data/disk2&nbsp;&nbsp;&nbsp;=
&nbsp;=20
*(rw,no_root_squash,sync,wdelay)<BR>root[vitorbelfort]:/var/log&gt;&nbsp;=
&nbsp;=20
grep . =
/proc/net/rpc/*/content<BR>/proc/net/rpc/auth.unix.ip/content:#class IP=20
domain<BR>/proc/net/rpc/auth.unix.ip/content:nfsd 172.19.15.102=20
*<BR>/proc/net/rpc/auth.unix.ip/content:nfsd 172.19.15.101=20
*<BR>/proc/net/rpc/auth.unix.ip/content:nfsd 172.19.15.97=20
*<BR>/proc/net/rpc/auth.unix.ip/content:nfsd 172.19.15.91=20
*<BR>/proc/net/rpc/auth.unix.ip/content:nfsd 172.19.15.92=20
*<BR>/proc/net/rpc/auth.unix.ip/content:nfsd 172.19.15.89=20
*<BR>/proc/net/rpc/nfs4.idtoname/content:#domain type id=20
[name]<BR>/proc/net/rpc/nfs4.nametoid/content:#domain type name=20
[id]<BR>/proc/net/rpc/nfsd.export/content:#path=20
domain(flags)<BR>/proc/net/rpc/nfsd.export/content:/opt/dcl/data/disk1&nb=
sp;&nbsp;=20
*(rw,no_root_squash,sync,wdelay)<BR>/proc/net/rpc/nfsd.export/content:/op=
t/dcl/data/disk2&nbsp;&nbsp;=20
*(rw,no_root_squash,sync,wdelay)<BR>/proc/net/rpc/nfsd.fh/content:#domain=
=20
fsidtype fsid [path]<BR>/proc/net/rpc/nfsd.fh/content:* 0 =
0x0300080000000080=20
/opt/dcl/data/disk1<BR>/proc/net/rpc/nfsd.fh/content:* 0 =
0x1100080000000080=20
/opt/dcl/data/disk2</FONT></P>
<P><FONT face=3DArial color=3D#ff00ff size=3D2>Regards,</FONT></P>
<P><FONT face=3DArial color=3D#ff00ff =
size=3D2>Edward.</FONT></P></BODY></HTML>

------_=_NextPart_001_01C5DEF9.085B485D--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
