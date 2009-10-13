Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:39071 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759957AbZJMOzB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:55:01 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEs0hC000815
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:54:01 GMT
Received: from acsmt354.oracle.com (acsmt354.oracle.com [141.146.40.154])
	by acsinet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9D2lOXQ022092
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:55:16 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/26] Basic IPv6 support in statd (take++)
To: linux-nfs@vger.kernel.org
Cc: chris.mason@oracle.com
Date: Tue, 13 Oct 2009 10:54:06 -0400
Message-ID: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I think I've addressed the three major concerns expressed during the
last round of review.

a) The on-disk format (files and directories under /var/lib/nfs) is
   unchanged.

b) IPv6 support is implemented as a series of incremental changes to
   the current statd implementation, not as a full replacement with
   a fresh implementation.  The series can be broken up into chunks
   of 4 or 5 patches and applied over time across nfs-utils releases
   (although it need not be).

c) New features, such as support for sending SM_NOTIFY over TCP and
   support for handling downcalls on IPv6 transports, has been
   removed for now.  No additional support for handling multi-homed
   hosts is introduced.  No additional support for distinguishing
   between client and server peers is introduced.

There remains some clean up that has been discussed previously on this
mailing list.  The on-disk monitor records are now managed in code
that sm-notify and statd share, replacing two separate but equal
implementations.  Additionally, common RPC code is now used to manage
both NLM downcalls and sending SM_NOTIFY requests; again, replacing
separate but similar implementations.

Jeff and I have been testing this code, and it appears to work at
least as well as the IPv4-only version, plus providing support for
monitoring IPv6 hosts.  It is designed to build and work properly with
TI-RPC and without.

I'm expecting to see some additional minor refinements and clean ups
to these patches over the next couple of weeks.  Right now, I would
like some feedback about the architecture of this proposed change.  Is
this overall design acceptable?  Are there parts that are crazy or
unclear that could be improved or better documented?  Outright bugs,
omissions, or oversights?  Do the layering and library APIs make
sense?  Any new security exposures?

I'm cooking up a few additional minor changes, so I'm holding back on
presenting the man page refreshes.  Other than allowing network
addresses specified on the command line to be IPv6 addresses, the
command line synopses for both programs are not changed by this work.

---

Chuck Lever (26):
      statd: Support TI-RPC statd listener
      statd: retain CAP_NET_BIND when dropping privileges
      statd: Support IPv6 in sm_stat_1_svc()
      statd: Support IPv6 in sm_mon_1_svc()
      statd: Support IPv6 in sm_simu_crash_1_svc
      statd: Support IPv6 is caller_is_localhost()
      statd: add IPv6 support in sm_notify_1_svc()
      libnsm.a: add nsm_present_address() API
      statd: Introduce statd version of matchhostname()
      statd: squelch compiler warning in sm-notify.c
      statd: Support IPv6 DNS lookups in smn_lookup
      statd: Use getaddrinfo(3) to generate bind address in smn_create_socket()
      statd: IPv6 support in reserved port binding in smn_create_socket()
      statd: Support creating a PF_INET6 socket in smn_create_socket()
      statd: factor socket creation out of notify()
      statd: Update rmtcall.c
      statd: Support sending SM_NOTIFY requests to IPv6 remotes
      libnsm: Add RPC construction helper functions
      statd: Use the new nsm_ file.c calls in rpc.statd
      statd: Use the new nsm_ file.c calls in sm_notify
      statd: Introduce common routines to handle persistent storage
      statd: Move the sm_inter XDR pieces to libnsm.a
      statd: fix address copy in sm-notify.c
      statd: replace smn_{get,set}_port() with the shared equivalents
      statd: Replace nsm_log() with xlog() in sm-notify command
      statd: Replace note() with xlog() in rpc.statd


 .gitignore                   |    9 
 aclocal/libcap.m4            |   15 +
 configure.ac                 |    4 
 support/Makefile.am          |    2 
 support/include/Makefile.am  |    1 
 support/include/ha-callout.h |    4 
 support/include/nsm.h        |   87 ++++
 support/include/rpcmisc.h    |    5 
 support/nfs/Makefile.am      |    3 
 support/nfs/svc_create.c     |  213 +++++++++++
 support/nsm/Makefile.am      |   45 ++
 support/nsm/file.c           |  816 ++++++++++++++++++++++++++++++++++++++++++
 support/nsm/rpc.c            |  505 ++++++++++++++++++++++++++
 support/nsm/sm_inter.x       |  131 +++++++
 utils/statd/Makefile.am      |   22 -
 utils/statd/callback.c       |   76 +++-
 utils/statd/hostname.c       |  268 ++++++++++++++
 utils/statd/log.c            |   95 -----
 utils/statd/log.h            |   42 --
 utils/statd/misc.c           |   30 --
 utils/statd/monitor.c        |  237 +++++-------
 utils/statd/notlist.c        |    4 
 utils/statd/rmtcall.c        |  165 ++------
 utils/statd/simu.c           |   37 +-
 utils/statd/simulate.c       |   52 +--
 utils/statd/sm-notify.c      |  773 ++++++++++++++++------------------------
 utils/statd/sm-notify.man    |    6 
 utils/statd/sm_inter.x       |  131 -------
 utils/statd/stat.c           |   14 -
 utils/statd/statd.c          |  199 +++-------
 utils/statd/statd.h          |   38 --
 utils/statd/svc_run.c        |    7 
 utils/statd/version.h        |    7 
 33 files changed, 2747 insertions(+), 1296 deletions(-)
 create mode 100644 aclocal/libcap.m4
 create mode 100644 support/include/nsm.h
 create mode 100644 support/nfs/svc_create.c
 create mode 100644 support/nsm/Makefile.am
 create mode 100644 support/nsm/file.c
 create mode 100644 support/nsm/rpc.c
 create mode 100644 support/nsm/sm_inter.x
 create mode 100644 utils/statd/hostname.c
 delete mode 100644 utils/statd/log.c
 delete mode 100644 utils/statd/log.h
 delete mode 100644 utils/statd/sm_inter.x
 delete mode 100644 utils/statd/version.h

-- 
Chuck Lever <chuck.lever@oracle.com>
