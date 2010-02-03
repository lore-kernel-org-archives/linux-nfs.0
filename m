Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49506 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754362Ab0BCGjI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 01:39:08 -0500
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 03 Feb 2010 17:31:30 +1100
Subject: [PATCH 0/9] Cache deferal improvements - try++
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100203060657.12945.27293.stgit@notabene.brown>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks to Bruce challenging me to justify the complexity of my
previous version of this I have managed to simplify it significantly.

I have changed the rules for sunrpc_caches so that items that have
expired get removed at the earliest opportunity even if they are still
referenced, and in particular so that sunrpc_cache_lookup never
returns an expired item.
This means that cache_check doesn't need to check for "expired" any
more and so only initiates an upcall for items that are not VALID.

This means that when the upcall is responded to, it will always be
exactly that item that is updated - never a different item with the
same key.  So there is no longer any need to repeat the lookup.

The last 3 patches in this series are simply "cleanups" that I
happened across while mucking about in the code.  The should have zero
change in functionality, and if you don't think they are cleanups
(second last is now questionable), feel free to ignore them.

I have tested this to ensure that it doesn't completely break things,
and to ensure that it fixes the problem(*) but I haven't hammered on
it very hard.

(*)
The problem is exhibited by sending a stream of writes to the NFS
server and then occasionally flushing the export cache (exportfs -f).
The problem manifests by a write not getting a reply and the client 
having to retransmit.
It is 'fixed' if there are no retransmit delays.
The follow generates the required writes and shows the delays.

Without the patch I get delays of 60 seconds with TCP and 5 seconds
with UDP.

NeilBrown

/*
 * write to NFS server and report delays exceeding 1 second.
 */

#define _GNU_SOURCE

#include <sys/time.h>
#include <stdio.h>
#include <sys/fcntl.h>
#include <malloc.h>
#include <memory.h>

main(int argc, char *argv[])
{
	int usec;
	//int fd = open(argv[1], O_WRONLY|O_DIRECT|O_CREAT, 0666);
	//int fd = open(argv[1], O_WRONLY|O_SYNC|O_CREAT, 0666);
	int fd = open(argv[1], O_WRONLY|O_CREAT, 0666);
	char *buf;
	struct timeval tv1, tv2;

	posix_memalign(&buf, 4096, 409600);
	memset(buf, 0x5a, 409600);

	while(1) {
		gettimeofday(&tv1, NULL);
		write(fd, buf, 409600);
		gettimeofday(&tv2, NULL);
		usec = (tv2.tv_sec*1000000 + tv2.tv_usec) -
			(tv1.tv_sec*1000000 + tv1.tv_usec);
		if (usec > 1000000)
			printf(" %d\n", usec/1000000);
		else
			printf(".");
		fflush(stdout);
	}
}


---

NeilBrown (9):
      sunrpc: don't keep expired entries in the auth caches.
      sunrpc/cache: factor out cache_is_expired
      sunrpc: never return expired entries in sunrpc_cache_lookup
      sunrpc/cache: allow threads to block while waiting for cache update.
      nfsd/idmap: drop special request deferal in favour of improved default.
      sunrpc: close connection when a request is irretrievably lost.
      nfsd: factor out hash functions for export caches.
      svcauth_gss: replace a trivial 'switch' with an 'if'
      sunrpc/cache: change deferred-request hash table to use hlist.


 fs/nfsd/export.c                  |   40 ++++++++------
 fs/nfsd/nfs4idmap.c               |  105 ++++--------------------------------
 include/linux/sunrpc/cache.h      |    5 +-
 include/linux/sunrpc/svcauth.h    |   10 ++-
 net/sunrpc/auth_gss/svcauth_gss.c |   51 ++++++++---------
 net/sunrpc/cache.c                |  109 ++++++++++++++++++++++++++-----------
 net/sunrpc/svc.c                  |    3 +
 net/sunrpc/svc_xprt.c             |   11 ++++
 net/sunrpc/svcauth_unix.c         |   11 +++-
 9 files changed, 169 insertions(+), 176 deletions(-)


