Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:2853 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754904Ab1CYJ5D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Mar 2011 05:57:03 -0400
Message-ID: <4D8C6701.3080506@panasas.com>
Date: Fri, 25 Mar 2011 11:57:21 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.38-2011-03-25
References: <4D41D711.70807@panasas.com> <4D4B10B0.2040500@panasas.com> <4D6BCDDF.1070909@panasas.com>
In-Reply-To: <4D6BCDDF.1070909@panasas.com>
Content-Type: text/plain; charset=windows-1255
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

With the release of 2.6.38 I've rebased the pnfs tree on top of it
and created the pnfs-all-2.6.38 branch to hold the stream.

A new branch, pnfs-for-2.6.39, holds a cleaned-up series of the pnfs
branch, to be rebased onto v2.6.39-rc* after Linus pulls the wave5
patches from nfs-for-2.6.39.

The patched in pnfs-for-2.6.39 are listed below

Benny

 fs/nfs/callback.h         |   20 ++
 fs/nfs/callback_proc.c    |   34 ++-
 fs/nfs/callback_xdr.c     |   96 ++++++-
 fs/nfs/client.c           |    7 +-
 fs/nfs/direct.c           |  160 ++++++-----
 fs/nfs/file.c             |    2 +-
 fs/nfs/inode.c            |   11 +-
 fs/nfs/nfs4_fs.h          |   13 +-
 fs/nfs/nfs4filelayout.c   |    9 +-
 fs/nfs/nfs4proc.c         |  273 +++++++++++++++++-
 fs/nfs/nfs4xdr.c          |  396 +++++++++++++++++++++++++
 fs/nfs/pnfs.c             |  725
++++++++++++++++++++++++++++++++++++++++-----
 fs/nfs/pnfs.h             |  198 ++++++++++++-
 fs/nfs/read.c             |   23 ++-
 fs/nfs/super.c            |   25 ++
 fs/nfs/write.c            |   23 ++-
 include/linux/nfs4.h      |    3 +
 include/linux/nfs_fs_sb.h |    3 +
 include/linux/nfs_xdr.h   |   74 +++++
 19 files changed, 1919 insertions(+), 176 deletions(-)

commit 155d9fde992ff98edad95c95ea554b7ad3b6794b
Author: J. Bruce Fields <bfields@fieldses.org>
Date:   Fri Jul 17 17:51:29 2009 -0400

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

commit ced8029bc8f2efa0933030b47529b1df8480b1bf
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Thu Feb 17 12:43:12 2011 -0500

    pnfs: improve nfs4_layoutget_done debug printouts

    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 96f5c53473ce08a539d2671a94d7011cc397a5e3
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon Jul 12 18:50:04 2010 +0300

    pnfs: mark page with error in readpage_async_filler when crossing lsegs

    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit fbd73560e503cc9c1b20f60d7d8588d113f3baea
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Tue Sep 28 21:22:53 2010 +0200

    pnfs: alloc and free layout_hdr layoutdriver methods

    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 3c5cf965115d69da8d5836229055a2440037050c
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Thu May 6 20:09:02 2010 +0300

    FIXME: pnfs: per mount layout driver private data

    Temporary relief until we convert to use generic device cache.

    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit d4ace0226c398ebd1c76790463d4e9b49e79f5dd
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed May 5 12:10:20 2010 +0300

    pnfs: pass mntfh down the init_pnfs path

    To allow layout driver to issue getdevicelist at mount time.

    [fixup non NFS_V4_1 set_pnfs_layoutdriver definition]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 5af291ca118e7229d63883a32031f24cd237856f
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Apr 30 14:27:12 2010 -0400

    pnfs: ds_wsize and ds_rsize

    Set read/write I/O sizes for data servers

    Signed-off-by: Andy Adamson <andros@netapp.com>
    [moved pnfs_set_ds_iosize to respective patch]
    [define pnfs_set_ds_iosize for !CONFIG_NFS_V4_1]
    [check pnfs_curr_ld in server->pnfs_curr_ld]
    [merge  get_blocksize policy operation]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 5bdeaa297a843419f5c16b923f5d6a3d6a5f34db
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Apr 30 14:27:09 2010 -0400

    pnfs: GETDEVICELIST

    The block driver uses GETDEVICELIST

    Signed-off-by: Andy Adamson <andros@netapp.com>
    [pass struct nfs_server * to getdevicelist]
    [get machince creds for getdevicelist]
    [fix getdevicelist decode sizing]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 7c9c654fb1da1d6bf7247ff285c761daef003d6a
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon Aug 30 12:34:48 2010 +0300

    pnfs: get machine creds

    for getdevicelist

    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit dc36f96e54aed069e73fa47adba216613cad2bc8
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon Jun 14 11:04:23 2010 -0400

    pnfs: check for non-rpc layout drivers

    [mark commit data as PNFS_NO_RPC in pnfs_try_to_commit]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 892b1015cf26b293b7a388200e2f79589b543597
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon Jun 14 11:04:16 2010 -0400

    pnfs: Introduce pnfs_call_done and io done callbacks

    To be called from layout drivers on the io done path.

    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 8d930291704eb794892112f3d90d448438838533
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon Jun 14 11:03:48 2010 -0400

    pnfs: pnfs_error

    Return errors on the pnfs path in pnfs_call_data.pnfs_error

    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 2707e163a9430e70da79291113cd83047d4f0cdb
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jun 17 15:34:56 2010 -0400

    pnfs: setup_layoutcommit

    Signed-off-by: Andy Adamson <andros@netapp.com>
    [fixup layout header pointer for layoutcommit]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 75fbbc5a44bba27fce939ed852981777873fb9a5
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jun 17 15:34:55 2010 -0400

    pnfs: cleanup_layoutcommit

    Signed-off-by: Andy Adamson <andros@netapp.com>
    [fixup layout header pointer for layoutcommit]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 184dd8974e49fe16264dceedbaebc431af44b3b8
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jun 17 15:34:54 2010 -0400

    pnfs: encode_layoutcommit

    Signed-off-by: Andy Adamson <andros@netapp.com>
    [fixup layout header pointer for layoutcommit]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 9fe095707fa05c1b7253dbc4bff7a8718a3ea3ae
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Jun 23 15:21:16 2010 -0400

    pnfs: encode_layoutreturn

    Signed-off-by: Andy Adamson <andros@netapp.com>
    [fixup layout header pointer for encode_layoutreturn]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 7c0448ceee9b3ecbe34c1cea5db9cf4b8bd3f96e
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon Jul 12 18:51:36 2010 +0300

    pnfs: Use byte-range layout segments

    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit f888d677ffc5c44b13ad2c74e9714670cb584607
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon Jul 12 18:50:50 2010 +0300

    pnfs: readahead_range

    Signed-off-by: TBD
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit c5120038ecb4050cf2e25b33e8782640efd26e57
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Jul 14 15:43:57 2010 -0400

    pnfs: layoutret_on_setattr

    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 752c112ff1aa66c793736595987c185bf9810116
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Dec 15 16:17:31 2010 +0200

    pnfs: layoutreturn

    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Andy Adamson <andros@citi.umich.edu>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit c6024e4cb3a70642f8baf09ceffe68eac84adc0e
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Aug 13 17:31:59 2010 -0400

    pnfs: direct i/o

    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 57ec1d2986e55ae6ea63641efdb56804a02f7420
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Dec 15 14:04:46 2010 -0500

    pnfs: layoutcommit

    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Mingyang Guo <guomingyang@nrchpc.ac.cn>
    Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
    Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
    Tested-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 815bb1f7c46c93771fcea62103c1d8562c3c3f10
Author: Andy Adamson <andros@citi.umich.edu>
Date:   Fri Aug 13 17:31:37 2010 -0400

    pnfs: layoutcommit helper functions

    Signed-off-by: Andy Adamson <andros@citi.umich.edu>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Mingyang Guo <guomingyang@nrchpc.ac.cn>
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Tested-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit b4555d970d24fda018b5d3348a5160230deb8306
Author: Fred Isaman <iisaman@netapp.com>
Date:   Mon Dec 20 11:33:54 2010 -0500

    pnfs: has_layout

    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit c10e3ca28266863b11fa266c13de79f5f6e83a31
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Sep 29 02:33:41 2010 +0200

    pnfs: file needs layout commit, server attributes may be stale

    [part of "pnfs: layoutcommit"]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 19c1edfde37912ca6f98f8947cd73a2248da014e
Author: Marc Eshel <eshel@almaden.ibm.com>
Date:   Fri Aug 13 17:32:01 2010 -0400

    pnfs: CB_NOTIFY_DEVICEID

    Note: This functionlaity is incomplete as all layout segments
referring to
    the 'to be removed device id' need to be reaped, and all in flight
I/O drained.

    [pnfs: cb_notify_deviceid declarations]
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [removed use of NIPQUAD starting 2.6.36]
    [covnerted to use Fred's latest device cache]
    [move synchronize_rcu out side of spin_lock]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
