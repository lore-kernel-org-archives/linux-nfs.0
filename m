Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38474 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750820AbaIBVxM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Sep 2014 17:53:12 -0400
Date: Tue, 2 Sep 2014 17:53:01 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfs: do not start the callback thread until we set
 rqstp->rq_task
Message-ID: <20140902215301.GA12100@fieldses.org>
References: <1409680738-12491-1-git-send-email-trond.myklebust@primarydata.com>
 <1409680738-12491-2-git-send-email-trond.myklebust@primarydata.com>
 <20140902192328.GA3873@infradead.org>
 <CAHQdGtRcyphAktKfdx8PKzbcExOmJsNCkCYFu9syfGjmS+J+TQ@mail.gmail.com>
 <20140902194556.GG17218@pad.redhat.com>
 <CAHQdGtQxaSzjrrU1xiiyO-dL-MiAKcFpqORnUWHyLoG08e=cTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQxaSzjrrU1xiiyO-dL-MiAKcFpqORnUWHyLoG08e=cTw@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 02, 2014 at 03:49:21PM -0400, Trond Myklebust wrote:
> On Tue, Sep 2, 2014 at 3:45 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > On Tue, Sep 02, 2014 at 03:32:55PM -0400, Trond Myklebust wrote:
> >> On Tue, Sep 2, 2014 at 3:23 PM, Christoph Hellwig <hch@infradead.org> wrote:
> >> > On Tue, Sep 02, 2014 at 01:58:58PM -0400, Trond Myklebust wrote:
> >> >> This fixes an Oopsable race when starting up the callback server.
> >> >>
> >> >> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> >> >> ---
> >> >>  fs/nfs/callback.c | 3 ++-
> >> >>  1 file changed, 2 insertions(+), 1 deletion(-)
> >> >>
> >> >> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> >> >> index e3dd1cd175d9..b8fb3a4ef649 100644
> >> >> --- a/fs/nfs/callback.c
> >> >> +++ b/fs/nfs/callback.c
> >> >> @@ -235,7 +235,7 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
> >> >>
> >> >>       cb_info->serv = serv;
> >> >>       cb_info->rqst = rqstp;
> >> >> -     cb_info->task = kthread_run(callback_svc, cb_info->rqst,
> >> >> +     cb_info->task = kthread_create(callback_svc, cb_info->rqst,
> >> >>                                   "nfsv4.%u-svc", minorversion);
> >> >>       if (IS_ERR(cb_info->task)) {
> >> >>               ret = PTR_ERR(cb_info->task);
> >> >> @@ -245,6 +245,7 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
> >> >>               return ret;
> >> >>       }
> >> >>       rqstp->rq_task = cb_info->task;
> >> >> +     wake_up_process(cb_info->task);
> >> >
> >> > Wouldn't it be cleaner to do something like:
> >> >
> >> > -       cb_info->task = kthread_run(callback_svc, cb_info->rqst,
> >> > +       cb_info->task = rqstp->rq_run =
> >> > +               kthread_create(callback_svc, cb_info->rqst,
> >> >
> >> > or am I missing something subtile that the changelog didn't mention?
> >>
> >> The above is fine if you call kthread_create(), but if you stick with
> >> kthread_run(), then there is still the same atomicity issue that the
> >> thread can be started before we've initialised cb_info->task and
> >> rqstp->rq_run.
> >>
> >> Internal testing has shown that this can lead to an oops when starting
> >> lockd.
> >
> > The oops seen in practice were probably after applying 983c684466e0
> > "SUNRPC: get rid of the request wait queue"?
> >
> > Though it was a bug before then too, of course.
> >
> 
> Right. This is not needed until you merge the new sunrpc server
> scalability stuff (which I'm assuming will be 3.18).

Got it.  Well there's also an rq_task use in
net/sunrpc/svc.c:choose_victim(), but I'm guessing it would take a
pretty strange case to hit, so I'll plan to take these for 3.18 without
a stable cc.

--b.
