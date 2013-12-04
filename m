Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932320Ab3LDNb1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Dec 2013 08:31:27 -0500
Date: Wed, 4 Dec 2013 08:31:01 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, gartim@gmail.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: when reusing an existing repcache entry, unhash
 it first
Message-ID: <20131204083101.6422fb40@tlielax.poochiereds.net>
In-Reply-To: <20131204130944.GA3464@infradead.org>
References: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
	<20131203102517.GA12576@infradead.org>
	<20131203132112.1f19c014@tlielax.poochiereds.net>
	<20131204083336.GB30216@infradead.org>
	<20131204075402.7b00d09d@tlielax.poochiereds.net>
	<20131204130944.GA3464@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 4 Dec 2013 05:09:44 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Dec 04, 2013 at 07:54:02AM -0500, Jeff Layton wrote:
> > Are you suggesting that we shouldn't try to bound the cache at all and
> > should instead just let it grow and rely on the shrinker to keep it in
> > check?
> 
> Exactly.  Btw, what about the comment that the DRC should be per-client
> on top of the file?  That also seems like some very low hanging fruit.
> 

Ok, I'll see about spinning up a patchset that does that. We'll also
probably want to just allocate entries out of the slabcache in that
case, so that'll make things quite a bit simpler.

As far as making this a per-client cache...sounds great! Go for it!
-- 
Jeff Layton <jlayton@redhat.com>
