Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34470 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933173AbcKGTQ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 Nov 2016 14:16:58 -0500
Subject: Re: [PATCH nfs-utils v2] nfs-server-generator: avoid using external
 services.
To: NeilBrown <neilb@suse.com>
References: <8737k0215d.fsf@notabene.neil.brown.name>
 <4a004767-e7cd-d427-706e-4e144b7bdbbb@RedHat.com>
 <87wpgnq8jx.fsf@notabene.neil.brown.name>
 <d58fc30b-bd9a-c280-c8a3-0358e9f1de01@RedHat.com>
 <87lgx2ram0.fsf@notabene.neil.brown.name>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <9cc0dda7-f00f-2725-2898-5939aac7bb02@RedHat.com>
Date: Mon, 7 Nov 2016 14:16:07 -0500
MIME-Version: 1.0
In-Reply-To: <87lgx2ram0.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/01/2016 08:25 PM, NeilBrown wrote:
> nfs-server-generator is run very early when a lot of services are not
> yet started, so it mustn't depend on them.  Currently it can try to
> use hostname lookup and syslog.  Using hostname lookup can cause
> errors and when these are logged via syslog, it can cause the
> generator to block indefinitely
>
> Hostname-lookup is not needed, as we don't use the host issue,
> and sending message to stderr is sufficient for the generator.
>
> Disabling syslog is easy - call a function that sets a static variable.
>
> Disabling hostname lookup requires adding an "ignore_hosts" flags to
> export_read and export_d_read().
>
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed!

steved.
> ---
>
> Hi Steve,
>  I decided that you were right and the interface wasn't really very
>  nice.
>  And it wasn't that hard to make a more sensible interface.
>  So I did that.  Less need for comments, but I put an appropriate
>  comment in anyway.
>
> Thanks,
> NeilBrown
>
>
>  support/export/export.c        | 13 +++++++++----
>  support/include/exportfs.h     |  4 ++--
>  systemd/nfs-server-generator.c |  4 ++--
>  utils/exportfs/exportfs.c      |  4 ++--
>  4 files changed, 15 insertions(+), 10 deletions(-)
>
> diff --git a/support/export/export.c b/support/export/export.c
> index 0b8a858c2c74..15e91cb3eb71 100644
> --- a/support/export/export.c
> +++ b/support/export/export.c
> @@ -70,11 +70,15 @@ static void warn_duplicated_exports(nfs_export *exp, struct exportent *eep)
>  /**
>   * export_read - read entries from /etc/exports
>   * @fname: name of file to read from
> + * @ignore_hosts: don't check validity of host names
>   *
>   * Returns number of read entries.
> + * @ignore_hosts can be set when the host names won't be used
> + * and when getting delays or errors due to problems with
> + * hostname looking is not acceptable.
>   */
>  int
> -export_read(char *fname)
> +export_read(char *fname, int ignore_hosts)
>  {
>  	struct exportent	*eep;
>  	nfs_export		*exp;
> @@ -83,7 +87,7 @@ export_read(char *fname)
>  
>  	setexportent(fname, "r");
>  	while ((eep = getexportent(0,1)) != NULL) {
> -		exp = export_lookup(eep->e_hostname, eep->e_path, 0);
> +		exp = export_lookup(eep->e_hostname, eep->e_path, ignore_hosts);
>  		if (!exp) {
>  			if (export_create(eep, 0))
>  				/* possible complaints already logged */
> @@ -100,13 +104,14 @@ export_read(char *fname)
>  /**
>   * export_d_read - read entries from /etc/exports.
>   * @fname: name of directory to read from
> + * @ignore_hosts: don't check validity of host names
>   *
>   * Returns number of read entries.
>   * Based on mnt_table_parse_dir() in
>   *  util-linux-ng/shlibs/mount/src/tab_parse.c
>   */
>  int
> -export_d_read(const char *dname)
> +export_d_read(const char *dname, int ignore_hosts)
>  {
>  	int n = 0, i;
>  	struct dirent **namelist = NULL;
> @@ -150,7 +155,7 @@ export_d_read(const char *dname)
>  			continue;
>  		}
>  
> -		volumes += export_read(fname);
> +		volumes += export_read(fname, ignore_hosts);
>  	}
>  
>  	for (i = 0; i < n; i++)
> diff --git a/support/include/exportfs.h b/support/include/exportfs.h
> index f033329b5fd2..32d4fe95fd7e 100644
> --- a/support/include/exportfs.h
> +++ b/support/include/exportfs.h
> @@ -134,8 +134,8 @@ struct addrinfo *		client_resolve(const struct sockaddr *sap);
>  int 				client_member(const char *client,
>  						const char *name);
>  
> -int				export_read(char *fname);
> -int				export_d_read(const char *dname);
> +int				export_read(char *fname, int ignore_hosts);
> +int				export_d_read(const char *dname, int ignore_hosts);
>  void				export_reset(nfs_export *);
>  nfs_export *			export_lookup(char *hname, char *path, int caconical);
>  nfs_export *			export_find(const struct addrinfo *ai,
> diff --git a/systemd/nfs-server-generator.c b/systemd/nfs-server-generator.c
> index af8bb52bfbd7..44895f1f8582 100644
> --- a/systemd/nfs-server-generator.c
> +++ b/systemd/nfs-server-generator.c
> @@ -102,8 +102,8 @@ int main(int argc, char *argv[])
>  	path = malloc(strlen(argv[1]) + sizeof(dirbase) + sizeof(filebase));
>  	if (!path)
>  		exit(2);
> -	if (export_read(_PATH_EXPORTS) +
> -	    export_d_read(_PATH_EXPORTS_D) == 0)
> +	if (export_read(_PATH_EXPORTS, 1) +
> +	    export_d_read(_PATH_EXPORTS_D, 1) == 0)
>  		/* Nothing is exported, so nothing to do */
>  		exit(0);
>  
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 4ac2c15ae13e..5136810029d0 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -183,8 +183,8 @@ main(int argc, char **argv)
>  	atexit(release_lockfile);
>  
>  	if (f_export && ! f_ignore) {
> -		if (! (export_read(_PATH_EXPORTS) +
> -		       export_d_read(_PATH_EXPORTS_D))) {
> +		if (! (export_read(_PATH_EXPORTS, 0) +
> +		       export_d_read(_PATH_EXPORTS_D, 0))) {
>  			if (f_verbose)
>  				xlog(L_WARNING, "No file systems exported!");
>  		}

