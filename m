From: Ben Greear <greearb@candelatech.com>
Subject: Re: Reading NFS file without copying to user-space?
Date: Fri, 04 Sep 2009 15:30:56 -0700
Message-ID: <4AA19520.70305@candelatech.com>
References: <4AA16F25.6050700@candelatech.com>	 <1252096543.2402.4.camel@heimdal.trondhjem.org>	 <4AA17D62.9020404@candelatech.com>	 <74C14419-4D21-4EC2-B01A-EAC04B354F06@fys.uio.no>	 <4AA18D32.50507@candelatech.com> <1252102506.5274.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43689 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934398AbZIDWbA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2009 18:31:00 -0400
In-Reply-To: <1252102506.5274.7.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/04/2009 03:15 PM, Trond Myklebust wrote:
> On Fri, 2009-09-04 at 14:57 -0700, Ben Greear wrote:
>> On 09/04/2009 01:58 PM, Trond Myklebust wrote:
>>
>>> You're missing the point. O_DIRECT does not copy data from the kernel
>>> into userspace. The data is placed directly into the user buffer from
>>> the socket.
>>>
>>> The only faster alternative would be to directly discard the data in the
>>> socket, and we offer no option to do that.
>>
>> I was thinking I might be clever and use sendfile to send an nfs
>> file to /dev/zero, but unfortunately it seems sendfile can only send
>> to a destination that is a socket....
>
> Why do you think that would be any faster than standard O_DIRECT? It
> should be slower, since it involves an extra copy.

I was thinking that the kernel might take the data received in the skb's from
the file-server and send it to /dev/null, ie basically just immediately
discard the received data.  If it could do that, it would be a zero-copy
read:  The only copying would be the NIC DMA'ing the packet into the skb.

It would also seem to me that if one allowed sendfile to copy between
files, it could do the same trick saving to a real file and save user-space
having to read the file in and then write it out again to disk.

Truth is, I don't know much about the low level of file-io, so I may
be completely confused about things :)

I'll try using much larger buffers for the read() call, and will also make
sure the networking buffer pools are big enough.

Out of curiosity, any one have any benchmarks for NFS on 10G hardware?

I have two 2.6.31-rc8 Linux systems that for a short time will serve & sink about 9Gbps of
file-io (serving from 2GB tmpfs, discarding as soon as we read).  Something
goes weird after a minute or two and bandwidth drops down and bounces between
4Gbps-8Gbps.
Based on testing against another vendor's nfs server, it seems that the client
is loosing packets (the server shows tcp retransmits).

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

