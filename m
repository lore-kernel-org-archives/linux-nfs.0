From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull NFS client changesets against Linux 2.6.28...
Date: Tue, 30 Dec 2008 18:48:35 -0500
Message-ID: <1230680915.11508.40.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41561 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751484AbYL3XtR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Dec 2008 18:49:17 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/lockd/clntlock.c                     |   23 +-
 fs/lockd/host.c                         |   10 +-
 fs/lockd/svc.c                          |    6 +-
 fs/nfs/callback.c                       |   36 +-
 fs/nfs/client.c                         |   95 ++-
 fs/nfs/delegation.c                     |  260 ++++----
 fs/nfs/delegation.h                     |   33 +-
 fs/nfs/dir.c                            |   24 +-
 fs/nfs/inode.c                          |   13 +-
 fs/nfs/internal.h                       |   14 +
 fs/nfs/mount_clnt.c                     |   34 +-
 fs/nfs/nfs4_fs.h                        |   32 +-
 fs/nfs/nfs4proc.c                       |  431 ++++++-----
 fs/nfs/nfs4renewd.c                     |   22 +-
 fs/nfs/nfs4state.c                      |  415 ++++++++---
 fs/nfs/nfs4xdr.c                        | 1235 ++++++++++++++-----------------
 fs/nfs/nfsroot.c                        |   27 +-
 fs/nfs/read.c                           |    6 -
 fs/nfs/super.c                          |   44 +-
 fs/nfs_common/nfsacl.c                  |    4 +-
 fs/nfsd/nfs4callback.c                  |    9 +-
 fs/nfsd/nfs4state.c                     |   12 +
 include/linux/jiffies.h                 |   10 +
 include/linux/lockd/bind.h              |    1 +
 include/linux/lockd/lockd.h             |    4 +-
 include/linux/nfs_fs.h                  |   17 +-
 include/linux/nfs_fs_sb.h               |    6 -
 include/linux/nfs_mount.h               |    3 +-
 include/linux/nfs_xdr.h                 |    7 +-
 include/linux/nfsd/state.h              |    2 +
 include/linux/sunrpc/clnt.h             |    2 +
 include/linux/sunrpc/rpc_pipe_fs.h      |    1 +
 include/linux/sunrpc/svcauth_gss.h      |    1 +
 include/linux/sunrpc/xdr.h              |   15 -
 include/linux/sunrpc/xprt.h             |    3 +-
 net/sunrpc/auth.c                       |    6 +-
 net/sunrpc/auth_gss/auth_gss.c          |  295 ++++++--
 net/sunrpc/auth_gss/gss_generic_token.c |    6 +-
 net/sunrpc/auth_gss/gss_mech_switch.c   |   18 +-
 net/sunrpc/auth_gss/svcauth_gss.c       |   28 +-
 net/sunrpc/clnt.c                       |   16 +
 net/sunrpc/rpc_pipe.c                   |   42 +-
 net/sunrpc/xdr.c                        |   50 +-
 43 files changed, 1876 insertions(+), 1442 deletions(-)

commit 46f72f57d279688c4524df78edb5738db730eeef
Author: WANG Cong <wangcong-va7F5g4oNmbYtjvyW6yDsg@public.gmane.org>
Date:   Tue Dec 30 16:35:55 2008 -0500

    fs/nfs/nfs4proc.c: make nfs4_map_errors() static
    
    nfs4_map_errors() can become static.
    
    Signed-off-by: WANG Cong <wangcong-va7F5g4oNmbYtjvyW6yDsg@public.gmane.org>
    Cc: J. Bruce Fields <bfields@fieldses.org>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2efef7080f471d312a9c4feb3dc5ee038039c7ed
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Tue Dec 23 16:19:56 2008 -0500

    rpc: add service field to new upcall
    
    This patch extends the new upcall with a "service" field that currently
    can have 2 values: "*" or "nfs". These values specify matching rules for
    principals in the keytab file. The "*" means that gssd is allowed to use
    "root", "nfs", or "host" keytab entries while the other option requires
    "nfs".
    
    Restricting gssd to use the "nfs" principal is needed for when the
    server performs a callback to the client.  The server in this case has
    to authenticate itself as an "nfs" principal.
    
    We also need "service" field to distiguish between two client-side cases
    both currently using a uid of 0: the case of regular file access by the
    root user, and the case of state-management calls (such as setclientid)
    which should use a keytab for authentication.  (And the upcall should
    fail if an appropriate principal can't be found.)
    
    Signed-off: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8b1c7bf5b624c9bc91b41ae577b9fc5c21641705
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Tue Dec 23 16:19:26 2008 -0500

    rpc: add target field to new upcall
    
    This patch extends the new upcall by adding a "target" field
    communicating who we want to authenticate to (equivalently, the service
    principal that we want to acquire a ticket for).
    
    Signed-off: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 61054b14d545e257b9415d5ca0cd5f43762b4d0c
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Tue Dec 23 16:19:00 2008 -0500

    nfsd: support callbacks with gss flavors
    
    This patch adds server-side support for callbacks other than AUTH_SYS.
    
    Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 945b34a7725a5f0741de7775132aafc58bfecfbb
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Tue Dec 23 16:18:34 2008 -0500

    rpc: allow gss callbacks to client
    
    This patch adds client-side support to allow for callbacks other than
    AUTH_SYS.
    
    Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 608207e8884e083ad8b8d33eda868da70f0d63e8
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Tue Dec 23 16:17:40 2008 -0500

    rpc: pass target name down to rpc level on callbacks
    
    The rpc client needs to know the principal that the setclientid was done
    as, so it can tell gssd who to authenticate to.
    
    Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 68e76ad0baf8f5d5060377c2423ee6eed5c63057
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Tue Dec 23 16:17:15 2008 -0500

    nfsd: pass client principal name in rsc downcall
    
    Two principals are involved in krb5 authentication: the target, who we
    authenticate *to* (normally the name of the server, like
    nfs/server.citi.umich.edu-1fImKH7ifK/W5BsphJQQlw@public.gmane.org), and the source, we we
    authenticate *as* (normally a user, like bfields-fNArPiWPQCi4O7BPJtRMKQ@public.gmane.org)
    
    In the case of NFSv4 callbacks, the target of the callback should be the
    source of the client's setclientid call, and the source should be the
    nfs server's own principal.
    
    Therefore we allow svcgssd to pass down the name of the principal that
    just authenticated, so that on setclientid we can store that principal
    name with the new client, to be used later on callbacks.
    
    Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 34769fc488b463cb753fc632f8f5ba56c918b7cb
Author: \"J. Bruce Fields\ <bfields@citi.umich.edu>
Date:   Tue Dec 23 16:16:37 2008 -0500

    rpc: implement new upcall
    
    Implement the new upcall.  We decide which version of the upcall gssd
    will use (new or old), by creating both pipes (the new one named "gssd",
    the old one named after the mechanism (e.g., "krb5")), and then waiting
    to see which version gssd actually opens.
    
    We don't permit pipes of the two different types to be opened at once.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5b7ddd4a7b19f913901140ef7807dbf5e2b301cd
Author: \"J. Bruce Fields\ <bfields@citi.umich.edu>
Date:   Tue Dec 23 16:15:44 2008 -0500

    rpc: store pointer to pipe inode in gss upcall message
    
    Keep a pointer to the inode that the message is queued on in the struct
    gss_upcall_msg.  This will be convenient, especially after we have a
    choice of two pipes that an upcall could be queued on.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 79a3f20b641f9f93787ada49d1d7cfa98ee5a11e
Author: \"J. Bruce Fields\ <bfields@citi.umich.edu>
Date:   Tue Dec 23 16:10:52 2008 -0500

    rpc: use count of pipe openers to wait for first open
    
    Introduce a global variable pipe_version which will eventually be used
    to keep track of which version of the upcall gssd is using.
    
    For now, though, it only keeps track of whether any pipe is open or not;
    it is negative if not, zero if one is opened.  We use this to wait for
    the first gssd to open a pipe.
    
    (Minor digression: note this waits only for the very first open of any
    pipe, not for the first open of a pipe for a given auth; thus we still
    need the RPC_PIPE_WAIT_FOR_OPEN behavior to wait for gssd to open new
    pipes that pop up on subsequent mounts.)
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cf81939d6fcdf381fcb069d780c29eceb516bccd
Author: \"J. Bruce Fields\ <bfields@citi.umich.edu>
Date:   Tue Dec 23 16:10:19 2008 -0500

    rpc: track number of users of the gss upcall pipe
    
    Keep a count of the number of pipes open plus the number of messages on
    a pipe.  This count isn't used yet.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e712804ae4bd858bd89272aa3fc1a577294c0940
Author: \"J. Bruce Fields\ <bfields@citi.umich.edu>
Date:   Tue Dec 23 16:09:47 2008 -0500

    rpc: call release_pipe only on last close
    
    I can't see any reason we need to call this until either the kernel or
    the last gssd closes the pipe.
    
    Also, this allows to guarantee that open_pipe and release_pipe are
    called strictly in pairs; open_pipe on gssd's first open, release_pipe
    on gssd's last close (or on the close of the kernel side of the pipe, if
    that comes first).
    
    That will make it very easy for the gss code to keep track of which
    pipes gssd is using.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c381060869317b3c84430d4f54965d409cbfe65f
Author: \"J. Bruce Fields\ <bfields@citi.umich.edu>
Date:   Tue Dec 23 16:08:32 2008 -0500

    rpc: add an rpc_pipe_open method
    
    We want to transition to a new gssd upcall which is text-based and more
    easily extensible.
    
    To simplify upgrades, as well as testing and debugging, it will help if
    we can upgrade gssd (to a version which understands the new upcall)
    without having to choose at boot (or module-load) time whether we want
    the new or the old upcall.
    
    We will do this by providing two different pipes: one named, as
    currently, after the mechanism (normally "krb5"), and supporting the
    old upcall.  One named "gssd" and supporting the new upcall version.
    
    We allow gssd to indicate which version it supports by its choice of
    which pipe to open.
    
    As we have no interest in supporting *simultaneous* use of both
    versions, we'll forbid opening both pipes at the same time.
    
    So, add a new pipe_open callback to the rpc_pipefs api, which the gss
    code can use to track which pipes have been open, and to refuse opens of
    incompatible pipes.
    
    We only need this to be called on the first open of a given pipe.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit db75b3d6b5b0dad29860370618ea94d2726641b4
Author: \"J. Bruce Fields\ <bfields@citi.umich.edu>
Date:   Tue Dec 23 16:07:13 2008 -0500

    rpc: minor gss_alloc_msg cleanup
    
    I want to add a little more code here, so it'll be convenient to have
    this flatter.
    
    Also, I'll want to add another error condition, so it'll be more
    convenient to return -ENOMEM than NULL in the error case.  The only
    caller is already converting NULL to -ENOMEM anyway.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b03568c32226163cb3588ea8993adb268ed497a5
Author: \"J. Bruce Fields\ <bfields@citi.umich.edu>
Date:   Tue Dec 23 16:06:55 2008 -0500

    rpc: factor out warning code from gss_pipe_destroy_msg
    
    We'll want to call this from elsewhere soon.  And this is a bit nicer
    anyway.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 99db35636842ede13bf3b6bf1a8d8f4f1c4c93bf
Author: \"J. Bruce Fields\ <bfields@citi.umich.edu>
Date:   Tue Dec 23 16:06:33 2008 -0500

    rpc: remove unnecessary assignment
    
    We're just about to kfree() gss_auth, so there's no point to setting any
    of its fields.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cf8cdbe5bd662eeaece96b017a4d6676ae416537
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Dec 23 16:06:18 2008 -0500

    NFS: remove unused status from encode routines
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d017931cff77f2a1603c9c76e96477743abc9f41
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Dec 23 16:06:17 2008 -0500

    NFS: increment number of operations in each encode routine
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 49c2559e29884fbb13fd273a108b213decd1d8a5
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Tue Dec 23 16:06:16 2008 -0500

    NFS: fix comment placement in nfs4xdr.c
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 05d564fe00c05bf8ff93948057ca1acb5bc68e10
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Dec 23 16:06:15 2008 -0500

    NFS: fix tabs in nfs4xdr.c
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6c0195a4681c08335a33a483be801aaf0ed7f192
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Dec 23 16:06:15 2008 -0500

    NFS: remove white space from nfs4xdr.c
    
    Clean-up
    
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 374130770efc80418b155b2966ff958495e03948
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Tue Dec 23 16:06:14 2008 -0500

    nfs: remove incorrect usage of nfs4 compound response hdr.status
    
    3 call sites look at hdr.status before returning success.
    hdr.status must be zero in this case so there's no point in this.
    
    Currently, hdr.status is correctly processed at decode_op_hdr time
    if the op status cannot be decoded.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit aadf61521199e5c0b2976002213819cafa41b897
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Tue Dec 23 16:06:13 2008 -0500

    nfs: return compound hdr.status when there are no op replies
    
    When there are no op replies encoded in the compound reply
    hdr.status still contains the overall status of the compound
    rpc.  This can happen, e.g., when the server returns a
    NFS4ERR_MINOR_VERS_MISMATCH error.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c977a2ef40a38c45537ad03823d0a004f06373f0
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Tue Dec 23 16:06:13 2008 -0500

    sunrpc: get rid of rpc_rqst.rq_bufsize
    
    rq_bufsize is not used.
    
    Signed-off-by: Mike Sager <Mike.Sager@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 027b6ca02192f381a5a91237ba8a8cf625dc6f6a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 16:04:13 2008 -0500

    NFSv4: Fix an infinite loop in the NFS state recovery code
    
    Marten Gajda <marten.gajda-PdBPhxpS/JMDwj1Imt9BnQ@public.gmane.org> states:
    
    I tracked the problem down to the function nfs4_do_open_expired.
    Within this function _nfs4_open_expired is called and may return
    -NFS4ERR_DELAY. When a further call to _nfs4_open_expired is
    executed and does not return -NFS4ERR_DELAY the "exception.retry"
    variable is not reset to 0, causing the loop to iterate again
    (and as long as err != -NFS4ERR_DELAY, probably forever)
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6dcd3926b214a1fb081df18305921dedae269977
Author: Jeff Layton <jlayton@redhat.com>
Date:   Tue Dec 23 15:21:57 2008 -0500

    sunrpc: fix code that makes auth_gss send destroy_cred message (try #2)
    
    There's a bit of a chicken and egg problem when it comes to destroying
    auth_gss credentials. When we destroy the last instance of a GSSAPI RPC
    credential, we should send a NULL RPC call with a GSS procedure of
    RPCSEC_GSS_DESTROY to hint to the server that it can destroy those
    creds.
    
    This isn't happening because we're setting clearing the uptodate bit on
    the credentials and then setting the operations to the gss_nullops. When
    we go to do the RPC call, we try to refresh the creds. That fails with
    -EACCES and the call fails.
    
    Fix this by not clearing the UPTODATE bit for the credentials and adding
    a new crdestroy op for gss_nullops that just tears down the cred without
    trying to destroy the context.
    
    The only difference between this patch and the first one is the removal
    of some minor formatting deltas.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 64672d55d93c26fb4035fd1a84a803cbc09cb058
Author: Peter Staubach <staubach@redhat.com>
Date:   Tue Dec 23 15:21:56 2008 -0500

    optimize attribute timeouts for "noac" and "actimeo=0"
    
    Hi.
    
    I've been looking at a bugzilla which describes a problem where
    a customer was advised to use either the "noac" or "actimeo=0"
    mount options to solve a consistency problem that they were
    seeing in the file attributes.  It turned out that this solution
    did not work reliably for them because sometimes, the local
    attribute cache was believed to be valid and not timed out.
    (With an attribute cache timeout of 0, the cache should always
    appear to be timed out.)
    
    In looking at this situation, it appears to me that the problem
    is that the attribute cache timeout code has an off-by-one
    error in it.  It is assuming that the cache is valid in the
    region, [read_cache_jiffies, read_cache_jiffies + attrtimeo].  The
    cache should be considered valid only in the region,
    [read_cache_jiffies, read_cache_jiffies + attrtimeo).  With this
    change, the options, "noac" and "actimeo=0", work as originally
    expected.
    
    This problem was previously addressed by special casing the
    attrtimeo == 0 case.  However, since the problem is only an off-
    by-one error, the cleaner solution is address the off-by-one
    error and thus, not require the special case.
    
        Thanx...
    
            ps
    
    Signed-off-by: Peter Staubach <staubach@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dc0b027dfadfcb8a5504f7d8052754bf8d501ab9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:56 2008 -0500

    NFSv4: Convert the open and close ops to use fmode
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7a50c60e461f6ff97428da9448c3dad5b7bef491
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:55 2008 -0500

    NFS: Use delegations to optimise ACCESS calls
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 15860ab1d7700249ebe3b0b8ca86ce43dfd0d66f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:54 2008 -0500

    NFSv4: Ensure that we set the verifier when revalidating delegated dentries
    
    This ensures that we don't have to look up the dentry again after we return
    the delegation if we know that the directory didn't change.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5584c30630f8a4aac557093b1603e166fe7385be
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:54 2008 -0500

    NFSv4: Clean up is_atomic_open()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bd7bf9d540c001055fba796ebf146d90e4dd2eb2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:53 2008 -0500

    NFSv4: Convert delegation->type field to fmode_t
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9082a5cc1e33d081f091f54e6ed69a0628a4bdcc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:53 2008 -0500

    NFSv4: Fix up delegation callbacks
    
    Currently, the callback server is listening on IPv6 if it is enabled. This
    means that IPv4 addresses will always be mapped.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b7391f44f26b17ad25c7183a3d6ad50f0a9305ff
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:52 2008 -0500

    NFSv4: Return unreferenced delegations more promptly
    
    If the client is not using a delegation, the right thing to do is to return
    it as soon as possible. This helps reduce the amount of state the server
    has to track, as well as reducing the potential for conflicts with other
    clients.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6411bd4a471893ab2af103d96253ba97c92d4777
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:51 2008 -0500

    NFSv4: Clean up the asynchronous delegation return
    
    Reuse the state management thread in order to return delegations when we
    get a callback.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b0d3ded1a21dc3057daff5a488469d9e6aa1b567
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:50 2008 -0500

    NFSv4: Clean up nfs_expire_all_delegations()
    
    Let the actual delegreturn stuff be run in the state manager thread rather
    than allocating a separate kthread.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0d62f85a81216f30a0ba1479b93e84103a5d535b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:49 2008 -0500

    NFSv4: Fix a BAD_SEQUENCEID condition.
    
    We really shouldn't be resetting the sequence ids when doing state
    expiration recovery, since we don't know if the server still remembers our
    previous state owners. There are servers out there that do attempt to
    preserve client state even if the lease has expired. Such a server would
    only release that state if a conflicting OPEN request occurs.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f3c76491e7ecacbb7942633f3b2a3514b7476ef9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:48 2008 -0500

    NFSv4: Don't exit the state management if there are still tasks to do
    
    Fix up a potential race...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e005e8041c132af9f70862e1387a222198f95e7f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:48 2008 -0500

    NFSv4: Rename the state reclaimer thread
    
    It is really a more general purpose state management thread at this point.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 707fb4b324371f1b4bea5eb29e39d265c66086ae
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:47 2008 -0500

    NFSv4: Clean up NFS4ERR_CB_PATH_DOWN error management...
    
    Add a delegation cleanup phase to the state management loop, and do the
    NFS4ERR_CB_PATH_DOWN recovery there.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 515d86117724abe39d7d57d7ccc7cc5c44480529
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:46 2008 -0500

    NFSv4: Clean up the support for returning multiple delegations
    
    Add a flag to mark delegations as requiring return, then run a garbage
    collector. In the future, this will allow for more flexible delegation
    management, where delegations may be marked for return if it turns out
    that they are not being referenced.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9e33bed55239bdcee1746c31a11177d239bac1b5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:46 2008 -0500

    NFSv4: Add recovery for individual stateids
    
    NFSv4 defines a number of state errors which the client does not currently
    handle. Among those we should worry about are:
      NFS4ERR_ADMIN_REVOKED - the server's administrator revoked our locks
      			  and/or delegations.
      NFS4ERR_BAD_STATEID - the client and server are out of sync, possibly
                            due to a delegation return racing with an OPEN
    			request.
      NFS4ERR_OPENMODE - the client attempted to do something not sanctioned
      		     by the open mode of the stateid. Should normally just
    		     occur as a result of a delegation return race.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 95d35cb4c473c754824967c0b069bbeb7efa4847
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:45 2008 -0500

    NFSv4: Remove nfs_client->cl_sem
    
    Now that we're using the flags to indicate state that needs to be
    recovered, as well as having implemented proper refcounting and spinlocking
    on the state and open_owners, we can get rid of nfs_client->cl_sem. The
    only remaining case that was dubious was the file locking, and that case is
    now covered by the nfsi->rwsem.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 19e03c570e6099ffaf24e5628d4fe1a8acbe820d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:44 2008 -0500

    NFSv4: Ensure that file unlock requests don't conflict with state recovery
    
    The unlock path is currently failing to take the nfs_client->cl_sem read
    lock, and hence the recovery path may see locks disappear from underneath
    it.
    Also ensure that it takes the nfs_inode->rwsem read lock so that it there
    is no conflict with delegation recalls.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 65de872ed6501a68e918a49a5c2fa7fca9c6ce21
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:44 2008 -0500

    NFS: Remove the unnecessary argument to nfs4_wait_clnt_recover()
    
    ...and move some code around in order to clear out an unnecessary
    forward declaration.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fe1d81952e7f62b9da7dc438caaa07e35ec2b908
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:43 2008 -0500

    NFSv4: Ensure that nfs4_reclaim_open_state() doesn't depend on cl_sem
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7eff03aec917e17f733471d7e12c262c0c96409f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:43 2008 -0500

    NFSv4: Add a recovery marking scheme for state owners
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0f605b56008c4b6b075217480c36ba395ca4eaa4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:42 2008 -0500

    NFSv4: Don't tell server we rebooted when not necessary
    
    Instead of doing a full setclientid, try doing a RENEW call first.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e598d843c08a7ab6bdfa8098de49afb017fc6c6a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:42 2008 -0500

    NFSv4: Remove redundant RENEW calls if we know the lease has expired
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b79a4a1b45b2543e38026303a1956bdc0aababa0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:41 2008 -0500

    NFSv4: Fix state recovery when the client runs over the grace period
    
    If the client for some reason is not able to recover all its state within
    the time allotted for the grace period, and the server reboots again, the
    client is not allowed to recover the state that was 'lost' using reboot
    recovery.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6dc9d57af9917f5c7faa13c17b770dce17c3972b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:41 2008 -0500

    NFSv4: Callers to nfs4_get_renew_cred() need to hold nfs_client->cl_lock
    
    Ditto for nfs4_get_setclientid_cred().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 028600143079c8e8f8366bbc2eb29977743baf3a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:40 2008 -0500

    NFSv4: Clean up for the state loss reclaimer
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 15c831bf1a3f8cab9812a96228145200726fea33
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:39 2008 -0500

    NFS: Use atomic bitops when changing struct nfs_delegation->flags
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 86e894899820f2b3094d5557124fc22743ae0fc7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:39 2008 -0500

    NFSv4: Fix up the dereferencing of delegation->inode
    
    Without an extra lock, we cannot just assume that the delegation->inode is
    valid when we're traversing the rcu-protected nfs_client lists. Use the
    delegation->lock to ensure that it is truly valid.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 343104308a33c4f1e23c8e841ede95e97b870842
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:38 2008 -0500

    NFSv4: Fix up another delegation related race
    
    When we can update_open_stateid(), we need to be certain that we don't
    race with a delegation return. While we could do this by grabbing the
    nfs_client->cl_lock, a dedicated spin lock in the delegation structure
    will scale better.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0cb2659b818eca99235e17c04291cfa9985c14f7
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 23 15:21:38 2008 -0500

    NLM: allow lockd requests from an unprivileged port
    
    If the admin has specified the "noresvport" option for an NFS mount
    point, the kernel's NFS client uses an unprivileged source port for
    the main NFS transport.  The kernel's lockd client should use an
    unprivileged port in this case as well.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 50a737f86dbf99daf3a8dcbdf778a3be36bb2a39
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 23 15:21:37 2008 -0500

    NFS: "[no]resvport" mount option changes mountd client too
    
    If the admin has specified the "noresvport" option for an NFS mount
    point, the kernel's NFS client uses an unprivileged source port for
    the main NFS transport.  The kernel's mountd client should use an
    unprivileged port in this case as well.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d740351bf0960e89ce1aef45cfe00167cb0f9e5b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 23 15:21:37 2008 -0500

    NFS: add "[no]resvport" mount option
    
    The standard default security setting for NFS is AUTH_SYS.  An NFS
    client connects to NFS servers via a privileged source port and a
    fixed standard destination port (2049).  The client sends raw uid and
    gid numbers to identify users making NFS requests, and the server
    assumes an appropriate authority on the client has vetted these
    values because the source port is privileged.
    
    On Linux, by default in-kernel RPC services use a privileged port in
    the range between 650 and 1023 to avoid using source ports of well-
    known IP services.  Using such a small range limits the number of NFS
    mount points and the number of unique NFS servers to which a client
    can connect concurrently.
    
    An NFS client can use unprivileged source ports to expand the range of
    source port numbers, allowing more concurrent server connections and
    more NFS mount points.  Servers must explicitly allow NFS connections
    from unprivileged ports for this to work.
    
    In the past, bumping the value of the sunrpc.max_resvport sysctl on
    the client would permit the NFS client to use unprivileged ports.
    Bumping this setting also changes the maximum port number used by
    other in-kernel RPC services, some of which still required a port
    number less than 1023.
    
    This is exacerbated by the way source port numbers are chosen by the
    Linux RPC client, which starts at the top of the range and works
    downwards.  It means that bumping the maximum means all RPC services
    requesting a source port will likely get an unprivileged port instead
    of a privileged one.
    
    Changing this setting effects all NFS mount points on a client.  A
    sysadmin could not selectively choose which mount points would use
    non-privileged ports and which could not.
    
    Lastly, this mechanism of expanding the limit on the number of NFS
    mount points was entirely undocumented.
    
    To address the need for the NFS client to use a large range of source
    ports without interfering with the activity of other in-kernel RPC
    services, we introduce a new NFS mount option.  This option explicitly
    tells only the NFS client to use a non-privileged source port when
    communicating with the NFS server for one specific mount point.
    
    This new mount option is called "resvport," like the similar NFS mount
    option on FreeBSD and Mac OS X.  A sister patch for nfs-utils will be
    submitted that documents this new option in nfs(5).
    
    The default setting for this new mount option requires the NFS client
    to use a privileged port, as before.  Explicitly specifying the
    "noresvport" mount option allows the NFS client to use an unprivileged
    source port for this mount point when connecting to the NFS server
    port.
    
    This mount option is supported only for text-based NFS mounts.
    
    [ Sidebar: it is widely known that security mechanisms based on the
      use of privileged source ports are ineffective.  However, the NFS
      client can combine the use of unprivileged ports with the use of
      secure authentication mechanisms, such as Kerberos.  This allows a
      large number of connections and mount points while ensuring a useful
      level of security.
    
      Eventually we may change the default setting for this option
      depending on the security flavor used for the mount.  For example,
      if the mount is using only AUTH_SYS, then the default setting will
      be "resvport;" if the mount is using a strong security flavor such
      as krb5, the default setting will be "noresvport." ]
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    [Trond.Myklebust@netapp.com: Fixed a bug whereby nfs4_init_client()
    was being called with incorrect arguments.]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 542fcc334adfea36d407cbf698d549fcb2bf6b91
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 23 15:21:36 2008 -0500

    NFS: move nfs_server flag initialization
    
    Make it possible for the NFSv4 mount set up logic to pass mount option
    flags down the stack to nfs_create_rpc_client().
    
    This is immediately useful if we want NFS mount options to modulate
    settings of the underlying RPC transport, but it may be useful at some
    later point if other parts of the NFSv4 mount initialization logic
    want to know what the mount options are.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4a01b8a4ee7b12becd26a49bae57f019605658cd
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 23 15:21:35 2008 -0500

    NFS: expand flags passed to nfs_create_rpc_client()
    
    The nfs_create_rpc_client() function sets up an RPC client for an NFS
    mount point.  Add an option that allows it to set up an RPC transport
    from an unprivileged port.
    
    Instead of having nfs_create_rpc_client()'s callers retain local
    knowledge about how to set up an RPC client, create a couple of flag
    arguments to control the use of RPC_CLNT_CREATE flags.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c5d120f8e8b464368a7dcb038dc5c077d234d10a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 23 15:21:35 2008 -0500

    NFS: introduce nfs_mount_info struct for calling nfs_mount()
    
    Clean up: convert nfs_mount() to take a single data structure argument to make
    it simpler to add more arguments.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 146ec944bbd31d241a44a00518b054fb01921d22
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 23 15:21:34 2008 -0500

    NFS: Move declaration of nfs_mount() to fs/nfs/internal.h
    
    Clean up:  The nfs_mount() function is not to be used outside of the
    NFS client.  Move its public declaration to fs/nfs/internal.h.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7b5d2b98e118716dd1ccc2808fae88f6c4b16d54
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 23 15:21:34 2008 -0500

    NFS: rename nfs_path variable
    
    Clean up: I'm about to move the declaration of nfs_mount into
    fs/nfs/internal.h and include it in fs/nfs/nfsroot.c.  There's a
    conflicting definition of nfs_path in fs/nfs/internal.h and
    fs/nfs/nfsroot.c, so rename the private one.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit df94f000c46c055cf439f5b92807cd827557ffbc
Author: Jeff Layton <jlayton@redhat.com>
Date:   Tue Dec 23 15:21:33 2008 -0500

    lockd: convert reclaimer thread to kthread interface
    
    My understanding is that there is a push to turn the kernel_thread
    interface into a non-exported symbol and move all kernel threads to use
    the kthread API. This patch changes lockd to use kthread_run to spawn
    the reclaimer thread.
    
    I've made the assumption here that the extra module references taken
    when we spawn this thread are unnecessary and removed them. I've also
    added a KERN_ERR printk that pops if the thread can't be spawned to warn
    the admin that the locks won't be reclaimed.
    
    In the future, it would be nice to be able to notify userspace that
    locks have been lost (probably by implementing SIGLOST), and adding some
    good policies about how long we should reattempt to reclaim the locks.
    
    Finally, I removed a comment about memory leaks that I believe is
    obsolete and added a new one to clarify the result of sending a SIGKILL
    to the reclaimer thread. As best I can tell, doing so doesn't actually
    cause a memory leak.
    
    I consider this patch 2.6.29 material.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2de59872a7842143f4507832e7c1f5123c47feb7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:33 2008 -0500

    LOCKD: Make lockd_up() and lockd_down() exported GPL-only
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d716f0b8a57f8577bcd869e7dcb5a0add9f6fc5e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:32 2008 -0500

    SUNRPC: nfsacl_encode/nfsacl_decode should be exported as GPL-only
    
    Again, this has never been intended as a public abi for out-of-tree
    modules.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7bd8826915989f1bd6917c11b0a4151b129e68cb
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:32 2008 -0500

    SUNRPC: rpcsec_gss modules should not be used by out-of-tree code
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 468039ee469c5772d3e39f736923c5e0c31017e2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:31 2008 -0500

    SUNRPC: Convert the xdr helpers and rpc_pipefs to EXPORT_SYMBOL_GPL
    
    We've never considered the sunrpc code as part of any ABI to be used by
    out-of-tree modules.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 88a9fe8cae3bb52e82489447f45e8d7ba1409ca8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 23 15:21:31 2008 -0500

    SUNRPC: Remove the last remnant of the BKL...
    
    Somehow, this escaped the previous purge. There should be no need to keep
    any extra locks in the XDR callbacks.
    
    The NFS client XDR code only writes into private objects, whereas all reads
    of shared objects are confined to fields that do not change, such as
    filehandles...
    
    Ditto for lockd, the NFSv2/v3 client mount code, and rpcbind.
    
    The nfsd XDR code may require the BKL, but since it does a synchronous RPC
    call from a thread that already holds the lock, that issue is moot.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 136221fc3219b3805c48db5da065e8e3467175d4
Author: Wu Fengguang <fengguang.wu@intel.com>
Date:   Tue Dec 23 15:21:30 2008 -0500

    nfs: remove redundant tests on reading new pages
    
    aops->readpages() and its NFS helper readpage_async_filler() will only
    be called to do readahead I/O for newly allocated pages. So it's not
    necessary to test for the always 0 dirty/uptodate page flags.
    
    The removal of nfs_wb_page() call also fixes a readahead bug: the NFS
    readahead has been synchronous since 2.6.23, because that call will
    clear PG_readahead, which is the reminder for asynchronous readahead.
    
    More background: the PG_readahead page flag is shared with PG_reclaim,
    one for read path and the other for write path. clear_page_dirty_for_io()
    unconditionally clears PG_readahead to prevent possible readahead residuals,
    assuming itself to be always called in the write path. However, NFS is one
    and the only exception in that it _always_ calls clear_page_dirty_for_io()
    in the read path, i.e. for readpages()/readpage().
    
    Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    Signed-off-by: Wu Fengguang <wfg@linux.intel.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
