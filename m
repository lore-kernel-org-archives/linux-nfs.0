Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:43056 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264Ab3J2PL4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 11:11:56 -0400
Date: Tue, 29 Oct 2013 08:11:53 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [RFC 5/4] NFSD: Add basic CB_OFFLOAD support
Message-ID: <20131029151153.GA26603@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-6-git-send-email-bjschuma@netapp.com>
 <20131028215221.GQ31322@fieldses.org>
 <20131029073719.GB10889@infradead.org>
 <20131029133611.GF29606@fieldses.org>
 <20131029133800.GA27762@infradead.org>
 <20131029135321.GI29606@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131029135321.GI29606@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 09:53:21AM -0400, J. Bruce Fields wrote:
> Your complaint as I understand it is that quick and long-running
> operations were combined into one one operation when they would have
> better been separated. I agree.

Not just quick and long running but semantically different -
preallocating space and writing zeroes over every byte are fundamentally
different operations.

> But I also don't understand why the long-running operations need an
> async option.  Maybe they do, I just don't understand why.

I didn't even bother questioning that, but it's not a bad question
either.

