Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932708Ab3LDSlr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Dec 2013 13:41:47 -0500
Date: Wed, 4 Dec 2013 13:43:57 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, gartim@gmail.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: when reusing an existing repcache entry, unhash
 it first
Message-ID: <20131204134357.6de3ae51@corrin.poochiereds.net>
In-Reply-To: <20131204170602.GA13308@infradead.org>
References: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
	<20131203102517.GA12576@infradead.org>
	<20131203132112.1f19c014@tlielax.poochiereds.net>
	<20131204083336.GB30216@infradead.org>
	<20131204075402.7b00d09d@tlielax.poochiereds.net>
	<20131204130944.GA3464@infradead.org>
	<20131204142509.GA14646@fieldses.org>
	<20131204120616.464e79d8@corrin.poochiereds.net>
	<20131204170602.GA13308@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 4 Dec 2013 09:06:02 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Dec 04, 2013 at 12:06:16PM -0500, Jeff Layton wrote:
> > That is another tricky question. Currently, we size the number of hash
> > buckets based on the max size of the cache. If we allow it to grow
> > without bound, then how do we determine how many hash buckets we need?
> 
> It won't grow without bound as long as it's trimmed below the size
> by both the periodic workqueue and the shrinker.
> 

Right, but we don't know a priori how big the cache can grow, so that
makes determining the number of buckets to allocate a little tricky.

> Of course replacing the hash with an autoscaling data structure would be
> useful, but given that 4.1 obsoletes the DRC I'm not sure how much
> effort we want to put into it.

Agreed.

-- 
Jeff Layton <jlayton@redhat.com>
