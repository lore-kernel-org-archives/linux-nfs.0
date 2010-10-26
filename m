Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1253 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933326Ab0JZR7z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Oct 2010 13:59:55 -0400
Subject: [GIT PULL] Please pull NFSv4.1 and pNFS changes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 26 Oct 2010 13:58:45 -0400
Message-ID: <1288115925.15897.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Resending request after adding the two patches "NFS: rename nfs.upcall
-> nfs.idmap" and "NFS: Fix a compile issue in nfs_root".

Please pull from the "nfs-for-2.6.37" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git nfs-for-2.6.37

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 Documentation/filesystems/nfs/00-INDEX     |    2 +
 Documentation/filesystems/nfs/idmapper.txt |   28 +-
 Documentation/filesystems/nfs/pnfs.txt     |   48 ++
 fs/nfs/Kconfig                             |    8 +-
 fs/nfs/Makefile                            |    4 +
 fs/nfs/callback_proc.c                     |    8 +-
 fs/nfs/client.c                            |   10 +-
 fs/nfs/file.c                              |    5 +
 fs/nfs/inode.c                             |    3 +
 fs/nfs/nfs4filelayout.c                    |  280 ++++++++++
 fs/nfs/nfs4filelayout.h                    |   94 ++++
 fs/nfs/nfs4filelayoutdev.c                 |  448 ++++++++++++++++
 fs/nfs/nfs4proc.c                          |  218 +++++++--
 fs/nfs/nfs4state.c                         |    2 +
 fs/nfs/nfs4xdr.c                           |  360 +++++++++++++
 fs/nfs/nfsroot.c                           |    2 +
 fs/nfs/pnfs.c                              |  783 ++++++++++++++++++++++++++++
 fs/nfs/pnfs.h                              |  189 +++++++
 fs/nfs/read.c                              |    3 +
 fs/nfsd/nfs4callback.c                     |    1 -
 include/linux/nfs4.h                       |   62 +++-
 include/linux/nfs_fs.h                     |    5 +
 include/linux/nfs_fs_sb.h                  |    3 +
 include/linux/nfs_xdr.h                    |   50 ++
 include/linux/sunrpc/xdr.h                 |    7 +
 net/sunrpc/auth_gss/gss_krb5_mech.c        |    2 +-
 26 files changed, 2566 insertions(+), 59 deletions(-)

commit eb1c86b8b501ad9a073d9d519105979d31fa0ef2
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Tue Oct 26 13:27:42 2010 -0400

    NFS: rename nfs.upcall -> nfs.idmap
    
    This patch renames the idmapper upcall program from nfs.upcall to nfs.idmap in
    the NFS documentation.  This is because the program has been renamed in the
    nfs-utils source.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 036a1075978e35811f22be3ff86a70cb8d22cb85
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 26 13:47:04 2010 -0400

    NFS: Fix a compile issue in nfs_root
    
    Stephen Rothwell reports:
    
    > /home/test/linux-2.6/fs/nfs/nfsroot.c: In function 'nfs_root_debug':
    > /home/test/linux-2.6/fs/nfs/nfsroot.c:110:2: error: 'nfs_debug'
    > undeclared (first use in this function)
    > /home/test/linux-2.6/fs/nfs/nfsroot.c:110:2: note: each undeclared
    > identifier is reported only once for each function it appears in
    > make[3]: *** [fs/nfs/nfsroot.o] Error 1
    > make[2]: *** [fs/nfs] Error 2
    > make[1]: *** [fs] Error 2
    > make: *** [sub-make] Error 2
    
    Which is caused by commit 306a075362a288683f6346185f97dd0e06df19da
    (NFS: Allow NFSROOT debugging messages to be enabled dynamically)
    
    Fix is to disable this code when RPC_DEBUG is disabled.
    
    Reported-by: Zimny Lech <napohybelskurwysynom2010@gmail.com>
    Tested-by: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 411b5e05617593efebc06241dbc56f42150f2abe
Author: Joe Perches <joe@perches.com>
Date:   Mon Sep 13 12:48:01 2010 -0700

    net/sunrpc: Use static const char arrays
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 43c2e885be25311e6289c7da52e8a03c4453ee03
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Sat Oct 2 15:19:01 2010 -0400

    nfs4: fix channel attribute sanity-checks
    
    The sanity checks here are incorrect; in the worst case they allow
    values that crash the client.
    
    They're also over-reliant on the preprocessor.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1c787096fce217b5fdd9806dbce96e738c9345c0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 21 16:56:48 2010 -0400

    NFSv4.1: Use more sensible names for 'initialize_mountpoint'
    
    The initialize_mountpoint/uninitialise_mountpoint functions are really about
    setting or clearing the layout driver to be used on this filesystem. Change
    the names to the more descriptive 'set_layoutdriver/clear_layoutdriver'.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 16b374ca439fb406e46e071f75428f5b033056f8
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Oct 20 00:18:04 2010 -0400

    NFSv4.1: pnfs: filelayout: add driver's LAYOUTGET and GETDEVICEINFO infrastructure
    
    Implement the driver's io_ops->alloc_lseg and free_lseg functions,
    which integrate into the deviceid cache and calls out to
    nfs4_proc_getdeviceinfo when necessary.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Dean Hildebrand <dhildebz@umich.edu>
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Mike Sager <sager@netapp.com>
    Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b1f69b754ee312ec75f2c7ead0e6851cd9598cc2
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Oct 20 00:18:03 2010 -0400

    NFSv4.1: pnfs: add LAYOUTGET and GETDEVICEINFO infrastructure
    
    Add the ability to actually send LAYOUTGET and GETDEVICEINFO.  This also adds
    in the machinery to handle layout state and the deviceid cache.  Note that
    GETDEVICEINFO is not called directly by the generic layer.  Instead it
    is called by the drivers while parsing the LAYOUTGET opaque data in response
    to an unknown device id embedded therein.  RFC 5661 only encodes
    device ids within the driver-specific opaque data.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Dean Hildebrand <dhildebz@umich.edu>
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Mike Sager <sager@netapp.com>
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 974cec8ca0352eb5d281535b714cf194a606e98f
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Oct 20 00:18:02 2010 -0400

    NFS: client needs to maintain list of inodes with active layouts
    
    In particular, server reboot will invalidate all layouts.
    
    Note that in order to have an active layout, we must get a successful response
    from the server.  To avoid adding that machinery, this patch just includes a
    stub that fakes up a successful return.  Since the layout is never referenced
    for io, this is not a problem.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Dean Hildebrand <dhildebz@umich.edu>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e5e940170b2136ad4d5483ef293ae284b9cc8d53
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Oct 20 00:18:01 2010 -0400

    NFS: create and destroy inode's layout cache
    
    At the start of the io paths, try to grab the relevant layout
    information.  This will initiate the inode's layout cache, but
    stubs ensure the cache stays empty.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Dean Hildebrand <dhildebz@umich.edu>
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7ab672ce312133ee4a5d85b71447b2b334403681
Author: Dean Hildebrand <dhildebz@umich.edu>
Date:   Wed Oct 20 00:18:00 2010 -0400

    NFSv4.1: pnfs: filelayout: introduce minimal file layout driver
    
    This driver just registers itself and supplies trivial mount/umount functions.
    
    Signed-off-by: Dean Hildebrand <dhildebz@umich.edu>
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 02c35fca7cf4ea2dfdc6db279e230cacbbf4b870
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Oct 20 00:17:59 2010 -0400

    NFSv4.1: pnfs: full mount/umount infrastructure
    
    Allow a module implementing a layout type to register, and
    have its mount/umount routines called for filesystems that
    the server declares support it.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Andy Adamson<andros@netapp.com>
    Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 85e174ba6b786ad336eb2df105b4f66d0932e70a
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Oct 20 00:17:58 2010 -0400

    NFS: set layout driver
    
    Put in the infrastructure that uses information returned from the
    server at mount to select a layout driver module.
    
    In this patch, a stub is used that always returns "no driver found".
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Dean Hildebrand <dhildebz@umich.edu>
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 504913fbc84c00bba7224d73e4aab525c1731f7d
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Oct 20 00:17:57 2010 -0400

    NFS: ask for layouttypes during v4 fsinfo call
    
    This information will be used to determine which layout driver,
    if any, to use for subsequent IO on this filesystem.  Each driver
    is assigned an integer id, with 0 reserved to indicate no driver.
    
    The server can in theory return multiple ids.  However, our current
    client implementation only notes the first entry and ignores the
    rest.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9449925273933d19235d7d36c1fd970841d055de
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Wed Oct 20 00:17:56 2010 -0400

    NFS: change stateid to be a union
    
    In NFSv4.1 the stateid consists of the other and seqid fields. For layout
    processing we need to numerically compare the seqid value of layout stateids.
    To do so, introduce a union to nfs4_stateid to switch between opaque(16 bytes)
    and opaque(12 bytes) / __be32
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c772567d97fa0fca454eea68aeae915ca1bc732b
Author: Dean Hildebrand <dhildebz@umich.edu>
Date:   Wed Oct 20 00:17:55 2010 -0400

    NFSv4.1: pnfsd, pnfs: protocol level pnfs constants
    
    Use only layoutreturn constant for both returns and recalls.
    (return_* works better for recall_type rather the other way around)
    
    Signed-off-by: Dean Hildebrand <dhildebz@umich.edu>
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 35b61e63323ccf5fdcdd74b11751b58392c9cce1
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Oct 20 00:17:54 2010 -0400

    SUNRPC: define xdr_decode_opaque_fixed
    
    A helper for decoding a fixed length opaque value.
    Returns a pointer to the next item in the xdr stream.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3c9101a0575f6078191dae6bb91a834c6aac3557
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Oct 20 00:17:53 2010 -0400

    NFSD: remove duplicate NFS4_STATEID_SIZE
    
    Already accepted by Bruce
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


