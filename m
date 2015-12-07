Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:36657 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728AbbLGQMa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2015 11:12:30 -0500
Received: by qgcc31 with SMTP id c31so146683911qgc.3
        for <linux-nfs@vger.kernel.org>; Mon, 07 Dec 2015 08:12:29 -0800 (PST)
Date: Mon, 7 Dec 2015 11:12:26 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151207111226.6e56f7ab@tlielax.poochiereds.net>
In-Reply-To: <20151207141701.GA1376@lst.de>
References: <20151201174800.407e2c40@synchrony.poochiereds.net>
	<20151202072504.GA15839@lst.de>
	<20151203220850.GC19518@fieldses.org>
	<20151204083803.GA2440@lst.de>
	<20151204155110.64a352dd@tlielax.poochiereds.net>
	<20151205120222.GA27009@lst.de>
	<20151205072409.46d66109@tlielax.poochiereds.net>
	<20151206080954.1fe7e5c9@tlielax.poochiereds.net>
	<20151207130932.GB30843@lst.de>
	<20151207082803.0b160bb6@tlielax.poochiereds.net>
	<20151207141701.GA1376@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 7 Dec 2015 15:17:01 +0100
Christoph Hellwig <hch@lst.de> wrote:

> On Mon, Dec 07, 2015 at 08:28:03AM -0500, Jeff Layton wrote:
> > My understanding is that you need to increment the seqid when prior to
> > sending the callback. The basic idea there is that you want to ensure
> > that any LAYOUTGETs that were sent before the CB_LAYOUTRECALL get back
> > an OLD_STATEID error. RFC5661, Section 12.5.3:
> > 
> >     After the layout stateid is established, the server increments by
> >     one the value of the "seqid" in each subsequent LAYOUTGET and
> >     LAYOUTRETURN response, and in each CB_LAYOUTRECALL request.
> 
> True.  Although I really don't see any way to make layoutrecall processing
> race free that way.  I guess your patch to just drop the mutex is the
> best we could do.
> 
> Note that it doesn't really matter for the current server, as we will
> always recall the whole file, and thus leave no layout state for it on
> the client.  But for finger grained recalls this could become a
> problem.


Just thinking out loud...

So we inc the seqid when sending the recall, and then the
layoutreturn(s) will inc it again, so that should cover those cases.

Let's suppose that the client returns 0 for the CB though, but never
actually returns the layouts. At that point I guess we need to revoke
the whole stateid, similarly to how we revoke delegations that aren't
returned.

The catch here is that the revocation timer is the same as the RPC
timeout period. It doesn't seem like there ought to be any relationship
there. It ought to be 1-2 lease periods, IIRC?
-- 
Jeff Layton <jlayton@poochiereds.net>
