From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount: Mount should retry unreachable hosts
Date: Fri, 19 Mar 2010 16:15:04 -0400
Message-ID: <4BA3DB48.8010506@RedHat.com>
References: <20100310214136.3002.78499.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51614 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013Ab0CSUPL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Mar 2010 16:15:11 -0400
In-Reply-To: <20100310214136.3002.78499.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/10/2010 04:42 PM, Chuck Lever wrote:
> Currently if a server is up but not responding (ie, it answers ARP
> requests, but not NFS or RPC requests), mount retries or backgrounds
> itself waiting for the server.
> 
> If the server is not responding on the network at all, mount fails
> the mount request immediately.
> 
> Users might find it more useful if mount retried in both cases.
> 
> Note that this change means attempting to mount using a misspelled
> server name will "hang" for the retry amount.  I suppose the error
> message isn't very helpful whether it fails immediately or waits
> a couple of minutes, though I imagine that an unreachable server is a
> much more common occurrence than a misspelling.
> 
> Reported-by: Daniel Goering <g_daniel@gmx.net>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
Committed... 

steved.
