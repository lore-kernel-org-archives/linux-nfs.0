Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:40699 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753843AbbCPMTL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Mar 2015 08:19:11 -0400
Date: Mon, 16 Mar 2015 13:19:08 +0100
From: Christoph Hellwig <hch@lst.de>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Put exports after nfsd4_layout_verify fail
Message-ID: <20150316121908.GA32460@lst.de>
References: <5505A14F.4090202@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5505A14F.4090202@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 15, 2015 at 11:12:15PM +0800, Kinglong Mee wrote:
> Fix commit 9cf514ccfa (nfsd: implement pNFS operations).
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
