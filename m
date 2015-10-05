Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:62732 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751919AbbJEVRP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 17:17:15 -0400
Date: Tue, 6 Oct 2015 08:17:11 +1100
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
Message-ID: <20151005211711.GB23350@dastard>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
 <20151004062313.GA20212@infradead.org>
 <CAHc6FU53mXg1k0KCNkWEjxyuC8iAUgWh-A76qX=C3Yth+qEyuQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU53mXg1k0KCNkWEjxyuC8iAUgWh-A76qX=C3Yth+qEyuQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 05, 2015 at 08:45:40PM +0200, Andreas Gruenbacher wrote:
> On Sun, Oct 4, 2015 at 8:23 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > On Mon, Sep 28, 2015 at 12:08:51AM +0200, Andreas Gruenbacher wrote:
> >> Hello,
> >>
> >> here's another update of the richacl patch queue.  At this stage, I would
> >> like to ask for final feedback so that the core and ext4 code (patches
> >> 1-19) can be merged in the 4.4 merge window.  The nfsd and nfs code should
> >> then go through the respective maintainer trees.
> >
> > Now way in this form even if everyone agrees we should have these
> > bastard ACLs.  I certainly disagree.
> 
> Well, thanks for having a look at the patches.
> 
> > Ayway, back to the VFS <-> FS interface.  You still require tons of
> > boilderplate code in the filesystem which isn't required and we got rid
> > of for Posix ACLs.  The filesystem should not look at the userspace
> > xattr format, please follow a model similar to ->get_acl and ->set_acl
> > for Posix ACLs.
> 
> I will repost a version that has this cleaned up.
> 
> > After that the wire up should be so trivial that you can wire up btrfs,
> > xfs and f2fs as well, which is important to make the feature mergeable.
> 
> Why would the patch queue become more mergeable by having support for
> more filesystems in it? The filesystem specific code really isn't all
> that interesting.

The hardest part for the filesystem support is the on-disk feature
flag that needs to be set. The kernel part of that is easy, but it's
an on-disk format change and so there's also all the userspace side
for mkfs, fsck, debug tools, etc, that also need to be able to parse
and understand it. So while the xattr code can be made much more
generic, there's a bunch of filesystem specific code that needs to
go into multiple different repositories and userspace packages for
this.

Andreas, I also can't remember if any xfstests have been written for
these ACLs? That would certainly help make sure all these
filesystems have equivalent behaviour...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
