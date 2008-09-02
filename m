From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] UBIFS: fill f_fsid
Date: Tue, 02 Sep 2008 23:12:41 +0100
Message-ID: <1220393561.2985.19.camel@pmac.infradead.org>
References: <1220194366-12731-1-git-send-email-dedekind@infradead.org>
	 <1220194366-12731-13-git-send-email-dedekind@infradead.org>
	 <1220262187.2982.58.camel@pmac.infradead.org>
	 <20080901150147.GA20323@infradead.org> <1220339032.4036.31.camel@sauron>
	 <20080902170954.GE3086@webber.adilger.int>
	 <20080902210219.GA9856@infradead.org>
	 <1220390769.2985.6.camel@pmac.infradead.org>
	 <20080902214841.GA9204@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>,
	Artem Bityutskiy <dedekind@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Adrian Hunter <ext-adrian.hunter@nokia.com>,
	linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59857 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbYIBWMs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2008 18:12:48 -0400
In-Reply-To: <20080902214841.GA9204@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-09-02 at 17:48 -0400, Christoph Hellwig wrote:
> On Tue, Sep 02, 2008 at 10:26:09PM +0100, David Woodhouse wrote:
> > > We also called the filesystem part of the NFS filehandle in a few
> > > places, and for those it's correct that it should be stable.  Currently
> > > the fsid is either created from the dev_t in kernelspace or from
> > > uuids extracted through libuuid in userspace.
> > 
> > Or from the f_fsid returned in statfs(), as of a week or so ago.
> 
> I think that's a rather bad idea.  As mentioned before f_fsid is
> basically random.

It's not that bad. Of the file systems which actually fill it in...

For NTFS it's the volume serial number.

For ext[234] it's the UUID xor-folded into 64 bits.
For btrfs the same, but with the root object ID xor'd in too.

For bfs and xfs it's the block device -- which isn't ideal, as Andreas
points out, but is what we'd fall back to anyway.

BFS seems to have a s_volume field which perhaps we could use, but we
should check for it being all spaces and leave f_fsid as zero in that
case. Presumably XFS could be using sb_uuid?

For efs, it'll be either EFS_MAGIC or EFS_NEWMAGIC, which is probably a
bad thing if you want to export multiple EFS file systems. I'll send a
patch to fix that (by leaving it zero) shortly.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



