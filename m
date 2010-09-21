From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [bfields-btOuF8jVhiP3NsPE3w5/ayCwEArCW2h5@public.gmane.org: all f08d6374 Merge branch
 'nfs-for-next' into linux-next results]
Date: Tue, 21 Sep 2010 16:24:11 -0400
Message-ID: <20100921202411.GA10570@fieldses.org>
References: <20100918171546.GA9859@fieldses.org>
 <1284831680.2787.1.camel@heimdal.trondhjem.org>
 <20100919184549.GD32071@fieldses.org>
 <20100920130106.GB4580@fieldses.org>
 <20100920131025.GC4580@fieldses.org>
 <1285091815.30222.19.camel@heimdal.trondhjem.org>
 <20100921111657.330e7838@corrin.poochiereds.net>
 <20100921192005.GC4385@fieldses.org>
 <1285097787.30222.24.camel@heimdal.trondhjem.org>
 <1285099232.30222.25.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47410 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753360Ab0IUUZn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 16:25:43 -0400
In-Reply-To: <1285099232.30222.25.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 21, 2010 at 04:00:32PM -0400, Trond Myklebust wrote:
> On Tue, 2010-09-21 at 15:36 -0400, Trond Myklebust wrote:
> > On Tue, 2010-09-21 at 15:20 -0400, J. Bruce Fields wrote:
> > > All I need to do is mount nfs4.1 and run cthon -s.  The last output I
> > > see from the test is:
> > > 
> > > check for proper open/unlink operation
> > > nfsjunk files before unlink:
> > >   
> > 
> > Oh... I bet I see what it is.
> > 
> > It's that damned res->sr_slotid = NFS4_MAX_SLOT_TABLE and related
> > initialisation junk that's biting us in the arse again...
> > 
> > I'll fix it...
> 
> Does this work?

Yup.

--b.

> 
> Cheers
>   Trond
> -------------------------------------------------------------------------------------
> NFSv4.1: Fix the slotid initialisation in nfs_async_rename()
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/nfs4proc.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index c46e45e..72aa706 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2550,6 +2550,7 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
>  
>  	args->bitmask = server->cache_consistency_bitmask;
>  	res->server = server;
> +	res->seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
>  	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
>  }
>  
> @@ -2575,6 +2576,7 @@ static void nfs4_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
>  	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME];
>  	arg->bitmask = server->attr_bitmask;
>  	res->server = server;
> +	res->seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
>  }
>  
>  static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
> 
> 
