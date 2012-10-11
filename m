Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:37542 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819Ab2JKPOa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Oct 2012 11:14:30 -0400
Subject: Re: [PATCH 8/8] mountd: Simplify "no junction support" case
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20121011151151.4665.80466.stgit@lebasque.1015granger.net>
Date: Thu, 11 Oct 2012 11:14:15 -0400
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Message-Id: <9AA1F8D6-DEA5-452D-ADC5-B6A1F7058D93@oracle.com>
References: <20121011150421.4665.35964.stgit@lebasque.1015granger.net> <20121011151151.4665.80466.stgit@lebasque.1015granger.net>
To: steved@redhat.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 11, 2012, at 11:11 AM, Chuck Lever wrote:

> We've added logic in the "not an export" case in nfsd_fh(), so it's

Oops, I meant nfsd_export() .

> no longer a simple function call.  Clean up this code by splitting
> it into a new function, and make plain what happens when junction
> support is compiled out.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> utils/mountd/cache.c |   32 +++++++++++++++++++-------------
> 1 files changed, 19 insertions(+), 13 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 457fc9c..8280234 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -1109,11 +1109,24 @@ static struct exportent *lookup_junction(char *dom, const char *pathname,
> 	(void)dlclose(handle);
> 	return exp;
> }
> +
> +static void lookup_nonexport(FILE *f, char *dom, char *path,
> +		struct addrinfo *ai)
> +{
> +	struct exportent *eep;
> +
> +	eep = lookup_junction(dom, path, ai);
> +	dump_to_cache(f, dom, path, eep);
> +	if (eep == NULL)
> +		return;
> +	exportent_release(eep);
> +	free(eep);
> +}
> #else	/* !HAVE_NFS_PLUGIN_H */
> -static inline struct exportent *lookup_junction(char *UNUSED(dom),
> -		const char *UNUSED(pathname), struct addrinfo *UNUSED(ai))
> +static void lookup_nonexport(FILE *f, char *dom, char *path,
> +		struct addrinfo *UNUSED(ai))
> {
> -	return NULL;
> +	dump_to_cache(f, dom, path, NULL);
> }
> #endif	/* !HAVE_NFS_PLUGIN_H */
> 
> @@ -1164,16 +1177,9 @@ static void nfsd_export(FILE *f)
> 			     " or fsid= required", path);
> 			dump_to_cache(f, dom, path, NULL);
> 		}
> -	} else {
> -		struct exportent *eep;
> -
> -		eep = lookup_junction(dom, path, ai);
> -		dump_to_cache(f, dom, path, eep);
> -		if (eep != NULL) {
> -			exportent_release(eep);
> -			free(eep);
> -		}
> -	}
> +	} else
> +		lookup_nonexport(f, dom, path, ai);
> +
>  out:
> 	xlog(D_CALL, "nfsd_export: found %p path %s", found, path ? path : NULL);
> 	if (dom) free(dom);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




