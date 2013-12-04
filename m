Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34458 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754095Ab3LDOZN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Dec 2013 09:25:13 -0500
Date: Wed, 4 Dec 2013 09:25:09 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@redhat.com>, gartim@gmail.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: when reusing an existing repcache entry, unhash it
 first
Message-ID: <20131204142509.GA14646@fieldses.org>
References: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
 <20131203102517.GA12576@infradead.org>
 <20131203132112.1f19c014@tlielax.poochiereds.net>
 <20131204083336.GB30216@infradead.org>
 <20131204075402.7b00d09d@tlielax.poochiereds.net>
 <20131204130944.GA3464@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131204130944.GA3464@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 04, 2013 at 05:09:44AM -0800, Christoph Hellwig wrote:
> On Wed, Dec 04, 2013 at 07:54:02AM -0500, Jeff Layton wrote:
> > Are you suggesting that we shouldn't try to bound the cache at all and
> > should instead just let it grow and rely on the shrinker to keep it in
> > check?
> 
> Exactly.

As long as the lookup times stay reasonable....

--b.
