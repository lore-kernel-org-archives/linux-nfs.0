Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27437 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753946Ab1H2QeL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Aug 2011 12:34:11 -0400
Message-ID: <4E5BBF7F.5090005@RedHat.com>
Date: Mon, 29 Aug 2011 12:34:07 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Ian Kent <raven@themaw.net>
CC: linux-nfs-list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs-utils-1.2.4 - fix nfs4 check
References: <20110818050827.15357.27820.stgit@perseus.themaw.net>
In-Reply-To: <20110818050827.15357.27820.stgit@perseus.themaw.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/18/2011 01:08 AM, Ian Kent wrote:
> From: Ian Kent <ikent@redhat.com>
> 
> nfs_umount_is_vers4() doesn't take acount of the escaping of characters
> seen in /proc/mounts and /etc/mtab as the functions in fstab.c do. This
> leads to an inability to umount a mount containing any of these escaped
> characters (like spaces).
> 
> This patch changes nfs_umount_is_vers4() to use functions in fstab.c and
> adds a function to fstab.c to read /proc/mounts specifically, as it was
> used  for the check in nfs_umount_is_vers4() previously.
> 
> Signed-off-by: Ian Kent <ikent@redhat.com>
Committed... Yes I realize this code goes a way when the
libmount code is enabled, but for legacy reasons I decided
to take it...

steved.
 
> ---
> 
>  utils/mount/fstab.c     |   52 +++++++++++++++++++++++++++++++++
>  utils/mount/fstab.h     |    1 +
>  utils/mount/nfsumount.c |   75 +++++++++++++++++++----------------------------
>  3 files changed, 84 insertions(+), 44 deletions(-)
> 
> diff --git a/utils/mount/fstab.c b/utils/mount/fstab.c
> index 1fc9efe..eedbdda 100644
> --- a/utils/mount/fstab.c
> +++ b/utils/mount/fstab.c
> @@ -86,10 +86,13 @@ mtab_is_writable() {
>  
>  struct mntentchn mounttable;
>  static int got_mtab = 0;
> +struct mntentchn procmounts;
> +static int got_procmounts = 0;
>  struct mntentchn fstab;
>  static int got_fstab = 0;
>  
>  static void read_mounttable(void);
> +static void read_procmounts(void);
>  static void read_fstab(void);
>  
>  static struct mntentchn *
> @@ -101,6 +104,14 @@ mtab_head(void)
>  }
>  
>  static struct mntentchn *
> +procmounts_head(void)
> +{
> +	if (!got_procmounts)
> +		read_procmounts();
> +	return &procmounts;
> +}
> +
> +static struct mntentchn *
>  fstab_head(void)
>  {
>  	if (!got_fstab)
> @@ -186,6 +197,30 @@ read_mounttable() {
>          read_mntentchn(mfp, fnam, mc);
>  }
>  
> +/*
> + * Read /proc/mounts.
> + * This produces a linked list. The list head procmounts is a dummy.
> + * Return 0 on success.
> + */
> +static void
> +read_procmounts() {
> +        mntFILE *mfp;
> +        const char *fnam;
> +        struct mntentchn *mc = &procmounts;
> +
> +        got_procmounts = 1;
> +        mc->nxt = mc->prev = NULL;
> +
> +        fnam = PROC_MOUNTS;
> +        mfp = nfs_setmntent(fnam, "r");
> +        if (mfp == NULL || mfp->mntent_fp == NULL) {
> +                nfs_error(_("warning: can't open %s: %s"),
> +                          PROC_MOUNTS, strerror (errno));
> +                return;
> +        }
> +        read_mntentchn(mfp, fnam, mc);
> +}
> +
>  static void
>  read_fstab()
>  {
> @@ -225,6 +260,23 @@ getmntdirbackward (const char *name, struct mntentchn *mcprev) {
>  }
>  
>  /*
> + * Given the directory name NAME, and the place MCPREV we found it last time,
> + * try to find more occurrences.
> + */
> +struct mntentchn *
> +getprocmntdirbackward (const char *name, struct mntentchn *mcprev) {
> +	struct mntentchn *mc, *mc0;
> +
> +	mc0 = procmounts_head();
> +	if (!mcprev)
> +		mcprev = mc0;
> +	for (mc = mcprev->prev; mc && mc != mc0; mc = mc->prev)
> +		if (streq(mc->m.mnt_dir, name))
> +			return mc;
> +	return NULL;
> +}
> +
> +/*
>   * Given the device name NAME, and the place MCPREV we found it last time,
>   * try to find more occurrences.
>   */ 
> diff --git a/utils/mount/fstab.h b/utils/mount/fstab.h
> index dc7c9fc..313bf9b 100644
> --- a/utils/mount/fstab.h
> +++ b/utils/mount/fstab.h
> @@ -18,6 +18,7 @@ struct mntentchn {
>  
>  struct mntentchn *getmntoptfile (const char *file);
>  struct mntentchn *getmntdirbackward (const char *dir, struct mntentchn *mc);
> +struct mntentchn *getprocmntdirbackward (const char *name, struct mntentchn *mc);
>  struct mntentchn *getmntdevbackward (const char *dev, struct mntentchn *mc);
>  
>  struct mntentchn *getfsfile (const char *file);
> diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
> index 8cd2852..b846564 100644
> --- a/utils/mount/nfsumount.c
> +++ b/utils/mount/nfsumount.c
> @@ -151,65 +151,50 @@ static int del_mtab(const char *spec, const char *node)
>   */
>  static int nfs_umount_is_vers4(const struct mntentchn *mc)
>  {
> -	char buffer[LINELEN], *next;
> +	struct mntentchn *pmc;
> +	struct mount_options *options;
>  	int retval;
> -	FILE *f;
> -
> -	if ((f = fopen(MOUNTSFILE, "r")) == NULL) {
> -		fprintf(stderr, "%s: %s\n",
> -			MOUNTSFILE, strerror(errno));
> -		return -1;
> -	}
>  
>  	retval = -1;
> -	while (fgets(buffer, sizeof(buffer), f) != NULL) {
> -		char *device, *mntdir, *type, *flags;
> -		struct mount_options *options;
> -		char *line = buffer;
> -
> -		next = strchr(line, '\n');
> -		if (next != NULL)
> -			*next = '\0';
> -
> -		device = strtok(line, " \t");
> -		if (device == NULL)
> -			continue;
> -		mntdir = strtok(NULL, " \t");
> -		if (mntdir == NULL)
> -			continue;
> -		if (strcmp(device, mc->m.mnt_fsname) != 0 &&
> -		    strcmp(mntdir, mc->m.mnt_dir) != 0)
> +	pmc = getprocmntdirbackward(mc->m.mnt_dir, NULL);
> +	if (!pmc)
> +		goto not_found;
> +
> +	do {
> +		int nlen = strlen(pmc->m.mnt_fsname);
> +		/*
> +		 * It's possible the mount location string in /proc/mounts
> +		 * ends with a '/'. In this case, if the entry came from
> +		 * /etc/mtab, it won't have the trailing '/' so deal with
> +		 * it.
> +		 */
> +		while (pmc->m.mnt_fsname[nlen - 1] == '/')
> +			nlen--;
> +		if (strncmp(pmc->m.mnt_fsname, mc->m.mnt_fsname, nlen) != 0)
>  			continue;
>  
> -		type = strtok(NULL, " \t");
> -		if (type == NULL)
> -			continue;
> -		if (strcmp(type, "nfs4") == 0)
> +		if (strcmp(pmc->m.mnt_type, "nfs4") == 0)
>  			goto out_nfs4;
>  
> -		flags = strtok(NULL, " \t");
> -		if (flags == NULL)
> -			continue;
> -		options = po_split(flags);
> +		options = po_split(pmc->m.mnt_opts);
>  		if (options != NULL) {
>  			unsigned long version;
> -			int rc;
> -
> -			rc = nfs_nfs_version(options, &version);
> +			int rc = nfs_nfs_version(options, &version);
>  			po_destroy(options);
>  			if (rc && version == 4)
>  				goto out_nfs4;
>  		}
>  
> -		goto out_nfs;
> -	}
> -	if (retval == -1)
> +		if (strcmp(pmc->m.mnt_type, "nfs") == 0)
> +			goto out_nfs;
> +	} while ((pmc = getprocmntdirbackward(mc->m.mnt_dir, pmc)) != NULL);
> +
> +	if (retval == -1) {
> +not_found:
>  		fprintf(stderr, "%s was not found in %s\n",
>  			mc->m.mnt_dir, MOUNTSFILE);
> -
> -out:
> -	fclose(f);
> -	return retval;
> +		goto out;
> +	}
>  
>  out_nfs4:
>  	if (verbose)
> @@ -221,7 +206,9 @@ out_nfs:
>  	if (verbose)
>  		fprintf(stderr, "Legacy NFS mount point detected\n");
>  	retval = 0;
> -	goto out;
> +
> +out:
> +	return retval;
>  }
>  
>  static struct option umount_longopts[] =
> 
