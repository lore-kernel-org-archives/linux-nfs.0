From: Enrico Weigelt <weigelt-EU+a56NjgY8@public.gmane.org>
Subject: Re: portmap -> map db entirely in filesystem
Date: Mon, 26 May 2008 23:11:09 +0200
Message-ID: <20080526211108.GA22544@nibiru.local>
References: <20080513195831.GA18915@nibiru.local> <DCFA5A55-22F0-4C03-9877-E8DC80F57CB5@oracle.com>
Reply-To: weigelt-EU+a56NjgY8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from s15216962.onlinehome-server.info ([217.160.22.205]:35404 "EHLO
	s15216962.onlinehome-server.info" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755056AbYEZVL3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 May 2008 17:11:29 -0400
Received: (from uucp@localhost)
	by s15216962.onlinehome-server.info (8.13.3/8.13.3) with UUCP id m4QLBRpv009260
	for linux-nfs@vger.kernel.org; Mon, 26 May 2008 23:11:27 +0200
Received: (from weigelt@localhost)
	by nibiru.metux.de (8.12.10/8.12.10) id m4QLB97d030804
	for linux-nfs@vger.kernel.org; Mon, 26 May 2008 23:11:09 +0200
In-Reply-To: <DCFA5A55-22F0-4C03-9877-E8DC80F57CB5@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Chuck Lever <chuck.lever@oracle.com> wrote:

Hi,

> Well, first of all we are moving away from portmap these days since we  
> need to support IPv6.  We currently have an rpcbind implementation  
> that is ported from Solaris.

I had a look at it a few days ago ... far too fat for me.
If you really need Ipv6 support on portmap, let's just do it.
Shouldn't be such a big job.

> But it would make sense to keep the rpcbind service completely in 
> the kernel. 

And move more bloat into the kernel ? Isn't it big enough yet ?

Actually, I'm working on making the kernel smaller, moving 
several things into userspace.

> That way the kernel RPC services could register with the rpcbind 
> database directly, and we wouldn't have to worry about reregistering 
> running RPC services because of a daemon restart.

Wouldn't it be easier to just fix the portmapper ? 

> There's no need to involve permanent storage for rpcbind. 

There is even no need to have it running all the time, start on
demand is enough for some workloads (eg. in embedded/smalldev 
environments)

> Local user-space RPC services might then register via an ioctl() 

Oh no, please no more ioctl()'s. We should start getting rid of 
that old relics.

> (or other special interface) instead of an actual RPC.  

And require an rewrite of each RPC service ? What a funny idea ;-o
Making a originally IP-based service locally dependent sounds 
like a strange step back to me ...


cu
-- 
---------------------------------------------------------------------
 Enrico Weigelt    ==   metux IT service - http://www.metux.de/
---------------------------------------------------------------------
 Please visit the OpenSource QM Taskforce:
 	http://wiki.metux.de/public/OpenSource_QM_Taskforce
 Patches / Fixes for a lot dozens of packages in dozens of versions:
	http://patches.metux.de/
---------------------------------------------------------------------
