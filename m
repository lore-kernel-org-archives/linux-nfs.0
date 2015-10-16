Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:61390 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753117AbbJPLt5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 07:49:57 -0400
Date: Fri, 16 Oct 2015 07:49:19 -0400
From: Chris Mason <clm@fb.com>
To: Christoph Hellwig <hch@infradead.org>
CC: "Darrick J. Wong" <darrick.wong@oracle.com>,
        P??draig Brady <P@draigBrady.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>
Subject: Re: [PATCH v5 9/9] btrfs: btrfs_copy_file_range() only supports
 reflinks
Message-ID: <20151016114919.GB6874@ret.masoncoding.com>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-10-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142939.GA30905@infradead.org>
 <561B8A09.5070507@draigBrady.com>
 <20151012143444.GA10156@infradead.org>
 <20151012234106.GD11398@birch.djwong.org>
 <20151013072959.GB10794@infradead.org>
 <20151014184608.GK850@birch.djwong.org>
 <20151015060045.GA23996@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <20151015060045.GA23996@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 14, 2015 at 11:00:45PM -0700, Christoph Hellwig wrote:
> On Wed, Oct 14, 2015 at 11:46:08AM -0700, Darrick J. Wong wrote:
> > The documentation for fallocate ought to be updated to include that as part of
> > guaranteeing that subsequent writes to the range won't fail due to ENOSPC,
> > shared blocks will be unshared.
> > 
> > Incidentally, btrfs leaves shared blocks alone.  OTOH, given that it's totally
> > COW it probably doesn't make sense to unshare blocks anyway... but maybe I
> > also don't want to dive into btrfs f-allocation behavior at this time. :)
> > 
> > Ok, so I'll rework the XFS funshare code into something that hangs off the
> > regular fallocate call, and get rid of the explicit 'funshare' bits.
> 
> Yes, that would be my preference.  I'd also like to understand what
> exactly btrfs does in fallocate.

For which part?  The answer changes based on how many references there
are to a given fallocated region.

-chris
