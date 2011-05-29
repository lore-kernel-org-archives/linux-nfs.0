From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull NFS client pnfs updates
Date: Sun, 29 May 2011 15:57:11 -0400
Message-ID: <1306699032.2299.21.camel__22549.6902633042$1306699045$gmane$org@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Boaz Harrosh <bharrosh@panasas.com>,
	Benny Halevy <bhalevy@panasas.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30265 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755581Ab1E2T5O convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 15:57:14 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please also pull from the "pnfs-submit" branch of the repository at

   git pull git://git.open-osd.org/linux-open-osd.git pnfs-submit

This set of changes contains bugfixes for the existing pnfs "files"
target, and also adds support for the "objects" pnfs target (as detailed
in RFC5664). Although the code is not going through my usual tree, it
has been extensively reviewed by myself and others on the NFS mailing
list for the past 2 months. It makes no functional changes to the
existing NFSv2/v3/v4 client code, but does add some infrastructure to
the existing pNFS code in order to support the new target.

The full set of changes will update the following files through the
appended changesets.

  Cheers,
    Trond

----
 fs/nfs/Kconfig                      |   10 +
 fs/nfs/Makefile                     |    4 +-
 fs/nfs/callback.h                   |   17 +
 fs/nfs/callback_proc.c              |   51 ++-
 fs/nfs/callback_xdr.c               |   96 ++++-
 fs/nfs/client.c                     |    2 +
 fs/nfs/dir.c                        |    9 +-
 fs/nfs/inode.c                      |    3 +-
 fs/nfs/internal.h                   |    1 +
 fs/nfs/nfs4filelayout.c             |   38 +-
 fs/nfs/nfs4filelayout.h             |    8 +-
 fs/nfs/nfs4filelayoutdev.c          |  119 +----
 fs/nfs/nfs4proc.c                   |   98 ++++-
 fs/nfs/nfs4xdr.c                    |  132 ++++-
 fs/nfs/objlayout/Kbuild             |    5 +
 fs/nfs/objlayout/objio_osd.c        | 1057 +++++++++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.c        |  712 +++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.h        |  187 ++++++
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |  412 ++++++++++++++
 fs/nfs/pagelist.c                   |   62 +-
 fs/nfs/pnfs.c                       |  340 +++++++++---
 fs/nfs/pnfs.h                       |  117 ++++-
 fs/nfs/pnfs_dev.c                   |  270 +++++++++
 fs/nfs/read.c                       |    9 +-
 fs/nfs/super.c                      |   25 +
 fs/nfs/write.c                      |   10 +-
 include/linux/nfs4.h                |    1 +
 include/linux/nfs_page.h            |    2 +-
 include/linux/nfs_xdr.h             |   23 +
 include/linux/pnfs_osd_xdr.h        |  345 ++++++++++++
 include/linux/sunrpc/xdr.h          |    2 +
 net/sunrpc/xdr.c                    |   19 +
 32 files changed, 3907 insertions(+), 279 deletions(-)

commit 9342077011d54f42fa1b88b7bc1f7008dcf5fff9
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Wed May 25 21:25:29 2011 +0300

    pnfs-obj: pg_test check for max_io_size
    
    Implement pg_test vector to test for max IO sizes. We calculate
    a max_io_size member only once, and cache it in lseg so to not
    do so on every page insert.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    [simplify logic]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 5b36c7dc41d87d39e779a84fdc2b44b39bba32ca
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Sun May 29 11:45:39 2011 +0300

    NFSv4.1: define nfs_generic_pg_test
    
    By default, unless pnfs is used coalesce pages until pg_bsize
    (rsize or wsize) is reached.
    
    pnfs layout drivers define their own pg_test methods that use
    pnfs_generic_pg_test and need to define their own I/O size
    limits (e.g. based on the file stripe size).
    
    [Move a check from nfs_pageio_do_add_request to nfs_generic_pg_test]
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 89a58e32d9105c01022a757fb32ddc3b51bf0025
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed May 25 20:54:40 2011 +0300

    NFSv4.1: use pnfs_generic_pg_test directly by layout driver
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 18ad0a9f2ccd260d37dd6bc5fa04c7819def4c84
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed May 25 21:03:56 2011 +0300

    NFSv4.1: change pg_test return type to bool
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit dfed206b8857d41a91ebba030f99e30017a44dda
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed May 25 20:25:22 2011 +0300

    NFSv4.1: unify pnfs_pageio_init functions
    
    Use common code for pnfs_pageio_init_{read,write} and use
    a common generic pg_test function.
    
    Note that this function always assumes the the layout driver's
    pg_test method is implemented.
    
    [Fix BUG]
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit a0fe8bf427f4987d7b82678292ca03cfd7331467
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Sun May 22 19:54:13 2011 +0300

    pnfs-obj: objlayout_encode_layoutcommit implementation
    
    * Define API for io-engines to report delta_space_used in IOs
    * Encode the osd-layout specific information of the layoutcommit
      XDR buffer.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit ac7db7264ac3314cae09893bc838fcb7e83267a4
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun May 22 19:53:48 2011 +0300

    pnfs: encode_layoutcommit
    
    Add a layout driver method to encode the layout type specific
    opaque part of layout commit in-line in the xdr stream.
    
    Currently, the pnfs-objects layout driver uses it to encode metadata hints
    to the MDS and the blocks layout driver to commit provisionally allocated
    extents to the file.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit adb58535e604a564495a7d50dfb0afa0ddc21bcb
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Thu May 26 21:49:46 2011 +0300

    pnfs-obj: report errors and .encode_layoutreturn Implementation.
    
    An io_state pre-allocates an error information structure for each
    possible osd-device that might error during IO. When IO is done if all
    was well the io_state is freed. (as today). If the I/O has ended with an
    error, the io_state is queued on a per-layout err_list. When eventually
    encode_layoutreturn() is called, each error is properly encoded on the
    XDR buffer and only then the io_state is removed from err_list and
    de-allocated.
    
    It is up to the io_engine to fill in the segment that fault and the type
    of osd_error that occurred. By calling objlayout_io_set_result() for
    each failing device.
    
    In objio_osd:
    * Allocate io-error descriptors space as part of io_state
    * Use generic objlayout error reporting at end of io.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 04a555498e03b3804e2dec916a4669f5f560e503
Author: Andy Adamson <andros@netapp.com>
Date:   Sun May 22 19:53:10 2011 +0300

    pnfs: encode_layoutreturn
    
    Add a layout driver method to encode the layout type specific
    opaque part of layout return in-line in the xdr stream.
    
    Currently the pnfs-objects layout driver uses it to encode i/o error
    information on LAYOUTRETURN.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [fixup layout header pointer for encode_layoutreturn]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 8a1636c459cb7a4b32ba4024cd1b2ba21fba6aed
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Jul 14 15:43:57 2010 -0400

    pnfs: layoutret_on_setattr
    
    With the objects layout security model, we have object capabilities
    that are associated with the layout and we anticipate that the server
    will issue a cb_layoutrecall for any setattr that changes security
    related attributes (user/group/mode/acl) or truncates the file.
    
    Therefore, the layout is returned before issuing the setattr to avoid
    the anticipated cb_layoutrecall.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit cbe8260369c9f88eafa035cd327dc3e02fad528c
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun May 22 19:52:37 2011 +0300

    pnfs: layoutreturn
    
    NFSv4.1 LAYOUTRETURN implementation
    
    Currently, does not support layout-type payload encoding.
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Andy Adamson <andros@citi.umich.edu>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
    [call pnfs_return_layout right before pnfs_destroy_layout]
    [remove assert_spin_locked from pnfs_clear_lseg_list]
    [remove wait parameter from the layoutreturn path.]
    [remove return_type field from nfs4_layoutreturn_args]
    [remove range from nfs4_layoutreturn_args]
    [no need to send layoutcommit from _pnfs_return_layout]
    [don't wait on sync layoutreturn]
    [fix layout stateid in layoutreturn args]
    [fixed NULL deref in _pnfs_return_layout]
    [removed recaim member of nfs4_layoutreturn_args]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 04f83450388e87d86b387cf4a27b81eb7e69de7d
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Sun May 22 19:52:19 2011 +0300

    pnfs-obj: osd raid engine read/write implementation
    
    With the use of the in-kernel osd library. Implement read/write
    of data from/to osd-objects according to information specified
    in the objects-layout.
    
    Support for stripping over mirrors with a received stripe_unit.
    There are however a few constrains which are not supported:
     1. Stripe Unit must be a multiple of PAGE_SIZE
     2. stripe length (stripe_unit * number_of_stripes) can not be
        bigger then 32bit.
    
    Also support raid-groups and partial-layout. Partial-layout is
    when not all the groups are received on the line, addressing
    only a partial range of the file.
    
    TODO:
      Only raid0! raid 4/5/6 support will come at later stage
    
    A none supported layout will send IO through the MDS
    
    [Important fallout from the last rebase]
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    [gfp_flags]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit d20581aa4be11407c9eeeb75992df5ef176bba0f
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun May 22 19:52:03 2011 +0300

    pnfs: support for non-rpc layout drivers
    
    Non-rpc layout driver such as for objects and blocks
    implement their own I/O path and error handling logic.
    Therefore bypass NFS-based error handling for these layout drivers.
    
    [fix lseg ref-count bugs, and null de-refs]
    [Fall out from: non-rpc layout drivers]
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    [get rid of PNFS_USE_RPC_CODE]
    [get rid of __nfs4_write_done_cb]
    [revert useless change in nfs4_write_done_cb]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit e51b841dd0be9ff53f740c44c32c32679edcb7c8
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun May 22 19:51:48 2011 +0300

    pnfs-obj: define per-inode private structure
    
    allocate and deallocate per-inode private pnfs_layout_hdr
    in preparation for I/O implementation.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 636fb9c89d7e216aac3d406e458864420057e981
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun May 22 19:51:33 2011 +0300

    pnfs: alloc and free layout_hdr layoutdriver methods
    
    [gfp_flags]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit b6c05f1693115164c7b797152ac7ea3ef8e5d296
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Thu May 26 21:45:34 2011 +0300

    pnfs-obj: objio_osd device information retrieval and caching
    
    When a new layout is received in objio_alloc_lseg all device_ids
    referenced are retrieved. The device information is queried for from MDS
    and then the osd_device is looked-up from the osd-initiator library. The
    devices are cached in a per-mount-point list, for later use. At unmount
    all devices are "put" back to the library.
    
    objlayout_get_deviceinfo(), objlayout_put_deviceinfo() middleware
    API for retrieving device information given a device_id.
    
    TODO: The device cache can get big. Cap its size. Keep an LRU and start
          to return devices which were not used, when list gets to big, or
          when new entries allocation fail.
    
    [pnfs-obj: Bugs in new global-device-cache code]
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    [gfp_flags]
    [use global device cache]
    [use layout driver in global device cache]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 09f5bf4e6d0607399c16ec7a2d8d166f31086686
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Sun May 22 19:50:20 2011 +0300

    pnfs-obj: decode layout, alloc/free lseg
    
    objlayout_alloc_lseg prepares an xdr_stream and calls the
    raid engins objio_alloc_lseg() to allocate a private
    pnfs_layout_segment.
    
    objio_osd.c::objio_alloc_lseg() uses passed xdr_stream to
    decode and store the layout_segment information in an
    objio_segment struct, using the pnfs_osd_xdr.h API for
    the actual parsing the layout xdr.
    
    objlayout_free_lseg calls objio_free_lseg() to free the
    allocated space.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    [gfp_flags]
    [removed "extern" from function definitions]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit f1bc893a89d012649e4e7f43575b2c290e08ee42
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Sun May 22 19:49:57 2011 +0300

    pnfs-obj: pnfs_osd XDR client implementation
    
    * Add the fs/nfs/objlayout/pnfs_osd_xdr_cli.c file, which will
      include the XDR encode/decode implementations for the pNFS
      client objlayout driver.
    
    [Wrong type in comments]
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 38b7c401f6ade50543f246c4bc2c971edf2b19dd
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun May 22 19:49:32 2011 +0300

    pnfs-obj: pnfs_osd XDR definitions
    
    * Add the pnfs_osd_xdr.h header
    
    * defintions the pnfs_osd_layout structure including all it's
      sub-types and constants.
    * Declare the pnfs_osd_xdr_decode_layout API + all needed
      inline helpers.
    
    * Define the pnfs_osd_deviceaddr structure and all its subtypes and
      constants.
    * Declare API for decoding of a pnfs_osd_deviceaddr from XDR stream.
    
    * Define the pnfs_osd_ioerr structure, its substructures and constants.
    * Declare API for encoding of a pnfs_osd_ioerr into XDR stream.
    
    * Define the pnfs_osd_layoutupdate structure and its substructures.
    * Declare API for encoding of a pnfs_osd_layoutupdate into XDR stream.
    
    [Remove server definitions]
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit c93407d03c3ccf60b33a309e5fcd41cd98969901
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun May 22 19:49:06 2011 +0300

    pnfs-obj: objlayoutdriver module skeleton
    
    * Define the PNFS_OBJLAYOUT Kconfig option in the nfs
      master Kconfig file.
    * Add the objlayout driver to the Kernel's Kbuild system.
    * Add the fs/nfs/objlayout/Kbuild file for building the
      objlayoutdriver.ko driver
    * Define fs/nfs/objlayout/objio_osd.c, register the driver on module
      initialization and unregister on exit.
    
    [pnfs-obj: remove of CONFIG_PNFS fallout]
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    [added "unsure" clause]
    [depend on NFS_V4_1]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit ae50c0b5c6f6fa340f1fe2d244b358145f7e5a15
Author: J. Bruce Fields <bfields@fieldses.org>
Date:   Sun May 22 19:48:21 2011 +0300

    pnfs: client stats
    
    A pNFS client auto-negotiates a lot of features (minorversion level,
    pNFS layout type, etc.).  This is convenient, but makes certain kinds of
    failures hard for a user to detect.
    
    For example, if the client falls back on 4.0, or falls back to MDS IO
    because the user didn't connect to the right iscsi disks before
    mounting, the only symptoms may be reduced performance, which may not be
    noticed till long after the actual failure, and may be difficult for a
    user to diagnose.
    
    However, such "failures" may also be perfectly normal in some cases, so
    we don't want to spam the system logs with them.
    
    One approach would be to put some more information into
    /proc/self/mountstats.
    
    Signed-off-by: J. Bruce Fields <bfields@fieldses.org>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [pnfs: add commit client stats]
    [fixup data types for "ret" variables in pnfs_try_to* inline funcs.]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [fix definition of show_pnfs for !CONFIG_PNFS]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfs41: Fix show_sessions in the not CONFIG_NFS_V4_1 case]
        There is a build error when CONFIG_NFS_V4 is set but
        CONFIG_NFS_V4_1 is *not* set. show_sessions() prototype
        was unbalanced between the two cases.
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    [pnfs: super.c remove CONFIG_PNFS]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 778b5502fdba5b183553f3f2ef1672ba78ac58b6
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun May 22 19:48:02 2011 +0300

    pnfs: Use byte-range for cb_layoutrecall
    
    Use recalled range to invalidate particular layout segments in the layout cache.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 707ed5fdb587c71fdb7ad224ba1d80231f33c974
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun May 22 19:47:46 2011 +0300

    pnfs: align layoutget requests on page boundaries
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit fb3296eb4636763918edef2d22e45b85b15d4518
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun May 22 19:47:26 2011 +0300

    pnfs: Use byte-range for layoutget
    
    Add offset and count parameters to pnfs_update_layout and use them to get
    the layout in the pageio path.
    
    Order cache layout segments in the following order:
    * offset (ascending)
    * length (descending)
    * iomode (RW before READ)
    
    Test byte range against the layout segment in use in pnfs_{read,write}_pg_test
    so not to coalesce pages not using the same layout segment.
    
    [fix lseg ordering]
    [clean up pnfs_find_lseg lseg arg]
    [remove unnecessary FIXME]
    [fix ordering in pnfs_insert_layout]
    [clean up pnfs_insert_layout]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit f7da7a129d57bfe0f74573dc03531c63e1360fae
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Thu May 19 14:16:47 2011 -0400

    SUNRPC: introduce xdr_init_decode_pages
    
    Initialize xdr_stream and xdr_buf using an array of page pointers
    and length of buffer.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 35c8bb543c9e83197e6375142d1d1c2ee3cf017d
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Tue May 24 18:04:02 2011 +0300

    NFSv4.1: use layout driver in global device cache
    
    pnfs deviceids are unique per server, per layout type.
    struct nfs_client is currently used to distinguish deviceids from
    different nfs servers, yet these may clash between different layout
    types on the same server.  Therefore, use the layout driver associated
    with each deviceid at insertion time to look it up, unhash, or
    delete it.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 1be5683b03a766670b3b629bf6bfeab3ca9239d8
Author: Marc Eshel <eshel@almaden.ibm.com>
Date:   Sun May 22 19:47:09 2011 +0300

    pnfs: CB_NOTIFY_DEVICEID
    
    Note: This functionlaity is incomplete as all layout segments referring to
    the 'to be removed device id' need to be reaped, and all in flight I/O drained.
    
    [use be32 res in nfs4_callback_devicenotify]
    [use nfs_client to qualify deviceid for cb_notify_deviceid]
    [use global deviceid cache for CB_NOTIFY_DEVICEID]
    [refactor device cache _lookup_deviceid]
    [refactor device cache _find_get_deviceid]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Bug in new global-device-cache code]
    [layout_driver MUST set free_deviceid_node if using dev-cache]
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 1775bc342c6eacd6304493cbb2e0cda1a0182246
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri May 20 13:47:33 2011 +0200

    NFSv4.1: purge deviceid cache on nfs_free_client
    
    Use the pnfs_layoutdriver_type both as a qualifier for the deviceid,
    distinguishing deviceid from different layout types on the server,
    and for freeing the layout-driver allocated structure containing the
    nfs4_deviceid_node.
    
    [BUG in _deviceid_purge_client]
    [layout_driver MUST set free_deviceid_node if using dev-cache]
    [let ver < 4.1 compile]
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    [removed EXPORT_SYMBOL_GPL(nfs4_deviceid_purge_client)]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit a1eaecbc4c8307e27772d6584ef85a2e93250661
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Thu May 19 22:14:47 2011 -0400

    NFSv4.1: make deviceid cache global
    
    Move deviceid cache from the pnfs files layout driver to the
    generic layer in preparation for the objects layout driver.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 45df3c8b0f3a58facb125d7631890426706c0bfa
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Thu May 5 08:28:46 2011 +0300

    pnfs: resolve header dependency in pnfs.h
    
    Some definitions in the header file depend on nfs_fs.h so pnfs.h can't
    be included independently.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 67d51f65bde233b17de304baec4f7c4d086471fe
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Fri May 20 10:45:05 2011 +0200

    NFSv4.1: use struct nfs_client to qualify deviceid
    
    deviceids are unique per server, per layout type.
    Therefore, in the global cache in the files layout driver
    deviceids from different servers may clash so we need
    to qualify them with a struct nfs_client that represents
    the nfs server that returned the deviceid.
    
    Introduced in 2.6.39 commit ea8eecdd
    "NFSv4.1 move deviceid cache to filelayout driver"
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 3b6445a6f68b839d1b437756b9c72312e33339b2
Author: Jim Rees <rees@umich.edu>
Date:   Tue Feb 22 19:31:57 2011 -0500

    NFSv4.1: fix typo in filelayout_check_layout
    
    Signed-off-by: Jim Rees <rees@umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

