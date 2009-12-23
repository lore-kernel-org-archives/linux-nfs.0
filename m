From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] libnsm.a: Move the sm_inter XDR pieces to libnsm.a
Date: Wed, 23 Dec 2009 14:40:44 -0500
Message-ID: <4B32723C.1090002@RedHat.com>
References: <20091215163102.14858.69699.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chris.Mason@oracle.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752167AbZLWTkt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Dec 2009 14:40:49 -0500
In-Reply-To: <20091215163102.14858.69699.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/15/2009 11:33 AM, Chuck Lever wrote:
> Clean up: Move the .x file and the generated C source for NSM to
> libnsm.a, echoing the architecture of mountd and exportfs.  This makes
> the NSM protocol definitions, data types, and XDR routines available
> to be shared across nfs-utils.
> 
> This simplifies the addition of other NSM-related code (for example
> for testing or providing clustering support), and also provides
> public data type definitions that can be used to make sense of the
> contents of statd's on-disk database.
> 
> Because sim_sm_inter.x still resides in utils/statd, I've left some
> rpcgen build magic in utils/statd/Makefile.am.
> 
> This is an internal organization change only.  This patch should not
> affect code behavior in any way.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> Steve-
> 
> Another in the statd IPv6 series.
> 
Committed...

steved.
