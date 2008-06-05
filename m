From: Norman Weathers <norman.r.weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Subject: Re: Problems with large number of clients and reads
Date: Thu, 05 Jun 2008 13:54:32 -0500
Message-ID: <1212692072.25393.6.camel@hololw58>
References: <1212519001.24900.14.camel@hololw58>
	 <76bd70e30806040649h53ab5d66x8c3423c551e94f77@mail.gmail.com>
	 <1212588796.27117.4.camel@hololw58>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailman2.ppco.com ([138.32.41.14]:39225 "EHLO mailman2.ppco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbYFESyi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2008 14:54:38 -0400
Received: from bvlextrd2.conoco.net (bvlextrd2.conoco.net [138.32.41.13])
	by mailman2.ppco.com (Switch-3.2.7/Switch-3.2.7) with ESMTP id m55Isaxb032450
	for <linux-nfs@vger.kernel.org>; Thu, 5 Jun 2008 13:54:36 -0500
In-Reply-To: <1212588796.27117.4.camel@hololw58>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-06-04 at 09:13 -0500, Norman Weathers wrote:
> On Wed, 2008-06-04 at 09:49 -0400, Chuck Lever wrote:
> > Hi Norman-
> > 
> > On Tue, Jun 3, 2008 at 2:50 PM, Norman Weathers
> > <norman.r.weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org> wrote:
> > > Hello all,
> > >
> > > We are having some issues with some high throughput servers of ours.
> > >
> > > Here is the issue, we are using a vanilla 2.6.22.14 kernel on a node
> > > with 2 Dual Core Intels (3 GHz) and 16 GB of ram.  The files that are
> > > being served are around 2 GB each, and there are usually 3 to 5 of them
> > > being read, so once read they fit into memory nicely, and when all is
> > > working correctly, we have a perfectly filled cache, with almost no disk
> > > activity.
> > >
> > > When we have large NFS activity (say, 600 to 1200 clients) connecting to
> > > the server(s), they can get into a state where they are using up all of
> > > memory, but they are dropping cache.  slabtop is showing 13 GB of memory
> > > being used by the size-4096 slab object.  We have two ethernet channels
> > > bonded, so we see in excess of 240 MB/s of data flowing out of the box,
> > > and all of the sudden, disk activity has risen to 185 MB/s.  This
> > > happens if we are using 8 or more nfs threads.  If we limit the threads
> > > to 6 or less, this doesn't happen.  Of course, we are starving clients,
> > > but at least the jobs that my customers are throwing out there are
> > > progressing.  The question becomes, what is causing the memory to be
> > > used up by the slab size-4096 object?  Why when all of the sudden a
> > > bunch of clients ask for data does this object grow from 100 MB to 13
> > > GB?  I have set the memory settings to something that I thought was
> > > reasonable.
> > >
> > > Here is some more of the particulars:
> > >
> > > sysctl.conf tcp memory settings:
> > >
> > > # NFS Tuning Parameters
> > > sunrpc.udp_slot_table_entries = 128
> > > sunrpc.tcp_slot_table_entries = 128
> > 
> > I don't have an answer to your size-4096 question, but I do want to
> > note that setting the slot table entries sysctls has no effect on NFS
> > servers.  It's a client-only setting.
> > 
> 
> 
> Ok.
> 
> > Have you tried this experiment on a server where there are no special
> > memory tuning sysctls?
> 
> Unfortunately, no.  I can try it today.
> 


I tried the test with no special memory settings, and I still see the
same issue.  I also have noticed that even with only 3 threads running,
I can still have times where 11 GB of memory is being used for buffer
and not for disk cache.  It just seems like memory is being used up if
we have a lot of requests from a lot of clients at once...

> > 
> > Can you describe the characteristics of your I/O workload (the
> > random/sequentialness of it, the size of the I/O requests, the
> > burstiness, etc)?
> 
> The I/O pattern is somewhat random, but when functioning properly, the
> files are small enough to fit into cache.  Size per record is ~ 10k (can
> be up to 64k).
> 
> > 
> > What mount options are you using on the clients, and what are your
> > export options on the server?  (Which NFS version are you using)?
> 
> NFSv3.  Client mount options are:
> rw,vers=3,rsize=1048576,wsize=1048576,acregmin=1,acregmax=15,acdirmin=0,acdirmax=0,hard,intr,proto=tcp,timeo=600,retrans=2,addr=hoeptt01
> 
> 
> > 
> > And finally, the output of uname -a on the server would be good to include.
> > 
> 
> Linux hoeptt06 2.6.22.14.SLAB #5 SMP Wed Jan 23 15:45:40 CST 2008 x86_64
> x86_64 x86_64 GNU/Linux
> 
> 
> > > vm.overcommit_ratio = 80
> > >
> > > net.core.rmem_max=524288
> > > net.core.rmem_default=262144
> > > net.core.wmem_max=524288
> > > net.core.wmem_default=262144
> > > net.ipv4.tcp_rmem = 8192 262144 524288
> > > net.ipv4.tcp_wmem = 8192 262144 524288
> > > net.ipv4.tcp_sack=0
> > > net.ipv4.tcp_timestamps=0
> > > vm.min_free_kbytes=50000
> > > vm.overcommit_memory=1
> > > net.ipv4.tcp_reordering=127
> > >
> > > # Enable tcp_low_latency
> > > net.ipv4.tcp_low_latency=1
> > >
> > > Here is a current reading from a slabtop of a system where this error is
> > > happening:
> > >
> > > 3007154 3007154 100%    4.00K 3007154        1  12028616K size-4096
> > >
> > > Note the size of the object cache, usually it is 50 - 100 MB (I have
> > > another box with 32 threads and the same settings which is bouncing
> > > between 50 and 128 MB right now).
> > >
> > > I have a lot of client boxes that need access to these servers, and
> > > would really benefit from having more threads, but if I increase the
> > > number of threads, it pushes everything out of cache, forcing re-reads,
> > > and really slows down our jobs.
> > >
> > > Any thoughts on this?
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
