From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/6] Refactor client_check()
Date: Thu, 08 Apr 2010 11:21:28 -0400
Message-ID: <4BBDF478.1020302@RedHat.com>
References: <20100323165122.4368.43659.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38558 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758732Ab0DHPVd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 11:21:33 -0400
In-Reply-To: <20100323165122.4368.43659.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/23/2010 12:52 PM, Chuck Lever wrote:
> Hi Steve-
> 
> These patches refactor client_check() so that IPv6 support can be
> added down the road.  They should introduce no change in behavior.
> 
> ---
> 
> Chuck Lever (6):
>       libexport.a: replace xlog(L_FATAL) in client_check()
>       libexport.a: Refactor wildcard checking in client_check()
>       libexport.a: Refactor netgroup checking in client_check()
>       libexport.a: Remove unused function client_checkaddr()
>       libexport.a: Factor SUBNETWORK checking out of check_client()
>       libexport.a: Factor FQDN checking out of check_client()
> 
> 
>  support/export/client.c |  204 ++++++++++++++++++++++++++++++-----------------
>  1 files changed, 130 insertions(+), 74 deletions(-)
> 
Committed... 

steved.
