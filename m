Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44801 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347AbbCZBPU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Mar 2015 21:15:20 -0400
Date: Wed, 25 Mar 2015 21:15:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Fix bad update of layout in
 nfsd4_return_file_layout
Message-ID: <20150326011519.GC20086@fieldses.org>
References: <550ECEF0.6030505@gmail.com>
 <20150325083445.GA3044@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150325083445.GA3044@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 25, 2015 at 09:34:45AM +0100, Christoph Hellwig wrote:
> Looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> Guess we need some good testcase for these artifical partial segment
> returns that don't happen with the real client..

pynfs might do it?  But I'm not volunteering.

Anyway, applying these three for 4.0. (NFSD: Printk blocklayout length
a.., NFSD: Take care the return value.., NFSD: Fix bad update of layout
in...).

--b.
