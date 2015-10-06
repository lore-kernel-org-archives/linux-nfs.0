Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:43452 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751214AbbJFBUZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 21:20:25 -0400
Date: Tue, 6 Oct 2015 12:20:20 +1100
From: Dave Chinner <david@fromorbit.com>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>,
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
Message-ID: <20151006012020.GD23350@dastard>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
 <20151004062313.GA20212@infradead.org>
 <CAHc6FU53mXg1k0KCNkWEjxyuC8iAUgWh-A76qX=C3Yth+qEyuQ@mail.gmail.com>
 <20151005211711.GB23350@dastard>
 <CAHc6FU5=nPVRRO+0MycYMMmp66hg7YvY4kMGy-D4JfgD3_FkLQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU5=nPVRRO+0MycYMMmp66hg7YvY4kMGy-D4JfgD3_FkLQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 06, 2015 at 12:01:19AM +0200, Andreas Gruenbacher wrote:
> On Mon, Oct 5, 2015 at 11:17 PM, Dave Chinner <david@fromorbit.com> wrote:
> > On Mon, Oct 05, 2015 at 08:45:40PM +0200, Andreas Gruenbacher wrote:
> >> On Sun, Oct 4, 2015 at 8:23 AM, Christoph Hellwig <hch@infradead.org> wrote:
> >> > After that the wire up should be so trivial that you can wire up btrfs,
> >> > xfs and f2fs as well, which is important to make the feature mergeable.
> >>
> >> Why would the patch queue become more mergeable by having support for
> >> more filesystems in it? The filesystem specific code really isn't all
> >> that interesting.
> >
> > The hardest part for the filesystem support is the on-disk feature
> > flag that needs to be set. The kernel part of that is easy, but it's
> > an on-disk format change and so there's also all the userspace side
> > for mkfs, fsck, debug tools, etc, that also need to be able to parse
> > and understand it. So while the xattr code can be made much more
> > generic, there's a bunch of filesystem specific code that needs to
> > go into multiple different repositories and userspace packages for
> > this.
> 
> Yes.
> 
> > Andreas, I also can't remember if any xfstests have been written for
> > these ACLs? That would certainly help make sure all these
> > filesystems have equivalent behaviour...
> 
> There's a reasonable amount of tests in the richacl user-space package
> which are shell based, with a few small C helpers. We could move those
> into xfstests eventually; now seems a bit early to me.

Well, all the fs developers that will do the userspace work are
already running xfstests. If you want us to be able to test the
richACL code as we add all the fs specific flags to the userspace
code, then we need the tests in xfstests at the same time the
infrastructure appears in the kernel...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
