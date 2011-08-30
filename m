Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244Ab1H3CgE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2011 22:36:04 -0400
Date: Mon, 29 Aug 2011 22:35:28 -0400 (EDT)
Message-Id: <20110829.223528.1015352328965337938.davem@davemloft.net>
To: Trond.Myklebust@netapp.com
Cc: bharrosh@panasas.com, joe@perches.com, bfields@fieldses.org, neilb@suse.de,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging messages
From: David Miller <davem@davemloft.net>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4FAF@SACMVEXC2-PRD.hq.netapp.com>
References: <4E5C0AB3.90401@panasas.com>
	<20110829.180348.1774953636752413432.davem@davemloft.net>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4FAF@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Date: Mon, 29 Aug 2011 16:25:08 -0700

> I can see that slub.c has the slab_out_of_memory() function that
> (although ratelimited) warns you if the allocation failed. However I
> can't find any equivalent for slab.c or slob.c.

See the page allocator.
