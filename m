Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:34107 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758302AbaJaMoD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Oct 2014 08:44:03 -0400
Received: by mail-qc0-f173.google.com with SMTP id x3so5708769qcv.4
        for <linux-nfs@vger.kernel.org>; Fri, 31 Oct 2014 05:44:02 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 31 Oct 2014 08:44:00 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>, imc@cs.ox.ac.uk,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] lockd: ratelimit "lockd: cannot monitor" messages
Message-ID: <20141031084400.4f3023af@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtSFrimRHne+NphHi5YcCSEV9pGjjQkUc2ktULsGDfE3iQ@mail.gmail.com>
References: <1414758509-30397-1-git-send-email-jlayton@primarydata.com>
	<CAHQdGtSFrimRHne+NphHi5YcCSEV9pGjjQkUc2ktULsGDfE3iQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 31 Oct 2014 14:36:16 +0200
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Fri, Oct 31, 2014 at 2:28 PM, Jeff Layton <jlayton@primarydata.com> wrote:
> > When lockd can't talk to a remote statd, it'll spew a warning message
> > to the ring buffer. If the application is really hammering on locks
> > however, it's possible for that message to spam the logs. Ratelimit it
> > to minimize the potential for harm.
> >
> > Reported-by: Ian Collier <imc@cs.ox.ac.uk>
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/lockd/mon.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> > index 9106f42c472c..1cc6ec51e6b1 100644
> > --- a/fs/lockd/mon.c
> > +++ b/fs/lockd/mon.c
> > @@ -214,7 +214,7 @@ int nsm_monitor(const struct nlm_host *host)
> >         if (unlikely(res.status != 0))
> >                 status = -EIO;
> >         if (unlikely(status < 0)) {
> > -               printk(KERN_NOTICE "lockd: cannot monitor %s\n", nsm->sm_name);
> > +               pr_notice_ratelimited("lockd: cannot monitor %s\n", nsm->sm_name);
> >                 return status;
> >         }
> >
> 
> How is this being triggered repeatedly? Normally, the 'cannot monitor'
> message should be happening at client mount time or not at all.
> 

No, it's triggered on NLM lock activity. I don't think we really do
much with NLM at mount time, do we? In any case, the bug was reported
here:

    https://bugzilla.redhat.com/show_bug.cgi?id=1155232

In this case, it was an application that was apparently responding to
ENOLCK errors by retrying the lock.

-- 
Jeff Layton <jlayton@primarydata.com>
