Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:36207 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751944AbcIHSgZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2016 14:36:25 -0400
Received: by mail-qt0-f182.google.com with SMTP id l91so11085363qte.3
        for <linux-nfs@vger.kernel.org>; Thu, 08 Sep 2016 11:36:25 -0700 (PDT)
Message-ID: <1473359782.23262.10.camel@redhat.com>
Subject: Re: [PATCH 4/9] nfs: add a freezable_schedule_timeout_unsafe() and
 use it when waiting to retry LOCK
From: Jeff Layton <jlayton@redhat.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 08 Sep 2016 14:36:22 -0400
In-Reply-To: <3c94ea23-fd38-be69-2eef-e641c8bb1ff5@Netapp.com>
References: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
         <1473174760-29859-5-git-send-email-jlayton@redhat.com>
         <3c94ea23-fd38-be69-2eef-e641c8bb1ff5@Netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-09-08 at 14:20 -0400, Anna Schumaker wrote:
> Hi Jeff,
> 
> Can you CC the freezer folks on this patch during the second
> posting?  They'll probably need to at send an ACK for the changes to
> their include file.
> 
> Thanks,
> Anna
> 

Will do...

OTOH, now that I look, I'm not sure we really need a *_unsafe variant
here at all.

File locking is somewhat different in that we're expected to sleep in
the kernel, and I don't think we hold any kernel locks that are the
usual worry here (i_rwsem and the like). So we might can just use
freezable_schedule_timeout here.

I'll see if I can experiment with that before the next posting. It'd be
nice to eliminate one of the unsafe sleep callsites.

> On 09/06/2016 11:12 AM, Jeff Layton wrote:
> > 
> > We actually want to use TASK_INTERRUPTIBLE sleeps here. Once the
> > task
> > wakes up, if there is a signal pending then we'll be returning an
> > error
> > anyway. So, we might as well wake up immediately for non-fatal
> > signals
> > as well. That allows us to return to userland more quickly in that
> > case,
> > but won't change the error that userland sees.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/nfs4proc.c       |  3 ++-
> >  include/linux/freezer.h | 13 +++++++++++++
> >  2 files changed, 15 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index e3bf95369daf..e9232d71bc64 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -5537,7 +5537,8 @@ int nfs4_proc_delegreturn(struct inode
> > *inode, struct rpc_cred *cred, const nfs4
> >  static unsigned long
> >  nfs4_set_lock_task_retry(unsigned long timeout)
> >  {
> > -	freezable_schedule_timeout_killable_unsafe(timeout);
> > +	set_current_state(TASK_INTERRUPTIBLE);
> > +	freezable_schedule_timeout_unsafe(timeout);
> >  	timeout <<= 1;
> >  	if (timeout > NFS4_LOCK_MAXTIMEOUT)
> >  		return NFS4_LOCK_MAXTIMEOUT;
> > diff --git a/include/linux/freezer.h b/include/linux/freezer.h
> > index dd03e837ebb7..fe31601e7f55 100644
> > --- a/include/linux/freezer.h
> > +++ b/include/linux/freezer.h
> > @@ -197,6 +197,19 @@ static inline long
> > freezable_schedule_timeout(long timeout)
> >   * Like schedule_timeout_interruptible(), but should not block the
> > freezer.  Do not
> >   * call this with locks held.
> >   */
> > +static inline long freezable_schedule_timeout_unsafe(long timeout)
> > +{
> > +	long __retval;
> > +	freezer_do_not_count();
> > +	__retval = schedule_timeout(timeout);
> > +	freezer_count_unsafe();
> > +	return __retval;
> > +}
> > +
> > +/*
> > + * Like schedule_timeout_interruptible(), but should not block the
> > freezer.  Do not
> > + * call this with locks held.
> > + */
> >  static inline long freezable_schedule_timeout_interruptible(long
> > timeout)
> >  {
> >  	long __retval;
> > 
> 

-- 
Jeff Layton <jlayton@redhat.com>
