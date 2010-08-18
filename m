Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:46445 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab0HRTe5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 15:34:57 -0400
Date: Wed, 18 Aug 2010 15:34:40 -0400
From: Chris Mason <chris.mason@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] VM: kswapd should not do blocking memory allocations
Message-ID: <20100818193440.GZ5854@think>
References: <1282158241.8540.85.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1282158241.8540.85.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 18, 2010 at 03:04:01PM -0400, Trond Myklebust wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Allowing kswapd to do GFP_KERNEL memory allocations (or any blocking memory
> allocations) is wrong and can cause deadlocks in try_to_release_page(), as
> the filesystem believes it is safe to allocate new memory and block,
> whereas kswapd is there specifically to clear a low-memory situation...
> 
> Set the gfp_mask to GFP_IOFS instead.

I always thought releasepage was supposed to do almost zero work.  It
could release an instantly freeable page but it wasn't supposed to dive
in and solve world hunger or anything.

I thought the VM would be using writepage for that.

-chris
