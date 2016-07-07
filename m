Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38487 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968AbcGGOOY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jul 2016 10:14:24 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1467831425.2908.16.camel@redhat.com>
References: <1467831425.2908.16.camel@redhat.com> <1467294433-3222-1-git-send-email-agruenba@redhat.com> <1467294433-3222-14-git-send-email-agruenba@redhat.com>
To: Jeff Layton <jlayton@redhat.com>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: dhowells@redhat.com, Christoph Hellwig <hch@infradead.org>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Subject: Re: [PATCH v23 13/22] vfs: Cache richacl in struct inode
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 07 Jul 2016 15:14:13 +0100
Message-ID: <1689.1467900853@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> wrote:

> > +	if (cmpxchg(&inode->i_acl, ACL_NOT_CACHED, sentinel) != ACL_NOT_CACHED)
> > +		/* fall through */ ;
> > +
> 
> So you do the same thing regardless of the outcome of the above? Why
> bother with the if at all here? Just do the cmpxchg and toss out the
> result.

gcc might complain if you don't check the result.

However, this does look like it's subject to a thundering herd problem.  If
30000 processes all look at the ACL at the same time on a network fs, could
that cause 30000 RPC calls to be transmitted for the same thing?

David
