From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Client performance questions
Date: Tue, 11 Dec 2007 12:03:01 -0500
Message-ID: <20732321-A9D9-4A20-8337-C8CBEC988A57@oracle.com>
References: <0a15723c4b267d4eb8b5ad05800315c0@swip.net> <e7ca40f70712110737x698b35a8g32377485cc7d8a16@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "Fredrik Lindgren" <fli-FpffG6+3qsA@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Aaron Wiebe" <epiphani@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:11214 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752878AbXLKRFI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 12:05:08 -0500
In-Reply-To: <e7ca40f70712110737x698b35a8g32377485cc7d8a16-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 11, 2007, at 10:37 AM, Aaron Wiebe wrote:
> Greetings - we also run mail on NFS.
>
> On Dec 10, 2007 4:52 PM, Fredrik Lindgren <fli-FpffG6+3qsA@public.gmane.org> wrote:
>
>> Mount options on the clients are as follows:
>> bg,intr,timeo=600,retrans=2,vers=3,proto=tcp,rsize=32768,wsize=32768
>>
>> MTU is 9000 bytes and they're all in the same Gigabit Ethernet  
>> switch along
>> with the NFS server.
>>
>> Each client seems to be doing somewhere around 3500 NFS ops/s  
>> during peak hours.
>> Average read/write size seems to be around 16kb, although these  
>> operations make
>> up just ~30% of the activity.
>
> This suggestion may get some controversy here - however it is what we
> have done and its made a difference.

Although TCP is generally our recommendation, your settings are  
reasonable.  I would complain only if you were using "soft" !  :-)

> Try switching to UDP.  We've found that with mail applications, a
> large amount of the transactions are small, and the windowing of TCP
> actually slows things down.

If windowing is a problem, have you tried boosting the default size  
of the socket send and receive buffers on both ends?

>   This is what we use for mount options:
>
> rw,v3,rsize=8192,wsize=8192,acregmin=15,acregmax=120,acdirmin=45,acdir 
> max=120,hard,lock,proto=udp
>
> With a 9000 byte jumbo frame, this will restrict every datagram into a
> single frame

Disclaimer: kids, if you try this at home, it will work well as long  
as the network links between your client and server all run at the  
same speed (ie. it will not work well if you have for example 100Mb  
connections from client to switch and GbE from switch to server).

> - also, you may want to play with sysctl
> sunrpc.udp_slot_table_entries.  We keep this at 32., but it can go
> right up to 128.
>
> In our case, our issues with this config are nearly exclusively in
> keeping our server side storage fast and responsive.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
