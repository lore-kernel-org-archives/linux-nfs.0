From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: RPC retransmission of write requests containing bogus data
Date: Fri, 17 Oct 2008 08:48:44 -0400
Message-ID: <1224247725.7722.4.camel@localhost>
References: <1224241273.9053.109.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21855 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757193AbYJQMtl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 08:49:41 -0400
In-Reply-To: <1224241273.9053.109.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-10-17 at 12:01 +0100, Ian Campbell wrote:
> (please CC me, I am not currently subscribed to linux-nfs)
> 
> Hi,
> 
> For some time now I have been tracking down a mysterious host crash when
> using Xen with blktap (userspace paravirtual disk implementation) under
> stress conditions. I have now managed to create a simple test case with
> no Xen components which appears to show RPC retransmissions of write
> requests containing invalid data. I'll start at the beginning and
> explain the original bug although the test case is much simpler.
> 
> blktap is a userspace daemon which provides paravirtualised disk support
> to Xen guests. The pages of data for a block write are mapped from the
> Xen guest into a domain 0 driver called blktap which has a userspace
> component which implements qcow/vhd/etc and writes the data to the
> backing file using O_DIRECT and aio in a zero copy manner. Once the  the
> aio is completed the pages are returned to the guest and unmapped from
> domain 0. When a page is unmapped in this way the pte is set not present
> and the PFN is mapped to an invalid MFN.
> 
> We have been seeing a crash in the domain 0 network driver's start_xmit
> routine when it attempts to access data from a page where the PFN maps
> to an invalid MFN. I added some tracing to the kernel and observed this
> sequence of events on an individual page:
>         tap: 0/41 at 4fac7a165ad6 "rpc_init_task" c8792844 0
>         tap: 1/41 at 4fac7a1663e2 "nfs_direct_write_schedule" ece19850 2000
>         tap: 2/41 at 4fac7a166cca "call_start" c8792844 0
>         tap: 3/41 at 4fac7a167540 "call_reserve" c8792844 0
>         tap: 4/41 at 4fac7a167de6 "call_reserveresult" c8792844 0
>         tap: 5/41 at 4fac7a168620 "call_allocate" c8792844 0
>         tap: 6/41 at 4fac7a168f08 "call_bind" c8792844 0
>         tap: 7/41 at 4fac7a169712 "call_connect" c8792844 0
>         tap: 8/41 at 4fac7a169f28 "call_transmit" c8792844 0
>         tap: 9/41 at 4fac7a16a7f2 "call_encode" c8792844 0
>         tap: 10/41 at 4fac7a16afd8 "call_header" c8792844 0
>         tap: 11/41 at 4fac7a16bc6e "xs_tcp_send_request" c8792844 0
>         tap: 12/41 at 4fac7a16c9d0 "tcp_sendpage" 0 0
>         tap: 13/41 at 4fac7a16cec2 "do_tcp_sendpages (adding data to skb)" cef08b00 0
>         tap: 14/41 at 4fac7a16e068 "call_transmit_status" c8792844 0
>         tap: 15/41 at 4fac7a2ed8f4 "tcp_transmit_skb, skb_clone" c9dca500 c9dca5a8
>         tap: 16/41 at 4faeeeb9f566 "xprt_timer" c8792844 0
>         tap: 17/41 at 4faeeeb9ff0e "xprt_timer: !req-&gt;rq_received" c8792844 0
>         tap: 18/41 at 4faeeeba08ec "rpc_make_runnable" c8792844 0
>         tap: 19/41 at 4faeeec117b8 "call_status" c8792844 ffffff92
>         tap: 20/41 at 4faeeec11faa "timeout (minor)" c8792844 0
>         tap: 21/41 at 4faeeec12778 "call_bind" c8792844 0
>         tap: 22/41 at 4faeeec12ef8 "call_connect" c8792844 0
>         tap: 23/41 at 4faeeec13678 "call_transmit" c8792844 0
>         tap: 24/41 at 4faeeec13e46 "call_encode" c8792844 0
>         tap: 25/41 at 4faeeec145ae "call_header" c8792844 0
>         tap: 26/41 at 4faeeec15082 "xs_tcp_send_request" c8792844 0
>         tap: 27/41 at 4faeeec15d1e "tcp_sendpage" 0 0
>         tap: 28/41 at 4faeeec161ce "do_tcp_sendpages (adding data to skb)" d06afe40 0
>         tap: 29/41 at 4faeeec172ea "call_transmit_status" c8792844 0
>         tap: 30/41 at 4faf2e3280d4 "rpc_make_runnable" c8792844 0
>         tap: 31/41 at 4faf2e3440c4 "call_status" c8792844 88
>         tap: 32/41 at 4faf2e3449d6 "call_decode" c8792844 0
>         tap: 33/41 at 4faf2e345240 "call_verify" c8792844 0
>         tap: 34/41 at 4faf2e345a9e "rpc_exit_task" c8792844 0
>         tap: 35/41 at 4faf2e34652a "nfs_direct_write_result" ece19850 2000
>         tap: 36/41 at 4faf2e351000 "nfs_direct_write_release (completing)" ece19850 0
>         tap: 37/41 at 4faf2e3517ec "nfs_direct_write_complete,DEFAULT w/ iocb" ece19850 0
>         tap: 38/41 at 4faf2e35205c "nfs_direct_free_writedata" ece19850 0
>         tap: 39/41 at 4faf2e51026a "fast_flush_area" 0 0
>         tap: 40/41 at 4faf33e1813a "tcp_transmit_skb, skb_clone" d06afe40 d06afee8
> (nb: fast_flush_area is the blktap function which returns the pages to
> the guest and unmaps them from domain 0, it is called via ioctl from the
> userspace process once the aio write returns successfully. 4fac7.... is
> the tsc, processor is 2.33GHz)
> 
> So what we see is the initial request being constructed and transmitted
> (around 11/41-15/41) followed by a timeout ~60s later (16/41-20/41)
> which causes us to queue a retransmit (26/41-29/41) but, critically, not
> yet actually transmit it. At this point we get the reply to the original
> request and complete the NFS write (35/41-38/41) returning success to
> userspace which causes it to unmap the pages and return them to the
> guest (39/41). At this point (40/41) we attempt to transmit the
> duplicate request and crash because the pages are not present any more.
> 
> By using libnetfilter_queue I was then able to reproduce this in
> non-stress situations by introducing delays into the network. Stalling
> all network traffic with the NFS server for 65s every 1000 packets seems
> to do the trick (probably on the aggressive side, I didn't attempt to
> minimise the interruption required to reproduce and I realise that this
> represents a pretty crappy network and/or server).
> 
> Given the observed sequence of events I then constructed a fairly simple
> test program (blktest2.c, attached) using O_DIRECT (but not aio, I don't
> think it matters) which shows the same issue without involving any Xen
> parts. The test writes a buffer filed with a counter to a file and
> immediately after the write() returns fills the buffer with 0xdeadbeef.
> By using tcpdump I capture and observe duplicated requests on the wire
> containing 0xdeadbeef in the payload and not the expected counter
> values. I usually see this in a matter of minutes. I've attached a pcap
> of a single request/reply pair which was corrupted.
> 
> Presumably in the case of a decent NFS server the XID request cache
> would prevent the bogus data actually reaching the disk but on a
> non-decent server I suspect it might actually lead to corruption (AIUI
> the request cache is not a hard requirement of the NFS protocol?).
> Perhaps even a decent server might have timed out the entry in the cache
> after such a delay?
> 
> The Xen case and the blktest2 repro was on 2.6.18. I have also
> reproduced the blktest2 case on 2.6.27 native but not with Xen since no
> domain 0 support exists just yet.
> 
> I can think of several possible option to fix this issue:
>       * Do not return success to userspace until all duplicated requests
>         have actually hit the wire, even if the response comes back
>         earlier than that.
>       * Cancel queued duplicates if a response comes in late.
>       * Copy the data pages on retransmission.
> 
> I think I prefer the 3rd option since the first two are a bit tricky
> since request has been merged into a tcp stream and may have been
> fragmented/segmented already etc. I don't think doing the copy on
> retransmits has a massive performance impact -- you must already be
> suffering from pretty severe network or server issues!
> 
> I have CC'd the maintainer of the bnx2 Ethernet driver (Michael Chan)
> because I have so far only been able to reproduce this with the broadcom
> NIC. Even in the same server if I switch to e1000 I cannot reproduce.
> However given the analysis above I'm not convinced it is likely to be a
> driver bug.
> 
> Ian.

I don't see how this could be an RPC bug. The networking layer is
supposed to either copy the data sent to the socket, or take a reference
to any pages that are pushed via the ->sendpage() abi.

IOW: the pages are supposed to be still referenced by the networking
layer even if the NFS layer and page cache have dropped their
references.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
