From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 00/19] export operations rewrite
Date: Fri, 28 Sep 2007 12:09:56 +1000
Message-ID: <18172.25204.554112.418896@notabene.brown>
References: <20070914114746.GA28282@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
To: hch@lst.de, akpm@linux-foundation.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: message from hch@lst.de on Friday September 14
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Friday September 14, hch@lst.de wrote:
> This patchset is a medium scale rewrite of the export operations
> interface.  The goal is to make the interface less complex, and
> easier to understand from the filesystem side, aswell as preparing
> generic support for exporting of 64bit inode numbers.

These 19 patches
Acked-by: NeilBrown <neilb@suse.de>

I didn't do a very thorough review this time, but I did the previous
time, and the one problem I found (module dependencies) has been
addressed - Thanks.

NeilBrown

> 
> This touches all nfs exporting filesystems, and I've done testing
> on all of the filesystems I have here locally (xfs, ext2, ext3, reiserfs,
> jfs)
> 
> Compared to the last version I've fixed the white space issues that
> checkpatch.pl complained about.
> 
> Note that this patch series is against mainline.  There will be some
> xfs changes landing in -mm soon that revamp lots of the code touched
> here.  They should hopefully include the first path in the series so
> it can be simply dropped, but the xfs conversion will need some smaller
> updates.  I will send this update as soon as the xfs tree updates get
> pulled into -mm.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
