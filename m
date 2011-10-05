Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54333 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932812Ab1JESUB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Oct 2011 14:20:01 -0400
Date: Wed, 5 Oct 2011 14:19:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>,
        "Kirill A. Shutemov" <kas@openvz.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: network-namespace-aware nfsd
Message-ID: <20111005181959.GB18449@fieldses.org>
References: <20111005150214.GA18449@fieldses.org>
 <4E8C9363.9030303@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4E8C9363.9030303@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 05, 2011 at 09:26:59PM +0400, Stanislav Kinsbursky wrote:
> 05.10.2011 19:02, J. Bruce Fields пишет:
> >This is a draft outline what we'd need to support containerized nfs
> >service; please tell me what I've got wrong.
> >
> >The goal is to give the impression of running multiple virtual nfs
> >services, each with its own ip address or addresses.
> >
> >A new nfs service will be started by forking off a new network
> >namespace, setting up interfaces there, and then starting nfs service
> >normally (including starting all the appropriate userland daemons, such
> >as rpc.mountd).
> >
> 
> Hello, Bruce.
> What do you mean by "nfs service will be started by forking off a
> new network namespace"?
> Does it means, that each nfs service start will create new network namespace?
> If so, what about if some process in freshly create namespace will
> start nfs service?

Sorry, what I meant to say was: "first userspace creates a new
namespace, then a process in that new namespace uses the ordinary
interfaces to start nfsd."

> If I understood you right, you want to share nfsd threads between
> environments and any of this threads can handle requests for
> different environments.
> Am I right?

Yes.

> If not - then what the difference with separated nfs servers?
> If yes, then will not we get problems with handling requests to
> container files with changed root?

I don't think so.  Here's roughly how nfsd looks up an inode given a
filehandle:

	- look up the ip address in the auth.unix.ip cache (filled by
	  rpc.mountd) and get a "struct auth_domain", which represents
	  some set of clients.  (E.g., "*.example.com").
	- extract the part of the filehandle that represents the export
	  and look that up in the nfsd.fh cache (also filled by
	  rpc.mountd); result is a path, resolved to a (vfsmount,
	  dentry) in the context of rpc.mountd.
	- look up the (auth_domain, path) pair in the nfsd.export cache
	  (again filled by rpc.mountd) to get export options (ro vs rw,
	  security requirements, etc.).

As long as we create per-network-namespace auth.unix.ip, nfsd.fh, and
nfsd.export caches, and as long as nfsd does those lookups in the right
cache (which should be easy, as it can always reach the namespace from
rqstp->rq_xprt->xpt_net).... I think it all works.  Do you see any
problem?

> And what about versions file? If we will share all kernel threads,
> doesn't it means, that we can't tune supported versions per network
> namespace?

Similarly net/sunrpc/svc.c:svc_process_common(), where the version check
is normally done, knows what namespace the request is associated with
(again by looking at xpt_net), and could look up the supported versions
per-namespace.

As long as everything on the server side is passed a struct svc_rqst, I
don't think having distinct thread pools would simplify anything.

Do you think I'm missing anything?

Also, do you think per-namespace version support is important?

> >NFSv4
> >-----
> >
> >To make NFSv4 work, we need per-network-namespace state that is
> >initialized and destroyed on startup and shutdown of a virtual nfs
> >server.  Each client therefore needs to be associated with a network
> >namespace, so it can be shut down at the right time, and so that we
> >consistently handle, for example, a broken NFSv4.0 client that sends the
> >same long-form identifier to servers with different IP addresses.
> >
> >For 4.1 we have the option of sharing state between servers if we'd
> >like.  Initially simplest is to advertise the servers as entirely
> >distinct, without the ability to share any state.
> >
> >The directory used for recovery data needs to be per-network-namespace.
> >If we replace it by something else, we'll need to make sure it's
> >namespace-aware.
> >
> >NFSv2/v3
> >--------
> >
> >For v2/v3 locking to work we also need per-network-namespace lockd and
> >statd state.
> >
> 
> What do you think about lockd kernel thread?
> I mean, do you want to share one thread for all network namespaces
> or create one thread per network namespace?

To start with I suspect it would be OK to share the one lockd thread.

Some day I would very much like to allow lockd to be multithreaded.  But
I don't know that we'd want separate threads per namespace.

--b.
