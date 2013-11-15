Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53224 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053Ab3KOQSo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Nov 2013 11:18:44 -0500
Date: Fri, 15 Nov 2013 11:18:43 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: nfsd changes for 3.13
Message-ID: <20131115161843.GD3371@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 3.13 from

  git://linux-nfs.org/~bfields/linux.git nfsd-next

This includes miscellaneous bugfixes and cleanup and a performance fix
for write-heavy NFSv4 workloads.

(The most significant nfsd-relevant change this time is actually in the
delegation patches that went through Viro, fixing a long-standing bug
that can cause NFSv4 clients to miss updates made by non-nfs users of
the filesystem.  Those enable some followup nfsd patches which I have
queued locally, but those can wait till 3.14.)

--b.

----------------------------------------------------------------
Al Viro (1):
      nfsd: switch to %p[dD]

Anna Schumaker (2):
      NFSD: Combine decode operations for v4 and v4.1
      NFSD: Add support for NFS v4.2 operation checking

Benny Halevy (5):
      nfsd: nfs4_free_stid
      nfsd: nfs4_open_delegation needs to remove_stid rather than unhash_stid
      nfsd: remove_stid can be incorporated into nfs4_put_delegation
      nfsd: no need to unhash_stid before free
      nfsd4: need to destroy revoked delegations in destroy_client

Christoph Hellwig (2):
      nfsd: fix Kconfig syntax
      nfsd: export proper maximum file size to the client

J. Bruce Fields (12):
      svcrpc: fix gss-proxy NULL dereference in some error cases
      svcrpc: fix error-handling on badd gssproxy downcall
      svcrpc: handle some gssproxy encoding errors
      gss_krb5: document that we ignore sequence number
      nfsd: fh_update should error out in unexpected cases
      nfsd: return better errors to exportfs
      nfsd: -EINVAL on invalid anonuid/gid instead of silent failure
      nfsd4: nfsd_shutdown_net needs state lock
      nfsd4: fix discarded security labels on setattr
      Revert "nfsd: remove_stid can be incorporated into nfs4_put_delegation"
      sunrpc: comment typo fix
      nfsd4: improve write performance with better sendspace reservations

Jeff Layton (1):
      sunrpc: trim off EC bytes in GSSAPI v2 unwrap

Weng Meiling (1):
      svcrpc: remove an unnecessary assignment

 fs/nfsd/Kconfig                       |    2 +-
 fs/nfsd/export.c                      |   24 +++++-
 fs/nfsd/nfs4recover.c                 |   12 +--
 fs/nfsd/nfs4state.c                   |   41 +++++-----
 fs/nfsd/nfs4xdr.c                     |  132 ++++++++++++++++++---------------
 fs/nfsd/nfsfh.c                       |   36 ++++-----
 fs/nfsd/nfsfh.h                       |    4 +-
 fs/nfsd/vfs.c                         |    9 +--
 include/linux/nfs4.h                  |    3 +
 net/sunrpc/auth_gss/gss_krb5_unseal.c |    8 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   10 ++-
 net/sunrpc/auth_gss/gss_rpc_upcall.c  |    3 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.c     |   29 ++++----
 net/sunrpc/auth_gss/svcauth_gss.c     |    4 +-
 net/sunrpc/svc.c                      |    2 -
 net/sunrpc/xprtsock.c                 |    4 +-
 16 files changed, 179 insertions(+), 144 deletions(-)
