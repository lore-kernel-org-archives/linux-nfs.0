From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: svcrdma/xprtrdma fast memory registration questions
Date: Fri, 03 Oct 2008 16:39:02 -0400
Message-ID: <RTPCLUEXC2-PRDkYRpw00000132@RTPMVEXC1-PRD.hq.netapp.com>
References: <1222357183.32577.34.camel@sale659>
 <RTPCLUEXC2-PRDFRaqb00000032@RTPMVEXC1-PRD.hq.netapp.com>
 <1222466867.17537.70.camel@sale659>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Jim Schutt" <jaschut@sandia.gov>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56164 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955AbYJCUjS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Oct 2008 16:39:18 -0400
In-Reply-To: <1222466867.17537.70.camel@sale659>
References: <1222357183.32577.34.camel@sale659>
 <RTPCLUEXC2-PRDFRaqb00000032-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <1222466867.17537.70.camel@sale659>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim, sorry for the long delay in replying. I've been working heavily on
the NFS/RDMA client this week. The new version is ready to go with
just a little more testing.

Your message has a lot to discuss, it might be best to take the
details offline, but I'll touch on the high points below:

At 06:07 PM 9/26/2008, Jim Schutt wrote:
>Hi Tom,
>
>On Fri, 2008-09-26 at 07:14 -0600, Talpey, Thomas wrote:
>> At 11:39 AM 9/25/2008, Jim Schutt wrote:
>> >Hi,
>> >
>> >I've been giving the fast memory registration NFS RDMA
>> >patches a spin, and I've got a couple questions.
>> 
>> Your questions are mainly about the client, so I'll jump in here too...
>
>Thanks for replying - I appreciate the opportunity to
>discuss the issues I think I might be seeing.
>The theme of my interest is to increase performance by
>reducing the number of cycles spent on bookkeeping per 
>byte of RPC payload.  I've been concentrating my testing
>on single-client performance so far.
>
>> 
>> >
>> >AFAICS the default xprtrdma memory registration model
>> >is still RPCRDMA_ALLPHYSICAL; I had to
>> >  "echo 6 > /proc/sys/sunrpc/rdma_memreg_strategy"
>> >prior to a mount to get fast registration.  Given that fast
>> >registration has better security properties for iWARP, and
>> >the fallback is RPCRDMA_ALLPHYSICAL if fast registration is
>> >not supported, is it more appropriate to have RPCRDMA_FASTREG
>> >be the default?
>> 
>> Possibly. At this point we don't have enough experience with FASTREG
>> to know whether it's better. For large-footprint memory on the server
>> with a Chelsio interconnect, it's required, but on Infiniband adapters,
>> there are more degrees of freedom and historically ALLPHYS works best.
>
>I've been working with Chelsio adapters mostly, but I do have
>Mellanox MT25208 HCAs in my test boxes, and I can probably get
>some newer HCAs that support FASTREG.  Can you fill me in on
>things to look at when comparing FASTREG vs. ALLPHYS on IB?

We don't have any experience yet with FASTREG on Infiniband, to
my knowledge the firmware for those cards hasn't been released
yet. All our work has been on the Chelsio. With the new client and
server code, the initial results are that the throughputs are quite
similar. What we don't know yet is how the CPU overhead compares,
nor what the latencies/IOPS come out as. Suffice it to say we are
optimistic.

FASTREG is preferable to ALLPHYS in two main ways. One, it's "safer"
in that it only exposes the exact buffers which are the target of
each i/o. This is more of a system integrity concern than a hacking
one for most users, what it means is that a bug in your server won't
cause problems outside of the transfer.

The second advantage is reduced RDMA wire operations. ALLPHYS
cannot perform scatter/gather on a single RDMA op, because there
is no mapping available on the NIC. In effect, each physical page is
a separate region. With FASTREG, it's possible to coalesce many or
all of the pages, making for single large transfers.

On low-latency high-speed network such as IB however, this can
make less of a difference than one would expect. Especially for
reads, which employ the ultrafast RDMA write, there is little penalty
for extra ops. So, we need more data to measure this difference.

>
>> 
>> Also, at this point we don't know that FASTREG is really FASTer. :-)
>> Frankly, I hate calling things "fast" or "new", there's always something
>> "faster" or "newer". But the OFA code uses this name. In any case,
>> the codepath still needs testing and performance evaluation before
>> we make it a default.
>
>FWIW, in my very limited testing so far on Chelsio, FASTREG and 
>ALLPHYS run at about the same speed.  And I've done no testing
>yet where I increased RPCRDMA_MAX_DATA_SEGS and use FASTREG.
>
>Caveat: my testing to date is all streaming reads/writes with dd.
>It turns out we have important use cases here for which that
>testing methodology is a good model.  See below for more on my 
>testing and results.

Well, "dd" is not a very good benchmark. It's generally single-threaded,
and uses the buffer cache and VM to manage its writebehind and
concurrency. If however, that's how your apps work, perhaps it's ok.
I might suggest iozone, however.

>> 
>> 
>> >Second, it seems that the number of pages in a client fast
>> >memory registration is still limited to RPCRDMA_MAX_DATA_SEGS.
>> >So on a client write, without fast registration I get
>> >RPCRDMA_MAX_DATA_SEGS RDMA reads of 1 page each, whereas with
>> >fast registration I get 1 RDMA read of RPCRDMA_MAX_DATA_SEGS
>> >pages.
>> 
>> Yes, the client is currently limited to this many segments. You can raise
>> the number by recompiling, but I don't recommend it, the client gets rather
>> greedy with per-mount memory. I do plan to remedy this.
>
>I've done this for RPCRDMA_MAX_DATA_SEGS = 16.  That's how I 
>discovered an issue that one of Tom Tucker's recent patches fixed.
>(http://marc.info/?l=linux-nfs&m=122149449727121&w=2)

Ok.

>
>Let me describe the testing I've done so far.
>
>I've got two test boxes running Fedora 8.  

Fedora 8 with an updated kernel, I assume. What rev?

>
>The client is a Tyan S2895 w/ 2.6 GHz Opterons and 4 GiB memory. 
>It has a Mellanox MT25208 and a Chelsio T310, both in x16 PCIe slots.  
>
>The server is a Tyan S2915 w/ 2.6 GHz dual-core Opterons and 
>4 GiB memory.  It has the same Mellanox/Chelsio adapters in 
>x16 slots, and two 3ware 9650SE RAID controllers, each in 
>x8 slots, driving 16 Seagate 7200.10 (ST3250620AS) discs.
>I use software RAID0 across all 16 spindles w/64 KiB chunk
>size, and an XFS filesystem tuned for 64 KiB stripes.

A-ha. Okay, XFS is good, but now i know why you want larger
write size. XFS performs much better with stripe-sized operations.

>I run 64 instances of nfsd.

This may be an issue, especially on an Opteron. Let's keep that
in mind. I'll be interested in your kernel .config.

>
>Note that although my boxes have 4 GiB installed, on advice of
>Steve Wise I've been limiting it at boot to 2 GiB to avoid the 
>memory registration issues you allude to above.

Yep. FASTREG will fix that however.

>
>So I mount with:
>mount.nfs 192.168.17.111:/mnt/xfs.0 /mnt/xfs.0-iW -i -o 
>rdma,port=2050,async,rsize=65536,wsize=65536
>mount.nfs 192.168.18.111:/mnt/xfs.0 /mnt/xfs.0-IB -i -o 
>rdma,port=2050,async,rsize=65536,wsize=65536
>
>and test with:
>dd conv=sync if=/dev/zero of=/mnt/xfs.0-iW/zero bs=64k count=128k
>
>A couple of weeks ago I got the following performance on stock
>2.6.26.3:
>   SDR IB:                   185 x 10^6 B/s
>   10 Gb/s iWARP:            225 x 10^6 B/s
>   10 Gb/s TCP, host stack:  105 x 10^6 B/s
>
>One problem is on my gear my results are quite variable:
>today I rebooted into the same kernel I used to get the 
>above.  I saw anywhere from 180 to 245 MB/s for iWARP, and
>from 170 to 215 MB/s on SDR IB.  The variability makes it 
>hard to draw conclusions :(

Have you measured local write performance? Does it vary?

>
>I retested with RPCRDMA_MAX_DATA_SEGS = 16.  Note that in
>this testing for Chelsio I also used (also on advice from 
>Steve Wise and Chelsio)
>
>@@ -85,10 +85,10 @@ static void rnic_init(struct iwch_dev *rnicp)
> 	rnicp->attr.mem_pgsizes_bitmask = 0x7FFF;	/* 4KB-128MB */
> 	rnicp->attr.max_mr_size = T3_MAX_MR_SIZE;
> 	rnicp->attr.can_resize_wq = 0;
>-	rnicp->attr.max_rdma_reads_per_qp = 8;
>+	rnicp->attr.max_rdma_reads_per_qp = 16;		/* ORD */
> 	rnicp->attr.max_rdma_read_resources =
> 	    rnicp->attr.max_rdma_reads_per_qp * rnicp->attr.max_qps;
>-	rnicp->attr.max_rdma_read_qp_depth = 8;	/* IRD */
>+	rnicp->attr.max_rdma_read_qp_depth = 16;	/* IRD */
> 	rnicp->attr.max_rdma_read_depth =
> 	    rnicp->attr.max_rdma_read_qp_depth * rnicp->attr.max_qps;
> 	rnicp->attr.rq_overflow_handled = 0;
>
>With those changes in place on top of 2.6.26.3, my testing a 
>few weeks ago gave:
>   SDR IB:                   250 x 10^6 B/s
>   10 Gb/s iWARP:            285 x 10^6 B/s
>Today I rebooted into that kernel and got anywhere from
>260 to 300 MB/s for iWARP, and from 255 to 275 MB/s for SDR IB.
>
>So that's a nice improvement, but I think my hardware should
>be capable of more than that.  I noticed on my server that I
>had lots of nfsd threads in uninterruptible sleep in xfs_write.
>It looks to me like they're serialized by the i_mutex for the
>file.

Yep, that and other issues. You really don't need 64 threads in
all likelihood to keep the disks busy. Also, I don't see any tunings
to the client's RPC slot count. By default on an NFS/RDMA mount
you'll only get 32.

>  So I did the following quick test to learn what effect
>that might have:
>
># set up some shell variables, where <mount_point> is the 
># XFS file system I am exporting to my NFS client.
>F=<mount_point>/zero
>TS=16384 # total data written will be 16384 MiB
>BS=1024  # data written in 1024 KiB chunks
>N=64     # data written by 64 concurrent threads
>
># write a single file with N threads using dd and shell commands
>rm -f $F* && C=$((1024*TS/N/BS)) && \
>  time { for n in $(seq 0 $((N-1)) ) ; do { \
>    dd conv=notrunc if=/dev/zero of=$F bs=${BS}k count=$C seek=$((n * 
>C)) 2>/dev/null & \
>  } done; wait; sync; } && \
>echo -e "\n Total $((C*BS*N/1024)) MiB"
>
># write N files with N threads using dd and shell commands
>rm -f $F* && C=$((1024*TS/N/BS)) && \
>  time { for n in $(seq 0 $((N-1)) ) ; do { \
>    dd conv=notrunc if=/dev/zero of=$F.$n bs=${BS}k count=$C seek=$((n 
>* C)) 2>/dev/null & \
>  } done; wait; sync; } && \
>echo -e "\n Total $((C*BS*N/1024)) MiB"
>
>Here's the elapsed times I got when writing 16 GiB of data 
>using 2.6.26.  I did each case in sequence, and repeated the 
>sequence of runs three times to get some idea of repeatability:
>
>          single        N
>    N      file       files
>    1         0m47.135s
>              0m47.190s
>              0m47.004s
>    4   0m52.993s   0m24.162s
>        0m56.458s   0m24.364s
>        0m55.767s   0m24.938s
>   16   1m6.008s    0m36.945s
>        1m3.526s    0m36.373s
>        1m1.058s    0m36.260s
>   64   1m19.917s   0m47.441s
>        1m20.216s   0m47.415s
>        1m15.971s   0m47.185s
>
>Note that 16 GiB in 47 seconds is ~365 MB/s, while 16 GiB in 75 
>seconds is ~230 MB/s.  So I think with RPCRDMA_MAX_DATA_SEGS = 16
>my single-client write throughput is limited by how fast my
>server can clean pages.  I haven't yet tested throughput on this
>server with multiple RDMA clients.

This will probably help, you might also try multiple mount points from
the same client. However, if the server page-cleaning is really the
bottleneck, more clients won't change a thing.

>
>> 
>> In the meantime, let me offer the observation that multiple RDMA Reads
>> are not a penalty, since they are able to stream up to the IRD max offered
>> by the client, which is in turn more than sufficient to maintain bandwidth
>> usage. Are you seeing a bottleneck? If so, I'd like to see the output from
>> the client with RPCDBG_TRANS turned on, it prints the IRD at connect time.
>
>I don't think I'm seeing a bottleneck directly related to the
>number of RDMA Reads per RPC.  I have verified that my IRD is
>as expected at transport connect, and that my write RPCs contain
>the correct number of chunks.

Actually, there may be an issue - Tom and I have discovered that the
server and client don't always agree on the IRD, even if one side says
so. We're still investigating this, it behaves differently over IB versus
iWARP, for instance.

>
>I'm really just looking for larger RPC payloads.

Ok.

>
>> 
>> >In either case my maximum rsize, wsize for an RDMA mount
>> >is still 32 KiB.
>> 
>> Yes. But here's the deal - write throughput is almost never a network
>> problem. Instead, it's either a server ordering problem, or a congestion/
>> latency issue. The rub is, large I/O's help the former (by cramming lots
>> of writes together in a single request), but they hurt the latter (by
>> cramming large chunks into the pipe).
>> 
>> In other words, small I/Os on low-latency networks can be good.
>> 
>Sure.  But, for our use cases I think larger RPC payloads would be
>beneficial. 

To be clear - I am inclined to agree but for the reason of your server's
filesystem, not the network itself. I will want to see the details of changing
from 32KB to 64KB, and maybe 128KB if we can try that easily. This will
help motivate the necessary work.

> My hope is that, via FASTREG and/or by removing
>the hard-coded limit of RPCRDMA_MAX_DATA_SEGS, it would be possible
>for people to tune this per mount via wsize,rsize.
>
>Also, we're looking forward to parallel NFS over RDMA.

Me too! The important thing to remember is that there is no dependency
between these two - pNFS can operate over NFS/RDMA or TCP without
any real change, all you need is pNFS-capable data servers, and of course
client support too. We are working hard on pNFS, and it should "just work"
over NFS/RDMA if you so choose.

>  We're hoping
>a single client will be able to stream data at line rate over an
>iWARP/IB interface to/from a parallel NFS filesystem.

This is already possible without pNFS, it's basically a question of how
much server and how many spindles. Of course, it's a bigger challenge
with a Linux server, but it's doable.

>  I'm thinking
>larger RPC payloads are going to be part of that solution, but
>right now I have nothing to back that assertion up.
>
>> 
>> However, the Linux NFS server has a rather clumsy interface to the
>> backing filesystem, and if you're using ext, its ability to handle many
>> 32KB sized writes in arbitrary order is somewhat poor. What type
>> of storage are you exporting? Are you using async on the server?
>> 
>See above.
>> 
>> >
>> >My understanding is that, e.g., a Chelsio T3 with the
>> >2.6.27-rc driver can support 24 pages in a fast registration
>> >request.  So, what I was hoping to see with a T3 were RPCs with
>> >RPCRDMA_MAX_DATA_SEGS  chunks, each for a fast registration of
>> >24 pages each, making possible an RDMA mount with 768 KiB for
>> >rsize, wsize.
>> 
>> You can certainly try raising MAX_DATA_SEGS to this value and building
>> a new sunrpc module. I do not recommend such a large write size however;
>> you won't be able to do many mounts, due to resource issues on both client
>> and server.
>> 
>> If you're seeing throughput problems, I would suggest trying a 64KB write
>> size first (MAX_DATA_SEGS==16), and if that improves then maybe 128KB (32).
>> 128KB is generally more than enough to make ext happy (well, happi*er*).
>> 
>I've been a little reluctant to try RPCRDMA_MAX_DATA_SEGS = 32, 
>because rpcrdma_register_external() has a couple of stack variables
>dimensioned by it.  "make checkstack" shows it will have a stack 
>of 1032 bytes at RPCRDMA_MAX_DATA_SEGS = 32, which makes me nervous.

Let's take this part offline. My new patchset reduces the stack needs somewhat,
and there are other approaches we can try as experiments. I'm very interested
in seeing the results.

Tom.


>
>But I'll give it a spin when I get a chance :)  I don't
>really expect to see much improvement given the I/O capabilities
>of my server.
>
>> 
>> >
>> >Is something like that possible?  If so, do you have any
>> >work in progress along those lines?
>> 
>> I do. But I'd be very interested to see more data before committing to
>> the large-io approach. Can you help?
>
>Yes.  Let me know.
>
>But, I do think I'm already near or at a bottleneck from
>my disk subsystem, and how fast the filesystem can write 
>out data under the type of load NFS puts on it.  Do you 
>think it would be useful to probe the limits of the transport
>by having the server drop data on the floor rather than
>write it out, in hopes of being ready for when the writeout 
>gets better?
>
>-- Jim
>
>> 
>> Tom.
>> 
>> 

