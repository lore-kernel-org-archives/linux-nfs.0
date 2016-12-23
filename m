Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38294 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbcLWJZz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Dec 2016 04:25:55 -0500
Date: Fri, 23 Dec 2016 01:25:54 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSD: pass an integer for stable type to
 nfsd_vfs_write
Message-ID: <20161223092554.GA17715@infradead.org>
References: <0df957d0-3405-b12f-0d39-210a0edd6f60@gmail.com>
 <20161223071928.GA19287@infradead.org>
 <ff5a91f2-000b-eaf8-d224-fb113d54f1e1@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ff5a91f2-000b-eaf8-d224-fb113d54f1e1@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 23, 2016 at 05:18:03PM +0800, Kinglong Mee wrote:
> We can check it in check_export() when exporting filesystem,
> but, what can we do for the unsupported fsync filesystem?
> Just a warning message? or deny the exporting? 
> I'd prefer the first one.

Warn and refuse the writable export.
