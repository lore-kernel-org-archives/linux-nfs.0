From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 00/29] IPv6 support for statd
Date: Thu, 12 Nov 2009 11:04:29 -0500
Message-ID: <FDD15FCE-996F-420B-8CBD-4E4B7C1221AA@oracle.com>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Chris Mason <Chris.Mason@oracle.com>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:31925 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426AbZKLQEm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Nov 2009 11:04:42 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please note: I expect a few more updates to some of these patches  
because there are some shared functions that may change somewhat as  
mountd IPv6 support is completed, and because other NFS maintainers  
have yet to review this series.  However, the basic architecture and  
feature set is complete, and should be reviewed as is.

On Nov 10, 2009, at 4:56 PM, Chuck Lever wrote:

> Hi Steve-
>
> There have been some bug fixes since I posted the statd IPv6 support
> patch series a month ago.  Jeff suggested I should post a refresh.
>
> ---
>
> Chuck Lever (29):
>      statd: Send unqualified and fully qualified mon_name in SM_NOTIFY
>      statd: Use my_name when sending SM_NOTIFY requests
>      statd: update rpc.statd(8) and sm-notify(8) to reflect IPv6  
> support
>      statd: Support TI-RPC statd listener
>      libnsm.a: retain CAP_NET_BIND when dropping privileges
>      statd: Support IPv6 in sm_stat_1_svc()
>      statd: Support IPv6 in sm_mon_1_svc()
>      statd: Support IPv6 in sm_simu_crash_1_svc
>      statd: Support IPv6 is caller_is_localhost()
>      statd: add IPv6 support in sm_notify_1_svc()
>      statd: add nsm_present_address() API
>      statd: Introduce statd version of matchhostname()
>      statd: squelch compiler warning in sm-notify.c
>      statd: Support IPv6 DNS lookups in smn_lookup
>      statd: Use getaddrinfo(3) to generate bind address in  
> smn_create_socket()
>      statd: IPv6 support in reserved port binding in  
> smn_create_socket()
>      statd: Support creating a PF_INET6 socket in smn_create_socket()
>      statd: factor socket creation out of notify()
>      statd: Update rmtcall.c
>      statd: Support sending SM_NOTIFY requests to IPv6 remotes
>      libnsm.a: Add RPC construction helper functions
>      statd: Use the new nsm_ file.c calls in rpc.statd
>      statd: Use the new nsm_ file.c calls in sm_notify
>      libnsm.a: Introduce common routines to handle persistent storage
>      libnsm.a: Move the sm_inter XDR pieces to libnsm.a
>      statd: fix address copy in sm-notify.c
>      statd: replace smn_{get,set}_port() with the shared equivalents
>      statd: Replace nsm_log() with xlog() in sm-notify command
>      statd: Replace note() with xlog() in rpc.statd
>
>
> .gitignore                   |    9
> aclocal/libcap.m4            |   15 +
> configure.ac                 |    4
> support/Makefile.am          |    2
> support/include/Makefile.am  |    1
> support/include/ha-callout.h |    4
> support/include/nsm.h        |   87 ++++
> support/include/rpcmisc.h    |    5
> support/nfs/Makefile.am      |    3
> support/nfs/svc_create.c     |  213 ++++++++++
> support/nsm/Makefile.am      |   45 ++
> support/nsm/file.c           |  816 +++++++++++++++++++++++++++++++++ 
> +++++++
> support/nsm/rpc.c            |  505 +++++++++++++++++++++++++
> support/nsm/sm_inter.x       |  131 ++++++
> utils/statd/Makefile.am      |   22 -
> utils/statd/callback.c       |   76 +++-
> utils/statd/hostname.c       |  251 ++++++++++++
> utils/statd/log.c            |   95 -----
> utils/statd/log.h            |   42 --
> utils/statd/misc.c           |   30 -
> utils/statd/monitor.c        |  237 +++++-------
> utils/statd/notlist.c        |    4
> utils/statd/rmtcall.c        |  165 ++------
> utils/statd/simu.c           |   37 +-
> utils/statd/simulate.c       |   52 +--
> utils/statd/sm-notify.c      |  854 ++++++++++++++++++ 
> +-----------------------
> utils/statd/sm-notify.man    |  409 ++++++++++++++------
> utils/statd/sm_inter.x       |  131 ------
> utils/statd/stat.c           |   14 -
> utils/statd/statd.c          |  199 +++-------
> utils/statd/statd.h          |   38 --
> utils/statd/statd.man        |  494 +++++++++++++++++-------
> utils/statd/svc_run.c        |    7
> utils/statd/version.h        |    7
> 34 files changed, 3432 insertions(+), 1572 deletions(-)
> create mode 100644 aclocal/libcap.m4
> create mode 100644 support/include/nsm.h
> create mode 100644 support/nfs/svc_create.c
> create mode 100644 support/nsm/Makefile.am
> create mode 100644 support/nsm/file.c
> create mode 100644 support/nsm/rpc.c
> create mode 100644 support/nsm/sm_inter.x
> create mode 100644 utils/statd/hostname.c
> delete mode 100644 utils/statd/log.c
> delete mode 100644 utils/statd/log.h
> delete mode 100644 utils/statd/sm_inter.x
> delete mode 100644 utils/statd/version.h
>
> -- 
> Signature
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



