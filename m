Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60855 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbaG3U57 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 16:57:59 -0400
Date: Wed, 30 Jul 2014 13:57:58 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 02/38] nfsd: Cleanup the freeing of stateids
Message-ID: <20140730205758.GA25112@infradead.org>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
 <1406684083-19736-3-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406684083-19736-3-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 29, 2014 at 09:34:07PM -0400, Jeff Layton wrote:
> Add a ->free() callback to the struct nfs4_stid, so that we can
> release a reference to the stid without caring about the contents.

Looks good, but I'd suggest merging it into the previous patch.


Signed-off-by: Christoph Hellwig <hch@lst.de>
