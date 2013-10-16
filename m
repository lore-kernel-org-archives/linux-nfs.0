Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48973 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753597Ab3JPHLN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 03:11:13 -0400
Date: Wed, 16 Oct 2013 00:11:10 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond@netapp.com>, linux-nfs@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH] nfs: use IS_ROOT not DCACHE_DISCONNECTED
Message-ID: <20131016071110.GA27799@infradead.org>
References: <20131015210316.GA11616@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131015210316.GA11616@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 15, 2013 at 05:03:16PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> This check was added by Al Viro with
> d9e80b7de91db05c1c4d2e5ebbfd70b3b3ba0e0f "nfs d_revalidate() is too
> trigger-happy with d_drop()", with the explanation that we don't want to
> remove the root of a disconnected tree, which will still be included on
> the s_anon list.
> 
> But DCACHE_DISCONNECTED does *not* actually identify dentries that are
> disconnected from the dentry tree or hashed on s_anon.  IS_ROOT() is the
> way to do that.
> 
> Also add a comment from Al's commit to remind us why this check is
> there.

Looks good.

Reviewed-by: Christoph Hellwig <hch@lst.de>
