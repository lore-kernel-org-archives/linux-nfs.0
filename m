Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44568 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbaDQOgh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Apr 2014 10:36:37 -0400
Date: Thu, 17 Apr 2014 07:36:34 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] NFSD: Clear cached acl after setting a zero-length
 default posix acl:
Message-ID: <20140417143634.GA20857@infradead.org>
References: <534FCD13.303@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <534FCD13.303@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 17, 2014 at 08:46:11PM +0800, Kinglong Mee wrote:
> After setting ACL for directory, I got two problems that caused
> by the cached zero-length default posix acl.
> 
> This patch just clears the cached zero-length default posix acl
> after setting.
> 
> First problem:
> # nfs4_setfacl -s A::OWNER@:RWX /mnt/123/; touch /mnt/123/test
> ............ hang ...........

Nfsd must not call forget_cached_acl, that's the filesystems job.
I think the right fix is to make sure nfsd4_set_nfs4_acl calls ->set_acl
with a NULL ACL structure if there are no entries.

Btw, it would be really good if we kept tests like this as a regression
test suite.  Is there one for NFS already?  If not we could add
nfs-specific tests to xfstests as well.

