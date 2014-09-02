Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754183AbaIBTqV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Sep 2014 15:46:21 -0400
Date: Tue, 2 Sep 2014 15:45:56 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfs: do not start the callback thread until we set
 rqstp->rq_task
Message-ID: <20140902194556.GG17218@pad.redhat.com>
References: <1409680738-12491-1-git-send-email-trond.myklebust@primarydata.com>
 <1409680738-12491-2-git-send-email-trond.myklebust@primarydata.com>
 <20140902192328.GA3873@infradead.org>
 <CAHQdGtRcyphAktKfdx8PKzbcExOmJsNCkCYFu9syfGjmS+J+TQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRcyphAktKfdx8PKzbcExOmJsNCkCYFu9syfGjmS+J+TQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 02, 2014 at 03:32:55PM -0400, Trond Myklebust wrote:
> On Tue, Sep 2, 2014 at 3:23 PM, Christoph Hellwig <hch@infradead.org> wrote:
> > On Tue, Sep 02, 2014 at 01:58:58PM -0400, Trond Myklebust wrote:
> >> This fixes an Oopsable race when starting up the callback server.
> >>
> >> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> >> ---
> >>  fs/nfs/callback.c | 3 ++-
> >>  1 file changed, 2 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> >> index e3dd1cd175d9..b8fb3a4ef649 100644
> >> --- a/fs/nfs/callback.c
> >> +++ b/fs/nfs/callback.c
> >> @@ -235,7 +235,7 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
> >>
> >>       cb_info->serv = serv;
> >>       cb_info->rqst = rqstp;
> >> -     cb_info->task = kthread_run(callback_svc, cb_info->rqst,
> >> +     cb_info->task = kthread_create(callback_svc, cb_info->rqst,
> >>                                   "nfsv4.%u-svc", minorversion);
> >>       if (IS_ERR(cb_info->task)) {
> >>               ret = PTR_ERR(cb_info->task);
> >> @@ -245,6 +245,7 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
> >>               return ret;
> >>       }
> >>       rqstp->rq_task = cb_info->task;
> >> +     wake_up_process(cb_info->task);
> >
> > Wouldn't it be cleaner to do something like:
> >
> > -       cb_info->task = kthread_run(callback_svc, cb_info->rqst,
> > +       cb_info->task = rqstp->rq_run =
> > +               kthread_create(callback_svc, cb_info->rqst,
> >
> > or am I missing something subtile that the changelog didn't mention?
> 
> The above is fine if you call kthread_create(), but if you stick with
> kthread_run(), then there is still the same atomicity issue that the
> thread can be started before we've initialised cb_info->task and
> rqstp->rq_run.
> 
> Internal testing has shown that this can lead to an oops when starting
> lockd.

The oops seen in practice were probably after applying 983c684466e0
"SUNRPC: get rid of the request wait queue"?

Though it was a bug before then too, of course.

--b.

> I'm therefore assuming that the same thing can happen with the
> NFS client callback channel.
> 
> -- 
> Trond Myklebust
> 
> Linux NFS client maintainer, PrimaryData
> 
> trond.myklebust@primarydata.com
