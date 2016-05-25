Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:46975 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753416AbcEYPH0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2016 11:07:26 -0400
Date: Wed, 25 May 2016 17:07:24 +0200
From: Christoph Hellwig <hch@lst.de>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/4] nfsd: Can leak pnfs_block_extent on error
Message-ID: <20160525150724.GA27535@lst.de>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com> <1464152979-103988-3-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1464152979-103988-3-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 24, 2016 at 10:09:37PM -0700, Tom Haynes wrote:
> Signed-off-by: Tom Haynes <loghyr@primarydata.com>

How was this reported?

Like other NFS procedures the private data should be freed by the
XDR encode callback (nfsd4_encode_layoutget in this case) even
in the error case.  It could be that there is a bug somewhere,
but it probably shouldn't be fixed here.
