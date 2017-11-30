Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53798 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751443AbdK3Oho (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Nov 2017 09:37:44 -0500
Date: Thu, 30 Nov 2017 09:37:44 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: make pnfs_destroy_layout() wait on commit when
 inode is being evicted
Message-ID: <20171130143744.odap43pjwh63xhrc@tonberry.usersys.redhat.com>
References: <20171120214312.5263-1-smayhew@redhat.com>
 <1511987540.20638.10.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1511987540.20638.10.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 29 Nov 2017, Trond Myklebust wrote:

> On Mon, 2017-11-20 at 16:43 -0500, Scott Mayhew wrote:
> > Otherwise nfs_commit_inode() can set I_DIRTY_DATASYNC in the inode's
> > i_state, allowing the following BUG_ON in evict() to be triggered:
> > 
> >         BUG_ON(inode->i_state != (I_FREEING | I_CLEAR));
> > 
> > Fixes: 1f18b82c3437 ("pNFS: Ensure we commit the layout if it has
> > been...")
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > Tested-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> > ---
> >  fs/nfs/filelayout/filelayout.c         | 2 +-
> >  fs/nfs/flexfilelayout/flexfilelayout.c | 2 +-
> >  fs/nfs/nfs4super.c                     | 2 +-
> >  fs/nfs/pnfs.c                          | 6 +++---
> >  fs/nfs/pnfs.h                          | 2 +-
> >  5 files changed, 7 insertions(+), 7 deletions(-)
> > 
> > diff --git a/fs/nfs/filelayout/filelayout.c
> > b/fs/nfs/filelayout/filelayout.c
> > index 4e54d8b..28b7228 100644
> > --- a/fs/nfs/filelayout/filelayout.c
> > +++ b/fs/nfs/filelayout/filelayout.c
> > @@ -169,7 +169,7 @@ static int filelayout_async_handle_error(struct
> > rpc_task *task,
> >  		 * i/o and all i/o waiting on the slot table to the
> > MDS until
> >  		 * layout is destroyed and a new valid layout is
> > obtained.
> >  		 */
> > -		pnfs_destroy_layout(NFS_I(inode));
> > +		pnfs_destroy_layout(NFS_I(inode), 0);
> >  		rpc_wake_up(&tbl->slot_tbl_waitq);
> >  		goto reset;
> >  	/* RPC connection errors */
> > diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c
> > b/fs/nfs/flexfilelayout/flexfilelayout.c
> > index c75ad98..ab0a1e5 100644
> > --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> > +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> > @@ -1088,7 +1088,7 @@ static int
> > ff_layout_async_handle_error_v4(struct rpc_task *task,
> >  		 * i/o and all i/o waiting on the slot table to the
> > MDS until
> >  		 * layout is destroyed and a new valid layout is
> > obtained.
> >  		 */
> > -		pnfs_destroy_layout(NFS_I(inode));
> > +		pnfs_destroy_layout(NFS_I(inode), 0);
> >  		rpc_wake_up(&tbl->slot_tbl_waitq);
> >  		goto reset;
> >  	/* RPC connection errors */
> > diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
> > index 6fb7cb6..3b4a063 100644
> > --- a/fs/nfs/nfs4super.c
> > +++ b/fs/nfs/nfs4super.c
> > @@ -95,7 +95,7 @@ static void nfs4_evict_inode(struct inode *inode)
> >  	nfs_inode_return_delegation_noreclaim(inode);
> >  	/* Note that above delegreturn would trigger pnfs return-on-
> > close */
> >  	pnfs_return_layout(inode);
> > -	pnfs_destroy_layout(NFS_I(inode));
> > +	pnfs_destroy_layout(NFS_I(inode), FLUSH_SYNC);
> >  	/* First call standard NFS clear_inode() code */
> >  	nfs_clear_inode(inode);
> >  }
> > 
> 
> NACK. If you still have dirty pages when you get to nfs4_evict_inode(),
> then you are screwed no matter what.
> 
> This problem should be fixable in nfs_commit_inode() by simply exiting
> after the call to nfs_commit_end() if res == 0.

Okay, I'll try that out.  Thanks for looking!
-Scott

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
