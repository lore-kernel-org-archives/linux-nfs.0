From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/4] mountd cleanup
Date: Mon, 22 Mar 2010 10:19:04 -0400
Message-ID: <4BA77C58.9020607@RedHat.com>
References: <20100322003317.30360.18289.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45104 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754693Ab0CVOTq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Mar 2010 10:19:46 -0400
In-Reply-To: <20100322003317.30360.18289.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/21/2010 08:37 PM, Chuck Lever wrote:
> Hi Steve-
> 
> These four patches clean up some spots in libexport.a.  They are
> pre-requisites for mountd/exportfs IPv6 support.
> 
> ---
> 
> Chuck Lever (4):
>       libexport.a: e_fslocdata should be freed with free(3)
>       libexport.a: Fix whitespace damage in support/export/export.c
>       libexport.a: Clean up client_compose() and client_member()
>       libexport.a: Remove dead code
> 
> 
>  support/export/client.c    |   65 ++++++++++++++++++--------------------------
>  support/export/export.c    |   13 +++++----
>  support/include/exportfs.h |    5 +--
>  3 files changed, 36 insertions(+), 47 deletions(-)
> 
Committed... 

steved.
