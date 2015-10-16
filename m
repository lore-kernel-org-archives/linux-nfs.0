Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:26254 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751870AbbJPNUc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 09:20:32 -0400
Date: Fri, 16 Oct 2015 09:19:50 -0400
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
Message-ID: <20151016131950.GC6874@ret.masoncoding.com>
References: <1443634014-3026-10-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142939.GA30905@infradead.org>
 <561B8A09.5070507@draigBrady.com>
 <20151012143444.GA10156@infradead.org>
 <20151012234106.GD11398@birch.djwong.org>
 <20151013072959.GB10794@infradead.org>
 <20151014184608.GK850@birch.djwong.org>
 <20151015060045.GA23996@infradead.org>
 <20151016114919.GB6874@ret.masoncoding.com>
 <20151016122544.GC5889@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <20151016122544.GC5889@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 16, 2015 at 05:25:44AM -0700, Christoph Hellwig wrote:
> On Fri, Oct 16, 2015 at 07:49:19AM -0400, Chris Mason wrote:
> > > Yes, that would be my preference.  I'd also like to understand what
> > > exactly btrfs does in fallocate.
> > 
> > For which part?  The answer changes based on how many references there
> > are to a given fallocated region.
> 
> Both cases.  With btrfs allocating new block on every write how do you
> avoid that ENOSPC?  Is there a unassigned block preallocation that's
> made persistent in some way?

So:

fallocate 1g -> foo

reflink foo foo2

We've now implicitly doubled the size of the fallocate, but at reflink
time btrfs doesn't account for the doubling.  It's actually much
better in this case to just use a hole because neither foo or foo2 can
use the preallocated space until the 1g is fully unshared.

When we're doing writes, it'll check the preallocated extents for extra
refs and force COW if any exist.  So writes into a preallocated region
can enospc.

-chris
