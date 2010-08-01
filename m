Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28617 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751392Ab0HARfU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Aug 2010 13:35:20 -0400
Subject: Re: [PATCH] NFS: Fix build failure on !CONFIG_NFS_V3 &&
 !CONFIG_NFS_V3
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>
In-Reply-To: <AANLkTim=6q1FC8YZvmi2Cju_6+00mHHkNPpCLHB8e3=h@mail.gmail.com>
References: <1280519035.12852.32.camel@heimdal.trondhjem.org>
	 <20100801064415.GA10523@elte.hu>
	 <AANLkTim=6q1FC8YZvmi2Cju_6+00mHHkNPpCLHB8e3=h@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 01 Aug 2010 13:35:00 -0400
Message-ID: <1280684100.4430.8.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2010-08-01 at 10:10 -0700, Linus Torvalds wrote:
> On Sat, Jul 31, 2010 at 11:44 PM, Ingo Molnar <mingo@elte.hu> wrote:
> >
> > FYI, these commits introduced a build failure on x86:
> >
> >  fs/nfs/file.c:508: error: implicit declaration of function ‘nfs_commit_inode’
> 
> Grr. Trond?

Sorry. I was intending to put that declaration outside the #ifdef. The
stub function is still declared in fs/nfs/write.c

> > @@ -492,11 +492,9 @@ extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
> >  extern int nfs_wb_all(struct inode *inode);
> >  extern int nfs_wb_page(struct inode *inode, struct page* page);
> >  extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
> > -#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
> >  extern int  nfs_commit_inode(struct inode *, int);
> >  extern struct nfs_write_data *nfs_commitdata_alloc(void);
> >  extern void nfs_commit_free(struct nfs_write_data *wdata);
> > -#endif
> 
> No, I think perhaps the '#if' line should just be moved down one line.
> The other function still only exist for V3/V4, it's just
> nfs_commit_inode() that is available (as a stub that just returns 0)
> for V2.
> 
> But maybe that stub should be made an inline function or #define?
> 
> Trond?

I'll convert it into an inlined stub just as it was prior to commit
8fc795f703c5138e1a8bfb88c69f52632031aa6a.

Trond
