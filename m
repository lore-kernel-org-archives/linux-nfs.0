Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807Ab3IRTPB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Sep 2013 15:15:01 -0400
Message-ID: <5239FBCA.3030803@RedHat.com>
Date: Wed, 18 Sep 2013 15:15:22 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: insecure/secure should be a secinfo_flag
References: <1378680082-19229-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378680082-19229-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/09/13 18:41, Trond Myklebust wrote:
> The 'insecure' flag is listed in /proc/fs/nfsd/export_features
> in newer kernels as being a secinfo_flag, however it is not displayed by
> secinfo_show.
> This patch fixes that, and sets up a framework which should make
> it easy to add new flags to /proc/fs/nfsd/export_features and have
> them be displayed properly.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Committed! 

steved.

> ---
>  support/nfs/exports.c | 34 +++++++++++++++++++++++++++-------
>  1 file changed, 27 insertions(+), 7 deletions(-)
> 
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index 3e99de6..8d2adf7 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -197,10 +197,35 @@ getexportent(int fromkernel, int fromexports)
>  	return &ee;
>  }
>  
> +static const struct secinfo_flag_displaymap {
> +	unsigned int flag;
> +	const unsigned char *set;
> +	const unsigned char *unset;
> +} secinfo_flag_displaymap[] = {
> +	{ NFSEXP_READONLY, "ro", "rw" },
> +	{ NFSEXP_INSECURE_PORT, "insecure", "secure" },
> +	{ NFSEXP_ROOTSQUASH, "root_squash", "no_root_squash" },
> +	{ NFSEXP_ALLSQUASH, "all_squash", "no_all_squash" },
> +	{ 0, NULL, NULL }
> +};
> +
> +static void secinfo_flags_show(FILE *fp, unsigned int flags, unsigned int mask)
> +{
> +	const struct secinfo_flag_displaymap *p;
> +
> +	for (p = &secinfo_flag_displaymap[0]; p->flag != 0; p++) {
> +		if (!(mask & p->flag))
> +			continue;
> +		fprintf(fp, ",%s", (flags & p->flag) ? p->set : p->unset);
> +	}
> +}
> +
>  void secinfo_show(FILE *fp, struct exportent *ep)
>  {
> +	const struct export_features *ef;
>  	struct sec_entry *p1, *p2;
> -	int flags;
> +
> +	ef = get_export_features();
>  
>  	if (ep->e_secinfo[0].flav == NULL)
>  		secinfo_addflavor(find_flavor("sys"), ep);
> @@ -211,12 +236,7 @@ void secinfo_show(FILE *fp, struct exportent *ep)
>  								p2++) {
>  			fprintf(fp, ":%s", p2->flav->flavour);
>  		}
> -		flags = p1->flags;
> -		fprintf(fp, ",%s", (flags & NFSEXP_READONLY) ? "ro" : "rw");
> -		fprintf(fp, ",%sroot_squash", (flags & NFSEXP_ROOTSQUASH)?
> -				"" : "no_");
> -		fprintf(fp, ",%sall_squash", (flags & NFSEXP_ALLSQUASH)?
> -				"" : "no_");
> +		secinfo_flags_show(fp, p1->flags, ef->secinfo_flags);
>  	}
>  }
>  
> 
