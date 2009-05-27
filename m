From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSD for 2.6.30.rc7 problem
Date: Wed, 27 May 2009 15:11:43 -0400
Message-ID: <20090527191143.GY18028@fieldses.org>
References: <1CB6CF624D80D146921DF8431FF3D134A6B1ACEE48@LEMUR.luxoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Smirnov, Alexander" <AlSmirnov-WEWivvub1mjQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:52002 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762567AbZE0TLm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 May 2009 15:11:42 -0400
In-Reply-To: <1CB6CF624D80D146921DF8431FF3D134A6B1ACEE48-/Q0dMsjZvzKLvz4rXgwZVQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 27, 2009 at 02:32:47PM +0400, Smirnov, Alexander wrote:
> Hello everybody,
> 
> During test of NFS software I've found the problem in Linux kernel (nfsd)
> 
> On the NFS4_WRITE request (data len=44), NFS server is responding with NFS4_OK (bytes written count = 0) that follows to
> cycliing in write request on client side.

Your problem looks the same as the following--could you confirm the fix?

--b.

From: Wei Yongjun <yjwei@cn.fujitsu.com>
To: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Subject: [PATCH] nfsd: fix hung up of nfs client while sync write data to
 nfs server

Commit 'Short write in nfsd becomes a full write to the client'
(31dec2538e45e9fff2007ea1f4c6bae9f78db724) broken the sync write.
With the following commands to reproduce:

  $ mount -t nfs -o sync 192.168.0.21:/nfsroot /mnt
  $ cd /mnt
  $ echo aaaa > temp.txt

Then nfs client is hung up.

In SYNC mode the server alaways return the write count 0 to the
client. This is because the value of host_err in nfsd_vfs_write()
will be overwrite in SYNC mode by 'host_err=nfsd_sync(file);',
and then we return host_err(which is now 0) as write count.

This patch fixed the problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 fs/nfsd/vfs.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6c68ffd..b660435 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1015,6 +1015,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);
 	set_fs(oldfs);
 	if (host_err >= 0) {
+		*cnt = host_err;
 		nfsdstats.io_write += host_err;
 		fsnotify_modify(file->f_path.dentry);
 	}
@@ -1060,10 +1061,9 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	}
 
 	dprintk("nfsd: write complete host_err=%d\n", host_err);
-	if (host_err >= 0) {
+	if (host_err >= 0)
 		err = 0;
-		*cnt = host_err;
-	} else
+	else
 		err = nfserrno(host_err);
 out:
 	return err;
-- 
1.5.3.8




