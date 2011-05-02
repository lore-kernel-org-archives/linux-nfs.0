Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48338 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757232Ab1EBJSQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2011 05:18:16 -0400
Received: by wwa36 with SMTP id 36so6145078wwa.1
        for <linux-nfs@vger.kernel.org>; Mon, 02 May 2011 02:18:15 -0700 (PDT)
Message-Id: <D9185CC9-D7C7-442F-B93D-FF4520EF3991@gmail.com>
From: David McGiven <davidmcgivenn@gmail.com>
To: linux-nfs@vger.kernel.org
In-Reply-To: <1304096044.3654.8.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: Linux to Netapp -> Is UDP over WAN safe as long as I use "sync, hard and intr" ?
Date: Mon, 2 May 2011 11:18:04 +0200
References: <D158BE8E-BEDC-43EF-9C6C-48668AA6F5DF@gmail.com> <20AFBC51-7103-47E9-825A-A52B4FCA08B6@oracle.com> <6FF9D79F-27E7-49E5-AE4D-A5A17C8F1403@gmail.com> <1304096044.3654.8.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi Trond,

You were right in that auto negotiation was the root of the problems,  
but only some of them.

I did :
ethtool -s eth0 duplex full autoneg off speed 100
[235557.010306] igb: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow  
Control: None

Seeing a big TCP performance boost (now it equals the UDP speed).

But I still have serious problems. I get :
[235809.364907] INFO: task dd:5858 blocked for more than 120 seconds.
[235809.377710] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"  
disables this message.
[...]

Trond, I think you were working with that with Ubuntu people right ?

I am using latest Ubuntu 10.04.2 kernel : 2.6.32-31-server

I might fix this bug with newer kernels or patches, but there's  
another thing I cannot fix :

I get lots of :
nfs: server.dom.com is not responding, still trying

So I guess I will stick to default ethernet settings and UDP. It might  
not be the fastest option, but it's the most trouble free setup (I  
cross my fingers ...)

Thanks again.

Best,
David

On 29/04/2011, at 18:54, Trond Myklebust wrote:

> On Fri, 2011-04-29 at 17:52 +0200, David McGiven wrote:
>> Chuck,
>>
>> Thank you very much for the advice. I'm currently using wsize and
>> rsize of 1024 to avoid IP fragmentation. Strangely, UDP performs much
>> faster compared to TCP, no matter the size of rsize/wsize. I am
>> puzzled about that, but ...
>>
>> The problem with the network troubleshoot is that I cannot change
>> anything in the path between the client and the server : 2 routers  
>> and
>> a CISCO PIX (I don't know if it's one of this 2 hops or it's
>> invisible, but it's there for sure). While researching this problem
>> I've noticed that iperf shows extremely slow speed from client to
>> server LAN segments, while in the opposite way the speed is ok.
>> There's definitely something wrong there but I cannot change it
>> neither complain, so, let UDP be it, I'm satisfied enough with the
>> speed I get with rsize/wsize=1024. My main concern was about data
>> corruption.
>
> Have you checked the autonegotiation settings on your NIC? 'ethtool
> eth0' is your friend...
>
> -- 
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

