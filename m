From: "Vivek Goyal" <vivek.goyal@wipro.com>
Subject: RE: Disabling Symbolic Link Content Caching in NFS Client
Date: Tue, 3 Jun 2003 18:50:34 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <2BB7146B38D9CA40B215AB3DAAE24C080BA622@blr-m2-msg.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <viro@math.psu.edu>, <davem@redhat.com>, <ezk@cs.sunysb.edu>,
   <indou.takao@jp.fujitsu.com>, <nfs@lists.sourceforge.net>,
   <linux-kernel@vger.kernel.org>, "Vivek Goyal" <vivek.goyal@wipro.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from wiprom2mx1.wipro.com ([203.197.164.41])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19NBiv-0008It-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Jun 2003 06:21:09 -0700
To: <trond.myklebust@fys.uio.no>, "Ion Badulescu" <ionut@badula.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> >>>>> " " =3D=3D Ion Badulescu <ionut@badula.org> writes:
>     >> 1. Make nfs_symlink_caching dynamically tunable using /proc and
>     >> sysctl interface.
>      > No. Do it on a per-mount basis, like the other OS's do.
>=20
> As I said to Vivek in a private mail, it would be very nice to see
> if this could be done by replacing hlfsd with namespace groups.
>=20
> Al Viro has already done all the VFS layer work, which should be ready
> and working in existing 2.4.20 and 2.5.x kernels. What is missing is
> userland support for doing a CLONE_NEWNS, and then mounting the user's
> home directory, mailspool,.... in the appropriate locations at login
> time.

Yes, this could be a better way to tackle hlfsd issues.

<snip from Trond's mail>

>I'm not overly keen on this proposal. IMHO we want to *maximize*
caching >rather than reduce it. This is particularly important as the
speed of >networks etc. starts to approach that of the PCI bus on the
server.

<end of snip>

You are right. But our idea is to provide an option to disable/enable
caching based on the nature of intended application.

With this, Linux will have enhanced flexibility in NFS client like other
operating systems. For example.

1. Solaris provides dynamically tunable parameter "nfs_do_symlink_cache"
for enabling/disabling symlink caching.

2. UNIX and IRIX provide 'symttl' mount option for enabling/disabling
symbolic link content caching in NFS client.

Kindly let me know your comments.

Regards,
Vivek



-------------------------------------------------------
This SF.net email is sponsored by: eBay
Get office equipment for less on eBay!
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
