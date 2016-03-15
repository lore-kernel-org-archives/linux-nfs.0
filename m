Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [198.137.202.9] ([198.137.202.9]:50396 "EHLO
	bombadil.infradead.org" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755723AbcCOHNs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2016 03:13:48 -0400
Date: Tue, 15 Mar 2016 00:12:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Theodore Ts'o" <tytso@mit.edu>, linux-cifs@vger.kernel.org,
        Linux API <linux-api@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        LKML <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>, jaegeuk@kernel.org,
        chao2.yu@samsung.com
Subject: Re: [PATCH v18 11/22] vfs: Cache base_acl objects in inodes
Message-ID: <20160315071256.GD19747@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <1456733847-17982-12-git-send-email-agruenba@redhat.com>
 <20160311140746.GC14808@infradead.org>
 <CAHc6FU7hSDBa51mJZZZ=q3agzWXk=DZicnyuPriKHnC2Nxr8rw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU7hSDBa51mJZZZ=q3agzWXk=DZicnyuPriKHnC2Nxr8rw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 11, 2016 at 05:24:45PM +0100, Andreas Gruenbacher wrote:
> POSIX ACLs and RichACLs are different objects, with different members
> and different algorithms operating on them. The only commonality is
> that they are both kmalloc()ed, reference counted objects, and when an
> inode is destroyed, both kinds of ACLs can be put in the same way,
> avoiding an unnecessary if. What kind of common-code container beyond
> that are you still dreaming about?

We still have a main object that is simply a list of ACEs.  But if that
doesn't work out (I suspect it should) I don't think the common base
object is a good idea.  It just leads to a lot of crazy container_of
calls.  If the common object abstraction doesn't work out we'll need
a procedural one instead that has common acl_* calls that decide what
do to based on the file system acl flag.
