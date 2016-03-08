Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:32801 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933116AbcCHQze (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Mar 2016 11:55:34 -0500
Subject: Re: linux-next: Tree for Mar 8 (nfsd)
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
References: <20160308165122.68ececf7@canb.auug.org.au>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <56DF0401.6010901@infradead.org>
Date: Tue, 8 Mar 2016 08:55:29 -0800
MIME-Version: 1.0
In-Reply-To: <20160308165122.68ececf7@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/07/16 21:51, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20160307:
> 

on x86_64:
when CONFIG_BLOCK is not enabled:

../fs/nfsd/nfs4layouts.c: In function 'nfsd4_setup_layout_type':
../fs/nfsd/nfs4layouts.c:145:39: error: dereferencing pointer to incomplete type
      sb->s_bdev && sb->s_bdev->bd_disk->fops->pr_ops)
                                       ^


-- 
~Randy
