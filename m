From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 00/10] nfs-utils: add IPv6 support to rpc.nfsd (try #5)
Date: Wed,  3 Jun 2009 15:52:33 -0400
Message-ID: <1244058763-10352-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51426 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753876AbZFCTwp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 15:52:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the fifth attempt at a patchset to add IPv6 support to the
rpc.nfsd program. This set is quite a bit different from the earlier
ones. The main differences are relatively minor cleanups and
refinements.

I've also taken greater care to break up the patchset into smaller
pieces. This does mean that multiple patches touch the same areas of
code but the individual patches should be a bit smaller.

This set should be bisectable, but I've only really tested the final
result. I have tested it on various combinations of build options and
with ipv6.ko blacklisted and it seems to work appropriately in all
cases.

Jeff Layton (10):
  nfs-utils: don't link libexport.a and libmisc.a to nfsd
  nfs-utils: clean up option parsing in nfsd.c
  nfs-utils: convert rpc.nfsd to use xlog()
  nfs-utils: clean up NFSCTL_* macros for handling protocol bits
  nfs-utils: move check for active knfsd to helper function
  nfs-utils: convert nfssvc_setfds to use getaddrinfo
  nfs-utils: break up the nfssvc interface
  nfs-utils: add IPv6 support to nfssvc_setfds
  nfs-utils: add IPv6 support to nfsd
  nfs-utils: update the nfsd manpage

 support/include/nfs/nfs.h |   15 ++-
 support/include/nfslib.h  |    7 +-
 support/nfs/nfssvc.c      |  261 +++++++++++++++++++++++++++++++--------------
 utils/nfsd/Makefile.am    |    4 +-
 utils/nfsd/nfsd.c         |  258 ++++++++++++++++++++++++++++++++------------
 utils/nfsd/nfsd.man       |   19 +++-
 6 files changed, 401 insertions(+), 163 deletions(-)

