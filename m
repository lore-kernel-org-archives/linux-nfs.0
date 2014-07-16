Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:40418 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbaGPJhk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 05:37:40 -0400
Date: Wed, 16 Jul 2014 02:37:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 5/7] nfsd: Move the delegation reference counter into the
 struct nfs4_stid
Message-ID: <20140716093739.GA19417@infradead.org>
References: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
 <1405420669-4030-6-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405420669-4030-6-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2014 at 06:37:47AM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> We will want to add reference counting to the lock stateid and open
> stateids too in later patches.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
