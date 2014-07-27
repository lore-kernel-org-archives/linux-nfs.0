Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58598 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbaG0NhB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jul 2014 09:37:01 -0400
Date: Sun, 27 Jul 2014 06:37:00 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 07/40] nfsd: do filp_close in sc_free callback for lock
 stateids
Message-ID: <20140727133700.GI32153@infradead.org>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
 <1405954972-28904-8-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405954972-28904-8-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 21, 2014 at 11:02:19AM -0400, Jeff Layton wrote:
> Releasing locks when we unhash the stateid instead of doing so only when
> the stateid is actually released will be problematic in later patches
> when we need to protect the unhashing with spinlocks. Move it into the
> sc_free operation instead.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Looks reasonable except that sc_free is now initialized twice for
lock stateids.

