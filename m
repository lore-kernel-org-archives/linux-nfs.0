From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] knfsd: nfsd: Handle ERESTARTSYS from syscalls.
Date: Mon, 16 Jun 2008 14:13:55 -0400
Message-ID: <20080616141355.20b4f824@tleilax.poochiereds.net>
References: <20080613213759.26929.patches@notabene>
	<1080613114215.27095@suse.de>
	<48565F19.10508@redhat.com>
	<76bd70e30806160809o495dd50fw88a80ec0673c0dc1@mail.gmail.com>
	<1213635286.7238.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Chuck Lever <chucklever@gmail.com>,
	Peter Staubach <staubach@redhat.com>,
	NeilBrown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43737 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753194AbYFPSOJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jun 2008 14:14:09 -0400
In-Reply-To: <1213635286.7238.13.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 16 Jun 2008 12:54:46 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Mon, 2008-06-16 at 11:09 -0400, Chuck Lever wrote:
> 
> > I think an error reply is much better than no reply in nearly every
> > case.  NFS3ERR_JUKEBOX/NFS4ERR_DELAY is an interesting idea, but
> > something else again will probably be required for v4.1 with sessions.
> 
> NFS3ERR_JUKEBOX/NFS4ERR_DELAY may be inappropriate if the nfs daemon has
> already started handling the RPC call, since you may be interrupting a
> non-idempotent operation.
> 

But if you drop the reply, the client will probably still end up
retransmitting the request. It seems like a JUKEBOX/DELAY error
is at least a defined error to the client instead of leaving it
guessing. Either way, the client could still end up on the wrong
side of a non-idempotent op.

Also, am I right that this should really only be happening if nfsd
catches a SIGKILL? All other signals should be masked off when
doing the local file operation. Or do we have a potential race if
we catch a signal just after svc_recv returns but before the new
sigmask is set and svc_process is called?

> The only complete solution to this problem is NFSv4.1 with persistent
> sessions.
> 

That's probably the case, though we should probably try to do
best-effort for earlier versions.

-- 
Jeff Layton <jlayton@redhat.com>
