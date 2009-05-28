From: "Smirnov, Alexander" <AlSmirnov-WEWivvub1mjQT0dZR+AlfA@public.gmane.org>
Subject: Re: NFSD for 2.6.30.rc7 problem
Date: Thu, 28 May 2009 11:13:15 +0400
Message-ID: <1CB6CF624D80D146921DF8431FF3D134A6B1ACEE4A@LEMUR.luxoft.com>
References: <1CB6CF624D80D146921DF8431FF3D134A6B1ACEE48@LEMUR.luxoft.com>,<20090527191143.GY18028@fieldses.org>,<1CB6CF624D80D146921DF8431FF3D134A6B1ACEE49@LEMUR.luxoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lama.luxoft.com ([217.74.46.11]:1920 "EHLO lama.luxoft.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753796AbZE1Hhs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2009 03:37:48 -0400
Received: from MSK-EDGE-01.luxoft.com by lama.luxoft.com
	(MDaemon PRO v9.0.4)
	with ESMTP id md50001676704.msg
	for <linux-nfs@vger.kernel.org>; Thu, 28 May 2009 11:13:17 +0400
In-Reply-To: <1CB6CF624D80D146921DF8431FF3D134A6B1ACEE49-/Q0dMsjZvzKLvz4rXgwZVQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I confirm that problem described by Wei Yongjun is the same problem that I have found.
Also I confirm the code change proposed by Wei Yongjun fill eliminate this problem.

b.r.

Alexander




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
+               *cnt = host_err;
                nfsdstats.io_write += host_err;
                fsnotify_modify(file->f_path.dentry);
        }
@@ -1060,10 +1061,9 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
        }

        dprintk("nfsd: write complete host_err=%d\n", host_err);
-       if (host_err >= 0) {
+       if (host_err >= 0)
                err = 0;
-               *cnt = host_err;
-       } else
+       else
                err = nfserrno(host_err);
 out:
        return err;
--
1.5.3.8






