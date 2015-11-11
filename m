Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38670 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbbKKH5S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2015 02:57:18 -0500
Date: Tue, 10 Nov 2015 23:57:07 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH v15 00/22] Richacls (Core and Ext4)
Message-ID: <20151111075707.GA23752@infradead.org>
References: <1447067343-31479-1-git-send-email-agruenba@redhat.com>
 <20151110112943.GA17038@infradead.org>
 <CAHc6FU5g7=wd1Wt4+GCaLJjNu7giruZyAON3VcYn-A=ffYMsmw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU5g7=wd1Wt4+GCaLJjNu7giruZyAON3VcYn-A=ffYMsmw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 10, 2015 at 01:39:52PM +0100, Andreas Gruenbacher wrote:
> > It still has the same crappy fs interfaces with lots of boilerplate
> > code
> 
> Could you please be more specific so that I can trace this complaint
> to some actual code?

if (IS_RICHACL())
	richacl_foo()
else
	posix_acl_foo()

for every call from the filesystem is the major one that came to mind.

> > and still abuses xattrs instead of a proper syscall interface.
> > That's far from being ready to merge.
> 
> The xattr syscall interface is what's used for very similar kinds of
> things today; using it for richacls as well sure does not count as
> abuse. Things could be improved in the xattr interface and in its
> implementation, but we need more substantial reasons than that for
> reimplementing the wheel once again.

And it's a horrible interface.  Look at all the pain for example in
XFS which has a different ACL format, or in fact everyone who just
uses a different xattr name or even none at all.  And all the mess
of people trying to shoe horn crazy interfaces into xattrs.

It was an experiment worth trying with Posix ACLs, but it failed, so
do not repeat it.
