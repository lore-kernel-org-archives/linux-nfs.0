From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/5] More mountd patches
Date: Tue, 24 Aug 2010 07:24:49 -0400
Message-ID: <4C73AC01.7050505@RedHat.com>
References: <20100823170552.2123.43124.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31103 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751351Ab0HXLYw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Aug 2010 07:24:52 -0400
In-Reply-To: <20100823170552.2123.43124.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/23/2010 01:10 PM, Chuck Lever wrote:
> Hi Steve-
> 
> Here are some clean-up and bug fix patches I'd like you to apply
> before I start sending the IPv6 series.
> 
> The first two fix a bug reported by Neil.  I posted these to you a
> few weeks ago, but I don't see them in your repo yet.
> 
> The next bug is the statd DNS bug that Ben Hutchings reported months
> ago.  We just got confirmation that the patch does indeed fix the
> problem.
> 
> The last two patches are two clean-ups from my IPv6 series.  The first
> is uncontroversial.  The second converts exportfs to use xlog() more
> idiomatically, allowing debugging messages in libexport.a to be
> enabled from the exportfs command line.
> 
> ---
> 
> Chuck Lever (5):
>       exportfs: Use xlog() for error reporting
>       exportfs: exportfs.c no longer needs #include "xmalloc.h"
>       statd: statd fails to monitor if no reverse mapping of mon_name exists
>       libexport: Fix IP address check in check_netgroup()
>       libexport: Add a common exit label to check_netgroup()
> 
> 
>  support/export/client.c   |   44 ++++++++++++++++++++++++--------
>  utils/exportfs/exportfs.c |   62 ++++++++++++++++++++++++---------------------
>  utils/statd/hostname.c    |    4 ++-
>  3 files changed, 69 insertions(+), 41 deletions(-)
> 
All five have been committed... Thanks!

steved.
