Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51586 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757303Ab1K3Amz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 19:42:55 -0500
Message-ID: <4ED57C04.6010905@panasas.com>
Date: Tue, 29 Nov 2011 16:42:44 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Marc Eshel <eshel@almaden.ibm.com>, Peng Tao <bergwolf@gmail.com>,
        <bhalevy@tonian.com>, Garth Gibson <garth@panasas.com>,
        Fred Isaman <iisaman@netapp.com>, <linux-nfs@vger.kernel.org>,
        Matt Benjamin <matt@linuxbox.com>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com> 	   <4ED54FE4.9050008@panasas.com> <4ED55399.4060707@panasas.com>  <1322603848.11286.7.camel@lade.trondhjem.org> <4ED55F78.205@panasas.com>  <1322606842.11286.33.camel@lade.trondhjem.org> 	 <4ED563AC.5040501@panasas.com>  <1322609431.11286.56.camel@lade.trondhjem.org>  <OFF7649CC5.E17B103B-ON88257957.0081DB7B-88257957.0082E12A@us.ibm.com> <1322611689.11286.72.camel@lade.trondhjem.org>
In-Reply-To: <1322611689.11286.72.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 04:08 PM, Trond Myklebust wrote:
> On Tue, 2011-11-29 at 15:49 -0800, Marc Eshel wrote: 
>> The only 1 cent that I can add to this argument is that I was led to 
>> believe by you and others that Linux kernel don't add functionality on the 
>> client side that is not supported on the server side. Last time I made 
>> this point I was told that it is ok if they are of by a version or two. 
>> You made it clear that this is no longer true and that the Linux client 
>> and server are now independent of each other. I spent time working on the 
>> server side believing that the client and server will progress more or 
>> less together, disappointed to find out that it is not the case any more.
>> Marc. 
> 
> I don't know how to manage layout segments in a way that meets the pNFS
> goals of scalability and performance, and neither you nor the pNFS spec
> have told me how to do this.

This I do not understand. What is the problem with current implementation?
I use these segments every day and see performance through the roof. I'm
able to saturate any cluster I throw at it and am happy as bliss. And it's
surprisingly stable. My IO flow is full of segments and recalls, and it
works surprisingly well.

(I intend to send some hard numbers next week. But believe me they are
 amassing)

> 
> If IBM wants a client that implements layout segments, then it is _your_
> responsibility to: 
>      A. Convince me that it is an implementable part of the spec. 

Sure

>      B. Provide me with an implementation that deals all with the
>         concerns that I have.
> 

What concerns are that. If it's the COMMITs then I think I know what
todo.

> IOW: nobody has ever promised IBM that the community would do all your
> client work for you. EMC, NetApp and Panasas have implemented (most of)
> the bits that they cared about; any bits that they haven't implemented
> and that you care about are up to you.
> 

I think I'll pick this up. Me or some interested people I know. Until now
it was said that Fred is working on that and we waited patiently for him
to do it out of respect and to save any wasted efforts. But if it's dropped
on the floor, then I'm all the gladder to pick it up. Just give me the green
light because I do not want to duplicate efforts.

Thanks
Heart
