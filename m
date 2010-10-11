Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35763 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755355Ab0JKSRE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Oct 2010 14:17:04 -0400
Date: Mon, 11 Oct 2010 14:16:47 -0400
To: Phil Endecott <phil_bnaqb_endecott@chezphil.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org
Subject: Re: NFS & atl1c : "RPC: multiple fragments per record not
 supported"
Message-ID: <20101011181647.GA3166@fieldses.org>
References: <1286722097803@dmwebmail.dmwebmail.chezphil.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1286722097803@dmwebmail.dmwebmail.chezphil.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Oct 10, 2010 at 03:48:17PM +0100, Phil Endecott wrote:
> Dear Experts,
> 
> I am seeing the error "RPC: multiple fragments per record not
> supported" on my NFS server when an NFS client with an atl1c network
> driver talks to it.
> 
> The server is a QNAP TS119 ARM box running Debian's 2.6.33.2 kernel.
> It works reliably with other clients.
> 
> The client is a new x86 system with an "Atheros Communications
> AR8131 Gigabit Ethernet (rev c0)" (1969:1063).  The kernel is
> Debian's 2.6.32-5-686 and the driver seems to be atl1c.

To my knowledge the Linux client has never sent packets that would
trigger the prink above, so off hand it does sound like some sort of
corruption at the network level.

(Independently of that: we should fix the server to support multiple
fragments per record at some point.  But if you hadn't hit that printk,
I'm guessing you would have had a failure soon enough anyway.)

> Typically NFS works for a few seconds and then stops, with that
> message repeated on the server.  Other network activity seems
> reliable (e.g. HTTP, ssh, etc.)
> 
> If I use a USB-ethernet adaptor instead of the built-in gigabit it
> works reliably.  (The USB device is not gigabit, but I do still see
> the problems if I limit the port to 100 Mbit on the switch.)
> 
> I see the problem with NFS v3 and v4.  However, I only see it with
> proto=tcp.  By changing the NFS protocol to UDP, the problem seems
> to go away [well, it has been working for about 20 minutes now
> without any issues].
> 
> Google finds a previous report here:
> http://lkml.org/lkml/2010/1/20/198 ; the suggestion is to turn off
> tcp segmentation offload, but it seems that this is not possible
> with my system:
> 
> # ethtool -K eth0 tso off
> Cannot set device tcp segmentation offload settings: Operation not supported
> 
> I have looked at the changes to atl1c since 2.6.32 (http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=history;f=drivers/net/atl1c;h=53cd10d07d040b7bec957acb1c69bc7b44897e69;hb=HEAD)
> and they seem harmless.
> 
> I wiresharked the network activity while this error was being shown,
> and it did include some packets with the high-contrast colour
> schemes that wireshark uses for "bad" packets.  Unfortunately my
> laptop ran out of battery before I could decipher these packets
> further.
> 
> So, is this a known issue?  Do people agree that the atl1c driver is
> most likely the culprit?  Can I offer any further debugging?

I haven't seen that before.  Adding netdev to the cc:, as you seem to
have reasonable evidence that the problem is the network driver.

--b.
