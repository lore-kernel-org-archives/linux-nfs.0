Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36268 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760AbaF1LBw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Jun 2014 07:01:52 -0400
Date: Sat, 28 Jun 2014 04:01:51 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 007/117] nfsd: properly handle embedded newlines in
 fault_injection input
Message-ID: <20140628110151.GA10848@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
 <1403810017-16062-8-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403810017-16062-8-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 26, 2014 at 03:11:47PM -0400, Jeff Layton wrote:
> Currently rpc_pton() fails to handle the case where you echo an address
> into the file, as it barfs on the newline. Ensure that we NULL out the
> first occurrence of any newline.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
