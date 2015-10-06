Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:60881 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbbJFJt7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 05:49:59 -0400
Date: Tue, 6 Oct 2015 02:49:35 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Subject: Re: [PATCH v8 00/41] Richacls
Message-ID: <20151006094935.GA14144@infradead.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
 <20151004062313.GA20212@infradead.org>
 <CAHc6FU53mXg1k0KCNkWEjxyuC8iAUgWh-A76qX=C3Yth+qEyuQ@mail.gmail.com>
 <5612C85C.2060407@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5612C85C.2060407@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 05, 2015 at 02:58:36PM -0400, Austin S Hemmelgarn wrote:
> I think the point is that a new VFS feature that is easy to integrate in
> multiple filesystems should have support for those filesystems.  A decade
> ago, just having ext* support would probably have been fine, but these days,
> XFS, BTRFS, and F2FS are used just as much (if not more) on production
> systems as ext4, and having support for them right from the start would
> significantly help with adoption of richacls.

That's one reason.  The other is that actually wiring it up for more
than a single consumer shows its actually reasonable generic.  I don't
want to end up with a situration like Posix ACLs again where different
file systems using different on disk formats again.
