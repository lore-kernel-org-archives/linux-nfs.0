Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f53.google.com ([209.85.216.53]:51857 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570Ab1LWTrM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Dec 2011 14:47:12 -0500
Received: by qadb15 with SMTP id b15so6236728qad.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Dec 2011 11:47:11 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] autoconf: clean up linking in nfs-utils
Date: Fri, 23 Dec 2011 14:47:02 -0500
Message-Id: <1324669625-2948-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is a cleanup of the linking in nfs-utils. This should
reduce the number of unnecessary libraries that each of the binaries are
linked against.

I've tested this on relatively recent machines with --enable-tirpc and
--disable-tirpc and it seems to do the right thing. But, as there are a
lot of possible combinations, it's difficult to know if this will break
more obscure setups. For that reason, this should probably go in fairly
soon to ensure that it gets plenty of testing.

Jeff Layton (3):
  autoconf: fix up libevent autoconf test
  autoconf: don't let libnfsidmap test add -lnfsidmap to $LIBS
  autoconf: only link binaries that need it to libtirpc

 aclocal/libevent.m4         |    3 ++-
 aclocal/libnfsidmap.m4      |    9 ++++++---
 aclocal/libtirpc.m4         |   15 +++++++++++++--
 tools/rpcgen/Makefile.am    |    1 +
 utils/gssd/Makefile.am      |    6 +++---
 utils/idmapd/Makefile.am    |    2 +-
 utils/mount/Makefile.am     |    3 ++-
 utils/mountd/Makefile.am    |    2 +-
 utils/nfsd/Makefile.am      |    2 +-
 utils/nfsidmap/Makefile.am  |    2 +-
 utils/showmount/Makefile.am |    3 ++-
 utils/statd/Makefile.am     |    4 ++--
 12 files changed, 35 insertions(+), 17 deletions(-)

-- 
1.7.7.4

