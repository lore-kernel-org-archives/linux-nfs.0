Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:45441 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229Ab0HPKkR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Aug 2010 06:40:17 -0400
Date: Mon, 16 Aug 2010 12:40:15 +0200
Message-ID: <s5hfwyelu28.wl%tiwai@suse.de>
From: Takashi Iwai <tiwai@suse.de>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Trond.Myklebust@netapp.com, rjw@sisk.pl, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: nfs regression 2.6.35+
In-Reply-To: <s5h39uedg3b.wl%tiwai@suse.de>
References: <20100816070626.GA10503@sli10-desk.sh.intel.com>
	<s5h39uedg3b.wl%tiwai@suse.de>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

At Mon, 16 Aug 2010 12:09:12 +0200, Takashi Iwai wrote:
> At Mon, 16 Aug 2010 15:06:26 +0800,
> Shaohua Li wrote:
> > 
> > NFS client runs latest git. At client side, use vim to edit a file located at
> > NFS server. If I save the file, vim always reports 'E667: Fsync failed'. If I
> > revert f7fa16506bf9b6323e862a61e14c20555152bb3, vim works. No kernel errors
> > reported.
> 
> This hits me, too.  Reverting it cures the problem.
> (BTW, the correct commit id of the affecting patch is
>  af7fa16506bf9b6323e862a61e14c20555152bb3
>  "NFS: Fix up the fsync code")
> 
> Reproduced on 2.6.36-rc1.
> 
> Looking at strace output, 
> 
>   open("afo", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 4
>   write(4, "#!/bin\n", 7)                 = 7
>   fsync(4)                                = 1
>   stat("afo", {st_mode=S_IFREG|0644, st_size=7, ...}) = 0
>   close(4)                                = 0
> 
> So, fsync() returns 1 wrongly.

How about a band-aid fix below?


Takashi


>From c75eab5ac47f5ce27a0d450423f8c46824f832f0 Mon Sep 17 00:00:00 2001
From: Takashi Iwai <tiwai@suse.de>
Date: Mon, 16 Aug 2010 12:25:19 +0200
Subject: [PATCH] NFS: fix fsync return code

With the commit af7fa16506bf9b6323e862a61e14c20555152bb3
    NFS: Fix up the fsync code
fsync returns a postive number for success incorrectly because now it
calls nfs_commit_inode() which returns the number of pages.

This patch makes fsync simply ignore a positive return value.

Signed-off-by: Takashi Iwai <tiwai@suse.de>
---
 fs/nfs/file.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 2d141a7..eb51bd6 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -323,7 +323,7 @@ nfs_file_fsync(struct file *file, int datasync)
 	have_error |= test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 	if (have_error)
 		ret = xchg(&ctx->error, 0);
-	if (!ret)
+	if (!ret && status < 0)
 		ret = status;
 	return ret;
 }
-- 
1.7.2.1

