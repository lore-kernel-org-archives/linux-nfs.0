From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.24-rc3 unable to mount something which should use nohide
Date: Thu, 29 Nov 2007 12:41:35 -0500
Message-ID: <1196358095.7808.24.camel@heimdal.trondhjem.org>
References: <1196354699.2912.57.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-XffS05sknRG4/kFtaHnb"
Cc: linux-nfs@vger.kernel.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:42232 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754239AbXK2Rlk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2007 12:41:40 -0500
In-Reply-To: <1196354699.2912.57.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-XffS05sknRG4/kFtaHnb
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Thu, 2007-11-29 at 11:44 -0500, Eric Paris wrote:
> NFS server "paris" (some 2.6.18 based kernel):
> 
> [root@paris ~]# mount | grep storage
> /dev/mapper/StorageVG01-LogVol00 on /export/storage type ext3 (rw)
> /dev/mapper/KernelVG01-LogVol00 on /export/storage/kernel type ext3 (rw)
> [root@paris ~]# cat /etc/exports
> /export/storage         *(rw,sync,all_squash,anonuid=500,anongid=500)
> /export/storage/kernel  *(rw,sync,all_squash,anonuid=500,anongid=500,nohide)
> 
> On my clients x86_64 running an almost clean-from-git 2.6.24-rc3 kernel:
> 
> [root@dhcp231-145 ~]# mount -o noatime paris:/export/storage /storage
> [root@dhcp231-145 ~]# ls /storage/kernel
> ls: cannot access /storage/kernel: Stale NFS file handle
> 
> (notice /storage/kernel should be triggering that nohide mount
> for /export/storage/kernel) so I figured maybe that automatic nohide
> stuff was broken.  I'll try by hand:
> 
> [root@dhcp231-145 ~]# mount paris:/export/storage/kernel /storage/kernel
> mount.nfs: Stale NFS file handle
> 
> Same thing.  Nothing in dmesg or /var/log/messages.  I know this worked
> not long ago....

Yep. I think the following patch ought to fix it.

Cheers
  Trond



--=-XffS05sknRG4/kFtaHnb
Content-Disposition: inline; filename=fix_mountpoint_crossing.dif
Content-Type: text/plain; name=fix_mountpoint_crossing.dif; charset=utf-8
Content-Transfer-Encoding: 7bit

commit 72e40add4adad50613083f1fda117fd74aa875ac
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Nov 29 12:39:46 2007 -0500

    NFS: Fix NFS mountpoint crossing...
    
    The check that was added to nfs_xdev_get_sb() to work around broken
    servers, works fine for NFSv2, but causes mountpoint crossing on NFSv3 to
    always return ESTALE.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2426e71..ea92920 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1475,7 +1475,7 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type, int flags,
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
 	}
-	if (mntroot->d_inode->i_op != &nfs_dir_inode_operations) {
+	if (mntroot->d_inode->i_op != server->nfs_client->rpc_ops->dir_inode_ops) {
 		dput(mntroot);
 		error = -ESTALE;
 		goto error_splat_super;

--=-XffS05sknRG4/kFtaHnb--

