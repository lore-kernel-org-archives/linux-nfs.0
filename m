Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56951 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751784AbaAQV1W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jan 2014 16:27:22 -0500
Date: Fri, 17 Jan 2014 16:26:55 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Miklos Szeredi <mszeredi@suse.cz>
Subject: Re: [PATCH] dcache: fix d_splice_alias handling of aliases
Message-ID: <20140117212655.GE26636@fieldses.org>
References: <20140115151749.GF23999@fieldses.org>
 <20140117121723.GA18375@infradead.org>
 <20140117153917.GA26636@fieldses.org>
 <20140117210343.GD26636@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140117210343.GD26636@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 17, 2014 at 04:03:43PM -0500, J. Bruce Fields wrote:
> 	- d_splice_alias handles inode == NULL in the same way,

Actually, not exactly; simplifying a bit, in the NULL case they do:

	d_splice_alias:

		__d_instantiate(dentry, NULL);
		security_d_instantiate(dentry, NULL);
		if (d_unhashed(dentry))
			d_rehash(dentry);

	d_materialise_unique:

		BUG_ON(!d_unhashed(dentry));

		 __d_instantiate(dentry, NULL);
		 d_rehash(dentry);
		 security_d_instantiate(dentry, NULL);

and a comment on d_splice_alias says

	Cluster filesystems may call this function with a negative,
	hashed dentry.  In that case, we know that the inode will be a
	regular file, and also this will only occur during atomic_open.

I don't understand those callers.  But I guess it would be easy enough
to handle in d_materialise_unique.

--b.
