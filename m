Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:46475 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309Ab3BUTMK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2013 14:12:10 -0500
Message-ID: <51267179.6060002@panasas.com>
Date: Thu, 21 Feb 2013 21:11:53 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: NFSv4 on Linux on Linux mailing mailing list <nfsv4@ietf.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] Connectathon 2013 talks
References: <8BD8BE06-E201-4704-AD4E-DB768F37255F@oracle.com>
In-Reply-To: <8BD8BE06-E201-4704-AD4E-DB768F37255F@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/25/2013 06:00 PM, Chuck Lever wrote:
> Hi-
> 
> I'm organizing the talks at this year's Connectathon event.  
> 
>   http://hub.opensolaris.org/bin/view/Community+Group+nfs/Connectathon13
> 
> If you are interested in presenting, please contact me with details
> before Monday, February 25 (but the sooner the better). Remember that
> the Connectathon test floor is covered by NDA, but the talks are open
> to the public.
> 

Hi Chuck, as we said at the con-call here is my email

> 
> For each talk, please provide:
> 
>  o  A title
> 

title: How to solve the Linux-Client LAYOUT_COMMIT vs LAYOUT_GET deadlock

>  o  An abstract (a couple of sentences or so)
> 

abstract:
	* I will describe the current problem we have since Kernel 3.5.
	* I will show how I fix it for now, though in a way that violates the STD
	  (It actually does works with all current pnfs servers I know of)
	* I will introduce two possible solutions I can see, for this.

	And would like people to:
		1. See if there are more possible solutions
		2. Choose (Trond) which way we would like to go, and I can start
		   coding for that.

>  o  Who exactly is going to present (with e-mail if possible)
> 

presentor: Me

>  o  How long you think you need
> 

I hope not more then 1 hour at most, or even less

>  o  Whether you need more than just a projector
> 

No that will be just fine.

> 
> Thanks!
> 

Thanks in advance
Boaz

