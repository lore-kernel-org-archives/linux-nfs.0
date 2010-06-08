From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/8] pnfs-submit: clean locking infrastructure
Date: Tue, 8 Jun 2010 03:30:53 -0400
Message-ID: <20100608073053.GA12121@infradead.org>
References: <1275945113-3436-1-git-send-email-batsakis@netapp.com>
 <1275945113-3436-2-git-send-email-batsakis@netapp.com>
 <1275945113-3436-3-git-send-email-batsakis@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, bhalevy@panasas.com,
	Fred Isaman <iisaman@netapp.com>
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33273 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743Ab0FHHa4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 03:30:56 -0400
In-Reply-To: <1275945113-3436-3-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 07, 2010 at 02:11:47PM -0700, Alexandros Batsakis wrote:
> +static inline void lock_current_layout(struct nfs_inode *nfsi)
> +{
> +	spin_lock(&nfsi->lo_lock);
> +}
> +
> +static inline void unlock_current_layout(struct nfs_inode *nfsi)
> +{
> +	BUG_ON_UNLOCKED_LO((&nfsi->layout));
> +	spin_unlock(&nfsi->lo_lock);
> +}

Adding wrappers for these is nothing but obsfucation.  No need
for the BUG_ON above, the spinlock code asserts that already if
building with spinlock debugging.

