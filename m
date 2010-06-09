Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26494 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752463Ab0FIKyL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jun 2010 06:54:11 -0400
Date: Wed, 9 Jun 2010 06:55:55 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] nfsd: fix error handling in write_ports interfaces
Message-ID: <20100609065555.5850427d@corrin.poochiereds.net>
In-Reply-To: <20100609004958.GA28390@fieldses.org>
References: <1275924800-5214-1-git-send-email-jlayton@redhat.com>
	<20100609004958.GA28390@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 8 Jun 2010 20:49:58 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jun 07, 2010 at 11:33:17AM -0400, Jeff Layton wrote:
> > This patchset fixes some problems with refcounting when there are
> > problems starting up nfsd. The easiest way to reproduce this is to have
> > rpcbind down and then try to start nfsd. The write_ports calls will
> > generally return failure at that point due to the fact that lockd can't
> > register its ports. That leaves the nfsd_serv pointer set, with the
> > sv_threads count set at 0. The first two patches fix this problem.
> > 
> > The third patch, I'm not 100% sure on. It looks correct to me, but the
> > intent of the existing code is not very clear. I know this interface is
> > used by the rdma code, and I may be missing the point of doing it this
> > way. If the existing code is correct as-is, I'll plan to do a patch to
> > add some clarifying comments.
> > 
> > It also seems suspicious to me that __write_ports_addfd/delfd take and
> > put lockd references, but the addxprt/delxprt interfaces do not. If
> > someone were to addfd a socket and then delxprt it, it'll leave a lockd
> > reference dangling.
> 
> I haven't looked at this closely enough to have any though beyond: boy,
> it seems confusing to use sv_nrthreads this way.  What is the
> refcounting actually meant to accomplish, and if we were designing it
> from scratch, what would we do?
> 

Yeah, I had the same thought. The fundamental problem I think is that
the refcounting serves two purposes:

1) it tracks the number of running nfsd threads

2) it serves as a refcount for the nfsd_serv itself

Of course, neither of these is entirely accurate since they're two
different things...

I'm not sure how to make this better. One idea might be to store the
"portlist" information in a separate container that's divorced from
the nfsd_serv. Then when you start the first thread you'd just bring up
whatever sockets were in the container. If you write to the portlist
file then you'd just sync up the sockets that nfsd_serv has open with
what's in the container.

-- 
Jeff Layton <jlayton@redhat.com>
