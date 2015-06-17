Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:48521 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbFQMqE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2015 08:46:04 -0400
Date: Wed, 17 Jun 2015 05:46:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: blocklayout regression in "pnfs: lookup new lseg at lseg
 boundary"
Message-ID: <20150617124603.GA1199@infradead.org>
References: <20150425165640.GA2008@infradead.org>
 <20150507074215.GA14450@infradead.org>
 <8C6E88F8-19DB-49B1-A0A8-ADA171D113AB@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8C6E88F8-19DB-49B1-A0A8-ADA171D113AB@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 13, 2015 at 11:17:52AM -0400, Weston Andros Adamson wrote:
> Hey Christoph,
> 
> Sorry this got buried in my inbox :-/
> 
> -               WARN_ON_ONCE(req_start > seg_end);
> +               WARN_ON_ONCE(req_start >= seg_end);
> 
> I think you???re right, I shouldn???t have changed that WARN_ON.
> 
> It???s been a while since I looked at this, but I???m wondering if that WARN_ON
> even makes sense anymore now that we do handle multiple segments.

Are you going to send a patch for this?
