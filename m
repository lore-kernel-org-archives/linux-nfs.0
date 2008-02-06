From: "Jesper Krogh" <jesper-Q2TZfHgGEy4@public.gmane.org>
Subject: Re: NFS performance (Currently 2.6.20)
Date: Wed, 6 Feb 2008 16:59:39 +0100 (CET)
Message-ID: <64226.195.41.66.226.1202313579.squirrel@mail.jabbernet.dk>
References: <3093.195.41.66.226.1202292274.squirrel@mail.jabbernet.dk>
    <47A9C620.70106@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "Gabriel Barazer" <gabriel-KSe8qvLY914@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:60685 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751823AbYBFQAL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 11:00:11 -0500
In-Reply-To: <47A9C620.70106-KSe8qvLY914@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Hi,
>> I'm currently trying to optimize our NFS server. We're running in a
>> cluster setup with a single NFS server and some compute nodes pulling
>> data from it. Currently the dataset is less than 10GB so it fits in
>> memory of the NFS-server. (confirmed via vmstat 1). Currently I'm
>> getting around 500mbit (700 peak) of the server on a gigabit link and
>> the server is CPU-bottlenecked when this happens. Clients having iowait
>> around 30-50%.
>
> I have a similar setup, and I'm very curious on how you can read an
> "iowait" value from the clients: On my nodes (server 2.6.21.5/clients
> 2.6.23.14), the iowait counter is only incremented when dealing with
> block devices, and since my nodes are diskless my iowait is near 0%.

Output in top is like this:
top - 16:51:01 up 119 days,  6:10,  1 user,  load average: 2.09, 2.00, 1.41
Tasks:  74 total,   2 running,  72 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.2%us,  0.0%sy,  0.0%ni, 50.0%id, 49.8%wa,  0.0%hi,  0.0%si, 
0.0%st
Mem:   2060188k total,  2047488k used,    12700k free,     2988k buffers
Swap:  4200988k total,    42776k used,  4158212k free,  1985500k cached

>> Is it reasonable to expect to be able to fill a gigabit link in this
>> scenario? (I'd like to put in a 10Gbit interface, but when I have a
>> cpu-bottleneck)
>
> I'm sure this is possible, but it is very dependant on which kind of
> traffic you have. If you have only data to pull (which theoretically never
> invalidate the page cache on the server), and you have options like
> 'noatime,nodiratime' to avoid nfs updating the access times, it
> seems possible to me. But maybe your CPU is busy doing something else than
> only computing NFS traffic. Maybe you should change your network
> controller ? I use the Intel Gigabit ones (integrated ESB2 with e1000
> driver) with rx-polling and Intel I/OAT enabled (DMA engine), and this
> really helps by reducing interrupts when dealing with a lot of traffic.

It is a Sun V20Z (dual Opteron) NIC is:
02:02.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5704
Gigabit Ethernet (rev 03)

Jesper
-- 
Jesper Krogh

