Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:56544 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750754AbcEZFiC convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 May 2016 01:38:02 -0400
From: Thomas Haynes <loghyr@primarydata.com>
To: hch <hch@lst.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] nfsd: Add a super simple flex file server
Date: Thu, 26 May 2016 05:37:54 +0000
Message-ID: <09EECD5D-FB03-4424-8841-0EB67D7C5090@primarydata.com>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
 <1464152979-103988-4-git-send-email-loghyr@primarydata.com>
 <20160525151504.GD27535@lst.de>
In-Reply-To: <20160525151504.GD27535@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 25, 2016, at 8:15 AM, Christoph Hellwig <hch@lst.de> wrote:
> 
> 
>> +	 * effectively be WRITE only.
>> +	 */
>> +	fl->flags = FF_FLAGS_NO_LAYOUTCOMMIT | FF_FLAGS_NO_IO_THRU_MDS |
>> +		    FF_FLAGS_NO_READ_IO;
>> +
>> +	fl->uid = inode->i_uid;
>> +	fl->gid = inode->i_gid;
> 
> Maybe I need to actually read the latest draft, but what's the story
> about these on the wire uids/gids?
> 

Since NFSv3 does not grok stateids, this allows us to control access to
the file.

The mode is adjusted such that the owner has read/write and
the group has read access:

loghyr:~ loghyr$ ls -la foo
-rw-r-----  1 loghyr  staff  0 May 25 22:27 foo

When the mds decides to fence off access for the IOMODE_RW
segment, it changes the uid (monotonically increasing reduces the
chance of resetting to some older value). When it wants to fence
off the IOMODE_READ segment, it changes the gid.

So the code above, should really be something like:

if (seg->iomode == IOMODE_READ)
        fl->uid = inode->i_uid + 11;
else
        fl->uid = inode->i_uid;

        fl->gid = inode->i_gid;

This prevents some client from using the IOMODE_READ segment
to do writes. (I think Jeff just fixed that recently in the client.)

As this patchset neither has fencing nor a remote DS, the synthetic
uid/gid works because the file modes have already determined if
access is to be granted. There are “issues” in that the mode bits
may not be 0640.




