From: "Don Allingham" <Don.Allingham@dothill.com>
Subject: Re: NFS randomly denying permission to files
Date: Thu, 1 Feb 2007 21:55:45 -0700
Message-ID: <9DDB513B94253445879B44C250C9BD9A07360F39@venusex1.power.com>
References: <1170369756.1221.8.camel@allingham.power.com><17858.28322.401622.364015@notabene.brown><9DDB513B94253445879B44C250C9BD9A07360F37@venusex1.power.com>
	<17858.37517.24831.277303@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1240478541=="
Cc: nfs@lists.sourceforge.net
To: "Neil Brown" <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCqW4-0001dE-7X
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 20:59:20 -0800
Received: from artecon.dothill.com ([155.254.128.254] helo=dothill.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCqW3-00042x-PM
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 20:59:18 -0800
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

This is a multi-part message in MIME format.

--===============1240478541==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C74686.DE8ED654"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C74686.DE8ED654
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


I've attached the results of tune2fs. The filesystem is a ext3 RAID0 =
configuration (/dev/md0) of two fibre channel arrays (a 1TB external =
RAID box configured as a two RAID5 arrays).

root@vlsi-fs0:~# tune2fs -l /dev/md0
tune2fs 1.39 (29-May-2006)
Filesystem volume name:   <none>
Last mounted on:          <not available>
Filesystem UUID:          912e625d-24fc-46ba-ab23-1965d7bc6623
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
Filesystem features:      has_journal resize_inode dir_index filetype =
needs_recovery sparse_super large_ file
Default mount options:    (none)
Filesystem state:         clean
Errors behavior:          Continue
Filesystem OS type:       Linux
Inode count:              143622144
Block count:              287242144
Reserved block count:     14362107
Free blocks:              282684137
Free inodes:              143622133
First block:              0
Block size:               4096
Fragment size:            4096
Reserved GDT blocks:      955
Blocks per group:         32768
Fragments per group:      32768
Inodes per group:         16384
Inode blocks per group:   512
Filesystem created:       Wed Jan 31 21:47:49 2007
Last mount time:          Wed Jan 31 22:06:41 2007
Last write time:          Wed Jan 31 22:06:41 2007
Mount count:              3
Maximum mount count:      38
Last checked:             Wed Jan 31 21:47:49 2007
Check interval:           15552000 (6 months)
Next check after:         Mon Jul 30 22:47:49 2007
Reserved blocks uid:      0 (user root)
Reserved blocks gid:      0 (group root)
First inode:              11
Inode size:               128
Journal inode:            8
First orphan inode:       139690025
Default directory hash:   tea
Directory Hash Seed:      628a4a04-a659-46fd-8182-def39afe85fa
Journal backup:           inode blocks


-----Original Message-----
From: Neil Brown [mailto:neilb@suse.de]
Sent: Thu 2/1/2007 6:23 PM
To: Don Allingham
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] NFS randomly denying permission to files
=20
On Thursday February 1, Don.Allingham@dothill.com wrote:
>=20
> Kernel version for the server and clients are (uname -a):
>=20
> Linux vlsi-fs0 2.6.17-10-generic #2 SMP Tue Dec 5 21:16:35 UTC 2006 =
x86_64 GNU/Linux
>=20
> The no_subtree_check option seems to have made a big difference.=20

Hmmm... The bug I was thinking of (affected ext3 with dir_index if you
didn't use no_subtree_check) was fixed will before 2.6.17 came out.

What filesystem are you using?  If ext3, what does
  tune2fs -l /dev/XXXX
say (for the device holding the filesystem).

>=20
> I'm not familar with tcpdump. However, the new system is on a 1G
> ethernet link, and the old was on a 10/100 link. However, I will
> investigate this if I start seeing the problem again.=20

I wouldn't both.  If no_subtree_check fixes it, then tcpdump won't
show us anything interesting.

NeilBrown


------_=_NextPart_001_01C74686.DE8ED654
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7650.28">
<TITLE>RE: [NFS] NFS randomly denying permission to files</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->
<BR>

<P><FONT SIZE=3D2>I've attached the results of tune2fs. The filesystem =
is a ext3 RAID0 configuration (/dev/md0) of two fibre channel arrays (a =
1TB external RAID box configured as a two RAID5 arrays).<BR>
<BR>
root@vlsi-fs0:~# tune2fs -l /dev/md0<BR>
tune2fs 1.39 (29-May-2006)<BR>
Filesystem volume name:&nbsp;&nbsp; &lt;none&gt;<BR>
Last mounted on:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&lt;not available&gt;<BR>
Filesystem UUID:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
912e625d-24fc-46ba-ab23-1965d7bc6623<BR>
Filesystem magic number:&nbsp; 0xEF53<BR>
Filesystem revision #:&nbsp;&nbsp;&nbsp; 1 (dynamic)<BR>
Filesystem features:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; has_journal =
resize_inode dir_index filetype needs_recovery sparse_super large_ =
file<BR>
Default mount options:&nbsp;&nbsp;&nbsp; (none)<BR>
Filesystem state:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
clean<BR>
Errors behavior:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
Continue<BR>
Filesystem OS type:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Linux<BR>
Inode =
count:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; 143622144<BR>
Block =
count:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; 287242144<BR>
Reserved block count:&nbsp;&nbsp;&nbsp;&nbsp; 14362107<BR>
Free =
blocks:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; 282684137<BR>
Free =
inodes:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; 143622133<BR>
First =
block:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; 0<BR>
Block =
size:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; 4096<BR>
Fragment =
size:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
4096<BR>
Reserved GDT blocks:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 955<BR>
Blocks per group:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
32768<BR>
Fragments per group:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 32768<BR>
Inodes per group:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
16384<BR>
Inode blocks per group:&nbsp;&nbsp; 512<BR>
Filesystem created:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Wed Jan 31 =
21:47:49 2007<BR>
Last mount time:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
Wed Jan 31 22:06:41 2007<BR>
Last write time:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
Wed Jan 31 22:06:41 2007<BR>
Mount =
count:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; 3<BR>
Maximum mount count:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 38<BR>
Last =
checked:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; Wed Jan 31 21:47:49 2007<BR>
Check =
interval:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
15552000 (6 months)<BR>
Next check after:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Mon =
Jul 30 22:47:49 2007<BR>
Reserved blocks uid:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 (user root)<BR>
Reserved blocks gid:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 (group root)<BR>
First =
inode:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; 11<BR>
Inode =
size:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; 128<BR>
Journal =
inode:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
8<BR>
First orphan inode:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 139690025<BR>
Default directory hash:&nbsp;&nbsp; tea<BR>
Directory Hash Seed:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
628a4a04-a659-46fd-8182-def39afe85fa<BR>
Journal =
backup:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
inode blocks<BR>
<BR>
<BR>
-----Original Message-----<BR>
From: Neil Brown [<A =
HREF=3D"mailto:neilb@suse.de">mailto:neilb@suse.de</A>]<BR>
Sent: Thu 2/1/2007 6:23 PM<BR>
To: Don Allingham<BR>
Cc: nfs@lists.sourceforge.net<BR>
Subject: Re: [NFS] NFS randomly denying permission to files<BR>
<BR>
On Thursday February 1, Don.Allingham@dothill.com wrote:<BR>
&gt;<BR>
&gt; Kernel version for the server and clients are (uname -a):<BR>
&gt;<BR>
&gt; Linux vlsi-fs0 2.6.17-10-generic #2 SMP Tue Dec 5 21:16:35 UTC 2006 =
x86_64 GNU/Linux<BR>
&gt;<BR>
&gt; The no_subtree_check option seems to have made a big =
difference.<BR>
<BR>
Hmmm... The bug I was thinking of (affected ext3 with dir_index if =
you<BR>
didn't use no_subtree_check) was fixed will before 2.6.17 came out.<BR>
<BR>
What filesystem are you using?&nbsp; If ext3, what does<BR>
&nbsp; tune2fs -l /dev/XXXX<BR>
say (for the device holding the filesystem).<BR>
<BR>
&gt;<BR>
&gt; I'm not familar with tcpdump. However, the new system is on a =
1G<BR>
&gt; ethernet link, and the old was on a 10/100 link. However, I =
will<BR>
&gt; investigate this if I start seeing the problem again.<BR>
<BR>
I wouldn't both.&nbsp; If no_subtree_check fixes it, then tcpdump =
won't<BR>
show us anything interesting.<BR>
<BR>
NeilBrown<BR>
<BR>
</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C74686.DE8ED654--


--===============1240478541==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1240478541==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1240478541==--
