Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:34769 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751676AbcILUa2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2016 16:30:28 -0400
Received: by mail-qk0-f178.google.com with SMTP id h8so67057596qka.1
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2016 13:30:27 -0700 (PDT)
Message-ID: <1473712223.8504.2.camel@redhat.com>
Subject: Re: [PATCH v2 05/10] nfs: track whether server sets MAY_NOTIFY_LOCK
 flag
From: Jeff Layton <jlayton@redhat.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 12 Sep 2016 16:30:23 -0400
In-Reply-To: <68634996-8fba-5bcd-27e3-5d6ab5f881ba@Netapp.com>
References: <1473446870-1831-1-git-send-email-jlayton@redhat.com>
         <1473446870-1831-6-git-send-email-jlayton@redhat.com>
         <68634996-8fba-5bcd-27e3-5d6ab5f881ba@Netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2016-09-12 at 16:19 -0400, Anna Schumaker wrote:
> Hi Jeff,
> 
> On 09/09/2016 02:47 PM, Jeff Layton wrote:
> > 
> > If it does, then always have the client sleep for the max time before
> > repolling for the lock. If it doesn't then we can skip all of the
> > waitqueue handling as well.
> > 
> > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/nfs4_fs.h  | 1 +
> >  fs/nfs/nfs4proc.c | 2 ++
> >  2 files changed, 3 insertions(+)
> > 
> > diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> > index 9bf64eacba5b..91e4f135a5f2 100644
> > --- a/fs/nfs/nfs4_fs.h
> > +++ b/fs/nfs/nfs4_fs.h
> > @@ -156,6 +156,7 @@ enum {
> > > > > >  	NFS_STATE_RECLAIM_NOGRACE,	/* OPEN stateid needs to recover state */
> > > > > >  	NFS_STATE_POSIX_LOCKS,		/* Posix locks are supported */
> > > > > >  	NFS_STATE_RECOVERY_FAILED,	/* OPEN stateid state recovery failed */
> > > > > > +	NFS_STATE_MAY_NOTIFY_LOCK,	/* server may CB_NOTIFY_LOCK */
> 
> Looks like the reason I don't have this flag is because it's added as part of the server patches.  I'll coordinate with the nfsd merge to make sure everything is added in the right order!
> 
> Thanks,
> Anna

Oh! Yes, that would explain it -- sorry...

Would it help at all to break out the addition of that field into a
separate patch? Just wondering what the right approach is for future
reference.

Thanks,
Jeff

> > 
> >  };
> >  
> >  struct nfs4_state {
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 90e8ded0ef82..627a9185822f 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -2537,6 +2537,8 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
> > > >  		goto out;
> > > >  	if (server->caps & NFS_CAP_POSIX_LOCK)
> > > >  		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
> > > > +	if (opendata->o_res.rflags & NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK)
> > > > +		set_bit(NFS_STATE_MAY_NOTIFY_LOCK, &state->flags);
> >  
> > > >  	dentry = opendata->dentry;
> > > >  	if (d_really_is_negative(dentry)) {
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jeff Layton <jlayton@redhat.com>
