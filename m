Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33258 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbbJKO3k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Oct 2015 10:29:40 -0400
Date: Sun, 11 Oct 2015 07:29:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com
Subject: Re: [PATCH v5 9/9] btrfs: btrfs_copy_file_range() only supports
 reflinks
Message-ID: <20151011142939.GA30905@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-10-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1443634014-3026-10-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 30, 2015 at 01:26:53PM -0400, Anna Schumaker wrote:
> Reject copies that don't have the COPY_FR_REFLINK flag set.

I think a reflink actually is a perfectly valid copy, and I don't buy
the duplicate arguments in earlier threads.  We really need to think
more in terms of how this impacts a user and now how it's implemented
internally.  How does a user notice it's a reflink?  They don't as
implemented in btrfs and co.  Now on filesystem that don't always do
copy on write but might support reflinks (ocfs2, XFS in the future)
this becomes a bit more interesting - the difference he is that we
get an implicit fallocate when doing a real copy.  But if that's
something we have actual requests for that's how we should specify
it rather than in terms of arcane implementation details.
