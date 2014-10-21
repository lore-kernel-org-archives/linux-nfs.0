Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60903 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932170AbaJULw7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Oct 2014 07:52:59 -0400
Date: Tue, 21 Oct 2014 04:52:58 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: convert nfs4_file searches to use RCU
Message-ID: <20141021115258.GA14331@infradead.org>
References: <1413541275-3884-1-git-send-email-jlayton@primarydata.com>
 <20141021104013.GC21863@infradead.org>
 <20141021071606.17f2513f@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141021071606.17f2513f@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 21, 2014 at 07:16:06AM -0400, Jeff Layton wrote:
> Yeah, that's probably fine. Suggestions on what to union it with?
> 
> struct callback_head is two pointers, so maybe we can use one of the
> list_heads (fi_delegations maybe?).

Sounds reasonable to me.

> If we do want to change to a different type of structure I'd be fine
> with that, but would prefer that it be RCU-friendly. What sort of
> structure did you have in mind?

For the XFS inode lookup we use multiple radix trees, which work
very well for how inode numbers work in XFS with a clear allocation
group component, and usual clustering of inode numbers.  A simple
radix tree might work fine for NFSd, or maybe the new resizable hash
tables from the networking folks?
