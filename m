Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:33225 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932500AbcIHVrw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2016 17:47:52 -0400
Received: by mail-qk0-f175.google.com with SMTP id w204so59606868qka.0
        for <linux-nfs@vger.kernel.org>; Thu, 08 Sep 2016 14:47:51 -0700 (PDT)
Message-ID: <1473371269.23262.20.camel@redhat.com>
Subject: Re: [PATCH 9/9] nfs: track whether server sets MAY_NOTIFY_LOCK flag
From: Jeff Layton <jlayton@redhat.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 08 Sep 2016 17:47:49 -0400
In-Reply-To: <aafd950e-78c0-96a3-085e-60b85ab0a29f@Netapp.com>
References: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
         <1473174760-29859-10-git-send-email-jlayton@redhat.com>
         <aafd950e-78c0-96a3-085e-60b85ab0a29f@Netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-09-08 at 16:15 -0400, Anna Schumaker wrote:
> Hi Jeff,
> 
> On 09/06/2016 11:12 AM, Jeff Layton wrote:
> > 
> > If it does, then always have the client sleep for the max time
> > before
> > repolling for the lock.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/nfs4_fs.h  | 1 +
> >  fs/nfs/nfs4proc.c | 7 ++++++-
> >  2 files changed, 7 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> > index 9bf64eacba5b..91e4f135a5f2 100644
> > --- a/fs/nfs/nfs4_fs.h
> > +++ b/fs/nfs/nfs4_fs.h
> > @@ -156,6 +156,7 @@ enum {
> >  	NFS_STATE_RECLAIM_NOGRACE,	/* OPEN stateid needs to
> > recover state */
> >  	NFS_STATE_POSIX_LOCKS,		/* Posix locks are
> > supported */
> >  	NFS_STATE_RECOVERY_FAILED,	/* OPEN stateid state
> > recovery failed */
> > +	NFS_STATE_MAY_NOTIFY_LOCK,	/* server may
> > CB_NOTIFY_LOCK */
> >  };
> >  
> >  struct nfs4_state {
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 6829b998776d..ecd00431fe0c 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -2537,6 +2537,8 @@ static int _nfs4_open_and_get_state(struct
> > nfs4_opendata *opendata,
> >  		goto out;
> >  	if (server->caps & NFS_CAP_POSIX_LOCK)
> >  		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
> > +	if (opendata->o_res.rflags &
> > NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK)
>                                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> ^
> Where does the NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK flag come from?  `git
> grep` isn't finding it in my source directory.
> 
> Thanks,
> Anna
> 

It's in:

    include/uapi/linux/nfs4.h

...which I think is already included here.

> 
> > 
> > +		set_bit(NFS_STATE_MAY_NOTIFY_LOCK, &state->flags);
> >  
> >  	dentry = opendata->dentry;
> >  	if (d_really_is_negative(dentry)) {
> > @@ -6230,7 +6232,7 @@ nfs4_proc_lock(struct file *filp, int cmd,
> > struct file_lock *request)
> >  {
> >  	struct nfs_open_context *ctx;
> >  	struct nfs4_state *state;
> > -	unsigned long timeout = NFS4_LOCK_MINTIMEOUT;
> > +	unsigned long timeout;
> >  	int status;
> >  
> >  	/* verify open state */
> > @@ -6279,6 +6281,9 @@ nfs4_proc_lock(struct file *filp, int cmd,
> > struct file_lock *request)
> >  	if (status != 0)
> >  		return status;
> >  
> > +	timeout = test_bit(NFS_STATE_MAY_NOTIFY_LOCK, &state-
> > >flags) ?
> > +				NFS4_LOCK_MAXTIMEOUT :
> > NFS4_LOCK_MINTIMEOUT;
> > +
> >  	do {
> >  		struct nfs4_lock_state *lsp = request-
> > >fl_u.nfs4_fl.owner;
> >  		struct inode *inode = lsp->ls_state->inode;
> > 
> 

-- 
Jeff Layton <jlayton@redhat.com>
