From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] Three more IPv6-related mountd patches
Date: Wed, 05 May 2010 15:39:43 -0400
Message-ID: <4BE1C97F.6030108@RedHat.com>
References: <20100503192041.29316.35846.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1947 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754731Ab0EETjt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 May 2010 15:39:49 -0400
In-Reply-To: <20100503192041.29316.35846.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/03/2010 03:23 PM, Chuck Lever wrote:
> Hi Steve-
> 
> Here are two clean-up patches, and one patch that modifies the
> nfs_client struct so it can store both IPv4 and IPv6 addresses
> concurrently.
> 
> ---
> 
> Chuck Lever (3):
>       mountd/exportfs: Make m_addrlist field a nfs_sockaddr
>       libexport.a: Clean up client_add()
>       libexport.a: Refactor client_init()
> 
> 
>  support/export/client.c    |  158 ++++++++++++++++++++++++++------------------
>  support/export/nfsctl.c    |   17 ++++-
>  support/include/exportfs.h |   50 +++++++++++++-
>  utils/mountd/auth.c        |    2 -
>  utils/mountd/cache.c       |    3 +
>  5 files changed, 158 insertions(+), 72 deletions(-)
> 
All three committed and pushed...

steved.
