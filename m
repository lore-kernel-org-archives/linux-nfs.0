Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp5-g21.free.fr ([212.27.42.5]:48503 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397Ab2ADUIu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jan 2012 15:08:50 -0500
From: Jim Meyering <jim@meyering.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/5] mountd: Support junction management plug-ins
In-Reply-To: <20120104195716.21904.62916.stgit@degas.1015granger.net> (Chuck
	Lever's message of "Wed, 04 Jan 2012 14:57:16 -0500")
References: <20120104194136.21904.36616.stgit@degas.1015granger.net>
	<20120104195716.21904.62916.stgit@degas.1015granger.net>
Date: Wed, 04 Jan 2012 21:08:41 +0100
Message-ID: <87ipkrcjsm.fsf@rho.meyering.net>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> To support FedFS and NFS junctions without introducing additional
> build-time or run-time dependencies on nfs-utils, the community has
> chosen to use a dynamically loadable library to handle junction
> resolution.
...

Hi Chuck,

You may just be following existing practice in nfs-utils (there
are numerous other examples of this off-by-one error[1]), but the
post-snprintf length check must fail when the returned length is
equal to the specified buffer length.

> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index d2ae456..d4f04ab 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -802,6 +802,229 @@ lookup_export(char *dom, char *path, struct addrinfo *ai)
>  	return found;
>  }
>
> +#ifdef HAVE_NFS_PLUGIN_H
> +#include <dlfcn.h>
> +#include <nfs-plugin.h>
> +
> +/*
> + * Walk through a set of FS locations and build a set of export options.
> + * Returns true if all went to plan; otherwise, false.
> + */
> +static _Bool
> +locations_to_options(struct jp_ops *ops, nfs_fsloc_set_t locations,
> +		char *options, size_t remaining, int *ttl)
> +{
> +	char *server, *last_path, *rootpath, *ptr;
> +	_Bool seen = false;
> +
> +	last_path = NULL;
> +	rootpath = NULL;
> +	server = NULL;
> +	ptr = options;
> +	*ttl = 0;
> +
> +	for (;;) {
> +		enum jp_status status;
> +		int len;
> +
> +		status = ops->jp_get_next_location(locations, &server,
> +							&rootpath, ttl);
> +		if (status == JP_EMPTY)
> +			break;
> +		if (status != JP_OK) {
> +			xlog(D_GENERAL, "%s: failed to parse location: %s",
> +				__func__, ops->jp_error(status));
> +			goto out_false;
> +		}
> +		xlog(D_GENERAL, "%s: Location: %s:%s",
> +			__func__, server, rootpath);
> +
> +		if (last_path && strcmp(rootpath, last_path) == 0) {
> +			len = snprintf(ptr, remaining, "+%s", server);
> +			if (len < 0) {
> +				xlog(D_GENERAL, "%s: snprintf: %m", __func__);
> +				goto out_false;
> +			}
> +			if ((size_t)len > remaining) {

s/>/>=/

snprintf returning the specified size indicates that the
result+NUL did not fit in the specified buffer.

> +				xlog(D_GENERAL, "%s: options buffer overflow", __func__);
> +				goto out_false;
> +			}
> +			remaining -= (size_t)len;
> +			ptr += len;
> +		} else {
> +			if (last_path == NULL)
> +				len = snprintf(ptr, remaining, "refer=%s@%s",
> +							rootpath, server);
> +			else
> +				len = snprintf(ptr, remaining, ":%s@%s",
> +							rootpath, server);
> +			if (len < 0) {
> +				xlog(D_GENERAL, "%s: snprintf: %m", __func__);
> +				goto out_false;
> +			}
> +			if ((size_t)len > remaining) {

Same here.

> +				xlog(D_GENERAL, "%s: options buffer overflow",
> +					__func__);
> +				goto out_false;
> +			}
> +			remaining -= (size_t)len;
> +			ptr += len;
> +			last_path = rootpath;
> +		}

[1] Here are other examples of that error:

  $ git grep -A13 snprintf|grep ' > '
  support/nfs/cacheio.c-  if (len > *lp)
  support/nfs/cacheio.c-  if (len > *lp)
  support/nfs/getport.c-  if (len < 0 || (size_t)len > count)
  utils/exportfs/exportfs.c-              if (fname_len > PATH_MAX) {
  utils/gssd/gssd_proc.c- if (nbytes > INFOBUFLEN)
