From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull NFS client changes...
Date: Tue, 11 Jan 2011 18:08:28 -0500
Message-ID: <1294787308.10037.48.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12490 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752122Ab1AKXIb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Jan 2011 18:08:31 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "nfs-for-2.6.38" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git nfs-fo=
r-2.6.38

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/lockd/Makefile               |    6 +-
 fs/lockd/clnt4xdr.c             |  605 ++++++++
 fs/lockd/clntlock.c             |    4 +-
 fs/lockd/clntproc.c             |   18 +-
 fs/lockd/clntxdr.c              |  627 +++++++++
 fs/lockd/host.c                 |  409 ++++---
 fs/lockd/mon.c                  |  110 +-
 fs/lockd/svc4proc.c             |   20 +-
 fs/lockd/svclock.c              |   34 +-
 fs/lockd/svcproc.c              |   28 +-
 fs/lockd/xdr.c                  |  287 ----
 fs/lockd/xdr4.c                 |  255 ----
 fs/nfs/callback.c               |   83 +-
 fs/nfs/callback.h               |   59 +-
 fs/nfs/callback_proc.c          |  326 +++--
 fs/nfs/callback_xdr.c           |  143 ++-
 fs/nfs/client.c                 |  302 +++--
 fs/nfs/delegation.c             |  362 ++++--
 fs/nfs/delegation.h             |    1 +
 fs/nfs/dir.c                    |   72 +-
 fs/nfs/idmap.c                  |    2 +-
 fs/nfs/inode.c                  |    3 +-
 fs/nfs/internal.h               |   19 +-
 fs/nfs/mount_clnt.c             |   83 +-
 fs/nfs/nfs2xdr.c                | 1294 ++++++++++++------
 fs/nfs/nfs3xdr.c                | 2889 ++++++++++++++++++++++++++++---=
--------
 fs/nfs/nfs4_fs.h                |   13 +-
 fs/nfs/nfs4filelayout.c         |    6 +-
 fs/nfs/nfs4proc.c               |  188 ++-
 fs/nfs/nfs4renewd.c             |   11 +-
 fs/nfs/nfs4state.c              |  293 +++--
 fs/nfs/nfs4xdr.c                | 1426 +++++++++----------
 fs/nfs/pagelist.c               |    7 +-
 fs/nfs/pnfs.c                   |  524 +++++---
 fs/nfs/pnfs.h                   |   76 +-
 fs/nfs/proc.c                   |    5 +-
 fs/nfs/super.c                  |   18 +-
 fs/nfs/unlink.c                 |    2 +-
 fs/nfsd/nfs4callback.c          |  686 ++++++----
 include/linux/lockd/debug.h     |   10 -
 include/linux/lockd/lockd.h     |    6 +-
 include/linux/nfs3.h            |    3 +
 include/linux/nfs4.h            |    8 +-
 include/linux/nfs_fs_sb.h       |   15 +-
 include/linux/nfs_xdr.h         |    6 +-
 include/linux/sunrpc/auth.h     |    8 +-
 include/linux/sunrpc/bc_xprt.h  |   15 +-
 include/linux/sunrpc/clnt.h     |    4 +-
 include/linux/sunrpc/svc.h      |    2 +-
 include/linux/sunrpc/svc_xprt.h |    1 +
 include/linux/sunrpc/xdr.h      |   14 +-
 net/sunrpc/auth.c               |   28 +-
 net/sunrpc/auth_gss/auth_gss.c  |   44 +-
 net/sunrpc/bc_svc.c             |    2 +-
 net/sunrpc/clnt.c               |   21 +-
 net/sunrpc/rpc_pipe.c           |    2 +-
 net/sunrpc/rpcb_clnt.c          |  147 +--
 net/sunrpc/svc.c                |   36 +-
 net/sunrpc/svcsock.c            |  106 ++-
 net/sunrpc/xdr.c                |  155 ++-
 60 files changed, 7852 insertions(+), 4077 deletions(-)

commit 357f54d6b38252737116a6d631f6ac28ded018ed
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Dec 14 10:11:57 2010 -0500

    NFS fix the setting of exchange id flag
   =20
    Indicate support for referrals. Do not set any PNFS roles. Check th=
e flags
    returned by the server for validity. Do not use exchange flags from=
 an old
    client ID instance when recovering a client ID.
   =20
    Update the EXCHID4_FLAG_XXX set to RFC 5661.
   =20
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6650239a4b01077e80d5a4468562756d77afaa59
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jan 8 17:45:38 2011 -0500

    NFS: Don't use vm_map_ram() in readdir
   =20
    vm_map_ram() is not available on NOMMU platforms, and causes troubl=
e
    on incoherrent architectures such as ARM when we access the page da=
ta
    through both the direct and the virtual mapping.
   =20
    The alternative is to use the direct mapping to access page data
    for the case when we are not crossing a page boundary, but to copy
    the data into a linear scratch buffer when we are accessing data
    that spans page boundaries.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Tested-by: Marc Kleine-Budde <mkl@pengutronix.de>
    Cc: stable@kernel.org  [2.6.37]

commit d035c36c58dd9183ad6aa7875dea89893faedb55
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 21 10:45:27 2010 -0500

    NFSv4: Ensure continued open and lockowner name uniqueness
   =20
    In order to enable migration support, we will want to move some of =
the
    structures that are subject to migration into the struct nfs_server=
=2E
    In particular, if we are to move the state_owner and state_owner_id=
 to
    being a per-filesystem structure, then we should label the resultin=
g
    open/lock owners with a per-filesytem label to ensure global unique=
ness.
   =20
    This patch does so by adding the super block s_dev to the open/lock=
 owner
    name.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d3978bb325510f0a26ebd92f211b36c5f98b2306
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 24 01:33:04 2010 +0000

    NFS: Move cl_delegations to the nfs_server struct
   =20
    Delegations are per-inode, not per-nfs_client.  When a server file
    system is migrated, delegations on the client must be moved from th=
e
    source to the destination nfs_server.  Make it easier to manage a
    mount point's delegation list across a migration event by moving th=
e
    list to the nfs_server struct.
   =20
    Clean up: I added documenting comments to public functions I change=
d
    in this patch.  For consistency I added comments to all the other
    public functions in fs/nfs/delegation.c.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dda4b225623f316335052828c24a16e2da313f8f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 24 01:32:54 2010 +0000

    NFS: Introduce nfs_detach_delegations()
   =20
    Clean up:  Refactor code that takes clp->cl_lock and calls
    nfs_detach_delegations_locked() into its own function.
   =20
    While we're changing the call sites, get rid of the second paramete=
r
    and the logic in nfs_detach_delegations_locked() that uses it, sinc=
e
    callers always set that parameter of nfs_detach_delegations_locked(=
)
    to NULL.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 24d292b894273495f9664bb495e575f8cb7e8cac
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 24 01:32:43 2010 +0000

    NFS: Move cl_state_owners and related fields to the nfs_server stru=
ct
   =20
    NFSv4 migration needs to reassociate state owners from the source t=
o
    the destination nfs_server data structures.  To make that easier, m=
ove
    the cl_state_owners field to the nfs_server struct.  cl_openowner_i=
d
    and cl_lockowner_id accompany this move, as they are used in
    conjunction with cl_state_owners.
   =20
    The cl_lock field in the parent nfs_client continues to protect all
    three of these fields.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fca5238ef3232cd0cf4bf0457e751b3bb20912a9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 24 01:32:32 2010 +0000

    NFS: Allow walking nfs_client.cl_superblocks list outside client.c
   =20
    We're about to move some fields from struct nfs_client to struct
    nfs_server.  There is a many-to-one relationship between nfs_server=
s
    and nfs_clients.  After these fields are moved to the nfs_server
    struct, to visit all of the data in these fields that is owned by o=
ne
    nfs_client, code will need to visit each nfs_server on the
    cl_superblocks list for that nfs_client.
   =20
    To serialize changes to the cl_superblocks list during these little
    expeditions, protect the list with RCU.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f7e8917a67980924651a9e244510e63ef05c7755
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:32 2011 +0000

    pnfs: layout roc code
   =20
    A layout can request return-on-close.  How this interacts with the
    forgetful model of never sending LAYOUTRETURNS is a bit ambiguous.
    We forget any layouts marked roc, and wait for them to be completel=
y
    forgotten before continuing with the close.  In addition, to compen=
sate
    for races with any inflight LAYOUTGETs, and the fact that we do not=
 get
    any layout stateid back from the server, we set the barrier to the =
worst
    case scenario of current_seqid + number of outstanding LAYOUTGETS.
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 36840370845629e6cb4324d1dd4aff6778670503
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Thu Jan 6 11:36:31 2011 +0000

    pnfs: update nfs4_callback_recallany to handle layouts
   =20
    While here, update the code a bit.
   =20
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 43f1b3da8b35d706d6c47880fc211d2519b4a587
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:30 2011 +0000

    pnfs: add CB_LAYOUTRECALL handling
   =20
    This is the heart of the wave 2 submission.  Add the code to trigge=
r
    drain and forget of any afected layouts.  In addition, we set a
    "barrier", below which any LAYOUTGET reply is ignored.  This is to
    compensate for the fact that we do not wait for outstanding LAYOUTG=
ETs
    to complete as per section 12.5.5.2.1 of RFC 5661.
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f2a625616045fe46e1d5fceebdd825f5acdecdb7
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:29 2011 +0000

    pnfs: CB_LAYOUTRECALL xdr code
   =20
    This is the xdr decoding for CB_LAYOUTRECALL.
   =20
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cc6e5340b0981feac5a00a992bab6154cb4b1fa1
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:28 2011 +0000

    pnfs: change lo refcounting to atomic_t
   =20
    This will be required to allow us to grab reference outside of i_lo=
ck.
    While we are at it, make put_layout_hdr take the same argument as a=
ll the
    related functions.
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fc1794c5b04f5322bad05385cd91b52ec85aab72
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:27 2011 +0000

    pnfs: check that partial LAYOUTGET return is ignored
   =20
    Either a bad server reply, or our ignoring of multiple array segmen=
ts in
    a reply, can cause a reply to not meet our requirements.  Ensure
    that we ignore such replies.
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2130ff663633e8a57921779ebfe62fc39d5585ec
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:26 2011 +0000

    pnfs: add layout to client list before sending rpc
   =20
    Since this list will be used to search for layouts to recall,
    this is necessary to avoid a race where the recall comes in,
    sees there is nothing in the client list, and prepares to return
    NOMATCHING, while the LAYOUTGET gets processed before the recall
    updates the stateid.
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cf7d63f1f9895713551df2e6d18b006f8af26e91
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:25 2011 +0000

    pnfs: serialize LAYOUTGET(openstateid)
   =20
    We shouldn't send a LAYOUTGET(openstateid) unless all outstanding R=
PCs
    using the previous stateid are completed.  This requires choosing t=
he
    stateid to encode earlier, so we can abort if one is not available =
(we
    want to use the open stateid, but a LAYOUTGET is already out using
    it), and adding a count of the number of outstanding rpc calls usin=
g
    layout state (which for now consist solely of LAYOUTGETs).
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c31663d4a1fac5ce1954d656cbcf80eb883b814a
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:24 2011 +0000

    pnfs: layoutget rpc code cleanup
   =20
    No functional changes, just some code minor code rearrangement and
    comments.
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4541d16c024ce40a0781e03c185ecdfe34aec46f
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:23 2011 +0000

    pnfs: change how lsegs are removed from layout list
   =20
    This is to prepare the way for sensible io draining.  Instead of ju=
st
    removing the lseg from the list, we instead clear the VALID flag
    (preventing new io from grabbing references to the lseg) and remove
    the reference holding it in the list.  Thus the lseg will be remove=
d
    once any io in progress completes and any references still held are
    dropped.
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fd6002e9b8a93220d5f53b93d9624caf73cdc8a2
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:22 2011 +0000

    pnfs: change layout state seqlock to a spinlock
   =20
    This prepares for future changes, where the layout state needs
    to change atomically with several other variables.  In particular,
    it will need to know if lo->segs is empty, as we test that instead
    of manipulating the NFS_LAYOUT_STATEID_SET bit.  Moreover, the
    layoutstateid is not really a read-mostly structure, as it is
    written almost as often as it is read.
   =20
    The behavior of pnfs_get_layout_stateid is also slightly changed, s=
o that
    it no longer changes the stateid.  Its name is changed to +pnfs_cho=
ose_layoutget_stateid.
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b7edfaa1983362842351e425adeb8e297b4c11fb
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:21 2011 +0000

    pnfs: add prefix to struct pnfs_layout_hdr fields
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 566052c53b5146e23a99ab95fb5c11f8a295a084
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:20 2011 +0000

    pnfs: add prefix to struct pnfs_layout_segment fields
   =20
    While we are renaming all the fields, change lo->state to lo->plh_f=
lags.
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit daaa82d1c72e10dc16cad3a810e225f9188dc7aa
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:19 2011 +0000

    pnfs: remove unnecessary field lgp->status
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 52fabd73199cd00932f92c9f548bdf66a5bbc23d
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Jan 6 11:36:18 2011 +0000

    pnfs: fix incorrect comment in destroy_lseg
   =20
    Comment references get_layout_hdr_locked, which never existed in
    submitted code.
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4a19de0f4b693139bb10b7cc3cfe1f618576ba67
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 6 02:04:35 2011 +0000

    NFS rename client back channel transport field
   =20
    Differentiate from server backchannel
   =20
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Acked-by: Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 42acd021824578fa0eeb6eb58d457c23ec5dc9c0
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 6 02:04:34 2011 +0000

    NFS add session back channel draining
   =20
    Currently session draining only drains the fore channel.
    The back channel processing must also be drained.
   =20
    Use the back channel highest_slot_used to indicate that a callback =
is being
    processed by the callback thread.  Move the session complete to be =
per channel.
   =20
    When the session is draininig, wait for any current back channel pr=
ocessing
    to complete and stop all new back channel processing by returning N=
=46S4ERR_DELAY
    to the back channel client.
   =20
    Drain the back channel, then the fore channel.
   =20
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ece0de633c4d9106c39ea9f0db1638c42ead2541
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 6 02:04:33 2011 +0000

    NFS RPC_AUTH_GSS unsupported on v4.1 back channel
   =20
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Acked-by: Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c36fca52f5e4594ffd0ff175b328966b0d393184
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 6 02:04:32 2011 +0000

    NFS refactor nfs_find_client and reference client across callback p=
rocessing
   =20
    Fixes a bug where the nfs_client could be freed during callback pro=
cessing.
    Refactor nfs_find_client to use minorversion specific means to loca=
te the
    correct nfs_client structure.
   =20
    In the NFS layer, V4.0 clients are found using the callback_ident f=
ield in the
    CB_COMPOUND header.  V4.1 clients are found using the sessionID in =
the
    CB_SEQUENCE operation which is also compared against the sessionID =
associated
    with the back channel thread after a successful CREATE_SESSION.
   =20
    Each of these methods finds the one an only nfs_client associated
    with the incoming callback request - so nfs_find_client_next is not=
 needed.
   =20
    In the RPC layer, the pg_authenticate call needs to find the nfs_cl=
ient. For
    the v4.0 callback service, the callback identifier has not been dec=
oded so a
    search by address, version, and minorversion is used.  The sessioni=
d for the
    sessions based callback service has (usually) not been set for the
    pg_authenticate on a CB_NULL call which can be sent prior to the re=
turn
    of a CREATE_SESSION call, so the sessionid associated with the back=
 channel
    thread is not used to find the client in pg_authenticate for CB_NUL=
L calls.
   =20
    Pass the referenced nfs_client to each CB_COMPOUND operation being =
proceesed
    via the new cb_process_state structure. The reference is held acros=
s
    cb_compound processing.
   =20
    Use the new cb_process_state struct to move the NFS4ERR_RETRY_UNCAC=
HED_REP
    processing from process_op into nfs4_callback_sequence where it bel=
ongs.
   =20
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2c2618c6f29c41a0a966f14f05c8bf45fcabb750
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 6 02:04:31 2011 +0000

    NFS associate sessionid with callback connection
   =20
    The sessions based callback service is started prior to the CREATE_=
SESSION call
    so that it can handle CB_NULL requests which can be sent before the
    CREATE_SESSION call returns and the session ID is known.
   =20
    Set the callback sessionid after a sucessful CREATE_SESSION.
   =20
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f4eecd5da3422e82e88e36c33cbd2595eebcacb1
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 6 02:04:30 2011 +0000

    NFS implement v4.0 callback_ident
   =20
    Use the small id to pointer translator service to provide a unique =
callback
    identifier per SETCLIENTID call used to identify the v4.0 callback =
service
    associated with the clientid.
   =20
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ea00528126a701845d7c445e725b271940381e3d
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 6 02:04:29 2011 +0000

    NFS do not clear minor version at nfs_client free
   =20
    Resetting the client minor version operations causes nfs4_destroy_c=
allback
    to fail to shutdown the NFSv4.1 callback service.
   =20
    There is no reason to reset the client minorversion operations when=
 the
    nfs_client struct is being freed.
   =20
    Remove the minorverion reset and rename the function.
   =20
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 01c9a0bc60507af7f28cb9138a81836de4528199
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 6 02:04:28 2011 +0000

    NFS use svc_create_xprt for NFSv4.1 callback service
   =20
    The new back channel transport means we call the normal creation ro=
utine as
    well as svc_xprt_put.
   =20
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 16b2d1e1d12de000404d7c845d0db1226511f84d
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 6 02:04:27 2011 +0000

    SUNRPC register and unregister the back channel transport
   =20
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1f11a034cdc4b45ee56d51b87a9e37cb776fb15b
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 6 02:04:26 2011 +0000

    SUNRPC new transport for the NFSv4.1 shared back channel
   =20
    Move the current sock create and destroy routines into the new tran=
sport ops.
    Back channel socket will be destroyed by the svc_closs_all call in =
svc_destroy.
   =20
    Added check: only TCP supported on shared back channel.
   =20
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Acked-by: Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 71e161a6a9fa021a280e564254fcda894e6fbd14
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 6 02:04:25 2011 +0000

    SUNRPC fix bc_send print
   =20
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4b5b3ba16be1b195d2e1161746637acd4b9fed4f
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 6 02:04:24 2011 +0000

    SUNRPC move svc_drop to caller of svc_process_common
   =20
    The NFSv4.1 shared back channel does not need to call svc_drop beca=
use the
    callback service never outlives the single connection it services, =
and it
    reuses it's buffers and keeps the trasport.
   =20
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Acked-by: Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 64c2ce8b72eceec4030b04bca32d098b3d1431bb
Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Date:   Thu Dec 9 11:35:25 2010 +0000

    nfsv4: Switch to generic xattr handling code
   =20
    This patch make nfsv4 use the generic xattr handling code
    to get the nfsv4 acl. This will help us to add richacl
    support to nfsv4 in later patches
   =20
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a8a5da996df7d2d91b5aef2752da9adcefea4bc6
Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Date:   Thu Dec 9 11:35:14 2010 +0000

    nfs: Set MS_POSIXACL always
   =20
    We want to skip VFS applying mode for NFS. So set MS_POSIXACL alway=
s
    and selectively use umask. Ideally we would want to use umask only
    when we don't have inheritable ACEs set. But NFS currently don't
    allow to send umask to the server. So this is best what we can do
    and this is consistent with NFSv3
   =20
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bf0c84f1614bffc59565d04f09b9ac6b1aa269a9
Author: Namhyung Kim <namhyung@gmail.com>
Date:   Tue Dec 28 17:02:46 2010 +0000

    NFS: use ERR_CAST()
   =20
    Use ERR_CAST() intead of wierd-looking cast.
   =20
    Signed-off-by: Namhyung Kim <namhyung@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5f3e97c9ee6290befb5a2e78baf95ff951a8a34a
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Dec 21 23:49:34 2010 +0000

    nfs: fix mispelling of idmap CONFIG symbol
   =20
    Trivial, but confusing when you're trying to grep through this
    code....
   =20
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit beb0f0a9fba1fa98b378329a9a5b0a73f25097ae
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Dec 20 21:19:26 2010 +0000

    kernel panic when mount NFSv4
   =20
    On Tue, 2010-12-14 at 16:58 +0800, Mi Jinlong wrote:
    > Hi,
    >
    > When testing NFSv4 at RHEL6 with kernel 2.6.32, I got a kernel pa=
nic
    > at NFS client's __rpc_create_common function.
    >
    > The panic place is:
    >   rpc_mkpipe
    >     __rpc_lookup_create()          <=3D=3D=3D find pipefile *idma=
p*
    >     __rpc_mkpipe()                 <=3D=3D=3D pipefile is *idmap*
    >       __rpc_create_common()
    >        ******  BUG_ON(!d_unhashed(dentry)); ******    *panic*
    >
    > It means that the dentry's d_flags have be set DCACHE_UNHASHED,
    > but it should not be set here.
    >
    > Is someone known this bug? or give me some idea?
    >
    > A reproduce program is append, but it can't reproduce the bug eve=
ry time.
    > the export is: "/nfsroot       *(rw,no_root_squash,fsid=3D0,insec=
ure)"
    >
    > And the panic message is append.
    >
    > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
    > #!/bin/sh
    >
    > LOOPTOTAL=3D768
    > LOOPCOUNT=3D0
    > ret=3D0
    >
    > while [ $LOOPCOUNT -ne $LOOPTOTAL ]
    > do
    > 	((LOOPCOUNT +=3D 1))
    > 	service nfs restart
    > 	/usr/sbin/rpc.idmapd
    > 	mount -t nfs4 127.0.0.1:/ /mnt|| return 1;
    > 	ls -l /var/lib/nfs/rpc_pipefs/nfs/*/
    > 	umount /mnt
    > 	echo $LOOPCOUNT
    > done
    >
    > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
    > Code: af 60 01 00 00 89 fa 89 f0 e8 64 cf 89 f0 e8 5c 7c 64 cf 31=
 c0 8b 5c 24 10 8b
    > 74 24 14 8b 7c 24 18 8b 6c 24 1c 83 c4 20 c3 <0f> 0b eb fc 8b 46 =
28 c7 44 24 08 20
    > de ee f0 c7 44 24 04 56 ea
    > EIP:[<f0ee92ea>] __rpc_create_common+0x8a/0xc0 [sunrpc] SS:ESP 00=
68:eccb5d28
    > ---[ end trace 8f5606cd08928ed2]---
    > Kernel panic - not syncing: Fatal exception
    > Pid:7131, comm: mount.nfs4 Tainted: G     D   -------------------=
2.6.32 #1
    > Call Trace:
    >  [<c080ad18>] ? panic+0x42/0xed
    >  [<c080e42c>] ? oops_end+0xbc/0xd0
    >  [<c040b090>] ? do_invalid_op+0x0/0x90
    >  [<c040b10f>] ? do_invalid_op+0x7f/0x90
    >  [<f0ee92ea>] ? __rpc_create_common+0x8a/0xc0[sunrpc]
    >  [<f0edc433>] ? rpc_free_task+0x33/0x70[sunrpc]
    >  [<f0ed6508>] ? prc_call_sync+0x48/0x60[sunrpc]
    >  [<f0ed656e>] ? rpc_ping+0x4e/0x60[sunrpc]
    >  [<f0ed6eaf>] ? rpc_create+0x38f/0x4f0[sunrpc]
    >  [<c080d80b>] ? error_code+0x73/0x78
    >  [<f0ee92ea>] ? __rpc_create_common+0x8a/0xc0[sunrpc]
    >  [<c0532bda>] ? d_lookup+0x2a/0x40
    >  [<f0ee94b1>] ? rpc_mkpipe+0x111/0x1b0[sunrpc]
    >  [<f10a59f4>] ? nfs_create_rpc_client+0xb4/0xf0[nfs]
    >  [<f10d6c6d>] ? nfs_fscache_get_client_cookie+0x1d/0x50[nfs]
    >  [<f10d3fcb>] ? nfs_idmap_new+0x7b/0x140[nfs]
    >  [<c05e76aa>] ? strlcpy+0x3a/0x60
    >  [<f10a60ca>] ? nfs4_set_client+0xea/0x2b0[nfs]
    >  [<f10a6d0c>] ? nfs4_create_server+0xac/0x1b0[nfs]
    >  [<c04f1400>] ? krealloc+0x40/0x50
    >  [<f10b0e8b>] ? nfs4_remote_get_sb+0x6b/0x250[nfs]
    >  [<c04f14ec>] ? kstrdup+0x3c/0x60
    >  [<c0520739>] ? vfs_kern_mount+0x69/0x170
    >  [<f10b1a3c>] ? nfs_do_root_mount+0x6c/0xa0[nfs]
    >  [<f10b1b47>] ? nfs4_try_mount+0x37/0xa0[nfs]
    >  [<f10afe6d>] ? nfs4_validate_text_mount_data+-x7d/0xf0[nfs]
    >  [<f10b1c42>] ? nfs4_get_sb+0x92/0x2f0
    >  [<c0520739>] ? vfs_kern_mount+0x69/0x170
    >  [<c05366d2>] ? get_fs_type+0x32/0xb0
    >  [<c052089f>] ? do_kern_mount+0x3f/0xe0
    >  [<c053954f>] ? do_mount+0x2ef/0x740
    >  [<c0537740>] ? copy_mount_options+0xb0/0x120
    >  [<c0539a0e>] ? sys_mount+0x6e/0xa0
   =20
    Hi,
   =20
    Does the following patch fix the problem?
   =20
    Cheers
      Trond
   =20
    --------------------------
    SUNRPC: Fix a BUG in __rpc_create_common
   =20
    From: Trond Myklebust <Trond.Myklebust@netapp.com>
   =20
    Mi Jinlong reports:
   =20
    When testing NFSv4 at RHEL6 with kernel 2.6.32, I got a kernel pani=
c
    at NFS client's __rpc_create_common function.
   =20
    The panic place is:
      rpc_mkpipe
          __rpc_lookup_create()          <=3D=3D=3D find pipefile *idma=
p*
          __rpc_mkpipe()                 <=3D=3D=3D pipefile is *idmap*
            __rpc_create_common()
             ******  BUG_ON(!d_unhashed(dentry)); ****** *panic*
   =20
    The test is wrong: we can find ourselves with a hashed negative den=
try here
    if the idmapper tried to look up the file before we got round to cr=
eating
    it.
   =20
    Just replace the BUG_ON() with a d_drop(dentry).
   =20
    Reported-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 51f128ea1c9224c1e3cf6c6a1498431d97699668
Author: Dan Carpenter <error27@gmail.com>
Date:   Sun Jan 2 20:20:42 2011 +0000

    lockd: double unlock in next_host_state()
   =20
    We unlock again after we goto out.
   =20
    Signed-off-by: Dan Carpenter <error27@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 878215feb8b2417c4700090b4335739858cf7b5a
Author: Jesper Juhl <jj@chaosbits.net>
Date:   Fri Dec 24 22:22:37 2010 +0000

    NFS: Don't leak in nfs_proc_symlink()
   =20
    Hi,
   =20
    In fs/nfs/proc.c::nfs_proc_symlink() we will leak memory if either
    nfs_alloc_fhandle() or nfs_alloc_fattr() returns NULL but the other=
 one
    doesn't.
    This patch ensures memory allocated by one when the other fails is =
always
    released (this is safe since nfs_free_fattr() and nfs_free_fhandle(=
) both
    call kfree which deals gracefully with NULL pointers).
   =20
    Signed-off-by: Jesper Juhl <jj@chaosbits.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1174dd1f890b7f8be8ec6a7071657fe8f59e18b7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 21 10:52:24 2010 -0500

    NFSv4: Convert a few commas into semicolons...
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b3bcedadf23264c3b7afcbfbfe1965a17ef1352c
Author: Joe Perches <joe@perches.com>
Date:   Tue Dec 21 10:52:24 2010 -0500

    net/sunrpc/clnt.c: Convert sprintf_symbol to %ps
   =20
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit aa69947399a119d7f1b35bbcd62c849839b35449
Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date:   Wed Dec 8 12:40:13 2010 +0300

    NFS: suppressing showing of default mount port value in /proc fixed
   =20
    Update: added check for zero value as it was before (note: can't si=
mply check
    mountd_port for positive value because it's typeof unsigned short)
   =20
    Default value for mount server port is set to NFS_UNSPEC_PORT (-1) =
and will not
    be changed during parsing mount options for mound data version 6. T=
his default
    value will be showed for mountport in /proc/mounts always since cur=
rent default
    check is for zero value. This small mistake leads to big problem, b=
ecause
    during umount.nfs execution from old user-space utils (at least nfs=
-utils
    1.0.9) this value will be used as the server port to connect to. Th=
is request
    will be rejected (since port is 65535) and thus nfs mount point can=
't be
    unmounted.
   =20
    Note from Chuck Lever (chuck.lever@oracle.com): this is only possib=
le if
    /etc/mtab is a link to /proc/mounts.  Not all systems have this con=
figuration.
   =20
    Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 611c96c8f728c4bcdbadaa2387942d3c0641cadf
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Dec 13 19:05:46 2010 -0500

    nfs4: fix units bug causing hang on recovery
   =20
    Note that cl_lease_time is in jiffies.  This can cause a very long =
wait
    in the NFS4ERR_CLID_INUSE case.
   =20
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 72895b1ac7baeda76835cddb3edb019a90d32bcb
Author: Jesper Juhl <jj@chaosbits.net>
Date:   Thu Dec 9 23:17:15 2010 +0100

    nfs: Take advantage of kmem_cache_zalloc() in nfs_page_alloc()
   =20
    Take advantage of kmem_cache_zalloc() in nfs_page_alloc(). Save a c=
all to
    memset() and a few bytes.
   =20
    Before:
     [jj@dragon linux-2.6]$ size fs/nfs/pagelist.o
        text    data     bss     dec     hex filename
        1765       0       8    1773     6ed fs/nfs/pagelist.o
    After:
     [jj@dragon linux-2.6]$ size fs/nfs/pagelist.o
        text    data     bss     dec     hex filename
        1749       0       8    1757     6dd fs/nfs/pagelist.o
   =20
    Signed-off-by: Jesper Juhl <jj@chaosbits.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c8b031ebc1246d42463c5c69df8f610ca9f48e77
Author: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Date:   Thu Dec 9 15:53:28 2010 +0100

    NFS: Remove redundant unlikely()
   =20
    IS_ERR() already implies unlikely(), so it can be omitted here.
   =20
    Signed-off-by: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 79691836603541e81a3793970826ac4a75429572
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 15:06:52 2010 +0000

    lockd: Remove src_sap and src_len from nlm_lookup_host_info struct
   =20
    Clean up.
   =20
    The contents of the src_sap field is not used in nlm_alloc_host().
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2025889828bb14b56d9aa4c1a785bd9847ccdc4b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 15:06:41 2010 +0000

    lockd: Remove nlm_lookup_host()
   =20
    Clean up.
   =20
    Remove the now unused helper nlm_lookup_host().
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fcc072c783491ca465e4d1e74da7dbb48dbf7a31
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 15:06:32 2010 +0000

    lockd: Make nrhosts an unsigned long
   =20
    Clean up.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d2df0484bb38f2e0d9754b00597d4a6d1cf666d0
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 15:06:22 2010 +0000

    lockd: Rename nlm_hosts
   =20
    Clean up.
   =20
    nlm_hosts now contains only server-side entries.  Rename it to matc=
h
    convention of client side cache.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 67216b94d498f5880d8bba2a6b841880739dd524
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 15:06:12 2010 +0000

    lockd: Clean up nlmsvc_lookup_host()
   =20
    Clean up.
   =20
    Change nlmsvc_lookup_host() to be purpose-built for server-side
    nlm_host management.  This replaces the generic nlm_lookup_host()
    helper function, just like on the client side.  The lookup logic is
    specialized for server host lookups.
   =20
    The server side cache also gets its own specialized equivalent of t=
he
    nlm_release_host() function.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8ea6ecc8b0759756a766c05dc7c98c51ec90de37
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 15:05:52 2010 +0000

    lockd: Create client-side nlm_host cache
   =20
    NFS clients don't need the garbage collection processing that is
    performed on nlm_host structures.  The client picks up an nlm_host =
at
    mount time and holds a reference to it until the file system is
    unmounted.
   =20
    Servers, on the other hand, don't have a precise way to tell when a=
n
    nlm_host is no longer being used, so zero refcount nlm_host entries
    are left to expire in the cache after a time.
   =20
    Basically there's nothing holding a reference to an nlm_host betwee=
n
    individual server-side NLM requests, but we can't afford the expens=
e
    of recreating them for every new NLM request from a client.  The
    nlm_host cache adds some lifetime hysteresis to entries in the cach=
e
    so the next time a particular nlm_host is needed, it's likely to be
    discovered by a lookup rather than created from whole cloth.
   =20
    With the new implementation, client nlm_host cache items are no lon=
ger
    garbage collected, and are destroyed directly by a new release
    function specialized for client entries, nlmclnt_release_host().  T=
hey
    are cached in their own data structure, and have their own lookup
    logic, simplified and specialized for client nlm_host entries.
   =20
    However, the client nlm_host cache still shares reboot recovery log=
ic
    with the server nlm_host cache.  The NSM "peer rebooted" downcall f=
or
    clients and servers still come through the same RPC call.  This is =
a
    legacy formal API that would be difficult to alter, and besides, th=
e
    user space NSM implementation can't tell the difference between pee=
rs
    that are clients or servers.
   =20
    For this reason, the client cache continues to share the
    nlm_host_mutex (and reboot recovery logic) with the server cache.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7db836d4a427c3c64406b00b6d8d745d6335d72a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 15:05:42 2010 +0000

    lockd: Split nlm_release_call()
   =20
    The nlm_release_call() function is invoked from both the server and
    the client side.  We're about to introduce a distinct server- and
    client-side nlm_release_host(), so nlm_release_call() must first be
    split into a client-side and a server-side version.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 723bb5b5052faba57060a2feb564ced22416b5bc
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 15:05:33 2010 +0000

    lockd: Add nlm_destroy_host_locked()
   =20
    Refactor the tail of nlm_gc_hosts() into nlm_destroy_host() so that
    this logic can be used separately from garbage collection.
   =20
    Rename it _locked() to document that it must be called with the hos=
ts
    cache mutex held.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a7952f4056d4d9c63c70534bcfd4f2c11e487000
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 15:05:23 2010 +0000

    lockd: Add nlm_alloc_host()
   =20
    Refactor nlm_host allocation and initialization into a separate
    function.  This will be the common piece of server and client nlm_h=
ost
    lookup logic after the nlm_host cache is split.
   =20
    Small change: use kmalloc() instead of kzalloc(), as we're overwrit=
ing
    almost all fields in the new nlm_host struct with non-zero values
    immediately after it is allocated.  An added benefit is we now have=
 an
    explicit reference to each field name where it is initialized (for =
all
    you cscope fans out there).
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b10e30f6559978e3c8ca2a70c1cb35d6680a4021
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Dec 14 15:05:13 2010 +0000

    lockd: reorganize nlm_host_rebooted
   =20
    Minor reorganization; no change in behavior.  This will save some
    duplicated code after we split the client and server host caches.
   =20
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    [ cel: Forward-ported to 2.6.37 ]
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b113746888c260a02f6ae1e92b0b9ef7e9c38993
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Dec 14 15:05:03 2010 +0000

    lockd: define host_for_each{_safe} macros
   =20
    We've got a lot of loops like this, and I find them a little easier=
 to
    read with the macros.  More such loops are coming.
   =20
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    [ cel: Forward-ported to 2.6.37 ]
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bf2695516db982e90a22fc94f93491b481796bb1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:59:29 2010 +0000

    SUNRPC: New xdr_streams XDR decoder API
   =20
    Now that all client-side XDR decoder routines use xdr_streams, ther=
e
    should be no need to support the legacy calling sequence [rpc_rqst =
*,
    __be32 *, RPC res *] anywhere.  We can construct an xdr_stream in t=
he
    generic RPC code, instead of in each decoder function.
   =20
    This is a refactoring change.  It should not cause different behavi=
or.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9f06c719f474be7003763284a990bed6377bb0d4
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:59:18 2010 +0000

    SUNRPC: New xdr_streams XDR encoder API
   =20
    Now that all client-side XDR encoder routines use xdr_streams, ther=
e
    should be no need to support the legacy calling sequence [rpc_rqst =
*,
    __be32 *, RPC arg *] anywhere.  We can construct an xdr_stream in t=
he
    generic RPC code, instead of in each encoder function.
   =20
    Also, all the client-side encoder functions return 0 now, making a
    return value superfluous.  Take this opportunity to convert them to
    return void instead.
   =20
    This is a refactoring change.  It should not cause different behavi=
or.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1ac7c23e4af5e83525137661595000099f1ce94f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:59:09 2010 +0000

    SUNRPC: Determine value of "nrprocs" automatically
   =20
    Clean up.
   =20
    Just fixed a panic where the nrprocs field in a different upper lay=
er
    client was set by hand incorrectly.  Use the compiler-generated met=
hod
    used by the other upper layer protocols.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4129ccf303593a1922a934697f99e682ff491504
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:58:59 2010 +0000

    SUNRPC: Avoid return code checking in rpcbind XDR encoder functions
   =20
    Clean up.
   =20
    The trend in the other XDR encoder functions is to BUG() when encod=
ing
    problems occur, since a problem here is always due to a local codin=
g
    error.  Then, instead of a status, zero is unconditionally returned=
=2E
   =20
    Update the rpcbind XDR encoders to behave this way.
   =20
    To finish the update, use the new-style be32_to_cpup() and
    cpu_to_be32() macros, and compute the buffer sizes using raw intege=
rs
    instead of sizeof().  This matches the conventions used in other XD=
R
    functions.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b43cd8c153f6902100ed50c1f7e11a470c73a73f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:58:49 2010 +0000

    NFS: Remove unused UMNT response data structure
   =20
    Clean up.
   =20
    The UMNT request has a NULL response.  There's no need to set up a
    mountres structure for it.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 98eb2b4f9323bcf2a46476576d3155758cb0a473
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:58:40 2010 +0000

    NFS: Avoid return code checking in mount XDR encoder functions
   =20
    Clean up.
   =20
    The trend in the other XDR encoder functions is to BUG() when encod=
ing
    problems occur, since a problem here is always due to a local codin=
g
    error.  Then, instead of a status, zero is unconditionally returned=
=2E
   =20
    Update the mount client XDR encoders to behave this way.
   =20
    To finish the update, use the new-style be32_to_cpup() and
    cpu_to_be32() macros, and compute the buffer sizes using raw intege=
rs
    instead of sizeof().  This matches the conventions used in other XD=
R
    functions.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 49b170047f4a9fe1483132e14a11bdf493bdb8af
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:58:30 2010 +0000

    NSM: Avoid return code checking in NSM XDR encoder functions
   =20
    Clean up.
   =20
    The trend in the other XDR encoder functions is to BUG() when encod=
ing
    problems occur, since a problem here is always due to a local codin=
g
    error.  Then, instead of a status, zero is unconditionally returned=
=2E
   =20
    Update the NSM XDR encoders to behave this way.
   =20
    To finish the update, use the new-style be32_to_cpup() and
    cpu_to_be32() macros, and compute the buffer sizes using raw intege=
rs
    instead of sizeof().  This matches the conventions used in other XD=
R
    functions
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ead00597882c4ee3c534d6880cc3bcb4d412cc4b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:58:21 2010 +0000

    NFS: Squelch compiler warning in decode_getdeviceinfo()
   =20
    Clean up.
   =20
    .../linux/nfs-2.6/fs/nfs/nfs4xdr.c: In function =E2=80=98decode_get=
deviceinfo=E2=80=99:
    .../linux/nfs-2.6/fs/nfs/nfs4xdr.c:5008: warning: comparison betwee=
n signed and unsigned integer expressions
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 573c4e1ef53a6b891b73cc2257e1604da754a2e4
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:58:11 2010 +0000

    NFS: Simplify ->decode_dirent() calling sequence
   =20
    Clean up.
   =20
    The pointer returned by ->decode_dirent() is no longer used as a
    pointer.  The only call site (xdr_decode() in fs/nfs/dir.c) simply
    extracts the errno value encoded in the pointer.  Replace the
    returned pointer with a standard integer errno return value.
   =20
    Also, pass the "server" argument as part of the nfs_entry instead o=
f
    as a separate parameter.  It's faster to derive "server" in
    nfs_readdir_xdr_to_array() since we already have the directory's in=
ode
    handy.  "server" ought to be invariant for a set of entries in the
    same directory, right?
   =20
    The legacy versions of decode_dirent() don't use "server" anyway, s=
o
    it's wasted work for them to derive and pass "server" for each entr=
y.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8111f373600cd43b3198b48b9238e3ad2fd9908d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:58:01 2010 +0000

    NFS: Fix hdrlen calculation in NFSv4's decode_read()
   =20
    When computing the length of the header, be sure to include the
    four octets consumed by "count".
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d8367c504e39528a057a5d7a267b6724f7fdb4b8
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:57:52 2010 +0000

    lockd: Move nlmdbg_cookie2a() to svclock.c
   =20
    Clean up.  nlmdbg_cookie2a() is used only in svclock.c.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7d93bd71cb3e2629cc88bc59f393bd4df4162b94
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:57:42 2010 +0000

    NFS: Repair whitespace damage in NFS PROC macro
   =20
    Clean up.
   =20
    When I was making other changes in this area, checkscript.pl
    complained about the use of leading blanks in the PROC macros in th=
e
    xdr files.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 85a56480191ca9f08fc775c129b9eb5c8c1f2c05
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:57:32 2010 +0000

    NFSD: Update XDR decoders in NFSv4 callback client
   =20
    Clean up.
   =20
    Remove old-style NFSv4 XDR macros in favor of the style now used in
    fs/nfs/nfs4xdr.c.  These were forgotten during the recent nfs4xdr.c
    rewrite.
   =20
    Additional whitespace cleanup adds to the size of this patch.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a033db487eec09afde00a3562842982a8053c887
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:57:22 2010 +0000

    NFSD: Update XDR encoders in NFSv4 callback client
   =20
    Clean up.
   =20
    Remove old-style NFSv4 XDR macros in favor of the style now used in
    fs/nfs/nfs4xdr.c.  These were forgotten during the recent nfs4xdr.c
    rewrite.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3460f29a27344db8c7af62cafdb961286ef0b6cd
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:57:12 2010 +0000

    lockd: Introduce new-style XDR functions for NLMv4
   =20
    We'd like to prevent local buffer overflows caused by malicious or
    broken servers.  New xdr_stream style decoders can do that.
   =20
    For efficiency, we also want to be able to pass xdr_streams from
    call_encode() to all XDR encoding functions, rather than building
    an xdr_stream in every XDR encoding function in the kernel.
   =20
    Same idea as the NLM v3 XDR overhaul.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f6048709391336cf27fb5c1cfca8e792103e5a73
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:57:02 2010 +0000

    NFS: Move and update xdr_decode_foo() functions that we're keeping
   =20
    Clean up.
   =20
    Move the timestamp decoder to match the placement and naming
    conventions of the other helpers.  Fold xdr_decode_fattr() into
    decode_fattr3(), which is now it's only user.  Fold
    xdr_decode_wcc_attr() into decode_wcc_attr(), which is now it's onl=
y
    user.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b2cdd9c9c95e0e389a8b75fe25f266fc5267bbb6
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:56:52 2010 +0000

    NFS: Remove unused old NFSv3 decoder functions
   =20
    Clean up.  Remove unused legacy result decoder functions, and any
    now unused decoder helper functions.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f5fc3c50c99a7df2bf908dfe66f112d35178ee07
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:56:42 2010 +0000

    NFS: Switch in new NFSv3 decoder functions
   =20
    The naming scheme of the new decoder functions, which follows the
    NFSv4 XDR decoder functions, is slightly different than the scheme
    used for the old functions.  Rename the functions as a separate
    step to keep the patches clean.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e4f9323409369a3aeb01885c0c4409d2eeec794a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:56:30 2010 +0000

    NFS: Introduce new-style XDR decoding functions for NFSv2
   =20
    We'd like to prevent local buffer overflows caused by malicious or
    broken servers.  New xdr_stream style decoders can do that.
   =20
    For efficiency, we also eventually want to be able to pass xdr_stre=
ams
    from call_decode() to all XDR decoding functions, rather than build=
ing
    an xdr_stream in every XDR decoding function in the kernel.
   =20
    Static helper functions are left without the "inline" directive.  T=
his
    allows the compiler to choose automatically how to optimize these f=
or
    size or speed.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9d5a64343925a152e1907c652a0d71d6640868b3
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:56:20 2010 +0000

    NFS: Update xdr_encode_foo() functions that we're keeping
   =20
    Clean up.  Move the timestamp and the sattr encoder to match the
    placement convention of the other helpers, update their coding styl=
e,
    and refresh their documenting comments.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 499ff710b2fd3a03c8195c82340e5166eed04205
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:56:10 2010 +0000

    NFS: Remove unused old NFSv3 encoder functions
   =20
    Clean up.  Remove unused legacy argument encoder functions, and any
    now unused encoder helper functions.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ad96b5b5eae59696b97e207d730b8c8cfb9d4e42
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:56:01 2010 +0000

    NFS: Replace old NFSv3 encoder functions with xdr_stream-based ones
   =20
    The naming scheme of the new encoder functions, which follows the
    NFSv4 XDR encoder functions, is slightly different than the scheme
    used for the old functions.  Rename the functions as a separate
    step to keep the patches clean.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d9c407b138926132e1f93c01fb2dee50eb0bb615
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:55:50 2010 +0000

    NFS: Introduce new-style XDR encoding functions for NFSv3
   =20
    We're interested in taking advantage of the safety benefits of
    xdr_streams.  These data structures allow more careful checking for
    buffer overflow while encoding.  More careful type checking is also
    introduced in the new functions.
   =20
    For efficiency, we also eventually want to be able to pass xdr_stre=
ams
    from call_encode() to all XDR encoding functions, rather than build=
ing
    an xdr_stream in every XDR encoding function in the kernel.  To do
    this means all encoders must be ready to handle a passed-in
    xdr_stream.
   =20
    The new encoders follow the modern paradigm for XDR encoders: BUG o=
n
    error, and always return a zero status code.
   =20
    Static helper functions are left without the "inline" directive.  T=
his
    allows the compiler to choose automatically how to optimize these f=
or
    size or speed.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2b061f9ef216b6d229b06267f188167fd6ab3d9b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:55:40 2010 +0000

    lockd: Introduce new-style XDR functions for NLMv3
   =20
    We'd like to prevent local buffer overflows caused by malicious or
    broken servers.  New xdr_stream style decoders can do that.
   =20
    For efficiency, we also eventually want to be able to pass xdr_stre=
ams
    from call_encode() and call_decode() to all XDR encoding functions,
    rather than building an xdr_stream in every XDR encoding and decodi=
ng
    function in the kernel.
   =20
    To do all of this, rewrite the XDR encoding and decoding functions =
in
    fs/lockd/xdr.c to use xdr_streams.  This makes them more or less
    incompatible with server-side XDR helper functions, so break them o=
ut
    into a separate source file.
   =20
    Static helper functions are left without the "inline" directive.  T=
his
    allows the compiler to choose automatically how to optimize these f=
or
    size or speed.
   =20
    SHARE-related functionality doesn't seem to be used, as those
    functions are hiding behind a #define that isn't set anywhere that =
I
    can find.  And, they've been in there forever (at least as far back=
 as
    the kernel's git history goes), yet remain unused.  Let's take the
    opportunity to bin them.  It should be easy enough for someone to
    introduce proper XDR functions if at some point SHARE-related NLM
    functionality is desired.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5f96e5e31b4f4a2f126adfe0586a7555c11b0562
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:55:30 2010 +0000

    NFS: Move and update xdr_decode_foo() functions that we're keeping
   =20
    Clean up.
   =20
    Move the timestamp decoder to match the placement and naming
    conventions of the other helpers.  Fold xdr_decode_fattr() into
    decode_fattr(), which is now it's only user.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 661ad4239a51a2169a366a227c68cf3b654ab936
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:55:20 2010 +0000

    NFS: Replace old NFSv2 decoder functions with xdr_stream-based ones
   =20
    Clean up.  Remove unused legacy result decoder functions, and any
    now unused decoder helper functions.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f796f8b3ae292abb9cb2931e8db6fc1d69bba09d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:55:10 2010 +0000

    NFS: Introduce new-style XDR decoding functions for NFSv2
   =20
    We'd like to prevent local buffer overflows caused by malicious or
    broken servers.  New xdr_stream style decoders can do that.
   =20
    For efficiency, we also eventually want to be able to pass xdr_stre=
ams
    from call_decode() to all XDR decoding functions, rather than build=
ing
    an xdr_stream in every XDR decoding function in the kernel.
   =20
    nfs_decode_dirent() is renamed to follow the naming convention of t=
he
    other two dirent decoders.
   =20
    Static helper functions are left without the "inline" directive.  T=
his
    allows the compiler to choose automatically how to optimize these f=
or
    size or speed.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 858284932462cec260f3d1d7426aeb03f5dbc2ad
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:55:00 2010 +0000

    NFS: Use the "nfs_stat" enum for nfs_stat_to_errno()'s argument
   =20
    Clean up.
   =20
    To distinguish more clearly between the on-the-wire NFSERR_ value a=
nd
    our local errno values, use the proper type for the argument of
    nfs_stat_to_errno().
   =20
    Add a documenting comment appropriate for a global function shared
    outside this source file.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 282ac2a573dd1be4230710932cd471ed5a3a94b8
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:54:50 2010 +0000

    NFS: Update xdr_encode_foo() functions that we're keeping
   =20
    Clean up.
   =20
    The new helper functions are kept in order by section of RFC 1094.
    Move the two timestamp encoders we're keeping, update their coding
    style, and refresh their documenting comments.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2d70f533eab0a0cabd05ee878b6709707bf63c86
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:54:40 2010 +0000

    NFS: Remove old NFSv2 encoder functions
   =20
    Clean up:  Remove unused legacy argument encoder functions, and any
    now unused encoder helper functions.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 25a0866cc63281b480cc0c11ddeaccb2ffc57dc9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:54:30 2010 +0000

    NFS: Introduce new-style XDR encoding functions for NFSv2
   =20
    We're interested in taking advantage of the safety benefits of
    xdr_streams.  These data structures allow more careful checking for
    buffer overflow while encoding.  More careful type checking is also
    introduced in the new functions.
   =20
    For efficiency, we also eventually want to be able to pass xdr_stre=
ams
    from call_encode() to all XDR encoding functions, rather than build=
ing
    an xdr_stream in every XDR encoding function in the kernel.  To do
    this means all encoders must be ready to handle a passed-in
    xdr_stream.
   =20
    The new encoders follow the modern paradigm for XDR encoders: BUG o=
n
    any error, and always return a zero status code.
   =20
    Static helper functions are left without the "inline" directive.  T=
his
    allows the compiler to choose automatically how to optimize these f=
or
    size or speed.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

