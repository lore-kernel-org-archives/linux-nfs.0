Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:54541 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675AbbCSOkU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2015 10:40:20 -0400
Date: Thu, 19 Mar 2015 15:40:18 +0100
From: Christoph Hellwig <hch@lst.de>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] NFSD: Take care the return value from
	nfsd4_decode_stateid
Message-ID: <20150319144018.GB25575@lst.de>
References: <550AAD49.2040906@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <550AAD49.2040906@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 19, 2015 at 07:04:41PM +0800, Kinglong Mee wrote:
> Return status after nfsd4_decode_stateid failed.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Looks good, I must have missed that during a rebase.

Reviewed-by: Christoph Hellwig <hch@lst.de>
