Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41160 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997AbbCTUQG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2015 16:16:06 -0400
Date: Fri, 20 Mar 2015 16:16:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Put exports after nfsd4_layout_verify fail
Message-ID: <20150320201606.GA5955@fieldses.org>
References: <5505A14F.4090202@gmail.com>
 <20150316121908.GA32460@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150316121908.GA32460@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 16, 2015 at 01:19:08PM +0100, Christoph Hellwig wrote:
> On Sun, Mar 15, 2015 at 11:12:15PM +0800, Kinglong Mee wrote:
> > Fix commit 9cf514ccfa (nfsd: implement pNFS operations).
> > 
> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> 
> Looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks, applying for 4.0.

--b.
