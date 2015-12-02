Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:56797 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752459AbbLBHZG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2015 02:25:06 -0500
Date: Wed, 2 Dec 2015 08:25:04 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151202072504.GA15839@lst.de>
References: <1442491104-30080-1-git-send-email-jeff.layton@primarydata.com> <565A7A14.4010902@gmail.com> <20151129084614.42fb1272@tlielax.poochiereds.net> <565BBB03.7020206@gmail.com> <20151130213420.GA31564@fieldses.org> <20151130193313.5bb10791@synchrony.poochiereds.net> <20151201115600.GA1557@lst.de> <20151201174800.407e2c40@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151201174800.407e2c40@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 01, 2015 at 05:48:00PM -0500, Jeff Layton wrote:
> > But for non-forgetful clients I wonder if returning 0 should be
> > interpreted the same as NFS4ERR_DELAY?  Note that we still need to
> > time out the client if it doesn't respond in time, so NFS4ERR_DELAY
> > seems better than 0, but the standard doesn't really talk about
> > return values other than NFS4ERR_NOMATCHING_LAYOUT.
> 
> My interpretation is somewhat different. To me, this is how we'd
> interpret the response from the client (pseudocode):
> 
> NFS_OK:
> 	/* Message received. I'll start returning these layouts soon. */
> NFS4ERR_DELAY:
> 	/* I'm too resource constrained to even process this simple
>            request right now. Please ask me again in a bit. */
> NFS4ERR_NOMATCHING_LAYOUT:
> 	/* Huh? What layout? */
> 
> ...IMO, the spec is pretty clear that a successful response from the
> client just means that it got the message that it should start
> returning layouts. If it happens to return anything before the cb
> response, then that's just luck/coincidence. The server shouldn't count
> on that.

Ok, so for 0 we should re check if the layouts are still outstanding
before sending the next recall.  But given that we have no client
returning that or test cases I'd be tempted to treat OK like DELAY
for now - if the client is properly implemented it will eventually
return NFS4ERR_NOMATCHING_LAYOUT.  We can add a big comment on why
we're doing that so that it's obvious.
