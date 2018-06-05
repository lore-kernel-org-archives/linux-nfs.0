Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:52006 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753031AbeFERWL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Jun 2018 13:22:11 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 61949407573E
        for <linux-nfs@vger.kernel.org>; Tue,  5 Jun 2018 17:22:11 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 3B054205D521
        for <linux-nfs@vger.kernel.org>; Tue,  5 Jun 2018 17:22:11 +0000 (UTC)
Subject: Re: [PATCH 1/2] Remove a number of stringop-truncation warnings
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180605153034.49074-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <ff8c72b0-092e-a889-83fb-b0ad051d0857@RedHat.com>
Date: Tue, 5 Jun 2018 13:22:11 -0400
MIME-Version: 1.0
In-Reply-To: <20180605153034.49074-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/05/2018 11:30 AM, Steve Dickson wrote:
> client.c:486:3: warning: ‘strncpy’ destination unchanged after
> 	copying no bytes [-Wstringop-truncation]
> 
> file.c:99:2: warning: ‘strncpy’ specified bound 4096
> 	equals destination size [-Wstringop-truncation]
> 
> v4root.c:95:2: warning: ‘strncpy’ specified bound 1025
> 	equals destination size [-Wstringop-truncation]
> 
> sm-notify.c:572:3: warning: ‘strncpy’ specified bound 1025
> 	equals destination size [-Wstringop-truncation]
> 
> nfs4mount.c:221:3: warning: ‘strncpy’ specified bound 1024
> 	equals destination size [-Wstringop-truncation]
> 
> nfsmount.c:831:2: warning: ‘strncpy’ specified bound 256
> 	equals destination size [-Wstringop-truncation]
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  support/export/client.c | 5 +++--
>  support/misc/file.c     | 2 +-
>  utils/mount/nfs4mount.c | 2 +-
>  utils/mount/nfsmount.c  | 2 +-
>  utils/mountd/v4root.c   | 2 +-
>  utils/statd/sm-notify.c | 2 +-
>  6 files changed, 8 insertions(+), 7 deletions(-)
Committed... 

steved.

> 
> diff --git a/support/export/client.c b/support/export/client.c
> index 2346f99..baf59c8 100644
> --- a/support/export/client.c
> +++ b/support/export/client.c
> @@ -482,8 +482,9 @@ add_name(char *old, const char *add)
>  		else
>  			cp = cp + strlen(cp);
>  	}
> -	if (old) {
> -		strncpy(new, old, cp-old);
> +	len = cp-old;
> +	if (old && len > 0) {
> +		strncpy(new, old, len);
>  		new[cp-old] = 0;
>  	} else {
>  		new[0] = 0;
> diff --git a/support/misc/file.c b/support/misc/file.c
> index 63597df..4065376 100644
> --- a/support/misc/file.c
> +++ b/support/misc/file.c
> @@ -96,7 +96,7 @@ generic_setup_basedir(const char *progname, const char *parentdir, char *base,
>  	}
>  
>  	/* Ensure we have a clean directory pathname */
> -	strncpy(buf, parentdir, sizeof(buf));
> +	strncpy(buf, parentdir, sizeof(buf)-1);
>  	path = dirname(buf);
>  	if (*path == '.') {
>  		(void)fprintf(stderr, "%s: Unusable directory %s",
> diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
> index 89629ed..3e4f1e2 100644
> --- a/utils/mount/nfs4mount.c
> +++ b/utils/mount/nfs4mount.c
> @@ -218,7 +218,7 @@ int nfs4mount(const char *spec, const char *node, int flags,
>  		goto fail;
>  	}
>  	if (running_bg)
> -		strncpy(new_opts, old_opts, sizeof(new_opts));
> +		strncpy(new_opts, old_opts, sizeof(new_opts)-1);
>  	else
>  		snprintf(new_opts, sizeof(new_opts), "%s%saddr=%s",
>  			 old_opts, *old_opts ? "," : "", s);
> diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
> index ae4a3da..952a755 100644
> --- a/utils/mount/nfsmount.c
> +++ b/utils/mount/nfsmount.c
> @@ -828,7 +828,7 @@ noauth_flavors:
>  
>  	data.fd = fsock;
>  	memcpy((char *) &data.addr, (char *) nfs_saddr, sizeof(data.addr));
> -	strncpy(data.hostname, hostname, sizeof(data.hostname));
> +	strncpy(data.hostname, hostname, sizeof(data.hostname)-1);
>  
>   out_ok:
>  	/* Ensure we have enough padding for the following strcat()s */
> diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
> index f978f4c..d735dbf 100644
> --- a/utils/mountd/v4root.c
> +++ b/utils/mountd/v4root.c
> @@ -92,7 +92,7 @@ v4root_create(char *path, nfs_export *export)
>  
>  	dupexportent(&eep, &pseudo_root.m_export);
>  	eep.e_hostname = curexp->e_hostname;
> -	strncpy(eep.e_path, path, sizeof(eep.e_path));
> +	strncpy(eep.e_path, path, sizeof(eep.e_path)-1);
>  	if (strcmp(path, "/") != 0)
>  		eep.e_flags &= ~NFSEXP_FSID;
>  	set_pseudofs_security(&eep, curexp->e_flags);
> diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
> index 6d19ec1..7a48473 100644
> --- a/utils/statd/sm-notify.c
> +++ b/utils/statd/sm-notify.c
> @@ -569,7 +569,7 @@ usage:		fprintf(stderr,
>  		if (name == NULL)
>  			exit(1);
>  
> -		strncpy(nsm_hostname, name, sizeof(nsm_hostname));
> +		strncpy(nsm_hostname, name, sizeof(nsm_hostname)-1);
>  		free(name);
>  	}
>  
> 
