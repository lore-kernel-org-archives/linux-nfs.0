Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42391 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757217Ab1K3AIM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 19:08:12 -0500
Message-ID: <1322611689.11286.72.camel@lade.trondhjem.org>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Marc Eshel <eshel@almaden.ibm.com>
Cc: Peng Tao <bergwolf@gmail.com>, bhalevy@tonian.com,
        Boaz Harrosh <bharrosh@panasas.com>, Garth Gibson <garth@panasas.com>,
        Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org,
        Matt Benjamin <matt@linuxbox.com>
Date: Tue, 29 Nov 2011 19:08:09 -0500
In-Reply-To: <OFF7649CC5.E17B103B-ON88257957.0081DB7B-88257957.0082E12A@us.ibm.com>
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>
		   <4ED54FE4.9050008@panasas.com> <4ED55399.4060707@panasas.com>
	 <1322603848.11286.7.camel@lade.trondhjem.org> <4ED55F78.205@panasas.com>
	 <1322606842.11286.33.camel@lade.trondhjem.org>
		 <4ED563AC.5040501@panasas.com>
	 <1322609431.11286.56.camel@lade.trondhjem.org>
	 <OFF7649CC5.E17B103B-ON88257957.0081DB7B-88257957.0082E12A@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-11-29 at 15:49 -0800, Marc Eshel wrote: 
> The only 1 cent that I can add to this argument is that I was led to 
> believe by you and others that Linux kernel don't add functionality on the 
> client side that is not supported on the server side. Last time I made 
> this point I was told that it is ok if they are of by a version or two. 
> You made it clear that this is no longer true and that the Linux client 
> and server are now independent of each other. I spent time working on the 
> server side believing that the client and server will progress more or 
> less together, disappointed to find out that it is not the case any more.
> Marc. 

I don't know how to manage layout segments in a way that meets the pNFS
goals of scalability and performance, and neither you nor the pNFS spec
have told me how to do this.

If IBM wants a client that implements layout segments, then it is _your_
responsibility to: 
     A. Convince me that it is an implementable part of the spec. 
     B. Provide me with an implementation that deals all with the
        concerns that I have.

IOW: nobody has ever promised IBM that the community would do all your
client work for you. EMC, NetApp and Panasas have implemented (most of)
the bits that they cared about; any bits that they haven't implemented
and that you care about are up to you.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

