Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50878 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbaGORBi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 13:01:38 -0400
Date: Tue, 15 Jul 2014 10:01:37 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: xdr_get_next_encode_buffer should be declared
 static
Message-ID: <20140715170137.GB1722@infradead.org>
References: <1405202462-50244-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405202462-50244-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 12, 2014 at 06:01:02PM -0400, Trond Myklebust wrote:
> Quell another sparse warning.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
