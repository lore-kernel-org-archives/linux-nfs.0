Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14279 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752393Ab0IORYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 13:24:00 -0400
Date: Wed, 15 Sep 2010 13:23:55 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/8] nfs: add a rename_setup nfs_rpc_op for async
 renames
Message-ID: <20100915132355.1aee4cca@tlielax.poochiereds.net>
In-Reply-To: <1683BE39-BC28-4A0E-969F-792D4D29B985@oracle.com>
References: <1284557041-4375-1-git-send-email-jlayton@redhat.com>
	<1284557041-4375-7-git-send-email-jlayton@redhat.com>
	<1683BE39-BC28-4A0E-969F-792D4D29B985@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 15 Sep 2010 11:39:38 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Sep 15, 2010, at 9:23 AM, Jeff Layton wrote:
> 
> > Add a call that can set up the arguments and the response container for
> > an asynchronous rename call.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > fs/nfs/nfs3proc.c       |   18 ++++++++++++++++++
> > fs/nfs/nfs4proc.c       |   21 +++++++++++++++++++++
> > fs/nfs/proc.c           |   12 ++++++++++++
> > include/linux/nfs_xdr.h |    1 +
> > 4 files changed, 52 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
> > index c5cccf1..0654177 100644
> > --- a/fs/nfs/nfs3proc.c
> > +++ b/fs/nfs/nfs3proc.c
> > @@ -439,6 +439,23 @@ nfs3_proc_unlink_done(struct rpc_task *task, struct inode *dir)
> > }
> > 
> > static int
> > +nfs3_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
> > +{
> > +	struct nfs_renameres *res = msg->rpc_resp;
> > +
> > +	msg->rpc_proc = &nfs3_procedures[NFS3PROC_RENAME];
> > +
> > +	res->old_fattr = nfs_alloc_fattr();
> > +	res->new_fattr = nfs_alloc_fattr();
> > +	if (res->old_fattr != NULL && res->new_fattr != NULL)
> > +		return 0;
> > +
> > +	nfs_free_fattr(res->old_fattr);
> > +	nfs_free_fattr(res->new_fattr);
> > +	return -ENOMEM;
> > +}
> 
> This is just a style nit, but my understanding is that there is a stated preference for the error case to be handled in the statement block after the NULL checks, and the common case should exit through the tail of the function.
> 

Fair enough. I can change that.

> I suspect that these last three patches can be merged together for submission.  I read somewhere recently that the powers that be do not like patches that introduce new code that isn't used by anything.
> 

I can do that. I figured this would make it easier to review, but I'm
fine doing it that way too.

Thanks for the review.

-- 
Jeff Layton <jlayton@redhat.com>
