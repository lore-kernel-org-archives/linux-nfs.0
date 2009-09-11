From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull NFS client changes for 2.6.32
Date: Fri, 11 Sep 2009 15:02:22 -0400
Message-ID: <1252695742.1683.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751760AbZIKTDX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2009 15:03:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 Documentation/filesystems/nfs.txt   |   98 +++
 Documentation/kernel-parameters.txt |   29 +
 fs/lockd/host.c                     |   14 +-
 fs/lockd/mon.c                      |   44 +-
 fs/nfs/Makefile                     |    3 +-
 fs/nfs/cache_lib.c                  |  140 ++++
 fs/nfs/cache_lib.h                  |   27 +
 fs/nfs/callback.c                   |   26 +-
 fs/nfs/client.c                     |   15 +-
 fs/nfs/direct.c                     |    3 -
 fs/nfs/dns_resolve.c                |  335 ++++++++
 fs/nfs/dns_resolve.h                |   14 +
 fs/nfs/file.c                       |   49 ++-
 fs/nfs/idmap.c                      |    6 +-
 fs/nfs/inode.c                      |  100 ++-
 fs/nfs/internal.h                   |   39 +-
 fs/nfs/mount_clnt.c                 |   83 ++-
 fs/nfs/nfs3proc.c                   |    1 -
 fs/nfs/nfs4namespace.c              |   24 +-
 fs/nfs/nfs4proc.c                   |   40 +-
 fs/nfs/nfs4xdr.c                    | 1460 +++++++++++++++++++++--------------
 fs/nfs/super.c                      |  451 ++++++------
 fs/nfs/write.c                      |   91 ++-
 fs/nfsd/export.c                    |   14 +-
 fs/nfsd/nfs4idmap.c                 |   20 +-
 fs/nfsd/nfsctl.c                    |   21 +-
 include/linux/nfs4.h                |    1 +
 include/linux/nfs_fs_sb.h           |    9 +
 include/linux/sunrpc/cache.h        |   40 +-
 include/linux/sunrpc/clnt.h         |   43 +-
 include/linux/sunrpc/msg_prot.h     |   17 +-
 include/linux/sunrpc/rpc_pipe_fs.h  |   20 +-
 include/linux/sunrpc/xdr.h          |   10 +-
 include/linux/sunrpc/xprt.h         |    2 -
 net/sunrpc/Makefile                 |    2 +-
 net/sunrpc/addr.c                   |  364 +++++++++
 net/sunrpc/auth_gss/auth_gss.c      |   12 +-
 net/sunrpc/auth_gss/svcauth_gss.c   |    7 +-
 net/sunrpc/cache.c                  |  622 +++++++++++----
 net/sunrpc/clnt.c                   |   60 +-
 net/sunrpc/rpc_pipe.c               |  685 ++++++++++-------
 net/sunrpc/rpcb_clnt.c              |  420 +++++++----
 net/sunrpc/sunrpc_syms.c            |    2 +-
 net/sunrpc/svcauth_unix.c           |   14 +-
 net/sunrpc/timer.c                  |   45 +-
 net/sunrpc/xdr.c                    |   12 +-
 net/sunrpc/xprtrdma/transport.c     |   48 +-
 net/sunrpc/xprtsock.c               |  287 ++++----
 48 files changed, 4064 insertions(+), 1805 deletions(-)

commit 2ecda72b49a0849ce41e7fa1fa974a245b9119f8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Sep 8 19:50:07 2009 -0400

    NFSv4: Disallow 'mount -t nfs4 -overs=2' and 'mount -t nfs4 -overs=3'
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 764302ccb88dd0df062eccd507b6c6de24f1c560
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Sep 8 19:50:03 2009 -0400

    NFS: Allow the "nfs" file system type to support NFSv4
    
    When mounting an "nfs" type file system, recognize "v4," "vers=4," or
    "nfsvers=4" mount options, and convert the file system to "nfs4" under
    the covers.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    [trondmy: fixed up binary mount code so it sets the 'version' field too]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a6fe23be90aa78783523a25330e09bfaa43a1581
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Sep 8 19:50:00 2009 -0400

    NFS: Move details of nfs4_get_sb() to a helper
    
    Clean up: Refactor nfs4_get_sb() to allow its guts to be invoked by
    nfs_get_sb().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7630c852e19c7fffb85b50d98eeb5516fec7c088
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Sep 8 19:49:57 2009 -0400

    NFS: Refactor NFSv4 text-based mount option validation
    
    Clean up: Refactor the part of nfs4_validate_mount_options() that
    handles text-based options, so we can call it from the NFSv2/v3
    option validation function.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4cfd74fc99a41fdc161f243e1c16199656d33ab1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Sep 8 19:49:47 2009 -0400

    NFS: Mount option parser should detect missing "port="
    
    The meaning of not specifying the "port=" mount option is different
    for "-t nfs" and "-t nfs4" mounts.  The default port value for
    NFSv2/v3 mounts is 0, but the default for NFSv4 mounts is 2049.
    
    To support "-t nfs -o vers=4", the mount option parser must detect
    when "port=" is missing so that the correct default port value can be
    set depending on which NFS version is requested.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dbab8360ed8abca38121109feab47c4bea895994
Author: Harshula Jayasuriya <harshula@redhat.com>
Date:   Tue Sep 8 19:49:33 2009 -0400

    NFS: out of date comment regarding O_EXCL above nfs3_proc_create()
    
    Hi Trond,
    
    Recently we were observing the behaviour difference between a 2.4.x and
    2.6.x kernel with respect to O_EXCL. A comment from 2.4.x era, "For now,
    we don't implement O_EXCL." seems inaccurate in TOT.
    
    If so, here's a patch to remove the comment.
    
    This patch is against:
    git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6
    
    Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5eecfde615894dc1c2e3f85b515a96ae2e408fb5
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Aug 21 17:50:30 2009 -0400

    NFS: Handle a zero-length auth flavor list
    
    Some releases of Linux rpc.mountd (nfs-utils 1.1.4 and later) return an
    empty auth flavor list if no sec= was specified for the export.  This is
    notably broken server behavior.
    
    The new auth flavor list checking added in a recent commit rejects this
    case.  The OpenSolaris client does too.
    
    The broken mountd implementation is already widely deployed.  To avoid
    a behavioral regression, the kernel's mount client skips flavor checking
    (ie reverts to the pre-2.6.32 behavior) if mountd returns an empty
    flavor list.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 405d8f8b1d936414da2093d4149ff790ff3f84a5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Aug 21 08:17:56 2009 -0400

    SUNRPC: Ensure that sunrpc gets initialised before nfs, lockd, etc...
    
    We can oops if rpc_pipefs isn't properly initialised before we start to set
    up objects that depend upon it.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4dceef96756b667360741712a8e37490f8458516
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Aug 20 17:08:39 2009 -0400

    nfs: fix compile error in rpc_pipefs.h
    
    This include is needed for the definition of delayed_work.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e1af88a1ad8f4dea3a2d6c5637d94a3fc3c62994
Author: Jan Kara <jack@suse.cz>
Date:   Wed Aug 19 18:04:43 2009 +0200

    nfs: Remove reference to generic_osync_inode from a comment
    
    generic_file_direct_write() no longer calls generic_osync_inode() so remove the
    comment.
    
    CC: linux-nfs@vger.kernel.org
    CC: Neil Brown <neilb@suse.de>
    CC: "J. Bruce Fields" <bfields@fieldses.org>
    Signed-off-by: Jan Kara <jack@suse.cz>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f7e86ab92f2198d30828a1a327ad2085e4a7ff7d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 19 18:13:00 2009 -0400

    SUNRPC: cache must take a reference to the cache detail's module on open()
    
    Otherwise we Oops if the module containing the cache detail is removed
    before all cache readers have closed the file.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7d7ea882898f23989209d0359691b356f73240dc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 19 18:12:34 2009 -0400

    NFS: Use the DNS resolver in the mount code.
    
    In the referral code, use it to look up the new server's ip address if the
    fs_locations attribute contains a hostname.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e571cbf1a4f8d8b6cfd4898df718dae84c75a8e1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 19 18:12:27 2009 -0400

    NFS: Add a dns resolver for use with NFSv4 referrals and migration
    
    The NFSv4 and NFSv4.1 protocols both allow for the redirection of a client
    from one server to another in order to support filesystem migration and
    replication. For full protocol support, we need to add the ability to
    convert a DNS host name into an IP address that we can feed to the RPC
    client.
    
    We'll reuse the sunrpc cache, now that it has been converted to work with
    rpc_pipefs.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 96c61cbd0f30496bfa57ed80f7131a57aea3e4de
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 19 18:12:21 2009 -0400

    SUNRPC: Fix a typo in cache_pipefs_files
    
    We want the channel to be a regular file, so that we don't need to supply
    rpc_pipe_ops.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cccddf4f5580131c9b963900e1d3400655e633cc
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:20:19 2009 +0300

    nfs: nfs4xdr: optimize low level decoding
    
    do not increment decoding ptr if not needed.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c0eae66ece40bdb8cd88c5106834b71a1c9f421c
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:20:14 2009 +0300

    nfs: nfs4xdr: get rid of READ_BUF
    
    Use xdr_inline_decode instead.
    Open code debug printout and error return.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2460ba57c49c36dfef0b62c929461de09240fe17
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:20:10 2009 +0300

    nfs: nfs4xdr: simplify decode_exchange_id by reusing decode_opaque_inline
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 99398d0655ada44ae464a1c93d13cd438a306ecd
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:20:05 2009 +0300

    nfs: nfs4xdr: get rid of COPYMEM
    
    Just directly call memcpy.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e78291e4e07520348b0634095cf19ed3bc868965
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:20:00 2009 +0300

    nfs: nfs4xdr: introduce decode_sessionid helper
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit db942bbd09563e169cc5d9004c32c1de33220fd1
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:19:56 2009 +0300

    nfs: nfs4xdr: introduce decode_verifier helper
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Trond: Fixed up an 'uninitialised variable' issue in decode_readdir]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 07d30434cfe2f1a1553143c6b20f1fe68d2ef80a
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:19:52 2009 +0300

    nfs: nfs4xdr: introduce decode_opaque_fixed and decode_stateid helpers
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 686841b3cc3a71918b45ed148be7a01a4f10e3f8
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:19:48 2009 +0300

    nfs: nfs4xdr: introduce print_overflow_msg
    
    Part fo the nfs4xdr cleanup.  READ_BUF will go away.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c816fd3406462702dee2e3859e70132c3aab7c10
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:19:44 2009 +0300

    nfs: nfs4xdr: get rid of READTIME
    
    It has no users.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3ceb4dbb993fdab6a6fafc69db36686278871134
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:19:41 2009 +0300

    nfs: nfs4xdr: get rid of READ64
    
    s/READ64\(\*(.*)\)/p = xdr_decode_hyper(p, \1)/
    s/READ64\((.*)\)/p = xdr_decode_hyper(p, &\1)/
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6f723f7710024bb151ca8c5277ce8c71beec4db8
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:19:37 2009 +0300

    nfs: nfs4xdr: get rid of READ32
    
    s/READ32\((.*)\)/\1 = be32_to_cpup(p++)/
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 811652bd6edd66dd35bf9caacdfe96d19f75a47e
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:19:34 2009 +0300

    nfs: nfs4xdr: merge xdr_encode_int+xdr_encode_opaque_fixed into xdr_encode_opaque
    
    use encode_string where appropriate.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 345585132a204859fbb7d8b662e9b6e5b563c6dc
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:19:30 2009 +0300

    nfs: nfs4xdr: optimize low level encoding
    
    do not increment encoding ptr if not needed.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 13c65ce90006badccd5663e558e3c85869ae5ce6
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:19:25 2009 +0300

    nfs: nfs4xdr: change RESERVE_SPACE macro into a static helper
    
    In order to open code and expose the result pointer assignment.
    
    Alternatively, we can open code the call to xdr_reserve_space
    and do the BUG_ON an the error case at the call site.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2220f13a8b90d2259f3094cb54cf4de67d8eee2d
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:19:18 2009 +0300

    nfs: nfs4xdr: encode_compound_hdr does not have to round up reserved bytes
    
    This is already done by xdr_reserve_space and since encode_compound_hdr
    is adding a byte count to "12" which is already word aligned, the xdr
    level rounding will work just as well.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 42edd698125b76a38bd9999015202db036dfbc76
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:19:13 2009 +0300

    nfs: nfs4xdr: optimize RESERVE_SPACE in encode_create_session and encode_sequence
    
    Coalesce multilpe constant RESERVE_SPACEs into one
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 93f0cf25944695e1229fe90a2897af0211fbd425
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:19:06 2009 +0300

    nfs: nfs4xdr: get rid of WRITEMEM
    
    s/WRITEMEM(/p = xdr_encode_opaque_fixed(p, /
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b95be5a976848febff82edb21d5b4351b3997bf6
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:19:01 2009 +0300

    nfs: nfs4xdr: get rid of WRITE64
    
    s/WRITE64/p = xdr_encode_hyper(p, /
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e75bc1c89e0c7dda0b140408ddee2ffaef7ba6d4
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:18:54 2009 +0300

    nfs: nfs4xdr: get rid of WRITE32
    
    s/WRITE32/*p++ = cpu_to_be32/
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 98866b5abe1513cdacc011874ca045d40002eccd
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:18:49 2009 +0300

    sunrpc: ntoh -> be*_to_cpu
    
    ntohl is already defined as be32_to_cpu.
    be64_to_cpu has architecture specific optimized implementations.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9f162d2a810b4db48f7b8d7e734d0932c81ec2a1
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri Aug 14 17:18:44 2009 +0300

    sunrpc: hton -> cpu_to_be*
    
    htonl is already defined as cpu_to_be32.
    cpu_to_be64 has architecture specific optimized implementations.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e576e05a73bc1a00cdf56630942dbada1bf280a1
Author: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Date:   Mon Aug 10 08:54:16 2009 -0400

    nfs: remove superfluous BUG_ON()s
    Subject: [PATCH] nfs: remove superfluous BUG_ON()s
    
    Remove duplicated BUG_ON()s from nfs[4]_create_server()
    (we make the same checks earlier in both functions).
    
    This takes care of the following entries from Dan's list:
    
    fs/nfs/client.c +1078 nfs_create_server(47) warning: variable derefenced before check 'server->nfs_client'
    fs/nfs/client.c +1079 nfs_create_server(48) warning: variable derefenced before check 'server->nfs_client->rpc_ops'
    fs/nfs/client.c +1363 nfs4_create_server(43) warning: variable derefenced before check 'server->nfs_client'
    fs/nfs/client.c +1364 nfs4_create_server(44) warning: variable derefenced before check 'server->nfs_
    
    Reported-by: Dan Carpenter <error27@gmail.com>
    Cc: corbet-T1hC0tSOHrs@public.gmane.org
    Cc: eteo@redhat.com
    Cc: Julia Lawall <julia@diku.dk>
    Signed-off-by: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 38c73044f5f4da2ef4339319b170e5e19f8dec87
Author: Peter Staubach <staubach@redhat.com>
Date:   Mon Aug 10 08:54:16 2009 -0400

    NFS: read-modify-write page updating
    
    Hi.
    
    I have a proposal for possibly resolving this issue.
    
    I believe that this situation occurs due to the way that the
    Linux NFS client handles writes which modify partial pages.
    
    The Linux NFS client handles partial page modifications by
    allocating a page from the page cache, copying the data from
    the user level into the page, and then keeping track of the
    offset and length of the modified portions of the page.  The
    page is not marked as up to date because there are portions
    of the page which do not contain valid file contents.
    
    When a read call comes in for a portion of the page, the
    contents of the page must be read in the from the server.
    However, since the page may already contain some modified
    data, that modified data must be written to the server
    before the file contents can be read back in the from server.
    And, since the writing and reading can not be done atomically,
    the data must be written and committed to stable storage on
    the server for safety purposes.  This means either a
    FILE_SYNC WRITE or a UNSTABLE WRITE followed by a COMMIT.
    This has been discussed at length previously.
    
    This algorithm could be described as modify-write-read.  It
    is most efficient when the application only updates pages
    and does not read them.
    
    My proposed solution is to add a heuristic to decide whether
    to do this modify-write-read algorithm or switch to a read-
    modify-write algorithm when initially allocating the page
    in the write system call path.  The heuristic uses the modes
    that the file was opened with, the offset in the page to
    read from, and the size of the region to read.
    
    If the file was opened for reading in addition to writing
    and the page would not be filled completely with data from
    the user level, then read in the old contents of the page
    and mark it as Uptodate before copying in the new data.  If
    the page would be completely filled with data from the user
    level, then there would be no reason to read in the old
    contents because they would just be copied over.
    
    This would optimize for applications which randomly access
    and update portions of files.  The linkage editor for the
    C compiler is an example of such a thing.
    
    I tested the attached patch by using rpmbuild to build the
    current Fedora rawhide kernel.  The kernel without the
    patch generated about 269,500 WRITE requests.  The modified
    kernel containing the patch generated about 261,000 WRITE
    requests.  Thus, about 8,500 fewer WRITE requests were
    generated.  I suspect that many of these additional
    WRITE requests were probably FILE_SYNC requests to WRITE
    a single page, but I didn't test this theory.
    
    The difference between this patch and the previous one was
    to remove the unneeded PageDirty() test.  I then retested to
    ensure that the resulting system continued to behave as
    desired.
    
    	Thanx...
    
    		ps
    
    Signed-off-by: Peter Staubach <staubach@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 074cc1deec5dee63fcd5d966b36fa4f3765b50fc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Aug 10 08:54:13 2009 -0400

    NFS: Add a ->migratepage() aop for NFS
    
    Make NFS a bit more friendly to NUMA and memory hot removal...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8854e82d9accc80f43c0bc3ff06b5979ac858185
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:30 2009 -0400

    SUNRPC: Add an rpc_pipefs front end for the sunrpc cache code
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 173912a6add00f4715774dcecf9ee53274c5924c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:29 2009 -0400

    SUNRPC: Move procfs-specific stuff out of the generic sunrpc cache code
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bc74b4f5e63a09fb78e245794a0de1e5a2716bbe
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:29 2009 -0400

    SUNRPC: Allow the cache_detail to specify alternative upcall mechanisms
    
    For events that are rare, such as referral DNS lookups, it makes limited
    sense to have a daemon constantly listening for upcalls on a channel. An
    alternative in those cases might simply be to run the app that fills the
    cache using call_usermodehelper_exec() and friends.
    
    The following patch allows the cache_detail to specify alternative upcall
    mechanisms for these particular cases.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit da77005f0d64486cd760f43d9b7cc2379262a363
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:28 2009 -0400

    SUNRPC: Remove the global temporary write buffer in net/sunrpc/cache.c
    
    While we do want to protect against multiple concurrent readers and writers
    on each upcall/downcall pipe, we don't want to limit concurrent reading and
    writing to separate caches.
    
    This patch therefore replaces the static buffer 'write_buf', which can only
    be used by one writer at a time, with use of the page cache as the
    temporary buffer for downcalls. We still fall back to using the the old
    global buffer if the downcall is larger than PAGE_CACHE_SIZE, since this is
    apparently needed by the SPKM security context initialisation.
    
    It then replaces the use of the global 'queue_io_mutex' with the
    inode->i_mutex in cache_read() and cache_write().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5b7a1b9f9214cb89dd164b43ca3fab7af4058e06
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:27 2009 -0400

    SUNRPC: Ensure we initialise the cache_detail before creating procfs files
    
    Also ensure that we destroy those files before we destroy the cache_detail.
    Otherwise, user processes might attempt to write into uninitialised caches.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2da8ca26c6bfad685bfddf39728eac1c83906aa9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:26 2009 -0400

    NFSD: Clean up the idmapper warning...
    
    What part of 'internal use' is so hard to understand?
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e57aed77ad48d28ac617ba157ad2f665f5301b30
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:26 2009 -0400

    SUNRPC: One more clean up for rpc_create_client_dir()
    
    In order to allow rpc_pipefs to create directories with different types of
    subtrees, it is useful to allow the caller to customise the subtree filling
    process.
    In order to do so, we separate out the parts which are specific to making
    an RPC client directory, and put them in a separate helper, then we convert
    the process of filling the directory contents into a callback.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 23ac6581702ac6d029643328a7e6ea3baf834c5e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:25 2009 -0400

    SUNRPC: clean up rpc_setup_pipedir()
    
    There is still a little wart or two there: Since we've already got a
    vfsmount, we might as well pass that in to rpc_create_client_dir.
    Another point is that if we open code __rpc_lookup_path() here, then we can
    avoid looking up the entire parent directory path over and over again: it
    doesn't change.
    
    Also get rid of rpc_clnt->cl_pathname, since it has no users...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7d217caca5d704e48aa5e59aba0b3ad4c7af4fd2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:24 2009 -0400

    SUNRPC: Replace rpc_client->cl_dentry and cl_mnt, with a cl_path
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7d59d1e86531a53d7648726ab8a6a670ecbd8f06
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:23 2009 -0400

    SUNRPC: Clean up rpc_create_client_dir()
    
    Factor out the code that does lookups from the code that actually creates
    the directory.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 458adb8ba9b26bfc66593866013adbb62a1a3d2e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:22 2009 -0400

    SUNRPC: Rename rpc_mkdir to rpc_create_client_dir()
    
    This reflects the fact that rpc_mkdir() as it stands today, can only create
    a RPC client type directory.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bb1567491e43df4113ec8b088ff0ebc22f568bc5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:21 2009 -0400

    SUNRPC: rpc_pipefs cleanup
    
    Move the files[] array closer to rpc_fill_super()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ac6fecee3121a6825a01c8fda2f5cbf1ad6a3ebd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:20 2009 -0400

    SUNRPC: Clean up rpc_populate/depopulate
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cfeaa4a3caaf590c1fdb7a83fcd5326e7cdc70c3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:20 2009 -0400

    SUNRPC: Clean up rpc_lookup_create
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 810d90bc2a76ff54295cfb3aa9b165160faa47ef
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:18 2009 -0400

    SUNRPC: Clean up rpc_unlink()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7589806e961a16449003b636b369edec537c2726
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:17 2009 -0400

    SUNRPC: Clean up file creation code in rpc_pipefs
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b5bb61da2efe7519eedd6a8f3830ab33ab774b83
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:17 2009 -0400

    SUNRPC: Clean up rpc_pipefs lookup code...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7364af6a2d5e708b5c6fee3cce08d1bd7b27c9f1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:16 2009 -0400

    SUNRPC: Allow rpc_pipefs_ops to have null values for upcall and downcall
    
    Also ensure that we use the umode_t type when appropriate...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b693ba4a338da15db1db4b5ebaa36e4ab9781c82
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:14:15 2009 -0400

    SUNRPC: Constify rpc_pipe_ops...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c05988cdb06237738d361ef82fbf4df1020aa3db
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:47 2009 -0400

    SUNRPC: Add documenting comments in net/sunrpc/timer.c
    
    Clean up: provide documenting comments for the functions in
    net/sunrpc/timer.c.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9dc3b095b78347bfb02c324b5ee2e558f7267396
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:46 2009 -0400

    SUNRPC: Update xprt address strings after an rpcbind completes
    
    After a bind completes, update the transport instance's address
    strings so debugging messages display the current port the transport
    is connected to.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c740eff84bcfd63c0497ef880e80171931cb8222
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:46 2009 -0400

    SUNRPC: Kill RPC_DISPLAY_ALL
    
    At some point, I recall that rpc_pipe_fs used RPC_DISPLAY_ALL.
    Currently there are no uses of RPC_DISPLAY_ALL outside the transport
    modules themselves, so we can safely get rid of it.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fbfffbd5e74c5fa8c9165e110cb5899ec21e6364
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:46 2009 -0400

    SUNRPC: Rename sock_xprt.addr as sock_xprt.srcaddr
    
    Clean up: Give the "addr" and "port" field less ambiguous names.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f8b761eff1e49fde43dd940ac32b38cf7cee2a95
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:44 2009 -0400

    SUNRPC: Eliminate PROC macro from rpcb_clnt
    
    Clean up: Replace PROC macro with open coded C99 structure
    initializers to improve readability.
    
    The rpcbind v4 GETVERSADDR procedure is never sent by the current
    implementation, so it is not copied to the new structures.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0e47f0d665efcf1b45f293422d21d8383f07d122
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:43 2009 -0400

    SUNRPC: Clean up: Remove unused XDR decoder functions from rpcb_clnt.c
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c0c077df009f2f329875051ac5283df235288689
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:43 2009 -0400

    SUNRPC: Introduce new xdr_stream-based decoders to rpcb_clnt.c
    
    Replace the open-coded decode logic for PMAP_GETPORT/RPCB_GETADDR with
    an xdr_stream-based implementation, similar to what NFSv4 uses, to
    protect against buffer overflows.  The new implementation also checks
    that the incoming port number is reasonable.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7ed0ff983c8ad30bf4e2b9fdbb299a3e3ec08d08
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:42 2009 -0400

    SUNRPC: Introduce xdr_stream-based decoders for RPCB_UNSET
    
    Replace the open-coded decode logic for rpcbind UNSET results with an
    xdr_stream-based implementation, similar to what NFSv4 uses, to
    protect against buffer overflows.
    
    The new function is unused for the moment.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0d36c4f7574d5a33bedd8f0e3c793490d45d83c6
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:41 2009 -0400

    SUNRPC: Clean up: Remove unused XDR encoder functions from rpcb_clnt.c
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6f2c2db7a46243bd86e3d7ff5f9ff982f26a9fe8
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:40 2009 -0400

    SUNRPC: Introduce new xdr_stream-based encoders to rpcb_clnt.c
    
    Replace the open-coded encode logic for rpcbind arguments with an
    xdr_stream-based implementation, similar to what NFSv4 uses, to
    better protect against buffer overflows.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4116092b92f859e5e9a90c99d740933e651ee8c0
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:40 2009 -0400

    NFSD: Support IPv6 addresses in write_failover_ip()
    
    In write_failover_ip(), replace the sscanf() with a call to the common
    sunrpc.ko presentation address parser.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c15128c5e428af1e8ada1476484a74c970665edd
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:39 2009 -0400

    lockd: Replace nsm_display_address() with rpc_ntop()
    
    Clean up.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b97a56747ea3f6c1a27dd0719bf1424959f1ebae
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:38 2009 -0400

    lockd: Replace nlm_clear_port()
    
    Clean up: Use shared rpc_set_port() function instead of nlm_clear_port().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ec6ee61250acfccbc5578dd4014735fb2cbe53b5
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:37 2009 -0400

    NFS: Replace nfs_set_port() with rpc_set_port()
    
    Clean up.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 53a0b9c4c99ab0085a06421f71592722e5b3fd5f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:36 2009 -0400

    NFS: Replace nfs_parse_ip_address() with rpc_pton()
    
    Clean up: Use the common routine now provided in sunrpc.ko for parsing mount
    addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c877b849d302d1275452af80b7221a2555dc02e1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:36 2009 -0400

    SUNRPC: Use rpc_ntop() for constructing transport address strings
    
    Clean up:  In addition to using the new generic rpc_ntop() and
    rpc_get_port() functions, have the RPC client compute the presentation
    address buffer sizes dynamically using kstrdup().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ba809130bc260fce04141aca01ef9e068d32af2a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:35 2009 -0400

    SUNRPC: Remove duplicate universal address generation
    
    RPC universal address generation is currently done in several places:
    rpcb_clnt.c, nfs4proc.c xprtsock.c, and xprtrdma.c.  Remove the
    redundant cases that convert a socket address to a universal
    address.  The nfs4proc.c case takes a pre-formatted presentation
    address string, not a socket address, so we'll leave that one.
    
    Because the new uaddr constructor uses the recently introduced
    rpc_ntop(), it now supports proper "::" shorthanding for IPv6
    addresses.  This allows the kernel to register properly formed
    universal addresses with the local rpcbind service, in _all_ cases.
    
    The kernel can now also send properly formed universal addresses in
    RPCB_GETADDR requests, and support link-local properly when
    encoding and decoding IPv6 addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a02d692611348f11ee1bc37431a883c3ff2de23e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:34 2009 -0400

    SUNRPC: Provide functions for managing universal addresses
    
    Introduce a set of functions in the kernel's RPC implementation for
    converting between a socket address and either a standard
    presentation address string or an RPC universal address.
    
    The universal address functions will be used to encode and decode
    RPCB_FOO and NFSv4 SETCLIENTID arguments.  The other functions are
    part of a previous promise to deliver shared functions that can be
    used by upper-layer protocols to display and manipulate IP
    addresses.
    
    The kernel's current address printf formatters were designed
    specifically for kernel to user-space APIs that require a particular
    string format for socket addresses, thus are somewhat limited for the
    purposes of sunrpc.ko.  The formatter for IPv6 addresses, %pI6, does
    not support short-handing or scope IDs.  Also, these printf formatters
    are unique per address family, so a separate formatter string is
    required for printing AF_INET and AF_INET6 addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0b10bf5e14d856d1d27a2117d07af2bebee81b75
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:33 2009 -0400

    SUNRPC: Move XDR data type size macros
    
    Clean up: To make subsequent patches cleaner, move the XDR data type
    size macros to the top of the file (similar to nfs4xdr.c) first.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 169026a61e6f436dfc12c9d10d95455c4e9f945b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:32 2009 -0400

    SUNRPC: Clean up RPCBIND_MAXUADDRLEN definitions
    
    Clean up: Replace the single-integer definition of RPCBIND_MAXUADDRLEN
    with a definition that is based on previously defined address string
    sizes, and document the way this maximum is calculated.  Also provide
    a separate macro for the size of the port number extension.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ec88f28d1eb77346f19ca324ceec76e645cdd9da
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:32 2009 -0400

    NFS: Use the authentication flavor list returned by mountd
    
    Commit a14017db added support in the kernel's NFS mount client to
    decode the authentication flavor list returned by mountd.
    
    The NFS client can now use this list to determine whether the
    authentication flavor requested by the user is actually supported
    by the server.
    
    Note we don't actually negotiate the security flavor if none was
    specified by the user.  Instead, we try to use AUTH_SYS, and fail if
    the server does not support it.  This prevents us from negotiating
    an inappropriate security flavor (some servers list AUTH_NULL first).
    
    If the server does not support AUTH_SYS, the user must provide an
    appropriate security flavor by specifying the "sec=" mount option.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 059f90b323c0f5d34656ab7e0548d7d033c2a51a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:31 2009 -0400

    NFS: Fix auth flavor len accounting
    
    Previous logic in the NFS mount parsing code path assumed
    auth_flavor_len was set to zero for simple authentication flavors
    (like AUTH_UNIX), and 1 for compound flavors (like AUTH_GSS).
    
    At some earlier point (maybe even before the option parsers were
    merged?) specific checks for auth_flavor_len being zero were removed
    from the functions that validate the mount option that sets the mount
    point's authentication flavor.
    
    Since we are populating an array for authentication flavors, the
    auth_flavor_len should always be set to the number of flavors.  Let's
    eliminate some cleverness here, and prepare for new logic that needs
    to know the number of flavors in the auth_flavors[] array.
    
    (auth_flavors[] is an array because at some point we want to allow a
    list of acceptable authentication flavors to be specified via the sec=
    mount option.  For now it remains a single element array).
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0b524123c93893391ec9e6c9b04998a45235f9c8
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:30 2009 -0400

    NFS: Add ability to send MOUNTPROC_UMNT to the kernel's mountd client
    
    After certain failure modes of an NFS mount, an NFS client should send
    a MOUNTPROC_UMNT request to remove the just-added mount entry from the
    server's mount table.  While no-one should rely on the accuracy of the
    server's mount table, sending a UMNT is simply being a good internet
    neighbor.
    
    Since NFS mount processing is handled in the kernel now, we will need
    a function in the kernel's mountd client that can post a MOUNTRPC_UMNT
    request, in order to handle these failure modes.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f3f4f4ed26b116f621596f74d42d2b736171e968
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 9 15:09:29 2009 -0400

    NFS: Fix up new minorversion= option
    
    The new minorversion= mount option (commit 3fd5be9e) was merged at
    the same time as the recent sloppy parser fixes (commit a5a16bae),
    so minorversion= still uses the old value parsing logic.
    
    If the minorversion= option specifies a bogus value, it should fail
    with "bad value" not "bad option."
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c140aa91357c415c91269884518fa1d6fdebc20d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:06:19 2009 -0400

    NFSv4: Clean up the nfs.callback_tcpport option
    
    Tighten up the validity checking in param_set_port: check for NULL pointers.
    Ensure that the option shows up on 'modinfo' output.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cbf1107126af2950623fafdaa5c9df43ab00f046
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:06:19 2009 -0400

    SUNRPC: convert some sysctls into module parameters
    
    Parameters like the minimum reserved port, and the number of slot entries
    should really be module parameters rather than sysctls.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 80e52aced138bb41b045a8595a87510f27d8d8c5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:06:19 2009 -0400

    NFSv4: Don't do idmapper upcalls for asynchronous RPC calls
    
    We don't want to cause rpciod to hang...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 62ab460cf5e450e1d207a98a9c6cf2e4a6a78fd1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:06:19 2009 -0400

    NFSv4: Add 'server capability' flags for NFSv4 recommended attributes
    
    If the NFSv4 server doesn't support a POSIX attribute, the generic NFS code
    needs to know that, so that it don't keep trying to poll for it.
    
    However, by the same count, if the NFSv4 server does support that
    attribute, then we should ensure that the inode metadata is appropriately
    labelled as being untrusted. For instance, if we don't know the correct
    value of the file's uid, we should certainly not be caching ACLs or ACCESS
    results.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a78cb57a106fceeba26da2907db9d8886700e1dc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 9 15:06:19 2009 -0400

    NFSv4: Don't loop forever on state recovery failure...
    
    If the server is broken, then retrying forever won't fix it. We
    should just give up after a while, and return an error to the user.
    We set the number of retries to 10 for now...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dd8ac1da4190139de70da18823ff8f5992a649ae
Author: Roel Kluin <roel.kluin@gmail.com>
Date:   Sun Aug 9 15:06:19 2009 -0400

    nfs: Keep index within mnt_errtbl[]
    
    Ensure that index i remains within array mnt_errtbl[] and mnt3_errtbl[].
    
    Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
