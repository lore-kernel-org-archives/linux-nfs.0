Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50553 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311AbbBEOGF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 09:06:05 -0500
Date: Thu, 5 Feb 2015 06:06:05 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH] fsx: check for filesystem support of
 FALLOCATE_FL_KEEP_SIZE
Message-ID: <20150205140605.GB28544@infradead.org>
References: <1422997783-22484-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1422997783-22484-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 03, 2015 at 04:09:43PM -0500, Anna Schumaker wrote:
> The NFS implementation of fallocate() does not support passing the
> KEEP_SIZE flag by itself, causing tests to randomly fail.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
