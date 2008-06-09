From: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Subject: RE: Problems with large number of clients and reads
Date: Mon, 9 Jun 2008 09:19:03 -0500
Message-ID: <0122F800A3B64C449565A9E8C2977010155587@hoexmb9.conoco.net>
References: <1212519001.24900.14.camel@hololw58> <20080606160922.GG30863@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailman1.ppco.com ([138.32.41.4]:45795 "EHLO mailman1.ppco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759266AbYFIOTN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2008 10:19:13 -0400
Received: from bvlextrd1.conoco.net (bvlextrd1.conoco.net [138.32.41.12])
	by mailman1.ppco.com (Switch-3.2.7/Switch-3.2.7) with ESMTP id m59EJAgn020517
	for <linux-nfs@vger.kernel.org>; Mon, 9 Jun 2008 09:19:10 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




-----Original Message-----
From: J. Bruce Fields [mailto:bfields@fieldses.org]
Sent: Fri 6/6/2008 11:09 AM
To: Weathers, Norman R.
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problems with large number of clients and reads
 
On Tue, Jun 03, 2008 at 01:50:01PM -0500, Norman Weathers wrote:
> Hello all,
> 
> We are having some issues with some high throughput servers of ours.
> 
> Here is the issue, we are using a vanilla 2.6.22.14 kernel on a node
> with 2 Dual Core Intels (3 GHz) and 16 GB of ram.  The files that are
> being served are around 2 GB each, and there are usually 3 to 5 of them
> being read, so once read they fit into memory nicely, and when all is
> working correctly, we have a perfectly filled cache, with almost no disk
> activity.
> 
> When we have large NFS activity (say, 600 to 1200 clients) connecting to
> the server(s), they can get into a state where they are using up all of
> memory, but they are dropping cache.  slabtop is showing 13 GB of memory
> being used by the size-4096 slab object.  We have two ethernet channels
> bonded, so we see in excess of 240 MB/s of data flowing out of the box,
> and all of the sudden, disk activity has risen to 185 MB/s.  This
> happens if we are using 8 or more nfs threads.  If we limit the threads
> to 6 or less, this doesn't happen.  Of course, we are starving clients,
> but at least the jobs that my customers are throwing out there are
> progressing.  The question becomes, what is causing the memory to be
> used up by the slab size-4096 object?  Why when all of the sudden a
> bunch of clients ask for data does this object grow from 100 MB to 13
> GB?  I have set the memory settings to something that I thought was
> reasonable.
> 
> Here is some more of the particulars:
> 
> sysctl.conf tcp memory settings:
> 
> # NFS Tuning Parameters
> sunrpc.udp_slot_table_entries = 128
> sunrpc.tcp_slot_table_entries = 128
> vm.overcommit_ratio = 80
> 
> net.core.rmem_max=524288
> net.core.rmem_default=262144
> net.core.wmem_max=524288
> net.core.wmem_default=262144
> net.ipv4.tcp_rmem = 8192 262144 524288
> net.ipv4.tcp_wmem = 8192 262144 524288
> net.ipv4.tcp_sack=0
> net.ipv4.tcp_timestamps=0
> vm.min_free_kbytes=50000
> vm.overcommit_memory=1
> net.ipv4.tcp_reordering=127
> 
> # Enable tcp_low_latency
> net.ipv4.tcp_low_latency=1
> 
> Here is a current reading from a slabtop of a system where this error is
> happening:
> 
> 3007154 3007154 100%    4.00K 3007154        1  12028616K size-4096
> 
> Note the size of the object cache, usually it is 50 - 100 MB (I have
> another box with 32 threads and the same settings which is bouncing
> between 50 and 128 MB right now).
> 
> I have a lot of client boxes that need access to these servers, and
> would really benefit from having more threads, but if I increase the
> number of threads, it pushes everything out of cache, forcing re-reads,
> and really slows down our jobs.
> 
> Any thoughts on this?



>I'd've thought that suggests a leak of memory allocated by kmalloc().

>Does the size-4096 cache decrease eventually, or does it stay that large
>until you reboot?



>--b.



I would agree that it "looks" like a memory leak.  If I restart NFS, the size-4096 cache
goes from 12 GB to under 50 MB, but then depending upon how hard the box is utilized, it
starts to climb back up.  I have seen it climb back up to 3 or 4 GB right after the
restart, but that is much better because the regular disk cache will grow from the 2 GB
that it was pressured into back to 5 or 8 GB, so all of the files have been reread into
memory and things are progressing smoothly.  It is weird.  I really think that this has 
to do with a lot of connections happening at once, because I can run slabtop and see a
node that is running full out, but only have a couple hundred megs of the size-4096 slab
being used, and then turn around and see another node that is pushing out 245 MB/s and
all of the sudden using over 12 GB of the size-4096.  It is very odd...  If I lower the
number of threads from a usable 64 to a low of 3 threads, I have less of a chance of the
servers going haywire, to the point of being so loaded they may crash or you cannot 
contact them over the network (fortunately, I have serial on these boxes so that I can
get on the nodes if they reach that point).  If I run 8 threads, and with enough 
clients, I can bring down one of these servers. size-4096 goes through the roof, and
depending on the hour of the day, the server can either crash or becomes unresponsive.

Norman
