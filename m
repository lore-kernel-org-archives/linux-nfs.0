Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35114 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751557AbcG2OAE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2016 10:00:04 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "hch@infradead.org" <hch@infradead.org>
Subject: Re: [PATCH 1/2] pnfs/blocklayout: update last_write_offset in
 prepare_layoutcommit
Date: Fri, 29 Jul 2016 10:00:58 -0400
Message-ID: <5B613E0E-523E-4725-9CDF-BE446048F268@redhat.com>
In-Reply-To: <7C1192C7-D1B0-4C4B-8927-314AB972CF41@redhat.com>
References: <cover.1469730653.git.bcodding@redhat.com>
 <973de15d7e14e23d6945ad03713384c97a6a0087.1469730653.git.bcodding@redhat.com>
 <1469731659.9558.3.camel@primarydata.com>
 <7C1192C7-D1B0-4C4B-8927-314AB972CF41@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 28 Jul 2016, at 16:03, Benjamin Coddington wrote:

> On 28 Jul 2016, at 14:47, Trond Myklebust wrote:
>
>> On Thu, 2016-07-28 at 14:41 -0400, Benjamin Coddington wrote:
>>> Block/SCSI layout write completion may add committable extents to the
>>> extent tree before updating the layout's last-written byte under the
>>> inode
>>> lock.  If a sync happens before this value is updated, then
>>> prepare_layoutcommit may find and encode these extents which would
>>> produce
>>> a LAYOUTCOMMIT request whose encoded extents are larger than the
>>> request's
>>> loca_length.
>>>
>>> Fix this by updating the last_write_offset to match the currently
>>> encoded
>>> extents.
>>>
>>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>>> ---
>>>  fs/nfs/blocklayout/extent_tree.c | 6 ++++--
>>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/fs/nfs/blocklayout/extent_tree.c
>>> b/fs/nfs/blocklayout/extent_tree.c
>>> index 992bcb19c11e..18ae1fd2175e 100644
>>> --- a/fs/nfs/blocklayout/extent_tree.c
>>> +++ b/fs/nfs/blocklayout/extent_tree.c
>>> @@ -518,7 +518,7 @@ static __be32 *encode_scsi_range(struct
>>> pnfs_block_extent *be, __be32 *p)
>>>  }
>>>  
>>>  static int ext_tree_encode_commit(struct pnfs_block_layout *bl,
>>> __be32 *p,
>>> -		size_t buffer_size, size_t *count)
>>> +		size_t buffer_size, size_t *count, __u64 *lastbyte)
>>>  {
>>>  	struct pnfs_block_extent *be;
>>>  	int ret = 0;
>>> @@ -541,6 +541,8 @@ static int ext_tree_encode_commit(struct
>>> pnfs_block_layout *bl, __be32 *p,
>>>  		else
>>>  			p = encode_block_extent(be, p);
>>>  		be->be_tag = EXTENT_COMMITTING;
>>> +		if ((ext_f_end(be) << SECTOR_SHIFT) - 1 > *lastbyte)
>>> +			*lastbyte = (ext_f_end(be) << SECTOR_SHIFT)
>>> - 1;
>>
>> Won't this cause the file size to be always sector aligned on the
>> server? I was assuming that we would have to store the lastbyte
>> atomically with setting up the commit in ext_tree_mark_written().
>
> You're right.  It is incorrect.  I'll fix it.

This turns out to be a little trickier than I thought, and so is taking me
longer than I have time at the moment.  Due to travel, I'll have to come
back to this week after next.  Thanks for catching my stupid mistake.

Ben
