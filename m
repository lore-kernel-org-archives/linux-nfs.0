Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36902 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753410AbaCKSGW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Mar 2014 14:06:22 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s2BI6KNs004416
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 11 Mar 2014 14:06:21 -0400
Message-ID: <531F5099.70108@RedHat.com>
Date: Tue, 11 Mar 2014 14:06:17 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mateusz Guzik <mguzik@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsidmap: fix error reporting for nfs4_* family of functions
References: <1393275114-28792-1-git-send-email-mguzik@redhat.com>
In-Reply-To: <1393275114-28792-1-git-send-email-mguzik@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/24/2014 03:51 PM, Mateusz Guzik wrote:
> Errors were logged with xlog_err function relying on errno, but these
> functions don't set it.
> 
> Fix the problem by introducing xlog_err_code which accepts error code.
> 
> Signed-off-by: Mateusz Guzik <mguzik@redhat.com>
Committed...

steved.

> ---
>  support/include/xlog.h    |  1 +
>  support/nfs/xlog.c        | 12 ++++++++++++
>  utils/nfsidmap/nfsidmap.c | 11 ++++++-----
>  3 files changed, 19 insertions(+), 5 deletions(-)
> 
> diff --git a/support/include/xlog.h b/support/include/xlog.h
> index fd34ec2..ae34eb7 100644
> --- a/support/include/xlog.h
> +++ b/support/include/xlog.h
> @@ -45,6 +45,7 @@ int			xlog_enabled(int fac);
>  void			xlog(int fac, const char *fmt, ...);
>  void			xlog_warn(const char *fmt, ...);
>  void			xlog_err(const char *fmt, ...);
> +void			xlog_err_code(int error, const char *fmt, ...);
>  void			xlog_backend(int fac, const char *fmt, va_list args);
>  
>  #endif /* XLOG_H */
> diff --git a/support/nfs/xlog.c b/support/nfs/xlog.c
> index 83d07e1..3759217 100644
> --- a/support/nfs/xlog.c
> +++ b/support/nfs/xlog.c
> @@ -27,6 +27,7 @@
>  #include <stdio.h>
>  #include <stdarg.h>
>  #include <syslog.h>
> +#include <errno.h>
>  #include "nfslib.h"
>  
>  #undef	VERBOSE_PRINTF
> @@ -220,3 +221,14 @@ xlog_err(const char* fmt, ...)
>  	xlog_backend(L_FATAL, fmt, args);
>  	va_end(args);
>  }
> +
> +void
> +xlog_err_code(int error, const char *fmt, ...)
> +{
> +	va_list args;
> +
> +	errno = -error;
> +	va_start(args, fmt);
> +	xlog_backend(L_FATAL, fmt, args);
> +	va_end(args);
> +}
> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
> index e14543c..bf97714 100644
> --- a/utils/nfsidmap/nfsidmap.c
> +++ b/utils/nfsidmap/nfsidmap.c
> @@ -54,7 +54,7 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
>  		sprintf(id, "%u", gid);
>  	}
>  	if (rc < 0)
> -		xlog_err("id_lookup: %s: failed: %m",
> +		xlog_err_code(rc, "id_lookup: %s: failed: %m",
>  			(type == USER ? "nfs4_owner_to_uid" : "nfs4_group_owner_to_gid"));
>  
>  	if (rc == 0) {
> @@ -95,8 +95,9 @@ int name_lookup(char *id, key_serial_t key, int type)
>  
>  	rc = nfs4_get_default_domain(NULL, domain, NFS4_MAX_DOMAIN_LEN);
>  	if (rc != 0) {
> +		xlog_err_code(rc,
> +			"name_lookup: nfs4_get_default_domain failed: %m");
>  		rc = -1;
> -		xlog_err("name_lookup: nfs4_get_default_domain failed: %m");
>  		goto out;
>  	}
>  
> @@ -108,7 +109,7 @@ int name_lookup(char *id, key_serial_t key, int type)
>  		rc = nfs4_gid_to_name(gid, domain, name, IDMAP_NAMESZ);
>  	}
>  	if (rc < 0)
> -		xlog_err("name_lookup: %s: failed: %m",
> +		xlog_err_code(rc, "name_lookup: %s: failed: %m",
>  			(type == USER ? "nfs4_uid_to_name" : "nfs4_gid_to_name"));
>  
>  	if (rc == 0) {
> @@ -272,8 +273,8 @@ int main(int argc, char **argv)
>  		}
>  	}
>  
> -	if (nfs4_init_name_mapping(PATH_IDMAPDCONF))  {
> -		xlog_err("Unable to create name to user id mappings.");
> +	if (rc = nfs4_init_name_mapping(PATH_IDMAPDCONF))  {
> +		xlog_err_code(rc, "Unable to create name to user id mappings.");
>  		return 1;
>  	}
>  	if (!verbose)
> 
