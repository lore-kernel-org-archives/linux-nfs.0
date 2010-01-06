From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/4] nfs-utils: add statdb_dump utility
Date: Wed, 6 Jan 2010 08:11:14 -0500
Message-ID: <B8627CA1-7835-4845-95D9-CB53274CFEFE@oracle.com>
References: <1262782412-7050-1-git-send-email-jlayton@redhat.com> <1262782412-7050-4-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:17612 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716Ab0AFNLs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2010 08:11:48 -0500
In-Reply-To: <1262782412-7050-4-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 6, 2010, at 7:53 AM, Jeff Layton wrote:

> To dump contents of statd's monitor DB.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> tests/Makefile.am   |    6 +++
> tests/statdb_dump.c |   98 ++++++++++++++++++++++++++++++++++++++++++ 
> +++++++++
> 2 files changed, 104 insertions(+), 0 deletions(-)
> create mode 100644 tests/statdb_dump.c
>
> diff --git a/tests/Makefile.am b/tests/Makefile.am
> index 375af80..a20b42b 100644
> --- a/tests/Makefile.am
> +++ b/tests/Makefile.am
> @@ -1,5 +1,11 @@
> ## Process this file with automake to produce Makefile.in
>
> +check_PROGRAMS = statdb_dump
> +statdb_dump_SOURCES = statdb_dump.c
> +
> +statdb_dump_LDADD = ../support/nfs/libnfs.a \
> +		    ../support/nsm/libnsm.a $(LIBCAP)
> +
> SUBDIRS = nsm_client
>
> MAINTAINERCLEANFILES = Makefile.in
> diff --git a/tests/statdb_dump.c b/tests/statdb_dump.c
> new file mode 100644
> index 0000000..a891bd7
> --- /dev/null
> +++ b/tests/statdb_dump.c
> @@ -0,0 +1,98 @@
> +/*
> + * statdb_dump.c -- dump contents of statd's monitor DB
> + *
> + * Copyright (C) 2010  Red Hat, Jeff Layton <jlayton@redhat.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; either version 2
> + * of the License, or (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor,
> + * Boston, MA 02110-1301, USA.
> + */
> +
> +#ifdef HAVE_CONFIG_H
> +#include "config.h"
> +#endif
> +
> +#include <sys/socket.h>
> +#include <netdb.h>
> +#include <stdio.h>
> +#include <errno.h>
> +
> +#include "nsm.h"
> +#include "xlog.h"
> +
> +static char cookiebuf[(SM_PRIV_SIZE * 2) + 1];
> +static char addrbuf[INET6_ADDRSTRLEN + 1];
> +
> +static unsigned int
> +dump_host(const char *hostname, const struct sockaddr *sa, const  
> struct mon *m,
> +	  const time_t timestamp)
> +{
> +	int ret;
> +	socklen_t salen;
> +
> +	ret = nsm_priv_to_hex(m->priv, cookiebuf, sizeof(cookiebuf));
> +	if (!ret) {
> +		xlog(L_ERROR, "Unable to convert cookie to hex string.\n");
> +		return ret;
> +	}
> +
> +	switch (sa->sa_family) {
> +	case AF_INET:
> +		salen = sizeof(struct sockaddr_in);
> +		break;
> +	case AF_INET6:
> +		salen = sizeof(struct sockaddr_in6);
> +		break;
> +	default:
> +		xlog(L_ERROR, "Unrecognized address family: %hu\n",
> +			sa->sa_family);
> +		return 0;
> +	}
> +
> +	ret = getnameinfo(sa, salen, addrbuf, sizeof(addrbuf), NULL, 0,
> +			  NI_NUMERICHOST);

getnameinfo(3) isn't available in older versions of glibc.  Usually  
this needs to be wrapped in #if HAVE_GETNAMEINFO, and an alternate  
version provided for when getnameinfo(3) isn't available.

I think you can safely use inet_ntop(3) in all cases here.

> +
> +	if (ret) {
> +		xlog(L_ERROR, "Unable to convert address to string: %s",
> +			ret == EAI_SYSTEM ? strerror(errno) :
> +				gai_strerror(ret));
> +		return 0;
> +	}
> +
> +	/*
> +	 * Callers of this program should assume that in the future, extra
> +	 * fields may be added to the output. Anyone adding extra fields to
> +	 * the output should add them to the end of the line.
> +	 */
> +	printf("%s %s %s %s %s %d %d %d\n",
> +			hostname, addrbuf, cookiebuf,
> +			m->mon_id.mon_name,
> +			m->mon_id.my_id.my_name,
> +			m->mon_id.my_id.my_prog,
> +			m->mon_id.my_id.my_vers,
> +			m->mon_id.my_id.my_proc);
> +
> +	return 1;
> +}
> +
> +int
> +main(int argc, char **argv)
> +{
> +	xlog_syslog(0);
> +	xlog_stderr(1);
> +	xlog_open(argv[0]);
> +	
> +	nsm_load_monitor_list(dump_host);
> +	return 0;
> +}
> -- 
> 1.6.5.2
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



