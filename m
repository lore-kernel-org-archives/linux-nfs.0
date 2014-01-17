Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58177 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbaAQMR2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jan 2014 07:17:28 -0500
Date: Fri, 17 Jan 2014 04:17:23 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Miklos Szeredi <mszeredi@suse.cz>
Subject: Re: [PATCH] dcache: fix d_splice_alias handling of aliases
Message-ID: <20140117121723.GA18375@infradead.org>
References: <20140115151749.GF23999@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140115151749.GF23999@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 15, 2014 at 10:17:49AM -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> d_splice_alias can create duplicate directory aliases (in the !new
> case), or (in the new case) d_move without holding appropriate locks.
> 
> d_materialise_unique deals with both of these problems.  (The latter
> seems to be dealt by trylocks (see __d_unalias), which look like they
> could cause spurious lookup failures--but that's at least better than
> corrupting the dcache.)

I'm a bit worried about those spurious failures, maybe we should
retry in that case?

Also looking over the changes I wonder if the explicit cecking for
aliases for every non-directory might have a major performance impact,
all the dcache growling already was a major issues in NFS workloads
years ago and I dumb it's become any better.

Also looking at this area I'd like to suggest that if you end up
merging the two I'd continue using the d_splice_alias name and
calling conventions.

Also the inode == NULL case really should be split out from
d_materialise_unique into a separate helper.  It shares almost no
code, is entirely undocumented to the point that I don't really
understand what the purpose is, and the only caller that can get
there (fuse) already branches around that case in the caller anyway.

