Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50140 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551AbaDROBY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 10:01:24 -0400
Date: Fri, 18 Apr 2014 07:01:23 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 04/17] NFS: Create a common read and write header struct
Message-ID: <20140418140123.GD20096@infradead.org>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1397768981-12856-5-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397768981-12856-5-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 17, 2014 at 05:09:28PM -0400, Anna Schumaker wrote:
> From: Anna Schumaker <Anna.Schumaker@netapp.com>
> 
> The only difference is the write verifier field, so I leave a comment
> saying that it's not used for reads.

Looks good.

Reviewed-by: Christoph Hellwig <hch@lst.de>
