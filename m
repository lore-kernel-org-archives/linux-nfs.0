Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59145 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757217Ab0IGTCj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 15:02:39 -0400
Subject: Re: [PATCH 03/03] sunrpc: scale hashtable cache size with memory
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Miquel van Smoorenburg <mikevs@xs4all.net>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100822183149.GC26607@xs4all.net>
References: <20100822182848.GA26590@xs4all.net>
	 <20100822183149.GC26607@xs4all.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Sep 2010 15:02:19 -0400
Message-ID: <1283886139.2788.72.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2010-08-22 at 20:31 +0200, Miquel van Smoorenburg wrote:
> Set the number of entries of the authcache to 4096 on servers
> with 4G of memory or more. Because kmallocing more than a few K
> is frowned upon, change the allocator from kmalloc to __get_free_pages.
> Since the minimum allocation size of __get_free_pages is 1 page,
> set the number of entries in the authcache to PAGE_SIZE / (entry_size)
> on servers with < 4G of memory so that exactly one page is used.

I'm not really understanding why this is an improvement. kmalloc() will
use pretty much the same mechanism when allocating a slab that is >
PAGE_SIZE, so why should we duplicate that in the RPC layer?

Cheers
  Trond
