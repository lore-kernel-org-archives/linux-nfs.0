From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [GIT] NFS client updates for 2.6.22...
Date: Wed, 02 May 2007 07:52:51 -0700
Message-ID: <1178117571.5435.10.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjGCo-0005ET-2o
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 07:53:24 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18769m8qTRx2px+cRJ2ZK9AQphmUx7Pxw4=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjGCo-00076g-91
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 07:53:23 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/Kconfig                           |   12 +
 fs/lockd/mon.c                       |   10 +-
 fs/lockd/xdr.c                       |   20 +-
 fs/lockd/xdr4.c                      |   24 +-
 fs/nfs/client.c                      |    3 +-
 fs/nfs/dir.c                         |   20 ++
 fs/nfs/direct.c                      |    5 +-
 fs/nfs/internal.h                    |   12 +
 fs/nfs/mount_clnt.c                  |    7 +-
 fs/nfs/nfs2xdr.c                     |    7 +-
 fs/nfs/nfs3xdr.c                     |   13 +-
 fs/nfs/nfs4proc.c                    |    3 +-
 fs/nfs/nfs4xdr.c                     |    7 +-
 fs/nfs/nfsroot.c                     |    2 +-
 fs/nfs/pagelist.c                    |  242 +++++++------
 fs/nfs/read.c                        |   92 ++----
 fs/nfs/super.c                       |   10 +-
 fs/nfs/write.c                       |  258 +++++----------
 fs/nfsd/nfs4callback.c               |    7 +-
 include/linux/lockd/lockd.h          |    2 +-
 include/linux/nfs_fs.h               |    4 +-
 include/linux/nfs_mount.h            |    1 +
 include/linux/nfs_page.h             |   33 ++-
 include/linux/sunrpc/clnt.h          |    9 +-
 include/linux/sunrpc/debug.h         |    2 +-
 include/linux/sunrpc/msg_prot.h      |    4 -
 include/linux/sunrpc/sched.h         |    2 +-
 include/linux/sunrpc/xprt.h          |    7 +-
 include/linux/writeback.h            |    2 +
 net/sunrpc/Makefile                  |    2 +-
 net/sunrpc/auth_gss/gss_spkm3_seal.c |   13 +-
 net/sunrpc/clnt.c                    |   69 +++--
 net/sunrpc/pmap_clnt.c               |  383 ---------------------
 net/sunrpc/rpcb_clnt.c               |  625 ++++++++++++++++++++++++++++++++++
 net/sunrpc/sched.c                   |   65 ++--
 net/sunrpc/svc.c                     |    2 +-
 net/sunrpc/xprt.c                    |    4 +-
 net/sunrpc/xprtsock.c                |    4 +-
 38 files changed, 1105 insertions(+), 882 deletions(-)

commit a19b89cad51b6f0da8f4bafdfdcfb10264cbcdea
Author: Jason Uhlenkott <juhlenko@akamai.com>
Date:   Thu Apr 26 17:25:51 2007 -0700

    NFS: Clean up nfs_create_request comments
    
    Remove some stale comments about hard limits which went away in 2.5.
    
    Signed-off-by: Jason Uhlenkott <juhlenko@akamai.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 61322b30139b79ec77170723a3a80043dcc94e87
Author: J. Bruce Fields - unquoted <bfields@snoopy.citi.umich.edu>
Date:   Sat Feb 10 01:33:27 2007 -0500

    spkm3: initialize hash
    
    There's an initialization step here I missed.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b80e183deff5f3d43565b552ed91e511128a6ea9
Author: J. Bruce Fields - unquoted <bfields@snoopy.citi.umich.edu>
Date:   Sat Feb 10 01:33:26 2007 -0500

    spkm3: remove bad kfree, unnecessary export
    
    We're kfree()'ing something that was allocated on the stack!
    
    Also remove an unnecessary symbol export while we're at it.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f32824d8ca9d3f84613ae2422070cc5469fe9e91
Author: J. Bruce Fields - unquoted <bfields@snoopy.citi.umich.edu>
Date:   Sat Feb 10 01:33:25 2007 -0500

    spkm3: fix spkm3's use of hmac
    
    I think I botched an attempt to keep an spkm3 patch up-to-date with a recent
    crypto api change.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 08efa202eb398ce7939885a4a01df370fd392068
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue May 1 10:56:25 2007 -0400

    NFS4: invalidate cached acl on setacl
    
    The ACL that the server sets may not be exactly the one we set--for
    example, it may silently turn off bits that it does not support.  So we
    should remove any cached ACL so that any subsequent request for the ACL
    will go to the server.
    
    Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 83672d392f7bcf556f7920d6715e4174d9373ee0
Author: Neil Brown <neilb@suse.de>
Date:   Mon Feb 26 12:48:25 2007 +1100

    NFS: Fix directory caching problem - with test case and patch.
    
    Try running this script in an NFS mounted directory (Client relatively
    recent - 2.6.18 has the problem as does 2.6.20).
    
    ------------------------------------------------------
    #!/bin/bash
    #
    # This script will produce the following errormessage from tar:
    #
    #   tar: newdir/innerdir/innerfile: file changed as we read it
    
    # create dirs
    rm -rf nfstest
    mkdir -p nfstest/dir/innerdir
    
    # create files (should not be empty)
    echo "Hello World!" >nfstest/dir/file
    echo "Hello World!" >nfstest/dir/innerdir/innerfile
    
    # problem only happens if we sleep before chmod
    sleep 1
    
    # change file modes
    chmod -R a+r nfstest
    
    # rename dir
    mv nfstest/dir nfstest/newdir
    
    # tar it
    tar -cf nfstest/nfstest.tar -C nfstest newdir
    
    # restore old dir name
    mv nfstest/newdir nfstest/dir
    --------------------------------------------------------
    
    What happens:
    
    The 'chmod -R' does a readdir_plus in each directory and the results
    get cached in the page cache.  It then updates the ctime on each file
    by one second.  When this happens, the post-op attributes are used to
    update the ctime stored on the client to match the value in the kernel.
    
    The 'mv' calls shrink_dcache_parent on the directory tree which
    flushes all the dentries (so a new lookup will be required) but
    doesn't flush the inodes or pagecache.
    
    The 'tar' does a readdir on each directory, but (in the case of
    'innerdir' at least) satisfies it from the pagecache and uses the
    READDIRPLUS data to update all the inodes.  In the case of
    'innerdir/innerfile', the ctime is out of date.
    
    'tar' then calls 'lstat' on innerdir/innerfile getting an old ctime.
    It then opens the file (triggering a GETATTR), reads the content, and
    then calls fstat to see if anything has changed.  It finds that ctime
    has changed and so complains.
    
    The problem seems to be that the cache readdirplus info is kept around
    for too long.
    
    My patch below discards pagecache data for directories when
    dentry_iput is called on them.  This effectively removes the symptom
    which convinces me that I correctly understand the problem.  However
    I'm not convinced that is a proper solution, as there could easily be
    other races that trigger the same problem without being affected by
    this 'fix'.
    
    One possibility would be to require that readdirplus pagecache data be
    only used *once* to instantiate an inode.  Somehow it should then be
    invalidated so that if the dentry subsequently disappears, it will
    cause a new request to the server to fill in the stat data.
    
    Another possibility is to compare the cache_change_attribute on the
    inode with something similar for the readdirplus info and reject the
    info from readdirplus if it is too old.
    
    I haven't tried to implement these and would value other opinions
    before I do.
    
    Thanks,
    NeilBrown
    
    
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1f4eab7e7c1d90dcd8ca4d7c064ee78dfbb345eb
Author: Neil Brown <neilb@suse.de>
Date:   Mon Apr 16 09:35:27 2007 +1000

    NFS: Set meaningful value for fattr->time_start in readdirplus results.
    
    Don't use uninitialsed value for fattr->time_start in readdirplus results.
    
    The 'fattr' structure filled in by nfs3_decode_direct does not get a
    value for ->time_start set.
    Thus if an entry is for an inode that we already have in cache,
    when nfs_readdir_lookup calls nfs_fhget, it will call nfs_refresh_inode
    and may update the inode with out-of-date information.
    
    Directories are read a page at a time, so each page could have a
    different timestamp that "should" be used to set the time_start for
    the fattr for info in that page.  However storing the timestamp per
    page is awkward.  (We could stick in the first 4 bytes and only read 4092
    bytes, but that is a bigger code change than I am interested it).
    
    This patch ignores the readdir_plus attributes if a readdir finds the
    information already in cache, and otherwise sets ->time_start to the time
    the readdir request was sent to the server.
    
    It might be nice to store - in the directory inode - the time stamp for
    the earliest readdir request that is still in the page cache, so that we
    don't ignore attribute data that we don't have to.  This patch doesn't do
    that.
    
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 74dd34e6e8bb127ff4c182423154b294729b663b
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Apr 14 17:01:15 2007 -0400

    NFS: Added support to turn off the NFSv3 READDIRPLUS RPC.
    
    READDIRPLUS can be a performance hindrance when the client is working with
    large directories. In addition, some servers still have bugs in their
    implementations (e.g. Tru64 returns wrong values for the fsid).
    
    Add a mount flag to enable users to turn it off at mount time following the
    implementation in Apple's NFS client.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 00a6e7bbf990e3a5e59a9a1e6a68e99c94fe001c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 29 16:48:33 2007 -0400

    SUNRPC: RPC client should retry with different versions of rpcbind
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4c2eaf073f0cc2b5bf593b8133c078b9d9406e95
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 29 16:48:27 2007 -0400

    SUNRPC: remove old portmapper
    
    net/sunrpc/pmap_clnt.c has been replaced by net/sunrpc/rpcb_clnt.c.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit df8b172a8880521396d2048ecef7e75df43b5bc4
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 29 16:48:22 2007 -0400

    NFS: switch NFSROOT to use new rpcbind client
    
    It is arguable whether NFSROOT will support IPv6, and thus whether
    rpcb_getport_external needs to support rpcbind versions greater than 2.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 260800142071a3a33e4523c7578358c6e29c0f53
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 29 16:48:16 2007 -0400

    SUNRPC: switch the RPC server to use the new rpcbind registration API
    
    Eventually this interface will support versions 3 and 4 of the rpcbind
    protocol, which will allow the Linux RPC server to register services on
    IPv6 addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e9b1c9c98c051f49a76dcd76f914c02653aecccb
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 29 16:48:10 2007 -0400

    SUNRPC: switch socket-based RPC transports to use rpcbind
    
    Now that we have a version of the portmapper that supports versions 3 and 4
    of the rpcbind protocol, use it for new RPC client connections over
    sockets.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a509050bd3b8e0aa269c2241aa10d74ca7701e2f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 29 16:48:04 2007 -0400

    SUNRPC: introduce rpcbind: replacement for in-kernel portmapper
    
    Introduce a replacement for the in-kernel portmapper client that supports
    all 3 versions of the rpcbind protocol.  This code is not used yet.
    
    Original code by Groupe Bull updated for the latest kernel, with multiple
    bug fixes.
    
    Note that rpcb_clnt.c does not yet support registering via versions 3 and
    4 of the rpcbind protocol.  That is planned for a later patch.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c5a4dd8b7c15927a8fbff83171b57cad675a79b9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 29 16:47:58 2007 -0400

    SUNRPC: Eliminate side effects from rpc_malloc
    
    Currently rpc_malloc sets req->rq_buffer internally.  Make this a more
    generic interface:  return a pointer to the new buffer (or NULL) and
    make the caller set req->rq_buffer and req->rq_bufsize.  This looks much
    more like kmalloc and eliminates the side effects.
    
    To fix a potential deadlock, this patch also replaces GFP_NOFS with
    GFP_NOWAIT in rpc_malloc.  This prevents async RPCs from sleeping outside
    the RPC's task scheduler while allocating their buffer.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2bea90d43a050bbc4021d44e59beb34f384438db
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 29 16:47:53 2007 -0400

    SUNRPC: RPC buffer size estimates are too large
    
    The RPC buffer size estimation logic in net/sunrpc/clnt.c always
    significantly overestimates the requirements for the buffer size.
    A little instrumentation demonstrated that in fact rpc_malloc was never
    allocating the buffer from the mempool, but almost always called kmalloc.
    
    To compute the size of the RPC buffer more precisely, split p_bufsiz into
    two fields; one for the argument size, and one for the result size.
    
    Then, compute the sum of the exact call and reply header sizes, and split
    the RPC buffer precisely between the two.  That should keep almost all RPC
    buffers within the 2KiB buffer mempool limit.
    
    And, we can finally be rid of RPC_SLACK_SPACE!
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 511d2e8855a065c8251d0c140ebc353854f1929e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 29 16:47:47 2007 -0400

    NLM: Shrink the maximum request size of NLM4 requests
    
    NLM version 4 requests estimate the call and reply header sizes rather
    conservatively, using the very maximum size allowed in the protocol even
    though Linux always uses only a small fraction of the allowable space.
    
    Reduce the size of caller and lock arguments to conserve RPC buffer space
    while XDR encoding NLM4 arguments.  Add compile-time checks to ensure the
    hostname string won't overflow NLM protocol maximums.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ca52fec152282ef73e5e882b847b36b1febbb1c6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 17 17:22:13 2007 -0400

    NFS: Use pgoff_t in structures and functions that pass page cache offsets
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 724c439c204b12a3537b71289fb4c0a42c3aa566
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 17 17:22:13 2007 -0400

    NFS: Clean up nfs_sync_mapping_wait()
    
    It has no business touching wbc->pages_skipped.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8d5658c949e6d89edc579a1f112aeee3bc232a8e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 10 09:26:35 2007 -0400

    NFS: Fix a buffer overflow in the allocation of struct nfs_read/writedata
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c63c7b051395368573779c8309aa5c990dcf2f96
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 2 19:29:52 2007 -0400

    NFS: Fix a race when doing NFS write coalescing
    
    Currently we do write coalescing in a very inefficient manner: one pass in
    generic_writepages() in order to lock the pages for writing, then one pass
    in nfs_flush_mapping() and/or nfs_sync_mapping_wait() in order to gather
    the locked pages for coalescing into RPC requests of size "wsize".
    
    In fact, it turns out there is actually a deadlock possible here since we
    only start I/O on the second pass. If the user signals the process while
    we're in nfs_sync_mapping_wait(), for instance, then we may exit before
    starting I/O on all the requests that have been queued up.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8b09bee3083897e375bd0bf9d60f48daedfab3e0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 2 18:48:28 2007 -0400

    NFS: Cleanup for nfs_readpages()
    
    Do the coalescing of read requests into block sized requests at start of
    I/O as we scan through the pages instead of going through a second pass.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bcb71bba7e64f0442d0ca339d7d3117a7060589f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 2 18:48:28 2007 -0400

    NFS: Another cleanup of the read/write request coalescing code
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d8a5ad75cc4d577987964e37a4c43b1c648c201e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 2 18:48:28 2007 -0400

    NFS: Cleanup the coalescing code
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 91e59c368c6ba5eed0369a085c42c9f270b97aa8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 6 13:12:46 2007 -0400

    NFS: Don't wait for congestion in nfs_update_request()
    
    It is redundant, and will interfere with the call to
    balance_dirty_pages_ratelimited_nr in generic_file_write().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1a0ba9ae485c5fd17d0bff2f14d9dd75b8985593
Author: Amnon Aaronsohn <amnonaar@gmail.com>
Date:   Mon Apr 9 22:05:26 2007 -0700

    NFS: statfs error-handling fix
    
    The nfs statfs function returns a success code on error, and fills the
    output buffer with invalid values.  The attached patch makes it return a
    correct error code instead.
    
    Signed-off-by: Amnon Aaronsohn <amnonaar@gmail.com>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
     (Modified patch to reinstate the dprintk())

commit d585158b608248a6ba8ae75e234672e048d3fde9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 30 22:17:02 2007 -0700

    NFS: Fix nfs_set_page_dirty()
    
    Be more careful about testing page->mapping.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/Kconfig b/fs/Kconfig
index a42f767..20bec77 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1734,6 +1734,18 @@ config SUNRPC
 config SUNRPC_GSS
 	tristate
 
+config SUNRPC_BIND34
+	bool "Support for rpcbind versions 3 & 4 (EXPERIMENTAL)"
+	depends on SUNRPC && EXPERIMENTAL
+	help
+	  Provides kernel support for querying rpcbind servers via versions 3
+	  and 4 of the rpcbind protocol.  The kernel automatically falls back
+	  to version 2 if a remote rpcbind service does not support versions
+	  3 or 4.
+
+	  If unsure, say N to get traditional behavior (version 2 rpcbind
+	  requests only).
+
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index eb243ed..2102e2d 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -225,16 +225,13 @@ xdr_decode_stat(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
 #define SM_monres_sz	2
 #define SM_unmonres_sz	1
 
-#ifndef MAX
-# define MAX(a, b)	(((a) > (b))? (a) : (b))
-#endif
-
 static struct rpc_procinfo	nsm_procedures[] = {
 [SM_MON] = {
 		.p_proc		= SM_MON,
 		.p_encode	= (kxdrproc_t) xdr_encode_mon,
 		.p_decode	= (kxdrproc_t) xdr_decode_stat_res,
-		.p_bufsiz	= MAX(SM_mon_sz, SM_monres_sz) << 2,
+		.p_arglen	= SM_mon_sz,
+		.p_replen	= SM_monres_sz,
 		.p_statidx	= SM_MON,
 		.p_name		= "MONITOR",
 	},
@@ -242,7 +239,8 @@ static struct rpc_procinfo	nsm_procedures[] = {
 		.p_proc		= SM_UNMON,
 		.p_encode	= (kxdrproc_t) xdr_encode_unmon,
 		.p_decode	= (kxdrproc_t) xdr_decode_stat,
-		.p_bufsiz	= MAX(SM_mon_id_sz, SM_unmonres_sz) << 2,
+		.p_arglen	= SM_mon_id_sz,
+		.p_replen	= SM_unmonres_sz,
 		.p_statidx	= SM_UNMON,
 		.p_name		= "UNMONITOR",
 	},
diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 34dae5d..9702956 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -510,17 +510,20 @@ nlmclt_decode_res(struct rpc_rqst *req, __be32 *p, struct nlm_res *resp)
 	return 0;
 }
 
+#if (NLMCLNT_OHSIZE > XDR_MAX_NETOBJ)
+#  error "NLM host name cannot be larger than XDR_MAX_NETOBJ!"
+#endif
+
 /*
  * Buffer requirements for NLM
  */
 #define NLM_void_sz		0
 #define NLM_cookie_sz		1+XDR_QUADLEN(NLM_MAXCOOKIELEN)
-#define NLM_caller_sz		1+XDR_QUADLEN(sizeof(utsname()->nodename))
-#define NLM_netobj_sz		1+XDR_QUADLEN(XDR_MAX_NETOBJ)
-/* #define NLM_owner_sz		1+XDR_QUADLEN(NLM_MAXOWNER) */
+#define NLM_caller_sz		1+XDR_QUADLEN(NLMCLNT_OHSIZE)
+#define NLM_owner_sz		1+XDR_QUADLEN(NLMCLNT_OHSIZE)
 #define NLM_fhandle_sz		1+XDR_QUADLEN(NFS2_FHSIZE)
-#define NLM_lock_sz		3+NLM_caller_sz+NLM_netobj_sz+NLM_fhandle_sz
-#define NLM_holder_sz		4+NLM_netobj_sz
+#define NLM_lock_sz		3+NLM_caller_sz+NLM_owner_sz+NLM_fhandle_sz
+#define NLM_holder_sz		4+NLM_owner_sz
 
 #define NLM_testargs_sz		NLM_cookie_sz+1+NLM_lock_sz
 #define NLM_lockargs_sz		NLM_cookie_sz+4+NLM_lock_sz
@@ -531,10 +534,6 @@ nlmclt_decode_res(struct rpc_rqst *req, __be32 *p, struct nlm_res *resp)
 #define NLM_res_sz		NLM_cookie_sz+1
 #define NLM_norep_sz		0
 
-#ifndef MAX
-# define MAX(a, b)		(((a) > (b))? (a) : (b))
-#endif
-
 /*
  * For NLM, a void procedure really returns nothing
  */
@@ -545,7 +544,8 @@ nlmclt_decode_res(struct rpc_rqst *req, __be32 *p, struct nlm_res *resp)
 	.p_proc      = NLMPROC_##proc,					\
 	.p_encode    = (kxdrproc_t) nlmclt_encode_##argtype,		\
 	.p_decode    = (kxdrproc_t) nlmclt_decode_##restype,		\
-	.p_bufsiz    = MAX(NLM_##argtype##_sz, NLM_##restype##_sz) << 2,	\
+	.p_arglen    = NLM_##argtype##_sz,				\
+	.p_replen    = NLM_##restype##_sz,				\
 	.p_statidx   = NLMPROC_##proc,					\
 	.p_name      = #proc,						\
 	}
diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
index a782405..ce1efdb 100644
--- a/fs/lockd/xdr4.c
+++ b/fs/lockd/xdr4.c
@@ -516,17 +516,24 @@ nlm4clt_decode_res(struct rpc_rqst *req, __be32 *p, struct nlm_res *resp)
 	return 0;
 }
 
+#if (NLMCLNT_OHSIZE > XDR_MAX_NETOBJ)
+#  error "NLM host name cannot be larger than XDR_MAX_NETOBJ!"
+#endif
+
+#if (NLMCLNT_OHSIZE > NLM_MAXSTRLEN)
+#  error "NLM host name cannot be larger than NLM's maximum string length!"
+#endif
+
 /*
  * Buffer requirements for NLM
  */
 #define NLM4_void_sz		0
 #define NLM4_cookie_sz		1+XDR_QUADLEN(NLM_MAXCOOKIELEN)
-#define NLM4_caller_sz		1+XDR_QUADLEN(NLM_MAXSTRLEN)
-#define NLM4_netobj_sz		1+XDR_QUADLEN(XDR_MAX_NETOBJ)
-/* #define NLM4_owner_sz		1+XDR_QUADLEN(NLM4_MAXOWNER) */
+#define NLM4_caller_sz		1+XDR_QUADLEN(NLMCLNT_OHSIZE)
+#define NLM4_owner_sz		1+XDR_QUADLEN(NLMCLNT_OHSIZE)
 #define NLM4_fhandle_sz		1+XDR_QUADLEN(NFS3_FHSIZE)
-#define NLM4_lock_sz		5+NLM4_caller_sz+NLM4_netobj_sz+NLM4_fhandle_sz
-#define NLM4_holder_sz		6+NLM4_netobj_sz
+#define NLM4_lock_sz		5+NLM4_caller_sz+NLM4_owner_sz+NLM4_fhandle_sz
+#define NLM4_holder_sz		6+NLM4_owner_sz
 
 #define NLM4_testargs_sz	NLM4_cookie_sz+1+NLM4_lock_sz
 #define NLM4_lockargs_sz	NLM4_cookie_sz+4+NLM4_lock_sz
@@ -537,10 +544,6 @@ nlm4clt_decode_res(struct rpc_rqst *req, __be32 *p, struct nlm_res *resp)
 #define NLM4_res_sz		NLM4_cookie_sz+1
 #define NLM4_norep_sz		0
 
-#ifndef MAX
-# define MAX(a,b)		(((a) > (b))? (a) : (b))
-#endif
-
 /*
  * For NLM, a void procedure really returns nothing
  */
@@ -551,7 +554,8 @@ nlm4clt_decode_res(struct rpc_rqst *req, __be32 *p, struct nlm_res *resp)
 	.p_proc      = NLMPROC_##proc,					\
 	.p_encode    = (kxdrproc_t) nlm4clt_encode_##argtype,		\
 	.p_decode    = (kxdrproc_t) nlm4clt_decode_##restype,		\
-	.p_bufsiz    = MAX(NLM4_##argtype##_sz, NLM4_##restype##_sz) << 2,	\
+	.p_arglen    = NLM4_##argtype##_sz,				\
+	.p_replen    = NLM4_##restype##_sz,				\
 	.p_statidx   = NLMPROC_##proc,					\
 	.p_name      = #proc,						\
 	}
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2190e6c..5bd03b9 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -618,7 +618,8 @@ static int nfs_init_server(struct nfs_server *server, const struct nfs_mount_dat
 	if (clp->cl_nfsversion == 3) {
 		if (server->namelen == 0 || server->namelen > NFS3_MAXNAMLEN)
 			server->namelen = NFS3_MAXNAMLEN;
-		server->caps |= NFS_CAP_READDIRPLUS;
+		if (!(data->flags & NFS_MOUNT_NORDIRPLUS))
+			server->caps |= NFS_CAP_READDIRPLUS;
 	} else {
 		if (server->namelen == 0 || server->namelen > NFS2_MAXNAMLEN)
 			server->namelen = NFS2_MAXNAMLEN;
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index cd34697..e59fd31 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -154,6 +154,8 @@ typedef struct {
 	decode_dirent_t	decode;
 	int		plus;
 	int		error;
+	unsigned long	timestamp;
+	int		timestamp_valid;
 } nfs_readdir_descriptor_t;
 
 /* Now we cache directories properly, by stuffing the dirent
@@ -195,6 +197,8 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page *page)
 		}
 		goto error;
 	}
+	desc->timestamp = timestamp;
+	desc->timestamp_valid = 1;
 	SetPageUptodate(page);
 	spin_lock(&inode->i_lock);
 	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATIME;
@@ -225,6 +229,10 @@ int dir_decode(nfs_readdir_descriptor_t *desc)
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 	desc->ptr = p;
+	if (desc->timestamp_valid)
+		desc->entry->fattr->time_start = desc->timestamp;
+	else
+		desc->entry->fattr->valid &= ~NFS_ATTR_FATTR;
 	return 0;
 }
 
@@ -316,6 +324,10 @@ int find_dirent_page(nfs_readdir_descriptor_t *desc)
 			__FUNCTION__, desc->page_index,
 			(long long) *desc->dir_cookie);
 
+	/* If we find the page in the page_cache, we cannot be sure
+	 * how fresh the data is, so we will ignore readdir_plus attributes.
+	 */
+	desc->timestamp_valid = 0;
 	page = read_cache_page(inode->i_mapping, desc->page_index,
 			       (filler_t *)nfs_readdir_filler, desc);
 	if (IS_ERR(page)) {
@@ -468,6 +480,7 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc, void *dirent,
 	struct rpc_cred	*cred = nfs_file_cred(file);
 	struct page	*page = NULL;
 	int		status;
+	unsigned long	timestamp;
 
 	dfprintk(DIRCACHE, "NFS: uncached_readdir() searching for cookie %Lu\n",
 			(unsigned long long)*desc->dir_cookie);
@@ -477,6 +490,7 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc, void *dirent,
 		status = -ENOMEM;
 		goto out;
 	}
+	timestamp = jiffies;
 	desc->error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, *desc->dir_cookie,
 						page,
 						NFS_SERVER(inode)->dtsize,
@@ -487,6 +501,8 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc, void *dirent,
 	desc->page = page;
 	desc->ptr = kmap(page);		/* matching kunmap in nfs_do_filldir */
 	if (desc->error >= 0) {
+		desc->timestamp = timestamp;
+		desc->timestamp_valid = 1;
 		if ((status = dir_decode(desc)) == 0)
 			desc->entry->prev_cookie = *desc->dir_cookie;
 	} else
@@ -849,6 +865,10 @@ static int nfs_dentry_delete(struct dentry *dentry)
 static void nfs_dentry_iput(struct dentry *dentry, struct inode *inode)
 {
 	nfs_inode_return_delegation(inode);
+	if (S_ISDIR(inode->i_mode))
+		/* drop any readdir cache as it could easily be old */
+		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_DATA;
+
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
 		lock_kernel();
 		drop_nlink(inode);
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 2877744..889de60 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -54,6 +54,7 @@
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
 
+#include "internal.h"
 #include "iostat.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
@@ -271,7 +272,7 @@ static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq, unsigned lo
 		bytes = min(rsize,count);
 
 		result = -ENOMEM;
-		data = nfs_readdata_alloc(pgbase + bytes);
+		data = nfs_readdata_alloc(nfs_page_array_len(pgbase, bytes));
 		if (unlikely(!data))
 			break;
 
@@ -602,7 +603,7 @@ static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq, unsigned l
 		bytes = min(wsize,count);
 
 		result = -ENOMEM;
-		data = nfs_writedata_alloc(pgbase + bytes);
+		data = nfs_writedata_alloc(nfs_page_array_len(pgbase, bytes));
 		if (unlikely(!data))
 			break;
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 6610f2b..ad2b40d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -231,3 +231,15 @@ unsigned int nfs_page_length(struct page *page)
 	}
 	return 0;
 }
+
+/*
+ * Determine the number of pages in an array of length 'len' and
+ * with a base offset of 'base'
+ */
+static inline
+unsigned int nfs_page_array_len(unsigned int base, size_t len)
+{
+	return ((unsigned long)len + (unsigned long)base +
+		PAGE_SIZE - 1) >> PAGE_SHIFT;
+}
+
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index f75fe72..ca5a266 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -133,13 +133,15 @@ xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p, struct mnt_fhstatus *res)
 
 #define MNT_dirpath_sz		(1 + 256)
 #define MNT_fhstatus_sz		(1 + 8)
+#define MNT_fhstatus3_sz	(1 + 16)
 
 static struct rpc_procinfo	mnt_procedures[] = {
 [MNTPROC_MNT] = {
 	  .p_proc		= MNTPROC_MNT,
 	  .p_encode		= (kxdrproc_t) xdr_encode_dirpath,	
 	  .p_decode		= (kxdrproc_t) xdr_decode_fhstatus,
-	  .p_bufsiz		= MNT_dirpath_sz << 2,
+	  .p_arglen		= MNT_dirpath_sz,
+	  .p_replen		= MNT_fhstatus_sz,
 	  .p_statidx		= MNTPROC_MNT,
 	  .p_name		= "MOUNT",
 	},
@@ -150,7 +152,8 @@ static struct rpc_procinfo mnt3_procedures[] = {
 	  .p_proc		= MOUNTPROC3_MNT,
 	  .p_encode		= (kxdrproc_t) xdr_encode_dirpath,
 	  .p_decode		= (kxdrproc_t) xdr_decode_fhstatus3,
-	  .p_bufsiz		= MNT_dirpath_sz << 2,
+	  .p_arglen		= MNT_dirpath_sz,
+	  .p_replen		= MNT_fhstatus3_sz,
 	  .p_statidx		= MOUNTPROC3_MNT,
 	  .p_name		= "MOUNT",
 	},
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 3be4e72..abd9f8b 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -687,16 +687,13 @@ nfs_stat_to_errno(int stat)
 	return nfs_errtbl[i].errno;
 }
 
-#ifndef MAX
-# define MAX(a, b)	(((a) > (b))? (a) : (b))
-#endif
-
 #define PROC(proc, argtype, restype, timer)				\
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
 	.p_encode   =  (kxdrproc_t) nfs_xdr_##argtype,			\
 	.p_decode   =  (kxdrproc_t) nfs_xdr_##restype,			\
-	.p_bufsiz   =  MAX(NFS_##argtype##_sz,NFS_##restype##_sz) << 2,	\
+	.p_arglen   =  NFS_##argtype##_sz,				\
+	.p_replen   =  NFS_##restype##_sz,				\
 	.p_timer    =  timer,						\
 	.p_statidx  =  NFSPROC_##proc,					\
 	.p_name     =  #proc,						\
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 0ace092..b51df8e 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1102,16 +1102,13 @@ nfs3_xdr_setaclres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 }
 #endif  /* CONFIG_NFS_V3_ACL */
 
-#ifndef MAX
-# define MAX(a, b)	(((a) > (b))? (a) : (b))
-#endif
-
 #define PROC(proc, argtype, restype, timer)				\
 [NFS3PROC_##proc] = {							\
 	.p_proc      = NFS3PROC_##proc,					\
 	.p_encode    = (kxdrproc_t) nfs3_xdr_##argtype,			\
 	.p_decode    = (kxdrproc_t) nfs3_xdr_##restype,			\
-	.p_bufsiz    = MAX(NFS3_##argtype##_sz,NFS3_##restype##_sz) << 2,	\
+	.p_arglen    = NFS3_##argtype##_sz,				\
+	.p_replen    = NFS3_##restype##_sz,				\
 	.p_timer     = timer,						\
 	.p_statidx   = NFS3PROC_##proc,					\
 	.p_name      = #proc,						\
@@ -1153,7 +1150,8 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 		.p_proc = ACLPROC3_GETACL,
 		.p_encode = (kxdrproc_t) nfs3_xdr_getaclargs,
 		.p_decode = (kxdrproc_t) nfs3_xdr_getaclres,
-		.p_bufsiz = MAX(ACL3_getaclargs_sz, ACL3_getaclres_sz) << 2,
+		.p_arglen = ACL3_getaclargs_sz,
+		.p_replen = ACL3_getaclres_sz,
 		.p_timer = 1,
 		.p_name = "GETACL",
 	},
@@ -1161,7 +1159,8 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 		.p_proc = ACLPROC3_SETACL,
 		.p_encode = (kxdrproc_t) nfs3_xdr_setaclargs,
 		.p_decode = (kxdrproc_t) nfs3_xdr_setaclres,
-		.p_bufsiz = MAX(ACL3_setaclargs_sz, ACL3_setaclres_sz) << 2,
+		.p_arglen = ACL3_setaclargs_sz,
+		.p_replen = ACL3_setaclres_sz,
 		.p_timer = 0,
 		.p_name = "SETACL",
 	},
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f52cf5c..3b5ca1b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2647,8 +2647,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	nfs_inode_return_delegation(inode);
 	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
 	ret = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
-	if (ret == 0)
-		nfs4_write_cached_acl(inode, buf, buflen);
+	nfs_zap_caches(inode);
 	return ret;
 }
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f02d522..b8c28f2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4546,16 +4546,13 @@ nfs4_stat_to_errno(int stat)
 	return stat;
 }
 
-#ifndef MAX
-# define MAX(a, b)	(((a) > (b))? (a) : (b))
-#endif
-
 #define PROC(proc, argtype, restype)				\
 [NFSPROC4_CLNT_##proc] = {					\
 	.p_proc   = NFSPROC4_COMPOUND,				\
 	.p_encode = (kxdrproc_t) nfs4_xdr_##argtype,		\
 	.p_decode = (kxdrproc_t) nfs4_xdr_##restype,		\
-	.p_bufsiz = MAX(NFS4_##argtype##_sz,NFS4_##restype##_sz) << 2,	\
+	.p_arglen = NFS4_##argtype##_sz,			\
+	.p_replen = NFS4_##restype##_sz,			\
 	.p_statidx = NFSPROC4_CLNT_##proc,			\
 	.p_name   = #proc,					\
     }
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 75f819d..49d1008 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -428,7 +428,7 @@ static int __init root_nfs_getport(int program, int version, int proto)
 	printk(KERN_NOTICE "Looking up port of RPC %d/%d on %u.%u.%u.%u\n",
 		program, version, NIPQUAD(servaddr));
 	set_sockaddr(&sin, servaddr, 0);
-	return rpc_getport_external(&sin, program, version, proto);
+	return rpcb_getport_external(&sin, program, version, proto);
 }
 
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ca4b1d4..fe90130 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -17,7 +17,8 @@
 #include <linux/nfs_page.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
-#include <linux/writeback.h>
+
+#include "internal.h"
 
 #define NFS_PARANOIA 1
 
@@ -50,9 +51,7 @@ nfs_page_free(struct nfs_page *p)
  * @count: number of bytes to read/write
  *
  * The page must be locked by the caller. This makes sure we never
- * create two different requests for the same page, and avoids
- * a possible deadlock when we reach the hard limit on the number
- * of dirty pages.
+ * create two different requests for the same page.
  * User should ensure it is safe to sleep in this function.
  */
 struct nfs_page *
@@ -63,16 +62,12 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_page		*req;
 
-	/* Deal with hard limits.  */
 	for (;;) {
 		/* try to allocate the request struct */
 		req = nfs_page_alloc();
 		if (req != NULL)
 			break;
 
-		/* Try to free up at least one request in order to stay
-		 * below the hard limit
-		 */
 		if (signalled() && (server->flags & NFS_MOUNT_INTR))
 			return ERR_PTR(-ERESTARTSYS);
 		yield();
@@ -223,124 +218,151 @@ out:
 }
 
 /**
- * nfs_coalesce_requests - Split coalesced requests out from a list.
- * @head: source list
- * @dst: destination list
- * @nmax: maximum number of requests to coalesce
- *
- * Moves a maximum of 'nmax' elements from one list to another.
- * The elements are checked to ensure that they form a contiguous set
- * of pages, and that the RPC credentials are the same.
+ * nfs_pageio_init - initialise a page io descriptor
+ * @desc: pointer to descriptor
+ * @inode: pointer to inode
+ * @doio: pointer to io function
+ * @bsize: io block size
+ * @io_flags: extra parameters for the io function
  */
-int
-nfs_coalesce_requests(struct list_head *head, struct list_head *dst,
-		      unsigned int nmax)
+void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
+		     struct inode *inode,
+		     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int),
+		     unsigned int bsize,
+		     int io_flags)
 {
-	struct nfs_page		*req = NULL;
-	unsigned int		npages = 0;
-
-	while (!list_empty(head)) {
-		struct nfs_page	*prev = req;
-
-		req = nfs_list_entry(head->next);
-		if (prev) {
-			if (req->wb_context->cred != prev->wb_context->cred)
-				break;
-			if (req->wb_context->lockowner != prev->wb_context->lockowner)
-				break;
-			if (req->wb_context->state != prev->wb_context->state)
-				break;
-			if (req->wb_index != (prev->wb_index + 1))
-				break;
-
-			if (req->wb_pgbase != 0)
-				break;
-		}
-		nfs_list_remove_request(req);
-		nfs_list_add_request(req, dst);
-		npages++;
-		if (req->wb_pgbase + req->wb_bytes != PAGE_CACHE_SIZE)
-			break;
-		if (npages >= nmax)
-			break;
-	}
-	return npages;
+	INIT_LIST_HEAD(&desc->pg_list);
+	desc->pg_bytes_written = 0;
+	desc->pg_count = 0;
+	desc->pg_bsize = bsize;
+	desc->pg_base = 0;
+	desc->pg_inode = inode;
+	desc->pg_doio = doio;
+	desc->pg_ioflags = io_flags;
+	desc->pg_error = 0;
 }
 
-#define NFS_SCAN_MAXENTRIES 16
 /**
- * nfs_scan_dirty - Scan the radix tree for dirty requests
- * @mapping: pointer to address space
- * @wbc: writeback_control structure
- * @dst: Destination list
+ * nfs_can_coalesce_requests - test two requests for compatibility
+ * @prev: pointer to nfs_page
+ * @req: pointer to nfs_page
  *
- * Moves elements from one of the inode request lists.
- * If the number of requests is set to 0, the entire address_space
- * starting at index idx_start, is scanned.
- * The requests are *not* checked to ensure that they form a contiguous set.
- * You must be holding the inode's req_lock when calling this function
+ * The nfs_page structures 'prev' and 'req' are compared to ensure that the
+ * page data area they describe is contiguous, and that their RPC
+ * credentials, NFSv4 open state, and lockowners are the same.
+ *
+ * Return 'true' if this is the case, else return 'false'.
  */
-long nfs_scan_dirty(struct address_space *mapping,
-			struct writeback_control *wbc,
-			struct list_head *dst)
+static int nfs_can_coalesce_requests(struct nfs_page *prev,
+				     struct nfs_page *req)
 {
-	struct nfs_inode *nfsi = NFS_I(mapping->host);
-	struct nfs_page *pgvec[NFS_SCAN_MAXENTRIES];
-	struct nfs_page *req;
-	pgoff_t idx_start, idx_end;
-	long res = 0;
-	int found, i;
-
-	if (nfsi->ndirty == 0)
+	if (req->wb_context->cred != prev->wb_context->cred)
 		return 0;
-	if (wbc->range_cyclic) {
-		idx_start = 0;
-		idx_end = ULONG_MAX;
-	} else if (wbc->range_end == 0) {
-		idx_start = wbc->range_start >> PAGE_CACHE_SHIFT;
-		idx_end = ULONG_MAX;
-	} else {
-		idx_start = wbc->range_start >> PAGE_CACHE_SHIFT;
-		idx_end = wbc->range_end >> PAGE_CACHE_SHIFT;
-	}
+	if (req->wb_context->lockowner != prev->wb_context->lockowner)
+		return 0;
+	if (req->wb_context->state != prev->wb_context->state)
+		return 0;
+	if (req->wb_index != (prev->wb_index + 1))
+		return 0;
+	if (req->wb_pgbase != 0)
+		return 0;
+	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
+		return 0;
+	return 1;
+}
 
-	for (;;) {
-		unsigned int toscan = NFS_SCAN_MAXENTRIES;
+/**
+ * nfs_pageio_do_add_request - Attempt to coalesce a request into a page list.
+ * @desc: destination io descriptor
+ * @req: request
+ *
+ * Returns true if the request 'req' was successfully coalesced into the
+ * existing list of pages 'desc'.
+ */
+static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
+				     struct nfs_page *req)
+{
+	size_t newlen = req->wb_bytes;
 
-		found = radix_tree_gang_lookup_tag(&nfsi->nfs_page_tree,
-				(void **)&pgvec[0], idx_start, toscan,
-				NFS_PAGE_TAG_DIRTY);
+	if (desc->pg_count != 0) {
+		struct nfs_page *prev;
 
-		/* Did we make progress? */
-		if (found <= 0)
-			break;
+		/*
+		 * FIXME: ideally we should be able to coalesce all requests
+		 * that are not block boundary aligned, but currently this
+		 * is problematic for the case of bsize < PAGE_CACHE_SIZE,
+		 * since nfs_flush_multi and nfs_pagein_multi assume you
+		 * can have only one struct nfs_page.
+		 */
+		if (desc->pg_bsize < PAGE_SIZE)
+			return 0;
+		newlen += desc->pg_count;
+		if (newlen > desc->pg_bsize)
+			return 0;
+		prev = nfs_list_entry(desc->pg_list.prev);
+		if (!nfs_can_coalesce_requests(prev, req))
+			return 0;
+	} else
+		desc->pg_base = req->wb_pgbase;
+	nfs_list_remove_request(req);
+	nfs_list_add_request(req, &desc->pg_list);
+	desc->pg_count = newlen;
+	return 1;
+}
 
-		for (i = 0; i < found; i++) {
-			req = pgvec[i];
-			if (!wbc->range_cyclic && req->wb_index > idx_end)
-				goto out;
+/*
+ * Helper for nfs_pageio_add_request and nfs_pageio_complete
+ */
+static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
+{
+	if (!list_empty(&desc->pg_list)) {
+		int error = desc->pg_doio(desc->pg_inode,
+					  &desc->pg_list,
+					  nfs_page_array_len(desc->pg_base,
+							     desc->pg_count),
+					  desc->pg_count,
+					  desc->pg_ioflags);
+		if (error < 0)
+			desc->pg_error = error;
+		else
+			desc->pg_bytes_written += desc->pg_count;
+	}
+	if (list_empty(&desc->pg_list)) {
+		desc->pg_count = 0;
+		desc->pg_base = 0;
+	}
+}
 
-			/* Try to lock request and mark it for writeback */
-			if (!nfs_set_page_writeback_locked(req))
-				goto next;
-			radix_tree_tag_clear(&nfsi->nfs_page_tree,
-					req->wb_index, NFS_PAGE_TAG_DIRTY);
-			nfsi->ndirty--;
-			nfs_list_remove_request(req);
-			nfs_list_add_request(req, dst);
-			res++;
-			if (res == LONG_MAX)
-				goto out;
-next:
-			idx_start = req->wb_index + 1;
-		}
+/**
+ * nfs_pageio_add_request - Attempt to coalesce a request into a page list.
+ * @desc: destination io descriptor
+ * @req: request
+ *
+ * Returns true if the request 'req' was successfully coalesced into the
+ * existing list of pages 'desc'.
+ */
+int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
+			   struct nfs_page *req)
+{
+	while (!nfs_pageio_do_add_request(desc, req)) {
+		nfs_pageio_doio(desc);
+		if (desc->pg_error < 0)
+			return 0;
 	}
-out:
-	WARN_ON ((nfsi->ndirty == 0) != list_empty(&nfsi->dirty));
-	return res;
+	return 1;
 }
 
 /**
+ * nfs_pageio_complete - Complete I/O on an nfs_pageio_descriptor
+ * @desc: pointer to io descriptor
+ */
+void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
+{
+	nfs_pageio_doio(desc);
+}
+
+#define NFS_SCAN_MAXENTRIES 16
+/**
  * nfs_scan_list - Scan a list for matching requests
  * @nfsi: NFS inode
  * @head: One of the NFS inode request lists
@@ -355,12 +377,12 @@ out:
  * You must be holding the inode's req_lock when calling this function
  */
 int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *head,
-		struct list_head *dst, unsigned long idx_start,
+		struct list_head *dst, pgoff_t idx_start,
 		unsigned int npages)
 {
 	struct nfs_page *pgvec[NFS_SCAN_MAXENTRIES];
 	struct nfs_page *req;
-	unsigned long idx_end;
+	pgoff_t idx_end;
 	int found, i;
 	int res;
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 6ab4d5a..9a55807 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -27,7 +27,8 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
-static int nfs_pagein_one(struct list_head *, struct inode *);
+static int nfs_pagein_multi(struct inode *, struct list_head *, unsigned int, size_t, int);
+static int nfs_pagein_one(struct inode *, struct list_head *, unsigned int, size_t, int);
 static const struct rpc_call_ops nfs_read_partial_ops;
 static const struct rpc_call_ops nfs_read_full_ops;
 
@@ -36,9 +37,8 @@ static mempool_t *nfs_rdata_mempool;
 
 #define MIN_POOL_READ	(32)
 
-struct nfs_read_data *nfs_readdata_alloc(size_t len)
+struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
 {
-	unsigned int pagecount = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	struct nfs_read_data *p = mempool_alloc(nfs_rdata_mempool, GFP_NOFS);
 
 	if (p) {
@@ -133,7 +133,10 @@ static int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 		memclear_highpage_flush(page, len, PAGE_CACHE_SIZE - len);
 
 	nfs_list_add_request(new, &one_request);
-	nfs_pagein_one(&one_request, inode);
+	if (NFS_SERVER(inode)->rsize < PAGE_CACHE_SIZE)
+		nfs_pagein_multi(inode, &one_request, 1, len, 0);
+	else
+		nfs_pagein_one(inode, &one_request, 1, len, 0);
 	return 0;
 }
 
@@ -230,7 +233,7 @@ static void nfs_execute_read(struct nfs_read_data *data)
  * won't see the new data until our attribute cache is updated.  This is more
  * or less conventional NFS client behavior.
  */
-static int nfs_pagein_multi(struct list_head *head, struct inode *inode)
+static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags)
 {
 	struct nfs_page *req = nfs_list_entry(head->next);
 	struct page *page = req->wb_page;
@@ -242,11 +245,11 @@ static int nfs_pagein_multi(struct list_head *head, struct inode *inode)
 
 	nfs_list_remove_request(req);
 
-	nbytes = req->wb_bytes;
+	nbytes = count;
 	do {
 		size_t len = min(nbytes,rsize);
 
-		data = nfs_readdata_alloc(len);
+		data = nfs_readdata_alloc(1);
 		if (!data)
 			goto out_bad;
 		INIT_LIST_HEAD(&data->pages);
@@ -258,23 +261,19 @@ static int nfs_pagein_multi(struct list_head *head, struct inode *inode)
 
 	ClearPageError(page);
 	offset = 0;
-	nbytes = req->wb_bytes;
+	nbytes = count;
 	do {
 		data = list_entry(list.next, struct nfs_read_data, pages);
 		list_del_init(&data->pages);
 
 		data->pagevec[0] = page;
 
-		if (nbytes > rsize) {
-			nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
-					rsize, offset);
-			offset += rsize;
-			nbytes -= rsize;
-		} else {
-			nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
-					nbytes, offset);
-			nbytes = 0;
-		}
+		if (nbytes < rsize)
+			rsize = nbytes;
+		nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
+				  rsize, offset);
+		offset += rsize;
+		nbytes -= rsize;
 		nfs_execute_read(data);
 	} while (nbytes != 0);
 
@@ -291,30 +290,24 @@ out_bad:
 	return -ENOMEM;
 }
 
-static int nfs_pagein_one(struct list_head *head, struct inode *inode)
+static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
 	struct nfs_read_data	*data;
-	unsigned int		count;
 
-	if (NFS_SERVER(inode)->rsize < PAGE_CACHE_SIZE)
-		return nfs_pagein_multi(head, inode);
-
-	data = nfs_readdata_alloc(NFS_SERVER(inode)->rsize);
+	data = nfs_readdata_alloc(npages);
 	if (!data)
 		goto out_bad;
 
 	INIT_LIST_HEAD(&data->pages);
 	pages = data->pagevec;
-	count = 0;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, &data->pages);
 		ClearPageError(req->wb_page);
 		*pages++ = req->wb_page;
-		count += req->wb_bytes;
 	}
 	req = nfs_list_entry(data->pages.next);
 
@@ -327,28 +320,6 @@ out_bad:
 	return -ENOMEM;
 }
 
-static int
-nfs_pagein_list(struct list_head *head, int rpages)
-{
-	LIST_HEAD(one_request);
-	struct nfs_page		*req;
-	int			error = 0;
-	unsigned int		pages = 0;
-
-	while (!list_empty(head)) {
-		pages += nfs_coalesce_requests(head, &one_request, rpages);
-		req = nfs_list_entry(one_request.next);
-		error = nfs_pagein_one(&one_request, req->wb_context->dentry->d_inode);
-		if (error < 0)
-			break;
-	}
-	if (error >= 0)
-		return pages;
-
-	nfs_async_read_error(head);
-	return error;
-}
-
 /*
  * This is the callback from RPC telling us whether a reply was
  * received or some error occurred (timeout or socket shutdown).
@@ -538,7 +509,7 @@ out_error:
 }
 
 struct nfs_readdesc {
-	struct list_head *head;
+	struct nfs_pageio_descriptor *pgio;
 	struct nfs_open_context *ctx;
 };
 
@@ -562,19 +533,21 @@ readpage_async_filler(void *data, struct page *page)
 	}
 	if (len < PAGE_CACHE_SIZE)
 		memclear_highpage_flush(page, len, PAGE_CACHE_SIZE - len);
-	nfs_list_add_request(new, desc->head);
+	nfs_pageio_add_request(desc->pgio, new);
 	return 0;
 }
 
 int nfs_readpages(struct file *filp, struct address_space *mapping,
 		struct list_head *pages, unsigned nr_pages)
 {
-	LIST_HEAD(head);
+	struct nfs_pageio_descriptor pgio;
 	struct nfs_readdesc desc = {
-		.head		= &head,
+		.pgio = &pgio,
 	};
 	struct inode *inode = mapping->host;
 	struct nfs_server *server = NFS_SERVER(inode);
+	size_t rsize = server->rsize;
+	unsigned long npages;
 	int ret = -ESTALE;
 
 	dprintk("NFS: nfs_readpages (%s/%Ld %d)\n",
@@ -593,13 +566,16 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	} else
 		desc.ctx = get_nfs_open_context((struct nfs_open_context *)
 				filp->private_data);
+	if (rsize < PAGE_CACHE_SIZE)
+		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
+	else
+		nfs_pageio_init(&pgio, inode, nfs_pagein_one, rsize, 0);
+
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
-	if (!list_empty(&head)) {
-		int err = nfs_pagein_list(&head, server->rpages);
-		if (!ret)
-			nfs_add_stats(inode, NFSIOS_READPAGES, err);
-			ret = err;
-	}
+
+	nfs_pageio_complete(&pgio);
+	npages = (pgio.pg_bytes_written + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	nfs_add_stats(inode, NFSIOS_READPAGES, npages);
 	put_nfs_open_context(desc.ctx);
 out:
 	return ret;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f1eae44..ca20d3c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -204,9 +204,9 @@ static int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	lock_kernel();
 
 	error = server->nfs_client->rpc_ops->statfs(server, fh, &res);
-	buf->f_type = NFS_SUPER_MAGIC;
 	if (error < 0)
 		goto out_err;
+	buf->f_type = NFS_SUPER_MAGIC;
 
 	/*
 	 * Current versions of glibc do not correctly handle the
@@ -233,15 +233,14 @@ static int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	buf->f_ffree = res.afiles;
 
 	buf->f_namelen = server->namelen;
- out:
+
 	unlock_kernel();
 	return 0;
 
  out_err:
 	dprintk("%s: statfs error = %d\n", __FUNCTION__, -error);
-	buf->f_bsize = buf->f_blocks = buf->f_bfree = buf->f_bavail = -1;
-	goto out;
-
+	unlock_kernel();
+	return error;
 }
 
 /*
@@ -291,6 +290,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 		{ NFS_MOUNT_NOAC, ",noac", "" },
 		{ NFS_MOUNT_NONLM, ",nolock", "" },
 		{ NFS_MOUNT_NOACL, ",noacl", "" },
+		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
 		{ 0, NULL, NULL }
 	};
 	const struct proc_nfs_info *nfs_infop;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7975589..5d44b8b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -38,7 +38,8 @@
 static struct nfs_page * nfs_update_request(struct nfs_open_context*,
 					    struct page *,
 					    unsigned int, unsigned int);
-static long nfs_flush_mapping(struct address_space *mapping, struct writeback_control *wbc, int how);
+static void nfs_pageio_init_write(struct nfs_pageio_descriptor *desc,
+				  struct inode *inode, int ioflags);
 static const struct rpc_call_ops nfs_write_partial_ops;
 static const struct rpc_call_ops nfs_write_full_ops;
 static const struct rpc_call_ops nfs_commit_ops;
@@ -71,9 +72,8 @@ void nfs_commit_free(struct nfs_write_data *wdata)
 	call_rcu_bh(&wdata->task.u.tk_rcu, nfs_commit_rcu_free);
 }
 
-struct nfs_write_data *nfs_writedata_alloc(size_t len)
+struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 {
-	unsigned int pagecount = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	struct nfs_write_data *p = mempool_alloc(nfs_wdata_mempool, GFP_NOFS);
 
 	if (p) {
@@ -139,7 +139,7 @@ static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int c
 {
 	struct inode *inode = page->mapping->host;
 	loff_t end, i_size = i_size_read(inode);
-	unsigned long end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
+	pgoff_t end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
 
 	if (i_size > 0 && page->index < end_index)
 		return;
@@ -201,7 +201,7 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 static int wb_priority(struct writeback_control *wbc)
 {
 	if (wbc->for_reclaim)
-		return FLUSH_HIGHPRI;
+		return FLUSH_HIGHPRI | FLUSH_STABLE;
 	if (wbc->for_kupdate)
 		return FLUSH_LOWPRI;
 	return 0;
@@ -251,7 +251,8 @@ static void nfs_end_page_writeback(struct page *page)
  * was not tagged.
  * May also return an error if the user signalled nfs_wait_on_request().
  */
-static int nfs_page_mark_flush(struct page *page)
+static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
+				struct page *page)
 {
 	struct nfs_page *req;
 	struct nfs_inode *nfsi = NFS_I(page->mapping->host);
@@ -273,6 +274,8 @@ static int nfs_page_mark_flush(struct page *page)
 		 *	 request as dirty (in which case we don't care).
 		 */
 		spin_unlock(req_lock);
+		/* Prevent deadlock! */
+		nfs_pageio_complete(pgio);
 		ret = nfs_wait_on_request(req);
 		nfs_release_request(req);
 		if (ret != 0)
@@ -283,21 +286,18 @@ static int nfs_page_mark_flush(struct page *page)
 		/* This request is marked for commit */
 		spin_unlock(req_lock);
 		nfs_unlock_request(req);
+		nfs_pageio_complete(pgio);
 		return 1;
 	}
-	if (nfs_set_page_writeback(page) == 0) {
-		nfs_list_remove_request(req);
-		/* add the request to the inode's dirty list. */
-		radix_tree_tag_set(&nfsi->nfs_page_tree,
-				req->wb_index, NFS_PAGE_TAG_DIRTY);
-		nfs_list_add_request(req, &nfsi->dirty);
-		nfsi->ndirty++;
-		spin_unlock(req_lock);
-		__mark_inode_dirty(page->mapping->host, I_DIRTY_PAGES);
-	} else
+	if (nfs_set_page_writeback(page) != 0) {
 		spin_unlock(req_lock);
+		BUG();
+	}
+	radix_tree_tag_set(&nfsi->nfs_page_tree, req->wb_index,
+			NFS_PAGE_TAG_WRITEBACK);
 	ret = test_bit(PG_NEED_FLUSH, &req->wb_flags);
-	nfs_unlock_request(req);
+	spin_unlock(req_lock);
+	nfs_pageio_add_request(pgio, req);
 	return ret;
 }
 
@@ -306,6 +306,7 @@ static int nfs_page_mark_flush(struct page *page)
  */
 static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc)
 {
+	struct nfs_pageio_descriptor mypgio, *pgio;
 	struct nfs_open_context *ctx;
 	struct inode *inode = page->mapping->host;
 	unsigned offset;
@@ -314,7 +315,14 @@ static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
 	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
 
-	err = nfs_page_mark_flush(page);
+	if (wbc->for_writepages)
+		pgio = wbc->fs_private;
+	else {
+		nfs_pageio_init_write(&mypgio, inode, wb_priority(wbc));
+		pgio = &mypgio;
+	}
+
+	err = nfs_page_async_flush(pgio, page);
 	if (err <= 0)
 		goto out;
 	err = 0;
@@ -331,12 +339,12 @@ static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc
 	put_nfs_open_context(ctx);
 	if (err != 0)
 		goto out;
-	err = nfs_page_mark_flush(page);
+	err = nfs_page_async_flush(pgio, page);
 	if (err > 0)
 		err = 0;
 out:
 	if (!wbc->for_writepages)
-		nfs_flush_mapping(page->mapping, wbc, FLUSH_STABLE|wb_priority(wbc));
+		nfs_pageio_complete(pgio);
 	return err;
 }
 
@@ -352,20 +360,20 @@ int nfs_writepage(struct page *page, struct writeback_control *wbc)
 int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
+	struct nfs_pageio_descriptor pgio;
 	int err;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGES);
 
+	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc));
+	wbc->fs_private = &pgio;
 	err = generic_writepages(mapping, wbc);
+	nfs_pageio_complete(&pgio);
 	if (err)
 		return err;
-	err = nfs_flush_mapping(mapping, wbc, wb_priority(wbc));
-	if (err < 0)
-		goto out;
-	nfs_add_stats(inode, NFSIOS_WRITEPAGES, err);
-	err = 0;
-out:
-	return err;
+	if (pgio.pg_error)
+		return pgio.pg_error;
+	return 0;
 }
 
 /*
@@ -503,11 +511,11 @@ int nfs_reschedule_unstable_write(struct nfs_page *req)
  *
  * Interruptible by signals only if mounted with intr flag.
  */
-static int nfs_wait_on_requests_locked(struct inode *inode, unsigned long idx_start, unsigned int npages)
+static int nfs_wait_on_requests_locked(struct inode *inode, pgoff_t idx_start, unsigned int npages)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_page *req;
-	unsigned long		idx_end, next;
+	pgoff_t idx_end, next;
 	unsigned int		res = 0;
 	int			error;
 
@@ -536,18 +544,6 @@ static int nfs_wait_on_requests_locked(struct inode *inode, unsigned long idx_st
 	return res;
 }
 
-static void nfs_cancel_dirty_list(struct list_head *head)
-{
-	struct nfs_page *req;
-	while(!list_empty(head)) {
-		req = nfs_list_entry(head->next);
-		nfs_list_remove_request(req);
-		nfs_end_page_writeback(req->wb_page);
-		nfs_inode_remove_request(req);
-		nfs_clear_page_writeback(req);
-	}
-}
-
 static void nfs_cancel_commit_list(struct list_head *head)
 {
 	struct nfs_page *req;
@@ -574,7 +570,7 @@ static void nfs_cancel_commit_list(struct list_head *head)
  * The requests are *not* checked to ensure that they form a contiguous set.
  */
 static int
-nfs_scan_commit(struct inode *inode, struct list_head *dst, unsigned long idx_start, unsigned int npages)
+nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, unsigned int npages)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int res = 0;
@@ -588,40 +584,12 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst, unsigned long idx_st
 	return res;
 }
 #else
-static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst, unsigned long idx_start, unsigned int npages)
+static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, unsigned int npages)
 {
 	return 0;
 }
 #endif
 
-static int nfs_wait_on_write_congestion(struct address_space *mapping)
-{
-	struct inode *inode = mapping->host;
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
-	int ret = 0;
-
-	might_sleep();
-
-	if (!bdi_write_congested(bdi))
-		return 0;
-
-	nfs_inc_stats(inode, NFSIOS_CONGESTIONWAIT);
-
-	do {
-		struct rpc_clnt *clnt = NFS_CLIENT(inode);
-		sigset_t oldset;
-
-		rpc_clnt_sigmask(clnt, &oldset);
-		ret = congestion_wait_interruptible(WRITE, HZ/10);
-		rpc_clnt_sigunmask(clnt, &oldset);
-		if (ret == -ERESTARTSYS)
-			break;
-		ret = 0;
-	} while (bdi_write_congested(bdi));
-
-	return ret;
-}
-
 /*
  * Try to update any existing write request, or create one if there is none.
  * In order to match, the request's credentials must match those of
@@ -636,12 +604,10 @@ static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 	struct inode *inode = mapping->host;
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_page		*req, *new = NULL;
-	unsigned long		rqend, end;
+	pgoff_t		rqend, end;
 
 	end = offset + bytes;
 
-	if (nfs_wait_on_write_congestion(mapping))
-		return ERR_PTR(-ERESTARTSYS);
 	for (;;) {
 		/* Loop over all inode entries and see if we find
 		 * A request for the page we wish to update
@@ -865,7 +831,7 @@ static void nfs_execute_write(struct nfs_write_data *data)
  * Generate multiple small requests to write out a single
  * contiguous dirty area on one page.
  */
-static int nfs_flush_multi(struct inode *inode, struct list_head *head, int how)
+static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how)
 {
 	struct nfs_page *req = nfs_list_entry(head->next);
 	struct page *page = req->wb_page;
@@ -877,11 +843,11 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, int how)
 
 	nfs_list_remove_request(req);
 
-	nbytes = req->wb_bytes;
+	nbytes = count;
 	do {
 		size_t len = min(nbytes, wsize);
 
-		data = nfs_writedata_alloc(len);
+		data = nfs_writedata_alloc(1);
 		if (!data)
 			goto out_bad;
 		list_add(&data->pages, &list);
@@ -892,23 +858,19 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, int how)
 
 	ClearPageError(page);
 	offset = 0;
-	nbytes = req->wb_bytes;
+	nbytes = count;
 	do {
 		data = list_entry(list.next, struct nfs_write_data, pages);
 		list_del_init(&data->pages);
 
 		data->pagevec[0] = page;
 
-		if (nbytes > wsize) {
-			nfs_write_rpcsetup(req, data, &nfs_write_partial_ops,
-					wsize, offset, how);
-			offset += wsize;
-			nbytes -= wsize;
-		} else {
-			nfs_write_rpcsetup(req, data, &nfs_write_partial_ops,
-					nbytes, offset, how);
-			nbytes = 0;
-		}
+		if (nbytes < wsize)
+			wsize = nbytes;
+		nfs_write_rpcsetup(req, data, &nfs_write_partial_ops,
+				   wsize, offset, how);
+		offset += wsize;
+		nbytes -= wsize;
 		nfs_execute_write(data);
 	} while (nbytes != 0);
 
@@ -934,26 +896,23 @@ out_bad:
  * This is the case if nfs_updatepage detects a conflicting request
  * that has been written but not committed.
  */
-static int nfs_flush_one(struct inode *inode, struct list_head *head, int how)
+static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
 	struct nfs_write_data	*data;
-	unsigned int		count;
 
-	data = nfs_writedata_alloc(NFS_SERVER(inode)->wsize);
+	data = nfs_writedata_alloc(npages);
 	if (!data)
 		goto out_bad;
 
 	pages = data->pagevec;
-	count = 0;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, &data->pages);
 		ClearPageError(req->wb_page);
 		*pages++ = req->wb_page;
-		count += req->wb_bytes;
 	}
 	req = nfs_list_entry(data->pages.next);
 
@@ -973,40 +932,15 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, int how)
 	return -ENOMEM;
 }
 
-static int nfs_flush_list(struct inode *inode, struct list_head *head, int npages, int how)
+static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
+				  struct inode *inode, int ioflags)
 {
-	LIST_HEAD(one_request);
-	int (*flush_one)(struct inode *, struct list_head *, int);
-	struct nfs_page	*req;
-	int wpages = NFS_SERVER(inode)->wpages;
 	int wsize = NFS_SERVER(inode)->wsize;
-	int error;
 
-	flush_one = nfs_flush_one;
 	if (wsize < PAGE_CACHE_SIZE)
-		flush_one = nfs_flush_multi;
-	/* For single writes, FLUSH_STABLE is more efficient */
-	if (npages <= wpages && npages == NFS_I(inode)->npages
-			&& nfs_list_entry(head->next)->wb_bytes <= wsize)
-		how |= FLUSH_STABLE;
-
-	do {
-		nfs_coalesce_requests(head, &one_request, wpages);
-		req = nfs_list_entry(one_request.next);
-		error = flush_one(inode, &one_request, how);
-		if (error < 0)
-			goto out_err;
-	} while (!list_empty(head));
-	return 0;
-out_err:
-	while (!list_empty(head)) {
-		req = nfs_list_entry(head->next);
-		nfs_list_remove_request(req);
-		nfs_redirty_request(req);
-		nfs_end_page_writeback(req->wb_page);
-		nfs_clear_page_writeback(req);
-	}
-	return error;
+		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
+	else
+		nfs_pageio_init(pgio, inode, nfs_flush_one, wsize, ioflags);
 }
 
 /*
@@ -1330,31 +1264,7 @@ static const struct rpc_call_ops nfs_commit_ops = {
 	.rpc_call_done = nfs_commit_done,
 	.rpc_release = nfs_commit_release,
 };
-#else
-static inline int nfs_commit_list(struct inode *inode, struct list_head *head, int how)
-{
-	return 0;
-}
-#endif
-
-static long nfs_flush_mapping(struct address_space *mapping, struct writeback_control *wbc, int how)
-{
-	struct nfs_inode *nfsi = NFS_I(mapping->host);
-	LIST_HEAD(head);
-	long res;
-
-	spin_lock(&nfsi->req_lock);
-	res = nfs_scan_dirty(mapping, wbc, &head);
-	spin_unlock(&nfsi->req_lock);
-	if (res) {
-		int error = nfs_flush_list(mapping->host, &head, res, how);
-		if (error < 0)
-			return error;
-	}
-	return res;
-}
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 int nfs_commit_inode(struct inode *inode, int how)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -1371,13 +1281,18 @@ int nfs_commit_inode(struct inode *inode, int how)
 	}
 	return res;
 }
+#else
+static inline int nfs_commit_list(struct inode *inode, struct list_head *head, int how)
+{
+	return 0;
+}
 #endif
 
 long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_control *wbc, int how)
 {
 	struct inode *inode = mapping->host;
 	struct nfs_inode *nfsi = NFS_I(inode);
-	unsigned long idx_start, idx_end;
+	pgoff_t idx_start, idx_end;
 	unsigned int npages = 0;
 	LIST_HEAD(head);
 	int nocommit = how & FLUSH_NOCOMMIT;
@@ -1390,41 +1305,24 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 		idx_start = wbc->range_start >> PAGE_CACHE_SHIFT;
 		idx_end = wbc->range_end >> PAGE_CACHE_SHIFT;
 		if (idx_end > idx_start) {
-			unsigned long l_npages = 1 + idx_end - idx_start;
+			pgoff_t l_npages = 1 + idx_end - idx_start;
 			npages = l_npages;
 			if (sizeof(npages) != sizeof(l_npages) &&
-					(unsigned long)npages != l_npages)
+					(pgoff_t)npages != l_npages)
 				npages = 0;
 		}
 	}
 	how &= ~FLUSH_NOCOMMIT;
 	spin_lock(&nfsi->req_lock);
 	do {
-		wbc->pages_skipped = 0;
 		ret = nfs_wait_on_requests_locked(inode, idx_start, npages);
 		if (ret != 0)
 			continue;
-		pages = nfs_scan_dirty(mapping, wbc, &head);
-		if (pages != 0) {
-			spin_unlock(&nfsi->req_lock);
-			if (how & FLUSH_INVALIDATE) {
-				nfs_cancel_dirty_list(&head);
-				ret = pages;
-			} else
-				ret = nfs_flush_list(inode, &head, pages, how);
-			spin_lock(&nfsi->req_lock);
-			continue;
-		}
-		if (wbc->pages_skipped != 0)
-			continue;
 		if (nocommit)
 			break;
 		pages = nfs_scan_commit(inode, &head, idx_start, npages);
-		if (pages == 0) {
-			if (wbc->pages_skipped != 0)
-				continue;
+		if (pages == 0)
 			break;
-		}
 		if (how & FLUSH_INVALIDATE) {
 			spin_unlock(&nfsi->req_lock);
 			nfs_cancel_commit_list(&head);
@@ -1456,7 +1354,7 @@ int nfs_wb_all(struct inode *inode)
 	};
 	int ret;
 
-	ret = generic_writepages(mapping, &wbc);
+	ret = nfs_writepages(mapping, &wbc);
 	if (ret < 0)
 		goto out;
 	ret = nfs_sync_mapping_wait(mapping, &wbc, 0);
@@ -1479,11 +1377,9 @@ int nfs_sync_mapping_range(struct address_space *mapping, loff_t range_start, lo
 	};
 	int ret;
 
-	if (!(how & FLUSH_NOWRITEPAGE)) {
-		ret = generic_writepages(mapping, &wbc);
-		if (ret < 0)
-			goto out;
-	}
+	ret = nfs_writepages(mapping, &wbc);
+	if (ret < 0)
+		goto out;
 	ret = nfs_sync_mapping_wait(mapping, &wbc, how);
 	if (ret >= 0)
 		return 0;
@@ -1506,7 +1402,7 @@ int nfs_wb_page_priority(struct inode *inode, struct page *page, int how)
 	int ret;
 
 	BUG_ON(!PageLocked(page));
-	if (!(how & FLUSH_NOWRITEPAGE) && clear_page_dirty_for_io(page)) {
+	if (clear_page_dirty_for_io(page)) {
 		ret = nfs_writepage_locked(page, &wbc);
 		if (ret < 0)
 			goto out;
@@ -1531,10 +1427,18 @@ int nfs_wb_page(struct inode *inode, struct page* page)
 
 int nfs_set_page_dirty(struct page *page)
 {
-	spinlock_t *req_lock = &NFS_I(page->mapping->host)->req_lock;
+	struct address_space *mapping = page->mapping;
+	struct inode *inode;
+	spinlock_t *req_lock;
 	struct nfs_page *req;
 	int ret;
 
+	if (!mapping)
+		goto out_raced;
+	inode = mapping->host;
+	if (!inode)
+		goto out_raced;
+	req_lock = &NFS_I(inode)->req_lock;
 	spin_lock(req_lock);
 	req = nfs_page_find_request_locked(page);
 	if (req != NULL) {
@@ -1547,6 +1451,8 @@ int nfs_set_page_dirty(struct page *page)
 	ret = __set_page_dirty_nobuffers(page);
 	spin_unlock(req_lock);
 	return ret;
+out_raced:
+	return !TestSetPageDirty(page);
 }
 
 
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index fb14d68..32ffea0 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -315,16 +315,13 @@ out:
 /*
  * RPC procedure tables
  */
-#ifndef MAX
-# define MAX(a, b)      (((a) > (b))? (a) : (b))
-#endif
-
 #define PROC(proc, call, argtype, restype)                              \
 [NFSPROC4_CLNT_##proc] = {                                      	\
         .p_proc   = NFSPROC4_CB_##call,					\
         .p_encode = (kxdrproc_t) nfs4_xdr_##argtype,                    \
         .p_decode = (kxdrproc_t) nfs4_xdr_##restype,                    \
-        .p_bufsiz = MAX(NFS4_##argtype##_sz,NFS4_##restype##_sz) << 2,  \
+        .p_arglen = NFS4_##argtype##_sz,                                \
+        .p_replen = NFS4_##restype##_sz,                                \
         .p_statidx = NFSPROC4_CB_##call,				\
 	.p_name   = #proc,                                              \
 }
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index ac25b56..f6a81e0 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -88,7 +88,7 @@ struct nlm_wait;
 /*
  * Memory chunk for NLM client RPC request.
  */
-#define NLMCLNT_OHSIZE		(sizeof(utsname()->nodename)+10)
+#define NLMCLNT_OHSIZE		((__NEW_UTS_LEN) + 10u)
 struct nlm_rqst {
 	unsigned int		a_flags;	/* initial RPC task flags */
 	struct nlm_host *	a_host;		/* host handle */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index e9ae0c6..0543439 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -455,7 +455,7 @@ nfs_have_writebacks(struct inode *inode)
 /*
  * Allocate nfs_write_data structures
  */
-extern struct nfs_write_data *nfs_writedata_alloc(size_t len);
+extern struct nfs_write_data *nfs_writedata_alloc(unsigned int npages);
 
 /*
  * linux/fs/nfs/read.c
@@ -469,7 +469,7 @@ extern void nfs_readdata_release(void *data);
 /*
  * Allocate nfs_read_data structures
  */
-extern struct nfs_read_data *nfs_readdata_alloc(size_t len);
+extern struct nfs_read_data *nfs_readdata_alloc(unsigned int npages);
 
 /*
  * linux/fs/nfs3proc.c
diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
index 659c754..cc8b9c5 100644
--- a/include/linux/nfs_mount.h
+++ b/include/linux/nfs_mount.h
@@ -61,6 +61,7 @@ struct nfs_mount_data {
 #define NFS_MOUNT_NOACL		0x0800	/* 4 */
 #define NFS_MOUNT_STRICTLOCK	0x1000	/* reserved for NFSv4 */
 #define NFS_MOUNT_SECFLAVOUR	0x2000	/* 5 */
+#define NFS_MOUNT_NORDIRPLUS	0x4000	/* 5 */
 #define NFS_MOUNT_FLAGMASK	0xFFFF
 
 #endif
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 16b0266..41afab6 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -21,8 +21,7 @@
 /*
  * Valid flags for the radix tree
  */
-#define NFS_PAGE_TAG_DIRTY	0
-#define NFS_PAGE_TAG_WRITEBACK	1
+#define NFS_PAGE_TAG_WRITEBACK	0
 
 /*
  * Valid flags for a dirty buffer
@@ -39,7 +38,7 @@ struct nfs_page {
 	struct page		*wb_page;	/* page to read in/write out */
 	struct nfs_open_context	*wb_context;	/* File state context info */
 	atomic_t		wb_complete;	/* i/os we're waiting for */
-	unsigned long		wb_index;	/* Offset >> PAGE_CACHE_SHIFT */
+	pgoff_t			wb_index;	/* Offset >> PAGE_CACHE_SHIFT */
 	unsigned int		wb_offset,	/* Offset & ~PAGE_CACHE_MASK */
 				wb_pgbase,	/* Start of page data */
 				wb_bytes;	/* Length of request */
@@ -48,6 +47,19 @@ struct nfs_page {
 	struct nfs_writeverf	wb_verf;	/* Commit cookie */
 };
 
+struct nfs_pageio_descriptor {
+	struct list_head	pg_list;
+	unsigned long		pg_bytes_written;
+	size_t			pg_count;
+	size_t			pg_bsize;
+	unsigned int		pg_base;
+
+	struct inode		*pg_inode;
+	int			(*pg_doio)(struct inode *, struct list_head *, unsigned int, size_t, int);
+	int 			pg_ioflags;
+	int			pg_error;
+};
+
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
 
 extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
@@ -59,13 +71,16 @@ extern	void nfs_clear_request(struct nfs_page *req);
 extern	void nfs_release_request(struct nfs_page *req);
 
 
-extern	long nfs_scan_dirty(struct address_space *mapping,
-				struct writeback_control *wbc,
-				struct list_head *dst);
 extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *head, struct list_head *dst,
-			  unsigned long idx_start, unsigned int npages);
-extern	int nfs_coalesce_requests(struct list_head *, struct list_head *,
-				  unsigned int);
+			  pgoff_t idx_start, unsigned int npages);
+extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
+			     struct inode *inode,
+			     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int),
+			     size_t bsize,
+			     int how);
+extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
+				   struct nfs_page *);
+extern	void nfs_pageio_complete(struct nfs_pageio_descriptor *desc);
 extern  int nfs_wait_on_request(struct nfs_page *);
 extern	void nfs_unlock_request(struct nfs_page *req);
 extern  int nfs_set_page_writeback_locked(struct nfs_page *req);
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index c7a78ee..6661142 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -84,7 +84,8 @@ struct rpc_procinfo {
 	u32			p_proc;		/* RPC procedure number */
 	kxdrproc_t		p_encode;	/* XDR encode function */
 	kxdrproc_t		p_decode;	/* XDR decode function */
-	unsigned int		p_bufsiz;	/* req. buffer size */
+	unsigned int		p_arglen;	/* argument hdr length (u32) */
+	unsigned int		p_replen;	/* reply hdr length (u32) */
 	unsigned int		p_count;	/* call count */
 	unsigned int		p_timer;	/* Which RTT timer to use */
 	u32			p_statidx;	/* Which procedure to account */
@@ -121,8 +122,8 @@ struct rpc_clnt *rpc_clone_client(struct rpc_clnt *);
 int		rpc_shutdown_client(struct rpc_clnt *);
 int		rpc_destroy_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
-void		rpc_getport(struct rpc_task *);
-int		rpc_register(u32, u32, int, unsigned short, int *);
+int		rpcb_register(u32, u32, int, unsigned short, int *);
+void		rpcb_getport(struct rpc_task *);
 
 void		rpc_call_setup(struct rpc_task *, struct rpc_message *, int);
 
@@ -144,7 +145,7 @@ char *		rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
 /*
  * Helper function for NFSroot support
  */
-int		rpc_getport_external(struct sockaddr_in *, __u32, __u32, int);
+int		rpcb_getport_external(struct sockaddr_in *, __u32, __u32, int);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index b7c7307..3912cf1 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -17,7 +17,7 @@
 #define RPCDBG_DEBUG		0x0004
 #define RPCDBG_NFS		0x0008
 #define RPCDBG_AUTH		0x0010
-#define RPCDBG_PMAP		0x0020
+#define RPCDBG_BIND		0x0020
 #define RPCDBG_SCHED		0x0040
 #define RPCDBG_TRANS		0x0080
 #define RPCDBG_SVCSOCK		0x0100
diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index 606cb21..784d4c3 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -78,10 +78,6 @@ enum rpc_auth_stat {
 	RPCSEC_GSS_CTXPROBLEM = 14
 };
 
-#define RPC_PMAP_PROGRAM	100000
-#define RPC_PMAP_VERSION	2
-#define RPC_PMAP_PORT		111
-
 #define RPC_MAXNETNAMELEN	256
 
 /*
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 3069ecc..2047fb2 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -264,7 +264,7 @@ struct rpc_task *rpc_wake_up_next(struct rpc_wait_queue *);
 void		rpc_wake_up_status(struct rpc_wait_queue *, int);
 void		rpc_delay(struct rpc_task *, unsigned long);
 void *		rpc_malloc(struct rpc_task *, size_t);
-void		rpc_free(struct rpc_task *);
+void		rpc_free(void *);
 int		rpciod_up(void);
 void		rpciod_down(void);
 int		__rpc_wait_for_completion_task(struct rpc_task *task, int (*)(void *));
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index f780e72..fa89ce6 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -84,7 +84,9 @@ struct rpc_rqst {
 	struct list_head	rq_list;
 
 	__u32 *			rq_buffer;	/* XDR encode buffer */
-	size_t			rq_bufsize;
+	size_t			rq_bufsize,
+				rq_callsize,
+				rq_rcvsize;
 
 	struct xdr_buf		rq_private_buf;		/* The receive buffer
 							 * used in the softirq.
@@ -112,7 +114,7 @@ struct rpc_xprt_ops {
 	void		(*set_port)(struct rpc_xprt *xprt, unsigned short port);
 	void		(*connect)(struct rpc_task *task);
 	void *		(*buf_alloc)(struct rpc_task *task, size_t size);
-	void		(*buf_free)(struct rpc_task *task);
+	void		(*buf_free)(void *buffer);
 	int		(*send_request)(struct rpc_task *task);
 	void		(*set_retrans_timeout)(struct rpc_task *task);
 	void		(*timer)(struct rpc_task *task);
@@ -150,6 +152,7 @@ struct rpc_xprt {
 	unsigned long		state;		/* transport state */
 	unsigned char		shutdown   : 1,	/* being shut down */
 				resvport   : 1; /* use a reserved port */
+	unsigned int		bind_index;	/* bind function index */
 
 	/*
 	 * Connection of transports
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 0c78f7f..daa6c12 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -59,6 +59,8 @@ struct writeback_control {
 	unsigned for_reclaim:1;		/* Invoked from the page allocator */
 	unsigned for_writepages:1;	/* This is a writepages() call */
 	unsigned range_cyclic:1;	/* range_start is cyclic */
+
+	void *fs_private;		/* For use by ->writepages() */
 };
 
 /*
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index cdcab9c..8ebfc4d 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -9,7 +9,7 @@ obj-$(CONFIG_SUNRPC_GSS) += auth_gss/
 sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    auth.o auth_null.o auth_unix.o \
 	    svc.o svcsock.o svcauth.o svcauth_unix.o \
-	    pmap_clnt.o timer.o xdr.o \
+	    rpcb_clnt.o timer.o xdr.o \
 	    sunrpc_syms.o cache.o rpc_pipe.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/sunrpc/auth_gss/gss_spkm3_seal.c b/net/sunrpc/auth_gss/gss_spkm3_seal.c
index 104cbf4..d158635 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_seal.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_seal.c
@@ -123,9 +123,6 @@ spkm3_make_token(struct spkm3_ctx *ctx,
 
 	return  GSS_S_COMPLETE;
 out_err:
-	if (md5cksum.data)
-		kfree(md5cksum.data);
-
 	token->data = NULL;
 	token->len = 0;
 	return GSS_S_FAILURE;
@@ -152,7 +149,7 @@ make_spkm3_checksum(s32 cksumtype, struct xdr_netobj *key, char *header,
 
 	switch (cksumtype) {
 		case CKSUMTYPE_HMAC_MD5:
-			cksumname = "md5";
+			cksumname = "hmac(md5)";
 			break;
 		default:
 			dprintk("RPC:       spkm3_make_checksum:"
@@ -172,8 +169,12 @@ make_spkm3_checksum(s32 cksumtype, struct xdr_netobj *key, char *header,
 	if (err)
 		goto out;
 
+	err = crypto_hash_init(&desc);
+	if (err)
+		goto out;
+
 	sg_set_buf(sg, header, hdrlen);
-	crypto_hash_update(&desc, sg, 1);
+	crypto_hash_update(&desc, sg, sg->length);
 
 	xdr_process_buf(body, body_offset, body->len - body_offset,
 			spkm3_checksummer, &desc);
@@ -184,5 +185,3 @@ out:
 
 	return err ? GSS_S_FAILURE : 0;
 }
-
-EXPORT_SYMBOL(make_spkm3_checksum);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 396cdbe..d8fbee4 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -36,8 +36,6 @@
 #include <linux/sunrpc/metrics.h>
 
 
-#define RPC_SLACK_SPACE		(1024)	/* total overkill */
-
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_CALL
 #endif
@@ -747,21 +745,38 @@ call_reserveresult(struct rpc_task *task)
 static void
 call_allocate(struct rpc_task *task)
 {
+	unsigned int slack = task->tk_auth->au_cslack;
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = task->tk_xprt;
-	unsigned int	bufsiz;
+	struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
 
 	dprint_status(task);
 
+	task->tk_status = 0;
 	task->tk_action = call_bind;
+
 	if (req->rq_buffer)
 		return;
 
-	/* FIXME: compute buffer requirements more exactly using
-	 * auth->au_wslack */
-	bufsiz = task->tk_msg.rpc_proc->p_bufsiz + RPC_SLACK_SPACE;
+	if (proc->p_proc != 0) {
+		BUG_ON(proc->p_arglen == 0);
+		if (proc->p_decode != NULL)
+			BUG_ON(proc->p_replen == 0);
+	}
 
-	if (xprt->ops->buf_alloc(task, bufsiz << 1) != NULL)
+	/*
+	 * Calculate the size (in quads) of the RPC call
+	 * and reply headers, and convert both values
+	 * to byte sizes.
+	 */
+	req->rq_callsize = RPC_CALLHDRSIZE + (slack << 1) + proc->p_arglen;
+	req->rq_callsize <<= 2;
+	req->rq_rcvsize = RPC_REPHDRSIZE + slack + proc->p_replen;
+	req->rq_rcvsize <<= 2;
+
+	req->rq_buffer = xprt->ops->buf_alloc(task,
+					req->rq_callsize + req->rq_rcvsize);
+	if (req->rq_buffer != NULL)
 		return;
 
 	dprintk("RPC: %5u rpc_buffer allocation failed\n", task->tk_pid);
@@ -788,6 +803,17 @@ rpc_task_force_reencode(struct rpc_task *task)
 	task->tk_rqstp->rq_snd_buf.len = 0;
 }
 
+static inline void
+rpc_xdr_buf_init(struct xdr_buf *buf, void *start, size_t len)
+{
+	buf->head[0].iov_base = start;
+	buf->head[0].iov_len = len;
+	buf->tail[0].iov_len = 0;
+	buf->page_len = 0;
+	buf->len = 0;
+	buf->buflen = len;
+}
+
 /*
  * 3.	Encode arguments of an RPC call
  */
@@ -795,28 +821,17 @@ static void
 call_encode(struct rpc_task *task)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
-	struct xdr_buf *sndbuf = &req->rq_snd_buf;
-	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
-	unsigned int	bufsiz;
 	kxdrproc_t	encode;
 	__be32		*p;
 
 	dprint_status(task);
 
-	/* Default buffer setup */
-	bufsiz = req->rq_bufsize >> 1;
-	sndbuf->head[0].iov_base = (void *)req->rq_buffer;
-	sndbuf->head[0].iov_len  = bufsiz;
-	sndbuf->tail[0].iov_len  = 0;
-	sndbuf->page_len	 = 0;
-	sndbuf->len		 = 0;
-	sndbuf->buflen		 = bufsiz;
-	rcvbuf->head[0].iov_base = (void *)((char *)req->rq_buffer + bufsiz);
-	rcvbuf->head[0].iov_len  = bufsiz;
-	rcvbuf->tail[0].iov_len  = 0;
-	rcvbuf->page_len	 = 0;
-	rcvbuf->len		 = 0;
-	rcvbuf->buflen		 = bufsiz;
+	rpc_xdr_buf_init(&req->rq_snd_buf,
+			 req->rq_buffer,
+			 req->rq_callsize);
+	rpc_xdr_buf_init(&req->rq_rcv_buf,
+			 (char *)req->rq_buffer + req->rq_callsize,
+			 req->rq_rcvsize);
 
 	/* Encode header and provided arguments */
 	encode = task->tk_msg.rpc_proc->p_encode;
@@ -887,9 +902,11 @@ call_bind_status(struct rpc_task *task)
 				task->tk_pid);
 		break;
 	case -EPROTONOSUPPORT:
-		dprintk("RPC: %5u remote rpcbind version 2 unavailable\n",
+		dprintk("RPC: %5u remote rpcbind version unavailable, retrying\n",
 				task->tk_pid);
-		break;
+		task->tk_status = 0;
+		task->tk_action = call_bind;
+		return;
 	default:
 		dprintk("RPC: %5u unrecognized rpcbind error (%d)\n",
 				task->tk_pid, -task->tk_status);
diff --git a/net/sunrpc/pmap_clnt.c b/net/sunrpc/pmap_clnt.c
deleted file mode 100644
index d9f7653..0000000
--- a/net/sunrpc/pmap_clnt.c
+++ /dev/null
@@ -1,383 +0,0 @@
-/*
- * linux/net/sunrpc/pmap_clnt.c
- *
- * In-kernel RPC portmapper client.
- *
- * Portmapper supports version 2 of the rpcbind protocol (RFC 1833).
- *
- * Copyright (C) 1996, Olaf Kirch <okir@monad.swb.de>
- */
-
-#include <linux/types.h>
-#include <linux/socket.h>
-#include <linux/kernel.h>
-#include <linux/errno.h>
-#include <linux/uio.h>
-#include <linux/in.h>
-#include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/sched.h>
-
-#ifdef RPC_DEBUG
-# define RPCDBG_FACILITY	RPCDBG_PMAP
-#endif
-
-#define PMAP_SET		1
-#define PMAP_UNSET		2
-#define PMAP_GETPORT		3
-
-struct portmap_args {
-	u32			pm_prog;
-	u32			pm_vers;
-	u32			pm_prot;
-	unsigned short		pm_port;
-	struct rpc_xprt *	pm_xprt;
-};
-
-static struct rpc_procinfo	pmap_procedures[];
-static struct rpc_clnt *	pmap_create(char *, struct sockaddr_in *, int, int);
-static void			pmap_getport_done(struct rpc_task *, void *);
-static struct rpc_program	pmap_program;
-
-static void pmap_getport_prepare(struct rpc_task *task, void *calldata)
-{
-	struct portmap_args *map = calldata;
-	struct rpc_message msg = {
-		.rpc_proc	= &pmap_procedures[PMAP_GETPORT],
-		.rpc_argp	= map,
-		.rpc_resp	= &map->pm_port,
-	};
-
-	rpc_call_setup(task, &msg, 0);
-}
-
-static inline struct portmap_args *pmap_map_alloc(void)
-{
-	return kmalloc(sizeof(struct portmap_args), GFP_NOFS);
-}
-
-static inline void pmap_map_free(struct portmap_args *map)
-{
-	kfree(map);
-}
-
-static void pmap_map_release(void *data)
-{
-	struct portmap_args *map = data;
-
-	xprt_put(map->pm_xprt);
-	pmap_map_free(map);
-}
-
-static const struct rpc_call_ops pmap_getport_ops = {
-	.rpc_call_prepare	= pmap_getport_prepare,
-	.rpc_call_done		= pmap_getport_done,
-	.rpc_release		= pmap_map_release,
-};
-
-static inline void pmap_wake_portmap_waiters(struct rpc_xprt *xprt, int status)
-{
-	xprt_clear_binding(xprt);
-	rpc_wake_up_status(&xprt->binding, status);
-}
-
-/**
- * rpc_getport - obtain the port for a given RPC service on a given host
- * @task: task that is waiting for portmapper request
- *
- * This one can be called for an ongoing RPC request, and can be used in
- * an async (rpciod) context.
- */
-void rpc_getport(struct rpc_task *task)
-{
-	struct rpc_clnt *clnt = task->tk_client;
-	struct rpc_xprt *xprt = task->tk_xprt;
-	struct sockaddr_in addr;
-	struct portmap_args *map;
-	struct rpc_clnt	*pmap_clnt;
-	struct rpc_task *child;
-	int status;
-
-	dprintk("RPC: %5u rpc_getport(%s, %u, %u, %d)\n",
-			task->tk_pid, clnt->cl_server,
-			clnt->cl_prog, clnt->cl_vers, xprt->prot);
-
-	/* Autobind on cloned rpc clients is discouraged */
-	BUG_ON(clnt->cl_parent != clnt);
-
-	status = -EACCES;		/* tell caller to check again */
-	if (xprt_test_and_set_binding(xprt))
-		goto bailout_nowake;
-
-	/* Put self on queue before sending rpcbind request, in case
-	 * pmap_getport_done completes before we return from rpc_run_task */
-	rpc_sleep_on(&xprt->binding, task, NULL, NULL);
-
-	/* Someone else may have bound if we slept */
-	status = 0;
-	if (xprt_bound(xprt))
-		goto bailout_nofree;
-
-	status = -ENOMEM;
-	map = pmap_map_alloc();
-	if (!map)
-		goto bailout_nofree;
-	map->pm_prog = clnt->cl_prog;
-	map->pm_vers = clnt->cl_vers;
-	map->pm_prot = xprt->prot;
-	map->pm_port = 0;
-	map->pm_xprt = xprt_get(xprt);
-
-	rpc_peeraddr(clnt, (struct sockaddr *) &addr, sizeof(addr));
-	pmap_clnt = pmap_create(clnt->cl_server, &addr, map->pm_prot, 0);
-	status = PTR_ERR(pmap_clnt);
-	if (IS_ERR(pmap_clnt))
-		goto bailout;
-
-	status = -EIO;
-	child = rpc_run_task(pmap_clnt, RPC_TASK_ASYNC, &pmap_getport_ops, map);
-	if (IS_ERR(child))
-		goto bailout_nofree;
-	rpc_put_task(child);
-
-	task->tk_xprt->stat.bind_count++;
-	return;
-
-bailout:
-	pmap_map_free(map);
-	xprt_put(xprt);
-bailout_nofree:
-	pmap_wake_portmap_waiters(xprt, status);
-bailout_nowake:
-	task->tk_status = status;
-}
-
-#ifdef CONFIG_ROOT_NFS
-/**
- * rpc_getport_external - obtain the port for a given RPC service on a given host
- * @sin: address of remote peer
- * @prog: RPC program number to bind
- * @vers: RPC version number to bind
- * @prot: transport protocol to use to make this request
- *
- * This one is called from outside the RPC client in a synchronous task context.
- */
-int rpc_getport_external(struct sockaddr_in *sin, __u32 prog, __u32 vers, int prot)
-{
-	struct portmap_args map = {
-		.pm_prog	= prog,
-		.pm_vers	= vers,
-		.pm_prot	= prot,
-		.pm_port	= 0
-	};
-	struct rpc_message msg = {
-		.rpc_proc	= &pmap_procedures[PMAP_GETPORT],
-		.rpc_argp	= &map,
-		.rpc_resp	= &map.pm_port,
-	};
-	struct rpc_clnt	*pmap_clnt;
-	char		hostname[32];
-	int		status;
-
-	dprintk("RPC:       rpc_getport_external(%u.%u.%u.%u, %u, %u, %d)\n",
-			NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
-
-	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(sin->sin_addr.s_addr));
-	pmap_clnt = pmap_create(hostname, sin, prot, 0);
-	if (IS_ERR(pmap_clnt))
-		return PTR_ERR(pmap_clnt);
-
-	/* Setup the call info struct */
-	status = rpc_call_sync(pmap_clnt, &msg, 0);
-
-	if (status >= 0) {
-		if (map.pm_port != 0)
-			return map.pm_port;
-		status = -EACCES;
-	}
-	return status;
-}
-#endif
-
-/*
- * Portmapper child task invokes this callback via tk_exit.
- */
-static void pmap_getport_done(struct rpc_task *child, void *data)
-{
-	struct portmap_args *map = data;
-	struct rpc_xprt *xprt = map->pm_xprt;
-	int status = child->tk_status;
-
-	if (status < 0) {
-		/* Portmapper not available */
-		xprt->ops->set_port(xprt, 0);
-	} else if (map->pm_port == 0) {
-		/* Requested RPC service wasn't registered */
-		xprt->ops->set_port(xprt, 0);
-		status = -EACCES;
-	} else {
-		/* Succeeded */
-		xprt->ops->set_port(xprt, map->pm_port);
-		xprt_set_bound(xprt);
-		status = 0;
-	}
-
-	dprintk("RPC: %5u pmap_getport_done(status %d, port %u)\n",
-			child->tk_pid, status, map->pm_port);
-
-	pmap_wake_portmap_waiters(xprt, status);
-}
-
-/**
- * rpc_register - set or unset a port registration with the local portmapper
- * @prog: RPC program number to bind
- * @vers: RPC version number to bind
- * @prot: transport protocol to use to make this request
- * @port: port value to register
- * @okay: result code
- *
- * port == 0 means unregister, port != 0 means register.
- */
-int rpc_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
-{
-	struct sockaddr_in	sin = {
-		.sin_family	= AF_INET,
-		.sin_addr.s_addr = htonl(INADDR_LOOPBACK),
-	};
-	struct portmap_args	map = {
-		.pm_prog	= prog,
-		.pm_vers	= vers,
-		.pm_prot	= prot,
-		.pm_port	= port,
-	};
-	struct rpc_message msg = {
-		.rpc_proc	= &pmap_procedures[port ? PMAP_SET : PMAP_UNSET],
-		.rpc_argp	= &map,
-		.rpc_resp	= okay,
-	};
-	struct rpc_clnt		*pmap_clnt;
-	int error = 0;
-
-	dprintk("RPC:       registering (%u, %u, %d, %u) with portmapper.\n",
-			prog, vers, prot, port);
-
-	pmap_clnt = pmap_create("localhost", &sin, IPPROTO_UDP, 1);
-	if (IS_ERR(pmap_clnt)) {
-		error = PTR_ERR(pmap_clnt);
-		dprintk("RPC:       couldn't create pmap client. Error = %d\n",
-				error);
-		return error;
-	}
-
-	error = rpc_call_sync(pmap_clnt, &msg, 0);
-
-	if (error < 0) {
-		printk(KERN_WARNING
-			"RPC: failed to contact portmap (errno %d).\n",
-			error);
-	}
-	dprintk("RPC:       registration status %d/%d\n", error, *okay);
-
-	/* Client deleted automatically because cl_oneshot == 1 */
-	return error;
-}
-
-static struct rpc_clnt *pmap_create(char *hostname, struct sockaddr_in *srvaddr, int proto, int privileged)
-{
-	struct rpc_create_args args = {
-		.protocol	= proto,
-		.address	= (struct sockaddr *)srvaddr,
-		.addrsize	= sizeof(*srvaddr),
-		.servername	= hostname,
-		.program	= &pmap_program,
-		.version	= RPC_PMAP_VERSION,
-		.authflavor	= RPC_AUTH_UNIX,
-		.flags		= (RPC_CLNT_CREATE_ONESHOT |
-				   RPC_CLNT_CREATE_NOPING),
-	};
-
-	srvaddr->sin_port = htons(RPC_PMAP_PORT);
-	if (!privileged)
-		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
-	return rpc_create(&args);
-}
-
-/*
- * XDR encode/decode functions for PMAP
- */
-static int xdr_encode_mapping(struct rpc_rqst *req, __be32 *p, struct portmap_args *map)
-{
-	dprintk("RPC:       xdr_encode_mapping(%u, %u, %u, %u)\n",
-			map->pm_prog, map->pm_vers,
-			map->pm_prot, map->pm_port);
-	*p++ = htonl(map->pm_prog);
-	*p++ = htonl(map->pm_vers);
-	*p++ = htonl(map->pm_prot);
-	*p++ = htonl(map->pm_port);
-
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-static int xdr_decode_port(struct rpc_rqst *req, __be32 *p, unsigned short *portp)
-{
-	*portp = (unsigned short) ntohl(*p++);
-	return 0;
-}
-
-static int xdr_decode_bool(struct rpc_rqst *req, __be32 *p, unsigned int *boolp)
-{
-	*boolp = (unsigned int) ntohl(*p++);
-	return 0;
-}
-
-static struct rpc_procinfo	pmap_procedures[] = {
-[PMAP_SET] = {
-	  .p_proc		= PMAP_SET,
-	  .p_encode		= (kxdrproc_t) xdr_encode_mapping,
-	  .p_decode		= (kxdrproc_t) xdr_decode_bool,
-	  .p_bufsiz		= 4,
-	  .p_count		= 1,
-	  .p_statidx		= PMAP_SET,
-	  .p_name		= "SET",
-	},
-[PMAP_UNSET] = {
-	  .p_proc		= PMAP_UNSET,
-	  .p_encode		= (kxdrproc_t) xdr_encode_mapping,
-	  .p_decode		= (kxdrproc_t) xdr_decode_bool,
-	  .p_bufsiz		= 4,
-	  .p_count		= 1,
-	  .p_statidx		= PMAP_UNSET,
-	  .p_name		= "UNSET",
-	},
-[PMAP_GETPORT] = {
-	  .p_proc		= PMAP_GETPORT,
-	  .p_encode		= (kxdrproc_t) xdr_encode_mapping,
-	  .p_decode		= (kxdrproc_t) xdr_decode_port,
-	  .p_bufsiz		= 4,
-	  .p_count		= 1,
-	  .p_statidx		= PMAP_GETPORT,
-	  .p_name		= "GETPORT",
-	},
-};
-
-static struct rpc_version	pmap_version2 = {
-	.number		= 2,
-	.nrprocs	= 4,
-	.procs		= pmap_procedures
-};
-
-static struct rpc_version *	pmap_version[] = {
-	NULL,
-	NULL,
-	&pmap_version2
-};
-
-static struct rpc_stat		pmap_stats;
-
-static struct rpc_program	pmap_program = {
-	.name		= "portmap",
-	.number		= RPC_PMAP_PROGRAM,
-	.nrvers		= ARRAY_SIZE(pmap_version),
-	.version	= pmap_version,
-	.stats		= &pmap_stats,
-};
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
new file mode 100644
index 0000000..6c7aa8a
--- /dev/null
+++ b/net/sunrpc/rpcb_clnt.c
@@ -0,0 +1,625 @@
+/*
+ * In-kernel rpcbind client supporting versions 2, 3, and 4 of the rpcbind
+ * protocol
+ *
+ * Based on RFC 1833: "Binding Protocols for ONC RPC Version 2" and
+ * RFC 3530: "Network File System (NFS) version 4 Protocol"
+ *
+ * Original: Gilles Quillard, Bull Open Source, 2005 <gilles.quillard@bull.net>
+ * Updated: Chuck Lever, Oracle Corporation, 2007 <chuck.lever@oracle.com>
+ *
+ * Descended from net/sunrpc/pmap_clnt.c,
+ *  Copyright (C) 1996, Olaf Kirch <okir@monad.swb.de>
+ */
+
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/sched.h>
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY	RPCDBG_BIND
+#endif
+
+#define RPCBIND_PROGRAM		(100000u)
+#define RPCBIND_PORT		(111u)
+
+enum {
+	RPCBPROC_NULL,
+	RPCBPROC_SET,
+	RPCBPROC_UNSET,
+	RPCBPROC_GETPORT,
+	RPCBPROC_GETADDR = 3,		/* alias for GETPORT */
+	RPCBPROC_DUMP,
+	RPCBPROC_CALLIT,
+	RPCBPROC_BCAST = 5,		/* alias for CALLIT */
+	RPCBPROC_GETTIME,
+	RPCBPROC_UADDR2TADDR,
+	RPCBPROC_TADDR2UADDR,
+	RPCBPROC_GETVERSADDR,
+	RPCBPROC_INDIRECT,
+	RPCBPROC_GETADDRLIST,
+	RPCBPROC_GETSTAT,
+};
+
+#define RPCB_HIGHPROC_2		RPCBPROC_CALLIT
+#define RPCB_HIGHPROC_3		RPCBPROC_TADDR2UADDR
+#define RPCB_HIGHPROC_4		RPCBPROC_GETSTAT
+
+/*
+ * r_addr
+ *
+ * Quoting RFC 3530, section 2.2:
+ *
+ * For TCP over IPv4 and for UDP over IPv4, the format of r_addr is the
+ * US-ASCII string:
+ *
+ *	h1.h2.h3.h4.p1.p2
+ *
+ * The prefix, "h1.h2.h3.h4", is the standard textual form for
+ * representing an IPv4 address, which is always four octets long.
+ * Assuming big-endian ordering, h1, h2, h3, and h4, are respectively,
+ * the first through fourth octets each converted to ASCII-decimal.
+ * Assuming big-endian ordering, p1 and p2 are, respectively, the first
+ * and second octets each converted to ASCII-decimal.  For example, if a
+ * host, in big-endian order, has an address of 0x0A010307 and there is
+ * a service listening on, in big endian order, port 0x020F (decimal
+ * 527), then the complete universal address is "10.1.3.7.2.15".
+ *
+ * ...
+ *
+ * For TCP over IPv6 and for UDP over IPv6, the format of r_addr is the
+ * US-ASCII string:
+ *
+ *	x1:x2:x3:x4:x5:x6:x7:x8.p1.p2
+ *
+ * The suffix "p1.p2" is the service port, and is computed the same way
+ * as with universal addresses for TCP and UDP over IPv4.  The prefix,
+ * "x1:x2:x3:x4:x5:x6:x7:x8", is the standard textual form for
+ * representing an IPv6 address as defined in Section 2.2 of [RFC2373].
+ * Additionally, the two alternative forms specified in Section 2.2 of
+ * [RFC2373] are also acceptable.
+ *
+ * XXX: Currently this implementation does not explicitly convert the
+ *      stored address to US-ASCII on non-ASCII systems.
+ */
+#define RPCB_MAXADDRLEN		(128u)
+
+/*
+ * r_netid
+ *
+ * Quoting RFC 3530, section 2.2:
+ *
+ * For TCP over IPv4 the value of r_netid is the string "tcp".  For UDP
+ * over IPv4 the value of r_netid is the string "udp".
+ *
+ * ...
+ *
+ * For TCP over IPv6 the value of r_netid is the string "tcp6".  For UDP
+ * over IPv6 the value of r_netid is the string "udp6".
+ */
+#define RPCB_NETID_UDP	"\165\144\160"		/* "udp" */
+#define RPCB_NETID_TCP	"\164\143\160"		/* "tcp" */
+#define RPCB_NETID_UDP6	"\165\144\160\066"	/* "udp6" */
+#define RPCB_NETID_TCP6	"\164\143\160\066"	/* "tcp6" */
+
+#define RPCB_MAXNETIDLEN	(4u)
+
+/*
+ * r_owner
+ *
+ * The "owner" is allowed to unset a service in the rpcbind database.
+ * We always use the following (arbitrary) fixed string.
+ */
+#define RPCB_OWNER_STRING	"rpcb"
+#define RPCB_MAXOWNERLEN	sizeof(RPCB_OWNER_STRING)
+
+static void			rpcb_getport_done(struct rpc_task *, void *);
+extern struct rpc_program	rpcb_program;
+
+struct rpcbind_args {
+	struct rpc_xprt *	r_xprt;
+
+	u32			r_prog;
+	u32			r_vers;
+	u32			r_prot;
+	unsigned short		r_port;
+	char *			r_netid;
+	char			r_addr[RPCB_MAXADDRLEN];
+	char *			r_owner;
+};
+
+static struct rpc_procinfo rpcb_procedures2[];
+static struct rpc_procinfo rpcb_procedures3[];
+
+static struct rpcb_info {
+	int			rpc_vers;
+	struct rpc_procinfo *	rpc_proc;
+} rpcb_next_version[];
+
+static void rpcb_getport_prepare(struct rpc_task *task, void *calldata)
+{
+	struct rpcbind_args *map = calldata;
+	struct rpc_xprt *xprt = map->r_xprt;
+	struct rpc_message msg = {
+		.rpc_proc	= rpcb_next_version[xprt->bind_index].rpc_proc,
+		.rpc_argp	= map,
+		.rpc_resp	= &map->r_port,
+	};
+
+	rpc_call_setup(task, &msg, 0);
+}
+
+static void rpcb_map_release(void *data)
+{
+	struct rpcbind_args *map = data;
+
+	xprt_put(map->r_xprt);
+	kfree(map);
+}
+
+static const struct rpc_call_ops rpcb_getport_ops = {
+	.rpc_call_prepare	= rpcb_getport_prepare,
+	.rpc_call_done		= rpcb_getport_done,
+	.rpc_release		= rpcb_map_release,
+};
+
+static void rpcb_wake_rpcbind_waiters(struct rpc_xprt *xprt, int status)
+{
+	xprt_clear_binding(xprt);
+	rpc_wake_up_status(&xprt->binding, status);
+}
+
+static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
+					int proto, int version, int privileged)
+{
+	struct rpc_create_args args = {
+		.protocol	= proto,
+		.address	= srvaddr,
+		.addrsize	= sizeof(struct sockaddr_in),
+		.servername	= hostname,
+		.program	= &rpcb_program,
+		.version	= version,
+		.authflavor	= RPC_AUTH_UNIX,
+		.flags		= (RPC_CLNT_CREATE_ONESHOT |
+				   RPC_CLNT_CREATE_NOPING),
+	};
+
+	((struct sockaddr_in *)srvaddr)->sin_port = htons(RPCBIND_PORT);
+	if (!privileged)
+		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
+	return rpc_create(&args);
+}
+
+/**
+ * rpcb_register - set or unset a port registration with the local rpcbind svc
+ * @prog: RPC program number to bind
+ * @vers: RPC version number to bind
+ * @prot: transport protocol to use to make this request
+ * @port: port value to register
+ * @okay: result code
+ *
+ * port == 0 means unregister, port != 0 means register.
+ *
+ * This routine supports only rpcbind version 2.
+ */
+int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
+{
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
+	};
+	struct rpcbind_args map = {
+		.r_prog		= prog,
+		.r_vers		= vers,
+		.r_prot		= prot,
+		.r_port		= port,
+	};
+	struct rpc_message msg = {
+		.rpc_proc	= &rpcb_procedures2[port ?
+					RPCBPROC_SET : RPCBPROC_UNSET],
+		.rpc_argp	= &map,
+		.rpc_resp	= okay,
+	};
+	struct rpc_clnt *rpcb_clnt;
+	int error = 0;
+
+	dprintk("RPC:       %sregistering (%u, %u, %d, %u) with local "
+			"rpcbind\n", (port ? "" : "un"),
+			prog, vers, prot, port);
+
+	rpcb_clnt = rpcb_create("localhost", (struct sockaddr *) &sin,
+					IPPROTO_UDP, 2, 1);
+	if (IS_ERR(rpcb_clnt))
+		return PTR_ERR(rpcb_clnt);
+
+	error = rpc_call_sync(rpcb_clnt, &msg, 0);
+
+	if (error < 0)
+		printk(KERN_WARNING "RPC: failed to contact local rpcbind "
+				"server (errno %d).\n", -error);
+	dprintk("RPC:       registration status %d/%d\n", error, *okay);
+
+	return error;
+}
+
+#ifdef CONFIG_ROOT_NFS
+/**
+ * rpcb_getport_external - obtain the port for an RPC service on a given host
+ * @sin: address of remote peer
+ * @prog: RPC program number to bind
+ * @vers: RPC version number to bind
+ * @prot: transport protocol to use to make this request
+ *
+ * Called from outside the RPC client in a synchronous task context.
+ *
+ * For now, this supports only version 2 queries, but is used only by
+ * mount_clnt for NFS_ROOT.
+ */
+int rpcb_getport_external(struct sockaddr_in *sin, __u32 prog,
+				__u32 vers, int prot)
+{
+	struct rpcbind_args map = {
+		.r_prog		= prog,
+		.r_vers		= vers,
+		.r_prot		= prot,
+		.r_port		= 0,
+	};
+	struct rpc_message msg = {
+		.rpc_proc	= &rpcb_procedures2[RPCBPROC_GETPORT],
+		.rpc_argp	= &map,
+		.rpc_resp	= &map.r_port,
+	};
+	struct rpc_clnt	*rpcb_clnt;
+	char hostname[40];
+	int status;
+
+	dprintk("RPC:       rpcb_getport_external(%u.%u.%u.%u, %u, %u, %d)\n",
+			NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
+
+	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(sin->sin_addr.s_addr));
+	rpcb_clnt = rpcb_create(hostname, (struct sockaddr *)sin, prot, 2, 0);
+	if (IS_ERR(rpcb_clnt))
+		return PTR_ERR(rpcb_clnt);
+
+	status = rpc_call_sync(rpcb_clnt, &msg, 0);
+
+	if (status >= 0) {
+		if (map.r_port != 0)
+			return map.r_port;
+		status = -EACCES;
+	}
+	return status;
+}
+#endif
+
+/**
+ * rpcb_getport - obtain the port for a given RPC service on a given host
+ * @task: task that is waiting for portmapper request
+ *
+ * This one can be called for an ongoing RPC request, and can be used in
+ * an async (rpciod) context.
+ */
+void rpcb_getport(struct rpc_task *task)
+{
+	struct rpc_clnt *clnt = task->tk_client;
+	int bind_version;
+	struct rpc_xprt *xprt = task->tk_xprt;
+	struct rpc_clnt	*rpcb_clnt;
+	static struct rpcbind_args *map;
+	struct rpc_task	*child;
+	struct sockaddr addr;
+	int status;
+
+	dprintk("RPC: %5u rpcb_getport(%s, %u, %u, %d)\n",
+			task->tk_pid, clnt->cl_server,
+			clnt->cl_prog, clnt->cl_vers, xprt->prot);
+
+	/* Autobind on cloned rpc clients is discouraged */
+	BUG_ON(clnt->cl_parent != clnt);
+
+	if (xprt_test_and_set_binding(xprt)) {
+		status = -EACCES;		/* tell caller to check again */
+		dprintk("RPC: %5u rpcb_getport waiting for another binder\n",
+				task->tk_pid);
+		goto bailout_nowake;
+	}
+
+	/* Put self on queue before sending rpcbind request, in case
+	 * rpcb_getport_done completes before we return from rpc_run_task */
+	rpc_sleep_on(&xprt->binding, task, NULL, NULL);
+
+	/* Someone else may have bound if we slept */
+	if (xprt_bound(xprt)) {
+		status = 0;
+		dprintk("RPC: %5u rpcb_getport already bound\n", task->tk_pid);
+		goto bailout_nofree;
+	}
+
+	if (rpcb_next_version[xprt->bind_index].rpc_proc == NULL) {
+		xprt->bind_index = 0;
+		status = -EACCES;	/* tell caller to try again later */
+		dprintk("RPC: %5u rpcb_getport no more getport versions "
+				"available\n", task->tk_pid);
+		goto bailout_nofree;
+	}
+	bind_version = rpcb_next_version[xprt->bind_index].rpc_vers;
+
+	dprintk("RPC: %5u rpcb_getport trying rpcbind version %u\n",
+			task->tk_pid, bind_version);
+
+	map = kzalloc(sizeof(struct rpcbind_args), GFP_ATOMIC);
+	if (!map) {
+		status = -ENOMEM;
+		dprintk("RPC: %5u rpcb_getport no memory available\n",
+				task->tk_pid);
+		goto bailout_nofree;
+	}
+	map->r_prog = clnt->cl_prog;
+	map->r_vers = clnt->cl_vers;
+	map->r_prot = xprt->prot;
+	map->r_port = 0;
+	map->r_xprt = xprt_get(xprt);
+	map->r_netid = (xprt->prot == IPPROTO_TCP) ? RPCB_NETID_TCP :
+						   RPCB_NETID_UDP;
+	memcpy(&map->r_addr, rpc_peeraddr2str(clnt, RPC_DISPLAY_ADDR),
+			sizeof(map->r_addr));
+	map->r_owner = RPCB_OWNER_STRING;	/* ignored for GETADDR */
+
+	rpc_peeraddr(clnt, (void *)&addr, sizeof(addr));
+	rpcb_clnt = rpcb_create(clnt->cl_server, &addr, xprt->prot, bind_version, 0);
+	if (IS_ERR(rpcb_clnt)) {
+		status = PTR_ERR(rpcb_clnt);
+		dprintk("RPC: %5u rpcb_getport rpcb_create failed, error %ld\n",
+				task->tk_pid, PTR_ERR(rpcb_clnt));
+		goto bailout;
+	}
+
+	child = rpc_run_task(rpcb_clnt, RPC_TASK_ASYNC, &rpcb_getport_ops, map);
+	if (IS_ERR(child)) {
+		status = -EIO;
+		dprintk("RPC: %5u rpcb_getport rpc_run_task failed\n",
+				task->tk_pid);
+		goto bailout_nofree;
+	}
+	rpc_put_task(child);
+
+	task->tk_xprt->stat.bind_count++;
+	return;
+
+bailout:
+	kfree(map);
+	xprt_put(xprt);
+bailout_nofree:
+	rpcb_wake_rpcbind_waiters(xprt, status);
+bailout_nowake:
+	task->tk_status = status;
+}
+
+/*
+ * Rpcbind child task calls this callback via tk_exit.
+ */
+static void rpcb_getport_done(struct rpc_task *child, void *data)
+{
+	struct rpcbind_args *map = data;
+	struct rpc_xprt *xprt = map->r_xprt;
+	int status = child->tk_status;
+
+	/* rpcbind server doesn't support this rpcbind protocol version */
+	if (status == -EPROTONOSUPPORT)
+		xprt->bind_index++;
+
+	if (status < 0) {
+		/* rpcbind server not available on remote host? */
+		xprt->ops->set_port(xprt, 0);
+	} else if (map->r_port == 0) {
+		/* Requested RPC service wasn't registered on remote host */
+		xprt->ops->set_port(xprt, 0);
+		status = -EACCES;
+	} else {
+		/* Succeeded */
+		xprt->ops->set_port(xprt, map->r_port);
+		xprt_set_bound(xprt);
+		status = 0;
+	}
+
+	dprintk("RPC: %5u rpcb_getport_done(status %d, port %u)\n",
+			child->tk_pid, status, map->r_port);
+
+	rpcb_wake_rpcbind_waiters(xprt, status);
+}
+
+static int rpcb_encode_mapping(struct rpc_rqst *req, __be32 *p,
+			       struct rpcbind_args *rpcb)
+{
+	dprintk("RPC:       rpcb_encode_mapping(%u, %u, %d, %u)\n",
+			rpcb->r_prog, rpcb->r_vers, rpcb->r_prot, rpcb->r_port);
+	*p++ = htonl(rpcb->r_prog);
+	*p++ = htonl(rpcb->r_vers);
+	*p++ = htonl(rpcb->r_prot);
+	*p++ = htonl(rpcb->r_port);
+
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	return 0;
+}
+
+static int rpcb_decode_getport(struct rpc_rqst *req, __be32 *p,
+			       unsigned short *portp)
+{
+	*portp = (unsigned short) ntohl(*p++);
+	dprintk("RPC:      rpcb_decode_getport result %u\n",
+			*portp);
+	return 0;
+}
+
+static int rpcb_decode_set(struct rpc_rqst *req, __be32 *p,
+			   unsigned int *boolp)
+{
+	*boolp = (unsigned int) ntohl(*p++);
+	dprintk("RPC:      rpcb_decode_set result %u\n",
+			*boolp);
+	return 0;
+}
+
+static int rpcb_encode_getaddr(struct rpc_rqst *req, __be32 *p,
+			       struct rpcbind_args *rpcb)
+{
+	dprintk("RPC:       rpcb_encode_getaddr(%u, %u, %s)\n",
+			rpcb->r_prog, rpcb->r_vers, rpcb->r_addr);
+	*p++ = htonl(rpcb->r_prog);
+	*p++ = htonl(rpcb->r_vers);
+
+	p = xdr_encode_string(p, rpcb->r_netid);
+	p = xdr_encode_string(p, rpcb->r_addr);
+	p = xdr_encode_string(p, rpcb->r_owner);
+
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+
+	return 0;
+}
+
+static int rpcb_decode_getaddr(struct rpc_rqst *req, __be32 *p,
+			       unsigned short *portp)
+{
+	char *addr;
+	int addr_len, c, i, f, first, val;
+
+	*portp = 0;
+	addr_len = (unsigned int) ntohl(*p++);
+	if (addr_len > RPCB_MAXADDRLEN)			/* sanity */
+		return -EINVAL;
+
+	dprintk("RPC:       rpcb_decode_getaddr returned string: '%s'\n",
+			(char *) p);
+
+	addr = (char *)p;
+	val = 0;
+	first = 1;
+	f = 1;
+	for (i = addr_len - 1; i > 0; i--) {
+		c = addr[i];
+		if (c >= '0' && c <= '9') {
+			val += (c - '0') * f;
+			f *= 10;
+		} else if (c == '.') {
+			if (first) {
+				*portp = val;
+				val = first = 0;
+				f = 1;
+			} else {
+				*portp |= (val << 8);
+				break;
+			}
+		}
+	}
+
+	dprintk("RPC:       rpcb_decode_getaddr port=%u\n", *portp);
+	return 0;
+}
+
+#define RPCB_program_sz		(1u)
+#define RPCB_version_sz		(1u)
+#define RPCB_protocol_sz	(1u)
+#define RPCB_port_sz		(1u)
+#define RPCB_boolean_sz		(1u)
+
+#define RPCB_netid_sz		(1+XDR_QUADLEN(RPCB_MAXNETIDLEN))
+#define RPCB_addr_sz		(1+XDR_QUADLEN(RPCB_MAXADDRLEN))
+#define RPCB_ownerstring_sz	(1+XDR_QUADLEN(RPCB_MAXOWNERLEN))
+
+#define RPCB_mappingargs_sz	RPCB_program_sz+RPCB_version_sz+	\
+				RPCB_protocol_sz+RPCB_port_sz
+#define RPCB_getaddrargs_sz	RPCB_program_sz+RPCB_version_sz+	\
+				RPCB_netid_sz+RPCB_addr_sz+		\
+				RPCB_ownerstring_sz
+
+#define RPCB_setres_sz		RPCB_boolean_sz
+#define RPCB_getportres_sz	RPCB_port_sz
+
+/*
+ * Note that RFC 1833 does not put any size restrictions on the
+ * address string returned by the remote rpcbind database.
+ */
+#define RPCB_getaddrres_sz	RPCB_addr_sz
+
+#define PROC(proc, argtype, restype)					\
+	[RPCBPROC_##proc] = {						\
+		.p_proc		= RPCBPROC_##proc,			\
+		.p_encode	= (kxdrproc_t) rpcb_encode_##argtype,	\
+		.p_decode	= (kxdrproc_t) rpcb_decode_##restype,	\
+		.p_arglen	= RPCB_##argtype##args_sz,		\
+		.p_replen	= RPCB_##restype##res_sz,		\
+		.p_statidx	= RPCBPROC_##proc,			\
+		.p_timer	= 0,					\
+		.p_name		= #proc,				\
+	}
+
+/*
+ * Not all rpcbind procedures described in RFC 1833 are implemented
+ * since the Linux kernel RPC code requires only these.
+ */
+static struct rpc_procinfo rpcb_procedures2[] = {
+	PROC(SET,		mapping,	set),
+	PROC(UNSET,		mapping,	set),
+	PROC(GETADDR,		mapping,	getport),
+};
+
+static struct rpc_procinfo rpcb_procedures3[] = {
+	PROC(SET,		mapping,	set),
+	PROC(UNSET,		mapping,	set),
+	PROC(GETADDR,		getaddr,	getaddr),
+};
+
+static struct rpc_procinfo rpcb_procedures4[] = {
+	PROC(SET,		mapping,	set),
+	PROC(UNSET,		mapping,	set),
+	PROC(GETVERSADDR,	getaddr,	getaddr),
+};
+
+static struct rpcb_info rpcb_next_version[] = {
+#ifdef CONFIG_SUNRPC_BIND34
+	{ 4, &rpcb_procedures4[RPCBPROC_GETVERSADDR] },
+	{ 3, &rpcb_procedures3[RPCBPROC_GETADDR] },
+#endif
+	{ 2, &rpcb_procedures2[RPCBPROC_GETPORT] },
+	{ 0, NULL },
+};
+
+static struct rpc_version rpcb_version2 = {
+	.number		= 2,
+	.nrprocs	= RPCB_HIGHPROC_2,
+	.procs		= rpcb_procedures2
+};
+
+static struct rpc_version rpcb_version3 = {
+	.number		= 3,
+	.nrprocs	= RPCB_HIGHPROC_3,
+	.procs		= rpcb_procedures3
+};
+
+static struct rpc_version rpcb_version4 = {
+	.number		= 4,
+	.nrprocs	= RPCB_HIGHPROC_4,
+	.procs		= rpcb_procedures4
+};
+
+static struct rpc_version *rpcb_version[] = {
+	NULL,
+	NULL,
+	&rpcb_version2,
+	&rpcb_version3,
+	&rpcb_version4
+};
+
+static struct rpc_stat rpcb_stats;
+
+struct rpc_program rpcb_program = {
+	.name		= "rpcbind",
+	.number		= RPCBIND_PROGRAM,
+	.nrvers		= ARRAY_SIZE(rpcb_version),
+	.version	= rpcb_version,
+	.stats		= &rpcb_stats,
+};
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 6d87320..4a53e94 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -741,50 +741,53 @@ static void rpc_async_schedule(struct work_struct *work)
  * @task: RPC task that will use this buffer
  * @size: requested byte size
  *
- * We try to ensure that some NFS reads and writes can always proceed
- * by using a mempool when allocating 'small' buffers.
+ * To prevent rpciod from hanging, this allocator never sleeps,
+ * returning NULL if the request cannot be serviced immediately.
+ * The caller can arrange to sleep in a way that is safe for rpciod.
+ *
+ * Most requests are 'small' (under 2KiB) and can be serviced from a
+ * mempool, ensuring that NFS reads and writes can always proceed,
+ * and that there is good locality of reference for these buffers.
+ *
  * In order to avoid memory starvation triggering more writebacks of
- * NFS requests, we use GFP_NOFS rather than GFP_KERNEL.
+ * NFS requests, we avoid using GFP_KERNEL.
  */
-void * rpc_malloc(struct rpc_task *task, size_t size)
+void *rpc_malloc(struct rpc_task *task, size_t size)
 {
-	struct rpc_rqst *req = task->tk_rqstp;
-	gfp_t	gfp;
+	size_t *buf;
+	gfp_t gfp = RPC_IS_SWAPPER(task) ? GFP_ATOMIC : GFP_NOWAIT;
 
-	if (task->tk_flags & RPC_TASK_SWAPPER)
-		gfp = GFP_ATOMIC;
+	size += sizeof(size_t);
+	if (size <= RPC_BUFFER_MAXSIZE)
+		buf = mempool_alloc(rpc_buffer_mempool, gfp);
 	else
-		gfp = GFP_NOFS;
-
-	if (size > RPC_BUFFER_MAXSIZE) {
-		req->rq_buffer = kmalloc(size, gfp);
-		if (req->rq_buffer)
-			req->rq_bufsize = size;
-	} else {
-		req->rq_buffer = mempool_alloc(rpc_buffer_mempool, gfp);
-		if (req->rq_buffer)
-			req->rq_bufsize = RPC_BUFFER_MAXSIZE;
-	}
-	return req->rq_buffer;
+		buf = kmalloc(size, gfp);
+	*buf = size;
+	dprintk("RPC: %5u allocated buffer of size %u at %p\n",
+			task->tk_pid, size, buf);
+	return (void *) ++buf;
 }
 
 /**
  * rpc_free - free buffer allocated via rpc_malloc
- * @task: RPC task with a buffer to be freed
+ * @buffer: buffer to free
  *
  */
-void rpc_free(struct rpc_task *task)
+void rpc_free(void *buffer)
 {
-	struct rpc_rqst *req = task->tk_rqstp;
+	size_t size, *buf = (size_t *) buffer;
 
-	if (req->rq_buffer) {
-		if (req->rq_bufsize == RPC_BUFFER_MAXSIZE)
-			mempool_free(req->rq_buffer, rpc_buffer_mempool);
-		else
-			kfree(req->rq_buffer);
-		req->rq_buffer = NULL;
-		req->rq_bufsize = 0;
-	}
+	if (!buffer)
+		return;
+	size = *buf;
+	buf--;
+
+	dprintk("RPC:       freeing buffer of size %u at %p\n",
+			size, buf);
+	if (size <= RPC_BUFFER_MAXSIZE)
+		mempool_free(buf, rpc_buffer_mempool);
+	else
+		kfree(buf);
 }
 
 /*
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index b4db53f..b7503c1 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -757,7 +757,7 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
 			if (progp->pg_vers[i]->vs_hidden)
 				continue;
 
-			error = rpc_register(progp->pg_prog, i, proto, port, &dummy);
+			error = rpcb_register(progp->pg_prog, i, proto, port, &dummy);
 			if (error < 0)
 				break;
 			if (port && !dummy) {
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 456a145..5b05b73 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -823,7 +823,6 @@ static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
 	req->rq_task	= task;
 	req->rq_xprt    = xprt;
 	req->rq_buffer  = NULL;
-	req->rq_bufsize = 0;
 	req->rq_xid     = xprt_alloc_xid(xprt);
 	req->rq_release_snd_buf = NULL;
 	xprt_reset_majortimeo(req);
@@ -855,7 +854,7 @@ void xprt_release(struct rpc_task *task)
 		mod_timer(&xprt->timer,
 				xprt->last_used + xprt->idle_timeout);
 	spin_unlock_bh(&xprt->transport_lock);
-	xprt->ops->buf_free(task);
+	xprt->ops->buf_free(req->rq_buffer);
 	task->tk_rqstp = NULL;
 	if (req->rq_release_snd_buf)
 		req->rq_release_snd_buf(req);
@@ -928,6 +927,7 @@ struct rpc_xprt *xprt_create_transport(int proto, struct sockaddr *ap, size_t si
 	xprt->timer.data = (unsigned long) xprt;
 	xprt->last_used = jiffies;
 	xprt->cwnd = RPC_INITCWND;
+	xprt->bind_index = 0;
 
 	rpc_init_wait_queue(&xprt->binding, "xprt_binding");
 	rpc_init_wait_queue(&xprt->pending, "xprt_pending");
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index a5a3202..cc33c58 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1476,7 +1476,7 @@ static struct rpc_xprt_ops xs_udp_ops = {
 	.set_buffer_size	= xs_udp_set_buffer_size,
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong,
-	.rpcbind		= rpc_getport,
+	.rpcbind		= rpcb_getport,
 	.set_port		= xs_set_port,
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,
@@ -1493,7 +1493,7 @@ static struct rpc_xprt_ops xs_udp_ops = {
 static struct rpc_xprt_ops xs_tcp_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xs_tcp_release_xprt,
-	.rpcbind		= rpc_getport,
+	.rpcbind		= rpcb_getport,
 	.set_port		= xs_set_port,
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
