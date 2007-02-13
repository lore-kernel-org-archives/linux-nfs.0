From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] NFS client updates for 2.6.20
Date: Mon, 12 Feb 2007 23:39:54 -0800
Message-ID: <1171352394.6177.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGsGr-0000po-Me
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 23:40:13 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HGsGp-0006yH-6m
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 23:40:12 -0800
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
 fs/lockd/clntproc.c                    |    9 +-
 fs/lockd/svclock.c                     |    4 -
 fs/nfs/client.c                        |   18 +++-
 fs/nfs/dir.c                           |   37 +++++++-
 fs/nfs/direct.c                        |    8 +-
 fs/nfs/getroot.c                       |   11 +-
 fs/nfs/inode.c                         |   50 +++++++----
 fs/nfs/internal.h                      |    4 -
 fs/nfs/nfs3proc.c                      |   24 -----
 fs/nfs/nfs4_fs.h                       |    2 
 fs/nfs/nfs4namespace.c                 |   16 ++--
 fs/nfs/nfs4proc.c                      |   60 ++-----------
 fs/nfs/nfs4xdr.c                       |    2 
 fs/nfs/proc.c                          |   30 -------
 fs/nfs/read.c                          |  109 +-----------------------
 fs/nfs/super.c                         |    2 
 fs/nfs/write.c                         |   91 ++++----------------
 include/linux/nfs_fs.h                 |   17 ++--
 include/linux/nfs_xdr.h                |    1 
 include/linux/sunrpc/clnt.h            |    2 
 include/linux/sunrpc/sched.h           |    2 
 net/sunrpc/auth.c                      |   25 +++---
 net/sunrpc/auth_gss/auth_gss.c         |   52 ++++++-----
 net/sunrpc/auth_gss/gss_krb5_crypto.c  |   10 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c    |    3 -
 net/sunrpc/auth_gss/gss_krb5_seal.c    |    2 
 net/sunrpc/auth_gss/gss_krb5_seqnum.c  |    2 
 net/sunrpc/auth_gss/gss_krb5_unseal.c  |    2 
 net/sunrpc/auth_gss/gss_krb5_wrap.c    |    4 -
 net/sunrpc/auth_gss/gss_mech_switch.c  |    6 +
 net/sunrpc/auth_gss/gss_spkm3_mech.c   |    9 +-
 net/sunrpc/auth_gss/gss_spkm3_seal.c   |   14 ++-
 net/sunrpc/auth_gss/gss_spkm3_token.c  |   14 ++-
 net/sunrpc/auth_gss/gss_spkm3_unseal.c |    9 +-
 net/sunrpc/auth_gss/svcauth_gss.c      |   11 +-
 net/sunrpc/auth_unix.c                 |    9 +-
 net/sunrpc/cache.c                     |    3 -
 net/sunrpc/clnt.c                      |  145 +++++++++++++++++---------------
 net/sunrpc/pmap_clnt.c                 |   26 +++---
 net/sunrpc/rpc_pipe.c                  |    2 
 net/sunrpc/sched.c                     |   78 +++++++++--------
 net/sunrpc/stats.c                     |    6 +
 net/sunrpc/svc.c                       |    6 +
 net/sunrpc/xprt.c                      |   67 +++++++++------
 net/sunrpc/xprtsock.c                  |  107 +++++++++++++-----------
 45 files changed, 476 insertions(+), 635 deletions(-)

commit 43d78ef2ba5bec26d0315859e8324bfc0be23766
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Feb 6 18:26:11 2007 -0500

    NFS: disconnect before retrying NFSv4 requests over TCP
    
    RFC3530 section 3.1.1 states an NFSv4 client MUST NOT send a request
    twice on the same connection unless it is the NULL procedure.  Section
    3.1.1 suggests that the client should disconnect and reconnect if it
    wants to retry a request.
    
    Implement this by adding an rpc_clnt flag that an ULP can use to
    specify that the underlying transport should be disconnected on a
    major timeout.  The NFSv4 client asserts this new flag, and requests
    no retries after a minor retransmit timeout.
    
    Note that disconnecting on a retransmit is in general not safe to do
    if the RPC client does not reuse the TCP port number when reconnecting.
    
    See http://bugzilla.linux-nfs.org/show_bug.cgi?id=6
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a301b777714087ea1d63dbec0173a13d416cd7a9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Feb 6 11:07:15 2007 -0800

    NFS: Don't use ClearPageUptodate() when writeback fails
    
    ClearPageUptodate() will just cause races here. What we really want to do
    is to invalidate the page cache.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b0c4fddca2bc3967381b728732a8850de35e1b20
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Feb 5 14:44:22 2007 -0800

    NFS: Cleanup - avoid rereading 'jiffies' more than once in the same routine
    
    Micro-optimisations for nfs_fhget() and nfs_wcc_update_inode().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3e7d950a528454ad749a264feef3c8bad3faa108
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Feb 5 14:26:28 2007 -0800

    NFS: Fix a wraparound issue with nfsi->cache_change_attribute
    
    Fix wraparound issue with nfsi->cache_change_attribute. If it is found
    to lie in the future, then update it to lie in the past. Patch based on
    a suggestion by Neil Brown.
    
    ..and minor micro-optimisation: avoid reading 'jiffies' more than once in
    nfs_update_inode().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 588a700b269b785b19d5d03084bee5e1b74c7758
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 2 17:41:53 2007 -0800

    NFSv4: /proc/mounts displays the wrong server name for referrals
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1d21632d366b33b3adf4fa26144edf3162a9715d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 2 15:56:06 2007 -0800

    NFSv4: Ensure non-root user can trigger a referral automount
    
    Currently only root can trigger a referral automount because only root
    can access rpc_pipefs directories. Enabling read access to non-root
    should be harmless (they can still not access the pipes themselves)
    and will suffice to fix this problem.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 46121cf7d85869bfe9588bac7ccf55aa0bc7f278
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jan 31 12:14:08 2007 -0500

    SUNRPC: fix print format for tk_pid
    
    The tk_pid field is an unsigned short.  The proper print format specifier for
    that type is %5u, not %4d.
    
    Also clean up some miscellaneous print formatting nits.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8885cb367f86ce02bed3bf18192d74a53ac3b81f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jan 31 12:14:05 2007 -0500

    SUNRPC: fix print format for tk_pid in auth_gss support
    
    The tk_pid field is an unsigned short.  The proper print format specifier for
    that type is %5u, not %4d.
    
    Also clean up some miscellaneous print formatting nits.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a3f565b1e530a756472401835107d08fd291f242
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jan 31 12:14:01 2007 -0500

    NFS: fix print format for tk_pid
    
    The tk_pid field is an unsigned short.  The proper print format specifier for
    that type is %5u, not %4d.
    
    Also clean up some miscellaneous print formatting nits.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4dc2eaecd4cf0687727e418540bccf956a62ebcf
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Dec 20 22:29:46 2006 +0200

    NFS: move NFS_DEBUG definition
    
    Trond, looks like the changes to include/linux/nfs_fs.h in 2.6.18
    that moved the #include's of sunrpc header files into the #ifdef __KERNEL__ block
    disabled nfs debugging for all nfs c file not including any sunrpc header.
    
    The following patch moves the definition down, right before its use
    for defining ifdebug.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    (Moved definition further down into the __KERNEL__ section: Trond)
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e148582e10a2c1a23dfc09210df4a18bc6cca4e9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Dec 13 16:43:13 2006 -0500

    NFSv4: Add lockdep checks to nfs4_wait_clnt_recover()
    
    Attempt to detect deadlocks due to caller holding locks on clp->cl_sem
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a6a352e93dfa78db8903f0e3610abb76efbf7fc9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Dec 13 16:43:06 2006 -0500

    NFSv4: Don't start state recovery in nfs4_close_done()
    
    We might not even have any open files at this point...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7c85d9007d05436e71d2b805b96c1e36a8193bd4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Dec 13 15:23:48 2006 -0500

    NFS: Fixup some outdated comments...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d30c8348a4ba292a09addd122de2f3189c21a7ff
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Dec 13 15:23:47 2006 -0500

    NFS: nfs_writepages() cleanup
    
    Strip out the call to nfs_commit_inode(), and allow that to be done by
    nfs_write_inode().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f40313ac39fedca519c36fdc454acf2632e641da
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jan 13 02:28:08 2007 -0500

    NFS: Micro-optimisation for nfs_wb_page()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 02241bc47e8961768de83d855accd0dcad1df045
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jan 13 02:28:07 2007 -0500

    NFS: Ensure that ->writepage() uses flush_stable() when reclaiming pages
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8e0969f0451eaf7cf32f2ec3946196d8d0b1cb2c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Dec 13 15:23:44 2006 -0500

    NFS: Remove nfs_readpage_sync()
    
    It makes no sense to maintain 2 parallel systems for reading in pages.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c228fd3aeef55637354167faead74c579d5da28b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jan 13 02:28:11 2007 -0500

    NFSv4: Cleanups for fs_locations code.
    
    Start long arduous project...  What the hell is
    
    	struct dentry = {};
    
    all about?
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit faebf4e2bb0efad9dda396ea13d5c6ad15d7d7fb
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jan 13 02:28:11 2007 -0500

    NFSv4: Don't require that NFSv4 mount paths begin with '/'
    
    Addresses the regression noted in
      http://bugzilla.linux-nfs.org/show_bug.cgi?id=134
    
    Also mark a couple of other regressions as requiring fixing.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c79ba787c11e767ffaf8d723923afda99ba6c63c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jan 31 08:16:24 2007 -0500

    NFS: Dont clobber more uptodate values in nfs_set_verifier()
    
    nfs_lookup_revalidate and friends are not serialised, so it is currently
    quite possible for the dentry to be revalidated, and then have the
    updated verifier replaced with an older value by another process.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ef75c7974b383769ae5741cf930b8aa4dcaef395
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 16 10:09:44 2007 -0500

    NFS: Also use readdir info to revalidate positive dentries
    
    If the fileid of the cached dentry fails to match that returned by
    the readdir call, then we should also d_drop. Try to take into account the
    fact that on NFSv4, readdir may return the "mounted_on_fileid" by looking
    for submounts.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit df1d5d23d3a1a713c69b0f9ec67c59aeca3ce6b3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Jan 15 13:56:29 2007 -0500

    NFS: Fix a readdir/lookup inefficiency.
    
    Make sure that nfs_readdir_lookup() handles negative dentries correctly.
    If d_lookup() returns a negative dentry, then we need to d_drop() that
    since readdir shows that it should be positive.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ccfeb506231348a3c60ab0fdb5753a574653e3c0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jan 13 02:28:12 2007 -0500

    NFS: Fix up "rm -rf"...
    
    When a file is being scheduled for deletion by means of the sillyrename
    mechanism, it makes sense to start out writeback of the dirty data as
    soon as possible in order to ensure that the delete can occur. Examples of
    cases where this is an issue include "rm -rf", which will busy-wait until
    the file is closed, and the sillyrename completes.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ab91f264cfbafd079dcb1bd02e9803c2dd65de19
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 2 14:47:17 2007 -0800

    NFSv4: Fix NFS4_enc_server_caps_sz/NFS4_dec_server_caps_sz
    
    Insert missing encode_putfh_maxsz/decode_putfh_maxsz
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f2d0d85e58099d518cb50b1c95fc1fc62bbce1b8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 2 14:46:09 2007 -0800

    NFSv4: Fix Oops in nfs4_create_referral_server
    
    The filehandle that is passed into nfs4_create_referral_server is
    not initialised. The expectation is that nfs4_create_referral_server will
    initialise it, and return it to the caller.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2efef837fb84f78cee7439804cb3722bffc64e75
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Feb 3 13:38:41 2007 -0800

    RPC: Clean up rpc_execute...
    
    The error values are already propagated through task->tk_status, and
    none of the callers check one without checking the other, so we can
    drop the return value.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 54cc533aaa0dc331ad126f0aacfb19572adee638
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Feb 3 13:38:40 2007 -0800

    RPC: Fix double free in portmapper code
    
    rpc_run_task is guaranteed to always call ->rpc_release.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a995e9eb3258df6ab2e9f958e08003978e50d568
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 2 15:37:43 2007 -0800

    NLM: Fix double free in __nlm_async_call
    
    rpc_call_async() will always call rpc_release_calldata(), so it is an
    error for __nlm_async_call() to do so as well.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
