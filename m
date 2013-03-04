Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55453 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758738Ab3CDUSv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Mar 2013 15:18:51 -0500
Date: Mon, 4 Mar 2013 15:18:46 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org, devel@openvz.org,
        Trond.Myklebust@netapp.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: try nfsdcld client tracker in containers
Message-ID: <20130304201846.GH20389@fieldses.org>
References: <20130301082423.21663.37825.stgit@localhost.localdomain>
 <20130301080911.2a1a28a2@corrin.poochiereds.net>
 <51344175.40503@parallels.com>
 <20130304094736.57a288b9@tlielax.poochiereds.net>
 <5134E043.70609@parallels.com>
 <20130304150422.0a1743f4@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20130304150422.0a1743f4@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 04, 2013 at 03:04:22PM -0500, Jeff Layton wrote:
> On Mon, 4 Mar 2013 21:56:19 +0400
> Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:
> 
> > 04.03.2013 18:47, Jeff Layton пишет:
> > > On Mon, 4 Mar 2013 10:38:45 +0400
> > > Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:
> > >> 3) UMH lookup and execute binary from current root. This problem just chasing all the containerisation work. So, either UHM logic have to updated (which is not
> > >> trivial or easy to implement and push upstream), or process root have to swapped to the right (container's) one. This, BTW, not that hard, because UMH call
> > >> accept "init" callback, which can be used to swap the root right before do_execve() is called.
> > >>
> > >> What do you, guys, think about all this?
> > >>
> > > You mean just change to use call_usermodehelper_fns() and pasn the
> > > correct namespace info? Yeah that looks like the easiest fix and sounds
> > > quite reasonable.
> > >
> > 
> > Nope. The problem here is not a namespace, but root path:
> > mount point + dentry.
> > do_execve() uses root path from current for search for any string path.
> > And this root path is inherited from the kernel thread. Which means,
> > that this is global "init" root path.
> > Thus, if is we want to search for path in a container (which could
> > have it's own nested root), we have to swap the root in usermode
> > helper thread before do_execve() call.
> > We can use call_usermodehelper_fns() to pass init callback and swap root 
> > in it.
> > But the problem here is that root swaping is not that... gentle.
> > I.e. we were trying to avoid it. For example, local SUNRPC transports
> > now connects synchronously (to make sure, that connection will be done in
> > proper root environment).
> > Nevertheless, I don't see any other way to containerize UMH so far.
> > 
> > Bruce, what's your opinion about this?
> > 
> > 
> 
> It doesn't seem all that awful here. Once we've spawned this new
> process it'll just run to completion and exit within the container. We
> shouldn't ever need to go back to the original root.
> 
> In the sunrpc layer, it's a little more complicated since you're
> working with kernel threads and workqueues that may be shared between
> containers (right?).

Also, is this really the only place that needs this?

I guess NFS for now allows mounts only in the initial namespace, so the
idmap upcalls can always be done there.  Module lookup and any usermode
helpers used for hardware setup probably also only happen in the initial
namespace.  Hrm.  Still, seems likely to be useful to someone
eventually.

--b.
