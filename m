From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 00/10] mount.nfs support for netids
Date: Fri, 11 Dec 2009 16:17:54 -0500
Message-ID: <4B22B702.5040303@RedHat.com>
References: <20091208175128.2544.457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16985 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755844AbZLKVRv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Dec 2009 16:17:51 -0500
In-Reply-To: <20091208175128.2544.457.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/08/2009 12:59 PM, Chuck Lever wrote:
> Hi Steve-
> 
> For 2.6.33, Trond has included Jeff's patch that adds support to the
> kernel NFS client for "proto=netid."  Here are the user space changes
> we think are necessary to complete this support.  See:
> 
>   https://bugzilla.redhat.com/show_bug.cgi?id=479350
> 
> This series has seen some light testing here, and Jeff is planning to
> do more of his own independent testing.
> 
> Note that last patch in the series has a rather full set of updates
> to nfs(5) that document NFS client side support for NFS over IPv6,
> including support for "proto=netid."
> 
> Please have a look and let me know what you think.
Committed... 

I did some regression testing and didn't find any problems... 

steved.
