Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19360 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756641Ab3CDOro convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2013 09:47:44 -0500
Date: Mon, 4 Mar 2013 09:47:36 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>, <devel@openvz.org>,
        <Trond.Myklebust@netapp.com>, <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: try nfsdcld client tracker in containers
Message-ID: <20130304094736.57a288b9@tlielax.poochiereds.net>
In-Reply-To: <51344175.40503@parallels.com>
References: <20130301082423.21663.37825.stgit@localhost.localdomain>
	<20130301080911.2a1a28a2@corrin.poochiereds.net>
	<51344175.40503@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 4 Mar 2013 10:38:45 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> 01.03.2013 17:09, Jeff Layton пишет:
> > On Fri, 01 Mar 2013 11:24:23 +0300
> > Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:
> >
> >> Currently, UMH and Legacy trackers are disabled in containers.
> >> But existent logic can lookup nfs4_recoverydir in a container, and in this
> >> case will try to init Legacy tracker and skip nfsdcld client tracker.
> >> This actually means, that no client tracker will be started in a container at
> >> all, because Legacy tracker init will return -EINVAL for a container.
> >> So, let's change "-EINVAL" on "-ENOTSUPP" for legacy tracker init call in a
> >> container and in case of this error code, try nfsdcld client tracker instead
> >> of returning a error.
> >>
> >> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> >> ---
> >>   fs/nfsd/nfs4recover.c |   12 ++++++++----
> >>   1 files changed, 8 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> >> index e0ae1cf..8aa069a 100644
> >> --- a/fs/nfsd/nfs4recover.c
> >> +++ b/fs/nfsd/nfs4recover.c
> >> @@ -524,7 +524,7 @@ nfsd4_legacy_tracking_init(struct net *net)
> >>   	if (net != &init_net) {
> >>   		WARN(1, KERN_ERR "NFSD: attempt to initialize legacy client "
> >>   			"tracking in a container!\n");
> >> -		return -EINVAL;
> >> +		return -ENOTSUPP;
> >>   	}
> >>
> >>   	status = nfs4_legacy_state_init(net);
> >> @@ -1285,14 +1285,17 @@ nfsd4_client_tracking_init(struct net *net)
> >>   	/*
> >>   	 * See if the recoverydir exists and is a directory. If it is,
> >>   	 * then use the legacy ops.
> >> +	 * If legacy ops init return -ENOSUPP, then we are in a container and
> >> +	 * should try nfsdcld client tracking.
> >>   	 */
> >>   	nn->client_tracking_ops = &nfsd4_legacy_tracking_ops;
> >>   	status = kern_path(nfs4_recoverydir(), LOOKUP_FOLLOW, &path);
> >>   	if (!status) {
> >> -		status = S_ISDIR(path.dentry->d_inode->i_mode);
> >> +		if (S_ISDIR(path.dentry->d_inode->i_mode))
> >> +			status = nn->client_tracking_ops->init(net);
> >>   		path_put(&path);
> >> -		if (status)
> >> -			goto do_init;
> >> +		if (status != -ENOTSUPP)
> >> +			goto do_exit;
> >>   	}
> >>
> >>   	/* Finally, try to use nfsdcld */
> >> @@ -1302,6 +1305,7 @@ nfsd4_client_tracking_init(struct net *net)
> >>   			"nfsdcltrack.\n");
> >>   do_init:
> >>   	status = nn->client_tracking_ops->init(net);
> >> +do_exit:
> >>   	if (status) {
> >>   		printk(KERN_WARNING "NFSD: Unable to initialize client "
> >>   				    "recovery tracking! (%d)\n", status);
> >>
> >
> > Seems OK as a stopgap fix. We're removing nfsdcld in 3.10 though so
> > this won't help prospective users of nfsd in a container for
> > long...particularly since our expectation is that no one has actually
> > ever deployed nfsdcld.
> >
> > This is something that really needs to be fixed the right way since a
> > NFS server that doesn't allow clients to reclaim state after a reboot is
> > potentially dangerous...
> >
> > I'm afraid I haven't been following along as closely as I should have
> > been. What's the rationale for disabling the UMH upcall? Is there no
> > way to make it so that new processes it spawns are done within the
> > correct container?
> >
> 
> Straight answer is "no, there is no way to do so": UMH threads are spawned in "init" context.
> But we solve the problem in a slightly different way.
> 
> So, here are my ideas about all the trackers (I haven't shared them yet, so I do it now):
> 
> 1) nfsdcld uses SUNRPC pipefs, which is containerised already. So it was very easy to containerise it.
> 

Right, but we want this one to just go away. It got superceded by the
UMH upcall and probably shouldn't have been merged in the first place
(mea culpa). That'll get ripped out when the 3.10 merge window opens,
so we don't really want to encourage anyone to use it.

> 2) Legacy tracker uses path. All is great and simple until we imagine two containers with the same root. In this case we have to make sure, that we can start 
> only one NFSd with this path (I don't care about user-space problems).
> I was thinking about global in-kernel RB tree for all paths. But maybe even a simple global list is enough (not so many NFSd can be started, and it not a 
> fast-path to optimise the search over all used paths).
> 

Well, you have a path, sure. In principle you could make that path
relative to the correct namespace for each server, and maybe allow this
to be settable on a per-namespace basis.

That said, it's probably best not to put to much effort into this
either. We want to eventually deprecate the legacy tracker too. So
limiting its use to the "init" namespace seems like a reasonable
stopgap fix, IMO...

> 3) UMH lookup and execute binary from current root. This problem just chasing all the containerisation work. So, either UHM logic have to updated (which is not 
> trivial or easy to implement and push upstream), or process root have to swapped to the right (container's) one. This, BTW, not that hard, because UMH call 
> accept "init" callback, which can be used to swap the root right before do_execve() is called.
> 
> What do you, guys, think about all this?
> 

You mean just change to use call_usermodehelper_fns() and pass in the
correct namespace info? Yeah that looks like the easiest fix and sounds
quite reasonable.

-- 
Jeff Layton <jlayton@redhat.com>
