From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] server's statd and lockd will not sync after its nfslock
	restart
Date: Tue, 15 Dec 2009 07:41:21 -0500
Message-ID: <20091215124121.GB32017@fieldses.org>
References: <4B275EA3.9030603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	NFSv3 list <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54064 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750783AbZLOMlZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Dec 2009 07:41:25 -0500
In-Reply-To: <4B275EA3.9030603@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 15, 2009 at 06:02:11PM +0800, Mi Jinlong wrote:
> Hi,
> 
> When testing the NLM at the latest kernel(2.6.32),  i find a bug.
> When a client hold locks, after server restart its nfslock service, 
> server's statd will not synchronize with lockd.
> If server restart nfslock twice or more, client's lock will be lost.
> 
> Test process:
> 
>   Step1: client open nfs file.
>   Step2: client using fcntl to get lock.
>   Step3: server restart it's nfslock service.

I don't know what you mean; what did you actually do in step 3?

--b.

> 
> After step3, server's lockd records client holding locks, but statd's 
> /var/lib/nfs/statd/sm/ directory is empty. It means statd and lockd are 
> not sync. If server restart it's nfslock again, client's locks will be lost.
> 
> The Primary Reason:
> 
>   At step3, when client's reclaimed lock request is sent to server, 
> client's host(the host struct) is reused but not be re-monitored at
> server's lockd. After that, statd and lockd are not sync.
> 
> Question:
> 
> In my opinion, if lockd is allowed reuseing the client's host, it should
> send a SM_MON to statd when reuse. If not allowed, the client's host should 
> be destroyed immediately.
>  
> What should lockd to do?  Reuse ? Destroy ? Or some other action?
> 
> 
> thanks,
> 
> Mi Jinlong
> 
