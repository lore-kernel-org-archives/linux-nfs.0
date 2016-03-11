Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:46778 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932219AbcCKOHt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Mar 2016 09:07:49 -0500
Date: Fri, 11 Mar 2016 06:07:46 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "Theodore Ts'o" <tytso@mit.edu>, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
        Christoph Hellwig <hch@infradead.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>,
        jaegeuk@kernel.org, chao2.yu@samsung.com
Subject: Re: [PATCH v18 11/22] vfs: Cache base_acl objects in inodes
Message-ID: <20160311140746.GC14808@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <1456733847-17982-12-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1456733847-17982-12-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 29, 2016 at 09:17:16AM +0100, Andreas Gruenbacher wrote:
> POSIX ACLs and richacls are both objects allocated by kmalloc() with a
> reference count which are freed by kfree_rcu().  An inode can either
> cache an access and a default POSIX ACL, or a richacl (richacls do not
> have default acls).  To allow an inode to cache either of the two kinds
> of acls, introduce a new base_acl type and convert i_acl and
> i_default_acl to that type. In most cases, the vfs then doesn't care which
> kind of acl an inode caches (if any).

This base_acl object is pointless.  I've asked in the past to have
a proper container for the ACLs in common code, but a union
of a refcount and a rcu head doesn't really fit that category.

But this points out that the f2fs folks really need a couple of
slaps on their hands.  Not if generic funtionality doesn't
fit your needs you are not going to blindly copy and paste it,
please talk to find a solution instead of duplicating it.

Folks, please come up with a suggestion to get rid of f2fs_acl_clone,
f2fs_acl_create_masq and f2fs_acl_create ASAP.
