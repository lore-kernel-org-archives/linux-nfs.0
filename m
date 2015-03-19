Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:54518 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751191AbbCSOjf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2015 10:39:35 -0400
Date: Thu, 19 Mar 2015 15:39:32 +0100
From: Christoph Hellwig <hch@lst.de>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] NFSD: Check layout type when returning client layouts
Message-ID: <20150319143932.GA25575@lst.de>
References: <550AAD2E.6040607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <550AAD2E.6040607@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 19, 2015 at 07:04:14PM +0800, Kinglong Mee wrote:
> According to RFC5661:
> " When lr_returntype is LAYOUTRETURN4_FSID, the current filehandle is used
>    to identify the file system and all layouts matching the client ID,
>    the fsid of the file system, lora_layout_type, and lora_iomode are
>    returned.  When lr_returntype is LAYOUTRETURN4_ALL, all layouts
>    matching the client ID, lora_layout_type, and lora_iomode are
>    returned and the current filehandle is not used. "
> 
> When returning client layouts, always check layout type.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
