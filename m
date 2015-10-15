Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45268 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932079AbbJOGAs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Oct 2015 02:00:48 -0400
Date: Wed, 14 Oct 2015 23:00:45 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, P??draig Brady <P@draigBrady.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, mtk.manpages@gmail.com, andros@netapp.com
Subject: Re: [PATCH v5 9/9] btrfs: btrfs_copy_file_range() only supports
 reflinks
Message-ID: <20151015060045.GA23996@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-10-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142939.GA30905@infradead.org>
 <561B8A09.5070507@draigBrady.com>
 <20151012143444.GA10156@infradead.org>
 <20151012234106.GD11398@birch.djwong.org>
 <20151013072959.GB10794@infradead.org>
 <20151014184608.GK850@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151014184608.GK850@birch.djwong.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 14, 2015 at 11:46:08AM -0700, Darrick J. Wong wrote:
> The documentation for fallocate ought to be updated to include that as part of
> guaranteeing that subsequent writes to the range won't fail due to ENOSPC,
> shared blocks will be unshared.
> 
> Incidentally, btrfs leaves shared blocks alone.  OTOH, given that it's totally
> COW it probably doesn't make sense to unshare blocks anyway... but maybe I
> also don't want to dive into btrfs f-allocation behavior at this time. :)
> 
> Ok, so I'll rework the XFS funshare code into something that hangs off the
> regular fallocate call, and get rid of the explicit 'funshare' bits.

Yes, that would be my preference.  I'd also like to understand what
exactly btrfs does in fallocate.
