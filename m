Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54540 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537Ab0G1SIi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jul 2010 14:08:38 -0400
Message-ID: <4C507208.6030309@oracle.com>
Date: Wed, 28 Jul 2010 14:08:08 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: =?UTF-8?B?IkouQS4gTWFnYWxsw7NuIg==?= <jamagallon@ono.com>
CC: Linux Kernel <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: Questions and problems with NFS4
References: <20100728004611.00c46b13@werewolf.home>
In-Reply-To: <20100728004611.00c46b13@werewolf.home>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/27/10 06:46 PM, J.A. Magallón wrote:
> - AFAIK, with NFS4 the only needed daemons are nfsd and idmapd. And the
>    only accesible port from the outside is 2049, for nfsd.
>    I have tried to strip down my nfs server (-N 2 -N 3 -U),
>    but rpcinfo still gives me:
>
> annwn:~# rpcinfo -p localhost
>     program vers proto   port  service
>      100000    4   tcp    111  portmapper
>      100000    3   tcp    111  portmapper
>      100000    2   tcp    111  portmapper
>      100000    4   udp    111  portmapper
>      100000    3   udp    111  portmapper
>      100000    2   udp    111  portmapper
>      100024    1   udp  48461  status
>      100024    1   tcp  37515  status
>      100021    1   udp  38583  nlockmgr
>      100021    3   udp  38583  nlockmgr
>      100021    4   udp  38583  nlockmgr
>      100021    1   tcp  37873  nlockmgr
>      100021    3   tcp  37873  nlockmgr
>      100021    4   tcp  37873  nlockmgr
>      100003    4   tcp   2049  nfs
>      100005    1   udp  45341  mountd
>      100005    1   tcp  58639  mountd
>
>    disabling portampper and mountd is just a matter of initscripts
>    requirements, but how can I disable nlockmgr ? It isn't needed for
>    NFS4, isn't it ? Nor portmapper nor mountd...

Strictly speaking, portmapper is not required for NFSv4 service. 
However, the NFS infrastructure on Linux is still designed for NFSv2 and 
v3.  There remains some work needed to make portmapper optional for a 
v4-only server.  For now, continue to run it in order to handle kernel 
upcalls.

rpc.mountd is, however, still required on Linux NFSv4 servers.  Although 
NFSv4 clients do not contact the server's mountd, the kernel's NFS 
server performs upcalls to rpc.mountd to manage export information.  You 
can firewall off the mountd service on the server without affecting 
NFSv4 clients.  Recent versions of rpc.mountd accept command line 
options that disable the mountd network service while still handling 
kernel upcalls.

And, as long as lockd is running, you will need to keep rpc.statd 
around.  Again, you can firewall this service so that it is not exposed 
on the network, but it must continue to be available to handle kernel 
upcalls.  This is something we hope to address eventually as part of the 
lockd work Bruce mentioned.
