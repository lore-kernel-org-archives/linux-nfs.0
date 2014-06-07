Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59911 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbaFGOjC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jun 2014 10:39:02 -0400
Date: Sat, 7 Jun 2014 07:39:01 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 5/6] nfs: remove pgio_header refcount, related cleanup
Message-ID: <20140607143901.GE9469@infradead.org>
References: <1401995791-40213-1-git-send-email-dros@primarydata.com>
 <1401995791-40213-6-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1401995791-40213-6-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 05, 2014 at 03:16:30PM -0400, Weston Andros Adamson wrote:
> The refcounting on nfs_pgio_header was related to there being (possibly)
> more than one nfs_pgio_data. Now that nfs_pgio_data has been merged into
> nfs_pgio_header, there is no reason to do this ref counting.  Just call
> the completion callback on nfs_pgio_release/nfs_pgio_error.


I think nfs_generic_pgio_reset isn't an all that descriptive name, why
not keep nfs_pgio_data_destroy?

