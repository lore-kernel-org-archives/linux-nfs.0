Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51746 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751227AbeAYMwc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Jan 2018 07:52:32 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@gmail.com>
Cc: "Anna Schumaker" <anna.schumaker@netapp.com>,
        "Christoph Hellwig" <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pnfs/blocklayout: Ensure disk address in block device map
Date: Thu, 25 Jan 2018 07:52:30 -0500
Message-ID: <BAF8F9F6-EA4F-4E90-B8FE-3A76DCEB5482@redhat.com>
In-Reply-To: <1516835307.50324.6.camel@gmail.com>
References: <8d0b4d04a683809e9986396840abcba1f5110dff.1516805178.git.bcodding@redhat.com>
 <1516835307.50324.6.camel@gmail.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 24 Jan 2018, at 18:08, Trond Myklebust wrote:

> On Wed, 2018-01-24 at 09:48 -0500, Benjamin Coddington wrote:
>> It's possible that the device map is smaller than the offset into the
>> device for the I/O we're adding.  This probably indicates an error of
>> some
>> sort (such as the dev->len = 0 due to the device being unreadable),
>> so
>> let's add a check for it and bail out.  Otherwise, we risk botching
>> the bio
>> calculations that follow.
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>>  fs/nfs/blocklayout/blocklayout.c | 9 +++++++--
>>  1 file changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/blocklayout/blocklayout.c
>> b/fs/nfs/blocklayout/blocklayout.c
>> index 334570888649..6259ef20ee3e 100644
>> --- a/fs/nfs/blocklayout/blocklayout.c
>> +++ b/fs/nfs/blocklayout/blocklayout.c
>> @@ -137,6 +137,11 @@ bl_alloc_init_bio(int npg, struct block_device
>> *bdev, sector_t disk_sector,
>>  	return bio;
>>  }
>>
>> +static bool offset_in_map(sector_t isect, struct pnfs_block_dev_map
>> *map)
>> +{
>> +	return isect >= map->start && isect < map->start + map->len;
>> +}
>> +
>>  static struct bio *
>>  do_add_page_to_bio(struct bio *bio, int npg, int rw, sector_t isect,
>>  		struct page *page, struct pnfs_block_dev_map *map,
>> @@ -156,8 +161,8 @@ do_add_page_to_bio(struct bio *bio, int npg, int
>> rw, sector_t isect,
>>
>>  	/* translate to physical disk offset */
>>  	disk_addr = (u64)isect << SECTOR_SHIFT;
>> -	if (disk_addr < map->start || disk_addr >= map->start + map-
>>> len) {
>> -		if (!dev->map(dev, disk_addr, map))
>> +	if (!offset_in_map(isect, map)) {
>> +		if (!dev->map(dev, disk_addr, map) ||
>> !offset_in_map(isect, map))
>>  			return ERR_PTR(-EIO);
>>  		bio = bl_submit_bio(bio);
>>  	}
>
> I'm confused. While your patch does appear to make sense, there is
> other code in the same function that mixes type sector_t and disk
> offsets (including a line of the form 'disk_addr -= map->start').
>
> IOW: if this patch makes sense, then there is definitely more code to
> fix in the same function.

Yes, this is wrong.  I think struct pnfs_block_dev_map should be byte
offsets not sectors.  I'll send a patch for that, and then this one again.

Ben
