Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21883 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756220Ab2HASkR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Aug 2012 14:40:17 -0400
Message-ID: <50196DB0.7090405@RedHat.com>
Date: Wed, 01 Aug 2012 13:56:00 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jiri Horky <jiri.horky@gmail.com>
CC: linux-nfs@vger.kernel.org, du@cesnet.cz
Subject: Re: [PATCH] libnfsidmap: implementation of client side Static translation
 method.
References: <1343028020-10587-1-git-send-email-jiri.horky@gmail.com>
In-Reply-To: <1343028020-10587-1-git-send-email-jiri.horky@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/23/2012 03:20 AM, Jiri Horky wrote:
> Since the [Static] section in idmapd.conf does not distinguish between user
> and group mappings we try both cases for each defined mapping. The code caches
> id->name mappings in the init function
> 
> Signed-off-by: Jiri Horky <jiri.horky@gmail.com>
Committed... My apologizes on taking so long to get this done....

steved.

> ---
>  static.c |  266 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
>  1 files changed, 255 insertions(+), 11 deletions(-)
> 
> diff --git a/static.c b/static.c
> index fffd458..8be87e8 100644
> --- a/static.c
> +++ b/static.c
> @@ -40,6 +40,7 @@
>  #include <grp.h>
>  #include <errno.h>
>  
> +#include "queue.h"
>  #include "cfg.h"
>  #include "nfsidmap.h"
>  #include "nfsidmap_internal.h"
> @@ -57,6 +58,40 @@ struct pwbuf {
>  	char buf[1];
>  };
>  
> +struct grbuf {
> +	struct group grbuf;
> +	char buf[1];
> +};
> +
> +struct uid_mapping {
> +	LIST_ENTRY (uid_mapping) link;
> +	uid_t uid;
> +	char * principal;
> +	char * localname;
> +};
> +
> +struct gid_mapping {
> +	LIST_ENTRY (gid_mapping) link;
> +	gid_t gid;
> +	char * principal;
> +	char * localgroup;
> +};
> +
> +static __inline__ u_int8_t uid_hash (uid_t uid)
> +{
> +	return uid % 256;
> +}
> +
> +static __inline__ u_int8_t gid_hash (gid_t gid)
> +{
> +	return gid % 256;
> +}
> +
> +//Hash tables of uid and guids to principals mappings.
> +//We reuse some queue/hash functions from cfg.c.
> +LIST_HEAD (uid_mappings, uid_mapping) uid_mappings[256];
> +LIST_HEAD (gid_mappings, gid_mapping) gid_mappings[256];
> +
>  static struct passwd *static_getpwnam(const char *name, const char *domain,
>  				      int *err_p)
>  {
> @@ -75,12 +110,9 @@ static struct passwd *static_getpwnam(const char *name, const char *domain,
>  	localname = conf_get_str("Static", (char *)name);
>  	if (!localname) {
>  		err = ENOENT;
> -		goto err;
> +		goto err_free_buf;
>  	}
>  
> -	IDMAP_LOG(4, ("static_getpwnam: name '%s' mapped to '%s'\n",
> -		  name, localname));
> -
>  again:
>  	err = getpwnam_r(localname, &buf->pwbuf, buf->buf, buflen, &pw);
>  
> @@ -91,12 +123,15 @@ again:
>  		if (err == 0)
>  			err = ENOENT;
>  
> -		IDMAP_LOG(0, ("static_getpwnam: name '%s' not found\n",
> -			  localname));
> +		IDMAP_LOG(0, ("static_getpwnam: localname '%s' for '%s' not found\n",
> +		  localname, name));
>  
>  		goto err_free_buf;
>  	}
>  
> +	IDMAP_LOG(4, ("static_getpwnam: name '%s' mapped to '%s'\n",
> +		  name, localname));
> +
>  	*err_p = 0;
>  	return pw;
>  
> @@ -107,6 +142,56 @@ err:
>  	return NULL;
>  }
>  
> +static struct group *static_getgrnam(const char *name, const char *domain,
> +				      int *err_p)
> +{
> +	struct group *gr;
> +	struct grbuf *buf;
> +	size_t buflen = sysconf(_SC_GETGR_R_SIZE_MAX);
> +	char *localgroup;
> +	int err;
> +
> +	buf = malloc(sizeof(*buf) + buflen);
> +	if (!buf) {
> +		err = ENOMEM;
> +		goto err;
> +	}
> +
> +	localgroup = conf_get_str("Static", (char *)name);
> +	if (!localgroup) {
> +		err = ENOENT;
> +		goto err_free_buf;
> +	}
> +
> +again:
> +	err = getgrnam_r(localgroup, &buf->grbuf, buf->buf, buflen, &gr);
> +
> +	if (err == EINTR)
> +		goto again;
> +
> +	if (!gr) {
> +		if (err == 0)
> +			err = ENOENT;
> +
> +		IDMAP_LOG(0, ("static_getgrnam: local group '%s' for '%s' not found\n",
> +			  localgroup, name));
> +
> +		goto err_free_buf;
> +	}
> +
> +	IDMAP_LOG(4, ("static_getgrnam: group '%s' mapped to '%s'\n",
> +		  name, localgroup));
> +
> +	*err_p = 0;
> +	return gr;
> +
> +err_free_buf:
> +	free(buf);
> +err:
> +	*err_p = err;
> +	return NULL;
> +}
> +
>  static int static_gss_princ_to_ids(char *secname, char *princ,
>  				   uid_t *uid, uid_t *gid,
>  				   extra_mapping_params **ex)
> @@ -151,14 +236,173 @@ static int static_gss_princ_to_grouplist(char *secname, char *princ,
>  	return -err;
>  }
>  
> +static int static_name_to_uid(char *name, uid_t *uid)
> +{
> +	struct passwd *pw;
> +	int err;
> +
> +	pw = static_getpwnam(name, NULL, &err);
> +
> +	if (pw) {
> +		*uid = pw->pw_uid;
> +		free(pw);
> +	}
> +
> +	return -err;
> +}
> +
> +static int static_name_to_gid(char *name, gid_t *gid)
> +{
> +	struct group *gr;
> +	int err;
> +
> +	gr = static_getgrnam(name, NULL, &err);
> +
> +	if (gr) {
> +		*gid = gr->gr_gid;
> +		free(gr);
> +	}
> +
> +	return -err;
> +}
> +
> +static int static_uid_to_name(uid_t uid, char *domain, char *name, size_t len)
> +{
> +	struct passwd *pw;
> +	struct uid_mapping * um;
> +
> +	for (um = LIST_FIRST (&uid_mappings[uid_hash (uid)]); um;
> +		um = LIST_NEXT (um, link)) {
> +		if (um->uid == uid) {
> +			strcpy(name, um->principal);
> +			return 0;
> +		}
> +	}
> +
> +	return -ENOENT;
> +}
> +
> +static int static_gid_to_name(gid_t gid, char *domain, char *name, size_t len)
> +{
> +	struct group *gr;
> +	struct gid_mapping * gm;
> +
> +	for (gm = LIST_FIRST (&gid_mappings[gid_hash (gid)]); gm;
> +		gm = LIST_NEXT (gm, link)) {
> +		if (gm->gid == gid) {
> +			strcpy(name, gm->principal);
> +			return 0;
> +		}
> +	}
> +
> +	return -ENOENT;
> +}
> +
> +/*
> + * We buffer all UID's for which static mappings is defined in advance, so the
> + * uid_to_name functions will be fast enough.
> + */
> +
> +static int static_init() {	
> +	int err;
> +	uid_t uid;
> +	struct conf_list * princ_list = NULL;
> +	struct conf_list_node * cln, *next;
> +	struct uid_mapping * unode;
> +	struct gid_mapping * gnode;
> +	struct passwd * pw = NULL;
> +	struct group * gr = NULL;
> +	unsigned int i;
> +
> +	//init hash_table first
> +	for (i = 0; i < sizeof uid_mappings / sizeof uid_mappings[0]; i++)
> +		LIST_INIT (&uid_mappings[i]);
> +
> +	//get all principals for which we have mappings
> +	princ_list = conf_get_tag_list("Static");
> +
> +	if (!princ_list) {
> +		return -ENOENT;
> +	}
> +
> +	/* As we can not distinguish between mappings for users and groups, we try to
> +	 * resolve all mappings for both cases.
> +	 */
> +
> +	//resolve uid of localname account for all such principals and cache it
> +	for (cln = TAILQ_FIRST (&princ_list->fields); cln; cln = next) 
> +	{ 
> +		next = TAILQ_NEXT (cln, link); 
> +
> +		pw = static_getpwnam(cln->field, NULL, &err);
> +		if (!pw) {
> +			continue;
> +		}
> +		
> +		unode = calloc (1, sizeof *unode);
> +		if (!unode)
> +		{
> +			warnx("static_init: calloc (1, %lu) failed",
> +				(unsigned long)sizeof *unode);
> +			free(pw);
> +			return -ENOMEM;
> +		}
> +		unode->uid = pw->pw_uid;
> +		unode->principal = strdup(cln->field);
> +
> +		unode->localname = conf_get_str("Static", cln->field);
> +		if (!unode->localname) {
> +			free(pw);
> +			return -ENOENT;
> +		}
> +
> +		free(pw);
> +
> +		LIST_INSERT_HEAD (&uid_mappings[uid_hash(unode->uid)], unode, link);
> +	}
> +
> +	//resolve gid of localgroup accounts and cache it
> +	for (cln = TAILQ_FIRST (&princ_list->fields); cln; cln = next) 
> +	{ 
> +		next = TAILQ_NEXT (cln, link); 
> +
> +		gr = static_getgrnam(cln->field, NULL, &err);
> +		if (!pw) {
> +			continue;
> +		}
> +		
> +		gnode = calloc (1, sizeof *gnode);
> +		if (!gnode)
> +		{
> +			warnx("static_init: calloc (1, %lu) failed",
> +				(unsigned long)sizeof *gnode);
> +			free(pw);
> +			return -ENOMEM;
> +		}
> +		gnode->gid = pw->pw_uid;
> +		gnode->principal = strdup(cln->field);
> +
> +		gnode->localgroup = conf_get_str("Static", cln->field);
> +		if (!gnode->localgroup) {
> +			free(pw);
> +			return -ENOENT;
> +		}
> +
> +		free(pw);
> +
> +		LIST_INSERT_HEAD (&gid_mappings[gid_hash(gnode->gid)], gnode, link);
> +	}
> +	return 0;
> +}
> +
>  
>  struct trans_func static_trans = {
>  	.name			= "static",
> -	.init			= NULL,
> -	.name_to_uid		= NULL,
> -	.name_to_gid		= NULL,
> -	.uid_to_name		= NULL,
> -	.gid_to_name		= NULL,
> +	.init			= static_init,
> +	.name_to_uid		= static_name_to_uid,
> +	.name_to_gid		= static_name_to_gid,
> +	.uid_to_name		= static_uid_to_name,
> +	.gid_to_name		= static_gid_to_name,
>  	.princ_to_ids		= static_gss_princ_to_ids,
>  	.gss_princ_to_grouplist	= static_gss_princ_to_grouplist,
>  };
