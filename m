Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15951 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751438Ab1F3NgW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jun 2011 09:36:22 -0400
Subject: Re: [nfsv4]nfs client bug
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <BANLkTinxF+obzedP+xupMCDZcgRTFDsQMg@mail.gmail.com>
Date: Thu, 30 Jun 2011 09:36:20 -0400
Cc: Benny Halevy <bhalevy@tonian.com>, linux-nfs@vger.kernel.org,
        "Mueller, Brian" <bmueller@panasas.com>
Message-Id: <4CC6F947-FE93-47E4-9FD9-C0EB4D8033A6@netapp.com>
References: <BANLkTi=xcQseTx8BTWEzg-1DO=ayJuMLrw@mail.gmail.com> <4E0B52BB.8090003@tonian.com> <BANLkTinxF+obzedP+xupMCDZcgRTFDsQMg@mail.gmail.com>
To: quanli gui <gqlxj1987@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 29, 2011, at 10:32 PM, quanli gui wrote:

> When I use the iperf tools for one client to 4 ds, the network
> throughput is 890MB/S. It reflect that it is indeed 10GE non-blocking.
> 
> a. about block size, I use bs=1M when I use dd
> b. we indeed use the tcp (doesn't the nfsv4 use the tcp defaultly?)
> c. the jumbo frames is what? how set mtu automatically?
> 
> Brian, do you have some more tips?

1) Set the mtu on both the client and the server 10G interface. Sometimes 9000 is too high. My setup uses 8000.
To set MTU on interface eth0.

% ifconfig eth0 mtu 9000

iperf will report the MTU of the full path between client and server - use it to verify the MTU of the connection.

2) Increase the # of rpc_slots on the client.
% echo 128 > /proc/sys/sunrpc/tcp_slot_table_entries

3) Increase the # of server threads

% echo 128 > /proc/fs/nfsd/threads
% service nfs restart

4) Ensure the TCP buffers on both the client and the server are large enough for the TCP window.
Calculate the required buffer size by pinging the server from the client with the MTU packet size and multiply the round trip time by the interface capacity

% ping -s 9000 server  - say 108 ms average

10Gbits/sec = 1,250,000,000 Bytes/sec * .108 sec = 135,000,000 bytes

Use this number to set the following: 
sysctl -w net.core.rmem_max = 135000000
sysctl -w net.core.wmem_max 135000000
sysctl -w "net.ipv4.tcp_rmem <first number unchaged> <second unchanged> 135000000"
sysctl net.ipv4.tcp_wmem  <first number unchaged> <second unchanged> 135000000"

5) mount with rsize=131072,wsize=131072

see if this helps

-->Andy

> 
> 
> On Thu, Jun 30, 2011 at 12:28 AM, Benny Halevy <bhalevy@tonian.com> wrote:
>> 
>> Hi,
>> 
>> First, please use plain text only when sending to linux-nfs@vger.kernel.org
>> as multi-part / html messages are automatically blocked by the spam filter.
>> 
>> I'm not so sure that the nfs client is to blame for the performance
>> you're seeing.  The problem could arise from too small of a block size
>> by dd / iozone
>> 
>> I'd try:
>> a. using a larger block size (e.g.  dd bs=4096k)
>> b. tuning your tcp better for high bandwidth
>> c. using jumbo frames all the way, and making sure that the mtu is discovered
>> automatically and set properly to 9000.
>> 
>> Also, what's you network look like?
>> what's the switch you're using
>> is it indeed 10 Gbps non-blocking
>> are there any linecard / chip bottlenecks or over subscription
>> 
>> Do you see better throughput with iperf?
>> 
>> Brian, you's probably have even more tips and tricks :)
>> 
>> Regards,
>> 
>> Benny
>> 
>> On 2011-06-28 11:26, quanli gui wrote:
>>> Hi,
>>> Recently I test the nfsv4 speed, I found that there is something wrong in
>>> the nfs client, that is the one nfs client can only provide 400MB/S to the
>>> server.
>>> My tests as follow:
>>> machine:one client, four server; hardware: all 16core, 16G memory, 5T disk;
>>> os: all suse 11 enterprise server, 2.6.31-pnfs-kernel; network: client,
>>> 10GE, server, 2GE(bond, 1GE*2);
>>> test method: on the client, mkdir four independent directory, mount the four
>>> server via nfsv4 protocol, every time increase one;
>>> test tool: iozone, or dd if=/dev/zero of=test count=20K,then cat
>>> test>/dev/null
>>> test result:(force on read speed, and watch the client/server network
>>> input/output by the sar command)
>>> 1 client vs 1 server: 200MB/S
>>> 1 client vs 2 server: 380MB/S, every server: 190MB/S
>>> 1 client vs 3 server: 380MB/S, every server: 130MB/S
>>> 1 client vs 4 server: 385MB/S, every server: 95MB/S
>>> 
>>> From above, we found that 400MB/S is the max-speed for one client. This
>>> speed is the limition? How to increase this speed?
>>> 
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

