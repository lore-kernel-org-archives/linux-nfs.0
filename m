Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18035 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754000Ab1KVLif convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Nov 2011 06:38:35 -0500
Message-ID: <1321961913.3323.67.camel@lade.trondhjem.org>
Subject: Re: NFS TCP race condition with SOCK_ASYNC_NOSPACE
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andrew Cooper <andrew.cooper3@citrix.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Date: Tue, 22 Nov 2011 13:38:33 +0200
In-Reply-To: <4ECA94F9.4090503@citrix.com>
References: <4EC6A681.30902@citrix.com>
	  <1321642368.2653.35.camel@lade.trondhjem.org> <4EC6AC47.60404@citrix.com>
	 <1321643673.2653.41.camel@lade.trondhjem.org> <4EC6B82B.3000701@citrix.com>
	 <4ECA94F9.4090503@citrix.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-11-21 at 18:14 +0000, Andrew Cooper wrote: 
> Following some debugging, I believe that the attached patch fixes the
> problem.
> 
> Simply returning EAGAIN is not sufficient, as the task does not get
> requeued, and times out 13 seconds later (as per our mount options). 
> Setting the SOCK_ASYNC_NOSPACE bit causes the requeue to happen.
> 
> I realize that this is a gross hack and I should probably not be using
> SOCK_ASYNC_NOSPACE in that way.  Is there a better way to achieve the
> same solution?
> 

What you are doing will cause the request to be put to sleep with no
guarantee that it will ever be woken up. Why would we want to do that if
there is no report of a tcp window/buffer space congestion?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

