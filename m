Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:34488 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933875AbcKJPA5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2016 10:00:57 -0500
Received: by mail-qk0-f173.google.com with SMTP id q130so298982839qke.1
        for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2016 07:00:57 -0800 (PST)
Message-ID: <1478790053.2402.5.camel@redhat.com>
Subject: Re: [PATCH/RFC nfs-utils] nfsdcltrack: read configuration from a
 file
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Thu, 10 Nov 2016 10:00:53 -0500
In-Reply-To: <8737j0lyms.fsf@notabene.neil.brown.name>
References: <87k2cdmi26.fsf@notabene.neil.brown.name>
         <1478692626.2394.9.camel@redhat.com>
         <877f8c9pku.fsf@notabene.neil.brown.name>
         <1478739358.2442.1.camel@redhat.com>
         <8737j0lyms.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-11-10 at 15:58 +1100, NeilBrown wrote:
> As nfsdcltrack is normally run directly from the kernel
> there is no opportunity to change the default
> storage directory.  This can be useful in a cluster to
> locate the "storage directory" on shared storage.
> 
> The easiest alternative is to allow configuration to be read from a
> file, particularly as nfs-utils already has code for parsing a config file.
> 
> So read the config file "/etc/nfs.conf" (or as set by ./configure) and
> look for "storagedir" and "debug" in the "nfsdcltrack" section.
> These values can still be over-ridden by command line options.
> 
> A generic name (nfs.conf) was changes for the config file so that
> other daemons can be enhanced to read configuration from there.
> This may be easier than passing command line arguments through systemd.
> 
I like the basic idea, but I'm not so sure we want to use a generic
config file like this. What else do you envision using this file?

That said, if we are going to do this, we should probably make it clear
that it's for server-side configuration. Maybe "nfsd.conf" or
"nfs-server.conf" would be a better name?

> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  configure.ac                      |  7 +++++++
>  utils/nfsdcltrack/nfsdcltrack.c   | 12 ++++++++++++
>  utils/nfsdcltrack/nfsdcltrack.man | 14 ++++++++++++++
>  3 files changed, 33 insertions(+)
> 
> diff --git a/configure.ac b/configure.ac
> index d60f3a2f7efa..8a5aa2e5203b 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -24,6 +24,12 @@ AC_ARG_WITH(statedir,
>  	statedir=$withval,
>  	statedir=/var/lib/nfs)
>  	AC_SUBST(statedir)
> +AC_ARG_WITH(nfsconfig,
> +	[AC_HELP_STRING([--with-nfsconfig=/config/file],
> +			[use general config file /config/file @<:@default=/etc/nfs.conf@:>@])],
> +	nfsconfig=$withval,
> +	nfsconfig=/etc/nfs.conf)
> +	AC_SUBST(nfsconfig)
>  AC_ARG_WITH(statdpath,
>  	[AC_HELP_STRING([--with-statdpath=/foo],
>  			[define the statd state dir as /foo instead of the NFS statedir @<:@default=/var/lib/nfs@:>@])],
> @@ -468,6 +474,7 @@ dnl Export some path names to config.h
>  dnl *************************************************************
>  AC_DEFINE_UNQUOTED(NFS_STATEDIR, "$statedir", [This defines the location of the NFS state files. Warning: this must match definitions in config.mk!])
>  AC_DEFINE_UNQUOTED(NSM_DEFAULT_STATEDIR, "$statdpath", [Define this to the pathname where statd keeps its state file])
> +AC_DEFINE_UNQUOTED(NFS_CONFFILE, "$nfsconfig", [This defines the location of NFS daemon config file])
>  
>  if test "x$cross_compiling" = "xno"; then
>  	CFLAGS_FOR_BUILD=${CFLAGS_FOR_BUILD-"$CFLAGS"}
> diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
> index fcdda7f66b8b..e6e514b78316 100644
> --- a/utils/nfsdcltrack/nfsdcltrack.c
> +++ b/utils/nfsdcltrack/nfsdcltrack.c
> @@ -43,6 +43,7 @@
>  #include <sys/capability.h>
>  #endif
>  
> +#include "conffile.h"
>  #include "xlog.h"
>  #include "sqlite.h"
>  
> @@ -55,6 +56,8 @@
>  /* defined by RFC 3530 */
>  #define NFS4_OPAQUE_LIMIT	1024
>  
> +char *conf_path = NFS_CONFFILE;
> +
>  /* private data structures */
>  struct cltrack_cmd {
>  	char *name;
> @@ -553,6 +556,7 @@ int
>  main(int argc, char **argv)
>  {
>  	char arg;
> +	char *val;
>  	int rc = 0;
>  	char *progname, *cmdarg = NULL;
>  	struct cltrack_cmd *cmd;
> @@ -562,6 +566,14 @@ main(int argc, char **argv)
>  	xlog_syslog(1);
>  	xlog_stderr(0);
>  
> +	conf_init();
> +	val = conf_get_str("nfsdcltrack", "storagedir");
> +	if (val)
> +		storagedir = val;
> +	rc = conf_get_num("nfsdcltrack", "debug", 0);
> +	if (rc > 0)
> +		xlog_config(D_ALL, 1);
> +
>  	/* process command-line options */
>  	while ((arg = getopt_long(argc, argv, "hdfs:", longopts,
>  				  NULL)) != EOF) {
> diff --git a/utils/nfsdcltrack/nfsdcltrack.man b/utils/nfsdcltrack/nfsdcltrack.man
> index 4b8f4d762a00..cc24b7a2c32e 100644
> --- a/utils/nfsdcltrack/nfsdcltrack.man
> +++ b/utils/nfsdcltrack/nfsdcltrack.man
> @@ -67,6 +67,20 @@ Check to see if a nfs_client_id4 is allowed to reclaim. This command requires a
>  .IP "\fBgracedone\fR" 4
>  .IX Item "gracedone"
>  Remove any unreclaimed client records from the database. This command requires a epoch boot time as an argument.
> +.SH "EXTERNAL CONFIGURATION"
> +The directory for stable storage information can be set via the file
> +.B /etc/nfs.conf
> +by setting the
> +.B storagedir
> +value in the
> +.B nfsdcltrack
> +section.  For example:
> +.in +5
> +[nfsdcltrack]
> +.br
> +  storagedir = /shared/nfs/nfsdcltrack
> +.in -5
> +Debuging to syslog can also be enabled by setting "debug = 1" in this file.
>  .SH "LEGACY TRANSITION MECHANISM"
>  .IX Header "LEGACY TRANSITION MECHANISM"
>  The Linux kernel NFSv4 server has historically tracked this information

-- 
Jeff Layton <jlayton@redhat.com>
