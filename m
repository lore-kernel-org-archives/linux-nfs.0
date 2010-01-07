From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] showmount bug fixes
Date: Thu, 07 Jan 2010 12:52:08 -0500
Message-ID: <4B461F48.4070906@RedHat.com>
References: <20100107162421.27102.21422.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34208 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752023Ab0AGRwX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 12:52:23 -0500
In-Reply-To: <20100107162421.27102.21422.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/07/2010 11:26 AM, Chuck Lever wrote:
> Hi Steve-
> 
> As promised, a couple of bug fixes for the recent improvements to the
> showmount command.
> 
> ---
> 
> Chuck Lever (2):
>       showmount: Use CLNT_CONTROL for version fallback
Why is calling CLNT_CONTROL() verses calling clnt_create again
so much better?? In between failures the server status could 
change so why not just ping it again?? 

steved.
