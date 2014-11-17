Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46509 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752025AbaKQNJo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Nov 2014 08:09:44 -0500
Message-ID: <5469F395.9080701@RedHat.com>
Date: Mon, 17 Nov 2014 08:09:41 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Henrique Martins <linux@martins.cc>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfsd/exportfs: allow empty exports file
References: <17903.1415988313@monster.martins.cc>
In-Reply-To: <17903.1415988313@monster.martins.cc>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/14/2014 01:05 PM, Henrique Martins wrote:
> Attaching patch to nfs/exportfs to allow nfsd to start when
> /etc/exports is empty, which broke with previous patch
> (bugzilla 1115179).
> 
> Files changed:
> - in export.c/export_read:
>     counts the number of good (resolvable) and bad
>     (unresolvable) volume entries and generates a (x)log
>     L_ERROR if no resolvable entries are exported AND there
>     are some unresolvable entries.
> 
> Built and tested on a Fedora 20 (fully updated) system.
> 
> (And yes, if I need to add the patch inline, my mailer may
> screw up the indentation, blanks vs tabs.)
> 
> Signed-off-by: Henrique Martins <linux@xxxxxxxxxx>
> ---
> 
> diff -upN nfs-utils-1.3.0/support/export/export.c.orig
> nfs-utils-1.3.0/support/export/export.c
> --- nfs-utils-1.3.0/support/export/export.c.orig
>     2014-11-14 08:46:58.284175535 -0800
> +++ nfs-utils-1.3.0/support/export/export.c	2014-11-14
>     08:47:52.079349910 -0800
> @@ -76,7 +76,8 @@ export_read(char *fname)
>  	struct exportent	*eep;
>  	nfs_export		*exp;
> 
> -	int volumes = 0;
> +	int good = 0;
> +	int bad = 0;
> 
>  	setexportent(fname, "r");
>  	while ((eep = getexportent(0,1)) != NULL) {
> @@ -84,13 +85,15 @@ export_read(char *fname)
>  		if (!exp) {
>  			exp = export_create(eep, 0);
>  			if (exp)
> -				volumes++;
> +				good++;
> +			else
> +				bad++;
>  		}
>  		else
>  			warn_duplicated_exports(exp, eep);
>  	}
>  	endexportent();
> -	if (volumes == 0)
> +	if (good == 0 && bad > 0)
>  		xlog(L_ERROR, "No file systems exported!");
>  }
> 
The presidence has been set that having an empty export file
is not a problem. So I would rather change that xlog to be
a L_WARNING and only log it when the verbose is set.
Something similar to:

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index bdea12b..92fb9eb 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
  *
  */
 void
-export_read(char *fname)
+export_read(char *fname, int verbose)
 {
        struct exportent        *eep;
        nfs_export              *exp;
@@ -90,8 +90,8 @@ export_read(char *fname)
                        warn_duplicated_exports(exp, eep);
        }
        endexportent();
-       if (volumes == 0)
-               xlog(L_ERROR, "No file systems exported!");
+       if (volumes == 0 && verbose)
+               xlog(L_WARNING, "No file systems exported!");
 }


steved.
