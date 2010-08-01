Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:40960 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368Ab0HAGo1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Aug 2010 02:44:27 -0400
Date: Sun, 1 Aug 2010 08:44:15 +0200
From: Ingo Molnar <mingo@elte.hu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] NFS: Fix build failure on !CONFIG_NFS_V3 && !CONFIG_NFS_V3
Message-ID: <20100801064415.GA10523@elte.hu>
References: <1280519035.12852.32.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1280519035.12852.32.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


* Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> Hi Linus,
> 
> Please pull from the "bugfixes" branch of the repository at
> 
>    git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes
> 
> This will update the following files through the appended changesets.
> 
>   Cheers,
>     Trond
> 
> ----
>  fs/nfs/file.c          |   13 +++++++++++--
>  fs/nfs/nfsroot.c       |    2 +-
>  fs/nfs/write.c         |   27 +++++++++++++++++++--------
>  include/linux/nfs_fs.h |    1 +
>  4 files changed, 32 insertions(+), 11 deletions(-)

FYI, these commits introduced a build failure on x86:

  fs/nfs/file.c:508: error: implicit declaration of function ‘nfs_commit_inode’

The nfs_commit_inode() prototype:

 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_write_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_write_data *wdata);
 #endif

is missing if the kernel is configured for legacy NFS:

 CONFIG_NFS_FS=y
 # CONFIG_NFS_V3 is not set
 # CONFIG_NFS_V4 is not set

The fix below solves the build problem here, but I have not tested whether NFS 
still works fine for this config.

Thanks,

	Ingo

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 include/linux/nfs_fs.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f6e2455..bf145c6 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -492,11 +492,9 @@ extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
 extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_write_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_write_data *wdata);
-#endif
 
 static inline int
 nfs_have_writebacks(struct inode *inode)
