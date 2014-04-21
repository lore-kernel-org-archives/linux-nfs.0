Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50102 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbaDUNcx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 09:32:53 -0400
Date: Mon, 21 Apr 2014 06:32:52 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/17] NFS: Create a common rw_header_alloc and
 rw_header_free function
Message-ID: <20140421133252.GA30954@infradead.org>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1397768981-12856-8-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397768981-12856-8-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 17, 2014 at 05:09:31PM -0400, Anna Schumaker wrote:
> From: Anna Schumaker <Anna.Schumaker@netapp.com>
> 
> I create a new struct nfs_rw_ops to decide the differences between reads
> and writes.  This struct will be set when initializing a new
> nfs_pgio_descriptor, and then passed on to the nfs_rw_header when a new
> header is allocated.

To me it seems like adding this new vector confuses things.  From a look
at your whole tree it seems like all methods added to it could as well
be added to nfs_pageio_ops.  In that case we'd still keep separate
instances of nfs_pageio_ops for reads and writes, but most methods would
be that same.  I'm also defintively curious what you have on your
sleeves for pnfs.
