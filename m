Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42638 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276AbaAQVEK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jan 2014 16:04:10 -0500
Date: Fri, 17 Jan 2014 16:03:43 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Miklos Szeredi <mszeredi@suse.cz>
Subject: Re: [PATCH] dcache: fix d_splice_alias handling of aliases
Message-ID: <20140117210343.GD26636@fieldses.org>
References: <20140115151749.GF23999@fieldses.org>
 <20140117121723.GA18375@infradead.org>
 <20140117153917.GA26636@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140117153917.GA26636@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 17, 2014 at 10:39:17AM -0500, J. Bruce Fields wrote:
> On Fri, Jan 17, 2014 at 04:17:23AM -0800, Christoph Hellwig wrote:
> > Also the inode == NULL case really should be split out from
> > d_materialise_unique into a separate helper.  It shares almost no
> > code, is entirely undocumented to the point that I don't really
> > understand what the purpose is, and the only caller that can get
> > there (fuse) already branches around that case in the caller anyway.
> 
> I think I see what you mean, I can fix that.

Actually:

	- two callers (fuse and nfs) take advantage of the NULL case.

	- d_splice_alias handles inode == NULL in the same way, and
	  almost every caller takes advantage of that.

So at least we wouldn't want to actually make the caller handle this
case.

But maybe there's still some opportunity for cleanup or documentation.

--b.
