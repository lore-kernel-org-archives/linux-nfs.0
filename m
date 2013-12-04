Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45980 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932585Ab3LDREC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Dec 2013 12:04:02 -0500
Date: Wed, 4 Dec 2013 12:06:16 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, gartim@gmail.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: when reusing an existing repcache entry, unhash
 it first
Message-ID: <20131204120616.464e79d8@corrin.poochiereds.net>
In-Reply-To: <20131204142509.GA14646@fieldses.org>
References: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
	<20131203102517.GA12576@infradead.org>
	<20131203132112.1f19c014@tlielax.poochiereds.net>
	<20131204083336.GB30216@infradead.org>
	<20131204075402.7b00d09d@tlielax.poochiereds.net>
	<20131204130944.GA3464@infradead.org>
	<20131204142509.GA14646@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 4 Dec 2013 09:25:09 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Dec 04, 2013 at 05:09:44AM -0800, Christoph Hellwig wrote:
> > On Wed, Dec 04, 2013 at 07:54:02AM -0500, Jeff Layton wrote:
> > > Are you suggesting that we shouldn't try to bound the cache at all and
> > > should instead just let it grow and rely on the shrinker to keep it in
> > > check?
> > 
> > Exactly.
> 
> As long as the lookup times stay reasonable....
> 

That is another tricky question. Currently, we size the number of hash
buckets based on the max size of the cache. If we allow it to grow
without bound, then how do we determine how many hash buckets we need?

-- 
Jeff Layton <jlayton@redhat.com>
