Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50243 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbaDROCU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 10:02:20 -0400
Date: Fri, 18 Apr 2014 07:02:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 05/17] NFS: Move the write verifier into the
 nfs_pgio_header
Message-ID: <20140418140220.GE20096@infradead.org>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1397768981-12856-6-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397768981-12856-6-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 17, 2014 at 05:09:29PM -0400, Anna Schumaker wrote:
> From: Anna Schumaker <Anna.Schumaker@netapp.com>
> 
> The header had a pointer to the verifier that was set from the old write
> data struct.  We don't need to keep the pointer around now that we have
> shared structures.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

