Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEE11C2BC61
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 19:17:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 64B2F20664
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 19:17:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64B2F20664
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726532AbeJaELz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 00:11:55 -0400
Received: from fieldses.org ([173.255.197.46]:53490 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726235AbeJaELz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Oct 2018 00:11:55 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 815F82056; Tue, 30 Oct 2018 15:17:10 -0400 (EDT)
Date:   Tue, 30 Oct 2018 15:17:10 -0400
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>
Subject: [GIT PULL] nfsd changes for 4.20
Message-ID: <20181030191710.GA23042@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please pull nfsd changes for 4.20:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.20

Olga added support for the NFSv4.2 asynchronous copy protocol.  We
already supported COPY, by copying a limited amount of data and then
returning a short result, letting the client resend.  The asynchronous
protocol should offer better performance at the expense of some
complexity.

The other highlight is Trond's work to convert the duplicate reply cache
to a red-black tree, and to move it and some other server caches to RCU.
(Previously these have meant taking global spinlocks on every RPC.)

Otherwise, some RDMA work and miscellaneous bugfixes.

--b.

Amir Goldstein (1):
      lockd: fix access beyond unterminated strings in prints

Andrew Elble (1):
      nfsd: correctly decrement odstate refcount in error path

Chuck Lever (4):
      svcrdma: Reduce max_send_sges
      svcrdma: Remove ->release_rqst call in bc reply handler
      svcrdma: Remove try_module_get from backchannel
      svcrdma: Increase the default connection credit limit

Gustavo A. R. Silva (1):
      nfsd: fix fall-through annotations

Olga Kornievskaia (4):
      NFSD CB_OFFLOAD xdr
      NFSD OFFLOAD_STATUS xdr
      NFSD OFFLOAD_CANCEL xdr
      NFSD introduce async copy feature

Trond Myklebust (18):
      SUNRPC: Remove the server 'authtab_lock' and just use RCU
      SUNRPC: Add lockless lookup of the server's auth domain
      SUNRPC: Refactor sunrpc_cache_lookup
      SUNRPC: Allow cache lookups to use RCU protection rather than the r/w spinlock
      SUNRPC: Make server side AUTH_UNIX use lockless lookups
      knfsd: Allow lockless lookups of the exports
      SUNRPC: Lockless server RPCSEC_GSS context lookup
      knfsd: Lockless lookup of NFSv4 identities.
      NFS: Lockless DNS lookups
      NFS: Fix up a typo in nfs_dns_ent_put
      SUNRPC: Remove non-RCU protected lookup
      SUNRPC: Replace the cache_detail->hash_lock with a regular spinlock
      SUNRPC: Simplify TCP receive code
      knfsd: Remove dead code from nfsd_cache_lookup
      knfsd: Simplify NFS duplicate replay cache
      knfsd: Further simplify the cache lookup
      knfsd: Improve lookup performance in the duplicate reply cache using an rbtree
      nfsd: Fix an Oops in free_session()

YueHaibing (1):
      nfsd: remove set but not used variable 'dirp'

 Documentation/filesystems/nfs/rpc-cache.txt |   6 +-
 fs/lockd/host.c                             |   2 +-
 fs/nfs/dns_resolve.c                        |  15 +-
 fs/nfsd/cache.h                             |  20 +-
 fs/nfsd/export.c                            |  14 +-
 fs/nfsd/export.h                            |   2 +
 fs/nfsd/netns.h                             |   8 +
 fs/nfsd/nfs4callback.c                      |  98 ++++++++++
 fs/nfsd/nfs4idmap.c                         |  11 +-
 fs/nfsd/nfs4proc.c                          | 289 ++++++++++++++++++++++++++--
 fs/nfsd/nfs4state.c                         |  41 +++-
 fs/nfsd/nfs4xdr.c                           |  50 ++++-
 fs/nfsd/nfscache.c                          | 142 +++++++-------
 fs/nfsd/nfsctl.c                            |   1 +
 fs/nfsd/state.h                             |  10 +
 fs/nfsd/vfs.c                               |   5 +-
 fs/nfsd/xdr4.h                              |  28 +++
 fs/nfsd/xdr4cb.h                            |  10 +
 include/linux/sunrpc/cache.h                |  18 +-
 include/linux/sunrpc/svc_rdma.h             |  13 +-
 include/linux/sunrpc/svcauth.h              |   1 +
 net/sunrpc/auth_gss/svcauth_gss.c           |  41 +++-
 net/sunrpc/cache.c                          | 153 +++++++++------
 net/sunrpc/svc_xprt.c                       |   2 +-
 net/sunrpc/svcauth.c                        |  74 +++++--
 net/sunrpc/svcauth_unix.c                   |  24 ++-
 net/sunrpc/svcsock.c                        |  53 ++---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c  |  23 +--
 net/sunrpc/xprtrdma/svc_rdma_transport.c    |  10 +-
 29 files changed, 858 insertions(+), 306 deletions(-)
