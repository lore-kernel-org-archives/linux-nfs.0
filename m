From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [PATCH 4/4] NLM: don't requeue block if it was invalidated while GRANT_MSG was in flight
Date: Fri, 14 Mar 2008 17:21:12 -0400
Message-ID: <170fa0d20803141421s5c784d16ie1db8e1d57e4b428@mail.gmail.com>
References: <1202315653-11840-1-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-2-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-3-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-4-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-5-git-send-email-jlayton@redhat.com>
	 <170fa0d20803141255k41e8e2a3t6a53f4f812a15d7b@mail.gmail.com>
	 <1205529061.27906.86.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Jeff Layton" <jlayton@redhat.com>, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:5104 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756041AbYCNVVN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 17:21:13 -0400
Received: by wf-out-1314.google.com with SMTP id 28so4222904wff.4
        for <linux-nfs@vger.kernel.org>; Fri, 14 Mar 2008 14:21:12 -0700 (PDT)
In-Reply-To: <1205529061.27906.86.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3/14/08, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>
>  On Fri, 2008-03-14 at 15:55 -0400, Mike Snitzer wrote:
>  > On 2/6/08, Jeff Layton <jlayton@redhat.com> wrote:
>  > > It's possible for lockd to catch a SIGKILL while a GRANT_MSG callback
>  > >  is in flight. If this happens we don't want lockd to insert the block
>  > >  back into the nlm_blocked list.
>  > >
>  > >  This helps that situation, but there's still a possible race. Fixing
>  > >  that will mean adding real locking for nlm_blocked.
>  > >
>  > >  Signed-off-by: Jeff Layton <jlayton@redhat.com>
>  > >  ---
>  > >   fs/lockd/svclock.c |   11 +++++++++++
>  > >   1 files changed, 11 insertions(+), 0 deletions(-)
>  > >
>  > >  diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
>  > >  index 82db7b3..fe9bdb4 100644
>  > >  --- a/fs/lockd/svclock.c
>  > >  +++ b/fs/lockd/svclock.c
>  > >  @@ -795,6 +795,17 @@ static void nlmsvc_grant_callback(struct rpc_task *task, void *data)
>  > >
>  > >         dprintk("lockd: GRANT_MSG RPC callback\n");
>  > >
>  > >  +       /* if the block is not on a list at this point then it has
>  > >  +        * been invalidated. Don't try to requeue it.
>  > >  +        *
>  > >  +        * FIXME: it's possible that the block is removed from the list
>  > >  +        * after this check but before the nlmsvc_insert_block. In that
>  > >  +        * case it will be added back. Perhaps we need better locking
>  > >  +        * for nlm_blocked?
>  > >  +        */
>  > >  +       if (list_empty(&block->b_list))
>  > >  +               return;
>  > >  +
>  > >         /* Technically, we should down the file semaphore here. Since we
>  > >          * move the block towards the head of the queue only, no harm
>  > >          * can be done, though. */
>  > >
>  >
>  > Hi Jeff,
>  >
>  > Would the following patch take care of this race?  Two questions I have:
>  > 1) Does my patch address your FIXME?  I believe it should.
>  > 2) Can I get rid of the BKL in nlmsvc_grant_deferred() given this
>  > nlm_blocked serialization?  It is unclear to me if
>  > nlmsvc_grant_deferred() is taking the BKL purely to protect
>  > nlm_blocked.
>
>
> Ugh... NACK!
>
>  We already have the file->f_mutex, so there should be no need to add a
>  global semaphore on top of that.

Um, nlm_blocked is global.  file->f_mutex is local.  What am I missing?
