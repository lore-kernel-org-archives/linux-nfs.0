From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] Two short fixes for sm-notify
Date: Fri, 19 Mar 2010 16:05:18 -0400
Message-ID: <4BA3D8FE.7040903@RedHat.com>
References: <20100315174453.2586.40876.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37575 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077Ab0CSUFZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Mar 2010 16:05:25 -0400
In-Reply-To: <20100315174453.2586.40876.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/15/2010 01:51 PM, Chuck Lever wrote:
> Hi Steve-
> 
> These address two minor shortcomings when sending SM_NOTIFY requests
> during reboot recovery.  Please consider these for the next nfs-utils
> release.
> 
> ---
> 
> Chuck Lever (2):
>       sm-notify: Send fully-qualified and unqualified mon_names
>       sm-notify: Use my_name when sending SM_NOTIFY requests
> 
> 
>  utils/statd/sm-notify.c   |   62 ++++++++++++++++++++++++++++++++++++---------
>  utils/statd/sm-notify.man |   28 +++++++++-----------
>  utils/statd/statd.man     |   14 +---------
>  3 files changed, 64 insertions(+), 40 deletions(-)
> 
Both patches committed... 

steved.
