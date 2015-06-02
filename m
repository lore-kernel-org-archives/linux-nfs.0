Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60485 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753009AbbFBMkb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2015 08:40:31 -0400
Date: Tue, 2 Jun 2015 13:40:26 +0100
From: Mel Gorman <mgorman@suse.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Jerome Marchand <jmarchan@redhat.com>
Subject: Re: [PATCH 3/4] sunrpc: if we're closing down a socket, clear
 memalloc on it first
Message-ID: <20150602124025.GG26425@suse.de>
References: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
 <1432987393-15604-4-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
In-Reply-To: <1432987393-15604-4-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 30, 2015 at 08:03:12AM -0400, Jeff Layton wrote:
> We currently increment the memalloc_socks counter if we have a xprt that
> is associated with a swapfile. That socket can be replaced however
> during a reconnect event, and the memalloc_socks counter is never
> decremented if that occurs.
> 
> When tearing down a xprt socket, check to see if the xprt is set up for
> swapping and sk_clear_memalloc before releasing the socket if so.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs
