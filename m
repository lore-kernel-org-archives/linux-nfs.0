Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22317 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757224Ab1CCTxJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 14:53:09 -0500
Message-ID: <4D6FF1A2.8060205@RedHat.com>
Date: Thu, 03 Mar 2011 14:53:06 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Karel Zak <kzak@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] mount: add --enable-libmount-mount
References: <1299159822-25190-1-git-send-email-kzak@redhat.com> <1299159822-25190-3-git-send-email-kzak@redhat.com>
In-Reply-To: <1299159822-25190-3-git-send-email-kzak@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 03/03/2011 08:43 AM, Karel Zak wrote:

> +static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
> +{
> +	int rc, c;
> +	char *spec = NULL, *opts = NULL;
> +
> +	static const struct option longopts[] = {
> +		{ "force", 0, 0, 'f' },
> +		{ "help", 0, 0, 'h' },
> +		{ "no-mtab", 0, 0, 'n' },
> +		{ "verbose", 0, 0, 'v' },
> +		{ "read-only", 0, 0, 'r' },
> +		{ "lazy", 0, 0, 'l' },
> +		{ "types", 1, 0, 't' },
> +		{ NULL, 0, 0, 0 }
> +	};
> +
> +	mnt_context_init_helper(cxt, MNT_ACT_UMOUNT, 0);
> +
> +	while ((c = getopt_long (argc, argv, "fvnrlh", longopts, NULL)) != -1) {
> +
> +		rc = mnt_context_helper_setopt(cxt, c, optarg);
> +		if (rc == 0)		/* valid option */
> +			continue;
> +		if (rc < 0)		/* error (probably ENOMEM) */
> +			goto err;
> +					/* rc==1 means unknow option */
> +		umount_usage();
> +		return EX_USAGE;
> +	}
> +
> +	if (optind < argc)
> +		spec = argv[optind++];
> +
> +	if (!spec || (*spec != '/' && strchr(spec,':') == NULL)) {
> +		nfs_error(_("%s: no mount point provided"), progname);
> +		return EX_USAGE;
> +	}
> +
> +	if (mnt_context_set_target(cxt, spec))
> +		goto err;
> +	if (mnt_context_set_fstype_pattern(cxt, "nfs,nfs4"))	/* restrict filesystems */
> +		goto err;
> +
> +	/* read mtab/fstab, evaluate permissions, etc. */
> +	rc = mnt_context_prepare_umount(cxt);
> +	if (rc) {
> +		nfs_error(_("%s: failed to prepare umount: %s\n"),
> +					progname, strerror(-rc));
> +		goto err;
> +	}
> +
> +	opts = retrieve_mount_options(mnt_context_get_fs(cxt));
> +
> +	if (!mnt_context_is_lazy(cxt)) {
> +		if (opts) {
> +			/* we have full FS description (e.g. from mtab or /proc) */
> +			switch (is_vers4(cxt)) {
> +			case 0:
> +				/* We ignore the error from nfs_umount23.
> +				 * If the actual umount succeeds (in del_mtab),
> +				 * we don't want to signal an error, as that
> +				 * could cause /sbin/mount to retry!
> +				 */
> +				nfs_umount23(mnt_context_get_source(cxt), opts);
> +				break;
> +			case 1:			/* unknown */
> +				break;
> +			default:		/* error */
> +				goto err;
> +			}
> +		} else
> +			/* strange, no entry in mtab or /proc not mounted */
> +			nfs_umount23(spec, "tcp,v3");
Question: since retrieve_mount_options() returns NULL why do you assume 
the mount exists? What's happing is I'm doing an umount.nfs on an 
not existing mount point and the error is 
    umount.nfs: remote share not in 'host:dir' format

Instead of
    umount.nfs: /mnt/home: not mounted

steved.
  
