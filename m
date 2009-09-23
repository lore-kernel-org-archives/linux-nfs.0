Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52052 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbZIWXsS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2009 19:48:18 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n8NNmL0E006454
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2009 16:48:22 -0700
Message-ID: <4ABAB3C5.9060808@candelatech.com>
Date: Wed, 23 Sep 2009 16:48:21 -0700
From: Ben Greear <greearb@candelatech.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Some NFS performance numbers for 2.6.31
References: <4AB96F06.5040703@candelatech.com>
In-Reply-To: <4AB96F06.5040703@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/22/2009 05:42 PM, Ben Greear wrote:
> I'm running some performance tests on NFSv3 on a slightly hacked 2.6.31
> kernel.

I realized that LRO on the NICs was disabled because I had enabled ip-forwarding.

I re-enabled that, and now can get about 18Gbps read rates (on the wires), using MTU
1500.

Take it easy,
Ben

>
> Both: 64-bit linux.
> Dual-port 10G NIC, 82599 (I think, at any rate it's the new Intel 5GT/s
> pci-e gen2 chipset, ixgbe driver)
> MTU 1500
>
> Server: dual Intel E5530 2.4Ghz processors.
> Serving 2 25M files from tmpfs (RAM)
>
> Client: Core i7 3.2Ghz, quad-core.
> I'm running 10 mac-vlans on each physical interface, one NFS mount per
> interface
> (my patches are to allow multiple mounts per client OS).
> one reader for each mac-vlan and one on the physical, reading 16m chunks
> O_DIRECT is enabled for the readers.
> Mounts are using 'noatime', leaving everything else at defaults.
>
> Total read bandwidth is about 12Gbps, but it varies quite a bit and I've
> seen short term (10 seconds or so)
> averages go up to 15Gbps. These are on-the-wire stats reported by the
> NICs, not actual NFS throughput.
>
> Some things of interest:
> * Rates bounce around several Gbps
> * I see tcp retransmits in netstat -s on the server
> * I see zero errors (pkt loss, etc) reported by the NICs.
> * Reading 100M files slows down the test.
> * 2M and 16M reads are about equivalent (the normal bouncing of the
> rates makes it hard to tell)
> * Messing with rmem max, backlog, and other network tunings doesn't seem
> to matter.
> * Running 10 readers (5 on each physical NIC) ran at 16Gbps for a few
> seconds (higher than I'd
> seen with 10..but then it went back down to around 13Gbps.
> * Running 6 seems slower..about 11.5Gbps on average.
> * Using 9000 MTU yields a fairly steady 16.5Gbps throughput. This may be
> about the max
> IO bandwidth for the server machine...but I know the client can do full
> 10Gbps tx + rx
> on both ports (using pktgen and 1514 byte pkts).
>
> Here is snippet of top on the client. bthelper is the thing doing the
> reads:
>
> top - 17:26:25 up 13 min, 3 users, load average: 25.45, 23.12, 13.98
> Tasks: 227 total, 3 running, 224 sleeping, 0 stopped, 0 zombie
> Cpu(s): 0.2%us, 1.4%sy, 0.0%ni, 74.4%id, 0.0%wa, 0.6%hi, 23.4%si, 0.0%st
> Mem: 12326604k total, 1343680k used, 10982924k free, 30912k buffers
> Swap: 14254072k total, 0k used, 14254072k free, 112084k cached
>
> 1586 root 15 -5 0 0 0 R 39.2 0.0 1:47.91 rpciod/6
> 22 root 15 -5 0 0 0 R 38.5 0.0 1:46.94 ksoftirqd/6
> 3841 root 3 -17 49320 33m 980 D 20.3 0.3 0:23.05 bthelper
> 3840 root 3 -17 49320 33m 980 D 18.9 0.3 0:23.43 bthelper
> 3836 root 3 -17 49320 33m 980 D 12.0 0.3 0:26.39 bthelper
> 3849 root 3 -17 49320 33m 980 D 11.3 0.3 0:22.74 bthelper
>
>
> And, here is the server:
>
> top - 17:28:02 up 2:03, 2 users, load average: 0.08, 0.47, 0.68
> Tasks: 291 total, 1 running, 290 sleeping, 0 stopped, 0 zombie
> Cpu(s): 0.0%us, 2.5%sy, 0.0%ni, 95.5%id, 0.0%wa, 0.2%hi, 1.7%si, 0.0%st
> Mem: 12325312k total, 617720k used, 11707592k free, 8240k buffers
> Swap: 0k total, 0k used, 0k free, 101016k cached
>
> PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND
> 2171 root 15 -5 0 0 0 S 4.0 0.0 4:41.54 nfsd
> 2163 root 15 -5 0 0 0 S 3.6 0.0 3:06.09 nfsd
> 2166 root 15 -5 0 0 0 S 3.6 0.0 4:45.78 nfsd
> 2176 root 15 -5 0 0 0 S 3.6 0.0 4:45.45 nfsd
> 2164 root 15 -5 0 0 0 S 3.3 0.0 3:08.28 nfsd
> 2165 root 15 -5 0 0 0 S 3.3 0.0 4:20.12 nfsd
> 2167 root 15 -5 0 0 0 S 3.3 0.0 4:31.29 nfsd
> 2170 root 15 -5 0 0 0 S 3.3 0.0 4:50.80 nfsd
> 2174 root 15 -5 0 0 0 S 3.3 0.0 4:50.74 nfsd
> 2168 root 15 -5 0 0 0 S 3.0 0.0 4:53.15 nfsd
> 2169 root 15 -5 0 0 0 S 3.0 0.0 4:48.07 nfsd
>
>
> I'm curious if anyone else has done similar testing...
>
> Thanks,
> Ben
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

