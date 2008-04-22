From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 07/33] NFS: Ensure that rpc_run_task() errors are
	propagated back to the caller
Date: Mon, 21 Apr 2008 20:17:47 -0400
Message-ID: <1208823472.7767.40.camel@heimdal.trondhjem.org>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080419204048.14124.4335.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <BE4F0130-A492-4229-83E4-E7C912B0ABF0@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38919 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758472AbYDVARw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Apr 2008 20:17:52 -0400
In-Reply-To: <BE4F0130-A492-4229-83E4-E7C912B0ABF0@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-04-21 at 15:55 -0400, Chuck Lever wrote:
> Hi Trond-
> 
> On Apr 19, 2008, at 4:40 PM, Trond Myklebust wrote:
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> >
> > fs/nfs/direct.c |   10 ++++++----
> > fs/nfs/read.c   |   23 +++++++++++++++--------
> > fs/nfs/write.c  |   33 +++++++++++++++++++--------------
> > 3 files changed, 40 insertions(+), 26 deletions(-)
> >
> > diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> > index abf8e02..4757a2b 100644
> > --- a/fs/nfs/direct.c
> > +++ b/fs/nfs/direct.c
> > @@ -347,8 +347,9 @@ static ssize_t  
> > nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
> > 		NFS_PROTO(inode)->read_setup(data, &msg);
> >
> > 		task = rpc_run_task(&task_setup_data);
> > -		if (!IS_ERR(task))
> > -			rpc_put_task(task);
> > +		if (IS_ERR(task))
> > +			break;
> > +		rpc_put_task(task);
> >
> > 		dprintk("NFS: %5u initiated direct read call "
> > 			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
> 
> My reading of this logic suggests that if the very first  
> rpc_run_task() call in the loop fails, we'll return -EFAULT instead of  
> something sensible, like -ENOMEM.

I'm confused. How could ENOMEM be a sensible substitute for EFAULT?


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
