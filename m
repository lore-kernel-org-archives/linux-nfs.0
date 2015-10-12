Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.vodafone.ie ([213.233.128.43]:48662 "EHLO
	mail1.vodafone.ie" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbJLKX0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Oct 2015 06:23:26 -0400
Subject: Re: [PATCH v5 9/9] btrfs: btrfs_copy_file_range() only supports
 reflinks
To: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-10-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142939.GA30905@infradead.org>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com
From: =?UTF-8?Q?P=c3=a1draig_Brady?= <P@draigBrady.com>
Message-ID: <561B8A09.5070507@draigBrady.com>
Date: Mon, 12 Oct 2015 11:23:05 +0100
MIME-Version: 1.0
In-Reply-To: <20151011142939.GA30905@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/10/15 15:29, Christoph Hellwig wrote:
> On Wed, Sep 30, 2015 at 01:26:53PM -0400, Anna Schumaker wrote:
>> Reject copies that don't have the COPY_FR_REFLINK flag set.
> 
> I think a reflink actually is a perfectly valid copy, and I don't buy
> the duplicate arguments in earlier threads.  We really need to think
> more in terms of how this impacts a user and now how it's implemented
> internally.  How does a user notice it's a reflink?  They don't as
> implemented in btrfs and co. 

You're right that if the user doesn't notice, then there is no
point exposing this. However I think the user does notice as
there is a difference in the end state of the copy.  I.E. generally
if there is a different end state it would require an option,
while if only a different copying mechanism it would not.
I think the different end state of a reflink warrants an option for 3 reasons:

 - The user might want separate bits for resiliency. Now this is
   a weak argument due to possible deduplication in lower layers,
   but still valid is some setups.

 - The user might want to avoid CoW at a later time critical stage.

 - The user might want to avoid ENOSPC at a later critical stage.

> Now on filesystem that don't always do
> copy on write but might support reflinks (ocfs2, XFS in the future)
> this becomes a bit more interesting - the difference he is that we
> get an implicit fallocate when doing a real copy.  But if that's
> something we have actual requests for that's how we should specify
> it rather than in terms of arcane implementation details.

thanks,
Pádraig.

