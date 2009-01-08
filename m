From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: please pull nfsd patches for 2.6.29
Date: Wed, 7 Jan 2009 20:06:02 -0500
Message-ID: <20090108010602.GC4276@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:57745 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491AbZAHBGI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2009 20:06:08 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes from the for-2.6.29 branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.29

I'm a little slow this time around.  I may still have a few smaller
bugfixes outstanding for a later pull.

This includes a fix for two post-2.6.29 regressions: one which would
cause any nfsd to deadlock on some common operations, due to fsync()
changes, and one that could fail to enforce file permissions, due to
cred changes.

Trond also investigated some long-standing problems with socket shutdown
on the server, fixed by patches from Trond and Tom Tucker (and thanks to
Ian Campbell and others for bug reporting and testing).

Jeff Layton fixed a dumb limit on the number of lockd sockets, allowing
us to scale more easily to more clients.

The bulk by patches is a series of patches (mostly smaller cleanups)
from Chuck preparing for ipv6 support, which is close to done and should
be in 2.6.30, and the bulk by lines is probably due to Chuck's
documentation of some userland interfaces in fs/nfsd/nfsctl.c.

Thanks to everyone!

--b.


Benny Halevy (4):
      nfsd: dprint each op status in nfsd4_proc_compound
      nfsd: git rid of nfs4_cb_null_ops declaration
      nfsd: last_byte_offset
      nfsd: get rid of NFSD_VERSION

Chuck Lever (47):
      NLM: Use modern style for pointer fields in nlm_host
      NLM: Remove address eye-catcher buffers from nlm_host
      NLM: Remove AF_UNSPEC arm in nlm_display_address()
      NLM: Support IPv6 scope IDs in nlm_display_address()
      NLM: Add helper to handle IPv4 addresses
      NSM: Use C99 structure initializer to initialize nsm_args
      NSM: convert printk(KERN_DEBUG) to a dprintk()
      NSM: Use modern style for sm_name field in nsm_handle
      NSM: Support IPv6 version of mon_name
      NSM: Use sm_name instead of h_name in nsm_monitor() and nsm_unmonitor()
      NLM: Remove redundant printk() in nlmclnt_lock()
      NSM: Remove BUG_ON() in nsm_monitor()
      NSM: Make sure to return an error if the SM_MON call result is not zero
      NLM: Move the public declaration of nsm_monitor() to lockd.h
      NSM: Release nsmhandle in nlm_destroy_host
      NLM: Move the public declaration of nsm_unmonitor() to lockd.h
      NSM: Check result of SM_UNMON upcall
      NSM: Move NSM-related XDR data structures to lockd's xdr.h
      NSM: Move NSM program and procedure numbers to fs/lockd/mon.c
      NSM: move to xdr_stream-based XDR encoders and decoders
      NSM: Move nsm_find() to fs/lockd/mon.c
      NSM: Add dprintk() calls in nsm_find and nsm_release
      NSM: Remove NULL pointer check from nsm_find()
      NSM: Remove !nsm check from nsm_release()
      NSM: Generate NSMPROC_MON's "priv" argument when nsm_handle is created
      NSM: Encode the new "priv" cookie for NSMPROC_MON requests
      NLM: Change nlm_host_rebooted() to take a single nlm_reboot argument
      NLM: Decode "priv" argument of NLMPROC_SM_NOTIFY as an opaque
      NSM: Add nsm_lookup() function
      NLM: Call nsm_reboot_lookup() instead of nsm_find()
      NLM: Remove "create" argument from nsm_find()
      NSM: Refactor nsm_handle creation into a helper function
      NSM: More clean up of nsm_get_handle()
      NSM: Replace IP address as our nlm_reboot lookup key
      NSM: Remove include/linux/lockd/sm_inter.h
      NSM: Move nsm_addr() to fs/lockd/mon.c
      NSM: Move nsm_use_hostnames to mon.c
      NSM: Move nsm_create()
      NLM: nlm_privileged_requester() doesn't recognize mapped loopback address
      NLM: Rewrite IPv4 privileged requester's check
      lockd: Enable NLM use of AF_INET6
      NFSD: clean up failover sysctl function naming
      NFSD: Fix a handful of coding style issues in write_filehandle()
      NFSD: Replace open-coded integer with macro
      NFSD: Add documenting comments for nfsctl interface
      NLM: Refactor make_socks() function
      NLM: Clean up flow of control in make_socks() function

David Howells (1):
      CRED: Fix NFSD regression

Dean Hildebrand (1):
      nfsd: add etoosmall to nfserrno

J. Bruce Fields (4):
      nfsd: update fh_verify description
      nfsd: document new filehandle fsid types
      nfsd: Ensure nfsv4 calls the underlying filesystem on LOCKT
      nfsd: fix double-locks of directory mutex

Jeff Layton (2):
      sunrpc: add sv_maxconn field to svc_serv (try #3)
      lockd: set svc_serv->sv_maxconn to a more reasonable value (try #3)

Krishna Kumar (2):
      nfsd: Minor cleanup of find_stateid
      nfsd: Fix leaked memory in nfs4_make_rec_clidname

Marc Eshel (1):
      nfsd: delete wrong file comment from nfsd/nfs4xdr.c

Steve Dickson (1):
      NFSD: FIDs need to take precedence over UUIDs

Tom Tucker (2):
      svc: Move kfree of deferral record to common code
      svc: Clean up deferred requests on transport destruction

Trond Myklebust (2):
      SUNRPC: Ensure the server closes sockets in a timely fashion
      SUNRPC: The sunrpc server code should not be used by out-of-tree modules

 fs/lockd/clntproc.c            |    7 +-
 fs/lockd/host.c                |  170 ++-----------
 fs/lockd/mon.c                 |  569 ++++++++++++++++++++++++++++++----------
 fs/lockd/svc.c                 |   72 ++++--
 fs/lockd/svc4proc.c            |   13 +-
 fs/lockd/svcproc.c             |   13 +-
 fs/lockd/svcsubs.c             |    1 -
 fs/lockd/xdr.c                 |    5 +-
 fs/lockd/xdr4.c                |    5 +-
 fs/nfsd/auth.c                 |    4 +-
 fs/nfsd/nfs4callback.c         |    3 -
 fs/nfsd/nfs4proc.c             |    5 +
 fs/nfsd/nfs4recover.c          |    2 +-
 fs/nfsd/nfs4state.c            |   79 ++++--
 fs/nfsd/nfs4xdr.c              |    2 -
 fs/nfsd/nfsctl.c               |  479 +++++++++++++++++++++++++++++++--
 fs/nfsd/nfsfh.c                |   36 ++-
 fs/nfsd/nfsproc.c              |    1 +
 fs/nfsd/vfs.c                  |   34 +++-
 include/linux/lockd/lockd.h    |   68 +++--
 include/linux/lockd/sm_inter.h |   48 ----
 include/linux/lockd/xdr.h      |   15 +-
 include/linux/nfs4.h           |    2 +
 include/linux/nfsd/nfsd.h      |    1 -
 include/linux/nfsd/nfsfh.h     |    4 +
 include/linux/sunrpc/svc.h     |    5 +-
 net/sunrpc/cache.c             |   20 +-
 net/sunrpc/stats.c             |    6 +-
 net/sunrpc/svc.c               |   14 +-
 net/sunrpc/svc_xprt.c          |   58 +++--
 net/sunrpc/svcauth.c           |   14 +-
 net/sunrpc/svcauth_unix.c      |   12 +-
 net/sunrpc/svcsock.c           |   30 ++-
 33 files changed, 1225 insertions(+), 572 deletions(-)
 delete mode 100644 include/linux/lockd/sm_inter.h
