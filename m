Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46732 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751483AbZEZPPy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 May 2009 11:15:54 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com, steved@redhat.com
Subject: [PATCH 0/6] nfs-utils: add IPv6 support for rpc.nfsd (try #2)
Date: Tue, 26 May 2009 11:15:45 -0400
Message-Id: <1243350951-13462-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is the second attempt to add support IPv6 to rpc.nfsd. The main
changes since the last patchset are:

1) the addition of a patch that makes nfsd look at /etc/netconfig when
tirpc is enabled, and to disable any family/protocol combinations that
don't have visible netid's.

2) stop linking in some unneeded .a libs.

3) some minor bugfixes

4) update to the nfsd manpage for new options

I think the set is bisectable, but have only really tested the final
result. I've also tested the final result when built with tirpc enabled
and disabled, and ipv6 enabled and disabled.

I haven't seen any regressions when testing on recent mainline kernels
and The only real difference that anyone may notice is that when IPv6
support is built in, and the kernel doesn't support IPv6, nfsd logs this
message a couple of times when starting nfsd:

nfssvc: writing fds to kernel failed: errno 97 (Address family not supported by protocol)

Most of the testing I've done has been by watching the program under
strace.  Since most of the kernel work for IPv6 support hasn't made it
to mainline, it's a little difficult to do much testing of this beyond
that.

Jeff Layton (6):
  nfs-utils: don't link libexport.a and libmisc.a to nfsd
  nfs-utils: break up nfssvc.c into more individually callable
    functions
  nfs-utils: set IPV6_V6ONLY on nfssvc IPv6 sockets
  nfs-utils: add IPv6 support to nfsd
  nfs-utils: limit protocols and families used by nfsd to those listed
    in /etc/netconfig
  nfs-utils: add -4 and -6 options to nfsd manpage

 support/include/nfslib.h |    8 ++-
 support/nfs/nfssvc.c     |  164 +++++++++++++++++++++++++++++++++----------
 utils/nfsd/Makefile.am   |    4 +-
 utils/nfsd/nfsd.c        |  175 ++++++++++++++++++++++++++++++++++++++--------
 utils/nfsd/nfsd.man      |   10 +++
 5 files changed, 292 insertions(+), 69 deletions(-)

