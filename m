Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753272AbcGSNI1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jul 2016 09:08:27 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "List Linux" <linux-nfs@vger.kernel.org>,
        "Schumaker Anna" <anna.schumaker@netapp.com>, hch <hch@lst.de>
Subject: Re: [PATCH] pnfs/blocklayout: put deviceid node after releasing
 bl_ext_lock
Date: Tue, 19 Jul 2016 09:10:00 -0400
Message-ID: <E5D40259-4AEA-4828-A309-534ACB527251@redhat.com>
In-Reply-To: <5F0069E8-CCD7-42B0-B391-F1D4B0B9C0AF@primarydata.com>
References: <0ca3d07057a20e89726de2f0e9ff8c7fcb6ac3d9.1465589365.git.bcodding@redhat.com>
 <5F0069E8-CCD7-42B0-B391-F1D4B0B9C0AF@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 19 Jul 2016, at 8:25, Trond Myklebust wrote:

> Hi Ben,
>
>> On Jun 10, 2016, at 16:37, Benjamin Coddington <bcodding@redhat.com> 
>> wrote:
>>
>> The last put of deviceid nodes for SCSI layouts may sleep, so we 
>> shouldn't
>> hold any spinlocks.  Make sure we put them outside the bl_ext_lock.
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>> fs/nfs/blocklayout/extent_tree.c | 27 +++++++++++++++++++++------
>> 1 file changed, 21 insertions(+), 6 deletions(-)
>>
>> diff --git a/fs/nfs/blocklayout/extent_tree.c 
>> b/fs/nfs/blocklayout/extent_tree.c
>> index 720b3ff55fa9..992bcb19c11e 100644
>> --- a/fs/nfs/blocklayout/extent_tree.c
>> +++ b/fs/nfs/blocklayout/extent_tree.c
>> @@ -121,6 +121,16 @@ ext_try_to_merge_right(struct rb_root *root, 
>> struct pnfs_block_extent *be)
>> 	return be;
>> }
>>
>> +static void __ext_put_deviceids(struct list_head *head)
>> +{
>> +	struct pnfs_block_extent *be, *tmp;
>> +
>> +	list_for_each_entry_safe(be, tmp, head, be_list) {
>> +		nfs4_put_deviceid_node(be->be_device);
>> +		kfree(be);
>> +	}
>
> This definitely needs a list_del()… I only noticed this morning 
> after hunting for the OOM that Christoph says turned up after this 
> weekend.

I'm afraid I don't understand why, though.  List traversal seems fine
without it since we're using list_for_each_entry_safe..   I must be 
missing
something.

Ben

>> +}
>> +
>> static void
>> __ext_tree_insert(struct rb_root *root,
>> 		struct pnfs_block_extent *new, bool merge_ok)
>> @@ -163,7 +173,8 @@ free_new:
>> }
>>
>> static int
>> -__ext_tree_remove(struct rb_root *root, sector_t start, sector_t 
>> end)
>> +__ext_tree_remove(struct rb_root *root,
>> +		sector_t start, sector_t end, struct list_head *tmp)
>> {
>> 	struct pnfs_block_extent *be;
>> 	sector_t len1 = 0, len2 = 0;
>> @@ -223,8 +234,7 @@ __ext_tree_remove(struct rb_root *root, sector_t 
>> start, sector_t end)
>> 			struct pnfs_block_extent *next = ext_tree_next(be);
>>
>> 			rb_erase(&be->be_node, root);
>> -			nfs4_put_deviceid_node(be->be_device);
>> -			kfree(be);
>> +			list_add_tail(&be->be_list, tmp);
>> 			be = next;
>> 		}
>>
>> @@ -350,16 +360,18 @@ int ext_tree_remove(struct pnfs_block_layout 
>> *bl, bool rw,
>> 		sector_t start, sector_t end)
>> {
>> 	int err, err2;
>> +	LIST_HEAD(tmp);
>>
>> 	spin_lock(&bl->bl_ext_lock);
>> -	err = __ext_tree_remove(&bl->bl_ext_ro, start, end);
>> +	err = __ext_tree_remove(&bl->bl_ext_ro, start, end, &tmp);
>> 	if (rw) {
>> -		err2 = __ext_tree_remove(&bl->bl_ext_rw, start, end);
>> +		err2 = __ext_tree_remove(&bl->bl_ext_rw, start, end, &tmp);
>> 		if (!err)
>> 			err = err2;
>> 	}
>> 	spin_unlock(&bl->bl_ext_lock);
>>
>> +	__ext_put_deviceids(&tmp);
>> 	return err;
>> }
>>
>> @@ -396,12 +408,13 @@ ext_tree_mark_written(struct pnfs_block_layout 
>> *bl, sector_t start,
>> 	sector_t end = start + len;
>> 	struct pnfs_block_extent *be;
>> 	int err = 0;
>> +	LIST_HEAD(tmp);
>>
>> 	spin_lock(&bl->bl_ext_lock);
>> 	/*
>> 	 * First remove all COW extents or holes from written to range.
>> 	 */
>> -	err = __ext_tree_remove(&bl->bl_ext_ro, start, end);
>> +	err = __ext_tree_remove(&bl->bl_ext_ro, start, end, &tmp);
>> 	if (err)
>> 		goto out;
>>
>> @@ -459,6 +472,8 @@ ext_tree_mark_written(struct pnfs_block_layout 
>> *bl, sector_t start,
>> 	}
>> out:
>> 	spin_unlock(&bl->bl_ext_lock);
>> +
>> +	__ext_put_deviceids(&tmp);
>> 	return err;
>> }
>>
>> -- 
>> 2.5.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
