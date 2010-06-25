Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:55887 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253Ab0FYSvT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jun 2010 14:51:19 -0400
Subject: Re: Problem: Clients freeze on transfer of large files, w gigabit
 lan
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jasper Mackenzie <jasper.mackenzie@gmail.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <op.vet93peko2qfwp@foundation>
References: <op.vet93peko2qfwp@foundation>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 25 Jun 2010 14:51:13 -0400
Message-ID: <1277491873.6141.23.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-06-25 at 16:44 +1200, Jasper Mackenzie wrote:
> Good Day All,
>     I and many others have been plagued by a problem that can be summarised
> as follows:
> 
> Client hangs upon copying of large files TO the server. Transfer begins
> quickly then hangs, sometimes taking the client o/s with it, until
> transfer starts again. In less extreme cases transfer is sporadic.
>     I am using nfs4 w gigabit nics.
> 
>     My experience is with debian and ubuntu clients and servers, as such I
> started a thread on ubuntu forum to find similar cases to give you more to
> work from:
> http://ubuntuforums.org/showthread.php?p=9269703
>     It appears that this problem is not restricted to ubuntu and exists in  
> at
> least fedora and redhat as well.
> 
> More details and user experience is in the above forum thread.
> 
>     Help in solving this would be greatly appreciated.

Could this perhaps be related to the following bugzilla entry?
    https://bugzilla.kernel.org/show_bug.cgi?id=16213

If so, then could you please try the proposed fix and see if it helps.

Cheers
  Trond

