From: Bruce Allan <bruce.allan@us.ibm.com>
Subject: NFS lockd and clustered filesystems
Date: Fri, 27 Feb 2004 15:55:52 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF64DBF011.B2C89360-ON08256E43.007A05D6-08256E47.0083756B@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=87BBE4D0DFE983468f9e8a93df938690918c87BBE4D0DFE98346"
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Awrsc-0002NV-5b
	for nfs@lists.sourceforge.net; Fri, 27 Feb 2004 15:58:54 -0800
Received: from e34.co.us.ibm.com ([32.97.110.132])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1Awraw-0006Yp-BP
	for nfs@lists.sourceforge.net; Fri, 27 Feb 2004 15:40:38 -0800
To: trond.myklebust@fys.uio.no
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

--0__=87BBE4D0DFE983468f9e8a93df938690918c87BBE4D0DFE98346
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable






Hi Trond,

I've been asked to look into an issue that has been previously discusse=
d
both on and off the lkml.  The issue is with lockd not invoking a
filesystem-specific locking function if one is defined, such as with
out-of-tree cluster filesystems.  You may recall the discussions you ha=
d
with Brian Dixon regarding this sometime ago [1]; you didn't like Brian=
's
patch because such a filesystem call could hang the single-threaded loc=
kd.
As I understand it, there was further (off-list?) discussion regarding
making lockd multi-threaded to get around this problem.  In light of re=
cent
announcements/discussions regarding cluster filesystems on Linux (eg.
RedHat's acquisition of Sistina, Linus' remarks about clustered filesys=
tems
being one of the main things to work on for 2.7), is the time right to
re-address this matter?  How receptive would you be to these previous
patches (including the multi-threaded lockd patch) being ported to 2.6,=
 or
would you prefer another method?

[1] - http://marc.theaimsgroup.com/?l=3Dlinux-kernel&m=3D10204585360394=
4&w=3D2

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187=

--0__=87BBE4D0DFE983468f9e8a93df938690918c87BBE4D0DFE98346
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>Hi Trond,<br>
<br>
I've been asked to look into an issue that has been previously discusse=
d both on and off the lkml.  The issue is with lockd not invoking a fil=
esystem-specific locking function if one is defined, such as with out-o=
f-tree cluster filesystems.  You may recall the discussions you had wit=
h Brian Dixon regarding this sometime ago [1]; you didn't like Brian's =
patch because such a filesystem call could hang the single-threaded loc=
kd.  As I understand it, there was further (off-list?) discussion regar=
ding making lockd multi-threaded to get around this problem.  In light =
of recent announcements/discussions regarding cluster filesystems on Li=
nux (eg. RedHat's acquisition of Sistina, Linus' remarks about clustere=
d filesystems being one of the main things to work on for 2.7), is the =
time right to re-address this matter?  How receptive would you be to th=
ese previous patches (including the multi-threaded lockd patch) being p=
orted to 2.6, or would you prefer another method?<br>
<br>
[1] - <a href=3D"http://marc.theaimsgroup.com/?l=3Dlinux-kernel&m=3D102=
045853603944&w=3D2">http://marc.theaimsgroup.com/?l=3Dlinux-kernel&amp;=
m=3D102045853603944&amp;w=3D2</a><br>
<br>
Regards,<br>
---<br>
Bruce Allan  &lt;bruce.allan@us.ibm.com&gt;<br>
Software Engineer, Linux Technology Center<br>
IBM Corporation, Beaverton OR<br>
503-578-4187   IBM Tie-line 775-4187<br>
</body></html>=

--0__=87BBE4D0DFE983468f9e8a93df938690918c87BBE4D0DFE98346--



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
