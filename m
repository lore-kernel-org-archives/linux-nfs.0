From: Nathaniel Stahl <nrs@levanta.com>
Subject: NFS && loop == VFS: Busy inodes after unmount. Self-destruct in 5
 seconds.  Have a nice day...
Date: Mon, 14 Mar 2005 18:22:26 -0800
Message-ID: <423646E2.9040303@levanta.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080806010102050204080201"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DB1hU-0000rZ-6F
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 18:22:28 -0800
Received: from mail.levanta.com ([69.36.243.36] helo=mail.linuxcare.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DB1hT-0005h6-NU
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 18:22:28 -0800
Received: from [10.1.1.183] (cisco-6509.levanta.com [69.36.253.2] (may be forged))
	by mail.linuxcare.com (8.12.11/8.12.8) with ESMTP id j2F27qvk022822
	for <nfs@lists.sourceforge.net>; Mon, 14 Mar 2005 18:07:52 -0800
To: nfs@lists.sourceforge.net
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
--------------080806010102050204080201
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


On the 2.6 kernel, using NFS and the loopback device, I can trivially 
cause this to happen.  Create a container file on an NFS imported 
directory.  Make a filesystem in the container file, and loopback mount 
it.  Write another file onto that newly mounted filesystem, then unmount 
it and the original NFS filesystem that held the container.  Usually, 
the error will occur.

(Scripts and patches I've tried are reproduced at the end of the message)

The call path when the error occurs is:
sys_umount->_mntput->__mntput->deactivate_super->nfs_kill_super->
        kill_anon_super->generic_shutdown_super

nfs_kill_super calls kill_anon_super - which calls 
generic_shutdown_super, which outputs the message.

My guess was that some of the inodes are still being referenced by 
outstanding RPC operations.  Putting a call to 'rpc_show_tasks()' 
immediately after the call to kill_anon_super in nfs_kill_super produces 
output like:

(with nfsv3)
VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice 
day...
-pid- proc flgs status -client- -prog- --rqstp- -timeout -rpcwait 
-action- --exit--
11911 0021 0401 000000 de2b2e00 100003 cf251000 00060000 xprt_pending 
e0a65dc4 e0aa4ee8

 From kallsyms: e0a65dc4 == call_status, e0aa4ee8 = nfs3_commit_done

nfs_commit_done calls nfs_inode_remove_request, which can release an 
inode reference...

When a file is closed (via sys_close) it calls the filesystem flush 
operation.  The loop device doesn't do this.  If I update loop.c to call 
the f_op->flush on the file pointer prior to the file backing the 
loopback device being released, the VFS error doesn't occur (at least 
not trivially with those scripts on 2.6.11.3).  mmaps will also call 
fput without calling flush, but I can't seem to reproduce the problem 
this way, so maybe that's a red herring.  Changing the loop device to 
call sync_page_range prior to releasing the file also seems to solve the 
problem.  Should one or both of these be done?  (Perhaps neither?)

Any ideas would be appreciated.

############################################################

Without any patches, changing the NFS mount options to 'sync' - in a 
more complicated senario using our control software and not the simple 
scripts generates errors like:

kernel: Buffer I/O error on device loop1, logical block 2368
Mar 11 13:45:12 sandevel kernel: lost page write due to I/O error on loop1

I haven't been able to reproduce this using my simpler scripts.

(nfsvers=2/sync full system)
Buffer I/O error on device loop1, logical block 2396
lost page write due to I/O error on loop1
-pid- proc flgs status -client- -prog- --rqstp- -timeout -rpcwait 
-action- --exit--
03133 0004 0080 000000 de15e400 100003 d7501000 00060000 xprt_pending 
e0a65dc4        0
03182 0008 0080 000000 de16de00 100003 d36d40ac 00060000 xprt_pending 
e0a65dc4        0
03183 0008 0080 000000 d2c22a00 100003 dd66a60c 00060000 xprt_pending 
e0a65dc4        0

############################################################

# With an NFS filesystem exported from $SERVERDIR to the client
# This usually causes the problem to occur.

SERVERDIR=172.31.37.2:/mnt/test
NFSDIR=/mnt/test
LOOPDIR=/mnt/loop

mkdir -p $NFSDIR $LOOPDIR
mount -t nfs $SERVERDIR $NFSDIR
dd if=/dev/zero of=$NFSDIR/filesystem bs=1024 seek=102400 count=1
mke2fs -F $NFSDIR/filesystem
mount -o loop $NFSDIR/filesystem $LOOPDIR
dd if=/dev/zero of=$LOOPDIR/foo bs=1024 count=1000
umount $LOOPDIR
umount $NFSDIR

############################################################

# This one is slightly more likely to generate the error.

SERVERDIR=172.31.37.2:/mnt/test
SERVERDIR2=172.31.37.2:/mnt/test2
NFSDIR=/mnt/test
NFSDIR2=/mnt/test2
LOOPDIR=/mnt/loop
LOOPDIR2=/mnt/loop2

mkdir -p $NFSDIR $NFSDIR2 $LOOPDIR $LOOPDIR2
mount -t nfs -o nfsvers=2 $SERVERDIR $NFSDIR
mount -t nfs -o nfsvers=2 $SERVERDIR2 $NFSDIR2
dd if=/dev/zero of=$NFSDIR/filesystem bs=1024 seek=102400 count=1
dd if=/dev/zero of=$NFSDIR2/filesystem bs=1024 seek=102400 count=1
mke2fs -F $NFSDIR/filesystem
mke2fs -F $NFSDIR2/filesystem
mount -o loop $NFSDIR/filesystem $LOOPDIR
mount -o loop $NFSDIR2/filesystem $LOOPDIR2
dd if=/dev/zero of=$LOOPDIR/foo bs=1024 count=1000
dd if=/dev/zero of=$LOOPDIR2/foo bs=1024 count=1000
umount $LOOPDIR
umount $NFSDIR
umount $LOOPDIR2
umount $NFSDIR2


--------------080806010102050204080201
Content-Type: text/x-patch;
 name="loop.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="loop.patch"

--- linux-2.6.11.2/drivers/block/loop.c.orig	2005-03-10 23:22:12.000000000 -0800
+++ linux-2.6.11.2/drivers/block/loop.c	2005-03-10 23:22:21.000000000 -0800
@@ -608,6 +608,12 @@
 	if (get_loop_size(lo, file) != get_loop_size(lo, old_file))
 		goto out_putf;
 
+	if (old_file->f_op && old_file->f_op->flush) {
+		error = old_file->f_op->flush(old_file);
+		if (error)
+			goto out_putf;
+	}
+
 	/* and ... switch */
 	error = loop_switch(lo, file);
 	if (error)
@@ -820,6 +826,10 @@
 	bd_set_size(bdev, 0);
 	mapping_set_gfp_mask(filp->f_mapping, gfp);
 	lo->lo_state = Lo_unbound;
+
+	if (filp->f_op && filp->f_op->flush)
+		filp->f_op->flush(filp);
+
 	fput(filp);
 	/* This is safe: open() is still holding a reference. */
 	module_put(THIS_MODULE);

--------------080806010102050204080201
Content-Type: text/x-patch;
 name="loop2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="loop2.patch"

610a611,626
> /*
> 	if (old_file->f_op && old_file->f_op->flush) {
> 		error = old_file->f_op->flush(old_file);
> 		if (error)
> 			goto out_putf;
> 	}
> */
> 	error = sync_page_range(old_file->f_dentry->d_inode,
> 		old_file->f_dentry->d_inode->i_mapping, 0,
> 		i_size_read(old_file->f_dentry->d_inode));
> 	if (error) {
> 		char b[BDEVNAME_SIZE];
> 		printk(KERN_WARNING "Failed to sync all pages for old backing "
> 			"file of loop device %s.\n", bdevname(bdev,b));
> 	}
> 
785a802
> 	int err;
803a821,829
> 	err = sync_page_range(filp->f_dentry->d_inode,
> 		filp->f_dentry->d_inode->i_mapping, 0,
> 		i_size_read(filp->f_dentry->d_inode));
> 	if (err) {
> 		char b[BDEVNAME_SIZE];
> 		printk(KERN_WARNING "Failed to sync all pages for old backing "
> 			"file of loop device %s.\n", bdevname(bdev,b));
> 	}
> 
822a849,854
> 
> /*
> 	if (filp->f_op && filp->f_op->flush)
> 		filp->f_op->flush(filp);
> */
> 

--------------080806010102050204080201--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
