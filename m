Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755698AbcHCRbF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2016 13:31:05 -0400
Subject: Re: [PATCH 6/7] mountd: allow alternate ttl to be specified for
 dump_to_cache.
To: NeilBrown <neilb@suse.com>
References: <146976807524.20186.8871903418718212567.stgit@noble>
 <146976861681.20186.16926967483251671716.stgit@noble>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <b4e08e92-9f58-967b-73cd-4785e4fb17c7@RedHat.com>
Date: Wed, 3 Aug 2016 13:31:03 -0400
MIME-Version: 1.0
In-Reply-To: <146976861681.20186.16926967483251671716.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/29/2016 01:03 AM, NeilBrown wrote:
> The default will not always be best.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  utils/mountd/cache.c |   20 ++++++++++++--------
>  1 file changed, 12 insertions(+), 8 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index ec86a22613cf..9cc270690d90 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -881,12 +881,16 @@ static void write_secinfo(char **bp, int *blen, struct exportent *ep, int flag_m
>  
>  }
>  
> -static int dump_to_cache(int f, char *buf, int buflen, char *domain, char *path, struct exportent *exp)
> +static int dump_to_cache(int f, char *buf, int buflen, char *domain,
> +			 char *path, struct exportent *exp, int ttl)
>  {
>  	char *bp = buf;
>  	int blen = buflen;
>  	time_t now = time(0);
>  
> +	if (ttl <= 1)
> +		ttl = DEFAULT_TTL;
> +
>  	qword_add(&bp, &blen, domain);
>  	qword_add(&bp, &blen, path);
>  	if (exp) {
> @@ -913,7 +917,7 @@ static int dump_to_cache(int f, char *buf, int buflen, char *domain, char *path,
>  			qword_addhex(&bp, &blen, u, 16);
>  		}
>  	} else
> -		qword_adduint(&bp, &blen, now + DEFAULT_TTL);
> +		qword_adduint(&bp, &blen, now + ttl);
>  	qword_addeol(&bp, &blen);
>  	if (blen <= 0) return -1;
>  	if (write(f, buf, bp - buf) != bp - buf) return -1;
> @@ -1273,7 +1277,7 @@ static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path
>  	struct exportent *eep;
>  
>  	eep = lookup_junction(dom, path, ai);
> -	dump_to_cache(f, buf, buflen, dom, path, eep);
> +	dump_to_cache(f, buf, buflen, dom, path, eep, 0);
>  	if (eep == NULL)
>  		return;
>  	exportent_release(eep);
> @@ -1283,7 +1287,7 @@ static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path
>  static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path,
>  		struct addrinfo *UNUSED(ai))
>  {
> -	dump_to_cache(f, buf, buflen, dom, path, NULL);
> +	dump_to_cache(f, buf, buflen, dom, path, NULL, 0);
>  }
>  #endif	/* !HAVE_NFS_PLUGIN_H */
>  
> @@ -1330,11 +1334,11 @@ static void nfsd_export(int f)
>  	found = lookup_export(dom, path, ai);
>  
>  	if (found) {
> -		if (dump_to_cache(f, buf, sizeof(buf), dom, path, &found->m_export) < 0) {
> +		if (dump_to_cache(f, buf, sizeof(buf), dom, path, &found->m_export, 0) < 0) {
>  			xlog(L_WARNING,
>  			     "Cannot export %s, possibly unsupported filesystem"
>  			     " or fsid= required", path);
> -			dump_to_cache(f, buf, sizeof(buf), dom, path, NULL);
> +			dump_to_cache(f, buf, sizeof(buf), dom, path, NULL, 0);
>  		}
>  	} else
>  		lookup_nonexport(f, buf, sizeof(buf), dom, path, ai);
> @@ -1423,7 +1427,7 @@ static int cache_export_ent(char *buf, int buflen, char *domain, struct exporten
>  	f = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
>  	if (f < 0) return -1;
>  
> -	err = dump_to_cache(f, buf, buflen, domain, exp->e_path, exp);
> +	err = dump_to_cache(f, buf, buflen, domain, exp->e_path, exp, 0);
>  	if (err) {
>  		xlog(L_WARNING,
>  		     "Cannot export %s, possibly unsupported filesystem or"
> @@ -1464,7 +1468,7 @@ static int cache_export_ent(char *buf, int buflen, char *domain, struct exporten
>  				continue;
>  			dev = stb.st_dev;
>  			path[l] = 0;
> -			dump_to_cache(f, buf, buflen, domain, path, exp);
> +			dump_to_cache(f, buf, buflen, domain, path, exp, 0);
>  			path[l] = c;
>  		}
>  		break;
> 
> 
Hey Neil,

This one is a bit confusing... Unless I'm missing something this
patch enables the passing of the TTL in to dump_to_cache() but
a zero is always passed in which causes the default TTL to
be used... So I guess my question is... what's the point?
Is there an upcoming patch that will  actually passing a 
non-default TTL

steved.
