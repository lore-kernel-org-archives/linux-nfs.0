From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] nfsd: fix hung up of nfs client while sync write data to
 nfs server
Date: Tue, 19 May 2009 12:03:15 +0800
Message-ID: <4A122F83.4020606@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
To: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49836 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750750AbZESEGq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 May 2009 00:06:46 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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



