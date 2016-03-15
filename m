Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [198.137.202.9] ([198.137.202.9]:49766 "EHLO
	bombadil.infradead.org" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755058AbcCOHLx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2016 03:11:53 -0400
Date: Tue, 15 Mar 2016 00:11:03 -0700
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
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH v18 00/22] Richacls (Core and Ext4)
Message-ID: <20160315071103.GC19747@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <20160311140134.GA14808@infradead.org>
 <CAHc6FU4t3yisCM=MXrHRmCja_A8eZOpVa1smJ0gUhv+vuUAuXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU4t3yisCM=MXrHRmCja_A8eZOpVa1smJ0gUhv+vuUAuXA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 11, 2016 at 05:11:51PM +0100, Andreas Gruenbacher wrote:
> > while breaking a lot of assumptions,
> 
> The model is designed specifically to be compliant with the POSIX
> permission model. What assumptions are you talking about?

People have long learned that we only have 'alloc' permissions.  Any
model that mixes allow and deny ACE is a mistake.

> > especially by adding allow and deny ACE at the same time.
> 
> I remember from past discussions that a permission model like the
> POSIX ACL model that doesn't have DENY ACEs would be more to your
> liking. This argument is dead from the start though: NFSv4 ACLs
> without DENY ACEs cannot represent basic file permissions like 0604
> where the owning group has fewer permissions than others, for example
> (see the richaclex(7) man page). We would end up with a permission
> model that isn't even compatible with the traditional POSIX file
> permission model, one which nobody else implements or cares about.

So let's stick to the model that we already have.

