Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59702 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750971AbcKASpH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Nov 2016 14:45:07 -0400
Subject: Re: [PATCH nfs-utils] nfs-server-generator: avoid using external
 services.
To: NeilBrown <neilb@suse.com>
References: <8737k0215d.fsf@notabene.neil.brown.name>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <4a004767-e7cd-d427-706e-4e144b7bdbbb@RedHat.com>
Date: Tue, 1 Nov 2016 14:45:06 -0400
MIME-Version: 1.0
In-Reply-To: <8737k0215d.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 10/13/2016 02:50 AM, NeilBrown wrote:
> 
> nfs-server-generator is run very early when a lot of services
> are not yet started, so it mustn't depend on them.
> Currently it can try to use hostname lookup and syslog.
> 
> Hostname-lookup is not needed, as we don't use the host issue,
> and sending message to stderr is sufficient for the generator.
> 
> Disabling syslog is easy - call a function that sets a static variable.
> 
> Disabling hostname lookup isn't quite so easy, so add a static variable
> which can be set to disable it.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> hi,
>  I contemplated passing another arg to export_read() and export_d_read()
>  to resolve this, but it didn't seem worth it.
> 
>  Is this approach OK to people?
It's not the most eloquent interface I've 
ever seen... ;-) 

What are the failures this is fixing? When a
hostname lookup is done what happens? Failure
hangs stopping the server from coming up?

 
> 
> Thanks,
> NeilBrown
> 
> 
>  support/export/export.c        | 12 ++++++++++--
>  support/include/exportfs.h     |  1 +
>  systemd/nfs-server-generator.c |  4 ++++
>  3 files changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/support/export/export.c b/support/export/export.c
> index 0b8a858c2c74..c65dc8807a4e 100644
> --- a/support/export/export.c
> +++ b/support/export/export.c
> @@ -67,6 +67,14 @@ static void warn_duplicated_exports(nfs_export *exp, struct exportent *eep)
>  	}
>  }
If we do have to stay with this approach, 
I definitely think comment explaining
why its needed and what it does.

Finally, on an unrelated issue I'm seeing 
SELinux preventing nfs-server-generator from 
accessing nfs-server.service.d/order-with-mounts.conf
because of a labeling issue. I guess the label
should be nfsd_unit_file_t not systemd_unit_file_t

steved. 
>  
> +static int assume_canonical = 0;
> +
> +void
> +export_avoid_host_lookup(int i)
> +{
> +	assume_canonical = i;
> +}
> +
>  /**
>   * export_read - read entries from /etc/exports
>   * @fname: name of file to read from
> @@ -83,9 +91,9 @@ export_read(char *fname)
>  
>  	setexportent(fname, "r");
>  	while ((eep = getexportent(0,1)) != NULL) {
> -		exp = export_lookup(eep->e_hostname, eep->e_path, 0);
> +		exp = export_lookup(eep->e_hostname, eep->e_path, assume_canonical);
>  		if (!exp) {
> -			if (export_create(eep, 0))
> +			if (export_create(eep, assume_canonical))
>  				/* possible complaints already logged */
>  				volumes++;
>  		}
> diff --git a/support/include/exportfs.h b/support/include/exportfs.h
> index f033329b5fd2..ba45b2dee199 100644
> --- a/support/include/exportfs.h
> +++ b/support/include/exportfs.h
> @@ -134,6 +134,7 @@ struct addrinfo *		client_resolve(const struct sockaddr *sap);
>  int 				client_member(const char *client,
>  						const char *name);
>  
> +void				export_avoid_host_lookup(int i);
>  int				export_read(char *fname);
>  int				export_d_read(const char *dname);
>  void				export_reset(nfs_export *);
> diff --git a/systemd/nfs-server-generator.c b/systemd/nfs-server-generator.c
> index af8bb52bfbd7..7ae6dd1c4b20 100644
> --- a/systemd/nfs-server-generator.c
> +++ b/systemd/nfs-server-generator.c
> @@ -93,6 +93,10 @@ int main(int argc, char *argv[])
>  	FILE		*f, *fstab;
>  	struct mntent	*mnt;
>  
> +	/* Avoid using any external services */
> +	xlog_syslog(0);
> +	export_avoid_host_lookup(1);
> +
>  	if (argc != 4 || argv[1][0] != '/') {
>  		fprintf(stderr, "nfs-server-generator: create systemd dependencies for nfs-server\n");
>  		fprintf(stderr, "Usage: normal-dir early-dir late-dir\n");
> 
