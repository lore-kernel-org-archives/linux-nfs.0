From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1 / 2] Move NFS mount code from util-linux to
	nfs-utils
Date: Fri, 9 Jun 2006 16:14:34 +1000
Message-ID: <17545.4554.906159.103397@cse.unsw.edu.au>
References: <44887628.5020901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FoaH2-0001l8-2y
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 23:15:12 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FoaH1-0002Gn-8O
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 23:15:12 -0700
To: Amit Gud <agud@redhat.com>
In-Reply-To: message from Amit Gud on Thursday June 8
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday June 8, agud@redhat.com wrote:
> 
> Adds the mount directory and the code to mount and umount the NFS file system.
> 
> 
> Signed-off-by: Amit Gud <agud@redhat.com>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> ---
> diff -uprN nfs-utils-1.0.8/utils/mount/mount.c nfs-utils-1.0.8-ag/utils/mount/mount.c
> --- nfs-utils-1.0.8/utils/mount/mount.c	1969-12-31 19:00:00.000000000 -0500
> +++ nfs-utils-1.0.8-ag/utils/mount/mount.c	2006-06-08 11:22:22.107815000 -0400
> +
> +extern int nfsumount(int, char **);
> +extern int nfs4mount(const char *, const char *, int *, char **,
> +		char **, int);
> +extern int nfsmount(const char *, const char *, int *, char **,
> +		char **, int *, int);

Any chance of these going in an include file?  I really like the same
include file to be included both where the function is defined and
where it is used, so there is a some real checking of signature
consistency going on.

> +int add_mtab(char *fsname, char *mount_point, char *fstype, int flags, char *opts, int freq, int passno)
> +{
> +	struct mntent ment;
> +	int fd;
> +	FILE *mtab;
> +
> +	ment.mnt_fsname = fsname;
> +	ment.mnt_dir = mount_point;
> +	ment.mnt_type = fstype;
> +	ment.mnt_opts = fix_opts_string(flags, opts);
> +	ment.mnt_freq = 0;
> +	ment.mnt_passno= 0;
> +
> +	if ((fd = open(MTAB_FILE"~", O_RDWR|O_CREAT|O_EXCL, 0600)) == -1)	{
> +		fprintf(stderr, "Can't get "MOUNTED"~ lock file");

I think you mean "MTAB_FILE"~

But in the next patch, it is _PATH_MOUNTED.
A bit of consistence here would be a good thing!

> +		return 1;
> +	}
> +        close(fd);
> +
> +        if ((mtab = setmntent(MTAB_FILE, "a+")) == NULL) {
> +		fprintf(stderr, "Can't open " MTAB_FILE);
> +		return 1;
> +	}

> +
> +void mount_usage()
> +{
> +	printf("usage: %s remotetarget dir [-rvnh] [-t version] [-o nfsoptions]\n", progname);
> +	printf("options:\n\t-r\t\tmount readonly\n");
> +	printf("\t-v\t\tverbose\n");
> +	printf("\t-n\t\tno mtab updation\n");

I don't think 'updation' is a word :-)
Maybe:   -n    Do not update /etc/mtab

> +	printf("\t-h\t\tprint this help\n");
> +	printf("\tversion\t\tnfs4 - NFS version 4, nfs - older NFS version supported\n");
> +	printf("\tnfsoptions\tRefer mount.nfs(8) or nfs(5)\n\n");
> +}


> +
> +	spec = canonicalize(argv[1]);
> +	mount_point = canonicalize(argv[2]);
> +

I'm certain you don't want to 'canonicalize' "spec" as it is not a
local path name.  I'm not convinced that you want to canonicalize
mount_point, but I cannot immediately see any harm in it.

> +
> +	parse_opts(mount_opts, &flags, &extra_opts);
> +
> +	if (!strcmp(progname, "mount.nfs4") || nfs_mount_vers == 4) {
> +		nfs_mount_vers = 4;
> +		mnt_err = nfs4mount(spec, mount_point, &flags, &extra_opts, &mount_opts, 0);
> +	}
> +
> +	/* fall back to v3 if v4 didn't work */

Nope.  Falling back to v2 if v3 didn't work and no explicit version
was given is OK,  Falling back to v3 if v4 doesn't work is definitely
not ok because
  1- we only use v4 if an explicit version is asked for
  2- v4 is very different, and has different path names for places on
            the server.

> +	if (mnt_err && errno != EBUSY && errno != ENOENT) {
> +		nfs_mount_vers = 3;
> +		mnt_err = nfsmount(spec, mount_point, &flags, &extra_opts, &mount_opts, &nfs_mount_vers, 0);
> +	}
> +
> +	if (!mnt_err) {
> +		do_mount_syscall(spec, mount_point, nfs_mount_vers == 4 ? "nfs4" : "nfs", flags, mount_opts);
> +		if(!nomtab)
> +			add_mtab(spec, mount_point, nfs_mount_vers == 4 ? "nfs4" : "nfs",
> +				 flags, extra_opts, 0, 0);
> +	}

I think I would prefer to have two completely separate branches here,
one for v4, one for v2/3 (But if you really really don't like that
idea, I might listen).

> diff -uprN nfs-utils-1.0.8/utils/mount/mount_constants.h nfs-utils-1.0.8-ag/utils/mount/mount_constants.h
> --- nfs-utils-1.0.8/utils/mount/mount_constants.h	1969-12-31 19:00:00.000000000 -0500
> +++ nfs-utils-1.0.8-ag/utils/mount/mount_constants.h	2006-06-08 11:22:22.113815000 -0400
> @@ -0,0 +1,74 @@
> +#ifndef _NFS_MOUNT_CONSTANTS_H
> +#define _NFS_MOUNT_CONSTANTS_H
> +
> +#ifndef MS_RDONLY
> +#define MS_RDONLY	 1	/* Mount read-only */
> +#endif
> +#ifndef MS_NOSUID
> +#define MS_NOSUID	 2	/* Ignore suid and sgid bits */
> +#endif
> +#ifndef MS_NODEV
> +#define MS_NODEV	 4	/* Disallow access to device special files */
> +#endif
> +#ifndef MS_NOEXEC
> +#define MS_NOEXEC	 8	/* Disallow program execution */
> +#endif
> +#ifndef MS_SYNCHRONOUS
> +#define MS_SYNCHRONOUS	16	/* Writes are synced at once */
> +#endif
> +#ifndef MS_REMOUNT
> +#define MS_REMOUNT	32	/* Alter flags of a mounted FS */
> +#endif
> +#ifndef MS_MANDLOCK
> +#define MS_MANDLOCK	64	/* Allow mandatory locks on an FS */
> +#endif
> +#ifndef MS_DIRSYNC
> +#define MS_DIRSYNC	128	/* Directory modifications are synchronous */
> +#endif

Do we really need all of this?  Is there any system at all that we
want to support that doesn't have these in <sys/mount.h> ??



> diff -uprN nfs-utils-1.0.8/utils/mount/mount.nfs.man nfs-utils-1.0.8-ag/utils/mount/mount.nfs.man
> --- nfs-utils-1.0.8/utils/mount/mount.nfs.man	1969-12-31 19:00:00.000000000 -0500
> +++ nfs-utils-1.0.8-ag/utils/mount/mount.nfs.man	2006-06-08 11:22:22.118815000 -0400
> @@ -0,0 +1,87 @@
> +.\"@(#)mount.nfs.8"
> +.TH MOUNT.NFS 8 "5 Jun 2006"
> +.SH NAME
> +mount.nfs, mount.nfs4 \- mount a Network File System
> +.SH SYNOPSIS
> +.BI "mount.nfs" " remotetarget dir" " [\-rvnh ] [\-t " version "] [\-o " options "]
> +.SH DESCRIPTION
> +.BR mount.nfs
> +is a part of 
> +.BR nfs (5)
> +utilities package, which provides NFS client functionality.
> +
> +.BR mount.nfs 
> +is meant to be used by the
> +.BR mount (8)
> +command for mounting NFS shares. This subcommand, however, can also be used as a standalone command with limited functionality.
> +
> +.BR mount.nfs 
                ^^^ 4 ??

> +is used for mounting NFSv4 file system, while 
> +.BR mount.nfs 
> +is used to mount NFS file systems with older versions.
                        v2 or v3 filesystems.
Saying "older versions" is, I think, the wrong emphasis.  They are
simply different versions.

> +.I remotetarget 
> +is a server share usually in the form of 
> +.BR servername:/path/to/share.
> +.I dir 
> +is the directory on which the file system is to be mounted.
> +
> +.SH OPTIONS
> +.TP
> +.BI "\-r"
> +Mount file system readonly.
> +.TP
> +.BI "\-v"
> +Be verbose.
> +.TP
> +.BI "\-n"
> +Make no updation to mtab. By default, an entry is created in 
           ^^^^^^^^
There's that word again :-)


> +.I /etc/mtab 
> +for every mounted file system. Use this option to skip making an entry.
> +.TP
> +.BI "\-h"
> +Print help message.
> +.TP
> +.BI "version"
> +Specify NFS file system version. Either
> +.BR nfs4 
> +or 
> +.BR nfs.
> +By default 
> +.BR mount.nfs4 
> +takes version 4, and 
> +.BR mount.nfs 
> +takes any supported older version.

This implied that
         mount.nfs4 -t nfs
will use a v3 or v2 mount, but that code doesn't do that.
I would say something like:
   If the command is "mount.nfs4" or the filesystem type is nfs4,
   then version4 is used, else version 3 or 2 is used.


> +.TP
> +.BI "nfsoptions"
> +Refer 

Refer to

> +.BR nfs(5)
> +or
> +.BR mount(8) 
> +manual pages.
> +
> +.SH NOTE
> +For further information please refer 
                                        to
> +.BR nfs (5)
> +and
> +.BR mount (8)
> +manual pages.


> diff -uprN nfs-utils-1.0.8/utils/mount/nfs4mount.c nfs-utils-1.0.8-ag/utils/mount/nfs4mount.c
> --- nfs-utils-1.0.8/utils/mount/nfs4mount.c	1969-12-31 19:00:00.000000000 -0500
> +++ nfs-utils-1.0.8-ag/utils/mount/nfs4mount.c	2006-06-08 11:27:25.318390000 -0400
> @@ -0,0 +1,450 @@
> +/*
> + * nfs4mount.c -- Linux NFS mount
> + * Copyright (C) 2002 Trond Myklebust <trond.myklebust@fys.uio.no>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2, or (at your option)
> + * any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Note: this file based on the original nfsmount.c
> + *
> + * 2006-06-06 Amit Gud <agud@redhat.com>
> + * - Moved to nfs-utils/utils/mount from util-linux/mount.
> + */
> +
> +#include <linux/posix_types.h>
> +#include <asm/posix_types.h>
> +#undef __FD_CLR
> +#undef __FD_SET
> +#undef __FD_ISSET
> +#undef __FD_ZERO

Is it possible to avoid including anything from 'linux' or 'asm' ?? 
It is generally considered to be bad form.


> diff -uprN nfs-utils-1.0.8/utils/mount/nfsmount.h nfs-utils-1.0.8-ag/utils/mount/nfsmount.h
> --- nfs-utils-1.0.8/utils/mount/nfsmount.h	1969-12-31 19:00:00.000000000 -0500
> +++ nfs-utils-1.0.8-ag/utils/mount/nfsmount.h	2006-06-08 11:22:22.152816000 -0400
> @@ -0,0 +1,328 @@
> +/*
> + * Please do not edit this file.
> + * It was generated using rpcgen.
> + */

Please do not post this file.  It was generated using rpcgen
:-)

> diff -uprN nfs-utils-1.0.8/utils/mount/umount.nfs.man nfs-utils-1.0.8-ag/utils/mount/umount.nfs.man
> --- nfs-utils-1.0.8/utils/mount/umount.nfs.man	1969-12-31 19:00:00.000000000 -0500
> +++ nfs-utils-1.0.8-ag/utils/mount/umount.nfs.man	2006-06-08 11:22:22.177815000 -0400
> +.BI "\-n"
> +Make no updation to mtab. By default, an entry is created in 

and again....


I haven't looked closely at the core mount/umount code, but it seemed
reasonable and I assume it works...

If you'd like to send me a revised patch, it can probably get included
in the next nfs-utils.... though it occurs to me that it might be good
to have a  
   --without-mount
option to configure for distros that don't want to start using the
new-improved approach just yet.

NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
