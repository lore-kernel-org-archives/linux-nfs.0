From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull NFSv4 and NFSv4.1 client changes for
 mainline kernel inclusion
Date: Sat, 20 Jun 2009 18:24:47 -0400
Message-ID: <1245536687.5182.53.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755932AbZFTWZF@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "for-2.6.31" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git for-2.6.31

This will update the following files through the appended changesets.

Most of the changsets are to do with adding support for the NFSv4.1 protocol.
As in the case of the server code, we'd like to move client development into
the mainline tree to allow increased testing and developer participation.
The bulk of the NFSv4.1 code is compiled out as long as you don't define
the CONFIG_V4_1 Kconfig option (which is marked as 'DEVELOPER ONLY').

Interoperability testing against other vendor implementations was done last
week at the NFSv4.1 Bakeathon event in Sunnyvale, and all known problems
have been patched.

This series does not include the NFS private namespace mount fixes, which
depend on a couple of VFS fixes, and will thus be sent separately.

  Cheers,
    Trond

----
 fs/lockd/clntproc.c            |    4 +-
 fs/lockd/mon.c                 |   19 +-
 fs/nfs/Kconfig                 |    9 +
 fs/nfs/callback.c              |  218 ++++++--
 fs/nfs/callback.h              |   68 ++-
 fs/nfs/callback_proc.c         |  127 ++++
 fs/nfs/callback_xdr.c          |  280 ++++++++-
 fs/nfs/client.c                |  191 +++++-
 fs/nfs/delegation.c            |   32 +-
 fs/nfs/direct.c                |    9 +
 fs/nfs/file.c                  |   37 +-
 fs/nfs/internal.h              |   70 ++
 fs/nfs/mount_clnt.c            |  337 +++++++++--
 fs/nfs/nfs3acl.c               |    2 -
 fs/nfs/nfs4_fs.h               |   37 +-
 fs/nfs/nfs4proc.c              | 1348 ++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4renewd.c            |    6 +-
 fs/nfs/nfs4state.c             |  190 +++++-
 fs/nfs/nfs4xdr.c               | 1072 ++++++++++++++++++++++++++++----
 fs/nfs/nfsroot.c               |    5 +
 fs/nfs/read.c                  |   33 +-
 fs/nfs/super.c                 |  295 ++++++----
 fs/nfs/unlink.c                |   20 +-
 fs/nfs/write.c                 |   31 +-
 include/linux/lockd/lockd.h    |    2 +-
 include/linux/nfs.h            |    5 +-
 include/linux/nfs2.h           |    7 -
 include/linux/nfs3.h           |    5 -
 include/linux/nfs4.h           |   18 +
 include/linux/nfs_fs_sb.h      |   67 ++-
 include/linux/nfs_xdr.h        |  171 +++++
 include/linux/nfsd/state.h     |    1 -
 include/linux/sunrpc/bc_xprt.h |   49 ++
 include/linux/sunrpc/clnt.h    |    1 +
 include/linux/sunrpc/sched.h   |    3 +
 include/linux/sunrpc/svc.h     |   11 +
 include/linux/sunrpc/svcsock.h |    2 +
 include/linux/sunrpc/xprt.h    |   38 ++-
 net/sunrpc/Makefile            |    1 +
 net/sunrpc/backchannel_rqst.c  |  281 +++++++++
 net/sunrpc/bc_svc.c            |   81 +++
 net/sunrpc/clnt.c              |  143 ++++-
 net/sunrpc/sched.c             |    2 +-
 net/sunrpc/stats.c             |    8 +-
 net/sunrpc/sunrpc.h            |   37 ++
 net/sunrpc/svc.c               |  134 +++-
 net/sunrpc/svcsock.c           |   39 ++
 net/sunrpc/xprt.c              |   60 ++-
 net/sunrpc/xprtsock.c          |  217 ++++++-
 49 files changed, 5220 insertions(+), 603 deletions(-)

commit e9f029855865e917821ef6034b31e340a4cfc815
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Thu Jun 18 22:01:24 2009 -0400

    nfs41: sunrpc: xprt_alloc_bc_request() should not use spin_lock_bh()
    
    xprt_alloc_bc_request() is always called in soft interrupt context.
    Grab the spin_lock instead of the bottom half spin_lock.  Softirqs
    do not preempt other softirqs running on the same processor, so there
    is no need to disable bottom halves.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 578e4585685410cacd1a4ac86b7e3c12805be918
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Thu Jun 18 22:01:23 2009 -0400

    nfs41: Move initialization of nfs4_opendata seq_res to nfs4_init_opendata_res
    
    nfs4_open_recover_helper clears opendata->o_res
    before calling nfs4_init_opendata_res, thus causing
    NFSv4.0 OPEN operations to be sent rather than nfsv4.1.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4bf259e3ae5015e73282ba66716c4a917e1264ac
Author: James Morris <jmorris@namei.org>
Date:   Wed Jun 17 18:02:14 2009 -0700

    nfs: remove unnecessary NFS_INO_INVALID_ACL checks
    
    Unless I'm mistaken, NFS_INO_INVALID_ACL is being checked twice during
    getacl calls (i.e. first via nfs_revalidate_inode() and then by each all
    site).
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a5a16bae707cd5d2bc97d7bd1a30079f18113a77
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:14 2009 -0700

    NFS: More "sloppy" parsing problems
    
    Specifying "port=-5" with the kernel's current mount option parser
    generates "unrecognized mount option".  If "sloppy" is set, this
    causes the mount to succeed and use the default values; the desired
    behavior is that, since this is a valid option with an invalid value,
    the mount should fail, even with "sloppy."
    
    To properly handle "sloppy" parsing, we need to distinguish between
    correct options with invalid values, and incorrect options.  We will
    need to parse integer values by hand, therefore, and not rely on
    match_token().
    
    For instance, these must all fail with "invalid value":
    
    	port=12345678
    	port=-5
    	port=samuel
    
    and not with "unrecognized option," as they do currently.
    
    Thus, for the sake of match_token() we need to treat the values for
    these options as strings, and do the conversion to integers using
    strict_strtol().
    
    This is basically the same solution we used for the earlier "retry="
    fix (commit ecbb3845), except in this case the kernel actually has to
    parse the value, rather than ignore it.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d23c45fd84f79a3b84899dac053dcafe9d43ebc9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:13 2009 -0700

    NFS: Invalid mount option values should always fail, even with "sloppy"
    
    Ian Kent reports:
    
    "I've noticed a couple of other regressions with the options vers
    and proto option of mount.nfs(8).
    
    The commands:
    
    mount -t nfs -o vers=<invalid version> <server>:/<path> /<mountpoint>
    mount -t nfs -o proto=<invalid proto> <server>:/<path> /<mountpoint>
    
    both immediately fail.
    
    But if the "-s" option is also used they both succeed with the
    mount falling back to defaults (by the look of it).
    
    In the past these failed even when the sloppy option was given, as
    I think they should. I believe the sloppy option is meant to allow
    the mount command to still function for mount options (for example
    in shared autofs maps) that exist on other Unix implementations but
    aren't present in the Linux mount.nfs(8). So, an invalid value
    specified for a known mount option is different to an unknown mount
    option and should fail appropriately."
    
    See RH bugzilla 486266.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 065015e5efff60884ad600a3e9a5127dbb684429
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:13 2009 -0700

    NFS: Remove unused XDR decoder functions
    
    Clean up: Remove xdr_decode_fhstatus() and xdr_decode_fhstatus3(), now
    that they are unused.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8e02f6b9aae9b265064f929c6df15222b9baf256
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:13 2009 -0700

    NFS: Update MNT and MNT3 reply decoding functions
    
    Solder xdr_stream-based XDR decoding functions into the in-kernel mountd
    client that are more careful about checking data types and watching for
    buffer overflows.  The new MNT3 decoder includes support for auth-flavor
    list decoding.
    
    The "_sz" macro for MNT3 replies was missing the size of the file handle.
    I've added this back, and included the size of the auth flavor array.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a14017db2852f9393a401a0f64053c331003babf
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:12 2009 -0700

    NFS: add XDR decoder for mountd version 3 auth-flavor lists
    
    Introduce an xdr_stream-based XDR decoder that can unpack the auth-
    flavor list returned in a MNT3 reply.
    
    The nfs_mount() function's caller allocates an array, and passes the
    size and a pointer to it.  The decoder decodes all the flavors it can
    into the array, and returns the number of decoded flavors.
    
    If the caller is not interested in the auth flavors, it can pass a
    value of zero as the size of the pre-allocated array.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4fdcd9966d8469be26a6f12122ac21ffce19fc20
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:12 2009 -0700

    NFS: add new file handle decoders to in-kernel mountd client
    
    Introduce xdr_stream-based XDR file handle decoders to the in-kernel
    mountd client.  These are more careful than the existing decoder
    functions about buffer overflows and data type and range checking.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fb12529577541aa02f9c3d9e325329f9568dfb58
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:12 2009 -0700

    NFS: Add separate mountd status code decoders for each mountd version
    
    Introduce data structures and xdr_stream-based decoding functions for
    unmarshalling mountd status codes properly.
    
    Mountd version 3 uses specific standard error return codes that are
    not errno values and not NFS3ERR_ values.  These have a well-defined
    standard mapping to local errno values.  Introduce data structures
    and a decoder function that map these status codes to local errno
    values properly.  This is new functionality (but not used yet).
    
    Version 1 mountd status values are defined by RFC 1094 as UNIX error
    values (errno values).  Errno values on heterogeneous systems do not
    necessarily match each other.  To avoid exposing possibly incorrect
    errno values to upper layers, the current XDR decoder converts all
    non-zero MNT version 1 status codes to -EACCES.
    
    The OpenGroup XNFS standard provides a mapping similar to but smaller
    than the version 3 error codes.  Implement a decoder that uses the XNFS
    error codes, replacing the current decoder.
    
    For both mountd protocol versions, map unrecognized errors to -EACCES.
    
    Finally we introduce a replacement data structure for mnt_fhstatus
    at this time, which is used by the new XDR decoders.  In addition to
    documenting that the status value returned by the XDR decoders is
    always an errno, this new structure will be expanded in subsequent
    patches.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 99835db430904e90c0640ebc6b91cd2a90a118f7
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:11 2009 -0700

    NFS: remove unused function in fs/nfs/mount_clnt.c
    
    Clean up: remove xdr_encode_dirpath() now that it has been replaced.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 29a1bd6bf8c7a9ff511aaaf7e40fd6ca5198babe
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:11 2009 -0700

    NFS: Use xdr_stream-based XDR encoder for MNT's dirpath argument
    
    Check the length of the supplied dirpath, and see that it fits
    properly in the RPC buffer.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2ad780978b7c0c3e7877949f098cbd06e7c73839
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:11 2009 -0700

    NFS: Clean up MNT program definitions
    
    Clean up:  Relocate MNT program procedure number definitions to the
    only file that uses them.  Relocate the version number definitions,
    which are shared, to nfs.h.  Remove duplicate program number
    definitions.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0e5c2632e1c9182f0dadc31bec68d6f42e7905ea
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:11 2009 -0700

    lockd: Don't bother with RPC ping for NSM upcalls
    
    Cut NSM upcall RPC traffic in half -- don't do a NULL call first.
    The cases where a ping would be helpful are rare.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6c9dc4255108bab4ef5c177d369b99c3c23492a7
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:10 2009 -0700

    lockd: Update NSM state from SM_MON replies
    
    When rpc.statd starts up in user space at boot time, it attempts to
    write the latest NSM local state number into
    /proc/sys/fs/nfs/nsm_local_state.
    
    If lockd.ko isn't loaded yet (as is the case in most configurations),
    that file doesn't exist, thus the kernel's NSM state remains set to
    its initial value of zero during lockd operation.
    
    This is a problem because rpc.statd and lockd use the NSM state number
    to prevent repeated lock recovery on rebooted hosts.  If lockd sends
    a zero NSM state, but then a delayed SM_NOTIFY with a real NSM state
    number is received, there is no way for lockd or rpc.statd to
    distinguish that stale SM_NOTIFY from an actual reboot.  Thus lock
    recovery could be performed after the rebooted host has already
    started reclaiming locks, and those locks will be lost.
    
    We could change /etc/init.d/nfslock so it always modprobes lockd.ko
    before starting rpc.statd.  However, if lockd.ko is ever unloaded
    and reloaded, we are back at square one, since the NSM state is not
    preserved across an unload/reload cycle.  This may happen frequently
    on clients that use automounter.  A period of NFS inactivity causes
    lockd.ko to be unloaded, and the kernel loses its NSM state setting.
    
    Instead, let's use the fact that rpc.statd plants the local system's
    NSM state in every SM_MON (and SM_UNMON) reply.  lockd performs a
    synchronous SM_MON upcall to the local rpc.statd _before_ sending its
    first NLM request to a new remote.  This would permit rpc.statd to
    provide the current NSM state to lockd, even after lockd.ko had been
    unloaded and reloaded.
    
    Note that NLMPROC_LOCK arguments are constructed before the
    nsm_monitor() call, so we have to rearrange argument construction very
    slightly to make this all work out.
    
    And, the kernel appears to treat NSM state as a u32 (see struct
    nlm_args and nsm_res).  Make nsm_local_state a u32 as well, to ensure
    we don't get bogus comparison results.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 18fc31641925867c871bc75270ce642c039188d3
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:10 2009 -0700

    NFS: Fix false error return from nfs_callback_up() if ipv6.ko is not available
    
    Clear "ret" if the error return from svc_create_xprt(AF_INET6) was
    -EAFNOSUPORT.  Otherwise, callback start-up will succeed, but
    nfs_callback_up() will return -EAFNOSUPPORT anyway, and the first
    NFSv4 mount attempt after a reboot will fail.
    
    Bug introduced by commit f738f517 in 2.6.30-rc1.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a21bdd9b960ccce421b63aa0e3efda4fcdc26f10
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:10 2009 -0700

    NFS: Return error code from nfs_callback_up() to user space
    
    If the kernel cannot start the NFSv4 callback service during a mount
    request, it returns -ENOMEM to user space, resulting in this message:
    
       mount.nfs4: Cannot allocate memory
    
    Adjust nfs_alloc_client() and nfs_get_client() to pass NFSv4 callback
    start-up errors back to user space so a less mysterious error message
    can be displayed by the mount command.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c381ad2cf2d5dcd3991bcc8a18fddd9d5c66ccaa
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 17 18:02:09 2009 -0700

    NFS: Do not display the setting of the "intr" mount option
    
    The "intr" mount option has been deprecated for a while, but
    /proc/mounts continues to display "nointr" whether "intr" or "nointr"
    has been specified for a mount point.
    
    Since these options do not have any effect, simply do not display
    them.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bf40d3435caf49369058b1ed6bbc92f8e2bd92f1
Author: Suresh Jayaraman <sjayaraman@suse.de>
Date:   Wed Jun 17 18:02:09 2009 -0700

    NFS: add support for splice writes
    
    Adds support for splice writes. It effectively calls
    generic_file_splice_write() to do the writes.
    
    We need not worry about O_APPEND case as the combination of splice()
    writes and O_APPEND is disallowed. This patch propagates NFS write
    errors back to the caller. The number of bytes written via splice are
    being added to NFSIO_NORMALWRITTENBYTES as these are effectively
    cached writes.
    
    Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 68f3f90133d56e0c38f04f991e662c2b21592b31
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:35 2009 -0400

    nfs41: Backchannel: CB_SEQUENCE validation
    
    Validates the callback's sessionID, the slot number, and the sequence ID.
    Increments the slot's sequence.
    
    Detects replays, but simply prints a debug message (if debugging is enabled
    since we don't yet implement a duplicate request cache for the backchannel.
    This should not present a problem, since only idempotent callbacks are
    currently implemented.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Backchannel: Be more obvious about the return value]
    [nfs41: Backchannel: dprink in host order]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 963891ac43ecf9974d82f4c178752e11e007cf87
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:34 2009 -0400

    nfs41: Backchannel: New find_client_with_session()
    
    Finds the 'struct nfs_client' that matches the server's address, major
    version number, and session ID.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit f8625a6a4bb76207302be58453603d8e324df490
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:33 2009 -0400

    nfs41: Backchannel: Add a backchannel slot table to the session
    
    Defines a new 'struct nfs4_slot_table' in the 'struct nfs4_session'
    for use by the backchannel.  Initializes, resets, and destroys the backchannel
    slot table in the same manner the forechannel slot table is initialized,
    reset, and destroyed.
    
    The sequenceid for each slot in the backchannel slot table is initialized
    to 0, whereas the forechannel slotid's sequenceid is set to 1.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 050047ce71bcf60867d2af7a9dc965a9c6f15cb8
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:32 2009 -0400

    nfs41: Backchannel: Refactor nfs4_init_slot_table()
    
    Generalize nfs4_init_slot_table() so it can be used to initialize the
    backchannel slot table in addition to the forechannel slot table.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit b73dafa7ac94ca8387f65c57cb63a7ffac91bf2c
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:31 2009 -0400

    nfs41: Backchannel: Refactor nfs4_reset_slot_table()
    
    Generalize nfs4_reset_slot_table() so it can be used to reset the
    backchannel slot table in addition to the forechannel slot table.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 65fc64e547c794764a441e16e95bb76c0e256bd7
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:30 2009 -0400

    nfs41: Backchannel: update cb_sequence args and results
    
    Change the type of cs_addr and csr_status to 'struct sockaddr' and
    '__be32' since the cb_sequence processing function will use existing
    functionality that expects these types.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit dd2b63d049480979016b959abc2d141cdddb1389
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:28 2009 -0400

    nfs41: Rename rq_received to rq_reply_bytes_recvd
    
    The 'rq_received' member of 'struct rpc_rqst' is used to track when we
    have received a reply to our request.  With v4.1, the backchannel
    can now accept callback requests over the existing connection.  Rename
    this field to make it clear that it is only used for tracking reply bytes
    and not all bytes received on the connection.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 281fe15dc1d6ad46992f18b7a6644269ec5f7138
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:23:27 2009 -0400

    nfs41: verify CB_SEQUENCE position in callback compound
    
    CB_SEQUENCE must appear first in the callback compound RPC.
    If it is not the first operation NFS4ERR_SEQUENCE_POS must be returned.
    If the first operation ni the CB_COMPOUND is not CB_SEQUENCE then
    NFS4ERR_OP_NOT_IN_SESSION must be returned.
    
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: refactor op preprocessing out of process_op]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 4aece6a19cf7f474f15eb861ba74db4479884ce3
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:23:26 2009 -0400

    nfs41: cb_sequence xdr implementation
    
    [nfs41: get rid of READMEM and COPYMEM for callback_xdr.c]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: get rid of READ64 in callback_xdr.c]
    See http://linux-nfs.org/pipermail/pnfs/2009-June/007846.html
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit d49433e1e3bb144a5752ce2a8ba1139dc519df1a
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:23:25 2009 -0400

    nfs41: cb_sequence proc implementation
    
    Currently, just free up any referring calls information.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: fix csr_{,target}highestslotid]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 2d9b9ec344b19b7b65c732b7000114df57684140
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:23:24 2009 -0400

    nfs41: cb_sequence protocol level data structures
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 34bc47c941a074f91c2455b4b08503d02c74b878
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:23:22 2009 -0400

    nfs41: consider minorversion in callback_xdr:process_op
    
    Note that this patch changes the nfsv4.0 behavior also when
    CONFIG_NFS_V4_1 is not defined where NFS4ERR_MINOR_VERS_MISMATCH
    will be returned if the client received a CB_COMPOUND
    with minorversion != 0.  Previously, it would have
    returned NFS4ERR_OP_ILLEGAL for CB_SEQUENCE.
    (or if the server is broken and sent OP_CB_GETATTR or OP_CB_RECALL
    with minorversion!=0, they would have been processed normally.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: refactor op preprocessing out of process_op]
    See http://linux-nfs.org/pipermail/pnfs/2009-June/007845.html
    [nfs41: define CB_NOTIFY_DEVICEID as not supported]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 45377b94edea18f53dd3ba4d46d94de4bb7c00b5
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:23:21 2009 -0400

    nfs41: callback numbers definitions
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 48a9e2d2289ed4b5053b3986d99709e9b07a0923
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:23:20 2009 -0400

    nfs41: decode minorversion 1 cb_compound header
    
    decode cb_compound header conforming to
    http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
    
    Get rid of cb_compound_hdr_arg.callback_ident
    
    callback_ident is not used anywhere so we shouldn't waste any memory to
    store it.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: no need to break read_buf in decode_compound_hdr_arg]
    See http://linux-nfs.org/pipermail/pnfs/2009-June/007844.html
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit b8f2ef84b079ceb22b42d6d353609db7eb8efa93
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:23:19 2009 -0400

    nfs41: store minorversion in cb_compound_hdr_arg
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 5a0ffe544c54f62be99751e369f4d0f44bd5ee19
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:23:18 2009 -0400

    nfs41: Release backchannel resources associated with session
    
    Frees the preallocated backchannel resources that are associated with
    this session when the session is destroyed.
    
    A backchannel is currently created once per session. Destroy the backchannel
    only when the session is destroyed.
    
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 343952fa5aac888934ffc203abed26a823400eb6
Author: Rahul Iyer <iyer@netapp.com>
Date:   Wed Apr 1 09:23:17 2009 -0400

    nfs41: Get the rpc_xprt * from the rpc_rqst instead of the rpc_clnt.
    
    Obtain the rpc_xprt from the rpc_rqst so that calls and callback replies
    can both use the same code path.  A client needs the rpc_xprt in order
    to reply to a callback.
    
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 0f91421e8ea986c990c01bf091ceff1d59c165ff
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:23:16 2009 -0400

    nfs41: Client indicates presence of NFSv4.1 callback channel.
    
    Set the SESSION4_BACK_CHAN flag to indicate the client supports a backchannel.
    
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 0b5b7ae0a853c91015bb3b1729166ca65f693322
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:23:15 2009 -0400

    nfs41: Setup the backchannel
    
    The NFS v4.1 callback service has already been setup, and
    rpc_xprt->serv points to the svc_serv structure describing it.
    Invoke the xprt_setup_backchannel() initialization to pre-
    allocate the necessary backchannel structures.
    
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: change nfs4_put_session(nfs4_session**) to nfs4_destroy_session(nfs_session*)]
    Signed-off-by: Alexandros Batsakis <Alexandros.Batsakis@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [moved xprt_setup_backchannel from nfs4_init_session to nfs4_init_backchannel]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit e82dc22dac6525a2f365a1d53c0483252d4aa38e
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:23:14 2009 -0400

    nfs41: Allow NFSv4 and NFSv4.1 callback services to coexist
    
    Tracks the nfs_callback_info for both versions, enabling the callback
    service for v4 and v4.1 to run concurrently and be stopped independently
    of each other.
    
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 8f975242352e92898dc641ebff0d24808f39848a
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:23:11 2009 -0400

    nfs41: create a svc_xprt for nfs41 callback thread and use for incoming callbacks
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 9c9f3f5fa62cc4959e4d4d1cf1ec74f2d6ac1197
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:23:10 2009 -0400

    nfs41: sunrpc: add a struct svc_xprt pointer to struct svc_serv for backchannel use
    
    This svc_xprt is passed on to the callback service thread to be later used
    to processes incoming svc_rqst's
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 7652e5a09ba319241607b22d9055ce93fd5b8039
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:23:09 2009 -0400

    nfs41: sunrpc: provide functions to create and destroy a svc_xprt for backchannel use
    
    For nfs41 callbacks we need an svc_xprt to process requests coming up the
    backchannel socket as rpc_rqst's that are transformed into svc_rqst's that
    need a rq_xprt to be processed.
    
    The svc_{udp,tcp}_create methods are too heavy for this job as svc_create_socket
    creates an actual socket to listen on while for nfs41 we're "reusing" the
    fore channel's socket.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit a43cde94feded0f65fce36330614691c650ae8fe
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:08 2009 -0400

    nfs41: Implement NFSv4.1 callback service process.
    
    nfs41_callback_up() initializes the necessary queues and creates the new
    nfs41_callback_svc thread.  This thread executes the callback service which
    waits for requests to arrive on the svc_serv->sv_cb_list.
    
    NFS41_BC_MIN_CALLBACKS is set to 1 because we expect callbacks to not
    cause substantial latency.
    
    The actual processing of the callback will be implemented as a separate patch.
    
    There is only one NFSv4.1 callback service.  The first caller of
    nfs4_callback_up() creates the service, subsequent callers increment a
    reference count on the service.  The service is destroyed when the last
    caller invokes nfs_callback_down().
    
    The transport needs to hold a reference to the callback service in order
    to invoke it during callback processing.  Currently this reference is only
    obtained when the service is first created.  This is incorrect, since
    subsequent registrations for other transports will leave the xprt->serv
    pointer uninitialized, leading to an oops when a callback arrives on
    the "unreferenced" transport.
    
    This patch fixes the problem by ensuring that a reference to the service
    is saved in xprt->serv, either because the service is created by this
    invocation to nfs4_callback_up() or by a prior invocation.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Add a reference to svc_serv during callback service bring up]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Type check arguments of nfs_callback_up]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: save svc_serv in nfs_callback_info]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Removal of ugly #ifdefs]
    [nfs41: Update to removal of ugly #ifdefs]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 4d6bbb6233c9cf23822a2f66f8470c9f40854b77
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:07 2009 -0400

    nfs41: Backchannel bc_svc_process()
    
    Implement the NFSv4.1 backchannel service.  Invokes the common callback
    processing logic svc_process_common() to authenticate the call and
    dispatch the appropriate NFSv4.1 XDR decoder and operation procedure.
    It then invokes bc_send() to send the reply over the same connection.
    bc_send() is implemented in a separate patch.
    
    At this time there is no slot validation or reply cache handling.
    
    [nfs41: Preallocate rpc_rqst receive buffer for handling callbacks]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Move bc_svc_process() declaration to correct patch]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 1cad7ea6fe98dc414bd3df55275c147bd15ebf97
Author: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Date:   Wed Apr 1 09:23:06 2009 -0400

    nfs41: Refactor svc_process()
    
    net/sunrpc/svc.c:svc_process() is used by the NFSv4 callback service
    to process RPC requests arriving over connections initiated by the
    server.  NFSv4.1 supports callbacks over the backchannel on connections
    initiated by the client.  This patch refactors svc_process() so that
    common code can also be used by the backchannel.
    
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 0d90ba1cd416525c4825c111db862d8b15a02e9b
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:04 2009 -0400

    nfs41: Backchannel callback service helper routines
    
    Executes the backchannel task on the RPC state machine using
    the existing open connection previously established by the client.
    
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    
    nfs41: Add bc_svc.o to sunrpc Makefile.
    
    [nfs41: bc_send() does not need to be exported outside RPC module]
    [nfs41: xprt_free_bc_request() need not be exported outside RPC module]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Update copyright]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 55ae1aabfb108106dd095de2578ceef1c755a8b8
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:03 2009 -0400

    nfs41: Add backchannel processing support to RPC state machine
    
    Adds rpc_run_bc_task() which is called by the NFS callback service to
    process backchannel requests.  It performs similar work to rpc_run_task()
    though "schedules" the backchannel task to be executed starting at the
    call_trasmit state in the RPC state machine.
    
    It also introduces some miscellaneous updates to the argument validation,
    call_transmit, and transport cleanup functions to take into account
    that there are now forechannel and backchannel tasks.
    
    Backchannel requests do not carry an RPC message structure, since the
    payload has already been XDR encoded using the existing NFSv4 callback
    mechanism.
    
    Introduce a new transmit state for the client to reply on to backchannel
    requests.  This new state simply reserves the transport and issues the
    reply.  In case of a connection related error, disconnects the transport and
    drops the reply.  It requires the forechannel to re-establish the connection
    and the server to retransmit the request, as stated in NFSv4.1 section
    2.9.2 "Client and Server Transport Behavior".
    
    Note: There is no need to loop attempting to reserve the transport.  If EAGAIN
    is returned by xprt_prepare_transmit(), return with tk_status == 0,
    setting tk_action to call_bc_transmit.  rpc_execute() will invoke it again
    after the task is taken off the sleep queue.
    
    [nfs41: rpc_run_bc_task() need not be exported outside RPC module]
    [nfs41: New call_bc_transmit RPC state]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Backchannel: No need to loop in call_bc_transmit()]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [rpc_count_iostats incorrectly exits early]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Convert rpc_reply_expected() to inline function]
    [Remove unnecessary BUG_ON()]
    [Rename variable]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 5cd973c44a92f4abf8f7084c804089b3eaa7b4bf
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 17 13:23:01 2009 -0700

    NFSv4/NLM: Push file locking BKL dependencies down into the NLM layer
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3f09df70e3a33590ae5a97b8a15486d3711c7065
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 17 13:23:00 2009 -0700

    NFS: Ensure we always hold the BKL when dereferencing inode->i_flock
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 965b5d679146c9f69bc0325388bb9ed357863c4f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 17 13:22:59 2009 -0700

    NFSv4: Handle more errors when recovering open file and locking state
    
    It is possible for servers to return NFS4ERR_BAD_STATEID when
    the state management code is recovering locks or is reclaiming state when
    returning a delegation. Ensure that we handle that case.
    While we're at it, add in handlers for NFS4ERR_STALE,
    NFS4ERR_ADMIN_REVOKED, NFS4ERR_OPENMODE, NFS4ERR_DENIED and
    NFS4ERR_STALE_STATEID, since the protocol appears to allow for them too.
    
    Also handle ENOMEM...
    
    Finally, rather than add new NFSv4.0-specific errors and error handling into
    the generic delegation code, move that open file and locking state error
    handling into the NFSv4 layer.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d5122201a7f90b2aa73092f158b84d1d74f1134d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 17 13:22:58 2009 -0700

    NFSv4: Move error handling out of the delegation generic code
    
    The NFSv4 delegation recovery code is required by the protocol to handle
    more errors. Rather than add NFSv4.0 specific errors into 'generic'
    delegation code, we should move the error handling into the NFSv4 layer.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 01c3f05228ce7fc19baa103e4e4bf6c1b5062a53
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 17 13:22:58 2009 -0700

    NFSv4: Fix the 'nolock' option regression
    
    NFSv4 should just ignore the 'nolock' option. It is an NFSv2/v3 thing...
    This fixes the Oops in http://bugzilla.kernel.org/show_bug.cgi?id=13330
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 88b5ed73bcd0f21e008b6e303a02c8b7cb1199f4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 17 13:22:57 2009 -0700

    SUNRPC: Fix a missing "break" option in xs_tcp_setup_socket()
    
    In the case of -EADDRNOTAVAIL and/or unhandled connection errors, we want
    to get rid of the existing socket and retry immediately, just as the
    comment says. Currently we end up sleeping for a minute, due to the missing
    "break" statement.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 44b98efdd0a205bdca2cb63493350d06ff6804b1
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:02 2009 -0400

    nfs41: New xs_tcp_read_data()
    
    Handles RPC replies and backchannel callbacks.  Traditionally the NFS
    client has expected only RPC replies on its open connections.  With
    NFSv4.1, callbacks can arrive over an existing open connection.
    
    This patch refactors the old xs_tcp_read_request() into an RPC reply handler:
    xs_tcp_read_reply(), a new backchannel callback handler: xs_tcp_read_callback(),
    and a common routine to read the data off the transport: xs_tcp_read_common().
    The new xs_tcp_read_callback() queues callback requests onto a queue where
    the callback service (a separate thread) is listening for the processing.
    
    This patch incorporates work and suggestions from Rahul Iyer (iyer@netapp.com)
    and Benny Halevy (bhalevy@panasas.com).
    
    xs_tcp_read_callback() drops the connection when the number of expected
    callbacks is exceeded.  Use xprt_force_disconnect(), ensuring tasks on
    the pending queue are awaken on disconnect.
    
    [nfs41: Keep track of RPC call/reply direction with a flag]
    [nfs41: Preallocate rpc_rqst receive buffer for handling callbacks]
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: sunrpc: xs_tcp_read_callback() should use xprt_force_disconnect()]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Moves embedded #ifdefs into #ifdef function blocks]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 4a8d70bfef01f8e6b27785e2625e88e9a80924a5
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:01 2009 -0400

    nfs41: New include/linux/sunrpc/bc_xprt.h
    
    Contains prototype for backchannel helper routines.
    
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: xprt_setup_backchannel v4.0 only inline]
        Fix compile error when CONFIG_NFS_V4_1 is not set.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Update Copyright notice and fix formatting]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit fb7a0b9addbdbbb13b7bc02abf55ee524ea19ce1
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:23:00 2009 -0400

    nfs41: New backchannel helper routines
    
    This patch introduces support to setup the callback xprt on the client side.
    It allocates/ destroys the preallocated memory structures used to process
    backchannel requests.
    
    At setup time, xprt_setup_backchannel() is invoked to allocate one or
    more rpc_rqst structures and substructures.  This ensures that they
    are available when an RPC callback arrives.  The rpc_rqst structures
    are maintained in a linked list attached to the rpc_xprt structure.
    We keep track of the number of allocations so that they can be correctly
    removed when the channel is destroyed.
    
    When an RPC callback arrives, xprt_alloc_bc_request() is invoked to
    obtain a preallocated rpc_rqst structure.  An rpc_xprt structure is
    returned, and its RPC_BC_PREALLOC_IN_USE bit is set in
    rpc_xprt->bc_flags.  The structure is removed from the the list
    since it is now in use, and it will be later added back when its
    user is done with it.
    
    After the RPC callback replies, the rpc_rqst structure is returned
    by invoking xprt_free_bc_request().  This clears the
    RPC_BC_PREALLOC_IN_USE bit and adds it back to the list, allowing it
    to be reused by a subsequent RPC callback request.
    
    To be consistent with the reception of RPC messages, the backchannel requests
    should be placed into the 'struct rpc_rqst' rq_rcv_buf, which is then in turn
    copied to the 'struct rpc_rqst' rq_private_buf.
    
    [nfs41: Preallocate rpc_rqst receive buffer for handling callbacks]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Update copyright notice and explain page allocation]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit f9acac1a4710ce88871f1ae323fc91c1cb6e9d52
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:22:59 2009 -0400

    nfs41: Initialize new rpc_xprt callback related fields
    
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 56632b5bff5af10eb12d7e9499b5ffcadcb7a7b2
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:22:58 2009 -0400

    nfs41: client callback structures
    
    Adds new list of rpc_xprt structures, and a readers/writers lock to
    protect the list.  The list is used to preallocate resources for
    the backchannel during backchannel requests.  Callbacks are not
    expected to cause significant latency, so only one callback will
    be allowed at this time.
    
    It also adds a pointer to the NFS callback service so that
    requests can be directed to it for processing.
    
    New callback members added to svc_serv. The NFSv4.1 callback service will
    sleep on the svc_serv->svc_cb_waitq until new callback requests arrive.
    The request will be queued in svc_serv->svc_cb_list. This patch adds this
    list, the sleep queue and spinlock to svc_serv.
    
    [nfs41: NFSv4.1 callback support]
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 7146851376861fe55c7a48ac8fc1354a5fff6cd0
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:56 2009 -0400

    nfs41: minorversion support for nfs4_{init,destroy}_callback
    
    move nfs4_init_callback into nfs4_init_client_minor_version
    and nfs4_destroy_callback into nfs4_clear_client_minor_version
    
    as these need to happen also when auto-negotiating the minorversion
    once the callback service for nfs41 becomes different than for nfs4.0
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Fix checkpatch warning]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Type check arguments of nfs_callback_up]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Backchannel: Remove FIXME comment]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 9bdaa86d2a4cbf9a71de3048c0c0a874e7ebc8ad
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:55 2009 -0400

    nfs41: Refactor nfs4_{init,destroy}_callback for nfs4.0
    
    Refactor-out code to bring the callback service up and down.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit f4a2e418bfd03a1f25f515e8a92ecd584d96cfc1
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:22:54 2009 -0400

    nfs41: Process the RPC call direction
    
    Reading and storing the RPC direction is a three step process.
    
    1. xs_tcp_read_calldir() reads the RPC direction, but it will not store it
    in the XDR buffer since the 'struct rpc_rqst' is not yet available.
    
    2. The 'struct rpc_rqst' is obtained during the TCP_RCV_COPY_DATA state.
    This state need not necessarily be preceeded by the TCP_RCV_READ_CALLDIR.
    For example, we may be reading a continuation packet to a large reply.
    Therefore, we can't simply obtain the 'struct rpc_rqst' during the
    TCP_RCV_READ_CALLDIR state and assume it's available during TCP_RCV_COPY_DATA.
    
    This patch adds a new TCP_RCV_READ_CALLDIR flag to indicate the need to
    read the RPC direction.  It then uses TCP_RCV_COPY_CALLDIR to indicate the
    RPC direction needs to be saved after the 'struct rpc_rqst' has been allocated.
    
    3. The 'struct rpc_rqst' is obtained by the xs_tcp_read_data() helper
    functions.  xs_tcp_read_common() then saves the RPC direction in the XDR
    buffer if TCP_RCV_COPY_CALLDIR is set.  This will happen when we're reading
    the data immediately after the direction was read.  xs_tcp_read_common()
    then clears this flag.
    
    [was nfs41: Skip past the RPC call direction]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: sunrpc: Add RPC direction back into the XDR buffer]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: sunrpc: Don't skip past the RPC call direction]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 18dca02aeb3c49dfce87c76be643b139d05cf647
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Apr 1 09:22:53 2009 -0400

    nfs41: Add ability to read RPC call direction on TCP stream.
    
    NFSv4.1 callbacks can arrive over an existing connection. This patch adds
    the logic to read the RPC call direction (call or reply). It does this by
    updating the state machine to look for the call direction invoking
    xs_tcp_read_calldir(...) after reading the XID.
    
    [nfs41: Keep track of RPC call/reply direction with a flag]
    
    As per 11/14/08 review of RFC 53/85.
    
    Add a new flag to track whether the incoming message is an RPC call or an
    RPC reply.  TCP_RPC_REPLY is set in the 'struct sock_xprt' tcp_flags in
    xs_tcp_read_calldir() if the message is an RPC reply sent on the forechannel.
    It is cleared if the message is an RPC request sent on the back channel.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 34dc1ad752ad3f55b2a6e6cd8cfcf3504682fec7
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:52 2009 -0400

    nfs41: increment_{open,lock}_seqid
    
    Unlike minorversion0, in nfsv4.1 the open and lock seqids need
    not be incremented by the client and should always be set to zero.
    
    This is implemented using a new nfs_rpc_ops methods -
    increment_open_seqid and increment_lock_seqid
    
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: check for session not minorversion]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 78722e9c9208a312695178f5331511badd190598
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Jun 16 14:43:15 2009 -0400

    nfs41: only retry EXCHANGE_ID on recoverable errors
    
    Stops an infinite loop of EXCHANGE_ID.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [fixed checkpatch warnings]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 008f55d0e019943323c20a03493a2ba5672a4cc8
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:50 2009 -0400

    nfs41: recover lease in _nfs4_lookup_root
    
    This creates the nfsv4.1 session on mount.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b4b82607ffcf09b57301846d154f2c09c0b807c0
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:49 2009 -0400

    nfs41: get_clid_cred for EXCHANGE_ID
    
    Unlike SETCLIENTID, EXCHANGE_ID requires a machine credential. Do not search
    for credentials other than the machine credential.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 90a16617ee6a052c3a1aac00eb67136324cf4dd0
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:48 2009 -0400

    nfs41: add a get_clid_cred function to nfs4_state_recovery_ops
    
    EXCHANGE_ID has different credential requirements than SETCLIENTID.
    Prepare for a separate credential function.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 591d71cbde186cc498c0d9718dc17f2fadf7c643
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:47 2009 -0400

    nfs41: establish sessions-based clientid
    
    nfsv4.1 clientid is established via EXCHANGE_ID rather than
    SETCLIENTID{,_CONFIRM}
    
    This is implemented using a new establish_clid method in
    nfs4_state_recovery_ops.
    
    nfs41: establish clientid via exchange id only if cred != NULL
    
    >From 2.6.26 reclaimer() uses machine cred for setting up the client id
    therefore it is never expected to be NULL.
    
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    [removed dprintk]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: lease renewal]
    [revamped patch for new nfs4_state_manager design]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a7b721037f898b29a8083da59b1dccd3da385b07
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:46 2009 -0400

    nfs41: introduce get_state_renewal_cred
    
    Use the machine cred for sending SEQUENCE to renew
    the client's lease.
    
    [revamp patch for new state management design starting 2.6.29]
    [nfs41: support minorversion 1 for nfs4_check_lease]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: get cred in exchange_id when cred arg is NULL]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use cl_machined_cred instead of cl_ex_cred]
        Since EXCHANGE_ID insists on using the machine credential, cl_ex_cred is
        not needed. nfs4_proc_exchange_id() is only called if the machine credential
        is available. Remove the credential logic from nfs4_proc_exchange_id.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8e69514f2981d85108c2bd220ff8e188c0c27cdb
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:45 2009 -0400

    nfs41: support minorversion 1 for nfs4_check_lease
    
    [moved nfs4_get_renew_cred related changes to
     "nfs41: introduce get_state_renewal_cred"]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 29fba38b793225798104a1ac870e6807ebd078dd
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:44 2009 -0400

    nfs41: lease renewal
    
    Send a NFSv4.1 SEQUENCE op rather than RENEW that was deprecated in
    minorversion 1.
    Use the nfs_client minorversion to select reboot_recover/
    network_partition_recovery/state_renewal ops.
    
    Note: we use reclaimer to create the nfs41 session before there are any
    cl_superblocks for the nfs_client.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: check for session not minorversion]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [revamped patch for new nfs4_state_manager design]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: obliterate nfs4_state_recovery_ops.renew_lease method]
        moved to nfs4_state_maintenance_ops
    [also undid per-minorversion nfs4_state_recovery_ops here]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b069d94af7785750228287c35f9ce5c463515726
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:43 2009 -0400

    nfs41: schedule async session reset
    
    Define a new session reset state which is set upon a sequence operation error
    in both the sync and async error handlers.
    
    Place all new requests and all but the last outstanding rpc on the
    slot_tbl_waitq. Spawn the recovery thread when the last slot is free.
    Call nfs4_proc_destroy_session, reinitialize the session, call
    nfs4_proc_create_session, clear the session reset state, and wake up the next
    task on the slot_tbl_waitq.
    
    Return the nfs4_proc_destroy_session status to the session reclaimer and
    check for NFS4ERR_BADSESSION and NFS4ERR_DEADSESSION. Other destroy session
    errors should be handled in nfs4_proc_destroy_session where the call can
    be retried with adjusted arguments.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    nfs41: make nfs4_wait_bit_killable public]
        nfs4_wait_bit_killable to be used by NFSv4.1 session recover logic.
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: have create_session work on nfs_client]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: trigger the state manager for session reset]
        Replace the session reset state with the NFS4CLNT_SESSION_SETUP cl_state.
        Place all rpc tasks to sleep on the slot table waitqueue until the slot
        table is drained, then schedule state recovery and wait for it to complete.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: remove nfs41_session_recovery [ch]
    Replaced by using the nfs4_state_manager.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: nfs4_wait_bit_killable only used locally]
    [nfs41: keep nfs4_wait_bit_killable static]
    [nfs41: keep const nfs_server in nfs4_handle_exception]
    [nfs41: remove session parameter from nfs4_find_slot]
    Signed-off-by: Andy Adamson <andros@netapp.com
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: resset the session from nfs41_setup_sequence]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4745e3154bf33048d970d1519703089493988f65
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:42 2009 -0400

    nfs41: kick start nfs41 session recovery when handling errors
    
    Remove checking for any errors that the SEQUENCE operation does not return.
    -NFS4ERR_STALE_CLIENTID, NFS4ERR_EXPIRED, NFS4ERR_CB_PATH_DOWN, NFS4ERR_BACK_CHAN_BUSY, NFS4ERR_OP_NOT_IN_SESSION.
    
    SEQUENCE operation error recovery is very primative, we only reset the session.
    
    Remove checking for any errors that are returned by the SEQUENCE operation, but
    that resetting the session won't address.
    NFS4ERR_RETRY_UNCACHED_REP, NFS4ERR_SEQUENCE_POS,NFS4ERR_TOO_MANY_OPS.
    
    Add error checking for missing SEQUENCE errors that a session reset will
    address.
    NFS4ERR_BAD_HIGH_SLOT, NFS4ERR_DEADSESSION, NFS4ERR_SEQ_FALSE_RETRY.
    
    A reset of the session is currently our only response to a SEQUENCE operation
    error. Don't reset the session on errors where a new session won't help.
    
    Don't reset the session on errors where a new session won't help.
    
    [nfs41: nfs4_async_handle_error update error checking]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: trigger the state manager for session reset]
        Replace session state bit with nfs_client state bit.  Set the
        NFS4CLNT_SESSION_SETUP bit upon a session related error in the sync/async
        error handlers.
    [nfs41: _nfs4_async_handle_error fix session reset error list]
    Sequence operation errors that session reset could help.
    NFS4ERR_BADSESSION
    NFS4ERR_BADSLOT
    NFS4ERR_BAD_HIGH_SLOT
    NFS4ERR_DEADSESSION
    NFS4ERR_CONN_NOT_BOUND_TO_SESSION
    NFS4ERR_SEQ_FALSE_RETRY
    NFS4ERR_SEQ_MISORDERED
    
    Sequence operation errors that a session reset would not help
    
    NFS4ERR_BADXDR
    NFS4ERR_DELAY
    NFS4ERR_REP_TOO_BIG
    NFS4ERR_REP_TOO_BIG_TO_CACHE
    NFS4ERR_REQ_TOO_BIG
    NFS4ERR_RETRY_UNCACHED_REP
    NFS4ERR_SEQUENCE_POS
    NFS4ERR_TOO_MANY_OPS
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41 nfs4_handle_exception fix session reset error list]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [moved nfs41_sequece_call_done code to nfs41: sequence operation]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit eedc020e718b8ce45381383ec66030f09eb02a1e
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:41 2009 -0400

    nfs41: use rpc prepare call state for session reset
    
    [nfs41: change nfs4_restart_rpc argument]
    [nfs41: check for session not minorversion]
    [nfs41: trigger the state manager for session reset]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [always define nfs4_restart_rpc]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit aae2006e9b0c294114915c13022fa348e1a88023
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:40 2009 -0400

    nfs41: sunrpc: Export the call prepare state for session reset
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c3fad1b1aaf850bf692642642ace7cd0d64af0a3
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:39 2009 -0400

    nfs41: add session reset to state manager
    
    Move the code to reset a session from the session_reclaimer to the
    nfs4_state_manager.  Destroy the session, and create a new one. Treat
    NFS4ERR_BADSESSION and NFS4ERR_DEADSESSION as a successful
    nfs4_proc_destroy_session. Signal nfs4_proc_create_session that this is a
    session reset so that the session slot table is re-used.
    
    If the clientid is stale, set both NFS4CLNT_LEASE_EXPIRED and
    NFS4CLNT_SESSION_SETUP bits and retry.
    
    Use a switch statement in nfs4_session_recovery_handle_error for future
    patche which will add handling for other errors.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    
    [nfs41: session reset in nfs4_recovery_handle_error]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: reset session on nfs4_do_reclaim session reset error]
        If nfs4_do_reclaim gets a session reset error, nfs4_recovery_handle_error
        will set the NFS4CLNT_SESSION_SETUP bit, and the state manager should
        continue processing to reset the session.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [move nfs4_proc_destroy_session declaration here]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 76db6d9500caeaa774a3e32a997eba30bbdc176b
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:38 2009 -0400

    nfs41: add session setup to the state manager
    
    At mount, nfs_alloc_client sets the cl_state NFS4CLNT_LEASE_EXPIRED bit
    and nfs4_alloc_session sets the NFS4CLNT_SESSION_SETUP bit, so both bits are
    set when nfs4_lookup_root calls nfs4_recover_expired_lease which schedules
    the nfs4_state_manager and waits for it to complete.
    
    Place the session setup after the clientid establishment in nfs4_state_manager
    so that the session is setup right after the clientid has been established
    without rescheduling the state manager.
    
    Unlike nfsv4.0, the nfs_client struct is not ready to use until the session
    has been established.  Postpone marking the nfs_client struct to NFS_CS_READY
    until after a successful CREATE_SESSION call so that other threads cannot use
    the client until the session is established.
    
    If the EXCHANGE_ID call fails and the session has not been setup (the
    NFS4CLNT_SESSION_SETUP bit is set), mark the client with the error and return.
    
    If the session setup CREATE_SESSION call fails with NFS4ERR_STALE_CLIENTID
    which could occur due to server reboot or network partition inbetween the
    EXCHANGE_ID and CREATE_SESSION call, reset the NFS4CLNT_LEASE_EXPIRED and
    NFS4CLNT_SESSION_SETUP bits and try again.
    
    If the CREATE_SESSION call fails with other errors, mark the client with
    the error and return.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    
    [nfs41: NFS_CS_SESSION_SETUP cl_cons_state for back channel setup]
      On session setup, the CREATE_SESSION reply races with the server back channel
      probe which needs to succeed to setup the back channel. Set a new
      cl_cons_state NFS_CS_SESSION_SETUP just prior to the CREATE_SESSION call
      and add it as a valid state to nfs_find_client so that the client back channel
      can find the nfs_client struct and won't drop the server backchannel probe.
      Use a new cl_cons_state so that NFSv4.0 back channel behaviour which only
      sets NFS_CS_READY is unchanged.
      Adjust waiting on the nfs_client_active_wq accordingly.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    
    [nfs41: rename NFS_CS_SESSION_SETUP to NFS_CS_SESSION_INITING]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: set NFS_CL_SESSION_INITING in alloc_session]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: move session setup into a function]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [moved nfs4_proc_create_session declaration here]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ac72b7b3b3263ce64d55094eac1d1bde5f34e64a
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:37 2009 -0400

    nfs41: reset the session slot table
    
    Separated from nfs41: schedule async session reset
    
    Do not kfree the session slot table upon session reset, just re-initialize it.
    Add a boolean to nfs4_proc_create_session to inidicate if this is a
    session reset or a session initialization.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fc01cea963a246742ff15e118ce5259e3091352c
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:36 2009 -0400

    nfs41: sequence operation
    
    Implement the sequence operation conforming to
    http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
    
    Check returned sessionid, slotid and slot sequenceid in decode_sequence.
    
    If the server returns different values for sessionID, slotID or slot sequence
    number than what was sent, the server is looney tunes.
    
    Pass the sequence operation status to nfs41_sequence_done in order to
    determine when to increment the slot sequence ID.
    
    Free slot is separated from sequence done.
    
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Andy Adamson<andros@umich.edu>
    [nfs41: sequence res use slotid]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: deref slot table in decode_sequence only for minorversion!=0]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_call_sync]
    [nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
    [nfs41: return ESERVERFAULT in decode_sequence]
    [no sr_session, no sr_flags]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use nfs4_call_sync_sequence to renew session lease]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove nfs4_call_sync_sequence forward definition]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: use struct nfs_client for nfs41_proc_async_sequence]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41 nfs41_sequence_call_done update error checking]
    [nfs41 nfs41_sequence_done update error checking]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove switch on error from nfs41_sequence_call_done]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8328d59f380e26477b9c1ede99e33d021365bcd1
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:35 2009 -0400

    nfs41: enable nfs_client only nfs4_async_handle_error
    
    The session is per struct nfs_client, not per nfs_server. Allow the handler
    to be called with no nfs_server which simplifies the nfs4_proc_async_sequence session renewal call and will let it be used by pnfs file layout data servers.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0f3e66c6a6cae479028d31198288e524fe5ff90d
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:34 2009 -0400

    nfs41: destroy_session operation
    
    Implement the destroy_session operation conforming to
    http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
    
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove extraneous rpc_clnt pointer]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41; NFS_CS_READY required for DESTROY_SESSION]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    [nfs41: fix encode_destroy_session's xdr Xcoding pointer type]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 96b09e024fedf0a6604c8c688a3994d5ed991434
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:33 2009 -0400

    nfs41: use session attributes for rsize and wsize
    
    Set the mount points rsize and wsize to the negotiated session fore channel
    maximum response and requeset size. These values will be bound checked in
    nfs_server_set_fsinfo.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [move nfs4_session_set_rwsize into CONFIG_NFS_V4]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8d35301d7db4165f2430c428865f7b0add47615d
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:32 2009 -0400

    nfs41: verify session channel attribues
    
    Invalidate the session if the server returns invalid fore or back channel
    attributes.
    
    Use a KERN_WARNING to report the fatal session estabishment error.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [refactor nfs4_verify_channel_attrs]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fc931582c260e53ca5ca23bd70ccc9b2265cca9f
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:31 2009 -0400

    nfs41: create_session operation
    
    Implement the create_session operation conforming to
    http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
    
    Set the real fore channel max operations to preserve server resources.
    Note: If the server returns < NFS4_MAX_OPS, the client will very soon
    get an NFS4ERR_TOO_MANY_OPS. A later patch will handle this.
    
    Set the max_rqst_sz and max_resp_sz to PAGE_SIZE - we preallocate the buffers.
    
    Set the back channel max_resp_sz_cached to zero to force the client to
    always set csa_cachethis to FALSE because the current implementation
    of the back channel DRC only supports caching the CB_SEQUENCE operation.
    
    The client back channel server supports one slot, and desires 2 operations
    per compound.
    
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove extraneous rpc_clnt pointer]
    Use the struct nfs_client cl_rpcclient.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_init_channel_attrs, just use nfs41_create_session_args]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use rsize and wsize for session channel attributes]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: set channel max operations]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: set back channel attributes]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: obliterate nfs4_adjust_channel_attrs]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: have create_session work on nfs_client]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: move CONFIG_NFS_V4_1 endif]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    [moved nfs4_init_slot_table definition here]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use kcalloc to allocate slot table]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    [nfs41: fix Xcode_create_session's xdr Xcoding pointer type]
    [nfs41: refactor decoding of channel attributes]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 2050f0cc0703aab7cee798b3cb47037754f368bc
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:30 2009 -0400

    nfs41: get_lease_time
    
    get_lease_time uses the FSINFO rpc operation to
    get the lease time attribute.
    
    nfs4_get_lease_time() is only called from the state manager on session setup
    so don't recover from clientid or sequence level errors.
    
    We do need to recover from NFS4ERR_DELAY or NFS4ERR_GRACE.
    Use NFS4_POLL_RETRY_MIN - the Linux server returns NFS4ERR_DELAY when an
    upcall is needed to resolve an uncached export referenced by a file handle.
    
    [nfs41: sequence res use slotid]
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove extraneous rpc_clnt pointer]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: have get_lease_time work on nfs_client]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: get_lease_time recover from NFS4ERR_DELAY]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    [define nfs4_get_lease_time_{args,res}]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 99fe60d062cfecf382c036065b3278b82b6c5eff
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:29 2009 -0400

    nfs41: exchange_id operation
    
    Implement the exchange_id operation conforming to
    http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
    
    Unlike NFSv4.0, NFSv4.1 requires machine credentials. RPC_AUTH_GSS machine
    credentials will be passed into the kernel at mount time to be available for
    the exchange_id operation.
    
    RPC_AUTH_UNIX root mounts can use the UNIX root credential. Store the root
    credential in the nfs_client struct.
    
    Without a credential, NFSv4.1 state renewal fails.
    
    [nfs41: establish clientid via exchange id only if cred != NULL]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfsd41: move nfstime4 from under CONFIG_NFS_V4_1]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: do not wait a lease time in exchange id]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    [nfs41: Ignoring impid in decode_exchange_id is missing a READ_BUF]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: fix Xcode_exchange_id's xdr Xcoding pointer type]
    [nfs41: get rid of unused struct nfs41_exchange_id_res members]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 938e10109115a71cc69d475122f21cf75e5046cd
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:28 2009 -0400

    nfs41 delegreturn sequence setup done support
    
    Separate delegreturn calls from nfs41: sequence setup/done support
    
    Implement the delegreturn rpc_call_prepare method for
    asynchronuos nfs rpcs, call nfs41_setup_sequence from
    respective rpc_call_validate_args methods.
    
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 21d9a851aaa4161a9fddde720594659f3dae7fdd
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:27 2009 -0400

    nfs41 commit sequence setup done support
    
    Separate commit calls from nfs41: sequence setup/done support
    
    Implement the commit rpc_call_prepare method for
    asynchronuos nfs rpcs, call nfs41_setup_sequence from
    respective rpc_call_validate_args methods.
    
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Support sessions with O_DIRECT.]
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: separate free slot from sequence done]
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit def6ed7ef45ed19c3d6ca765f3bfdff1fe4c6bba
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:26 2009 -0400

    nfs41 write sequence setup done support
    
    Separate write calls from nfs41: sequence setup/done support
    
    Implement the write rpc_call_prepare method for
    asynchronuos nfs rpcs, call nfs41_setup_sequence from
    respective rpc_call_validate_args methods.
    
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson <andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [move the nfs4_sequence_free_slot call in nfs_readpage_retry from]
    [nfs41: separate free slot from sequence done
    Signed-off-by: Andy Adamson <andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Support sessions with O_DIRECT.]
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f11c88af26453aee2823a1fd9120d0cd8dae7b9a
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:25 2009 -0400

    nfs41: read sequence setup/done support
    
    Implement the read rpc_call_prepare method for
    asynchronuos nfs rpcs, call nfs41_setup_sequence from
    respective rpc_call_validate_args methods.
    
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson <andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [move the nfs4_sequence_free_slot call in nfs_readpage_retry from]
    [nfs41: separate free slot from sequence done]
    [remove nfs_readargs.nfs_server, use calldata->inode instead]
    Signed-off-by: Andy Adamson <andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Support sessions with O_DIRECT]
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 472cfbd9b97be210a9b61ac1c6a774cd456ea9d2
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:24 2009 -0400

    nfs41: unlink sequence setup/done support
    
    Implement the rpc_call_prepare methods for
    asynchronuos nfs rpcs, call nfs41_setup_sequence from
    respective rpc_call_validate_args methods.
    
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: separate free slot from sequence done]
    [nfs41: sequence res use slotid]
    [nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a893693c151433a1375060ecb13419080426bc08
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:23 2009 -0400

    nfs41: locku sequence setup/done support
    
    Separate nfs4_locku calls from nfs41: sequence setup/done support
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson <andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 66179efee31f431ab538016b4ac05edaf87525dc
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:22 2009 -0400

    nfs41: lock sequence setup/done support
    
    Separate nfs4_lock calls from nfs41: sequence setup/done support
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    [use nfs4_sequence_done_free_slot]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d898528cdb338b145c71049c3cb7b1dfa542a48a
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:21 2009 -0400

    nfs41: open sequence setup/done support
    
    Separate nfs4_open calls from nfs41: sequence setup/done support
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    [use nfs4_sequence_done_free_slot]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 19ddab06ed923d27339b8009d37b0ab3de93cadf
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:20 2009 -0400

    nfs41: close sequence setup/done support
    
    Separate nfs4_close calls from nfs41: sequence setup/done support
    Call nfs4_sequence_done from respective rpc_call_done methods.
    
    Note that we need to pass a pointer to the nfs_server in calls data
    for passing on to nfs4_sequence_done.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: client data server write validate and release]
    Signed-off-by: Andy Adamson<andros@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: separate free slot from sequence done]
    [nfs41: sequence res use slotid]
    [nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 69ab40c4c3b9622232e31e0ee145875a2853c113
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:19 2009 -0400

    nfs41: nfs41_call_sync_done
    
    Implement nfs4.1 synchronous rpc_call_done method
    that essentially just calls nfs4_sequence_done, that turns
    around and calls nfs41_sequence_done for minorversion1 rpcs.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: check for session not minorversion]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [move adding nfs4_sequence_free_slot from nfs41-separate-free-slot-from-sequence-done]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs41_call_sync_data use nfs_client not nfs_server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b0df806c0f9d61e5fcfdb0f4e606e1a59303aaa6
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:18 2009 -0400

    nfs41: nfs41_sequence_done
    
    Handle session level errors, update slot sequence id and
    sessions bookeeping, free slot.
    
    [nfs41: sequence res use slotid]
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: check for session not minorversion]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: bail out early out of nfs41_sequence_done if !res->sr_session]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [move nfs4_sequence_done from nfs41: nfs41_call_sync_done]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [move nfs4_sequence_free_slot from nfs41: separate free slot from sequence done]
        Don't free the slot until after all rpc_restart_calls have completed.
        Session reset will require more work.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [moved reset sr_slotid to nfs41_sequence_free_slot]
    [free slot also on unexpectecd error]
    [remove seq_res.sr_session member, use nfs_client's instead]
    [ditch seq_res.sr_flags until used]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [look at sr_slotid for bailing out early from nfs41_sequence_done]
    [nfs41: rpc_wake_up_next if sessions slot was not consumed.]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove unused error checking in nfs41_sequence_done]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: remove nfs4_has_session check in nfs41_sequence_done]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: remove nfs_client pointer check]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 13615871cdf8e8263626a817c350c6978a6483fe
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:17 2009 -0400

    nfs41: nfs41_sequence_free_slot
    
    [from nfs41: separate free slot from sequence done]
    
    Don't free the slot until after all rpc_restart_calls have completed.
    Session reset will require more work.
    
    As noted by Trond, since we're using rpc_wake_up_next rather than
    rpc_wake_up() we must always wake up the next task in the queue
    either by going through nfs4_free_slot, or just calling
    rpc_wake_up_next if no slot is to be freed.
    
    [nfs41: sequence res use slotid]
    [nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
    [got rid of nfs4_sequence_res.sr_session, use nfs_client.cl_session instead]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: rpc_wake_up_next if sessions slot was not consumed.]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_sequence_free_slot use nfs_client for data server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e2c4ab3ce2ecc527672bd7e29a594c50d3ec0477
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:16 2009 -0400

    nfs41: free slot
    
    Free a slot in the slot table.
    
    Mark the slot as free in the bitmap-based allocation table
    by clearing a bit corresponding to the slotid.
    
    Update lowest_free_slotid if freed slotid is lower than that.
    Update highest_used_slotid.  In the case the freed slotid
    equals the highest_used_slotid, scan downwards for the next
    highest used slotid using the optimized fls* functions.
    
    Finally, wake up thread waiting on slot_tbl_waitq for a free slot
    to become available.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: free slot use slotid]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use find_first_zero_bit for nfs4_find_slot]
        While at it, obliterate lowest_free_slotid and fix-up related comments.
        As per review comment 21/85.
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use __clear_bit for nfs4_free_slot]
        While at it, fix-up function comment.
        Part of review comment 22/85.
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: use find_last_bit in nfs4_free_slot to determine highest used slot.]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: rpc_sleep_on slot_tbl_waitq must be called under slot_tbl_lock]
        Otherwise there's a race (we've hit) with nfs4_free_slot where
        nfs41_setup_sequence sees a full slot table, unlocks slot_tbl_lock,
        nfs4_free_slots happen concurrently and call rpc_wake_up_next
        where there's nobody to wake up yet, context goes back to
        nfs41_setup_sequence which goes to sleep when the slot table
        is actually empty now and there's no-one to wake it up anymore.
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fbcd4abcb3841f85578985c09c6df85aa41b0ae8
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:15 2009 -0400

    nfs41: setup_sequence method
    
    Allocate a slot in the session slot table and set the sequence op arguments.
    
    Called at the rpc prepare stage.
    
    Add a status to nfs41_sequence_res, initialize it to one so that we catch
    rpc level failures which do not go through decode_sequence which sets
    the new status field.
    
    Note that upon an rpc level failure, we don't know if the server processed the
    sequence operation or not. Proceed as if the server did process the sequence
    operation.
    
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    [nfs41: sequence args use slotid]
    [nfs41: find slot return slotid]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
    As per 11-14-08 review
    [move extern declaration from nfs41: sequence setup/done support]
    [removed sa_session definition, changed sa_cache_this into a u8 to reduce footprint]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: rpc_sleep_on slot_tbl_waitq must be called under slot_tbl_lock]
        Otherwise there's a race (we've hit) with nfs4_free_slot where
        nfs41_setup_sequence sees a full slot table, unlocks slot_tbl_lock,
        nfs4_free_slots happen concurrently and call rpc_wake_up_next
        where there's nobody to wake up yet, context goes back to
        nfs41_setup_sequence which goes to sleep when the slot table
        is actually empty now and there's no-one to wake it up anymore.
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 510b81756f18922a4c5b555e8145f4fed5beb569
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:14 2009 -0400

    nfs41: find slot
    
    Find a free slot using bitmap-based allocation.
    Use the optimized ffz function to find a zero bit
    in the bitmap that indicates a free slot, starting
    the search from the 'lowest_free_slotid' position.
    
    If found, mark the slot as used in the bitmap, get
    the slot's slotid and seqid, and update max_slotid
    to be used by the SEQUENCE operation.
    
    Also, update lowest_free_slotid for next search.
    
    If no free slot was found the caller has to wait
    for a free slot (outside the scope of this function)
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: find slot return slotid]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [use find_first_zero_bit for nfs4_find_slot as per review comment 21/85.]
    [use NFS4_MAX_SLOT_TABLE rather than NFS4_NO_SLOT]
    [nfs41: rpc_sleep_on slot_tbl_waitq must be called under slot_tbl_lock]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ce5039c1be1fd04c2d9b1af80d41a6d003f2e20c
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:13 2009 -0400

    nfs41: nfs4_setup_sequence
    
    Perform the nfs4_setup_sequence in the rpc_call_prepare state.
    
    If a session slot is not available, we will rpc_sleep_on the
    slot wait queue leaving the tk_action as rpc_call_prepare.
    
    Once we have a session slot, hang on to it even through rpc_restart_calls.
    Ensure the nfs41_sequence_res sr_slot pointer is NULL before rpc_run_task is
    called as nfs41_setup_sequence will only find a new slot if it is NULL.
    
    A future patch will call free slot after any rpc_restart_calls, and handle the
    rpc restart that result from a sequence operation error.
    
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    [nfs41: sequence res use slotid]
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: simplify nfs4_call_sync]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_call_sync]
    [nfs41: check for session not minorversion]
    [nfs41: remove rpc_message from nfs41_call_sync_args]
    [moved NFS4_MAX_SLOT_TABLE logic into nfs41_setup_sequence]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs41_call_sync_data use nfs_client not nfs_server]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: expose nfs4_call_sync_session for lease renewal]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: remove unnecessary return check]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9b7b9fcc9c124b8a2a079f748239ce9b7a8d8304
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:11 2009 -0400

    nfs41: xdr {encode,decode}_sequence
    
    Implement stubs for encode and decode sequence, defined as no-ops when
    CONFIG_NFS_V4_1 is not defined.
    Add the nfsv41 encode and decode sizes. Add encode_sequence to all
    nfs4_enc_* routines and decode_sequence to all nfs4_dec_* routines as required
    by v41.
    
    [was nfs41: minorversion support for xdr]
    [added nfs_client argument to encode_sequence so not to use sequence_args to pass sa_session]
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 66cc042970f7077c66be65a780eb3a60a9bcbf0b
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:10 2009 -0400

    nfs41: encode minorversion in compound header
    
    Signed-off-by: Andy Adamdon <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: pass *session in seq_args and seq_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 28f566942c6b1d929f5e240e69e7081b77b238d3
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:09 2009 -0400

    NFS: use dynamically computed compound_hdr.replen for xdr_inline_pages offset
    
    As Trond suggested, rather than passing a constant to xdr_inline_pages,
    keep a running count of the expected reply bytes.  In preparation for
    nfs41, where additional op sequence are expteced when talking to nfs41
    servers.
    
    [NFS: cb_compoundhdr.replen is in words not bytes]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: get fs_locations replen before encoding the GETATTR]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: get getacl replen before encoding the GETATTR]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dadf0c2767ce7772fc4ff82044f3ba5823e5b79f
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:08 2009 -0400

    NFS: update hdr->replen for every encode op
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0c4e8c187758258ec58842384fe6a99cf1ce16c7
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:07 2009 -0400

    NFS: define and initialize compound_hdr.replen
    
    replen holds the running count of expected reply bytes.
    repl will then be used by encoding routines for xdr_inline_pages offset
    after which data bytes are to be received directly into the xdr
    buffer pages.
    
    NOTE: According to the nfsv4 and v4.1 RFCs, the replied tag SHOULD be the same
    is the one sent, but this is not required as a MUST for the server to do so.
    The server may screw us if it replies a tag of a different length in the
    compound result.
    
    [NFS: cb_compoundhdr.replen is in words not bytes]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6ce183919b4a09289cb0fe4fce960a9faa1e7c6b
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:06 2009 -0400

    NFS: use decode_change_info_maxsz for xdr maxsz calculations
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5f7dbd5c752d88310d8fe1feedefd5c6496eff48
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:05 2009 -0400

    nfs41: set up seq_res.sr_slotid
    
    Initialize nfs4_sequence_res sr_slotid to NFS4_MAX_SLOT_TABLE.
    
    [was nfs41: sequence res use slotid]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [pulled definition of struct nfs4_sequence_res.sr_slotid to here]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f3752975caa716709c5ea0b0820b86111d921df4
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:04 2009 -0400

    nfs41: nfs41: pass *session in seq_args and seq_res
    
    To be used for getting the rpc's minorversion and for nfs41 xdr
    {en,de}coding of the sequence operation.
    Reset the seq session ptrs for minorversion=0 rpc calls.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cccef3b96a4759ae0790452280c00ea505412157
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:22:03 2009 -0400

    nfs41: introduce nfs4_call_sync
    
    Use nfs4_call_sync rather than rpc_call_sync to provide
    for a nfs41 sessions-enabled interface for sessions manipulation.
    
    The nfs41 rpc logic uses the rpc_call_prepare method to
    recover and create the session, as well as selecting a free slot id
    and the rpc_call_done to free the slot and update slot table
    related metadata.
    
    In the coming patches we'll add rpc prepare and done routines
    for setting up the sequence op and processing the sequence result.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: nfs4_call_sync]
    As per 11-14-08 review.
    Squash into "nfs41: introduce nfs4_call_sync" and "nfs41: nfs4_setup_sequence"
    Define two functions one for v4 and one for v41
    add a pointer to struct nfs4_client to the correct one.
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [added BUG() in _nfs4_call_sync_session if !CONFIG_NFS_V4_1]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: check for session not minorversion]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [group minorversion specific stuff together]
    Signed-off-by: Alexandros Batsakis <Alexandros.Batsakis@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [nfs41: fixup nfs4_clear_client_minor_version]
    [introduce nfs4_init_client_minor_version() in this patch]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [cleaned-up patch: got rid of nfs_call_sync_t, dprintks, cosmetics, extra server defs]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 22958463d5dca8548e19430779f379e66fd6e4a4
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:02 2009 -0400

    nfs41: use nfs4_fs_locations_res
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [find nfs4_fs_locations_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 73c403a9a93743b068103c13c05ed136dc687d05
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:01 2009 -0400

    nfs41: use nfs4_setaclres
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [define nfs_setaclres]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9e9ecc03d6b37a5d85e16b357751e3b341de0fef
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:22:00 2009 -0400

    NFS: get rid of unused xdr decode_setattr(, res) argument
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 663c79b3cd8f5fe21fe7d7565fec0072e3234ddc
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:59 2009 -0400

    nfs41: use nfs4_getaclres
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: embed resp_len in nfs_getaclres]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d45b2989a7956ae9e71d584ceac942278c0371c7
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:58 2009 -0400

    nfs41: use nfs4_pathconf_res
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [define nfs4_pathconf_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3dda5e434721f942870ee30bc6103761618d410f
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:57 2009 -0400

    nfs41: use nfs4_fsinfo_res
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [define nfs4_fsinfo_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 24ad148a0ff74b1e703a8bc5b3e0793dc7d4e3a9
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:56 2009 -0400

    nfs41: use nfs4_statfs_res
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [define nfs4_statfs_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f50c7000817e7cb4e676ac5d911a82c0f3fd226f
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:55 2009 -0400

    nfs41: use nfs4_readlink_res
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [define nfs4_readlink_res]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 43652ad55342d9146d8035932101a5814b22315a
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:54 2009 -0400

    nfs41: use nfs4_server_caps_arg
    
    In preparation for nfs41 sequence processing.
    
    Signed-off-by: Andy Admason <andros@netapp.com>
    [define nfs4_server_caps_arg]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 557134a39c8d2ab79d8b8d53438e03e29feb5ec4
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Apr 1 09:21:53 2009 -0400

    nfs41: sessions client infrastructure
    
    NFSv4.1 Sessions basic data types, initialization, and destruction.
    
    The session is always associated with a struct nfs_client that holds
    the exchange_id results.
    
    Signed-off-by: Rahul Iyer <iyer@netapp.com>
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [remove extraneous rpc_clnt pointer, use the struct nfs_client cl_rpcclient.
    remove the rpc_clnt parameter from nfs4 nfs4_init_session]
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Use the presence of a session to determine behaviour instead of the
    minorversion number.]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [constified nfs4_has_session's struct nfs_client parameter]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Rename nfs4_put_session() to nfs4_destroy_session() and call it from nfs4_free_client() not nfs4_free_server().
    Also get rid of nfs4_get_session() and the ref_count in nfs4_session struct as keeping track of nfs_client should be sufficient]
    Signed-off-by: Alexandros Batsakis <Alexandros.Batsakis@netapp.com>
    [nfs41: pass rsize and wsize into nfs4_init_session]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [separated out removal of rpc_clnt parameter from nfs4_init_session ot a
     patch of its own]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Pass the nfs_client pointer into nfs4_alloc_session]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: don't assign to session->clp->cl_session in nfs4_destroy_session]
    [nfs41: fixup nfs4_clear_client_minor_version]
    [introduce nfs4_clear_client_minor_version() in this patch]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Refactor nfs4_init_session]
        Moved session allocation into nfs4_init_client_minor_version, called from
        nfs4_init_client.
        Leave rwise and wsize initialization in nfs4_init_session, called from
        nfs4_init_server.
        Reverted moving of nfs_fsid definition to nfs_fs_sb.h
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Move NFS4_MAX_SLOT_TABLE define from under CONFIG_NFS_V4_1]
    [Fix comile error when CONFIG_NFS_V4_1 is not set.]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [moved nfs4_init_slot_table definition to "create_session operation"]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: alloc session with GFP_KERNEL]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9ff71c3a9827b99699510076dffa0bbe7c36bfd4
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:52 2009 -0400

    nfs41: client xdr definitions
    
    Define stubs for sequence args and res data structures and embed
    them in all other nfs4 and nfs41 xdr types.  They are needed for
    sending any op in a nfs41 compound rpc.
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    [moved new args/res definitions away, to where they're first used]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c2e713dd83dcabb2ae951ea572e7de68c96e2d48
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:51 2009 -0400

    nfs41: translate NFS4ERR_MINOR_VERS_MISMATCH to EPROTONOSUPPORT
    
    To be returned to the mount command when trying to mount a v4 server
    using minorversion 1.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5aae4a9ae0dd55409a42ca61b82ef1f5a840091e
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:50 2009 -0400

    nfs41: Use mount minorversion option
    
    Use the mount minorversion option to initialize the nfs_client cl_minorversion
    and match it in nfs_match_client() when looking up a nfs_client.
    
    [nfs41: remove ifdefs around nfs_client_initdata.minorversion]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 94a417f3d7a02478a2d7842e693a61339fb54ea4
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 1 09:21:49 2009 -0400

    nfs41: nfs_client.cl_minorversion
    
    This field is set to the nfsv4 minor version for this mount.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    
    Note: This patch sets the referral to the same minorversion as the
    current mount. Revisit in future patch.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [removed cl_minorversion assignment in nfs_set_client]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [always define nfs_client.cl_minorversion]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3fd5be9e19921a89d9ed78d6a708a379a6c3c76a
Author: Mike Sager <sager@netapp.com>
Date:   Wed Apr 1 09:21:48 2009 -0400

    nfs41: add mount command option minorversion
    
    mount -t nfs4 -o minorversion=[0|1] specifies whether to use 4.0 or 4.1.
    By default, the minorversion is set to 0.
    
    Signed-off-by: Mike Sager <sager@netapp.com>
    [set default minorversion to 0 as per Trond and SteveD's request]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 44549dff82753b6a5ffabcefeead34be63e95d96
Author: Mike Sager <sager@netapp.com>
Date:   Wed Apr 1 09:21:47 2009 -0400

    nfs41: define NFS4_MAX_MINOR_VERSION based on CONFIG_NFS_V4_1
    
    If 4.1 isn't supported, NFS4_MAX_MINOR_VERSION will be 0.
    
    Signed-off-by: Mike Sager <sager@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1efae38140546db403845d628db9f2d608caa87e
Author: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Date:   Wed Apr 1 09:21:46 2009 -0400

    nfs41: Add Kconfig symbols for NFSv4.1
    
    Added CONFIG_NFS_V4_1 and made it depend upon CONFIG_NFS_V4 and EXPERIMENTAL.
    Indicate that CONFIG_NFS_V4_1 is for NFS developers at the moment
    
    At the moment we're expecting folks trying out nfs41 to
    actively participate in the development process by helping us
    debug issues and ideally send patches to fix problems.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
