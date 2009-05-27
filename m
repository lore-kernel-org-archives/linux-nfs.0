Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40501 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761611AbZE0Lyi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 May 2009 07:54:38 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com, steved@redhat.com
Subject: [PATCH 0/5] nfs-utils: add IPv6 support for rpc.nfsd (try #3)
Date: Wed, 27 May 2009 07:54:30 -0400
Message-Id: <1243425275-6284-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is the third attempt to add support IPv6 to rpc.nfsd. The main
changes since the last patchset are:

1) removal of the -4 and -6 options. The preferred way to disable
address families for now will be to configure /etc/netconfig. It's
probably better not to add new command line options until there is a
clear need for them. Since I'm not adding new options, I've dropped the
manpage patch too. We may still want a manpage update eventually to
discuss how one should disable address families for nfsd.

2) Fixed the error handling when ipv6.ko is blacklisted. The earlier
patchset would cause the program to error out when it couldn't create a
socket for an address family. Now, as long as the program succeeds in
creating sockets for at least one address family it will declare
success. It will however, log an error that it was unable to create the
socket for the other.

I think the set is bisectable, but have only really tested the final
result. I've also tested the final result when built with tirpc enabled
and disabled, and ipv6 enabled and disabled. I've also tested this with
a rpc.nfsd built for IPv6 on a host that has ipv6.ko blacklisted.

Most of the testing I've done has been by watching the program under
strace. Since most of the kernel work for IPv6 support hasn't made it
to mainline, it's a little difficult to do much testing of this beyond
that.

Jeff Layton (5):
  nfs-utils: don't link libexport.a and libmisc.a to nfsd
  nfs-utils: break up nfssvc.c into more individually callable
    functions
  nfs-utils: set IPV6_V6ONLY on nfssvc IPv6 sockets
  nfs-utils: add IPv6 support to nfsd
  nfs-utils: limit protocols and families used by nfsd to those listed
    in /etc/netconfig

 support/include/nfslib.h |    8 ++-
 support/nfs/nfssvc.c     |  201 +++++++++++++++++++++++++++++++++++----------
 utils/nfsd/Makefile.am   |    4 +-
 utils/nfsd/nfsd.c        |  180 ++++++++++++++++++++++++++++++++++-------
 4 files changed, 316 insertions(+), 77 deletions(-)

