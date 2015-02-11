Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:44071 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752002AbbBKNVW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Feb 2015 08:21:22 -0500
Date: Wed, 11 Feb 2015 14:21:19 +0100
From: Christoph Hellwig <hch@lst.de>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch] nfsd: fix comparison in fh_fsid_match()
Message-ID: <20150211132119.GA10377@lst.de>
References: <20150211130832.GA25573@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150211130832.GA25573@mwanda>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 04:08:32PM +0300, Dan Carpenter wrote:
> We're supposed to be testing that the fh_fsid's match but because the
> parenthesis are in the wrong place, then we only check the first
> byte.
> 
> Fixes: 9558f2500a20 ('nfsd: add fh_fsid_match helper')

Thanks, this looks good.  Is there an easy to setup way to check for
these sorts of errors?
