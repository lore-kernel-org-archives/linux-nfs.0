Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:42000 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098AbbCXGvb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Mar 2015 02:51:31 -0400
Date: Tue, 24 Mar 2015 07:51:28 +0100
From: Christoph Hellwig <hch@lst.de>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Printk blocklayout length and offset as format
	0x%llx
Message-ID: <20150324065128.GA3159@lst.de>
References: <550ECEC8.5040406@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <550ECEC8.5040406@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 22, 2015 at 10:16:40PM +0800, Kinglong Mee wrote:
> When testing pnfs with nfsd_debug on, nfsd print a negative number
> of layout length and foff in nfsd4_block_proc_layoutget as, 
> "GET: -xxxx:-xxx 2"

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
