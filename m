From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [patch 10/14] sunrpc: Reorganise the queuing of cache upcalls.
Date: Fri, 09 Jan 2009 13:40:47 +1100
Message-ID: <4966B92F.8060008@melbourne.sgi.com>
References: <20090108082510.050854000@sgi.com> <20090108082604.517918000@sgi.com> <20090108195747.GB19312@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:59936 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751538AbZAICsi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 21:48:38 -0500
In-Reply-To: <20090108195747.GB19312@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Jan 08, 2009 at 07:25:20PM +1100, Greg Banks wrote:
>   
>> [...]
>> Firstly, the kernel code assumes that each reader uses a separate
>> struct file; because rpc.mountd fork()s *after* opening the cache
>> file descriptor this is not true.  Thus the single struct file and
>> the single rp->offset field are shared between multiple threads.
>> Unfortunately rp->offset is not maintained in a safe manner.  This can
>> lead to the BUG_ON() in cache_read() being tripped.
>>     
>
> Hm, have you seen this happen?
>   

Yes, at last count at least a half-dozen times with two separate
customers.  For future reference, the SGI bug report is PV 988959. 
Here's a representative crash report:

System dropped to KDB with following crash string:

    <4>kernel BUG at net/sunrpc/cache.c:578!
    <4>rpc.mountd[50696]: bugcheck! 0 [1]
    <4>nfsd: request from insecure port (10.150.3.54:911)!
    <4>Modules linked in: af_packet svcxprt_rdma nfsd exportfs lockd<4>nfsd: request from insecure port (10.150.3.59:838)!
    <4> nfs_acl sunrpc rdma_ucm rdma_cm iw_cm ib_addr ib_uverbs ib_umad iw_cxgb3 cxgb3 mlx4_ib mlx4_core iscsi_trgt crc32c libcrc32c mst_pciconf mst_pci binfmt_misc button ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables scsi_dump dump_blockdev dump_gzi zlib_deflate dump xfs_quota xfs_dmapi dmapi<4>nfsd: request from insecure port (10.150.3.84:744)!
    <4>nfsd: request from insecure port (10.150.3.68:768)!
    <4> nls_iso8859_1 loop sgi_xvm sgi_os_lib ib_ipoib ib_cm ib_sa ipv6 kdbm_vm kdbm_task kdbm_sched kdbm_pg mmtimer mca_recovery arsess xpmem xp numatools mspec shpchp pci_hotplug ib_mthca ide_cd ib_mad ehci_hcd ohci_hcd cdrom ib_core tg3 usbcore pata_sil680siimage xfs fan thermal processor ide_generic qla2xxx firmware_class mptfc scsi_transport_fc mptspi scsi_transport_spi sg mptsas mptscsih mptbase scsi_transport_sas qla1280 sata_vsc libata sgiioc4 ioc4 sd_mod scsi_mod ide_disk ide_core
    <4>
    <4>Pid: 50696, CPU 1, comm:           rpc.mountd
    <4>psr : 0000101008526010 ifs : 800000000000050d ip  : [<a000000214362120>]    Tainted: P U
    <4>ip is at cache_read+0x2a0/0x840 [sunrpc]
    <4>unat: 0000000000000000 pfs : 000000000000050d rsc : 0000000000000003
    <4>rnat: 0000000000000000 bsps: 0000000000000000 pr  : 95a95666659aa959
    <4>ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
    <4>csd : 0000000000000000 ssd : 0000000000000000
    <4>b0  : a000000214362120 b6  : a000000100431640 b7  : a00000010000c320
    <4>f6  : 1003e00000000000000a0 f7  : 1003e20c49ba5e353f7cf
    <4>f8  : 1003e00000000000004e2 f9  : 1003e000000000fa00000
    <4>f10 : 1003e000000003b9aca00 f11 : 1003e431bde82d7b634db
    <4>r1  : a000000100b31db0 r2  : e000006003118e6b r3  : a00000010087fad8
    <4>r8  : 0000000000000029 r9  : ffffffffffff8e68 r10 : ffffffffffff0028
    <4>r11 : 8000020310000380 r12 : e0000171ebb77e20 r13 : e0000171ebb70000
    <4>r14 : 0000000000004000 r15 : a00000010087fad8 r16 : a00000010087fae0
    <4>r17 : e0000171e575fe18 r18 : 0000000000000027 r19 : 0000020000000000
    <4>r20 : 0fd0000000000000 r21 : 80000001fdc00820 r22 : 0000000000000004
    <4>r23 : 0000000000000820 r24 : 80000001fdc00000 r25 : 0000000000000820
    <4>r26 : 0000000000000000 r27 : e000006003118e6b r28 : e000006003118e68
    <4>r29 : ffffffffffff8e68 r30 : e000006003120000 r31 : ffffffffffff0028
    <4>
    <4>Call Trace:
    <4> [<a000000100014ce0>] show_stack+0x40/0xa0
    <4>                                sp=e0000171ebb779b0 bsp=e0000171ebb71478
    <4> [<a0000001000155e0>] show_regs+0x840/0x880
    <4>                                sp=e0000171ebb77b80 bsp=e0000171ebb71420
    <4> [<a000000100039460>] die+0x1c0/0x360
    <4>                                sp=e0000171ebb77b80 bsp=e0000171ebb713d0
    <4> [<a000000100039650>] die_if_kernel+0x50/0x80
    <4>                                sp=e0000171ebb77ba0 bsp=e0000171ebb713a0
    <4> [<a000000100559b80>] ia64_bad_break+0x260/0x540
    <4>                                sp=e0000171ebb77ba0 bsp=e0000171ebb71378
    <4> [<a00000010000cb20>] ia64_leave_kernel+0x0/0x280
    <4>                                sp=e0000171ebb77c50 bsp=e0000171ebb71378
    <4> [<a000000214362120>] cache_read+0x2a0/0x840 [sunrpc]
    <4>                                sp=e0000171ebb77e20 bsp=e0000171ebb71310
    <4> [<a0000001001615a0>] vfs_read+0x240/0x3e0
    <4>                                sp=e0000171ebb77e20 bsp=e0000171ebb712c0
    <4> [<a000000100161e10>] sys_read+0x70/0xe0
    <4>                                sp=e0000171ebb77e20 bsp=e0000171ebb71248
    <4> [<a00000010000c980>] ia64_ret_from_syscall+0x0/0x20
    <4>                                sp=e0000171ebb77e30 bsp=e0000171ebb71248
    <4> [<a000000000010620>] __kernel_syscall_via_break+0x0/0x20
    <4>                                sp=e0000171ebb78000 bsp=e0000171ebb71248


Rpc.mountd is doing a read() on /proc/net/rpc/auth.unix.ip/channel.  The
BUG_ON() tripped is here:

    553 static ssize_t
    554 cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
    555 {
    556         struct cache_reader *rp = filp->private_data;
    557         struct cache_request *rq;
    558         struct cache_detail *cd = PDE(filp->f_dentry->d_inode)->data;
    ...
    567         spin_lock(&queue_lock);
    568         /* need to find next request */
    569         while (rp->q.list.next != &cd->queue &&
    570                list_entry(rp->q.list.next, struct cache_queue, list)
    571                ->reader) {
    572                 struct list_head *next = rp->q.list.next;
    573                 list_move(&rp->q.list, next);
    574         }
    575         if (rp->q.list.next == &cd->queue) {
    576                 spin_unlock(&queue_lock);
    577                 up(&queue_io_sem);
    578                 BUG_ON(rp->offset);  <----- SPLAT!
    579                 return 0;
    580         }


Note there's one obvious problem: the BUG_ON() is testing the condition
(rp->offset) outside any locking.  In at least one dump rp->offset is
actually zero by the time the page got saved to the dump device, so I
suspect a race here.

> All the current upcalls are small enough (and mountd's default read
> buffer large enough) that messages should always be read in one gulp.
>   
Indeed.  This is why SGI shipped a workaround, comprising a backported
commit to mountd to use the larger read buffer size and thus avoid
triggering the partial read path.  Unfortunately this seems not to have
helped.  I *suspect* that the BUG_ON() is racing with another thread
running through this code later in the same function:

    596                 if (copy_to_user(buf, rq->buf + rp->offset, count))
    597                         goto out;
    598                 rp->offset += count;
    599                 if (rp->offset >= rq->len) {
    600                         rp->offset = 0;
    601                         spin_lock(&queue_lock);


Note that even if userspace does full sized reads, rp->offset briefly
becomes nonzero in code which is serialised by queue_io_mutex.  The
BUG_ON() is not serialised by that lock.

The two customers to which this is occurring have in common a very large
set of NFS clients (>6000 in one case) all mounting over TCP/IPoIB at
the same time.  This puts a lot of stress on the auth.unix.ip cache :-/

>   
>> Secondly, even if the kernel code worked perfectly it's sharing
>> a single offset between multiple reading rpc.mountd threads.
>>     
>
> I made what I suspect is a similar patch a while ago and never got
> around to submitting it.  (Arrgh!  Bad me!)
Heh, I do way too much of the same thing :-(

>   Appended below if it's of
> any use to you to compare.  (Happy to apply either your patch or mine
> depending which looks better; I haven't tried to compare carefully.)
>   

Ok, I'll take a look at yours.
> [...]
>     
>     You can mitigate the problem by reading from a single file descriptor
>     that's shared between processes (as mountd currently does), but that
>     requires the read to always provide a buffer large enough to get the
>     whole request in one atomic read.  That's less practical for gss
>     init_sec_context calls, which could vary in size from a few hundred
>     bytes to 100k or so.
>   
I'm confused -- doesn't the current cache_make_upcall() code allocate a
buffer of length PAGE_SIZE and not allow it to be resized?
>     [...]
> -struct cache_queue {
> -	struct list_head	list;
> -	int			reader;	/* if 0, then request */
> -};
>  struct cache_request {
> -	struct cache_queue	q;
> +	struct list_head	list;
>  	struct cache_head	*item;
>  	char			* buf;
> +	int			offset;
>  	int			len;
> -	int			readers;
> -};
> -struct cache_reader {
> -	struct cache_queue	q;
> -	int			offset;	/* if non-0, we have a refcnt on next request */
>  };
>  
>   
Looking very similar so far.

>  static ssize_t
>  cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
>  {
> -	struct cache_reader *rp = filp->private_data;
> -	struct cache_request *rq;
> +	struct cache_request *rq = filp->private_data;
>  	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
> +	struct list_head *queue = &cd->queue;
>  	int err;
>  
>  	if (count == 0)
> @@ -711,60 +703,45 @@ cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
>  	mutex_lock(&queue_io_mutex); /* protect against multiple concurrent
>  			      * readers on this file */
>   

Ah, so you still have a single global lock which is serialising all
reads and writes to all caches.

Also, I think you'd want to sample filp->private_data after taking
queue_io_mutex.
> +	if (rq == NULL) {
>  		mutex_unlock(&queue_io_mutex);
> -		BUG_ON(rp->offset);
>   

Good riddance to that BUG_ON().
> -		return 0;
> +		return -EAGAIN;
>  	}
> -	rq = container_of(rp->q.list.next, struct cache_request, q.list);
> -	BUG_ON(rq->q.reader);
> -	if (rp->offset == 0)
> -		rq->readers++;
> -	spin_unlock(&queue_lock);
>  
> -	if (rp->offset == 0 && !test_bit(CACHE_PENDING, &rq->item->flags)) {
> +	if (!test_bit(CACHE_PENDING, &rq->item->flags))
>  		err = -EAGAIN;
> -		spin_lock(&queue_lock);
> -		list_move(&rp->q.list, &rq->q.list);
> -		spin_unlock(&queue_lock);
> -	} else {
> -		if (rp->offset + count > rq->len)
> -			count = rq->len - rp->offset;
> +	else {
> +		if (rq->offset + count > rq->len)
> +			count = rq->len - rq->offset;
>  		err = -EFAULT;
> -		if (copy_to_user(buf, rq->buf + rp->offset, count))
> +		if (copy_to_user(buf, rq->buf + rq->offset, count))
>  			goto out;
>   

Ok, so you try to keep partial read support but move the offset into the
upcall request itself.  Interesting idea.

I think partial reads are Just Too Hard to do properly, i.e. without
risk of racy message corruption under all combinations of message size
and userspace behaviour .  In particular I think your code will corrupt
upcall data if multiple userspace threads race to do partial reads on
the same struct file (as rpc.mountd is doing at SGI's customer sites).

For the same reasons I think the FIONREAD support is utterly pointless
(even though I preserved it).

But I still don't understand how this 100K message size number for gssd
can happen?  If that's really necessary then the design equation changes
considerably.  This seems to be the most significant difference between
our patches.

A smaller issue is that you keep a single list and use the value of the
CACHE_PENDING bit to tell the difference between states.  I think this
could be made to work; however my technique of using two lists makes
most of the code even simpler at the small cost of having to do two list
searches in queue_loose().

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

