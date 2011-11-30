Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51689 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756637Ab1K3Aue (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 19:50:34 -0500
Message-ID: <4ED57DCF.2070600@panasas.com>
Date: Tue, 29 Nov 2011 16:50:23 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Marc Eshel <eshel@almaden.ibm.com>, Peng Tao <bergwolf@gmail.com>,
        <bhalevy@tonian.com>, Garth Gibson <garth@panasas.com>,
        Fred Isaman <iisaman@netapp.com>, <linux-nfs@vger.kernel.org>,
        Matt Benjamin <matt@linuxbox.com>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com> 		   <4ED54FE4.9050008@panasas.com> <4ED55399.4060707@panasas.com>  <1322603848.11286.7.camel@lade.trondhjem.org> <4ED55F78.205@panasas.com>  <1322606842.11286.33.camel@lade.trondhjem.org> 		 <4ED563AC.5040501@panasas.com>  <1322609431.11286.56.camel@lade.trondhjem.org> 	 <OFF7649CC5.E17B103B-ON88257957.0081DB7B-88257957.0082E12A@us.ibm.com>  <1322611689.11286.72.camel@lade.trondhjem.org>  <OF5755ED9D.CC1FAA6E-ON88257958.00014359-88257958.0001D4D0@us.ibm.com> <1322613425.11286.86.camel@lade.trondhjem.org>
In-Reply-To: <1322613425.11286.86.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 04:37 PM, Trond Myklebust wrote:
> On Tue, 2011-11-29 at 16:20 -0800, Marc Eshel wrote: 
>> You ignored my main point, I was talking about the server side, my point 
>> was that there is nothing to build on on the serve side since the pNFS 
>> Linux server is not happening.
>> Marc.
> 
> Sorry. I misunderstood your concern. As far as I know, the main problem
> there is also one of investment: nobody has stepped up to help Bruce
> write a pNFS server.
> 

I use "OUR" Linux pNFS Server every day, all day. It's there it is written
and it kicks us. We've been working on that for 5 Years now.

The only holding factor is that no one wants to do the final step and
fight the VFS guys to actually push it into Linus.

But it is there and alive in full open-source glory in Benny's tree.

> I'm less worried about this now than I was earlier, because other open
> source efforts are gaining traction (see Ganesha - which is being
> sponsored by IBM, and projects such as Tigran's java based pNFS server).
> The other point is that we've developed client test-rigs that don't
> depend on the availability of a Linux server (newpynfs and the pynfs
> based proxy).
> 

For me I'm testing with the linux Server and it is just there and works
well for me. Better than any other solution I have right now.

> Cheers
>   Trond 
> 

Ciao
Heart
