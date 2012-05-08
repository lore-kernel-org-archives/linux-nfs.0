Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754689Ab2EHOIX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 May 2012 10:08:23 -0400
Message-ID: <4FA928BE.1070208@RedHat.com>
Date: Tue, 08 May 2012 10:07:58 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        NeilBrown <neilb@suse.de>, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/5] mountd: fix export upcall failure in use_ipaddr case.
References: <1335995775-12009-1-git-send-email-bfields@redhat.com> <1335995775-12009-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1335995775-12009-2-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/02/2012 05:56 PM, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> After 0509d3428f523 "mountd: Replace "struct hostent" with "struct
> addinfo"", the export upcall fails in the use_ipaddr case.
> 
> I think we never noticed because a) the use_ipaddr case is rarer than
> the !use_ipaddr case, and b) the nfsd_fh upcall does a preemptive export
> downcall that renders the nfsd export call unnecessary in some cases.
> 
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
All 5 committed....

steved.

> ---
>  utils/mountd/cache.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index ac9cdbd..cf07b56 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -1064,6 +1064,7 @@ static void nfsd_export(FILE *f)
>  			goto out;
>  		ai = client_resolve(tmp->ai_addr);
>  		freeaddrinfo(tmp);
> +		if (!ai)
>  			goto out;
>  	}
>  
