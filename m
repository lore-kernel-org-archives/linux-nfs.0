From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/5] pnfs-submit fix kfree under spin lock
Date: Tue, 20 Jul 2010 15:09:53 -0400
Message-ID: <20100720190953.GA22237@infradead.org>
References: <1279645283-9862-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51698 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932356Ab0GTTKG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 15:10:06 -0400
In-Reply-To: <1279645283-9862-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 20, 2010 at 01:01:18PM -0400, andros@netapp.com wrote:
> 
> Fix kfree under spin lock
> 
> Both put_lseg and put_layout are called under the inode i_lock where the
> last reference will end up freeing structures.
> 
> I know there has been a lot of churn in this code, but free'ing under the
> spin lock is a no-no.

kfree under a spinlock is perfectly fine.  That is as long as you
don't free the spinlock itself.

