Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:35710 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbbJDGXc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Oct 2015 02:23:32 -0400
Date: Sat, 3 Oct 2015 23:23:13 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Subject: Re: [PATCH v8 00/41] Richacls
Message-ID: <20151004062313.GA20212@infradead.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 28, 2015 at 12:08:51AM +0200, Andreas Gruenbacher wrote:
> Hello,
> 
> here's another update of the richacl patch queue.  At this stage, I would
> like to ask for final feedback so that the core and ext4 code (patches
> 1-19) can be merged in the 4.4 merge window.  The nfsd and nfs code should
> then go through the respective maintainer trees.

Now way in this form even if everyone agrees we should have these
bastard ACLs.  I certainly disagree.

Ayway, back to the VFS <-> FS interface.  You still require tons of
boilderplate code in the filesystem which isn't required and we got rid
of for Posix ACLs.  The filesystem should not look at the userspace
xattr format, please follow a model similar to ->get_acl and ->set_acl
for Posix ACLs.  After that the wire up should be so trivial that you
can wire up btrfs, xfs and f2fs as well, which is important to make the
feature mergeable.

And honestly I tink adding even more overload to xattrs is a really bad
idea and after 10 years of experience with that junk we really need to
learn and make new overloads proper system calls.

