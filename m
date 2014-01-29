Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42673 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751796AbaA2Syw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jan 2014 13:54:52 -0500
Date: Wed, 29 Jan 2014 13:54:49 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: please pull nfsd changes for 3.14
Message-ID: <20140129185449.GC30065@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 3.14:

git://linux-nfs.org/~bfields/linux.git for-3.14

	- Handle some loose ends from the vfs read delegation support.
	  (For example nfsd can stop breaking leases on its own in a
	  fewer places where it can now depend on the vfs to.)
	- Make life a little easier for NFSv4-only configurations
	  (thanks to Kinglong Mee).
	- Fix some gss-proxy problems (thanks Jeff Layton).

And miscellaneous bug fixes and cleanup.

Stephen Rothwell noted a merge conflict:

http://marc.info/?i=<20140129124238.6e1667abab08be8be2dafe01@canb.auug.org.au>

I'm assuming as usual you'll handle it and let me know if you need
anything from me.

--b.

----------------------------------------------------------------
Albert Fluegel (1):
      nfsd: don't return high mode bits

Andy Shevchenko (1):
      net/sunrpc/cache: simplify code by using hex_pack_byte()

Christoph Hellwig (1):
      nfsd: start documenting some XDR handling functions

J. Bruce Fields (12):
      nfsd4: update 4.1 nfsd status documentation
      nfsd4: break only delegations when appropriate
      nfsd4: better VERIFY comment
      minor svcauth_gss.c cleanup
      nfsd4: nfsd4_encode_fattr cleanup
      nfsd4: encode_rdattr_error cleanup
      nfsd4: simplify xdr encoding of nfsv4 names
      nfsd: fix encode_entryplus_baggage stack usage
      nfsd4: decrease nfsd4_encode_fattr stack usage
      nfsd4: minor nfs4_setlease cleanup
      nfsd4: delay setting current_fh in open
      nfsd4: fix delegation-unlink/rename race

Jeff Layton (4):
      nfsd: don't try to reuse an expired DRC entry off the list
      sunrpc: don't wait for write before allowing reads from use-gss-proxy file
      sunrpc: fix potential race between setting use_gss_proxy and the upcall rpc_clnt
      sunrpc: get rid of use_gssp_lock

Kinglong Mee (15):
      nfsd: calculate the missing length of bitmap in EXCHANGE_ID
      nfsd: get rid of unused function definition
      nfsd: clean up an xdr reserved space calculation
      nfsd: using nfsd4_encode_noop for encoding destroy_session/free_stateid
      nfsd: clean up unnecessary temporary variable in nfsd4_decode_fattr
      nfsd: get rid of unused macro definition
      Add missing recording of back channel attrs in nfsd4_session
      NFSD: fix a leak which can cause CREATE_SESSION failures
      NFSD: fix bad length checking for backchannel
      SUNRPC/NFSD: Support a new option for ignoring the result of svc_register
      NFSD: Don't start lockd when only NFSv4 is running
      NFSD: fix compile warning without CONFIG_NFSD_V3
      Define op_iattr for nfsd4_open instead using macro
      nfsd: get rid of unused function definition
      NFSD: Fix a memory leak in nfsd4_create_session

Luis Henriques (1):
      gss_krb5: use lcm from kernel lib

Ming Chen (1):
      nfsd: consider CLAIM_FH when handing out delegation

Stanislav Kholmanskikh (1):
      nfsd: revoking of suid/sgid bits after chown() in a consistent way

Weng Meiling (1):
      sunrpc: fix some typos

 Documentation/filesystems/nfs/nfs41-server.txt |   42 ++----
 fs/nfsd/acl.h                                  |    2 +-
 fs/nfsd/cache.h                                |    8 --
 fs/nfsd/idmap.h                                |    4 +-
 fs/nfsd/netns.h                                |    1 +
 fs/nfsd/nfs3xdr.c                              |   14 +-
 fs/nfsd/nfs4acl.c                              |   20 ++-
 fs/nfsd/nfs4idmap.c                            |   50 ++++---
 fs/nfsd/nfs4proc.c                             |   57 +++++---
 fs/nfsd/nfs4state.c                            |   40 ++++--
 fs/nfsd/nfs4xdr.c                              |  178 +++++++++---------------
 fs/nfsd/nfscache.c                             |   36 +----
 fs/nfsd/nfssvc.c                               |   30 +++-
 fs/nfsd/nfsxdr.c                               |    2 +-
 fs/nfsd/vfs.c                                  |   40 +-----
 fs/nfsd/vfs.h                                  |    2 -
 fs/nfsd/xdr3.h                                 |    3 +
 fs/nfsd/xdr4.h                                 |    4 +-
 include/linux/sunrpc/svc.h                     |    6 +-
 net/sunrpc/auth_gss/gss_krb5_keys.c            |   17 +--
 net/sunrpc/auth_gss/gss_rpc_upcall.c           |    2 -
 net/sunrpc/auth_gss/svcauth_gss.c              |   82 +++--------
 net/sunrpc/cache.c                             |    4 +-
 net/sunrpc/netns.h                             |    1 -
 net/sunrpc/svc.c                               |   25 ++--
 net/sunrpc/xprtsock.c                          |    7 +-
 26 files changed, 284 insertions(+), 393 deletions(-)
