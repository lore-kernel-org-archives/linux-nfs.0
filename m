From: Wu Fengguang <wfg@linux.intel.com>
Subject: Re: Slow file transfer speeds with CFQ IO scheduler in some cases
Date: Fri, 28 Nov 2008 08:48:30 +0800
Message-ID: <20081128004830.GA8874@localhost>
References: <20081112190227.GS26778@kernel.dk> <1226566313.199910.29888@de> <492BDAA9.4090405@vlnb.net> <20081125113048.GB16422@localhost> <492BE47B.3010802@vlnb.net> <20081125114908.GA16545@localhost> <492BE97A.3050606@vlnb.net> <492BEAE8.9050809@vlnb.net> <20081125121534.GA16778@localhost> <492EDCFB.7080302@vlnb.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6TrnltStXW4iwmi0"
Cc: Jens Axboe <jens.axboe@oracle.com>, Jeff Moyer <jmoyer@redhat.com>,
	"Vitaly V. Bursov" <vitalyb-CNXmb7IdZIXO1JJkmS+EZg@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Vladislav Bolkhovitin <vst-d+Crzxg7Rs0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:55349 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752340AbYK1AtT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Nov 2008 19:49:19 -0500
In-Reply-To: <492EDCFB.7080302-d+Crzxg7Rs0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Nov 27, 2008 at 08:46:35PM +0300, Vladislav Bolkhovitin wrote:
>
> Wu Fengguang wrote:
>> On Tue, Nov 25, 2008 at 03:09:12PM +0300, Vladislav Bolkhovitin wrote:
>>> Vladislav Bolkhovitin wrote:
>>>> Wu Fengguang wrote:
>>>>> On Tue, Nov 25, 2008 at 02:41:47PM +0300, Vladislav Bolkhovitin wrote:
>>>>>> Wu Fengguang wrote:
>>>>>>> On Tue, Nov 25, 2008 at 01:59:53PM +0300, Vladislav Bolkhovitin wrote:
>>>>>>>> Wu Fengguang wrote:
>>>>>>>>> Hi all,
>>>>>>>>>
>>>>>>>>> //Sorry for being late. 
>>>>>>>>>
>>>>>>>>> On Wed, Nov 12, 2008 at 08:02:28PM +0100, Jens Axboe wrote:
>>>>>>>>> [...]
>>>>>>>>>> I already talked about this with Jeff on irc, but I guess should post it
>>>>>>>>>> here as well.
>>>>>>>>>>
>>>>>>>>>> nfsd aside (which does seem to have some different behaviour skewing the
>>>>>>>>>> results), the original patch came about because dump(8) has a really
>>>>>>>>>> stupid design that offloads IO to a number of processes. This basically
>>>>>>>>>> makes fairly sequential IO more random with CFQ, since each process gets
>>>>>>>>>> its own io context. My feeling is that we should fix dump instead of
>>>>>>>>>> introducing a fair bit of complexity (and slowdown) in CFQ. I'm not
>>>>>>>>>> aware of any other good programs out there that would do something
>>>>>>>>>> similar, so I don't think there's a lot of merrit to spending cycles on
>>>>>>>>>> detecting cooperating processes.
>>>>>>>>>>
>>>>>>>>>> Jeff will take a look at fixing dump instead, and I may have promised
>>>>>>>>>> him that santa will bring him something nice this year if he does (since
>>>>>>>>>> I'm sure it'll be painful on the eyes).
>>>>>>>>> This could also be fixed at the VFS readahead level.
>>>>>>>>>
>>>>>>>>> In fact I've seen many kinds of interleaved accesses:
>>>>>>>>> - concurrently reading 40 files that are in fact hard links of one single file
>>>>>>>>> - a backup tool that splits a big file into 8k chunks, and serve the
>>>>>>>>>   {1, 3, 5, 7, ...} chunks in one process and the {0, 2, 4, 6, ...}
>>>>>>>>>   chunks in another one
>>>>>>>>> - a pool of NFSDs randomly serving some originally 
>>>>>>>>> sequential read  requests - now dump(8) seems to have 
>>>>>>>>> some similar problem.
>>>>>>>>>
>>>>>>>>> In summary there have been all kinds of efforts on trying to
>>>>>>>>> parallelize I/O tasks, but unfortunately they can easily screw up the
>>>>>>>>> sequential pattern. It may not be easily fixable for many of them.
>>>>>>>>>
>>>>>>>>> It is however possible to detect most of these patterns at the
>>>>>>>>> readahead layer and restore sequential I/Os, before they propagate
>>>>>>>>> into the block layer and hurt performance.
>>>>>>>> I believe this would be the most effective way to go,  
>>>>>>>> especially in case  if data delivery path to the original  
>>>>>>>> client has its own latency  depended from the amount of  
>>>>>>>> transferred data as it is in the case of  remote NFS mount, 
>>>>>>>> which does synchronous sequential reads. In this case  it 
>>>>>>>> is essential for performance to make both links (local to 
>>>>>>>> the storage  and network to the client) be always busy and  
>>>>>>>> transfer data  simultaneously. Since the reads are 
>>>>>>>> synchronous, the only way to achieve  that is perform read 
>>>>>>>> ahead on the server sufficient to cover the network  link 
>>>>>>>> latency. Otherwise you would end up with only half of 
>>>>>>>> possible  throughput.
>>>>>>>>
>>>>>>>> However, from one side, server has to have a pool of   
>>>>>>>> threads/processes  to perform well, but, from other side,  
>>>>>>>> current read ahead code doesn't  detect too well that those 
>>>>>>>> threads/processes are doing joint sequential  read, so the 
>>>>>>>> read ahead window gets smaller, hence the overall read  
>>>>>>>> performance gets considerably smaller too.
>>>>>>>>
>>>>>>>>> Vitaly, if that's what you need, I can try to prepare a patch for testing out.
>>>>>>>> I can test it with SCST SCSI target sybsystem  
>>>>>>>> (http://scst.sf.net). SCST  needs such feature very much,  
>>>>>>>> otherwise it can't get full backstorage  read speed. The  
>>>>>>>> maximum I can see is about ~80MB/s from ~130MB/s 15K RPM  
>>>>>>>> disk over 1Gbps iSCSI link (maximum possible is ~110MB/s).
>>>>>>> Thank you very much!
>>>>>>>
>>>>>>> BTW, do you implicate that the SCSI system (or its applications) has
>>>>>>> similar behaviors that the current readahead code cannot handle well?
>>>>>> No. SCSI target subsystem is not the same as SCSI initiator  
>>>>>> subsystem,  which usually called simply SCSI (sub)system. SCSI  
>>>>>> target is a SCSI  server. It has the same amount of common with 
>>>>>> SCSI initiator as there  is, e.g., between Apache (HTTP server) 
>>>>>> and Firefox (HTTP client).
>>>>> Got it. So the SCSI server will split&spread sequential IO of one
>>>>> single file to cooperative threads?
>>>> Yes. It has to do so, because Linux doesn't have async. cached IO 
>>>> and a client can queue several tens of commands at time. Then, on 
>>>> the  sequential IO with 1 command at time, CPU scheduler comes to 
>>>> play and  spreads those commands over those threads, so read ahead 
>>>> gets too small to cover the external link latency and fill both 
>>>> links with data, so  that uncovered latency kills throughput.
>>> Additionally, if the uncovered external link latency is too large, 
>>> one  more factor is getting noticeable: storage rotation latency. If 
>>> the next  unread sector is missed to be read at time, server has to 
>>> wait a full  rotation to start receiving data for the next block, 
>>> which even more  decreases the resulting throughput.
>
>> Thank you for the details. I've been working slowly on the idea, and
>> should be able to send you a patch in the next one or two days.
>
> Actually, there's one more thing, which should have been mentioned. It
> is possible that remote clients have several sequential read streams at
> time together with some "noise" of random requests. A good read-ahead
> subsystem should handle such case by keeping big read-ahead windows for
> the sequential streams and don't do any read ahead for the random
> requests. And all at the same time.
>
> Currently on such workloads read ahead will be completely disabled for
> all the requests. Hence, there is a possibility here to improve
> performance in 3-5 times or even more by making the workload more linear.

Are you sure? I'd expect such mixed-sequential-random pattern to be
handled by the current readahead code pretty well: sequential ones
will get large readahead and random ones won't get readahead at all.

Attached is the context readahead patch plus a kernel module for
readahead tracing and accounting, which will hopefully help clarify the
read patterns and readahead behaviors on production workloads. It is
based on 2.6.27 for your convenience, but also applies to 2.6.28.

The patch is not targeted for code review, but if anyone are interested,
you can take a look at try_context_readahead(). This is the only newly
introduced readahead policy, the other majorities are code refactor
and tracing facilities.

The newly introduced context readahead policy is disabled by default.
To enable it:
        echo 1 > /sys/block/sda/queue/context_readahead
I'm not sure for now whether this parameter will be a long term one, or
whether the context readahead policy should be enabled unconditionally.

The readahead accounting stats can be viewed by
        mount -t debugfs none /sys/kernel/debug
        cat /sys/kernel/debug/readahead/stats
The numbers can be reset by
        echo > /sys/kernel/debug/readahead/stats

Here is a sample output from my desktop:

% cat /sys/kernel/debug/readahead/stats
pattern         count sync_count  eof_count       size async_size     actual
none                0          0          0          0          0          0
initial0         3009       3009       2033          5          4          2
initial            35         35          0          5          4          3
subsequent       1294        240        827         52         49         26
marker            220          0        109         54         53         29
trail               0          0          0          0          0          0
oversize            0          0          0          0          0          0
reverse             0          0          0          0          0          0
stride              0          0          0          0          0          0
thrash              0          0          0          0          0          0
mmap             2833       2833       1379        142          0         47
fadvise             7          7          7          0          0         40
random           7621       7621         69          1          0          1
all             15019      13745       4424         33          5         12

The readahead/read tracing messages are disabled by default.
To enable them:
        echo 1 > /sys/kernel/debug/readahead/trace_enable
        echo 1 > /sys/kernel/debug/readahead/read_jprobes
They(especially the latter one) will generate a lot of printk messages like:

[  828.151013] readahead-initial0(pid=4644(zsh), dev=00:10(0:10), ino=351452(whoami), req=0+1, ra=0+4-3, async=0) = 4
[  828.167853] readahead-mmap(pid=4644(whoami), dev=00:10(0:10), ino=351452(whoami), req=0+0, ra=0+60-0, async=0) = 3
[  828.195652] readahead-initial0(pid=4629(zsh), dev=00:10(0:10), ino=115569(zsh_prompt), req=0+128, ra=0+120-60, async=0) = 3
[  828.225081] readahead-initial0(pid=4629(zsh), dev=00:10(0:10), ino=342086(.zsh_history), req=0+128, ra=0+120-60, async=0) = 4

[  964.471450] do_generic_file_read(pid=4685(zsh), dev=00:10(0:10), ino=351445(wc), pos=0, count=128)
[  964.471544] do_generic_file_read(pid=4685(zsh), dev=00:10(0:10), ino=351445(wc), pos=64, count=448)
[  964.471575] do_generic_file_read(pid=4685(zsh), dev=00:10(0:10), ino=351445(wc), pos=512, count=28)
[  964.472659] do_generic_file_read(pid=4685(zsh), dev=00:10(0:10), ino=383002(ld-2.7.so), pos=0, count=128)
[  964.473431] do_generic_file_read(pid=4685(wc), dev=00:10(0:10), ino=383002(ld-2.7.so), pos=64, count=336)
[  964.475639] do_generic_file_read(pid=4685(wc), dev=00:10(0:10), ino=383010(libc-2.7.so), pos=0, count=832)
[  964.479037] do_generic_file_read(pid=4685(wc), dev=00:10(0:10), ino=196085(locale.alias), pos=0, count=524288)
[  964.479166] do_generic_file_read(pid=4685(wc), dev=00:10(0:10), ino=196085(locale.alias), pos=2586, count=524288)

So please enable them only when necessary.

My recommendation for the double readahead in NFS client and NFS servers,
is to keep client side readahead size small and the server side one large.
For example, 128K-512K/1M-2M(more for RAID). The NFS client side readahead size
is not directly tunable, but setting rsize to a small value does the trick.
Currently the NFS magic is readahead_size=N*rsize. The default numbers in my
2.6.28 kernel are rsize=512k, N=15, readahead_size=7680k. The latter is
obviously way too large.

Thanks,
Fengguang

> I guess, such functionality can be done by keeping several read-ahead
> contexts not in file handle as now, but in inode, or ever in task_struct
> similarly to io_context. Or even as a part of struct io_context. Then
> those contexts would be rotated in, e.g., round robin manner. I have
> some basic thoughts in this area and would be glad to share them, if you
> are interested.
>
> Going further, ultimately, it would be great to provide somehow a
> capability to allow to assign for each read-ahead stream own IO context,
> because on the remote side in most cases such streams would correspond
> to different programs reading data in parallel. This should allow to
> increase performance even more.
>
>> Thanks,
>> Fengguang
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>

--6TrnltStXW4iwmi0
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="readahead-context-plus-tracing-module-2.6.27.patch"

---
 block/blk-sysfs.c           |   25 +
 include/linux/backing-dev.h |    1 
 include/linux/fs.h          |   44 +++
 include/linux/radix-tree.h  |    2 
 lib/radix-tree.c            |   37 ++
 mm/Kconfig                  |   18 +
 mm/Makefile                 |    1 
 mm/filemap.c                |    2 
 mm/readahead.c              |  166 +++++++++--
 mm/readahead_trace.c        |  486 ++++++++++++++++++++++++++++++++++
 10 files changed, 754 insertions(+), 28 deletions(-)

--- mm.orig/mm/readahead.c
+++ mm/mm/readahead.c
@@ -16,6 +16,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
+#include <linux/marker.h>
 
 void default_unplug_io_fn(struct backing_dev_info *bdi, struct page *page)
 {
@@ -204,6 +205,10 @@ int force_page_cache_readahead(struct ad
 		offset += this_chunk;
 		nr_to_read -= this_chunk;
 	}
+
+	trace_mark(readahead_fadvise, "%p %p %lu %lu %d",
+			mapping, filp, offset, nr_to_read, ret);
+
 	return ret;
 }
 
@@ -217,10 +222,18 @@ int force_page_cache_readahead(struct ad
 int do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			pgoff_t offset, unsigned long nr_to_read)
 {
+	int actual;
+
 	if (bdi_read_congested(mapping->backing_dev_info))
 		return -1;
 
-	return __do_page_cache_readahead(mapping, filp, offset, nr_to_read, 0);
+	actual = __do_page_cache_readahead(mapping, filp, offset,
+								nr_to_read, 0);
+
+	trace_mark(readahead_mmap, "%p %p %lu %lu %d",
+			mapping, filp, offset, nr_to_read, actual);
+
+	return actual;
 }
 
 /*
@@ -248,14 +261,21 @@ subsys_initcall(readahead_init);
 /*
  * Submit IO for the read-ahead request in file_ra_state.
  */
-static unsigned long ra_submit(struct file_ra_state *ra,
-		       struct address_space *mapping, struct file *filp)
+static unsigned long ra_submit(struct address_space *mapping,
+			       struct file *filp,
+			       pgoff_t offset,
+			       unsigned long req_size,
+			       struct file_ra_state *ra,
+			       int async)
 {
 	int actual;
 
 	actual = __do_page_cache_readahead(mapping, filp,
 					ra->start, ra->size, ra->async_size);
 
+	trace_mark(readahead_generic, "%p %p %lu %lu %p %d %d",
+			mapping, filp, offset, req_size, ra, actual, async);
+
 	return actual;
 }
 
@@ -337,6 +357,60 @@ static unsigned long get_next_ra_size(st
  */
 
 /*
+ * Count continuously cached pages from @offset-1 to @offset-@max,
+ * this count is a conservative estimation of
+ * 	- length of the sequential read sequence, or
+ * 	- thrashing threshold in memory tight systems
+ */
+static unsigned long count_history_pages(struct address_space *mapping,
+					 struct file_ra_state *ra,
+					 pgoff_t offset, unsigned long max)
+{
+	pgoff_t head;
+
+	rcu_read_lock();
+	head = radix_tree_prev_hole(&mapping->page_tree, offset - 1, max);
+	rcu_read_unlock();
+
+	return offset - 1 - head;
+}
+
+/*
+ * page cache context based read-ahead
+ */
+static int try_context_readahead(struct address_space *mapping,
+				 struct file_ra_state *ra,
+				 pgoff_t offset,
+				 unsigned int req_size,
+				 unsigned int max)
+{
+	unsigned long size;
+
+	size = count_history_pages(mapping, ra, offset, max);
+
+	/*
+	 * no history pages:
+	 * it could be a random read
+	 */
+	if (!size)
+		return 0;
+
+	/*
+	 * starts from beginning of file:
+	 * it is a strong indication of long-run stream (or whole-file-read)
+	 */
+	if (size >= offset)
+		size *= 2;
+
+	ra_set_pattern(ra, RA_PATTERN_HAS_TRAIL);
+	ra->start = offset;
+	ra->size = get_init_ra_size(size + req_size, max);
+	ra->async_size = ra->size;
+
+	return 1;
+}
+
+/*
  * A minimal readahead algorithm for trivial sequential/random reads.
  */
 static unsigned long
@@ -345,34 +419,30 @@ ondemand_readahead(struct address_space 
 		   bool hit_readahead_marker, pgoff_t offset,
 		   unsigned long req_size)
 {
-	int	max = ra->ra_pages;	/* max readahead pages */
-	pgoff_t prev_offset;
-	int	sequential;
+	unsigned long	max = ra->ra_pages;	/* max readahead pages */
+	pgoff_t prev_offset = ra->prev_pos >> PAGE_CACHE_SHIFT;
+
+	/*
+	 * start of file
+	 */
+	if (!offset) {
+		ra_set_pattern(ra, RA_PATTERN_INITIAL0);
+		goto initial_readahead;
+	}
 
 	/*
 	 * It's the expected callback offset, assume sequential access.
 	 * Ramp up sizes, and push forward the readahead window.
 	 */
-	if (offset && (offset == (ra->start + ra->size - ra->async_size) ||
-			offset == (ra->start + ra->size))) {
+	if ((offset == (ra->start + ra->size - ra->async_size) ||
+	     offset == (ra->start + ra->size))) {
+		ra_set_pattern(ra, RA_PATTERN_SUBSEQUENT);
 		ra->start += ra->size;
 		ra->size = get_next_ra_size(ra, max);
 		ra->async_size = ra->size;
 		goto readit;
 	}
 
-	prev_offset = ra->prev_pos >> PAGE_CACHE_SHIFT;
-	sequential = offset - prev_offset <= 1UL || req_size > max;
-
-	/*
-	 * Standalone, small read.
-	 * Read as is, and do not pollute the readahead state.
-	 */
-	if (!hit_readahead_marker && !sequential) {
-		return __do_page_cache_readahead(mapping, filp,
-						offset, req_size, 0);
-	}
-
 	/*
 	 * Hit a marked page without valid readahead state.
 	 * E.g. interleaved reads.
@@ -389,6 +459,7 @@ ondemand_readahead(struct address_space 
 		if (!start || start - offset > max)
 			return 0;
 
+		ra_set_pattern(ra, RA_PATTERN_HIT_MARKER);
 		ra->start = start;
 		ra->size = start - offset;	/* old async_size */
 		ra->size = get_next_ra_size(ra, max);
@@ -397,18 +468,59 @@ ondemand_readahead(struct address_space 
 	}
 
 	/*
-	 * It may be one of
-	 * 	- first read on start of file
-	 * 	- sequential cache miss
-	 * 	- oversize random read
-	 * Start readahead for it.
+	 * oversize read
+	 */
+	if (req_size > max) {
+		ra_set_pattern(ra, RA_PATTERN_OVERSIZE);
+		goto initial_readahead;
+	}
+
+	/*
+	 * sequential cache miss
+	 */
+	if (offset - prev_offset <= 1UL) {
+		ra_set_pattern(ra, RA_PATTERN_INITIAL);
+		goto initial_readahead;
+	}
+
+	/*
+	 * Query the page cache and look for the traces(cached history pages)
+	 * that a sequential stream would leave behind.
+	 */
+	if (mapping->backing_dev_info->context_readahead != 0 &&
+		try_context_readahead(mapping, ra, offset, req_size, max))
+		goto readit;
+
+	/*
+	 * Standalone, small read.
+	 * Read as is, and do not pollute the readahead state.
 	 */
+	ra_set_pattern(ra, RA_PATTERN_RANDOM);
+	ra->start = offset;
+	ra->size = req_size;
+	ra->async_size = 0;
+	goto readit;
+
+initial_readahead:
 	ra->start = offset;
 	ra->size = get_init_ra_size(req_size, max);
-	ra->async_size = ra->size > req_size ? ra->size - req_size : ra->size;
+	if (req_size <= max / 2)
+		ra->async_size = ra->size - req_size;
+	else
+		ra->async_size = ra->size;
 
 readit:
-	return ra_submit(ra, mapping, filp);
+	/*
+	 * Will this read will hit the readahead marker made by itself?
+	 */
+	if (offset + min(req_size, max) >
+			ra->start + ra->size - ra->async_size) {
+		ra->async_size = get_next_ra_size(ra, max);
+		ra->size += ra->async_size;
+	}
+
+	return ra_submit(mapping, filp, offset, req_size, ra,
+			 hit_readahead_marker);
 }
 
 /**
--- mm.orig/block/blk-sysfs.c
+++ mm/block/blk-sysfs.c
@@ -75,6 +75,24 @@ queue_requests_store(struct request_queu
 	return ret;
 }
 
+static ssize_t queue_cxt_ra_show(struct request_queue *q, char *page)
+{
+	unsigned int cra = q->backing_dev_info.context_readahead;
+
+	return queue_var_show(cra, (page));
+}
+
+static ssize_t
+queue_cxt_ra_store(struct request_queue *q, const char *page, size_t count)
+{
+	unsigned long cra;
+	ssize_t ret = queue_var_store(&cra, page, count);
+
+	q->backing_dev_info.context_readahead = cra;
+
+	return ret;
+}
+
 static ssize_t queue_ra_show(struct request_queue *q, char *page)
 {
 	int ra_kb = q->backing_dev_info.ra_pages << (PAGE_CACHE_SHIFT - 10);
@@ -163,6 +181,12 @@ static struct queue_sysfs_entry queue_re
 	.store = queue_requests_store,
 };
 
+static struct queue_sysfs_entry queue_cxt_ra_entry = {
+	.attr = {.name = "context_readahead", .mode = S_IRUGO | S_IWUSR },
+	.show = queue_cxt_ra_show,
+	.store = queue_cxt_ra_store,
+};
+
 static struct queue_sysfs_entry queue_ra_entry = {
 	.attr = {.name = "read_ahead_kb", .mode = S_IRUGO | S_IWUSR },
 	.show = queue_ra_show,
@@ -200,6 +224,7 @@ static struct queue_sysfs_entry queue_no
 static struct attribute *default_attrs[] = {
 	&queue_requests_entry.attr,
 	&queue_ra_entry.attr,
+	&queue_cxt_ra_entry.attr,
 	&queue_max_hw_sectors_entry.attr,
 	&queue_max_sectors_entry.attr,
 	&queue_iosched_entry.attr,
--- mm.orig/include/linux/backing-dev.h
+++ mm/include/linux/backing-dev.h
@@ -41,6 +41,7 @@ enum bdi_stat_item {
 
 struct backing_dev_info {
 	unsigned long ra_pages;	/* max readahead in PAGE_CACHE_SIZE units */
+	int context_readahead;	/* enable page cache context readahead */
 	unsigned long state;	/* Always use atomic bitops on this */
 	unsigned int capabilities; /* Device capabilities */
 	congested_fn *congested_fn; /* Function pointer if device is md/dm */
--- mm.orig/lib/radix-tree.c
+++ mm/lib/radix-tree.c
@@ -665,6 +665,43 @@ unsigned long radix_tree_next_hole(struc
 }
 EXPORT_SYMBOL(radix_tree_next_hole);
 
+/**
+ *	radix_tree_prev_hole    -    find the prev hole (not-present entry)
+ *	@root:		tree root
+ *	@index:		index key
+ *	@max_scan:	maximum range to search
+ *
+ *	Search backwards in the range [max(index-max_scan+1, 0), index]
+ *	for the first hole.
+ *
+ *	Returns: the index of the hole if found, otherwise returns an index
+ *	outside of the set specified (in which case 'index - return >= max_scan'
+ *	will be true). In rare cases of wrap-around, LONG_MAX will be returned.
+ *
+ *	radix_tree_next_hole may be called under rcu_read_lock. However, like
+ *	radix_tree_gang_lookup, this will not atomically search a snapshot of
+ *	the tree at a single point in time. For example, if a hole is created
+ *	at index 10, then subsequently a hole is created at index 5,
+ *	radix_tree_prev_hole covering both indexes may return 5 if called under
+ *	rcu_read_lock.
+ */
+unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
+				   unsigned long index, unsigned long max_scan)
+{
+	unsigned long i;
+
+	for (i = 0; i < max_scan; i++) {
+		if (!radix_tree_lookup(root, index))
+			break;
+		index--;
+		if (index == LONG_MAX)
+			break;
+	}
+
+	return index;
+}
+EXPORT_SYMBOL(radix_tree_prev_hole);
+
 static unsigned int
 __lookup(struct radix_tree_node *slot, void ***results, unsigned long index,
 	unsigned int max_items, unsigned long *next_index)
--- mm.orig/include/linux/radix-tree.h
+++ mm/include/linux/radix-tree.h
@@ -167,6 +167,8 @@ radix_tree_gang_lookup_slot(struct radix
 			unsigned long first_index, unsigned int max_items);
 unsigned long radix_tree_next_hole(struct radix_tree_root *root,
 				unsigned long index, unsigned long max_scan);
+unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
+				unsigned long index, unsigned long max_scan);
 int radix_tree_preload(gfp_t gfp_mask);
 void radix_tree_init(void);
 void *radix_tree_tag_set(struct radix_tree_root *root,
--- mm.orig/include/linux/fs.h
+++ mm/include/linux/fs.h
@@ -789,11 +789,55 @@ struct file_ra_state {
 					   there are only # of pages ahead */
 
 	unsigned int ra_pages;		/* Maximum readahead window */
+	unsigned int flags;
 	int mmap_miss;			/* Cache miss stat for mmap accesses */
 	loff_t prev_pos;		/* Cache last read() position */
 };
 
 /*
+ * Which policy makes decision to do the current read-ahead IO?
+ */
+#define RA_PATTERN_SHIFT	0
+#define RA_PATTERN_MASK		0xf
+
+enum readahead_pattern {
+	RA_PATTERN_NONE,
+	RA_PATTERN_INITIAL0,	/* start of file */
+	RA_PATTERN_INITIAL,
+	RA_PATTERN_SUBSEQUENT,
+	RA_PATTERN_HIT_MARKER,
+	RA_PATTERN_HAS_TRAIL,
+	RA_PATTERN_OVERSIZE,
+	RA_PATTERN_REVERSE,
+	RA_PATTERN_STRIDE,
+	RA_PATTERN_THRASH,
+	RA_PATTERN_MMAP_AROUND,
+	RA_PATTERN_FADVISE,
+	RA_PATTERN_RANDOM,
+	RA_PATTERN_ALL,		/* for collecting stats */
+	RA_PATTERN_MAX
+};
+
+static inline int ra_pattern(struct file_ra_state *ra)
+{
+	int pattern = (ra->flags >> RA_PATTERN_SHIFT) & RA_PATTERN_MASK;
+
+	if (pattern > RA_PATTERN_MAX)
+		pattern = RA_PATTERN_NONE;
+
+	return pattern;
+}
+
+/*
+ * Which method is issuing this read-ahead?
+ */
+static inline void ra_set_pattern(struct file_ra_state *ra, int pattern)
+{
+	ra->flags = (ra->flags & ~RA_PATTERN_MASK) |
+			(pattern << RA_PATTERN_SHIFT);
+}
+
+/*
  * Check if @index falls in the readahead windows.
  */
 static inline int ra_has_index(struct file_ra_state *ra, pgoff_t index)
--- /dev/null
+++ mm/mm/readahead_trace.c
@@ -0,0 +1,486 @@
+/*
+ * Readahead I/O tracing and accounting
+ *
+ * Copyright 2008 Wu Fengguang, Intel Corporation
+ * Subject to the GNU Public License, version 2 or later.
+ *
+ */
+
+#include <linux/sched.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/marker.h>
+#include <linux/kprobes.h>
+#include <linux/pagemap.h>
+#include <linux/seq_file.h>
+#include <linux/debugfs.h>
+#include <linux/mm.h>
+#include <linux/fs.h>
+#include <asm/atomic.h>
+#include <linux/stringify.h>
+#include <linux/version.h>
+
+int option_read_jprobes;
+int option_trace_enable;
+u32 option_trace_pid;
+u32 option_trace_ino;
+
+struct readahead_trace_probe {
+	const char *name;
+	const char *format;
+	marker_probe_func *probe_func;
+	int pattern;
+};
+
+enum ra_account {
+	/* number of readaheads */
+	RA_ACCOUNT_COUNT,
+	RA_ACCOUNT_EOF,
+	RA_ACCOUNT_SYNC,
+	/* number of pages */
+	RA_ACCOUNT_SIZE,
+	RA_ACCOUNT_ASIZE,
+	RA_ACCOUNT_ACTUAL,
+	/* end mark */
+	RA_ACCOUNT_MAX,
+};
+
+static const char * const ra_pattern_names[] = {
+	[RA_PATTERN_NONE]		= "none",
+	[RA_PATTERN_INITIAL0]		= "initial0",
+	[RA_PATTERN_INITIAL]		= "initial",
+	[RA_PATTERN_SUBSEQUENT]		= "subsequent",
+	[RA_PATTERN_HIT_MARKER]		= "marker",
+	[RA_PATTERN_HAS_TRAIL]		= "trail",
+	[RA_PATTERN_OVERSIZE]		= "oversize",
+	[RA_PATTERN_REVERSE]		= "reverse",
+	[RA_PATTERN_STRIDE]		= "stride",
+	[RA_PATTERN_THRASH]		= "thrash",
+	[RA_PATTERN_MMAP_AROUND]	= "mmap",
+	[RA_PATTERN_FADVISE]		= "fadvise",
+	[RA_PATTERN_RANDOM]		= "random",
+	[RA_PATTERN_ALL]		= "all",
+};
+
+static unsigned long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX];
+
+/*
+ * readahead tracing
+ */
+
+static void do_readahead_stats(struct address_space *mapping,
+			       struct file_ra_state *ra,
+			       int actual,
+			       int async,
+			       int pattern)
+{
+	pgoff_t lastpage = (i_size_read(mapping->host) - 1) >> PAGE_CACHE_SHIFT;
+
+	ra_stats[pattern][RA_ACCOUNT_COUNT]++;
+	ra_stats[pattern][RA_ACCOUNT_SIZE] += ra->size;
+	ra_stats[pattern][RA_ACCOUNT_ASIZE] += ra->async_size;
+	ra_stats[pattern][RA_ACCOUNT_ACTUAL] += actual;
+	if (ra->start + ra->size > lastpage)
+		ra_stats[pattern][RA_ACCOUNT_EOF]++;
+	if (!async)
+		ra_stats[pattern][RA_ACCOUNT_SYNC]++;
+}
+
+static void do_readahead_trace(struct address_space *mapping,
+			       struct file *filp,
+			       pgoff_t offset,
+			       unsigned long req_size,
+			       struct file_ra_state *ra,
+			       int actual,
+			       int async)
+{
+	int pattern = ra_pattern(ra);
+
+	BUILD_BUG_ON(ARRAY_SIZE(ra_pattern_names) != RA_PATTERN_MAX);
+
+	do_readahead_stats(mapping, ra, actual, async, pattern);
+	do_readahead_stats(mapping, ra, actual, async, RA_PATTERN_ALL);
+
+	if (!option_trace_enable)
+		return;
+	if (option_trace_pid && option_trace_pid != current->pid)
+		return;
+	if (option_trace_ino && option_trace_ino != mapping->host->i_ino)
+		return;
+
+	printk(KERN_DEBUG "readahead-%s(pid=%d(%s), dev=%02x:%02x(%s), "
+		"ino=%lu(%s), req=%lu+%lu, ra=%lu+%d-%d, async=%d) = %d\n",
+		ra_pattern_names[pattern],
+		current->pid, current->comm,
+		MAJOR(mapping->host->i_sb->s_dev),
+		MINOR(mapping->host->i_sb->s_dev),
+		mapping->host->i_sb->s_id,
+		mapping->host->i_ino,
+		filp->f_path.dentry->d_name.name,
+		offset, req_size,
+		ra->start, ra->size, ra->async_size,
+		async,
+		actual);
+}
+
+
+static void readahead_trace(void *readahead_trace_probe, void *call_data,
+			    const char *format, va_list *args)
+{
+	struct address_space *mapping;
+	struct file *filp;
+	pgoff_t offset;
+	unsigned long req_size;
+	struct file_ra_state *ra;
+	int actual;
+	int async;
+
+	mapping  = va_arg(*args, typeof(mapping));
+	filp     = va_arg(*args, typeof(filp));
+	offset   = va_arg(*args, typeof(offset));
+	req_size = va_arg(*args, typeof(req_size));
+	ra       = va_arg(*args, typeof(ra));
+	actual   = va_arg(*args, typeof(actual));
+	async    = va_arg(*args, typeof(async));
+
+	do_readahead_trace(mapping, filp, offset, req_size, ra, actual, async);
+}
+
+static void plain_readahead_trace(void *probe_private, void *call_data,
+				  const char *format, va_list *args)
+{
+	struct readahead_trace_probe *probe = probe_private;
+	struct address_space *mapping;
+	struct file *filp;
+	struct file_ra_state ra = {0};
+	int actual;
+
+	mapping  = va_arg(*args, typeof(mapping));
+	filp     = va_arg(*args, typeof(filp));
+	ra.start = va_arg(*args, typeof(ra.start));
+	ra.size  = va_arg(*args, typeof(ra.size));
+	actual   = va_arg(*args, typeof(actual));
+
+	ra_set_pattern(&ra, probe->pattern);
+
+	do_readahead_trace(mapping, filp, 0, 0, &ra, actual, 0);
+}
+
+/*
+ * read tracing
+ */
+
+static void read_trace(const char func_name[],
+		       struct file *file,
+		       loff_t pos, size_t count)
+{
+	struct inode *inode = file->f_mapping->host;
+
+	if (!option_trace_enable)
+		return;
+	if (option_trace_pid && option_trace_pid != current->pid)
+		return;
+	if (option_trace_ino && option_trace_ino != inode->i_ino)
+		return;
+
+	printk(KERN_DEBUG "%s(pid=%d(%s), dev=%02x:%02x(%s), ino=%lu(%s), "
+			"pos=%llu, count=%lu)\n",
+			func_name,
+			current->pid, current->comm,
+			MAJOR(inode->i_sb->s_dev),
+			MINOR(inode->i_sb->s_dev),
+			inode->i_sb->s_id,
+			inode->i_ino,
+			file->f_path.dentry->d_name.name,
+			pos, count);
+}
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,24)
+static ssize_t jdo_generic_file_splice_read(struct file *in,
+					    loff_t *ppos,
+					    struct pipe_inode_info *pipe,
+					    size_t len,
+					    unsigned int flags)
+{
+	read_trace("generic_file_splice_read", in, *ppos, len);
+	jprobe_return();
+	return 0;
+}
+#endif
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,25)
+static void jdo_do_generic_file_read(struct file *filp,
+				     loff_t *ppos,
+				     read_descriptor_t *desc,
+				     read_actor_t actor)
+{
+	read_trace("do_generic_file_read", filp, *ppos, desc->count);
+	jprobe_return();
+}
+#else
+static void jdo_do_generic_mapping_read(struct address_space *mapping,
+					struct file_ra_state *_ra,
+					struct file *filp,
+					loff_t *ppos,
+					read_descriptor_t *desc,
+					read_actor_t actor)
+{
+	read_trace("do_generic_mapping_read", filp, *ppos, desc->count);
+	jprobe_return();
+}
+#endif
+
+/*
+ * jprobes
+ */
+
+#define jprobe_entry(func)			\
+{						\
+	.entry = jdo_##func,			\
+	.kp.symbol_name = __stringify(func)	\
+}
+
+static struct jprobe jprobe_array[] = {
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,25)
+	jprobe_entry(do_generic_file_read),
+#else
+	jprobe_entry(do_generic_mapping_read),
+#endif
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,24)
+	jprobe_entry(generic_file_splice_read),
+#endif
+};
+
+static void insert_jprobes(void)
+{
+	int err;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(jprobe_array); i++) {
+		err = register_jprobe(jprobe_array + i);
+		if (err)
+			printk(KERN_ERR "unable to register probe %s\n",
+					jprobe_array[i].kp.symbol_name);
+	}
+}
+
+static void remove_jprobes(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(jprobe_array); i++)
+		unregister_jprobe(jprobe_array + i);
+}
+
+/*
+ * marker probes
+ */
+
+static struct readahead_trace_probe probe_array[] =
+{
+	{
+		.name = "readahead_generic",
+		.format = "%p %p %lu %lu %p %d %d",
+		.probe_func = readahead_trace,
+	},
+	{
+		.name = "readahead_mmap",
+		.format = "%p %p %lu %lu %d",
+		.probe_func = plain_readahead_trace,
+		.pattern = RA_PATTERN_MMAP_AROUND,
+	},
+	{
+		.name = "readahead_fadvise",
+		.format = "%p %p %lu %lu %d",
+		.probe_func = plain_readahead_trace,
+		.pattern = RA_PATTERN_FADVISE,
+	},
+};
+
+static void insert_marker(void)
+{
+	int err;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(probe_array); i++) {
+		err = marker_probe_register(probe_array[i].name,
+					    probe_array[i].format,
+					    probe_array[i].probe_func,
+					    probe_array + i);
+		if (err)
+			printk(KERN_ERR "unable to register probe %s\n",
+					probe_array[i].name);
+	}
+}
+
+static void remove_marker(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(probe_array); i++)
+		marker_probe_unregister(probe_array[i].name,
+					probe_array[i].probe_func,
+					probe_array + i);
+
+	synchronize_sched();
+}
+
+/*
+ * file operations for readahead_stats
+ */
+
+static int readahead_stats_show(struct seq_file *s, void *_)
+{
+	unsigned long i;
+	unsigned long count;
+
+	seq_printf(s, "%-10s %10s %10s %10s %10s %10s %10s\n",
+			"pattern",
+			"count", "sync_count", "eof_count",
+			"size", "async_size", "actual");
+
+	for (i = 0; i < RA_PATTERN_MAX; i++) {
+		count = ra_stats[i][RA_ACCOUNT_COUNT];
+		if (count == 0)
+			count = 1;
+
+		seq_printf(s, "%-10s %10lu %10lu %10lu %10lu %10lu %10lu\n",
+				ra_pattern_names[i],
+				ra_stats[i][RA_ACCOUNT_COUNT],
+				ra_stats[i][RA_ACCOUNT_SYNC],
+				ra_stats[i][RA_ACCOUNT_EOF],
+				ra_stats[i][RA_ACCOUNT_SIZE]   / count,
+				ra_stats[i][RA_ACCOUNT_ASIZE]  / count,
+				ra_stats[i][RA_ACCOUNT_ACTUAL] / count);
+	}
+
+	return 0;
+}
+
+static int readahead_stats_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, readahead_stats_show, NULL);
+}
+
+static ssize_t readahead_stats_write(struct file *file, const char __user *buf,
+				     size_t size, loff_t *offset)
+{
+	memset(ra_stats, 0, sizeof(ra_stats));
+	return size;
+}
+
+static struct file_operations readahead_stats_fops = {
+	.owner		= THIS_MODULE,
+	.open		= readahead_stats_open,
+	.write		= readahead_stats_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+/*
+ * file operations for read_jprobes
+ */
+
+static int read_jprobes_set(void *data, u64 val)
+{
+	if (val && !option_read_jprobes)
+		insert_jprobes();
+	else if (!val && option_read_jprobes)
+		remove_jprobes();
+
+	*(int *)data = val;
+	WARN_ON(data != &option_read_jprobes);
+
+	return 0;
+}
+static int read_jprobes_get(void *data, u64 *val)
+{
+	*val = *(int *)data;
+	return 0;
+}
+DEFINE_SIMPLE_ATTRIBUTE(read_jprobes_fops,
+			read_jprobes_get, read_jprobes_set, "%llu\n");
+
+/*
+ * debugfs entries: readahead/stats
+ */
+
+struct readahead_debug {
+	struct dentry *root;
+	struct dentry *stats;
+	struct dentry *trace_enable;
+	struct dentry *trace_pid;
+	struct dentry *read_jprobes;
+};
+static struct readahead_debug debug;
+
+static void remove_debugfs(void)
+{
+	debugfs_remove(debug.read_jprobes);
+	debugfs_remove(debug.trace_enable);
+	debugfs_remove(debug.trace_pid);
+	debugfs_remove(debug.stats);
+	debugfs_remove(debug.root);
+}
+
+static int create_debugfs(void)
+{
+	debug.root = debugfs_create_dir("readahead", NULL);
+	if (!debug.root)
+		goto error_debugfs;
+
+	debug.stats = debugfs_create_file("stats", 0644, debug.root,
+					  NULL, &readahead_stats_fops);
+	if (!debug.stats)
+		goto error_debugfs;
+
+	debug.trace_enable = debugfs_create_bool("trace_enable", 0644,
+						 debug.root,
+						 &option_trace_enable);
+	if (!debug.trace_enable)
+		goto error_debugfs;
+
+	debug.trace_pid = debugfs_create_u32("trace_pid", 0644, debug.root,
+					     &option_trace_pid);
+	if (!debug.trace_pid)
+		goto error_debugfs;
+
+	debug.read_jprobes = debugfs_create_file("read_jprobes", 0644,
+						 debug.root,
+						 &option_read_jprobes,
+						 &read_jprobes_fops);
+	if (!debug.read_jprobes)
+		goto error_debugfs;
+
+	return 0;
+
+error_debugfs:
+	printk(KERN_ERR "readahead: failed to create debugfs directory\n");
+	return -ENOMEM;
+}
+
+/*
+ * module init/exit
+ */
+
+static int __init readahead_probe_init(void)
+{
+	create_debugfs();
+	insert_marker();
+	return 0;
+}
+
+static void __exit readahead_probe_exit(void)
+{
+	remove_jprobes();
+	remove_marker();
+	remove_debugfs();
+}
+
+module_init(readahead_probe_init);
+module_exit(readahead_probe_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Wu Fengguang");
+MODULE_DESCRIPTION("readahead tracing and accounting");
--- mm.orig/mm/Kconfig
+++ mm/mm/Kconfig
@@ -208,3 +208,21 @@ config VIRT_TO_BUS
 
 config MMU_NOTIFIER
 	bool
+
+config READAHEAD_TRACE
+	tristate "Readahead tracing"
+	select MARKER
+	select KPROBES
+	select DEBUGFS
+	help
+	 This module injects code to show detailed readahead traces and do
+	 readahead events accounting.
+
+	 To actually get the data:
+
+	 # mount -t debugfs none /sys/kernel/debug
+
+	 After that you can do the following:
+
+	 # cat /sys/kernel/debug/readahead/stats     # check counters
+	 # echo > /sys/kernel/debug/readahead/stats  # reset counters
--- mm.orig/mm/Makefile
+++ mm/mm/Makefile
@@ -35,3 +35,4 @@ obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
 
+obj-$(CONFIG_READAHEAD_TRACE) += readahead_trace.o
--- mm.orig/mm/filemap.c
+++ mm/mm/filemap.c
@@ -982,7 +982,7 @@ static void shrink_readahead_size_eio(st
  * This is really ugly. But the goto's actually try to clarify some
  * of the logic when it comes to error handling etc.
  */
-static void do_generic_file_read(struct file *filp, loff_t *ppos,
+void do_generic_file_read(struct file *filp, loff_t *ppos,
 		read_descriptor_t *desc, read_actor_t actor)
 {
 	struct address_space *mapping = filp->f_mapping;

--6TrnltStXW4iwmi0--
