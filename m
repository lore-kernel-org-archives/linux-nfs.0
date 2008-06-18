From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] knfsd: nfsd: Handle ERESTARTSYS from syscalls.
Date: Wed, 18 Jun 2008 11:59:26 -0400
Message-ID: <20080618155926.GA25297@fieldses.org>
References: <20080613213759.26929.patches@notabene> <1080613114215.27095@suse.de> <48565F19.10508@redhat.com> <76bd70e30806160809o495dd50fw88a80ec0673c0dc1@mail.gmail.com> <1213635286.7238.13.camel@localhost> <18519.24997.34761.283298@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Chuck Lever <chucklever@gmail.com>,
	Peter Staubach <staubach@redhat.com>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41954 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750880AbYFRP7h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jun 2008 11:59:37 -0400
In-Reply-To: <18519.24997.34761.283298-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 17, 2008 at 05:03:01PM +1000, Neil Brown wrote:
> On Monday June 16, trond.myklebust@fys.uio.no wrote:
> > On Mon, 2008-06-16 at 11:09 -0400, Chuck Lever wrote:
> > 
> > > I think an error reply is much better than no reply in nearly every
> > > case.  NFS3ERR_JUKEBOX/NFS4ERR_DELAY is an interesting idea, but
> > > something else again will probably be required for v4.1 with sessions.
> > 
> > NFS3ERR_JUKEBOX/NFS4ERR_DELAY may be inappropriate if the nfs daemon has
> > already started handling the RPC call, since you may be interrupting a
> > non-idempotent operation.
> 
> If the filesystem allows you to interrupt a non-idempotent operation
> part way through, then the filesystem is doing something very wrong.
> 
> The observed behaviour is that multiple 32K writes are outstanding
> (in different nfsd threads) when a signal is delivered to each nfsd.
> 
> OCFS2 appears to be serialising these writes.
> 
> One of the writes completes returning a length that is less than 32K.
> This length is returned to the client.  A quick look at the client
> code suggests that it complains with a printk, and tries to write the
> remainder, which seems correct.
> 
> The other writes all complete with ERESTARTSYS.  Presumably they
> haven't started at all.  If they had, you might expect a partial
> return from them too.
> 
> So far, what OCFS2 is doing seems credible and doesn't leave us in an
> awkward position with respect to incomplete idempotent operations.
> 
> I cannot be certain, but I'm willing to believe that OCFS2 only
> returns ERESTARTSYS when the operation hasn't been performed at all
> (or has been wound-back to the starting condition).
> 
> I agree that NFS3ERR_JUKEBOX is more appropriate than no reply, but I
> don't think there is any reason to suspect that will not be
> sufficient.

OK.  Want to send a replacement patch?

--b.
