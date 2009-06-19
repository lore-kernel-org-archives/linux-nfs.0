From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/5] nfsd: add support for NFSv4 callbacks over IPv6
 (try #2)
Date: Fri, 19 Jun 2009 16:05:29 -0400
Message-ID: <20090619160529.37ba9987@tlielax.poochiereds.net>
References: <1245436981-11806-1-git-send-email-jlayton@redhat.com>
	<20090619195810.GB28506@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59242 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884AbZFSUFf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jun 2009 16:05:35 -0400
In-Reply-To: <20090619195810.GB28506@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 19 Jun 2009 15:58:10 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Jun 19, 2009 at 02:42:56PM -0400, Jeff Layton wrote:
> > Here's a second pass at adding support for NFSv4 callback channels over
> > IPv6. The main changes since the last set are:
> > 
> > 1) rebase to Bruce's master/for-2.6.31 branches. It applies cleanly to
> > either.
> > 
> > 2) cleaned up the IPv6-enablement patch: mostly this was done by
> > removing conditional compilation from several places where it wasn't
> > really required.
> > 
> > 3) add patch that makes it set the sin6_scope_id for the callback
> > address to the same value as the sin6_scope_id in the svc_rqst->rq_addr.
> > This allows the server to call back clients that mounted the server via
> > one of its link-local addresses.
> > 
> > Again, tested using opensolaris and linux clients and watching the
> > traffic with wireshark. Everything seems to work. Delegations and
> > recalls work fine to opensolaris.
> > 
> > I seem to be having some trouble getting the server to issue delegations
> > to linux clients, but I can see the callback channel being correctly
> > established.
> > 
> > I think the problem with delegations is unrelated to this set. It seems
> > to still be a problem even with IPv4 on an unpatched kernel. I think it
> > has something to do with how linux clients are generating open_owner
> > ID's. I'll email the list separately about that...
> 
> The usual problem here is just that delegations aren't given out on
> first use of an open_owner.  You'll probably need to open the file
> twice.
> 

Yep I tried that and it still didn't work. Looks like the client is
generating a different open_owner on each open call. I even tried
having the same process open and close the file multiple times and it
generated a different open_owner for each open call.

For the record, the client is running a Fedora 11 kernel:

2.6.29.4-167.fc11.x86_64

...I need to dig a little deeper when I get some time, but I'm pretty
sure it's a client problem.

-- 
Jeff Layton <jlayton@redhat.com>
