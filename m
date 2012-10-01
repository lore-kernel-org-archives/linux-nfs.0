Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:47624 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752022Ab2JAOGV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2012 10:06:21 -0400
Message-ID: <5069A345.3060807@parallels.com>
Date: Mon, 1 Oct 2012 18:05:57 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bharrosh@panasas.com" <bharrosh@panasas.com>,
        "steved@redhat.com" <steved@redhat.com>
Subject: Re: [PATCH 0/2] nfsd: add a usermodehelper upcall for client id tracking
References: <1349092298-23872-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1349092298-23872-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

01.10.2012 15:51, Jeff Layton пишет:
> - Do we need to switch to a different mount namespace somehow based on
>    the net namespace? Eventually we want to allow nfsd to run in a
>    container. At some point we'll need a mechanism to ensure that the
>    upcall runs within the correct container. Stanislav, I'd appreciate
>    your input here...

Hello, Jeff.
As far as I can see - yes, we have to switch to desired mount namespace in 
kernel (because we can't do this in user namespace).
Moreover, for NFSd mount namespace looks even more important than net namespace. 
I.e. we can't share one NFSd between mount namespaces (at least, I don't 
understand how to do this safely).
So, if we are going to have NFSd per container, we have to tie NFSd and mount 
namespace somehow.
Having one NFSd for more than one network namespace looks feasible. But we have 
some races with creation and destruction of service per-net transports, and 
Bruce was suggesting to think about maybe we can just simplify all that stuff 
and create service per network namespace.

BTW, is it possible to split service (trasports, etc.) and it's "executors" 
(kernel threads)? If we could do it, then it would be really easy to create as 
many services (with it's unique namespaces combination) as required and teach 
"executors" to switch to desired namespaces while handling service requests.

-- 
Best regards,
Stanislav Kinsbursky
