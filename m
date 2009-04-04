Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Sat, 4 Apr 2009 12:08:51 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Subject: nfsd pull request for 2.6.30
Message-ID: <20090404160851.GC495@fieldses.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
        linux-kernel@vger.kernel.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd-releated changes for 2.6.30 from the for-2.6.30 branch
at:

	git://linux-nfs.org/~bfields/linux.git for-2.6.30

This includes the first 4.1 code.  It still needs work, but it's been
developed out of tree for a while, and it's high time that we move the
development upstream.  It is off by default and shouldn't impact exiting
v2/v3/v4.0 behavior.

Also included is some performance work (including new nfsd performance
counters and a tcp fix for high bandwidth-delay-product networks), and
the usual miscellaneous bugfixes and cleanup.

Thanks to everyone for their work on all of this!

And apologies for getting this in late.  Most of the delay was trying to
agree on a reasonable subset of the 4.1 patches to submit.  I hope that
starting to focus the 4.1 development more on upstream will make the
process go a little smoother in future releases.

--b.

Alexandros Batsakis (1):
      nfsd: lock state around put client and delegation in nfsd4_cb_recall

Andy Adamson (21):
      nfsd: embed nfsd4_current_state in nfsd4_compoundres
      nfsd: don't use the deferral service, return NFS4ERR_DELAY
      nfsd41: sessions basic data types
      nfsd41: xdr infrastructure
      nfsd41: proc stubs
      nfsd41: exchange_id operation
      nfsd41: match clientid establishment method
      nfsd41: enforce NFS4ERR_SEQUENCE_POS operation order rules for minorversion != 0 only.
      nfsd41: DRC save, restore, and clear functions
      nfsd41: hard page limit for DRC
      nfsd41: nfsd DRC logic
      nfsd41: clear DRC cache on free_session
      nfsd41: create_session operation
      nfsd41: Add a create session replay cache
      nfsd41: non-page DRC for solo sequence responses
      nfsd41: stateid handling
      nfsd41: check encode size for sessions maxresponse cached
      nfsd41: clientid handling
      nfsd41: access_valid
      nfsd41: add OPEN4_SHARE_ACCESS_WANT nfs4_stateid bmap
      nfsd41: support for 3-word long attribute bitmask

Benny Halevy (12):
      NFSD: return nfsv4 error code nfserr_notsupp rather than nfsv[23]'s nfserr_opnotsupp
      nfsd: remove nfsd4_ops array size
      nfs41: common protocol definitions
      nfsd41: sequence operation
      nfsd41: destroy_session operation
      nfsd: pass nfsd4_compound_state* to nfs4_preprocess_{state,seq}id_op
      nfsd41: control nfsv4.1 svc via /proc/fs/nfsd/versions
      nfsd41: pass writable attrs mask to nfsd4_decode_fattr
      nfsd: dynamically skip encoded fattr bitmap in _nfsd4_verify
      nfsd41: SUPPATTR_EXCLCREAT attribute
      nfsd41: CREATE_EXCLUSIVE4_1
      nfsd41: Documentation/filesystems/nfs41-server.txt

Chuck Lever (1):
      SUNRPC: Clean up static inline functions in svc_xprt.h

David Shaw (1):
      Short write in nfsd becomes a full write to the client

Greg Banks (5):
      knfsd: remove the nfsd thread busy histogram
      knfsd: avoid overloading the CPU scheduler with enormous load averages
      knfsd: add file to export stats about nfsd pools
      Document /proc/fs/nfsd/pool_stats
      Fix a build warning about leaking CONFIG_NFSD to userspace.

Harvey Harrison (1):
      nfs: replace uses of __constant_{endian}

J. Bruce Fields (25):
      nfsd4: split lockstateid/openstateid release logic
      nfsd4: remove a forward declaration
      nfsd4: split open/lockowner release code
      nfsd: clarify exclusive create bitmask result.
      nfsd4: fix misplaced comment
      nfsd4: use helper for copying filehandles for replay
      nfsd4: use helper for copying delegation filehandle
      nfsd4: trivial preprocess_stateid_op cleanup
      nfsd4: move check_stateid_generation check
      nfsd4: remove redundant "if" in nfs4_preprocess_stateid_op
      nfsd4: remove unneeded local variable
      nfsd4: remove some dprintk's
      nfsd4: add a helper function to decide if stateid is delegation
      nfsd4: separate delegreturn case from preprocess_stateid_op
      nfsd4: fail when delegreturn gets a non-delegation stateid
      nfsd4: remove unused CHECK_FH flag
      nfsd4: rename io_during_grace_disallowed
      nfsd4: put_nfs4_client does not require state lock
      nfsd4: remove use of mutex for file_hashtable
      nfsd4: fix do_probe_callback errors
      nfsd4: move rpc_client setup to a separate function
      nfsd4: support putpubfh operation
      nfsd4: don't do lookup within readdir in recovery code
      nfsd4: remove redundant check from nfsd4_open
      nfsd4: don't check ip address in setclientid

Manish Katiyar (1):
      nfsd : Define NFSD only when FILE_LOCKING is enabled

Marc Eshel (5):
      nfsd41: define nfs41 error codes
      nfsd41: introduce nfs4_client cl_sessions list
      nfsd41: release_session when client is expired
      nfsd41: sessionid hashing
      nfsd41: provide support for minor version 1 at rpc level

Miklos Szeredi (1):
      lockd: clean up blocking lock cases of nlsmvc_lock()

Olga Kornievskaia (1):
      svcrpc: take advantage of tcp autotuning

Qinghuang Feng (1):
      NFSD: cleanup for nfs3proc.c

Sachin S. Prabhu (1):
      Inconsistent setattr behaviour

ideawu (1):
      sunrpc/svc.c: Remove unused line 'rqstp->rq_server = serv;' in svc_process

wengang wang (1):
      nfsd(v2/v3): fix the failure of creation from HPUX client

 Documentation/filesystems/knfsd-stats.txt  |  159 ++++
 Documentation/filesystems/nfs41-server.txt |  161 ++++
 fs/lockd/svclock.c                         |   13 +-
 fs/nfsd/Kconfig                            |    1 +
 fs/nfsd/nfs3proc.c                         |   10 +-
 fs/nfsd/nfs4callback.c                     |   47 +-
 fs/nfsd/nfs4proc.c                         |  246 ++++--
 fs/nfsd/nfs4recover.c                      |   74 +-
 fs/nfsd/nfs4state.c                        | 1196 +++++++++++++++++++++++-----
 fs/nfsd/nfs4xdr.c                          |  633 ++++++++++++++-
 fs/nfsd/nfsctl.c                           |   38 +-
 fs/nfsd/nfsproc.c                          |    3 +-
 fs/nfsd/nfssvc.c                           |   86 ++-
 fs/nfsd/vfs.c                              |   37 +-
 include/linux/lockd/xdr.h                  |   12 +-
 include/linux/lockd/xdr4.h                 |   10 +-
 include/linux/nfs.h                        |    1 -
 include/linux/nfs4.h                       |  138 ++++-
 include/linux/nfsd/cache.h                 |    1 +
 include/linux/nfsd/nfsd.h                  |  228 ++++--
 include/linux/nfsd/nfsfh.h                 |    7 +
 include/linux/nfsd/state.h                 |   84 ++-
 include/linux/nfsd/stats.h                 |    9 +-
 include/linux/nfsd/xdr4.h                  |  129 +++-
 include/linux/sunrpc/svc.h                 |   16 +
 include/linux/sunrpc/svc_xprt.h            |   46 +-
 include/linux/sunrpc/xdr.h                 |   42 +-
 net/sunrpc/svc.c                           |    3 +-
 net/sunrpc/svc_xprt.c                      |  127 +++-
 net/sunrpc/svcsock.c                       |   35 +-
 30 files changed, 3017 insertions(+), 575 deletions(-)
 create mode 100644 Documentation/filesystems/knfsd-stats.txt
 create mode 100644 Documentation/filesystems/nfs41-server.txt
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
