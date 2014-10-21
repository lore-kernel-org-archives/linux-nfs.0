Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51698 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015AbaJUKgb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Oct 2014 06:36:31 -0400
Date: Tue, 21 Oct 2014 03:36:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfsd4: fix response size estimation for OP_SEQUENCE
Message-ID: <20141021103631.GB21863@infradead.org>
References: <20141017212446.GC3474@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141017212446.GC3474@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 17, 2014 at 05:24:46PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> We added this new estimator function but forgot to hook it up.  The
> effect is that NFSv4.1 won't do zero-copy reads.
> 
> The estimate was also wrong by 8 bytes.

This would affect 4.0 and 4.2 as well, wouldn't it?
