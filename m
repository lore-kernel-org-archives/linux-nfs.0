Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48029 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754493Ab3JCS3W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Oct 2013 14:29:22 -0400
Date: Thu, 3 Oct 2013 14:29:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: remove gss_clnt_send_err and gss_destroy_creds
Message-ID: <20131003182918.GA1577@fieldses.org>
References: <1380824881-2958-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380824881-2958-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 03, 2013 at 02:28:01PM -0400, Jeff Layton wrote:
> As Bruce recently pointed out, gss_clnt_send_err basically does an
> unsolicited downcall into the kernel to try and destroy a valid GSS
> context. That has been broken however since this kernel commit:
> 
>     commit 3b68aaeaf54065e5c44583a1d33ffb7793953ba4
>     Author: Trond Myklebust <Trond.Myklebust@netapp.com>
>     Date:   Thu Jun 7 10:14:15 2007 -0400
> 
>         SUNRPC: Always match an upcall message in gss_pipe_downcall()
> 
> Downcalls that don't match an in-progress upcall just get back an
> -ENOENT error and don't actually do anything. Remove these tools
> since they've been useless for the last 6 years.

Thanks, looks good to me.--b.

> 
> Reported-by: "J. Bruce Fields" <bfields@fieldses.org>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  utils/gssd/Makefile.am         |   8 +--
>  utils/gssd/gss_clnt_send_err.c | 108 -----------------------------------------
>  utils/gssd/gss_destroy_creds   |  11 -----
>  3 files changed, 1 insertion(+), 126 deletions(-)
>  delete mode 100644 utils/gssd/gss_clnt_send_err.c
>  delete mode 100644 utils/gssd/gss_destroy_creds
> 
> diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
> index a300da2..a9a3e42 100644
> --- a/utils/gssd/Makefile.am
> +++ b/utils/gssd/Makefile.am
> @@ -5,8 +5,7 @@ man8_MANS	= gssd.man svcgssd.man
>  RPCPREFIX	= rpc.
>  KPREFIX		= @kprefix@
>  sbin_PREFIXED	= gssd svcgssd
> -sbin_PROGRAMS	= $(sbin_PREFIXED) gss_clnt_send_err
> -sbin_SCRIPTS	= gss_destroy_creds
> +sbin_PROGRAMS	= $(sbin_PREFIXED)
>  
>  EXTRA_DIST = \
>  	gss_destroy_creds \
> @@ -65,11 +64,6 @@ svcgssd_LDFLAGS = $(KRBLDFLAGS)
>  svcgssd_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
>  		 $(RPCSECGSS_CFLAGS) $(KRBCFLAGS) $(GSSAPI_CFLAGS)
>  
> -gss_clnt_send_err_SOURCES = gss_clnt_send_err.c
> -
> -gss_clnt_send_err_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
> -		 $(RPCSECGSS_CFLAGS) $(KRBCFLAGS) $(GSSAPI_CFLAGS)
> -
>  MAINTAINERCLEANFILES = Makefile.in
>  
>  #######################################################################
> diff --git a/utils/gssd/gss_clnt_send_err.c b/utils/gssd/gss_clnt_send_err.c
> deleted file mode 100644
> index 4800a01..0000000
> --- a/utils/gssd/gss_clnt_send_err.c
> +++ /dev/null
> @@ -1,108 +0,0 @@
> -/*
> -  Copyright (c) 2000 The Regents of the University of Michigan.
> -  All rights reserved.
> -
> -  Copyright (c) 2004 Bruce Fields <bfields@umich.edu>
> -
> -  Redistribution and use in source and binary forms, with or without
> -  modification, are permitted provided that the following conditions
> -  are met:
> -
> -  1. Redistributions of source code must retain the above copyright
> -     notice, this list of conditions and the following disclaimer.
> -  2. Redistributions in binary form must reproduce the above copyright
> -     notice, this list of conditions and the following disclaimer in the
> -     documentation and/or other materials provided with the distribution.
> -  3. Neither the name of the University nor the names of its
> -     contributors may be used to endorse or promote products derived
> -     from this software without specific prior written permission.
> -
> -  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
> -  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
> -  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> -  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
> -  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> -  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
> -  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
> -  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
> -  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
> -  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> -  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> -*/
> -
> -#ifdef HAVE_CONFIG_H
> -#include <config.h>
> -#endif	/* HAVE_CONFIG_H */
> -
> -#include <sys/param.h>
> -#include <sys/socket.h>
> -#include <sys/types.h>
> -#include <sys/stat.h>
> -#include <rpc/rpc.h>
> -
> -#include <unistd.h>
> -#include <err.h>
> -#include <stdio.h>
> -#include <stdlib.h>
> -#include <string.h>
> -#include <pwd.h>
> -#include <fcntl.h>
> -
> -#include "gssd.h"
> -#include "write_bytes.h"
> -
> -char pipefsdir[PATH_MAX] = GSSD_PIPEFS_DIR;
> -
> -static void
> -usage(char *progname)
> -{
> -	fprintf(stderr, "usage: %s clntdir user [user ...]\n", progname);
> -	exit(1);
> -}
> -
> -static int
> -do_error_downcall(int k5_fd, uid_t uid, int err)
> -{
> -	char    buf[1024];
> -	char    *p = buf, *end = buf + 1024;
> -	unsigned int timeout = 0;
> -	int     zero = 0;
> -
> -	if (WRITE_BYTES(&p, end, uid)) return -1;
> -	if (WRITE_BYTES(&p, end, timeout)) return -1;
> -	/* use seq_win = 0 to indicate an error: */
> -	if (WRITE_BYTES(&p, end, zero)) return -1;
> -	if (WRITE_BYTES(&p, end, err)) return -1;
> -
> -	if (write(k5_fd, buf, p - buf) < p - buf) return -1;
> -	return 0;
> -}
> -
> -int
> -main(int argc, char *argv[])
> -{
> -	int fd;
> -	int i;
> -	uid_t uid;
> -	char *endptr;
> -	struct passwd *pw;
> -
> -	if (argc < 3)
> -		usage(argv[0]);
> -	fd = open(argv[1], O_WRONLY);
> -	if (fd == -1)
> -		err(1, "unable to open %s", argv[1]);
> -
> -	for (i = 2; i < argc; i++) {
> -		uid = strtol(argv[i], &endptr, 10);
> -		if (*endptr != '\0') {
> -			pw = getpwnam(argv[i]);
> -			if (!pw)
> -				err(1, "unknown user %s", argv[i]);
> -			uid = pw->pw_uid;
> -		}
> -		if (do_error_downcall(fd, uid, -1))
> -			err(1, "failed to destroy cred for user %s", argv[i]);
> -	}
> -	exit(0);
> -}
> diff --git a/utils/gssd/gss_destroy_creds b/utils/gssd/gss_destroy_creds
> deleted file mode 100644
> index 1f978d1..0000000
> --- a/utils/gssd/gss_destroy_creds
> +++ /dev/null
> @@ -1,11 +0,0 @@
> -#!/bin/bash
> -
> -path=`mount|grep rpc_pipefs|awk '{ print $3;exit }'`
> -
> -if [ -z "$path" ]; then
> -	echo "unable to find rpc_pipefs; is it mounted?"
> -	exit 1
> -fi;
> -
> -find "$path" -name 'krb5' -exec gss_clnt_send_err '{}' $* ';'
> -
> -- 
> 1.8.3.1
> 
