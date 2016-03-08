Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38433 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbcCHRCm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Mar 2016 12:02:42 -0500
Date: Tue, 8 Mar 2016 09:02:42 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Subject: Re: linux-next: Tree for Mar 8 (nfsd)
Message-ID: <20160308170242.GA25057@infradead.org>
References: <20160308165122.68ececf7@canb.auug.org.au>
 <56DF0401.6010901@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56DF0401.6010901@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 08, 2016 at 08:55:29AM -0800, Randy Dunlap wrote:
> On 03/07/16 21:51, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Changes since 20160307:
> > 
> 
> on x86_64:
> when CONFIG_BLOCK is not enabled:
> 
> ../fs/nfsd/nfs4layouts.c: In function 'nfsd4_setup_layout_type':
> ../fs/nfsd/nfs4layouts.c:145:39: error: dereferencing pointer to incomplete type
>       sb->s_bdev && sb->s_bdev->bd_disk->fops->pr_ops)
>                                        ^

My fault, this will need a CONFIG_BLOCK ifdef.  I'll send a fix.
