From: Gabriel Barazer <gabriel-KSe8qvLY914@public.gmane.org>
Subject: Re: NFS performance (Currently 2.6.20)
Date: Wed, 06 Feb 2008 15:37:20 +0100
Message-ID: <47A9C620.70106@oxeva.fr>
References: <3093.195.41.66.226.1202292274.squirrel@mail.jabbernet.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.reagi.com ([195.60.188.80]:46457 "EHLO mail.reagi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751161AbYBFOoH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 09:44:07 -0500
In-Reply-To: <3093.195.41.66.226.1202292274.squirrel-e3PW5SUo3N5/BLzvFphCflpr/1R2p/CL@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On 02/06/2008 11:04:34 AM +0100, "Jesper Krogh" <jesper-Q2TZfHgGEy4@public.gmane.org> wrote:
> Hi.
> 
> I'm currently trying to optimize our NFS server. We're running in a
> cluster setup with a single NFS server and some compute nodes pulling data
> from it. Currently the dataset is less than 10GB so it fits in memory of
> the NFS-server. (confirmed via vmstat 1).
> Currently I'm  getting around 500mbit (700 peak) of the server on a
> gigabit link and the server is CPU-bottlenecked when this happens. Clients
> having iowait around 30-50%.

I have a similar setup, and I'm very curious on how you can read an 
"iowait" value from the clients: On my nodes (server 2.6.21.5/clients 
2.6.23.14), the iowait counter is only incremented when dealing with 
block devices, and since my nodes are diskless my iowait is near 0%.

Maybe I'm wrong, but when the NFS servers lags, this is my system 
counter which is increased (having peaks at 30% system instead of 5-10%)

> Is it reasonable to expect to be able to fill a gigabit link in this
> scenario? (I'd like to put in a 10Gbit interface, but when I have a
> cpu-bottleneck)

I'm sure this is possible, but it is very dependant on which kind of 
traffic you have. If you have only data to pull (which theoretically 
never invalidate the page cache on the server), and you have options 
like 'noatime,nodiratime' to avoid nfs updating the access times, it 
seems possible to me. But maybe your CPU is busy doing something else 
than only computing NFS traffic. Maybe you should change your network 
controller ? I use the Intel Gigabit ones (integrated ESB2 with e1000 
driver) with rx-polling and Intel I/OAT enabled (DMA engine), and this 
really helps by reducing interrupts when dealing with a lot of traffic.

You will have to check your kernel if you have IOAT enabled in the "DMA 
engines" section.

> 
> Should I go for NFSv2 (default if I dont change mount options) NFSv3 ? or
> NFSv4

NFSv2/3 have nearly the same performance, and NFSv4 has a slight 
negative hit probably because of its "earlyness": it's too early to work 
on the performances when features are not completely stable.

> 
> NFSv3 default mount options is around 1MB for rsize and wsize, but reading
> the nfs-man page, they suggest setting them "up to" around 32K.

the values for rsize and wsize mount options depends on the amount of 
memory you have (on the server AFAIK), and when you have >4GB the values 
are not very realistic anymore. On my systems I have the defaults 
rsize/wsize set to 512KB and all is running fine, but I sure there is 
some work to be done to adjust more precisely the buffers size when 
dealing with large memory amounts (e.g. a 1MB buffer is a non-sense). 
The 32k value in a very old one and the man page doesn't even explain 
the memory-related rsize/wsize values.

> 
> I probably only need some pointers to the documentation.

And the documentation probably needs some refresh, but things are 
changing nearly every week here...

Gabriel
