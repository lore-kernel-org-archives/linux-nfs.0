Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35818 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757934Ab3CYOQt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 10:16:49 -0400
Message-ID: <51505C4F.2060803@RedHat.com>
Date: Mon, 25 Mar 2013 10:16:47 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 00/10] gssd clean-ups for nfs-utils
References: <20130312203105.2478.88903.stgit@seurat.1015granger.net>
In-Reply-To: <20130312203105.2478.88903.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/03/13 16:36, Chuck Lever wrote:
> I've been working on several fixes and clean-ups in response to an
> issue reported by Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>.
> The thread is archived here:
> 
>  http://www.spinics.net/lists/linux-nfs/msg35306.html
> 
> There were two suggestions in that thread:
> 
>  1.  Clarify rpc.gssd(8)
> 
>  2.  Implement a gssd option to name a credential file where
>      machine credentials can be found
> 
> This series implements the first suggestion along with a number of
> clean-ups I found while working on this code.  The second suggestion
> has been dropped for the moment.
>       
> I had this series with me at Connectathon, and did some light
> testing there.  This series is ready to be merged into
> nfs-utils.
> 
> Changes since v1:
> 
>   o  Acks from Bruce
>   o  Restored part of the comment documenting
>      gssd_find_existing_krb5_ccache()
>   o  Dropped the patch adding the "-c" option to rpc.gssd.
>      This issue will be revisited soon.
> 
> ---
> 
> Chuck Lever (10):
>       gssd: gethostname(3) returns zero or -1, not an errno
>       gssd: Fix whitespace nits
>       gssd: Clean up gssd_setup_krb5_user_gss_ccache()
>       gssd: Update description of "-l" option
>       gssd: Clarify use of the term "machine credentials" in rpc.gssd(8)
>       gssd: Provide an introduction in gssd(8)
>       gssd: gssd.man is missing a description of the "-M" option
>       gssd: Use italics for option values and pathnames
>       mountd: make local functions in v4root.c static
>       mountd: remove unused variable
> 
> 
>  utils/gssd/gssd.c      |    2 
>  utils/gssd/gssd.man    |  310 +++++++++++++++++++++++++++++++++++-------------
>  utils/gssd/gssd_proc.c |   12 +-
>  utils/gssd/krb5_util.c |   20 ++-
>  utils/mountd/cache.c   |    2 
>  utils/mountd/v4root.c  |    6 +
>  6 files changed, 244 insertions(+), 108 deletions(-)
> 
All Committed...

steved.
