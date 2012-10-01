Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44374 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751342Ab2JAOMl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 10:12:41 -0400
Date: Mon, 1 Oct 2012 10:12:39 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bharrosh@panasas.com" <bharrosh@panasas.com>,
        "steved@redhat.com" <steved@redhat.com>
Subject: Re: [PATCH 0/2] nfsd: add a usermodehelper upcall for client id
 tracking
Message-ID: <20121001141239.GA18400@fieldses.org>
References: <1349092298-23872-1-git-send-email-jlayton@redhat.com>
 <5069A345.3060807@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <5069A345.3060807@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 01, 2012 at 06:05:57PM +0400, Stanislav Kinsbursky wrote:
> 01.10.2012 15:51, Jeff Layton пишет:
> >- Do we need to switch to a different mount namespace somehow based on
> >   the net namespace? Eventually we want to allow nfsd to run in a
> >   container. At some point we'll need a mechanism to ensure that the
> >   upcall runs within the correct container. Stanislav, I'd appreciate
> >   your input here...
> 
> Hello, Jeff.
> As far as I can see - yes, we have to switch to desired mount
> namespace in kernel (because we can't do this in user namespace).
> Moreover, for NFSd mount namespace looks even more important than
> net namespace. I.e. we can't share one NFSd between mount namespaces
> (at least, I don't understand how to do this safely).
> So, if we are going to have NFSd per container, we have to tie NFSd
> and mount namespace somehow.
> Having one NFSd for more than one network namespace looks feasible.
> But we have some races with creation and destruction of service
> per-net transports, and Bruce was suggesting to think about maybe we
> can just simplify all that stuff and create service per network
> namespace.
> 
> BTW, is it possible to split service (trasports, etc.) and it's
> "executors" (kernel threads)? If we could do it, then it would be
> really easy to create as many services (with it's unique namespaces
> combination) as required and teach "executors" to switch to desired
> namespaces while handling service requests.

I'm sure it is possible, and would be more efficient than requiring
(number of containers) * (number of threads per container) threads.

But I think it's also a little more complicated to do, and that to start
off we'd be better off just keeping the services entirely separate.

--b.
