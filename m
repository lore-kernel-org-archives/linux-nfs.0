Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:43918 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932270Ab3LDNJs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 08:09:48 -0500
Date: Wed, 4 Dec 2013 05:09:44 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        gartim@gmail.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: when reusing an existing repcache entry, unhash it
 first
Message-ID: <20131204130944.GA3464@infradead.org>
References: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
 <20131203102517.GA12576@infradead.org>
 <20131203132112.1f19c014@tlielax.poochiereds.net>
 <20131204083336.GB30216@infradead.org>
 <20131204075402.7b00d09d@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131204075402.7b00d09d@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 04, 2013 at 07:54:02AM -0500, Jeff Layton wrote:
> Are you suggesting that we shouldn't try to bound the cache at all and
> should instead just let it grow and rely on the shrinker to keep it in
> check?

Exactly.  Btw, what about the comment that the DRC should be per-client
on top of the file?  That also seems like some very low hanging fruit.

