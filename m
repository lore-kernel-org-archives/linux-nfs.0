From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS/Kernel Problem: getfh failed: Operation not permitted
Date: Thu, 30 Mar 2006 09:25:20 -0500
Message-ID: <1143728720.8074.41.camel@lade.trondhjem.org>
References: <Pine.LNX.4.64.0603300813270.18696@p34>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932228AbWC3OZu@vger.kernel.org>
To: Justin Piszcz <jpiszcz@lucidpixels.com>
In-Reply-To: <Pine.LNX.4.64.0603300813270.18696@p34>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 2006-03-30 at 08:19 -0500, Justin Piszcz wrote:
> The error is: rpc.mountd: getfh failed: Operation not permitted
> 
> In order to fix this error, someone needs to run these commands on each 
> nfs server.
> 
>     40  service nfs stop
>     41  rm -f /var/lib/nfs/etab /var/lib/nfs/rmtab /var/lib/nfs/state 
> /var/lib/xtab
>     42  touch /var/lib/nfs/etab /var/lib/nfs/rmtab /var/lib/nfs/state 
> /var/lib/xtab
>     43  chmod 644 /var/lib/nfs/etab /var/lib/nfs/rmtab /var/lib/nfs/state 
> /var/lib/xtab
>     44  service nfs start
> 
> http://www.ccs.neu.edu/home/johan/personal/linux.html
> 
> This issue seems to be more of an NFS issue than a kernel one, but I was 
> wondering what other people had to say about it.  There are a lot of 
> responses and questions concerning this error on google, but VERY few 
> people have a response or method of fixing it, much less finding a 
> permanent fix.
> 
> Has anyone found a fix or work-around that does not require restarting 
> NFS?

Very few people ought to be running RH-9 out there given that the
official support expired several years ago.

Are you still seeing this problem with 2.6 kernels with /proc/fs/nfsd
properly mounted?

Cheers,
  Trond
