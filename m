Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49E1CC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 11:24:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 167DB2084F
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 11:24:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725823AbfBULY3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 06:24:29 -0500
Received: from mout.gmx.net ([212.227.15.19]:53081 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725385AbfBULY3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Feb 2019 06:24:29 -0500
Received: from onion.lan ([213.162.73.216]) by mail.gmx.com (mrgmx002
 [212.227.17.190]) with ESMTPSA (Nemesis) id 0M5tU1-1hGnOK0zOL-00xuOM; Thu, 21
 Feb 2019 12:24:18 +0100
Date:   Thu, 21 Feb 2019 12:25:05 +0100
From:   Peter Wagner <tripolar@gmx.at>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, SteveD@redhat.com
Subject: Re: [PATCH v2] Remove abuse of ai_canonname
Message-ID: <20190221122505.1fae70a7@onion.lan>
In-Reply-To: <20190219155220.17240.31293.stgit@manet.1015granger.net>
References: <20190219155220.17240.31293.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Provags-ID: V03:K1:nNa90rv4YL527GEY3Ru9XsOafI56DGj61fW9PqUN38TwsL8/xqF
 Lw4w9uoHuByLYZNy6ZTF4sZqWLrYyiTq1588o0m8g+olk7hO+GV/Gu7gLzV2wj3Tho1h4lW
 rjLJgk5Q+v9P770+fORKJJkh1G/hInG4bestt0crCZsIIw3JIL2aqlzNIFKIrZYq1k9OXpN
 JCxXeikU5o1ByE9i9JKyA==
X-UI-Out-Filterresults: notjunk:1;V03:K0:q5EennleIzA=:FegO/FnDCBQnrK0WLFxJXN
 ed6mOGYkx7yYitpjddWap/Z8zJQXyNBQqfyqe2pXcfw+LxVG2qK3LLEpzN6FcaJnid8ket5NQ
 yQ6/gP5XYi5ZNUeHCVE6ypIP0Aqsd0lNoU9sTtcOGz7eTYinbEb9qj50PCcfYtKJrPDFEdaow
 tsKh9Sl6SKGdKQpNc3yJBqLE0IEZs7OnUHzvBNf4I2UpAnC5b302cEOCcMztHnDYBYD6785Rg
 eR0vHIPOMKG+caKHEvFiwE68yUUx8QvYMAh7xqV3a/XqZTEDYCUB2PS1i5X1tdt/4fPBnomxF
 pP+S9I8R49T3tWhMRdc7cgxTMoCYELPvlrD6OUQlSqlmYPTrWZqn5O2muLXhRCnB1DdgVDKwT
 GZWi8Xrx/Pi4OpmDlRjgPUutGaxDVikf3qDaP2F9R/zMmA6o/n7rAxsDiYT+zf4EW6m9kisLh
 OKuBQkamS786Vvf8jhSDtdbOi03n/TUXpgJ1rZPUT+3pVYys90CQslJhSm63xAaGt5GiSonWF
 g9olVMwQXZTX0c9LXv2o49OxI9X7u3byaSQGQMNZoDxlO/w+OrH8jbFgGD+jlJsVxTGwI+em/
 /jUvGu3sBktpG2We3F7hdHG3cbyFVOmyGR1qZHZfmPK1yFODWx2uiwmbjSb9hUHLZbVFxJM3c
 TpTozMQECJeaa/j/FTIDLLQw2csENY6ffRmo4gOeZGBz03gTnRCkJ3obkRvLPJ6Ki547xKTDO
 Kui+Sfvw0SdL28WqxaVBpiHeUQRnbd3ScNJqTegK+pB79ZGnyAF2STW68YQgEjotZxqPij2mv
 s2MrWQstQhpbB8804VbVIkvbILNflcX1jOt7PcGJJmvM3lB4l1jTwsyHLrND3DtSFnZK0j9wH
 ym6vIapE5QSWpG9CSZQz6ZEyDf39z9lDxs6CIzgATL4sZn5LOyi6TBp5Y7ioBYUOHh7cDAh0E
 9Q/PRr+g9VA==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On Tue, 19 Feb 2019 10:52:36 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> Peter Wagner <tripolar@gmx.at> reports a portability issue with
> freeing ai_canonname (and subsequently replacing that pointer via
> strdup(3)). The relevant standards text is:
> 
> > If nodename is not null, and if requested by the AI_CANONNAME
> > flag, the ai_canonname field of the first returned addrinfo
> > structure shall point to a null-terminated string containing the
> > canonical name corresponding to the input nodename; if the
> > canonical name is not available, then ai_canonname shall refer to
> > the nodename argument or a string with the same contents.  
> 
> There is no indication that this string may be freed using free(3).
> Eg, the library could have allocated it as part of the addrinfo
> struct itself, or it could point to static memory. The Linux man
> page is equally silent on this issue.
> 
> There is only one caller to host_reliable_addrinfo() that actually
> uses the string in ai->ai_canonname, and then only for debugging
> messages. Change those to display the IP address instead.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

Signed-off-by: Peter Wagner <tripolar@gmx.at>

> ---
>  support/export/hostname.c |   58
> +++++++++------------------------------------
> utils/mountd/auth.c       |   16 ++++++------ 2 files changed, 20
> insertions(+), 54 deletions(-)
> 
> 
> Compile-tested only.
> 
> 
> diff --git a/support/export/hostname.c b/support/export/hostname.c
> index 5c4c824..96c5449 100644
> --- a/support/export/hostname.c
> +++ b/support/export/hostname.c
> @@ -264,9 +264,9 @@ host_canonname(const struct sockaddr *sap)
>   * Reverse and forward lookups are performed to ensure the address
> has
>   * matching forward and reverse mappings.
>   *
> - * Returns addrinfo structure with just the provided address with
> - * ai_canonname filled in. If there is a problem with resolution or
> - * the resolved records don't match up properly then it returns NULL
> + * Returns addrinfo structure with just the provided address. If
> there
> + * is a problem with resolution or the resolved records don't match
> up
> + * properly then returns NULL.
>   *
>   * Caller must free the returned structure with freeaddrinfo(3).
>   */
> @@ -277,13 +277,15 @@ host_reliable_addrinfo(const struct sockaddr
> *sap) struct addrinfo *ai, *a;
>  	char *hostname;
>  
> +	ai = NULL;
>  	hostname = host_canonname(sap);
>  	if (hostname == NULL)
> -		return NULL;
> +		goto out;
>  
>  	ai = host_addrinfo(hostname);
> +	free(hostname);
>  	if (!ai)
> -		goto out_free_hostname;
> +		goto out;
>  
>  	/* make sure there's a matching address in the list */
>  	for (a = ai; a; a = a->ai_next)
> @@ -291,22 +293,15 @@ host_reliable_addrinfo(const struct sockaddr
> *sap) break;
>  
>  	freeaddrinfo(ai);
> +	ai = NULL;
>  	if (!a)
> -		goto out_free_hostname;
> +		goto out;
>  
>  	/* get addrinfo with just the original address */
>  	ai = host_numeric_addrinfo(sap);
> -	if (!ai)
> -		goto out_free_hostname;
>  
> -	/* and populate its ai_canonname field */
> -	free(ai->ai_canonname);
> -	ai->ai_canonname = hostname;
> +out:
>  	return ai;
> -
> -out_free_hostname:
> -	free(hostname);
> -	return NULL;
>  }
>  
>  /**
> @@ -323,7 +318,6 @@ host_numeric_addrinfo(const struct sockaddr *sap)
>  {
>  	socklen_t salen = nfs_sockaddr_length(sap);
>  	char buf[INET6_ADDRSTRLEN];
> -	struct addrinfo *ai;
>  	int error;
>  
>  	if (salen == 0) {
> @@ -348,21 +342,7 @@ host_numeric_addrinfo(const struct sockaddr *sap)
>  		return NULL;
>  	}
>  
> -	ai = host_pton(buf);
> -
> -	/*
> -	 * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
> -	 */
> -	if (ai != NULL) {
> -		free(ai->ai_canonname);		/* just in
> case */
> -		ai->ai_canonname = strdup(buf);
> -		if (ai->ai_canonname == NULL) {
> -			freeaddrinfo(ai);
> -			ai = NULL;
> -		}
> -	}
> -
> -	return ai;
> +	return host_pton(buf);
>  }
>  #else	/* !HAVE_GETNAMEINFO */
>  __attribute__((__malloc__))
> @@ -372,7 +352,6 @@ host_numeric_addrinfo(const struct sockaddr *sap)
>  	const struct sockaddr_in *sin = (const struct sockaddr_in
> *)sap; const struct in_addr *addr = &sin->sin_addr;
>  	char buf[INET_ADDRSTRLEN];
> -	struct addrinfo *ai;
>  
>  	if (sap->sa_family != AF_INET)
>  		return NULL;
> @@ -382,19 +361,6 @@ host_numeric_addrinfo(const struct sockaddr *sap)
>  					(socklen_t)sizeof(buf)) ==
> NULL) return NULL;
>  
> -	ai = host_pton(buf);
> -
> -	/*
> -	 * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
> -	 */
> -	if (ai != NULL) {
> -		ai->ai_canonname = strdup(buf);
> -		if (ai->ai_canonname == NULL) {
> -			freeaddrinfo(ai);
> -			ai = NULL;
> -		}
> -	}
> -
> -	return ai;
> +	return host_pton(buf);
>  }
>  #endif	/* !HAVE_GETNAMEINFO */
> diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
> index 8299256..cb4848c 100644
> --- a/utils/mountd/auth.c
> +++ b/utils/mountd/auth.c
> @@ -261,40 +261,40 @@ auth_authenticate(const char *what, const
> struct sockaddr *caller, *p = '\0';
>  	}
>  
> +	host_ntop(caller, buf, sizeof(buf));
>  	switch (error) {
>  	case bad_path:
>  		xlog(L_WARNING, "bad path in %s request from %s:
> \"%s\"",
> -		     what, host_ntop(caller, buf, sizeof(buf)),
> path);
> +		     what, buf, path);
>  		break;
>  
>  	case unknown_host:
>  		xlog(L_WARNING, "refused %s request from %s for %s
> (%s): unmatched host",
> -		     what, host_ntop(caller, buf, sizeof(buf)),
> path, epath);
> +		     what, buf, path, epath);
>  		break;
>  
>  	case no_entry:
>  		xlog(L_WARNING, "refused %s request from %s for %s
> (%s): no export entry",
> -		     what, ai->ai_canonname, path, epath);
> +		     what, buf, path, epath);
>  		break;
>  
>  	case not_exported:
>  		xlog(L_WARNING, "refused %s request from %s for %s
> (%s): not exported",
> -		     what, ai->ai_canonname, path, epath);
> +		     what, buf, path, epath);
>  		break;
>  
>  	case illegal_port:
>  		xlog(L_WARNING, "refused %s request from %s for %s
> (%s): illegal port %u",
> -		     what, ai->ai_canonname, path, epath,
> nfs_get_port(caller));
> +		     what, buf, path, epath, nfs_get_port(caller));
>  		break;
>  
>  	case success:
>  		xlog(L_NOTICE, "authenticated %s request from %s:%u
> for %s (%s)",
> -		     what, ai->ai_canonname, nfs_get_port(caller),
> path, epath);
> +		     what, buf, nfs_get_port(caller), path, epath);
>  		break;
>  	default:
>  		xlog(L_NOTICE, "%s request from %s:%u for %s (%s)
> gave %d",
> -		     what, ai->ai_canonname, nfs_get_port(caller),
> -			path, epath, error);
> +		     what, buf, nfs_get_port(caller), path, epath,
> error); }
>  
>  	freeaddrinfo(ai);
> 

