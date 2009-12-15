From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] server's statd and lockd will not sync after its nfslock restart
Date: Tue, 15 Dec 2009 10:10:43 -0500
Message-ID: <F9F5EA38-B51C-44A4-9812-873EEE1891C9@oracle.com>
References: <4B275EA3.9030603@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:22450 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbZLOPLu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Dec 2009 10:11:50 -0500
In-Reply-To: <4B275EA3.9030603@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 15, 2009, at 5:02 AM, Mi Jinlong wrote:
> Hi,
>
> When testing the NLM at the latest kernel(2.6.32),  i find a bug.
> When a client hold locks, after server restart its nfslock service,
> server's statd will not synchronize with lockd.
> If server restart nfslock twice or more, client's lock will be lost.
>
> Test process:
>
>  Step1: client open nfs file.
>  Step2: client using fcntl to get lock.
>  Step3: server restart it's nfslock service.

I'll assume here that you mean the equivalent of "service nfslock  
restart".  This restarts statd and possibly runs sm-notify, but it has  
no effect on lockd.

Again, this test seems artificial to me.  Is there a real world use  
case where someone would deliberately restart statd while an NFS  
server is serving files?  I pose this question because I've worked on  
statd only for a year or so, and I am quite likely ignorant of all the  
ways it can be deployed.

> After step3, server's lockd records client holding locks, but statd's
> /var/lib/nfs/statd/sm/ directory is empty. It means statd and lockd  
> are
> not sync. If server restart it's nfslock again, client's locks will  
> be lost.
>
> The Primary Reason:
>
>  At step3, when client's reclaimed lock request is sent to server,
> client's host(the host struct) is reused but not be re-monitored at
> server's lockd. After that, statd and lockd are not sync.

The kernel squashes SM_MON upcalls for hosts that it already believes  
are monitored.  This is a scalability feature.

> Question:
>
> In my opinion, if lockd is allowed reuseing the client's host, it  
> should
> send a SM_MON to statd when reuse. If not allowed, the client's host  
> should
> be destroyed immediately.
>
> What should lockd to do?  Reuse ? Destroy ? Or some other action?

I don't immediately see why lockd should change it's behavior.   
Perhaps statd/sm-notify were incorrect to delete the monitor list when  
you restarted the nfslock service?

Can you show exactly how statd's state (ie it's on-disk monitor list  
in /var/lib/nfs/statd/sm) changed across the restart?  Did sm-notify  
run when you restarted statd?  If so, why didn't the sm-notify pid  
file stop it?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




