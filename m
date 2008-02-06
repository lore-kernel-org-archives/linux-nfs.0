From: Gabriel Barazer <gabriel-KSe8qvLY914@public.gmane.org>
Subject: Re: NFS performance (Currently 2.6.20)
Date: Wed, 06 Feb 2008 21:04:21 +0100
Message-ID: <47AA12C5.4010807@oxeva.fr>
References: <3093.195.41.66.226.1202292274.squirrel@mail.jabbernet.dk>    <47A9C620.70106@oxeva.fr> <64226.195.41.66.226.1202313579.squirrel@mail.jabbernet.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.reagi.com ([195.60.188.80]:57571 "EHLO mail.reagi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059AbYBFUE2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 15:04:28 -0500
In-Reply-To: <64226.195.41.66.226.1202313579.squirrel-e3PW5SUo3N5/BLzvFphCflpr/1R2p/CL@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/06/2008 4:59:39 PM +0100, "Jesper Krogh" <jesper-Q2TZfHgGEy4@public.gmane.org> wrote:

>> I have a similar setup, and I'm very curious on how you can read an
>> "iowait" value from the clients: On my nodes (server 2.6.21.5/clients
>> 2.6.23.14), the iowait counter is only incremented when dealing with
>> block devices, and since my nodes are diskless my iowait is near 0%.
> 
> Output in top is like this:
> top - 16:51:01 up 119 days,  6:10,  1 user,  load average: 2.09, 2.00, 1.41
> Tasks:  74 total,   2 running,  72 sleeping,   0 stopped,   0 zombie
> Cpu(s):  0.2%us,  0.0%sy,  0.0%ni, 50.0%id, 49.8%wa,  0.0%hi,  0.0%si, 
> 0.0%st
> Mem:   2060188k total,  2047488k used,    12700k free,     2988k buffers
> Swap:  4200988k total,    42776k used,  4158212k free,  1985500k cached

You have obviously a block device on your nodes, so I suspect that 
something is reading/writing to it. Looking at how much memory is used, 
your system must be constantly swapping. This could explain why your 
iowait is so high (if your swap space is a block device or a file on a 
block device. You don't use swap over NFS do you?)

> It is a Sun V20Z (dual Opteron) NIC is:
> 02:02.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5704
> Gigabit Ethernet (rev 03)

I don't know if this adapter supports DMA (no mention on the broadcom 
specs page). I've seen such a technology only with the Intel I/O 
Acceleration Technology (I/OAT) implementation, which the mainstream 
linux kernel supports. But I have really seen the difference. I suppose 
your controllers are integrated on the motherboard?
Another thing which could make a difference, maybe you could compile 
your kernel with a lower timer frequency (CONFIG_HZ) such as 100hz: this 
results in less interrupts being processed and a higher throughput. 
(very dirty explanation, I know)

Gabriel
