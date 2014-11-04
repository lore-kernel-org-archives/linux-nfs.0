Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36826 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751562AbaKDUOq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Nov 2014 15:14:46 -0500
Message-ID: <545933B4.6040303@RedHat.com>
Date: Tue, 04 Nov 2014 15:14:44 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Henrique Martins <linux@martins.cc>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfsd/exportfs: changes handling of unresolvable entries
References: <8957.1415128789@monster.martins.cc>
In-Reply-To: <8957.1415128789@monster.martins.cc>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/04/2014 02:19 PM, Henrique Martins wrote:
> In-reply-to: <54591385.2080007@RedHat.com>
> References: <14393.1409936528@monster.martins.cc>
>  <15531.1414780435@monster.martins.cc> <54591385.2080007@RedHat.com>
> Comments: In-reply-to Steve Dickson <SteveD@redhat.com>
>    message dated "Tue, 04 Nov 2014 12:57:25 -0500."
> X-Mailer: MH-E 8.5; nmh 1.6; XEmacs 21.5  (beta34)
> MIME-Version: 1.0
> Content-Type: multipart/mixed; boundary="=-=-="
> --------
> --=-=-=
> Content-Type: text/plain; charset=utf-8
> 
> 
> Attaching patch to nfs/exportfs to allow nfsd to start when
> there are some, but not all, unresolvable entries in
> /etc/exports.
> 
> Nfs currently fails to start in my laptop which has work
> machines listed in exports that aren't resolvable when I'm
> not in the office, and home machines in exports that aren't
> resolvable when I'm not home.
> 
> Files changed:
> - in client.c/client_lookup:
>     changes the (x)log level for unresolvable entries in
>     /etc/exports from L_ERROR to L_WARNING,
> - in hostname.c/host_addrinfo:
>     changes the (x)log level for unresolvable entries in
>     /etc/exports from D_GENERAL to D_PARSE,
> - in export.c/export_read:
>     counts the number of exported volume entries and
>     generates a (x)log L_ERROR if no volumes are exported.
> 
> Built and tested on a Fedora 20 (fully updated) system.
> 
> Signed-off-by: Henrique Martins <linux@martins.cc>
Committed!

steved.

> ---
> 
> --=-=-=
> Content-Type: text/x-diff; charset=utf-8
> Content-Disposition: inline; filename=nfs-utils-1.3.0-exportfs.patch
> 
> --- nfs-utils-1.3.0/support/export/client.c.orig	2014-09-05 08:21:37.568364360 -0700
> +++ nfs-utils-1.3.0/support/export/client.c	2014-09-05 08:21:41.709451778 -0700
> @@ -277,7 +277,7 @@
>  	if (htype == MCL_FQDN && !canonical) {
>  		ai = host_addrinfo(hname);
>  		if (!ai) {
> -			xlog(L_ERROR, "Failed to resolve %s", hname);
> +			xlog(L_WARNING, "Failed to resolve %s", hname);
>  			goto out;
>  		}
>  		hname = ai->ai_canonname;
> --- nfs-utils-1.3.0/support/export/hostname.c.orig	2014-09-05 08:09:07.387551291 -0700
> +++ nfs-utils-1.3.0/support/export/hostname.c	2014-09-05 08:09:13.799573723 -0700
> @@ -175,11 +175,11 @@
>  	case 0:
>  		return ai;
>  	case EAI_SYSTEM:
> -		xlog(D_GENERAL, "%s: failed to resolve %s: (%d) %m",
> +		xlog(D_PARSE, "%s: failed to resolve %s: (%d) %m",
>  				__func__, hostname, errno);
>  		break;
>  	default:
> -		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
> +		xlog(D_PARSE, "%s: failed to resolve %s: %s",
>  				__func__, hostname, gai_strerror(error));
>  		break;
>  	}
> --- nfs-utils-1.3.0/support/export/export.c.orig	2014-03-25 08:12:07.000000000 -0700
> +++ nfs-utils-1.3.0/support/export/export.c	2014-09-05 09:23:37.424105125 -0700
> @@ -76,15 +76,22 @@
>  	struct exportent	*eep;
>  	nfs_export		*exp;
> 
> +        int volumes = 0;
> +
>  	setexportent(fname, "r");
>  	while ((eep = getexportent(0,1)) != NULL) {
>  		exp = export_lookup(eep->e_hostname, eep->e_path, 0);
> -		if (!exp)
> -			export_create(eep, 0);
> +		if (!exp) {
> +			exp = export_create(eep, 0);
> +                        if (exp)
> +                        	volumes++;
> +                }
>  		else
>  			warn_duplicated_exports(exp, eep);
>  	}
>  	endexportent();
> +        if (volumes == 0)
> +        	xlog(L_ERROR, "no or all unresolvable export entries");
>  }
> 
>  /**
> 
> --=-=-=--
> 
