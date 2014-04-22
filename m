Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33896 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbaDVGXi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 02:23:38 -0400
Date: Mon, 21 Apr 2014 23:23:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH V2 10/17] xprtrdma: Add CONFIG setting that can disable
 ALLPHYSICAL
Message-ID: <20140422062338.GA23311@infradead.org>
References: <20140421214442.12569.8950.stgit@manet.1015granger.net>
 <20140421220214.12569.23157.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140421220214.12569.23157.stgit@manet.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 21, 2014 at 06:02:14PM -0400, Chuck Lever wrote:
> ALLPHYSICAL is not a safe memory registration mode because it
> permits NFS servers to write anywhere in a client's memory.  NFS
> server bugs could result in client memory being overwritten.
> 
> This can be useful for embedded systems which do not support more
> surgical RDMA memory registration and protection methods, or for
> bring-up of new HCA hardware.
> 
> However, enterprise Linux distributions have expressed a desire to
> disable it in production environments.

It's just as unsafe in embedded devices.  I think it should go
