Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161359AbcFMRlE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2016 13:41:04 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Christoph Hellwig" <hch@lst.de>
Cc: linux-nfs@vger.kernel.org,
        "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>
Subject: Re: [PATCH] pnfs/blocklayout: put deviceid node after releasing
 bl_ext_lock
Date: Mon, 13 Jun 2016 13:41:16 -0400
Message-ID: <CEEBB611-95AD-41C0-BB4C-2A4A3AE06C60@redhat.com>
In-Reply-To: <20160613145300.GB5863@lst.de>
References: <0ca3d07057a20e89726de2f0e9ff8c7fcb6ac3d9.1465589365.git.bcodding@redhat.com>
 <20160613145300.GB5863@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Fri, Jun 10, 2016 at 04:37:35PM -0400, Benjamin Coddington wrote:
>> The last put of deviceid nodes for SCSI layouts may sleep, so we 
>> shouldn't
>> hold any spinlocks.  Make sure we put them outside the bl_ext_lock.
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>
> Thanks Benjamin,
>
> the patch looks fine:
>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
>
> Although maybe it's worth addressing a few naming nitpicks:
>
>> +static void __ext_put_deviceids(struct list_head *head)
>
> No need for the __ here.
>
>>  static int
>> -__ext_tree_remove(struct rb_root *root, sector_t start, sector_t 
>> end)
>> +__ext_tree_remove(struct rb_root *root,
>> +		sector_t start, sector_t end, struct list_head *tmp)
>>  {
>
> Maybe instead of tmp this could be called to_free?
>
>> +	LIST_HEAD(tmp);
>>
>>  	spin_lock(&bl->bl_ext_lock);
>> -	err = __ext_tree_remove(&bl->bl_ext_ro, start, end);
>> +	err = __ext_tree_remove(&bl->bl_ext_ro, start, end, &tmp);
>>  	if (rw) {
>> -		err2 = __ext_tree_remove(&bl->bl_ext_rw, start, end);
>> +		err2 = __ext_tree_remove(&bl->bl_ext_rw, start, end, &tmp);
>
> Same here,
>
>> @@ -396,12 +408,13 @@ ext_tree_mark_written(struct pnfs_block_layout 
>> *bl, sector_t start,
>>  	sector_t end = start + len;
>>  	struct pnfs_block_extent *be;
>>  	int err = 0;
>> +	LIST_HEAD(tmp);
>
> and here.

OK. I'll send a V2.

Ben
