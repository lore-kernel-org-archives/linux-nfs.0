Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f41.google.com ([74.125.82.41]:60686 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754202AbaFYNy1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 09:54:27 -0400
Message-ID: <53AAD48C.7090401@suse.cz>
Date: Wed, 25 Jun 2014 15:54:20 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
To: Jeff Layton <jlayton@primarydata.com>, stable@vger.kernel.org
CC: kasparek@fit.vutbr.cz, linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [stable PATCH] nfsd: don't halt scanning the DRC LRU list when
 there's an RC_INPROG entry
References: <1403704114-3536-1-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403704114-3536-1-git-send-email-jlayton@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/25/2014 03:48 PM, Jeff Layton wrote:
> The patch below has already made it into mainline as commit
> 1b19453d1c6abcfa7c312ba6c9f11a277568fc94. I think we need it in stable
> as well. In addition to making the cache pruner more efficient, it also
> fixes a logic bug in prune_cache_entries. If num_drc_entries is greater
> than the max, then we can end up freeing the entry even if it's still
> RC_INPROG. This patch ensures that RC_INPROG entries are always skipped
> and that prevents a use-after-free.
> 
> Please apply this to any stable kernel, v3.9 or above. Original patch
> description follows.

Pushed to 3.12 too. Thanks.

-- 
js
suse labs
