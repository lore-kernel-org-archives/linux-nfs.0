Return-Path: <trondmy@gmail.com>
Message-ID: <1516835307.50324.6.camel@gmail.com>
Subject: Re: [PATCH] pnfs/blocklayout: Ensure disk address in block device
 map
From: Trond Myklebust <trondmy@gmail.com>
To: Benjamin Coddington <bcodding@redhat.com>, Anna Schumaker
	 <anna.schumaker@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Date: Wed, 24 Jan 2018 18:08:27 -0500
In-Reply-To: <8d0b4d04a683809e9986396840abcba1f5110dff.1516805178.git.bcodding@redhat.com>
References: 
	<8d0b4d04a683809e9986396840abcba1f5110dff.1516805178.git.bcodding@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2018-01-24 at 09:48 -0500, Benjamin Coddington wrote:
> It's possible that the device map is smaller than the offset into the
> device for the I/O we're adding.  This probably indicates an error of
> some
> sort (such as the dev->len = 0 due to the device being unreadable),
> so
> let's add a check for it and bail out.  Otherwise, we risk botching
> the bio
> calculations that follow.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/blocklayout/blocklayout.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c
> b/fs/nfs/blocklayout/blocklayout.c
> index 334570888649..6259ef20ee3e 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -137,6 +137,11 @@ bl_alloc_init_bio(int npg, struct block_device
> *bdev, sector_t disk_sector,
>  	return bio;
>  }
>  
> +static bool offset_in_map(sector_t isect, struct pnfs_block_dev_map
> *map)
> +{
> +	return isect >= map->start && isect < map->start + map->len;
> +}
> +
>  static struct bio *
>  do_add_page_to_bio(struct bio *bio, int npg, int rw, sector_t isect,
>  		struct page *page, struct pnfs_block_dev_map *map,
> @@ -156,8 +161,8 @@ do_add_page_to_bio(struct bio *bio, int npg, int
> rw, sector_t isect,
>  
>  	/* translate to physical disk offset */
>  	disk_addr = (u64)isect << SECTOR_SHIFT;
> -	if (disk_addr < map->start || disk_addr >= map->start + map-
> >len) {
> -		if (!dev->map(dev, disk_addr, map))
> +	if (!offset_in_map(isect, map)) {
> +		if (!dev->map(dev, disk_addr, map) ||
> !offset_in_map(isect, map))
>  			return ERR_PTR(-EIO);
>  		bio = bl_submit_bio(bio);
>  	}

I'm confused. While your patch does appear to make sense, there is
other code in the same function that mixes type sector_t and disk
offsets (including a line of the form 'disk_addr -= map->start').

IOW: if this patch makes sense, then there is definitely more code to
fix in the same function.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
