Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:57503 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbbFQLfT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2015 07:35:19 -0400
Date: Wed, 17 Jun 2015 04:35:17 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: trond.myklebust@primarydata.com, William.Adamson@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: deny backchannel RPCs with an incorrect authflavor
 instead of dropping them
Message-ID: <20150617113517.GB28508@infradead.org>
References: <1433457613-23300-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1433457613-23300-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 04, 2015 at 06:40:13PM -0400, Jeff Layton wrote:
> A drop should really only be done when the frame is malformed or we have
> reason to think that there is some sort of DoS going on. When we get an
> RPC with bad auth, we should send back an error instead.
> 
> Cc: Andy Adamson <William.Adamson@netapp.com>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
