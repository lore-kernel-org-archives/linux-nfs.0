From: "Edward Hibbert" <Edward.Hibbert@dataconnection.com>
Subject: RE: Stale NFS mounts
Date: Tue, 1 Nov 2005 10:58:28 -0000
Message-ID: <9E621559095AA746B22B21CD4FAF99A54E3140@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5DED3.30E80C21"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EWtqf-0006S3-M1
	for nfs@lists.sourceforge.net; Tue, 01 Nov 2005 02:58:37 -0800
Received: from smtp.dataconnection.com ([192.91.191.4])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EWtqe-00056S-6e
	for nfs@lists.sourceforge.net; Tue, 01 Nov 2005 02:58:37 -0800
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

------_=_NextPart_001_01C5DED3.30E80C21
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

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


------_=_NextPart_001_01C5DED3.30E80C21
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD><TITLE></TITLE>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2800.1515" name=3DGENERATOR></HEAD>
<BODY>
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

------_=_NextPart_001_01C5DED3.30E80C21--


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
