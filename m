Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59739 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbaFGO0f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jun 2014 10:26:35 -0400
Date: Sat, 7 Jun 2014 07:26:34 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSd: nfs4_preprocess_seqid_op should only set *stpp on
 success
Message-ID: <20140607142634.GA3700@infradead.org>
References: <1402080994-23737-1-git-send-email-jlayton@primarydata.com>
 <20140607140800.GA18140@infradead.org>
 <20140607102326.3b48b558@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140607102326.3b48b558@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 07, 2014 at 10:23:26AM -0400, Jeff Layton wrote:
> Yeah, I mentioned that to Bruce on IRC. This is not really a bugfix,
> per-se, but more of a defensive coding measure.

Looks fine to me for that,

Reviewed-by: Christoph Hellwig <hch@lst.de>
