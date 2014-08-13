Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1381 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753150AbaHMQpg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2014 12:45:36 -0400
Message-ID: <53EB962C.5000001@RedHat.com>
Date: Wed, 13 Aug 2014 12:45:32 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Christian Seiler <christian@iwakd.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] libnfsidmap: respect Nobody-User/Nobody-Group
References: <1401794264-3975-1-git-send-email-christian@iwakd.de>
In-Reply-To: <1401794264-3975-1-git-send-email-christian@iwakd.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/03/2014 07:17 AM, Christian Seiler wrote:
> Previous behavior of libnfsidmap was to do a name lookup of
> nobody@DEFAULTDOMAIN (for both user and group), which does not match
> the behavior of rpc.idmapd.
> 
> This patch makes libnfsidmap respect Nobody-User/Nobody-Group for
> lookups, thus making the nfsidmap utility properly handle the case if
> nobody@DEFAULTDOMAIN does not directly map to any user/group on the
> system.
> 
> Signed-off-by: Christian Seiler <christian@iwakd.de>
Wow... This one fell of the radar... sorry about that! 

Committed! 

steved.

> ---
>  libnfsidmap.c |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 48 insertions(+)
> 
> diff --git a/libnfsidmap.c b/libnfsidmap.c
> index 92bc493..4903c1e 100644
> --- a/libnfsidmap.c
> +++ b/libnfsidmap.c
> @@ -62,6 +62,8 @@ static struct conf_list *local_realms;
>  int idmap_verbosity = 0;
>  static struct mapping_plugin **nfs4_plugins = NULL;
>  static struct mapping_plugin **gss_plugins = NULL;
> +uid_t nobody_uid = (uid_t)-1;
> +gid_t nobody_gid = (gid_t)-1;
>  
>  #ifndef PATH_PLUGINS
>  #define PATH_PLUGINS "/usr/lib/libnfsidmap"
> @@ -228,6 +230,7 @@ int nfs4_init_name_mapping(char *conffile)
>  	int ret = -ENOENT;
>  	int dflt = 0;
>  	struct conf_list *nfs4_methods, *gss_methods;
> +	char *nobody_user, *nobody_group;
>  
>  	/* XXX: need to be able to reload configurations... */
>  	if (nfs4_plugins) /* already succesfully initialized */
> @@ -324,6 +327,39 @@ int nfs4_init_name_mapping(char *conffile)
>  		if (load_plugins(gss_methods, &gss_plugins) == -1)
>  			goto out;
>  	}
> +
> +	nobody_user = conf_get_str("Mapping", "Nobody-User");
> +	if (nobody_user) {
> +		size_t buflen = sysconf(_SC_GETPW_R_SIZE_MAX);
> +		struct passwd *buf;
> +		struct passwd *pw = NULL;
> +		int err;
> +
> +		buf = malloc(sizeof(*buf) + buflen);
> +		if (buf) {
> +			err = getpwnam_r(nobody_user, buf, ((char *)buf) + sizeof(*buf), buflen, &pw);
> +			if (err == 0 && pw != NULL)
> +				nobody_uid = pw->pw_uid;
> +			free(buf);
> +		}
> +	}
> +
> +	nobody_group = conf_get_str("Mapping", "Nobody-Group");
> +	if (nobody_group) {
> +		size_t buflen = sysconf(_SC_GETGR_R_SIZE_MAX);
> +		struct group *buf;
> +		struct group *gr = NULL;
> +		int err;
> +
> +		buf = malloc(sizeof(*buf) + buflen);
> +		if (buf) {
> +			err = getgrnam_r(nobody_group, buf, ((char *)buf) + sizeof(*buf), buflen, &gr);
> +			if (err == 0 && gr != NULL)
> +				nobody_gid = gr->gr_gid;
> +			free(buf);
> +		}
> +	}
> +
>  	ret = 0;
>  out:
>  	if (ret) {
> @@ -453,6 +489,18 @@ static int set_id_to_nobody(int *id, int is_uid)
>  	int rc = 0;
>  	const char name[] = "nobody@";
>  	char nobody[strlen(name) + strlen(get_default_domain()) + 1];
> +
> +	/* First try to see whether a Nobody-User/Nobody-Group was
> +         * configured, before we try to do a full lookup for the
> +         * NFS nobody user. */
> +	if (is_uid && nobody_uid != (uid_t)-1) {
> +		*id = (int)nobody_uid;
> +		return 0;
> +	} else if (!is_uid && nobody_gid != (gid_t)-1) {
> +		*id = (int)nobody_gid;
> +		return 0;
> +	}
> +
>  	strcpy(nobody, name);
>  	strcat(nobody, get_default_domain());
>  
> 
