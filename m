Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53079 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281Ab3IFRDk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Sep 2013 13:03:40 -0400
Date: Fri, 6 Sep 2013 10:03:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Nick Piggin <npiggin@kernel.dk>
Subject: Re: [PATCH 2/3] dcache: Don't set DISCONNECTED on "pseudo
 filesystem" dentries
Message-ID: <20130906170339.GB6460@infradead.org>
References: <1378482230-16312-1-git-send-email-bfields@redhat.com>
 <1378482230-16312-2-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1378482230-16312-2-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 06, 2013 at 11:43:49AM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> I can't for the life of me see any reason why anyone would care whether
> a dentry that is never hooked into the dentry cache would need
> DCACHE_DISCONNECTED set.

__d_shrink did before your PATCH 1/3.

With that fixed your patch looks fine.

> +/*
> + * For filesystems that do not actually use the dentry cache at all, and
> + * only ever deal in IS_ROOT() dentries:
> + */

If you document the function it really should be a kerneldoc comment.

Also the description, while technically correct, isn't all that useful.

It need an explanation why the filesystem is fine with unhashed
dentries, and the reason is that it never performs any lookups as it
pins the dentries in memory.

