From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS && loop == VFS: Busy inodes after unmount.
	Self-destruct in 5 seconds.  Have a nice day...
Date: Mon, 14 Mar 2005 22:40:27 -0500
Message-ID: <1110858027.22328.1.camel@lade.trondhjem.org>
References: <423646E2.9040303@levanta.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-HMFsnVFsmq8tDLk8jzdJ"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DB2vC-0004P7-Sc
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 19:40:42 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DB2vB-0002ay-2k
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 19:40:42 -0800
To: Nathaniel Stahl <nrs@levanta.com>
In-Reply-To: <423646E2.9040303@levanta.com>
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


--=-HMFsnVFsmq8tDLk8jzdJ
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

m=E5 den 14.03.2005 Klokka 18:22 (-0800) skreiv Nathaniel Stahl:
> On the 2.6 kernel, using NFS and the loopback device, I can trivially=20
> cause this to happen.  Create a container file on an NFS imported=20
> directory.  Make a filesystem in the container file, and loopback mount=20
> it.  Write another file onto that newly mounted filesystem, then unmount=20
> it and the original NFS filesystem that held the container.  Usually,=20
> the error will occur.
>=20
> (Scripts and patches I've tried are reproduced at the end of the message)
>=20
> The call path when the error occurs is:
> sys_umount->_mntput->__mntput->deactivate_super->nfs_kill_super->
>         kill_anon_super->generic_shutdown_super
>=20
> nfs_kill_super calls kill_anon_super - which calls=20
> generic_shutdown_super, which outputs the message.
>=20
> My guess was that some of the inodes are still being referenced by=20
> outstanding RPC operations.  Putting a call to 'rpc_show_tasks()'=20
> immediately after the call to kill_anon_super in nfs_kill_super produces=20
> output like:

Coincidentally, I just got a similar bugreport. Could you try out the
following patch to the NFS client?

Cheers,
  Trond
--=20
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-HMFsnVFsmq8tDLk8jzdJ
Content-Disposition: inline; filename=linux-2.6.11-00-fix_munmap.dif
Content-Type: text/plain; name=linux-2.6.11-00-fix_munmap.dif; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

NFS: Ensure that dirty pages are written with the right creds.

 When doing shared mmap writes, the resulting dirty NFS pages may
 find themselves incapable of being flushed out if I/O is started
 after the file was released.
 Make sure we start I/O on all existing dirty pages in nfs_file_release().

 Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 file.c |    3 +++
 1 files changed, 3 insertions(+)

Index: linux-2.6.11-up/fs/nfs/file.c
===================================================================
--- linux-2.6.11-up.orig/fs/nfs/file.c
+++ linux-2.6.11-up/fs/nfs/file.c
@@ -108,6 +108,9 @@ nfs_file_open(struct inode *inode, struc
 static int
 nfs_file_release(struct inode *inode, struct file *filp)
 {
+	/* Ensure that dirty pages are flushed out with the right creds */
+	if (filp->f_mode & FMODE_WRITE)
+		filemap_fdatawrite(filp->f_mapping);
 	return NFS_PROTO(inode)->file_release(inode, filp);
 }
 

--=-HMFsnVFsmq8tDLk8jzdJ--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
