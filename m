Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18706 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674Ab0I2WNd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 18:13:33 -0400
Subject: Re: [PATCH] nfs-utils: Add nfs.upcall for idmapper
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, SteveD@redhat.com
In-Reply-To: <4CA39681.3000104@netapp.com>
References: <4CA39681.3000104@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 29 Sep 2010 18:13:16 -0400
Message-ID: <1285798396.3557.18.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-09-29 at 15:41 -0400, Bryan Schumaker wrote:
> Add nfs.upcall
> 
> This patch adds the nfs.upcall program to nfs-utils.  This program is called by
> the nfs idmapper through request-keys to map between uid / user name and
> gid / group name.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
> diff --git a/aclocal/keyutils.m4 b/aclocal/keyutils.m4
> new file mode 100644
> index 0000000..84bc112
> --- /dev/null
> +++ b/aclocal/keyutils.m4
> @@ -0,0 +1,11 @@
> +dnl Checks for keyutils library and headers
> +dnl
> +AC_DEFUN([AC_KEYUTILS], [
> +
> +  dnl Check for libkeyutils; do not add to LIBS if found
> +  AC_CHECK_LIB([keyutils], [keyctl_instantiate], [LIBKEYUTILS=-lkeyutils], ,)
> +  AC_SUBST(LIBKEYUTILS)
> +
> +  AC_CHECK_HEADERS([keyutils.h], ,
> +  		   [AC_MSG_ERROR([keyutils.h header not found.])])
> +])dnl
> diff --git a/configure.ac b/configure.ac
> index 3058be6..a5e8620 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -247,6 +247,9 @@ if test "$enable_nfsv4" = yes; then
>    dnl check for nfsidmap libraries and headers
>    AC_LIBNFSIDMAP
>  
> +  dnl check for the keyutils libraries and headers
> +  AC_KEYUTILS
> +
>    dnl librpcsecgss already has a dependency on libgssapi,
>    dnl but we need to make sure we get the right version
>    if test "$enable_gss" = yes; then
> @@ -435,6 +438,7 @@ AC_CONFIG_FILES([
>  	utils/mountd/Makefile
>  	utils/nfsd/Makefile
>  	utils/nfsstat/Makefile
> +	utils/nfs.upcall/Makefile
>  	utils/showmount/Makefile
>  	utils/statd/Makefile
>  	tests/Makefile
> diff --git a/utils/Makefile.am b/utils/Makefile.am
> index 8665183..0104a6c 100644
> --- a/utils/Makefile.am
> +++ b/utils/Makefile.am
> @@ -4,6 +4,7 @@ OPTDIRS =
>  
>  if CONFIG_NFSV4
>  OPTDIRS += idmapd
> +OPTDIRS += nfs.upcall
>  endif
>  
>  if CONFIG_GSS
> diff --git a/utils/nfs.upcall/Makefile.am b/utils/nfs.upcall/Makefile.am
> new file mode 100644
> index 0000000..52afd3d
> --- /dev/null
> +++ b/utils/nfs.upcall/Makefile.am
> @@ -0,0 +1,7 @@
> +## Process this file with automake to produce Makefile.in
> +
> +sbin_PROGRAMS	= nfs.upcall
> +nfs_upcall_SOURCES = nfs.upcall.c
> +nfs_upcall_LDADD = -lnfsidmap -lkeyutils
> +
> +MAINTAINERCLEANFILES = Makefile.in
> diff --git a/utils/nfs.upcall/nfs.upcall.c b/utils/nfs.upcall/nfs.upcall.c
> new file mode 100644
> index 0000000..37aa5e9
> --- /dev/null
> +++ b/utils/nfs.upcall/nfs.upcall.c
> @@ -0,0 +1,120 @@
> +
> +#include <stdarg.h>
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <string.h>
> +
> +#include <pwd.h>
> +#include <grp.h>
> +#include <keyutils.h>
> +#include <nfsidmap.h>
> +
> +#include <syslog.h>
> +
> +/* gcc nfs.upcall.c -o nfs.upcall -l nfsidmap -l keyutils */
> +
> +#define MAX_ID_LEN   11
> +#define IDMAP_NAMESZ 128
> +#define USER  1
> +#define GROUP 0
> +
> +
> +/*
> + * Find either a user or group id based on the name@domain string
> + */
> +int id_lookup(char *name_at_domain, key_serial_t key, int type)
> +{
> +	char id[MAX_ID_LEN];
> +	uid_t uid = 0;
> +	gid_t gid = 0;
> +	int rc;
> +
> +	if (type == USER) {
> +		rc = nfs4_owner_to_uid(name_at_domain, &uid);
> +		sprintf(id, "%u", uid);
> +	} else {
> +		rc = nfs4_group_owner_to_gid(name_at_domain, &gid);
> +		sprintf(id, "%u", gid);
> +	}
> +
> +	if (rc == 0)
> +		rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
> +
> +	return rc;
> +}
> +
> +/*
> + * Find the name@domain string from either a user or group id
> + */
> +int name_lookup(char *id, key_serial_t key, int type)
> +{
> +	char name[IDMAP_NAMESZ];
> +	char domain[NFS4_MAX_DOMAIN_LEN];
> +	uid_t uid;
> +	gid_t gid;
> +	int rc;
> +
> +	rc = nfs4_get_default_domain(NULL, domain, NFS4_MAX_DOMAIN_LEN);
> +	if (rc != 0) {
> +		rc = -1;
> +		goto out;
> +	}
> +
> +	if (type == USER) {
> +		uid = atoi(id);
> +		rc = nfs4_uid_to_name(uid, domain, name, IDMAP_NAMESZ);
> +	} else {
> +		gid = atoi(id);
> +		rc = nfs4_gid_to_name(gid, domain, name, IDMAP_NAMESZ);
> +	}
> +
> +	if (rc == 0)
> +		rc = keyctl_instantiate(key, &name, strlen(name), 0);
> +
> +out:
> +	return rc;
> +}
> +
> +int main(int argc, char **argv)
> +{
> +	char *arg;
> +	char *value;
> +	char *type;
> +	int rc = 1;
> +	int timeout = 600;
> +	key_serial_t key;
> +
> +	if (argc < 3)
> +		return 1;
> +
> +	arg = malloc(sizeof(char) * strlen(argv[2]) + 1);
> +	strcpy(arg, argv[2]);
> +	type = strtok(arg, ":");
> +	value = strtok(NULL, ":");
> +
> +	if (argc == 4) {
> +		timeout = atoi(argv[3]);
> +		if (timeout < 0)
> +			timeout = 0;
> +	}
> +
> +	key = strtol(argv[1], NULL, 10);
> +
> +	if (strcmp(type, "uid") == 0)
> +		rc = id_lookup(value, key, USER);
> +	else if (strcmp(type, "gid") == 0)
> +		rc = id_lookup(value, key, GROUP);
> +	else if (strcmp(type, "user") == 0)
> +		rc = name_lookup(value, key, USER);
> +	else if (strcmp(type, "group") == 0)
> +		rc = name_lookup(value, key, GROUP);
> +
> +	/* Set timeout to 5 (600 seconds) minutes */
> +	if (rc == 0)
> +		keyctl_set_timeout(key, timeout);
> +	else
> +		keyctl_negate(key, timeout, 0);

Hmm... I've been looking more closely at the design of request-key. It
looks as if the idea there is that you are supposed to return without
instantiating the key if you are unable to service the request.

Basically, if your program exits with a non-zero value, then request-key
is supposed to look at the next matching entry in /etc/request-key.conf
(until it hits they very last entry, which is always 'keyctl negate').

Sorry, Bryan. The above line was a result of me bugging you. I should
have checked the sources first...

> +	free(arg);
> +	return rc;
> +}

Cheers
  Trond
