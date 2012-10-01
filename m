Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3337 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751548Ab2JAOwb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2012 10:52:31 -0400
Date: Mon, 1 Oct 2012 10:52:19 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bharrosh@panasas.com" <bharrosh@panasas.com>,
        "steved@redhat.com" <steved@redhat.com>
Subject: Re: [PATCH 0/2] nfsd: add a usermodehelper upcall for client id
 tracking
Message-ID: <20121001105219.4272fd90@corrin.poochiereds.net>
In-Reply-To: <5069A8FA.1060401@parallels.com>
References: <1349092298-23872-1-git-send-email-jlayton@redhat.com>
	<5069A345.3060807@parallels.com>
	<20121001141239.GA18400@fieldses.org>
	<5069A8FA.1060401@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 1 Oct 2012 18:30:18 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> 01.10.2012 18:12, bfields@fieldses.org пишет:
> > On Mon, Oct 01, 2012 at 06:05:57PM +0400, Stanislav Kinsbursky wrote:
> >> 01.10.2012 15:51, Jeff Layton пишет:
> >>> - Do we need to switch to a different mount namespace somehow based on
> >>>    the net namespace? Eventually we want to allow nfsd to run in a
> >>>    container. At some point we'll need a mechanism to ensure that the
> >>>    upcall runs within the correct container. Stanislav, I'd appreciate
> >>>    your input here...
> >>
> >> Hello, Jeff.
> >> As far as I can see - yes, we have to switch to desired mount
> >> namespace in kernel (because we can't do this in user namespace).
> >> Moreover, for NFSd mount namespace looks even more important than
> >> net namespace. I.e. we can't share one NFSd between mount namespaces
> >> (at least, I don't understand how to do this safely).
> >> So, if we are going to have NFSd per container, we have to tie NFSd
> >> and mount namespace somehow.
> >> Having one NFSd for more than one network namespace looks feasible.
> >> But we have some races with creation and destruction of service
> >> per-net transports, and Bruce was suggesting to think about maybe we
> >> can just simplify all that stuff and create service per network
> >> namespace.
> >>
> >> BTW, is it possible to split service (trasports, etc.) and it's
> >> "executors" (kernel threads)? If we could do it, then it would be
> >> really easy to create as many services (with it's unique namespaces
> >> combination) as required and teach "executors" to switch to desired
> >> namespaces while handling service requests.
> >
> > I'm sure it is possible, and would be more efficient than requiring
> > (number of containers) * (number of threads per container) threads.
> >
> > But I think it's also a little more complicated to do, and that to start
> > off we'd be better off just keeping the services entirely separate.
> >
> 
> At first sight, this two solutions (split of service/threads and service per 
> namespace) doesn't look like they can share a lot of code base.
> I believe, that we have to think about mount namespaces during NFSd 
> containerization. And, if I understand you right, when you say about "entirely 
> separated services", you mean separated by networks namespace.
> Separations per mount namespace as a second step will take actually the same 
> time and amount of code, as it would be a first step.
> 
> So, as I can see it, the real question is: do we really want limited (only 
> per-net) NFSd containerisation as soon as possible (and in this case it's much 
> simpler to create NFSd/Lockd service and it's threads per network namespace) or 
> we should skip this step and concentrate on proper implementation from the very 
> beginning (split of service and it's threads and tie NFSd to mount namespace)?
> 

Ok, to bring the discussion back around, I'll note that the current
legacy clientid tracking code doesn't pay any attention to namespaces
either. So I don't think we're missing much by punting on that just
yet.

Once you've hashed out the mount namespace design, we should be able to
make it pay attention to that that without too much trouble.
-- 
Jeff Layton <jlayton@redhat.com>
