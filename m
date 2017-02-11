Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33435 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753198AbdBKMbr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Feb 2017 07:31:47 -0500
Received: by mail-qk0-f196.google.com with SMTP id 11so8288483qkl.0
        for <linux-nfs@vger.kernel.org>; Sat, 11 Feb 2017 04:31:47 -0800 (PST)
Message-ID: <1486816302.4233.29.camel@poochiereds.net>
Subject: Re: [RFC][PATCH] nfsd: add +1 to reference counting scheme for
 struct nfsd4_session
From: Jeff Layton <jlayton@poochiereds.net>
To: David Windsor <dwindsor@gmail.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com,
        Bruce Fields <bfields@fieldses.org>, Kees Cook <keescook@chromium.org>,
        "Reshetova, Elena" <elena.reshetova@intel.com>
Date: Sat, 11 Feb 2017 07:31:42 -0500
In-Reply-To: <CAEXv5_jUa8Av4JABoKSAueiLHSLzibMvaE-8DrVcxZHFceckMg@mail.gmail.com>
References: <1486625901-10094-1-git-send-email-dwindsor@gmail.com>
         <CAEXv5_jUa8Av4JABoKSAueiLHSLzibMvaE-8DrVcxZHFceckMg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2017-02-11 at 01:42 -0500, David Windsor wrote:
> <snip>
> 
> > Signed-off-by: David Windsor <dwindsor@gmail.com>
> > ---
> >  fs/nfsd/nfs4state.c | 6 +++---
> >  1 file changed, 3 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index a0dee8a..b0f3010 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -196,7 +196,7 @@ static void nfsd4_put_session_locked(struct nfsd4_session *ses)
> > 
> >         lockdep_assert_held(&nn->client_lock);
> > 
> > -       if (atomic_dec_and_test(&ses->se_ref) && is_session_dead(ses))
> > +       if (!atomic_add_unless(&ses->se_ref, -1, 1) && is_session_des(ses))
> 
> This should read:
> if (!atomic_add_unless(&ses->se_ref, -1, 1) && is_session_dead(ses))
> 
> >                 free_session(ses);
> >         put_client_renew_locked(clp);
> >  }
> > @@ -1645,7 +1645,7 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
> >         new->se_flags = cses->flags;
> >         new->se_cb_prog = cses->callback_prog;
> >         new->se_cb_sec = cses->cb_sec;
> > -       atomic_set(&new->se_ref, 0);
> > +       atomic_set(&new->se_ref, 1);
> >         idx = hash_sessionid(&new->se_sessionid);
> >         list_add(&new->se_hash, &nn->sessionid_hashtbl[idx]);
> >         spin_lock(&clp->cl_lock);
> > @@ -1792,7 +1792,7 @@ free_client(struct nfs4_client *clp)
> >                 ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
> >                                 se_perclnt);
> >                 list_del(&ses->se_perclnt);
> > -               WARN_ON_ONCE(atomic_read(&ses->se_ref));
> > +               WARN_ON_ONCE((atomic_read(&ses->se_ref) > 1));
> >                 free_session(ses);
> >         }
> >         rpc_destroy_wait_queue(&clp->cl_cb_waitq);
> > --
> > 2.7.4
> > 

The basic idea here is that nfsv4 sessions have a "resting state" of 0.
We want to keep them around, but if they go "dead" then we we'll tear
them down if they aren't actively in use at the time. So, we still free
the thing when the refcount goes to zero, but we have an extra condition
before we free it on the put -- that the session is also "dead" (meaning
that the client asked us to destroy it).

Your patch doesn't look like it'll break anything, but I personally find
 it harder to follow that way. The freeable reference state will be 1
instead of the normal 0.

--
Jeff Layton <jlayton@poochiereds.net>
