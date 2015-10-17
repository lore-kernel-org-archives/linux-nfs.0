Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:1650 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751924AbbJQNpU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Oct 2015 09:45:20 -0400
Date: Sat, 17 Oct 2015 09:44:40 -0400
From: Chris Mason <clm@fb.com>
To: Dave Chinner <david@fromorbit.com>
CC: Christoph Hellwig <hch@infradead.org>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        P??draig Brady <P@draigBrady.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>
Subject: Re: [PATCH v5 9/9] btrfs: btrfs_copy_file_range() only supports
 reflinks
Message-ID: <20151017134440.GE6874@ret.masoncoding.com>
References: <561B8A09.5070507@draigBrady.com>
 <20151012143444.GA10156@infradead.org>
 <20151012234106.GD11398@birch.djwong.org>
 <20151013072959.GB10794@infradead.org>
 <20151014184608.GK850@birch.djwong.org>
 <20151015060045.GA23996@infradead.org>
 <20151016114919.GB6874@ret.masoncoding.com>
 <20151016122544.GC5889@infradead.org>
 <20151016131950.GC6874@ret.masoncoding.com>
 <20151016214435.GA2786@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <20151016214435.GA2786@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 17, 2015 at 08:44:35AM +1100, Dave Chinner wrote:
> 
> > When we're doing writes, it'll check the preallocated extents for extra
> > refs and force COW if any exist.  So writes into a preallocated region
> > can enospc.
> 
> This really seems like an btrfs interpretation/implementation
> issue, not a problem for reflink in general.
> 

Right, now matter how we do it there are tradeoffs, and this one seemed
the least surprising to me.  I don't think it's a big problem at all.

Automatically replacing preallocated extents with holes during clone
seems like a better compromise though (at least for btrfs anyway).

-chris
