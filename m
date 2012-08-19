Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:1635 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754008Ab2HSC5q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Aug 2012 22:57:46 -0400
Date: Sun, 19 Aug 2012 10:57:24 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Namjae Jeon <linkinjeon@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        Namjae Jeon <namjae.jeon@samsung.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] writeback: add dirty_ratio_time per bdi variable
 (NFS write performance)
Message-ID: <20120819025724.GC16796@localhost>
References: <1345283402-7889-1-git-send-email-linkinjeon@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1345283402-7889-1-git-send-email-linkinjeon@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 18, 2012 at 05:50:02AM -0400, Namjae Jeon wrote:
> From: Namjae Jeon <namjae.jeon@samsung.com>
> 
> This patch is based on suggestion by Wu Fengguang:
> https://lkml.org/lkml/2011/8/19/19
> 
> kernel has mechanism to do writeback as per dirty_ratio and dirty_background
> ratio. It also maintains per task dirty rate limit to keep balance of
> dirty pages at any given instance by doing bdi bandwidth estimation.
> 
> Kernel also has max_ratio/min_ratio tunables to specify percentage of writecache
> to control per bdi dirty limits and task throtelling.
> 
> However, there might be a usecase where user wants a writeback tuning
> parameter to flush dirty data at desired/tuned time interval.
> 
> dirty_background_time provides an interface where user can tune background
> writeback start time using /sys/block/sda/bdi/dirty_background_time
> 
> dirty_background_time is used alongwith average bdi write bandwidth estimation
> to start background writeback.

Here lies my major concern about dirty_background_time: the write
bandwidth estimation is an _estimation_ and will sure become wildly
wrong in some cases. So the dirty_background_time implementation based
on it will not always work to the user expectations.

One important case is, some users (eg. Dave Chinner) explicitly take
advantage of the existing behavior to quickly create & delete a big
1GB temp file without worrying about triggering unnecessary IOs.

> One of the use case to demonstrate the patch functionality can be
> on NFS setup:-
> We have a NFS setup with ethernet line of 100Mbps, while the USB
> disk is attached to server, which has a local speed of 25MBps. Server
> and client both are arm target boards.
> 
> Now if we perform a write operation over NFS (client to server), as
> per the network speed, data can travel at max speed of 100Mbps. But
> if we check the default write speed of USB hdd over NFS it comes
> around to 8MB/sec, far below the speed of network.
> 
> Reason being is as per the NFS logic, during write operation, initially
> pages are dirtied on NFS client side, then after reaching the dirty
> threshold/writeback limit (or in case of sync) data is actually sent
> to NFS server (so now again pages are dirtied on server side). This
> will be done in COMMIT call from client to server i.e if 100MB of data
> is dirtied and sent then it will take minimum 100MB/10Mbps ~ 8-9 seconds.
> 
> After the data is received, now it will take approx 100/25 ~4 Seconds to
> write the data to USB Hdd on server side. Hence making the overall time
> to write this much of data ~12 seconds, which in practically comes out to
> be near 7 to 8MB/second. After this a COMMIT response will be sent to NFS
> client.
> 
> However we may improve this write performace by making the use of NFS
> server idle time i.e while data is being received from the client,
> simultaneously initiate the writeback thread on server side. So instead
> of waiting for the complete data to come and then start the writeback,
> we can work in parallel while the network is still busy in receiving the
> data. Hence in this way overall performace will be improved.
> 
> If we tune dirty_background_time, we can see there
> is increase in the performace and it comes out to be ~ 11MB/seconds.
> Results are:-
> ==========================================================
> Case:1 - Normal setup without any changes
> ./performancetest_arm ./100MB write
> 
>  RecSize  WriteSpeed   RanWriteSpeed
> 
>  10485760  7.93MB/sec   8.11MB/sec
>   1048576  8.21MB/sec   7.80MB/sec
>    524288  8.71MB/sec   8.39MB/sec
>    262144  8.91MB/sec   7.83MB/sec
>    131072  8.91MB/sec   8.95MB/sec
>     65536  8.95MB/sec   8.90MB/sec
>     32768  8.76MB/sec   8.93MB/sec
>     16384  8.78MB/sec   8.67MB/sec
>      8192  8.90MB/sec   8.52MB/sec
>      4096  8.89MB/sec   8.28MB/sec
> 
> Average speed is near 8MB/seconds.
> 
> Case:2 - Modified the dirty_background_time
> ./performancetest_arm ./100MB write
> 
>  RecSize  WriteSpeed   RanWriteSpeed
> 
>  10485760  10.56MB/sec  10.37MB/sec
>   1048576  10.43MB/sec  10.33MB/sec
>    524288  10.32MB/sec  10.02MB/sec
>    262144  10.52MB/sec  10.19MB/sec
>    131072  10.34MB/sec  10.07MB/sec
>     65536  10.31MB/sec  10.06MB/sec
>     32768  10.27MB/sec  10.24MB/sec
>     16384  10.54MB/sec  10.03MB/sec
>      8192  10.41MB/sec  10.38MB/sec
>      4096  10.34MB/sec  10.12MB/sec
> 
> we can see, average write speed is increased to ~10-11MB/sec.
> ============================================================

The numbers are impressive! FYI, I tried another NFS specific approach
to avoid big NFS COMMITs, which achieved similar performance gains:

nfs: writeback pages wait queue
https://lkml.org/lkml/2011/10/20/235

Thanks,
Fengguang

> Now to make this working we need to make change in dirty_[wirteback|expire]
> _interval so that flusher threads will be awaken up more early. But if we
> modify these values it will impact the overall system performace, while our
> requirement is to modify these parameters for the device used in NFS interface.
> 
> This patch provides the changes per block devices. So that we may modify the
> intervals as per the device and overall system is not impacted by the changes
> and we get improved
> 
> The above mentioned is one of the use case to use this patch.
> 
> Original-patch-by: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: Namjae Jeon <namjae.jeon@samsung.com>
> Tested-by: Vivek Trivedi <t.vivek@samsung.com>
> ---
>  fs/fs-writeback.c           |   18 ++++++++++++++++--
>  include/linux/backing-dev.h |    1 +
>  include/linux/writeback.h   |    1 +
>  mm/backing-dev.c            |   22 ++++++++++++++++++++++
>  mm/page-writeback.c         |    3 ++-
>  5 files changed, 42 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index be3efc4..75fda1d 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -769,6 +769,19 @@ static bool over_bground_thresh(struct backing_dev_info *bdi)
>  	return false;
>  }
>  
> +bool over_dirty_bground_time(struct backing_dev_info *bdi)
> +{
> +	unsigned long background_thresh;
> +
> +	background_thresh = bdi->avg_write_bandwidth *
> +		bdi->dirty_background_time / 1000;
> +
> +	if (bdi_stat(bdi, BDI_RECLAIMABLE) > background_thresh)
> +		return true;
> +
> +	return false;
> +}
> +
>  /*
>   * Called under wb->list_lock. If there are multiple wb per bdi,
>   * only the flusher working on the first wb should do it.
> @@ -828,7 +841,8 @@ static long wb_writeback(struct bdi_writeback *wb,
>  		 * For background writeout, stop when we are below the
>  		 * background dirty threshold
>  		 */
> -		if (work->for_background && !over_bground_thresh(wb->bdi))
> +		if (work->for_background && !over_bground_thresh(wb->bdi) &&
> +			!over_dirty_bground_time(wb->bdi))
>  			break;
>  
>  		/*
> @@ -920,7 +934,7 @@ static unsigned long get_nr_dirty_pages(void)
>  
>  static long wb_check_background_flush(struct bdi_writeback *wb)
>  {
> -	if (over_bground_thresh(wb->bdi)) {
> +	if (over_bground_thresh(wb->bdi) || over_dirty_bground_time(wb->bdi)) {
>  
>  		struct wb_writeback_work work = {
>  			.nr_pages	= LONG_MAX,
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 2a9a9ab..ad83783 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -95,6 +95,7 @@ struct backing_dev_info {
>  
>  	unsigned int min_ratio;
>  	unsigned int max_ratio, max_prop_frac;
> +	unsigned int dirty_background_time;
>  
>  	struct bdi_writeback wb;  /* default writeback info for this bdi */
>  	spinlock_t wb_lock;	  /* protects work_list */
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index b82a83a..433cd09 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -96,6 +96,7 @@ long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
>  long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
>  void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
>  void inode_wait_for_writeback(struct inode *inode);
> +bool over_dirty_bground_time(struct backing_dev_info *bdi);
>  
>  /* writeback.h requires fs.h; it, too, is not included from here. */
>  static inline void wait_on_inode(struct inode *inode)
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index b41823c..0f9f798 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -219,12 +219,33 @@ static ssize_t max_ratio_store(struct device *dev,
>  }
>  BDI_SHOW(max_ratio, bdi->max_ratio)
>  
> +static ssize_t dirty_background_time_store(struct device *dev,
> +		struct device_attribute *attr, const char *buf, size_t count)
> +{
> +	struct backing_dev_info *bdi = dev_get_drvdata(dev);
> +	char *end;
> +	unsigned int msec;
> +	ssize_t ret = -EINVAL;
> +
> +	msec = simple_strtoul(buf, &end, 10);
> +	if (*buf && (end[0] == '\0' || (end[0] == '\n' && end[1] == '\0'))) {
> +		bdi->dirty_background_time = msec;
> +		ret = count;
> +
> +		if (over_dirty_bground_time(bdi))
> +			bdi_start_background_writeback(bdi);
> +	}
> +	return ret;
> +}
> +BDI_SHOW(dirty_background_time, bdi->dirty_background_time)
> +
>  #define __ATTR_RW(attr) __ATTR(attr, 0644, attr##_show, attr##_store)
>  
>  static struct device_attribute bdi_dev_attrs[] = {
>  	__ATTR_RW(read_ahead_kb),
>  	__ATTR_RW(min_ratio),
>  	__ATTR_RW(max_ratio),
> +	__ATTR_RW(dirty_background_time),
>  	__ATTR_NULL,
>  };
>  
> @@ -626,6 +647,7 @@ int bdi_init(struct backing_dev_info *bdi)
>  	bdi->min_ratio = 0;
>  	bdi->max_ratio = 100;
>  	bdi->max_prop_frac = FPROP_FRAC_BASE;
> +	bdi->dirty_background_time = 10000;
>  	spin_lock_init(&bdi->wb_lock);
>  	INIT_LIST_HEAD(&bdi->bdi_list);
>  	INIT_LIST_HEAD(&bdi->work_list);
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 73a7a06..f51a252 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1403,7 +1403,8 @@ pause:
>  	if (laptop_mode)
>  		return;
>  
> -	if (nr_reclaimable > background_thresh)
> +	if (nr_reclaimable > background_thresh ||
> +		over_dirty_bground_time(bdi))
>  		bdi_start_background_writeback(bdi);
>  }
>  
> -- 
> 1.7.9.5
