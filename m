Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11910 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020Ab1AaXU6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Jan 2011 18:20:58 -0500
Subject: [GIT PULL] please pull NFS client bugfixes for 2.6.38-rc2
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 31 Jan 2011 18:20:40 -0500
Message-ID: <1296516040.12877.15.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/lockd/host.c                 |    9 ++--
 fs/nfs/callback.c               |  109 ++++++++++----------------------------
 fs/nfs/callback.h               |    4 +-
 fs/nfs/callback_proc.c          |   12 +---
 fs/nfs/callback_xdr.c           |    5 +-
 fs/nfs/client.c                 |   15 ++----
 fs/nfs/delegation.c             |    6 ++-
 fs/nfs/direct.c                 |   34 +++++++-----
 fs/nfs/inode.c                  |   26 ++++++---
 fs/nfs/internal.h               |    3 +-
 fs/nfs/nfs3acl.c                |    4 +-
 fs/nfs/nfs3xdr.c                |    5 ++-
 fs/nfs/nfs4filelayoutdev.c      |    9 +++-
 fs/nfs/nfs4proc.c               |   30 ++++-------
 fs/nfs/nfs4state.c              |    6 --
 fs/nfs/nfs4xdr.c                |    9 +--
 fs/nfs/pnfs.c                   |    2 +-
 fs/nfs/write.c                  |    2 +-
 fs/nfs_common/nfsacl.c          |   54 +++++++++++++++-----
 fs/posix_acl.c                  |   17 +++++--
 include/linux/nfsacl.h          |    4 +-
 include/linux/posix_acl.h       |    1 +
 include/linux/sunrpc/bc_xprt.h  |   13 -----
 include/linux/sunrpc/svc_xprt.h |    1 -
 net/sunrpc/svcsock.c            |    4 +-
 25 files changed, 174 insertions(+), 210 deletions(-)

commit d1205f87bbb8040c1408bbd9e0a720310b2b0b9b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jan 28 12:41:05 2011 -0500

    NFS: NFSv4 readdir loses entries
    
    On recent 2.6.38-rc kernels, connectathon basic test 6 fails on
    NFSv4 mounts of OpenSolaris with something like:
    
    > ./test6: readdir
    > 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.12' dir entry, pass 0
    > 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.82' dir entry, pass 0
    > 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.164' dir entry, pass 0
    > 	./test6: (/mnt/klimt/matisse.test) Test failed with 3 errors
    > basic tests failed
    > Tests failed, leaving /mnt/klimt mounted
    > [cel@matisse cthon04]$
    
    I narrowed the problem down to nfs4_decode_dirent() reporting that the
    decode buffer had overflowed while decoding the entries for those
    missing files.
    
    verify_attr_len() assumes both it's pointer arguments reside on the
    same page.  When these arguments point to locations on two different
    pages, verify_attr_len() can report false errors.  This can happen now
    that a large NFSv4 readdir result can span pages.
    
    We have reasonably good checking in nfs4_decode_dirent() anyway, so
    it should be safe to simply remove the extra checking.
    
    At a guess, this was introduced by commit 6650239a, "NFS: Don't use
    vm_map_ram() in readdir".
    
    Cc: stable@kernel.org [2.6.37]
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c08e76d0cd4beb759a73c1835d98f5fccc126ed1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jan 28 12:40:55 2011 -0500

    NFS: Micro-optimize nfs4_decode_dirent()
    
    Make the decoding of NFSv4 directory entries slightly more efficient
    by:
    
      1.  Avoiding unnecessary byte swapping when checking XDR booleans,
          and
    
      2.  Not bumping "p" when its value will be immediately replaced by
          xdr_inline_decode()
    
    This commit makes nfs4_decode_dirent() consistent with similar logic
    in the other two decode_dirent() functions.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e00b8a24041f37e56b4b8415ce4eba1cbc238065
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jan 27 14:55:39 2011 -0500

    NFS: Fix an NFS client lockdep issue
    
    There is no reason to be freeing the delegation cred in the rcu callback,
    and doing so is resulting in a lockdep complaint that rpc_credcache_lock
    is being called from both softirq and non-softirq contexts.
    
    Reported-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit c7a360b05b5430ac1d75dc7d53c586ada60a05cb
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Jan 25 19:15:32 2011 -0500

    NFS construct consistent co_ownerid for v4.1
    
    As stated in section 2.4 of RFC 5661, subsequent instances of the client need
    to present the same co_ownerid. Concatinate the client's IP dot address,
    host name, and the rpc_auth pseudoflavor to form the co_ownerid.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 27dc1cd3ad9300f81e1219e5fc305d91d85353f8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 25 15:28:21 2011 -0500

    NFS: nfs_wcc_update_inode() should set nfsi->attr_gencount
    
    If the call to nfs_wcc_update_inode() results in an attribute update, we
    need to ensure that the inode's attr_gencount gets bumped too, otherwise
    we are not protected against races with other GETATTR calls.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b2a2897dc4a59684321de425652061c62a0569d0
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Jan 25 15:38:03 2011 +0000

    NFS improve pnfs_put_deviceid_cache debug print
    
    What we really want to know is the ref count.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2c4cdf8f6d3cfb48036400952329555099c8c92c
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Jan 25 15:38:02 2011 +0000

    NFS fix cb_sequence error processing
    
    Always assign the cb_process_state nfs_client pointer so a processing error
    in cb_sequence after the nfs_client is found and referenced returns
    a non-NULL cb_process_state nfs_client and the matching nfs_put_client in
    nfs4_callback_compound dereferences the client.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 778be232a207e79088ba70d832ac25dfea6fbf1a
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Jan 25 15:38:01 2011 +0000

    NFS do not find client in NFSv4 pg_authenticate
    
    The information required to find the nfs_client cooresponding to the incoming
    back channel request is contained in the NFS layer. Perform minimal checking
    in the RPC layer pg_authenticate method, and push more detailed checking into
    the NFS layer where the nfs_client can be found.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 80c30e8de4f81851b1f712bcc596e11d53bc76f1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jan 24 20:50:26 2011 +0000

    NLM: Fix "kernel BUG at fs/lockd/host.c:417!" or ".../host.c:283!"
    
    Nick Bowler <nbowler@elliptictech.com> reports:
    
    > We were just having some NFS server troubles, and my client machine
    > running 2.6.38-rc1+ (specifically, commit 2b1caf6ed7b888c95) crashed
    > hard (syslog output appended to this mail).
    >
    > I'm not sure what the exact timeline was or how to reproduce this,
    > but the server was rebooted during all this.  Since I've never seen
    > this happen before, it is possibly a regression from previous kernel
    > releases.  However, I recently updated my nfs-utils (on the client) to
    > version 1.2.3, so that might be related as well.
    
      [ BUG output redacted ]
    
    When done searching, the for_each_host loop in next_host_state() falls
    through and returns the final host on the host chain without bumping
    it's reference count.
    
    Since the host's ref count is only one at that point, releasing the
    host in nlm_host_rebooted() attempts to destroy the host prematurely,
    and therefore hits a BUG().
    
    Likely, the original intent of the for_each_host behavior in
    next_host_state() was to handle the case when the host chain is empty.
    Searching the chain and finding no suitable host to return needs to be
    handled as well.
    
    Defensively restructure next_host_state() always to return NULL when
    the loop falls through.
    
    Introduced by commit b10e30f6 "lockd: reorganize nlm_host_rebooted".
    
    Cc: J. Bruce Fields <bfields@fieldses.org>
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f61f6da0d53842e849bab7f69e1431bd3de1136d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jan 21 03:05:38 2011 +0000

    NFS: Prevent memory allocation failure in nfsacl_encode()
    
    nfsacl_encode() allocates memory in certain cases.  This of course
    is not guaranteed to work.
    
    Since commit 9f06c719 "SUNRPC: New xdr_streams XDR encoder API", the
    kernel's XDR encoders can't return a result indicating possibly a
    failure, so a memory allocation failure in nfsacl_encode() has become
    fatal (ie, the XDR code Oopses) in some cases.
    
    However, the allocated memory is a tiny fixed amount, on the order
    of 40-50 bytes.  We can easily use a stack-allocated buffer for
    this, with only a wee bit of nose-holding.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 731f3f482ad3b2c58a1af2d0a9a634a82803706a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jan 21 03:05:28 2011 +0000

    NFS: nfsacl_{encode,decode} should return signed integer
    
    Clean up.
    
    The nfsacl_encode() and nfsacl_decode() functions return negative
    errno values, and each call site verifies that the returned value
    is not negative.  Change the synopsis of both of these functions
    to reflect this usage.
    
    Document the synopsis and return values.
    
    Reported-by: Trond Myklebust <trond.myklebust@netapp.com>
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ee5dc7732bd557bae6d10873a0aac606d2c551fb
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jan 21 03:05:18 2011 +0000

    NFS: Fix "kernel BUG at fs/nfs/nfs3xdr.c:1338!"
    
    Milan Broz <mbroz@redhat.com> reports:
    
    > on today Linus' tree I get OOps if using nfs.
    >
    > server (2.6.36) exports dir:
    > /dir   172.16.1.0/24(rw,async,all_squash,no_subtree_check,anonuid=500,anongid=500)
    >
    > on client it is mounted  in fstab
    > server:/dir  /mnt/tst  nfs  rw,soft 0 0
    >
    > and these commands OOpses it (simplified from a configure script):
    >
    > cd /dir
    > touch x
    > install x y
    >
    > [  105.327701] ------------[ cut here ]------------
    > [  105.327979] kernel BUG at fs/nfs/nfs3xdr.c:1338!
    > [  105.328075] invalid opcode: 0000 [#1] PREEMPT SMP
    > [  105.328223] last sysfs file: /sys/devices/virtual/bdi/0:16/uevent
    > [  105.328349] Modules linked in: usbcore dm_mod
    > [  105.328553]
    > [  105.328678] Pid: 3710, comm: install Not tainted 2.6.37+ #423 440BX Desktop Reference Platform/VMware Virtual Platform
    > [  105.328853] EIP: 0060:[<c116c06c>] EFLAGS: 00010282 CPU: 0
    > [  105.329152] EIP is at nfs3_xdr_enc_setacl3args+0x61/0x98
    > [  105.329249] EAX: ffffffea EBX: ce941d98 ECX: 00000000 EDX: 00000004
    > [  105.329340] ESI: ce941cd0 EDI: 000000a4 EBP: ce941cc0 ESP: ce941cb4
    > [  105.329431]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
    > [  105.329525] Process install (pid: 3710, ti=ce940000 task=ced36f20 task.ti=ce940000)
    > [  105.336600] Stack:
    > [  105.336693]  ce941cd0 ce9dc000 00000000 ce941cf8 c12ecd02 c12f43e0 c116c00b cf754158
    > [  105.336982]  ce9dc004 cf754284 ce9dc004 cf7ffee8 ceff9978 ce9dc000 cf7ffee8 ce9dc000
    > [  105.337182]  ce9dc000 ce941d14 c12e698d cf75412c ce941d98 cf7ffee8 cf7fff20 00000000
    > [  105.337405] Call Trace:
    > [  105.337695]  [<c12ecd02>] rpcauth_wrap_req+0x75/0x7f
    > [  105.337806]  [<c12f43e0>] ? xdr_encode_opaque+0x12/0x15
    > [  105.337898]  [<c116c00b>] ? nfs3_xdr_enc_setacl3args+0x0/0x98
    > [  105.337988]  [<c12e698d>] call_transmit+0x17e/0x1e8
    > [  105.338072]  [<c12ec307>] __rpc_execute+0x6d/0x1a6
    > [  105.338155]  [<c12ec474>] rpc_execute+0x34/0x37
    > [  105.338235]  [<c12e738d>] rpc_run_task+0xb5/0xbd
    > [  105.338316]  [<c12e7474>] rpc_call_sync+0x3d/0x58
    > [  105.338402]  [<c116d0c6>] nfs3_proc_setacls+0x18e/0x24f
    > [  105.338493]  [<c10b3f76>] ? __kmalloc+0x148/0x1c4
    > [  105.338579]  [<c10ecd01>] ? posix_acl_alloc+0x12/0x22
    > [  105.338665]  [<c116d5c8>] nfs3_proc_setacl+0xa0/0xca
    > [  105.338748]  [<c116d69c>] nfs3_setxattr+0x62/0x88
    > [  105.338834]  [<c1317042>] ? sub_preempt_count+0x7c/0x89
    > [  105.338926]  [<c116d63a>] ? nfs3_setxattr+0x0/0x88
    > [  105.339026]  [<c10cfa79>] __vfs_setxattr_noperm+0x26/0x95
    > [  105.339114]  [<c10cfb43>] vfs_setxattr+0x5b/0x76
    > [  105.339211]  [<c10cfbfb>] setxattr+0x9d/0xc3
    > [  105.339298]  [<c10a2ea8>] ? handle_pte_fault+0x258/0x5cb
    > [  105.339428]  [<c1091ff6>] ? __free_pages+0x1a/0x23
    > [  105.339517]  [<c10498ea>] ? up_read+0x16/0x2c
    > [  105.339599]  [<c10b8365>] ? fget+0x0/0xa3
    > [  105.339677]  [<c10b8365>] ? fget+0x0/0xa3
    > [  105.339760]  [<c1025d23>] ? get_parent_ip+0xb/0x31
    > [  105.339843]  [<c1317042>] ? sub_preempt_count+0x7c/0x89
    > [  105.339931]  [<c10cfc72>] sys_fsetxattr+0x51/0x79
    > [  105.340014]  [<c1002853>] sysenter_do_call+0x12/0x32
    > [  105.340133] Code: 2e 76 18 00 58 31 d2 8b 7f 28 f6 43 04 01 74 03 8b 53 08 6a 00 8b 46 04 6a 01 8b 0b 52 89 fa e8 85 10 f8 ff 83 c4 0c 85 c0 79 04 <0f> 0b eb fe 31 c9 f6 43 04 04 74 03 8b 4b 0c 68 00 10 00 00 8d
    > [  105.350321] EIP: [<c116c06c>] nfs3_xdr_enc_setacl3args+0x61/0x98 SS:ESP 0068:ce941cb4
    > [  105.364385] ---[ end trace 01fcfe7f0f7f6e4a ]---
    
    nfs3_xdr_enc_setacl3args() is not properly setting up the target
    buffer before nfsacl_encode() attempts to encode the ACL.
    
    Introduced by commit d9c407b1 "NFS: Introduce new-style XDR encoding
    functions for NFSv3."
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 839f7ad6932d95f4d5ae7267b95c574714ff3d5b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jan 21 15:54:57 2011 +0000

    NFS: Fix "kernel BUG at fs/aio.c:554!"
    
    Nick Piggin reports:
    
    > I'm getting use after frees in aio code in NFS
    >
    > [ 2703.396766] Call Trace:
    > [ 2703.396858]  [<ffffffff8100b057>] ? native_sched_clock+0x27/0x80
    > [ 2703.396959]  [<ffffffff8108509e>] ? put_lock_stats+0xe/0x40
    > [ 2703.397058]  [<ffffffff81088348>] ? lock_release_holdtime+0xa8/0x140
    > [ 2703.397159]  [<ffffffff8108a2a5>] lock_acquire+0x95/0x1b0
    > [ 2703.397260]  [<ffffffff811627db>] ? aio_put_req+0x2b/0x60
    > [ 2703.397361]  [<ffffffff81039701>] ? get_parent_ip+0x11/0x50
    > [ 2703.397464]  [<ffffffff81612a31>] _raw_spin_lock_irq+0x41/0x80
    > [ 2703.397564]  [<ffffffff811627db>] ? aio_put_req+0x2b/0x60
    > [ 2703.397662]  [<ffffffff811627db>] aio_put_req+0x2b/0x60
    > [ 2703.397761]  [<ffffffff811647fe>] do_io_submit+0x2be/0x7c0
    > [ 2703.397895]  [<ffffffff81164d0b>] sys_io_submit+0xb/0x10
    > [ 2703.397995]  [<ffffffff8100307b>] system_call_fastpath+0x16/0x1b
    >
    > Adding some tracing, it is due to nfs completing the request then
    > returning something other than -EIOCBQUEUED, so aio.c
    > also completes the request.
    
    To address this, prevent the NFS direct I/O engine from completing
    async iocbs when the forward path returns an error without starting
    any I/O.
    
    This fix appears to survive ^C during both "xfstest no. 208" and "fsx
    -Z."
    
    It's likely this bug has existed for a very long while, as we are seeing
    very similar symptoms in OEL 5.  Copying stable.
    
    Cc: Stable <stable@kernel.org>
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ad3d2eedf0ed3611f5f86b9e4d0d15cc76c63465
Author: Jesper Juhl <jj@chaosbits.net>
Date:   Mon Jan 17 18:41:50 2011 +0000

    NFS4: Avoid potential NULL pointer dereference in decode_and_add_ds().
    
    On Mon, 17 Jan 2011, Mi Jinlong wrote:
    
    >
    >
    > Jesper Juhl:
    > > strrchr() can return NULL if nothing is found. If this happens we'll
    > > dereference a NULL pointer in
    > > fs/nfs/nfs4filelayoutdev.c::decode_and_add_ds().
    > >
    > > I tried to find some other code that guarantees that this can never
    > > happen but I was unsuccessful. So, unless someone else can point to some
    > > code that ensures this can never be a problem, I believe this patch is
    > > needed.
    > >
    > > While I was changing this code I also noticed that all the dprintk()
    > > statements, except one, start with "%s:". The one missing the ":" I added
    > > it to.
    >
    >   Maybe another one also should be changed at decode_and_add_ds() at line 243:
    >
    >    243  printk("%s Decoded address and port %s\n", __func__, buf);
    >
    Missed that one. Thanks.
    
    Signed-off-by: Jesper Juhl <jj@chaosbits.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0da2a4ac33c291728d8be5bdb865467dcb078d13
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Jan 19 14:18:50 2011 -0500

    NFS: fix handling of malloc failure during nfs_flush_multi()
    
    Cleanup of the allocated list entries should not call
    put_nfs_open_context() on each entry, as the context will
    always be NULL, causing an oops.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

