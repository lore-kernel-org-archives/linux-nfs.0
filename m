From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] knfsd: nfsd: Handle ERESTARTSYS from syscalls.
Date: Tue, 17 Jun 2008 17:03:01 +1000
Message-ID: <18519.24997.34761.283298@notabene.brown>
References: <20080613213759.26929.patches@notabene>
	<1080613114215.27095@suse.de>
	<48565F19.10508@redhat.com>
	<76bd70e30806160809o495dd50fw88a80ec0673c0dc1@mail.gmail.com>
	<1213635286.7238.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chucklever@gmail.com>,
	Peter Staubach <staubach@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58570 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751186AbYFQHD5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jun 2008 03:03:57 -0400
In-Reply-To: message from Trond Myklebust on Monday June 16
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday June 16, trond.myklebust@fys.uio.no wrote:
> On Mon, 2008-06-16 at 11:09 -0400, Chuck Lever wrote:
> 
> > I think an error reply is much better than no reply in nearly every
> > case.  NFS3ERR_JUKEBOX/NFS4ERR_DELAY is an interesting idea, but
> > something else again will probably be required for v4.1 with sessions.
> 
> NFS3ERR_JUKEBOX/NFS4ERR_DELAY may be inappropriate if the nfs daemon has
> already started handling the RPC call, since you may be interrupting a
> non-idempotent operation.

If the filesystem allows you to interrupt a non-idempotent operation
part way through, then the filesystem is doing something very wrong.

The observed behaviour is that multiple 32K writes are outstanding
(in different nfsd threads) when a signal is delivered to each nfsd.

OCFS2 appears to be serialising these writes.

One of the writes completes returning a length that is less than 32K.
This length is returned to the client.  A quick look at the client
code suggests that it complains with a printk, and tries to write the
remainder, which seems correct.

The other writes all complete with ERESTARTSYS.  Presumably they
haven't started at all.  If they had, you might expect a partial
return from them too.

So far, what OCFS2 is doing seems credible and doesn't leave us in an
awkward position with respect to incomplete idempotent operations.

I cannot be certain, but I'm willing to believe that OCFS2 only
returns ERESTARTSYS when the operation hasn't been performed at all
(or has been wound-back to the starting condition).

I agree that NFS3ERR_JUKEBOX is more appropriate than no reply, but I
don't think there is any reason to suspect that will not be
sufficient.

Thanks,
NeilBrown
