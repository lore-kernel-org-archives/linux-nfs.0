Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50776 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934445AbZIDXDK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2009 19:03:10 -0400
Message-ID: <4AA19CA9.5090702@candelatech.com>
Date: Fri, 04 Sep 2009 16:03:05 -0700
From: Ben Greear <greearb@candelatech.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Reading NFS file without copying to user-space?
References: <4AA16F25.6050700@candelatech.com>	 <1252096543.2402.4.camel@heimdal.trondhjem.org>	 <4AA17D62.9020404@candelatech.com>	 <74C14419-4D21-4EC2-B01A-EAC04B354F06@fys.uio.no>	 <4AA18D32.50507@candelatech.com>	 <1252102506.5274.7.camel@heimdal.trondhjem.org>	 <4AA19520.70305@candelatech.com> <1252104582.5274.16.camel@heimdal.trondhjem.org>
In-Reply-To: <1252104582.5274.16.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/04/2009 03:49 PM, Trond Myklebust wrote:
> On Fri, 2009-09-04 at 15:30 -0700, Ben Greear wrote:

>> I was thinking that the kernel might take the data received in the skb's from
>> the file-server and send it to /dev/null, ie basically just immediately
>> discard the received data.  If it could do that, it would be a zero-copy
>> read:  The only copying would be the NIC DMA'ing the packet into the skb.
>
> No... The RPC layer will always copy the data from the socket into a
> buffer. If you are using O_DIRECT reads, then that buffer will be the
> same one that you supplied in userland (the kernel just uses page table
> trickery to map those pages into the kernel address space). If you are
> using any other type of read (even if it is being piped using sendfile()
> or splice()) then it will copy that data into the NFS filesystem's page
> cache.

Ok, I think I understand that better now.  Seems like one could have
RPC use a list of skbs as data store instead of copying the data,
but perhaps that would be optimizing for something no one would
ever really want in the real world.


>> Out of curiosity, any one have any benchmarks for NFS on 10G hardware?
>
> I'm not aware of any public figures. I'd be interested to hear how you
> max out.
>
>> Based on testing against another vendor's nfs server, it seems that the client
>> is loosing packets (the server shows tcp retransmits).
>
> Is the data being lost at the client, the switch or the server? Assuming
> that you are using a managed switch, then a look at its statistics
> should be able to answer that question.

At least for my local linux - linux tests, I'm using just fibre optic
cable to connect them, so definitely not a switch problem here.  No obvious errors
reported by either NIC, and pktgen tests show that they can easily sustain
9Gbps.  I need to do more detailed looking at the netstat
counters and such.  I suspect I may have too-small network buffers.  I last
set up their defaults when a 1GB RAM system was 'high end', and now
I'm using 12GB systems :P

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

