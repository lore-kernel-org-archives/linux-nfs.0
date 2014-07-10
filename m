Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59006 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbaGJHnZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 03:43:25 -0400
Date: Thu, 10 Jul 2014 00:43:24 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Check acl returned from get_acl/posix_acl_from_mode
Message-ID: <20140710074324.GB32584@infradead.org>
References: <53BD4988.6020302@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53BD4988.6020302@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 09, 2014 at 09:54:16PM +0800, Kinglong Mee wrote:
> Commit 4ac7249ea5 (nfsd: use get_acl and ->set_acl)
> don't check the acl returned from get_acl()/posix_acl_from_mode().
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
