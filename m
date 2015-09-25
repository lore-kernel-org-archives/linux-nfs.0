Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932258AbbIYODU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Sep 2015 10:03:20 -0400
Date: Fri, 25 Sep 2015 09:29:49 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Pankaj Singh <psingh.ait@gmail.com>
cc: linux-nfs@vger.kernel.org
Subject: Re: Tool or module to test NFSv3 server scalability
In-Reply-To: <CAPrqf91jVM8jq2-u9TBNPx4nc2pmPct-PYqGWau4mcQQOT_Lmg@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1509250914050.24831@planck.local>
References: <CAPrqf91jVM8jq2-u9TBNPx4nc2pmPct-PYqGWau4mcQQOT_Lmg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 25 Sep 2015, Pankaj Singh wrote:

> Hi all,
>
> I am new to nfs. I have a requirement to test the scalability of NFSv3.
> To test this I would require a solution that can simulate multiple nfs clients.
> As its known a single TCP connection is used for communication between
> client and server. So to increase multiple connections multiple
> nfs-clients would be needed. Which is very costly.
>
> So would need some method/tool to create multiple nfs TCP connections
> from single or few machines.


Hi Pankaj, this is a fun question.

One thought I had would be to use a big block ip addresses on a linux NFS
server, and mount the filesystem with each unique server ip address.  That
should create a bunch of connections with only a single client and server.
IPv6 is ideal since there's a lot of address room.

This turns out to be really easy to do if you have a linux server with
Any-IP support [1].

On my server, I set up a rule so that any ipv6 traffic arriving on eth0
consults route table 200, and set up route table 200 to route everything to
the loopback interface:

ip -6 rule add from all iif eth0 lookup 200
ip -6 route add local default dev lo table 200

Then on my client, I set a routing rule for a large local network to route
to my server's eth0 ipv6 real-world address:

ip -6 route add fd12:3456:789a:1::/64 via 2601:18b:4000:1a2a:5054:ff:fe30:a648

Now, whenever my client sends any traffic to any ip in
fd12:3456:789a:1::/64, it will go to my server's loopback adapter which
should accept it as though it had that address.

On the client we can then bash out some mounts:

for j in {1..1024}; do mkdir /mnt/v6/$(printf %x $j); done;
cd /mnt/v6
for dir in *; do mount \[fd12:3456:789a:1::$dir\]:/ $dir; done
grep fd12 /proc/mounts | wc
   1024    6144  248022

This should cause the linux nfs client's rpc code to create a separate
connection for each mount.

Ben

[1] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ab79ad14a2d51e95f0ac3cef7cd116a57089ba82
