Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9963 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763Ab1ITPLn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 11:11:43 -0400
Date: Tue, 20 Sep 2011 11:11:12 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Subject: Re: [PATCH v5 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
Message-ID: <20110920111112.3f07cd6e@tlielax.poochiereds.net>
In-Reply-To: <4E78A6A1.1000800@parallels.com>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6>
	<20110920101341.9861.51453.stgit@localhost6.localdomain6>
	<4E7899E7.9090809@parallels.com>
	<20110920102431.58ca1d96@tlielax.poochiereds.net>
	<4E78A6A1.1000800@parallels.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 20 Sep 2011 18:43:45 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> 20.09.2011 18:24, Jeff Layton пишет:
> > On Tue, 20 Sep 2011 17:49:27 +0400
> > Stanislav Kinsbursky<skinsbursky@parallels.com>  wrote:
> >
> >> v5: fixed races with rpcb_users in rpcb_get_local()
> >>
> >> This helpers will be used for dynamical creation and destruction of rpcbind
> >> clients.
> >> Variable rpcb_users is actually a counter of lauched RPC services. If rpcbind
> >> clients has been created already, then we just increase rpcb_users.
> >>
> >> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
> >>
> >> ---
> >>    net/sunrpc/rpcb_clnt.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++++
> >>    1 files changed, 53 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> >> index e45d2fb..5f4a406 100644
> >> --- a/net/sunrpc/rpcb_clnt.c
> >> +++ b/net/sunrpc/rpcb_clnt.c
> >> @@ -114,6 +114,9 @@ static struct rpc_program	rpcb_program;
> >>    static struct rpc_clnt *	rpcb_local_clnt;
> >>    static struct rpc_clnt *	rpcb_local_clnt4;
> >>    +DEFINE_SPINLOCK(rpcb_clnt_lock);
> >> +unsigned int			rpcb_users;
> >> +
> >>    struct rpcbind_args {
> >>    	struct rpc_xprt *	r_xprt;
> >>    @@ -161,6 +164,56 @@ static void rpcb_map_release(void *data)
> >>    	kfree(map);
> >>    }
> >>    +static int rpcb_get_local(void)
> >> +{
> >> +	int cnt;
> >> +
> >> +	spin_lock(&rpcb_clnt_lock);
> >> +	if (rpcb_users)
> >> +		rpcb_users++;
> >> +	cnt = rpcb_users;
> >> +	spin_unlock(&rpcb_clnt_lock);
> >> +
> >> +	return cnt;
> >> +}
> >> +
> >> +void rpcb_put_local(void)
> >> +{
> >> +	struct rpc_clnt *clnt = rpcb_local_clnt;
> >> +	struct rpc_clnt *clnt4 = rpcb_local_clnt4;
> >> +	int shutdown;
> >> +
> >> +	spin_lock(&rpcb_clnt_lock);
> >> +	if (--rpcb_users == 0) {
> >> +		rpcb_local_clnt = NULL;
> >> +		rpcb_local_clnt4 = NULL;
> >> +	}
> >
> > In the function below, you mention that the above pointers are
> > protected by rpcb_create_local_mutex, but it looks like they get reset
> > here without that being held?
> >
> 
> Assigning of them is protected by rpcb_create_local_mutex.
> Dereferencing of them is protected by rpcb_clnt_lock.
> 

That's probably a bug, but I haven't sat down to work through the logic.

> > Might it be simpler to just protect rpcb_users with the
> > rpcb_create_local_mutex and ensure that it's held whenever you call one
> > of these routines? None of these are codepaths are particularly hot.
> >
> 
> I just inherited this lock-mutex logic.
> Actually, you right. This codepaths are used rarely.
> But are use sure, that we need to remove this "speed-up" logic if we take into 
> account that it was here already?
> 

There are many ways to do this...

In general, it's difficult to get locking right, especially when you
start mixing multiple locks on related resources. Personally, I'd go
with a simpler scheme here. There's not much value in protecting this
counter with a spinlock when the other parts need to be protected by a
mutex. If you do decide to do it with multiple locks, then please do
document in comments how the locking is expected to work. 

An alternate scheme might be to consider doing this with krefs, but I
haven't really considered whether that idiom makes sense here.

-- 
Jeff Layton <jlayton@redhat.com>
