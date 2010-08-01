Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49711 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751358Ab0HARK7 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Aug 2010 13:10:59 -0400
In-Reply-To: <20100801064415.GA10523@elte.hu>
References: <1280519035.12852.32.camel@heimdal.trondhjem.org>
	<20100801064415.GA10523@elte.hu>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 1 Aug 2010 10:10:02 -0700
Message-ID: <AANLkTim=6q1FC8YZvmi2Cju_6+00mHHkNPpCLHB8e3=h@mail.gmail.com>
Subject: Re: [PATCH] NFS: Fix build failure on !CONFIG_NFS_V3 &&
	!CONFIG_NFS_V3
To: Ingo Molnar <mingo@elte.hu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jul 31, 2010 at 11:44 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> FYI, these commits introduced a build failure on x86:
>
>  fs/nfs/file.c:508: error: implicit declaration of function ‘nfs_commit_inode’

Grr. Trond?

> @@ -492,11 +492,9 @@ extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
>  extern int nfs_wb_all(struct inode *inode);
>  extern int nfs_wb_page(struct inode *inode, struct page* page);
>  extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
> -#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
>  extern int  nfs_commit_inode(struct inode *, int);
>  extern struct nfs_write_data *nfs_commitdata_alloc(void);
>  extern void nfs_commit_free(struct nfs_write_data *wdata);
> -#endif

No, I think perhaps the '#if' line should just be moved down one line.
The other function still only exist for V3/V4, it's just
nfs_commit_inode() that is available (as a stub that just returns 0)
for V2.

But maybe that stub should be made an inline function or #define?

Trond?

                  Linus
