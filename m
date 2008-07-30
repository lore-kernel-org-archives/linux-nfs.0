From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: high latency NFS
Date: Wed, 30 Jul 2008 15:21:10 -0400
Message-ID: <20080730192110.GA17061@fieldses.org>
References: <200807241311.31457.shuey@purdue.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	rees@citi.umich.edu, aglo@citi.umich.edu
To: Michael Shuey <shuey-olO2ZdjDehc3uPMLIKxrzw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51473 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752243AbYG3TVL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jul 2008 15:21:11 -0400
In-Reply-To: <200807241311.31457.shuey-olO2ZdjDehc3uPMLIKxrzw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

You might get more responses from the linux-nfs list (cc'd).

--b.

On Thu, Jul 24, 2008 at 01:11:31PM -0400, Michael Shuey wrote:
> I'm currently toying with Linux's NFS, to see just how fast it can go in a 
> high-latency environment.  Right now, I'm simulating a 100ms delay between 
> client and server with netem (just 100ms on the outbound packets from the 
> client, rather than 50ms each way).  Oddly enough, I'm running into 
> performance problems. :-)
> 
> According to iozone, my server can sustain about 90/85 MB/s (reads/writes) 
> without any latency added.  After a pile of tweaks, and injecting 100ms of 
> netem latency, I'm getting 6/40 MB/s (reads/writes).  I'd really like to 
> know why writes are now so much faster than reads, and what sort of things 
> might boost the read throughput.  Any suggestions?
> 1
> The read throughput seems to be proportional to the latency - adding only 
> 10ms of delay gives 61 MB/s reads, in limited testing (need to look at it 
> further).  While that's to be expected, to some extent, I'm hoping there's 
> some form of readahead that can help me out here (assume big sequential 
> reads).
> 
> iozone is reading/writing a file twice the size of memory on the client with 
> a 32k block size.  I've tried raising this as high as 16 MB, but I still 
> see around 6 MB/sec reads.
> 
> I'm using a 2.6.9 derivative (yes, I'm a RHEL4 fan).  Testing with a stock 
> 2.6, client and server, is the next order of business.
> 
> NFS mount is tcp, version 3.  rsize/wsize are 32k.  Both client and server 
> have had tcp_rmem, tcp_wmem, wmem_max, rmem_max, wmem_default, and 
> rmem_default tuned - tuning values are 12500000 for defaults (and minimum 
> window sizes), 25000000 for the maximums.  Inefficient, yes, but I'm not 
> concerned with memory efficiency at the moment.
> 
> Both client and server kernels have been modified to provide 
> larger-than-normal RPC slot tables.  I allow a max of 1024, but I've found 
> that actually enabling more than 490 entries in /proc causes mount to 
> complain it can't allocate memory and die.  That was somewhat suprising, 
> given I had 122 GB of free memory at the time...
> 
> I've also applied a couple patches to allow the NFS readahead to be a 
> tunable number of RPC slots.  Currently, I set this to 489 on client and 
> server (so it's one less than the max number of RPC slots).  Bandwidth 
> delay product math says 380ish slots should be enough to keep a gigabit 
> line full, so I suspect something else is preventing me from seeing the 
> readahead I expect.
> 
> FYI, client and server are connected via gigabit ethernet.  There's a couple 
> routers in the way, but they talk at 10gigE and can route wire speed.  
> Traffic is IPv4, path MTU size is 9000 bytes.
> 
> Is there anything I'm missing?
> 
> -- 
> Mike Shuey
> Purdue University/ITaP
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
