Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57710 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561AbaGaQvH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jul 2014 12:51:07 -0400
Date: Thu, 31 Jul 2014 12:50:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 02/38] nfsd: Cleanup the freeing of stateids
Message-ID: <20140731165058.GA11218@fieldses.org>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
 <1406684083-19736-3-git-send-email-jlayton@primarydata.com>
 <20140730205758.GA25112@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140730205758.GA25112@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 30, 2014 at 01:57:58PM -0700, Christoph Hellwig wrote:
> On Tue, Jul 29, 2014 at 09:34:07PM -0400, Jeff Layton wrote:
> > Add a ->free() callback to the struct nfs4_stid, so that we can
> > release a reference to the stid without caring about the contents.
> 
> Looks good, but I'd suggest merging it into the previous patch.
> 
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

OK, committing to for-3.17 with those two squashed together.

--b.
