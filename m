From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: ixgbe_clean_tx_irq: tx hang 1 detected, resetting adapter
	(2.6.32.8)
Date: Wed, 17 Feb 2010 14:53:34 -0800
Message-ID: <4807377b1002171453n277cfea3s6d7f3629bd43f674@mail.gmail.com>
References: <4B7824F1.6000202@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4B7824F1.6000202@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 14, 2010 at 8:29 AM, Jesper Krogh <jesper@krogh.cc> wrote:
> Hi List.
>
> I have tried to get a dual bond of 2 x 10G NICs using the
> Intel Corporation 82598EB 10-Gigabit AT2 Server Adapter (rev 01)
> going. As first it looked like it "just worked" but when tried to fil=
l
> the links with data one of the NIC's (eth7) hang and did a reset of
> itself, so all data was pushed through the other NIC in the bond (eth=
8)
>
> Full dmesg below, but I think the important part is this:
>
> [ 2162.745354] ixgbe: eth7: ixgbe_check_tx_hang: Detected Tx Unit Han=
g
> [ 2162.745356] =A0 Tx Queue =A0 =A0 =A0 =A0 =A0 =A0 <4>
> [ 2162.745356] =A0 TDH, TDT =A0 =A0 =A0 =A0 =A0 =A0 <e1>, <cc>
> [ 2162.745357] =A0 next_to_use =A0 =A0 =A0 =A0 =A0<cc>
> [ 2162.745358] =A0 next_to_clean =A0 =A0 =A0 =A0<e1>
> [ 2162.745359] tx_buffer_info[next_to_clean]
> [ 2162.745359] =A0 time_stamp =A0 =A0 =A0 =A0 =A0 <1000713d3>
> [ 2162.745360] =A0 jiffies =A0 =A0 =A0 =A0 =A0 =A0 =A0<10007152e>
> [ 2163.162478] ixgbe: eth7: ixgbe_clean_tx_irq: tx hang 1 detected,
> resetting adapter
> [ 2163.357333] bonding: bond0: link status definitely down for interf=
ace
> eth7, disabling it
> [ 2168.670342] ixgbe: eth7 NIC Link is Up 10 Gbps, Flow Control: None

Hi Jesper, my first thought was flow control, but I can see you have it=
 off.

Can we get some more details on the hardware and bios version?  What
about some dmidecode output.  I'm checking here if we have any
hardware like this.

are you running ubuntu 9.10 or something else?

Wow, thats a monster machine, 8 nodes, 128GB ram.  Can we get a full
lspci -vvv output, as well as ethtool -e eth7 and eth8

32 has ixgbe with a known issue of multiple mappings on transmit
possibly causing some problems, could it be that you're running into
this?  can you apply commit e5a43549f7a58509a91b299a51337d386697b92c
and see if it fixes your issue?
