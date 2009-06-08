From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 00/11] nfs-utils: add TIRPC/IPv6 support to rpc.nfsd
Date: Mon,  8 Jun 2009 14:00:33 -0400
Message-ID: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48144 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683AbZFHSAz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:00:55 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the sixth attempt at a patchset to add TIRPC and IPv6 support to
the rpc.nfsd program. The significant differences from the last set are:

1) Change it to log errors to stderr by default, and add a --syslog
switch to force output to syslog

2) moved nfssvc.c into the nfsd directory (and out of libnfs.a).
rpc.nfsd is the only user of those routines so there's no need to
keep it in common code.

3) declared a common static string buffer for the nfssvc routines
to use to cut down stack usage. It's also smaller than BUFSIZ so the
general memory footprint for rpc.nfsd should be smaller.

There are also a number of cleanups and small fixes.

Comments and suggestions appreciated...

Jeff Layton (11):
  nfs-utils: move nfssvc.c to nfsd dir and clean up linking of nfsd
  nfs-utils: clean up option parsing in nfsd.c
  nfs-utils: convert rpc.nfsd to use xlog()
  nfs-utils: clean up NFSCTL_* macros for handling protocol bits
  nfs-utils: declare a static common buffer for nfssvc.c routines
  nfs-utils: move check for active knfsd to helper function
  nfs-utils: convert nfssvc_setfds to use getaddrinfo
  nfs-utils: break up the nfssvc interface
  nfs-utils: add IPv6 support to nfssvc_setfds
  nfs-utils: add IPv6 support to nfsd
  nfs-utils: update the nfsd manpage and copyright notices

 support/include/nfs/nfs.h |   15 ++-
 support/include/nfslib.h  |    1 -
 support/nfs/Makefile.am   |    2 +-
 support/nfs/nfssvc.c      |  187 -----------------------------
 utils/nfsd/Makefile.am    |    6 +-
 utils/nfsd/nfsd.c         |  264 ++++++++++++++++++++++++++++++-----------
 utils/nfsd/nfsd.man       |   27 ++++-
 utils/nfsd/nfssvc.c       |  290 +++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsd/nfssvc.h       |   27 ++++
 9 files changed, 548 insertions(+), 271 deletions(-)
 delete mode 100644 support/nfs/nfssvc.c
 create mode 100644 utils/nfsd/nfssvc.c
 create mode 100644 utils/nfsd/nfssvc.h

