Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41232 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752070AbcITMWj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Sep 2016 08:22:39 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfs/blocklayout: last_write_offset incorrectly set to end of extent
Date: Tue, 20 Sep 2016 08:22:37 -0400
Message-Id: <ffe9a2cc97ead5b73b985aa4c16219351cac29d5.1474372904.git.bcodding@redhat.com>
In-Reply-To: <9FD74439-878E-464E-9334-5F6782145248@redhat.com>
References: <a754067b5a8252a10a0bcfa23c4229cf3d7b1adf.1471535578.git.bcodding@redhat.com> <f50699da22fbcd977842a4fa5dd40b27295fcfcf.1471889187.git.bcodding@redhat.com> <20160919145806.GA12452@infradead.org> <8ECEF67B-FB4D-4289-A656-D98D3175B85E@redhat.com> <20160919190610.GA3612@lst.de> <9FD74439-878E-464E-9334-5F6782145248@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 19 Sep 2016, at 15:40, Benjamin Coddington wrote:

> On 19 Sep 2016, at 15:06, Christoph Hellwig wrote:
>
>> On Mon, Sep 19, 2016 at 03:04:52PM -0400, Benjamin Coddington wrote:
>>> Are you sure this patch is the problem?  I just tested and things are
>>> broken for me too, but I think it has something to do with the client
>>> choosing the block layout over SCSI now that the server is returning
>>> multiple layout types.
>>
>> Yes, this is my local kvm test setup which only uses the block layout
>> for now (and doesn't even have the SCSI layout compiled in on the
>> server).
>>
>>> Just wondering if you reverted this patch and saw the problem go away.
>>
>> Yes, it does.
>
> Rats.. well, I will investigate.



>  diff --git a/fs/nfs/blocklayout/blocklayout.c
>  b/fs/nfs/blocklayout/blocklayout.c
>  index 17a42e4eb872..25cdd559831c 100644
>  --- a/fs/nfs/blocklayout/blocklayout.c
>  +++ b/fs/nfs/blocklayout/blocklayout.c
>  @@ -344,7 +344,7 @@ static void bl_write_cleanup(struct work_struct
>  *work)
>              PAGE_SIZE - 1) & (loff_t)PAGE_MASK;
>
>          ext_tree_mark_written(bl, start >> SECTOR_SHIFT,
>  -                   (end - start) >> SECTOR_SHIFT);
>  +                   (end - start) >> SECTOR_SHIFT, end);
>      }

I have stupidly made this mistake twice now..  end is not the end of the
write here, but rather the end of the extent.  My testing is broken as it's
not catching this, so now going to figure that out.

Ben

8<--------------------------------------------------------------------------------------

Commit 41963c10c47a35185e68cb9049f7a3493c94d2d7 sets the block layout's
last written byte to the offset of the end of the extent rather than the
end of the write which incorrectly updates the inode's size for
partial-page writes.

Fixes: 41963c10c47a ("pnfs/blocklayout: update last_write_offset atomically with extents")
Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/blocklayout/blocklayout.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 217847679f0e..2905479f214a 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -344,9 +344,10 @@ static void bl_write_cleanup(struct work_struct *work)
 		u64 start = hdr->args.offset & (loff_t)PAGE_MASK;
 		u64 end = (hdr->args.offset + hdr->args.count +
 			PAGE_SIZE - 1) & (loff_t)PAGE_MASK;
+		u64 lwb = hdr->args.offset + hdr->args.count;
 
 		ext_tree_mark_written(bl, start >> SECTOR_SHIFT,
-					(end - start) >> SECTOR_SHIFT, end);
+					(end - start) >> SECTOR_SHIFT, lwb);
 	}
 
 	pnfs_ld_write_done(hdr);
-- 
2.5.5

