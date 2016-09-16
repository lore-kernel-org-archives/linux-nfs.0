Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:33206 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755311AbcIPVrK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2016 17:47:10 -0400
Received: by mail-qk0-f182.google.com with SMTP id w204so99999970qka.0
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 14:47:10 -0700 (PDT)
Message-ID: <1474062428.13386.15.camel@redhat.com>
Subject: Re: [PATCH v3 8/9] nfs: move nfs4 lock retry attempt loop to a
 separate function
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Fields Bruce James <bfields@fieldses.org>
Date: Fri, 16 Sep 2016 17:47:08 -0400
In-Reply-To: <B44BF606-A37E-430A-B076-AF8050F4CBAD@primarydata.com>
References: <1474057631-31209-1-git-send-email-jlayton@redhat.com>
         <1474057631-31209-9-git-send-email-jlayton@redhat.com>
         <B44BF606-A37E-430A-B076-AF8050F4CBAD@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-09-16 at 21:20 +0000, Trond Myklebust wrote:
> > 
> > On Sep 16, 2016, at 16:27, Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > This also consolidates the waiting logic into a single function,
> > instead of having it spread across two like it is now.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > fs/nfs/nfs4proc.c | 51 ++++++++++++++++++++++++------------------
> > ---------
> > 1 file changed, 24 insertions(+), 27 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index c807850ac476..a7517abaf3c7 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -5530,22 +5530,6 @@ int nfs4_proc_delegreturn(struct inode
> > *inode, struct rpc_cred *cred, const nfs4
> > 	return err;
> > }
> > 
> > -#define NFS4_LOCK_MINTIMEOUT (1 * HZ)
> > -#define NFS4_LOCK_MAXTIMEOUT (30 * HZ)
> > -
> > -/* 
> > - * sleep, with exponential backoff, and retry the LOCK operation. 
> > - */
> > -static unsigned long
> > -nfs4_set_lock_task_retry(unsigned long timeout)
> > -{
> > -	freezable_schedule_timeout_interruptible(timeout);
> > -	timeout <<= 1;
> > -	if (timeout > NFS4_LOCK_MAXTIMEOUT)
> > -		return NFS4_LOCK_MAXTIMEOUT;
> > -	return timeout;
> > -}
> > -
> > static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd,
> > struct file_lock *request)
> > {
> > 	struct inode *inode = state->inode;
> > @@ -6178,12 +6162,34 @@ static int nfs4_proc_setlk(struct
> > nfs4_state *state, int cmd, struct file_lock *
> > 	return err;
> > }
> > 
> > +#define NFS4_LOCK_MINTIMEOUT (1 * HZ)
> > +#define NFS4_LOCK_MAXTIMEOUT (30 * HZ)
> > +
> > +static int
> > +nfs4_retry_setlk(struct nfs4_state *state, int cmd, struct
> > file_lock *request)
> > +{
> > +	int status;
> > +	unsigned long timeout = NFS4_LOCK_MINTIMEOUT;
> > +
> > +	do {
> > +		status = nfs4_proc_setlk(state, cmd, request);
> > +		if ((status != -EAGAIN) || IS_SETLK(cmd))
> > +			break;
> > +		freezable_schedule_timeout_interruptible(timeout);
> > +		timeout *= 2;
> > +		timeout = min_t(unsigned long,
> > NFS4_LOCK_MAXTIMEOUT, timeout);
> > +		status = -ERESTARTSYS;
> > +		if (signalled())
> > +			break;
> > +	} while(status < 0);
> 
> Can it ever be >= 0 here? Why not just use 'while (!signalled())'?
> 


Good point. I'll make that change.

Thanks,

> > 
> > +	return status;
> > +}
> > +
> > static int
> > nfs4_proc_lock(struct file *filp, int cmd, struct file_lock
> > *request)
> > {
> > 	struct nfs_open_context *ctx;
> > 	struct nfs4_state *state;
> > -	unsigned long timeout = NFS4_LOCK_MINTIMEOUT;
> > 	int status;
> > 
> > 	/* verify open state */
> > @@ -6232,16 +6238,7 @@ nfs4_proc_lock(struct file *filp, int cmd,
> > struct file_lock *request)
> > 	if (status != 0)
> > 		return status;
> > 
> > -	do {
> > -		status = nfs4_proc_setlk(state, cmd, request);
> > -		if ((status != -EAGAIN) || IS_SETLK(cmd))
> > -			break;
> > -		timeout = nfs4_set_lock_task_retry(timeout);
> > -		status = -ERESTARTSYS;
> > -		if (signalled())
> > -			break;
> > -	} while(status < 0);
> > -	return status;
> > +	return nfs4_retry_setlk(state, cmd, request);
> > }
> > 
> > int nfs4_lock_delegation_recall(struct file_lock *fl, struct
> > nfs4_state *state, const nfs4_stateid *stateid)
> > 
-- 
Jeff Layton <jlayton@redhat.com>
