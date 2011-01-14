Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50937 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774Ab1ANUfb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Jan 2011 15:35:31 -0500
Date: Fri, 14 Jan 2011 15:35:29 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd for 2.6.38
Message-ID: <20110114203529.GB16942@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Please pull nfsd development for 2.6.38 from:

  git://linux-nfs.org/~bfields/linux.git for-2.6.38

This includes a first implementation of session trunking support and
secinfo_no_name support, both mandatory features for NFSv4.1.  My list
of issues that I believe we need fixed before server-side 4.1 can be
considered minimally correct is at

  http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues

I want to see that list done before we start merging optional 4.1
features such as pNFS.  At my current rate I'm not sure when we'll get
there--not soon.

Also included is a stopgap measure to fix a longstanding failure to
revoke delegations in all the cases we should.  It still leaves some
races (and doesn't deal with local or Samba conflicts), so I hope to
have a more complete solution ready for 2.6.39.

And some other miscellaneous cleanup and bugfixing.  Thanks especially
to Mi Jinlong at Fujitsu, who has been writing tests and catching bugs
in the new 4.1 code.

--b.


Dan Carpenter (1):
      nfsd: fix NULL dereference in setattr()

J. Bruce Fields (52):
      svcrpc: don't set then immediately clear XPT_DEFERRED
      nfsd4: centralize more calls to svc_xprt_received
      svcrpc: simplify svc_close_all
      svcrpc: svc_close_xprt comment
      svcrpc: fix wspace-checking race
      nfsd4: return serverfault on request for ssv
      Merge commit 'v2.6.37-rc6' into for-2.6.38
      nfsd4: replace unintuitive match_clientid_establishment
      nfsd4: fix mixed 4.0/4.1 handling, 4.1 reboot
      nfsd: fix offset printk's in nfsd3 read/write
      nfsd4: 4.1 SECINFO should consume filehandle
      nfsd4: move guts of nfsd4_lookupp into helper
      nfsd4: implement secinfo_no_name
      svcrpc: modifying valid sunrpc cache entries is racy
      SUNRPC: Remove more code when NFSD_DEPRECATED is not configured
      nfsd: don't drop requests on -ENOMEM
      svcrpc: avoid double reply caused by deferral race
      svcrpc: simpler request dropping
      nfsd: stop translating EAGAIN to nfserr_dropit
      nfsd: remove some unnecessary dropit handling
      svcrpc: take lock on turning entry NEGATIVE in cache_check
      svcrpc: ensure cache_check caller sees updated entry
      nfsd4: eliminate lease delete callback
      nfsd4: use a single struct file for delegations
      locks: eliminate fl_mylease callback
      locks: minor setlease cleanup
      nfsd4: name->id mapping should fail with BADOWNER not BADNAME
      nfsd4: move idmap and acl header files into fs/nfsd
      nfsd4: remove outdated pathname-comments
      nfsd4: return nfs errno from name_to_id functions
      Documentation: don't remove lock manager fl_release_private
      Merge commit 'v2.6.37' into for-2.6.38-incoming
      Documentation: fl_mylease no longer exists
      nfsd4: modify session list under cl_lock
      nfsd4: support BIND_CONN_TO_SESSION
      nfsd4: allow backchannel recovery
      rpc: move sk_bc_xprt to svc_xprt
      rpc: keep backchannel xprt as long as server connection
      rpc: allow xprt_class->setup to return a preexisting xprt
      nfsd4: keep finer-grained callback status
      nfsd4: set sequence flag when backchannel is down
      nfsd4: re-probe callback on connection loss
      nfsd4: make sure sequence flags are set after destroy_session
      nfsd4: add helper function to run callbacks
      nfsd4: give out delegations more quickly in 4.1 case
      nfsd4: simplify nfsd4_cb_prepare
      nfsd4: allow restarting callbacks
      nfsd4: initialize cb_per_client
      nfsd: don't support msnfs export option
      nfsd4: break lease on nfsd setattr
      nfsd: break lease on unlink, link, and rename
      nfsd4: fix callback restarting

Joe Perches (1):
      net/sunrpc/auth_gss/gss_krb5_crypto.c: Use normal negative error value return

Kirill A. Shutemov (1):
      nfsd: declare several functions of nfs4callback as static

Mi Jinlong (4):
      NFSv4.1: Make sure nfsd can decode SP4_SSV correctly at exchange_id
      NFS4.1: server gets drc mem fail should reply error at create_session
      NFS4.1: Fix bug server don't reply the right fore_channel to client at create_session
      nfsd4: fix oops on secinfo_no_name result encoding

NeilBrown (2):
      sunrpc: remove xpt_pool
      sunrpc: svc_sock_names should hold ref to socket being closed.

Shan Wei (1):
      net: sunrpc: kill unused macros

Takuma Umeya (1):
      nfs4: set source address when callback is generated

bookjovi@gmail.com (1):
      nfs: add missed CONFIG_NFSD_DEPRECATED

 Documentation/filesystems/Locking             |    2 -
 fs/locks.c                                    |    8 +-
 include/linux/nfs4_acl.h => fs/nfsd/acl.h     |    2 -
 fs/nfsd/export.c                              |    4 -
 include/linux/nfsd_idmap.h => fs/nfsd/idmap.h |    6 +-
 fs/nfsd/nfs3proc.c                            |    8 +-
 fs/nfsd/nfs4acl.c                             |    2 +-
 fs/nfsd/nfs4callback.c                        |  151 ++++++++++------
 fs/nfsd/nfs4idmap.c                           |   15 +-
 fs/nfsd/nfs4proc.c                            |   59 +++++--
 fs/nfsd/nfs4recover.c                         |    1 -
 fs/nfsd/nfs4state.c                           |  243 +++++++++++++++----------
 fs/nfsd/nfs4xdr.c                             |  115 +++++++++---
 fs/nfsd/nfsctl.c                              |    4 +-
 fs/nfsd/nfsd.h                                |    1 +
 fs/nfsd/nfsproc.c                             |    6 +-
 fs/nfsd/nfssvc.c                              |    2 +-
 fs/nfsd/state.h                               |   16 ++-
 fs/nfsd/vfs.c                                 |   86 +++------
 fs/nfsd/xdr4.h                                |    9 +-
 include/linux/fs.h                            |    1 -
 include/linux/nfs4.h                          |    6 +
 include/linux/nfsd/export.h                   |    2 +-
 include/linux/sunrpc/cache.h                  |    3 +
 include/linux/sunrpc/svc.h                    |    1 +
 include/linux/sunrpc/svc_xprt.h               |    2 +-
 include/linux/sunrpc/svcsock.h                |    1 -
 include/linux/sunrpc/xprt.h                   |    1 +
 net/sunrpc/auth_gss/gss_krb5_crypto.c         |    2 +-
 net/sunrpc/auth_gss/svcauth_gss.c             |    2 -
 net/sunrpc/cache.c                            |   54 ++++--
 net/sunrpc/svc.c                              |    3 +-
 net/sunrpc/svc_xprt.c                         |   97 +++++-----
 net/sunrpc/svcauth.c                          |    1 -
 net/sunrpc/svcauth_unix.c                     |   17 ++-
 net/sunrpc/svcsock.c                          |   20 ++-
 net/sunrpc/xprt.c                             |    5 +-
 net/sunrpc/xprtsock.c                         |   34 +++-
 38 files changed, 608 insertions(+), 384 deletions(-)
 rename include/linux/nfs4_acl.h => fs/nfsd/acl.h (98%)
 rename include/linux/nfsd_idmap.h => fs/nfsd/idmap.h (92%)
