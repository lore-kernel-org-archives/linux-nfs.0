From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] Two small mountd IPv6 patches
Date: Thu, 15 Apr 2010 09:00:24 -0400
Message-ID: <4BC70DE8.1020908@RedHat.com>
References: <20100412195538.9839.76495.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42785 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753567Ab0DONAa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Apr 2010 09:00:30 -0400
In-Reply-To: <20100412195538.9839.76495.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/12/2010 03:57 PM, Chuck Lever wrote:
> Steve-
> 
> Two quick clean-ups that prepare for mountd/exportfs IPv6 support.
> 
> ---
> 
> Chuck Lever (2):
>       libexport.a: Add helper for populating m_addrlist[]
>       libexport.a: Reduce code duplication in client_init()
> 
> 
>  support/export/client.c |   41 ++++++++++++++++++++++-------------------
>  1 files changed, 22 insertions(+), 19 deletions(-)
> 
Committed... 

steved.
