Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:35556 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751468AbcIHVlV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2016 17:41:21 -0400
Received: by mail-qt0-f175.google.com with SMTP id 93so31270459qtg.2
        for <linux-nfs@vger.kernel.org>; Thu, 08 Sep 2016 14:41:20 -0700 (PDT)
Message-ID: <1473370876.23262.14.camel@redhat.com>
Subject: Re: [PATCH 6/9] nfs: move nfs4_set_lock_state call into caller
From: Jeff Layton <jlayton@redhat.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 08 Sep 2016 17:41:16 -0400
In-Reply-To: <6e584c1a-605c-2b3f-07dc-305c5287cd5c@Netapp.com>
References: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
         <1473174760-29859-7-git-send-email-jlayton@redhat.com>
         <6e584c1a-605c-2b3f-07dc-305c5287cd5c@Netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-09-08 at 15:47 -0400, Anna Schumaker wrote:
> Hi Jeff,
> 
> On 09/06/2016 11:12 AM, Jeff Layton wrote:
> > 
> > We need to have this info set up before adding the waiter to the
> > waitqueue, so move this out of the _nfs4_proc_setlk and into the
> > caller. That's more efficient anyway since we don't need to do
> > this more than once if we end up waiting on the lock.
> 
> Looks like you're moving this outside of the state recovery retry
> loop, too.  Do we need to worry about lock state changing during
> state recovery?
> 
> Thanks,
> Anna
> 

I'm not sure I understand. _nfs4_proc_setlk and nfs4_proc_setlk each
only have one caller so there are no cases where we'd call these
functions and not call nfs4_set_lock_state first.

The first thing that nfs4_set_lock_state does is this:

        if (fl->fl_ops != NULL)
                return 0;

So it's a no-op on every subsequent attempt.

> > 
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/nfs4proc.c | 16 +++++++++-------
> >  1 file changed, 9 insertions(+), 7 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index e9232d71bc64..5573f19539a6 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -6134,14 +6134,8 @@ static int _nfs4_proc_setlk(struct
> > nfs4_state *state, int cmd, struct file_lock
> >  	struct nfs_inode *nfsi = NFS_I(state->inode);
> >  	struct nfs4_state_owner *sp = state->owner;
> >  	unsigned char fl_flags = request->fl_flags;
> > -	int status = -ENOLCK;
> > +	int status;
> >  
> > -	if (!test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
> > -		goto out;
> > -	/* Is this a delegated open? */
> > -	status = nfs4_set_lock_state(state, request);
> > -	if (status != 0)
> > -		goto out;
> >  	request->fl_flags |= FL_ACCESS;
> >  	status = locks_lock_inode_wait(state->inode, request);
> >  	if (status < 0)
> > @@ -6215,6 +6209,10 @@ nfs4_proc_lock(struct file *filp, int cmd,
> > struct file_lock *request)
> >  
> >  	if (state == NULL)
> >  		return -ENOLCK;
> > +
> > +	if (!test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
> > +		return -ENOLCK;
> > +
> >  	/*
> >  	 * Don't rely on the VFS having checked the file open
> > mode,
> >  	 * since it won't do this for flock() locks.
> > @@ -6229,6 +6227,10 @@ nfs4_proc_lock(struct file *filp, int cmd,
> > struct file_lock *request)
> >  			return -EBADF;
> >  	}
> >  
> > +	status = nfs4_set_lock_state(state, request);
> > +	if (status != 0)
> > +		return status;
> > +
> >  	do {
> >  		status = nfs4_proc_setlk(state, cmd, request);
> >  		if ((status != -EAGAIN) || IS_SETLK(cmd))
> > 
> 

-- 
Jeff Layton <jlayton@redhat.com>
