Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:24215 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752525AbbBOX0E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Feb 2015 18:26:04 -0500
Date: Mon, 16 Feb 2015 10:25:14 +1100
From: Dave Chinner <david@fromorbit.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Christoph Hellwig <hch@lst.de>, Jeff Layton <jlayton@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        xfs@oss.sgi.com
Subject: Re: [PATCH 19/20] xfs: implement pNFS export operations
Message-ID: <20150215232514.GZ4251@dastard>
References: <20150205135756.GA6386@lst.de>
 <20150206222047.GM12722@dastard>
 <20150206224258.GJ29783@fieldses.org>
 <20150208133435.GA27081@lst.de>
 <20150208090942.51e99687@tlielax.poochiereds.net>
 <20150209201154.GA27746@fieldses.org>
 <20150210000423.GY12722@dastard>
 <20150213011130.GA6808@fieldses.org>
 <20150213015422.GE12722@dastard>
 <20150213133811.5c3b9f49@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150213133811.5c3b9f49@canb.auug.org.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 13, 2015 at 01:38:11PM +1100, Stephen Rothwell wrote:
> Hi Dave,
> 
> On Fri, 13 Feb 2015 12:54:22 +1100 Dave Chinner <david@fromorbit.com> wrote:
> >
> > Thanks Bruce. I might have to build a merged tree because one of the
> > changes from the review modified a header file introduced in the NFS
> > tree.
> > 
> > I'll see how it goes, and see if I can avoid doing something that
> > will make Linus yell at me :P
> 
> If its a syntactic conflict with an obvious resolution, just leave it
> (or maybe mention it in the pull request).  It gives him something to
> do so he feels useful. :-)

Heh.

It's not actually a conflict, though. The issue is that some of the
review comments on the XFS side resulted in changes files introduced
from the NFS tree. So the XFS side can't be merged without the NFS
changes being present....

> /me notes that I did not see a conflict while merging the xfs tree in
> linux-next today ...

Because I haven't pushed them yet ;)

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com
