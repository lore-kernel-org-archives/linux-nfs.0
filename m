Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44273 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747AbaGJIEI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 04:04:08 -0400
Date: Thu, 10 Jul 2014 01:04:07 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 013/100] nfsd: shrink st_access_bmap and st_deny_bmap
Message-ID: <20140710080407.GC6226@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-14-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404842668-22521-14-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 08, 2014 at 02:03:01PM -0400, Jeff Layton wrote:
> We never use anything above bit #3, so an unsigned long for each is
> wasteful. Shrink them to a char each, and add some WARN_ON_ONCE calls if
> we try to set or clear bits that would go outside those sizes.
> 
> Note too that because atomic bitops work on unsigned longs, we have to
> abandon their use here. That shouldn't be a problem though since we
> don't really care about the atomicity in this code anyway. Using them
> was just a convenient way to flip bits.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
