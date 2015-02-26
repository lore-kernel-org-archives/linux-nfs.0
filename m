Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753192AbbBZTgY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Feb 2015 14:36:24 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1QJaO6d008373
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 14:36:24 -0500
Message-ID: <54EF75B5.5090808@RedHat.com>
Date: Thu, 26 Feb 2015 14:36:21 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Scott Mayhew <smayhew@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH] mountd: Fix memory leak in getexportent
References: <1424458167-58324-1-git-send-email-smayhew@redhat.com>
In-Reply-To: <1424458167-58324-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/20/2015 01:49 PM, Scott Mayhew wrote:
> Valgrind shows that the memory allocated for ee.e_hostname in
> getexportent() is being leaked.  While there _is_ a call to xfree(), by
> the time it gets called the leak's already happened.  Moving the xfree()
> call so that it occurs before the assignment that overwrites ee fixes
> this.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed! 

steved.

> ---
>  support/nfs/exports.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index eb782b9..4b17d3c 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -154,6 +154,7 @@ getexportent(int fromkernel, int fromexports)
>  		}
>  	}
>  
> +	xfree(ee.e_hostname);
>  	ee = def_ee;
>  
>  	/* Check for default client */
> @@ -176,7 +177,6 @@ getexportent(int fromkernel, int fromexports)
>  		if (!has_default_opts)
>  			xlog(L_WARNING, "No options for %s %s: suggest %s(sync) to avoid warning", ee.e_path, exp, exp);
>  	}
> -	xfree(ee.e_hostname);
>  	ee.e_hostname = xstrdup(hostname);
>  
>  	if (parseopts(opt, &ee, fromexports && !has_default_subtree_opts, NULL) < 0)
> 
