From: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Subject: Re: ixgbe_clean_tx_irq: tx hang 1 detected, resetting adapter 	(2.6.32.8)
Date: Mon, 22 Feb 2010 19:40:20 +0100
Message-ID: <4B82CF94.5070903@krogh.cc>
References: <4B7824F1.6000202@krogh.cc> <4807377b1002171453n277cfea3s6d7f3629bd43f674@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.0.fullrate.dk ([90.184.12.24]:48623 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754239Ab0BVSkZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2010 13:40:25 -0500
In-Reply-To: <4807377b1002171453n277cfea3s6d7f3629bd43f674-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jesse Brandeburg wrote:
> On Sun, Feb 14, 2010 at 8:29 AM, Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org> wrote:
>> Hi List.
>>
>> I have tried to get a dual bond of 2 x 10G NICs using the
>> Intel Corporation 82598EB 10-Gigabit AT2 Server Adapter (rev 01)
>> going. As first it looked like it "just worked" but when tried to fill
>> the links with data one of the NIC's (eth7) hang and did a reset of
>> itself, so all data was pushed through the other NIC in the bond (eth8)
>>
>> Full dmesg below, but I think the important part is this:
>>
>> [ 2162.745354] ixgbe: eth7: ixgbe_check_tx_hang: Detected Tx Unit Hang
>> [ 2162.745356]   Tx Queue             <4>
>> [ 2162.745356]   TDH, TDT             <e1>, <cc>
>> [ 2162.745357]   next_to_use          <cc>
>> [ 2162.745358]   next_to_clean        <e1>
>> [ 2162.745359] tx_buffer_info[next_to_clean]
>> [ 2162.745359]   time_stamp           <1000713d3>
>> [ 2162.745360]   jiffies              <10007152e>
>> [ 2163.162478] ixgbe: eth7: ixgbe_clean_tx_irq: tx hang 1 detected,
>> resetting adapter
>> [ 2163.357333] bonding: bond0: link status definitely down for interface
>> eth7, disabling it
>> [ 2168.670342] ixgbe: eth7 NIC Link is Up 10 Gbps, Flow Control: None
> 
> Hi Jesper, my first thought was flow control, but I can see you have it off.

I didnt change it, so its default.

> Can we get some more details on the hardware and bios version?  

Sun X4600, 128GB, 16 cores..

> What
> about some dmidecode output.  I'm checking here if we have any
> hardware like this.

http://shrek.krogh.cc/~jesper/dmidecode.txt


> are you running ubuntu 9.10 or something else?

We're on Ubuntu 8.04 but we basically "only" use a filesystem, kernel
with a well-performing NFS-server and some NIC that work well :-)

> Wow, thats a monster machine, 8 nodes, 128GB ram.  Can we get a full
> lspci -vvv output, as well as ethtool -e eth7 and eth8

http://shrek.krogh.cc/~jesper/lspci.txt

http://shrek.krogh.cc/~jesper/ethtool-eth7.txt
http://shrek.krogh.cc/~jesper/ethtool-eth8.txt

> 32 has ixgbe with a known issue of multiple mappings on transmit
> possibly causing some problems, could it be that you're running into
> this?  can you apply commit e5a43549f7a58509a91b299a51337d386697b92c
> and see if it fixes your issue?

I'll do that the next time I can push a reboot through.

-- 
Jesper
