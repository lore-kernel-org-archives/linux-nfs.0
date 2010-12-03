Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42766 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758209Ab0LCOOE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Dec 2010 09:14:04 -0500
Message-ID: <4CF8FB1B.9010502@RedHat.com>
Date: Fri, 03 Dec 2010 09:13:47 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: [PATCH] libnfsidmap: Add numerical string translation
References: <1288046368-18427-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1288046368-18427-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Would it be possible to get an update to
the nfs4_uid_to_name(3) man page documenting
this new routines? It's only thing holding
this from being committed... 

If you give me the verbiage, I'll deal with the
nroff stuff...

steved.  

On 10/25/2010 06:39 PM, Trond Myklebust wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> Add numerical string translation
> 
> nfs4_owner_to_gid and nfs4_owner_to_uid will call their respective
> nfs4_name_to_*id functions first.  If the name could not be resolved, we
> check if the string is a numerical representation of an id number.  If it is,
> we convert the string to an id number.  If not, we map the user to "nobody"
> 
> If we are unable to find a mapping for a uid or gid, we convert the
> id into a numeric string to send to the server.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  libnfsidmap.c |   64 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  nfsidmap.h    |    4 +++
>  2 files changed, 68 insertions(+), 0 deletions(-)
> 
> diff --git a/libnfsidmap.c b/libnfsidmap.c
> index 41a6dc8..5dc2652 100644
> --- a/libnfsidmap.c
> +++ b/libnfsidmap.c
> @@ -42,6 +42,7 @@
>  #include <stdlib.h>
>  #include <stdio.h>
>  #include <string.h>
> +#include <ctype.h>
>  #include <pwd.h>
>  #include <grp.h>
>  #include <netdb.h>
> @@ -92,6 +93,15 @@ static char * toupper_str(char *s)
>  	return s;
>  }
>  
> +static int id_as_chars(char *name, int *id)
> +{
> +	long int value = strtol(name, NULL, 10);
> +	if (value == 0)
> +		return 0;
> +	*id = (int)value;
> +	return 1;
> +}
> +
>  static int domain_from_dns(char **domain)
>  {
>  	struct hostent *he;
> @@ -386,6 +396,20 @@ int nfs4_gid_to_name(gid_t gid, char *domain, char *name, size_t len)
>  	RUN_TRANSLATIONS(gid_to_name, 0, gid, domain, name, len);
>  }
>  
> +int nfs4_uid_to_owner(uid_t uid, char *domain, char *name, size_t len)
> +{
> +	if (nfs4_uid_to_name(uid, domain, name, len))
> +		sprintf(name, "%u", uid);
> +	return 0;
> +}
> +
> +int nfs4_gid_to_group_owner(gid_t gid, char *domain, char *name, size_t len)
> +{
> +	if (nfs4_gid_to_name(gid, domain, name, len))
> +		sprintf(name, "%u", gid);
> +	return 0;
> +}
> +
>  int nfs4_name_to_uid(char *name, uid_t *uid)
>  {
>  	RUN_TRANSLATIONS(name_to_uid, 0, name, uid);
> @@ -396,6 +420,46 @@ int nfs4_name_to_gid(char *name, gid_t *gid)
>  	RUN_TRANSLATIONS(name_to_gid, 0, name, gid);
>  }
>  
> +static int set_id_to_nobody(int *id, int is_uid)
> +{
> +	int rc = 0;
> +	const char name[] = "nobody@";
> +	char nobody[strlen(name) + strlen(get_default_domain()) + 1];
> +	strcpy(nobody, name);
> +	strcat(nobody, get_default_domain());
> +
> +	if (is_uid)
> +		rc = nfs4_name_to_uid(nobody, id);
> +	else
> +		rc = nfs4_name_to_gid(nobody, id);
> +
> +	if (rc) {
> +		*id = -2;
> +		rc = 0;
> +	}
> +	return rc;
> +}
> +
> +int nfs4_owner_to_uid(char *name, uid_t *uid)
> +{
> +	int rc = nfs4_name_to_uid(name, uid);
> +	if (rc && id_as_chars(name, uid))
> +		rc = 0;
> +	else if (rc)
> +		rc = set_id_to_nobody(uid, 1);
> +	return rc;
> +}
> +
> +int nfs4_group_owner_to_gid(char *name, gid_t *gid)
> +{
> +	int rc = nfs4_name_to_gid(name, gid);
> +	if (rc && id_as_chars(name, gid))
> +		rc = 0;
> +	else if (rc)
> +		rc = set_id_to_nobody(gid, 0);
> +	return rc;
> +}
> +
>  int nfs4_gss_princ_to_ids(char *secname, char *princ, uid_t *uid, gid_t *gid)
>  {
>  	RUN_TRANSLATIONS(princ_to_ids, 1, secname, princ, uid, gid, NULL);
> diff --git a/nfsidmap.h b/nfsidmap.h
> index ee54c47..eee40af 100644
> --- a/nfsidmap.h
> +++ b/nfsidmap.h
> @@ -53,8 +53,12 @@ int nfs4_init_name_mapping(char *conffile);
>  int nfs4_get_default_domain(char *server, char *domain, size_t len);
>  int nfs4_uid_to_name(uid_t uid, char *domain, char *name, size_t len);
>  int nfs4_gid_to_name(gid_t gid, char *domain, char *name, size_t len);
> +int nfs4_uid_to_owner(uid_t uid, char *domain, char *name, size_t len);
> +int nfs4_gid_to_group_owner(gid_t gid, char *domain, char *name, size_t len);
>  int nfs4_name_to_uid(char *name, uid_t *uid);
>  int nfs4_name_to_gid(char *name, gid_t *gid);
> +int nfs4_owner_to_uid(char *name, uid_t *uid);
> +int nfs4_owner_to_gid(char *name, gid_t *gid);
>  int nfs4_gss_princ_to_ids(char *secname, char *princ, uid_t *uid, gid_t *gid);
>  int nfs4_gss_princ_to_grouplist(char *secname, char *princ, gid_t *groups, int *ngroups);
>  int nfs4_gss_princ_to_ids_ex(char *secname, char *princ, uid_t *uid, gid_t *gid, extra_mapping_params **ex);
