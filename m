Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:29001 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690Ab1B1Qbf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Feb 2011 11:31:35 -0500
Message-ID: <4D6BCDDF.1070909@panasas.com>
Date: Mon, 28 Feb 2011 18:31:27 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.38-rc5-2011-02-26
References: <4D41D711.70807@panasas.com> <4D4B10B0.2040500@panasas.com>
In-Reply-To: <4D4B10B0.2040500@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I pushed the Connectathon fixes for pnfs-all-latest to the main tree
git://linux-nfs.org/~bhalevy/linux-pnfs.git
And I'll sync with Fred's wave[345] series when he's ready.

New commits submitted since last update (pnfs-all-2.6.38-rc3-2011-02-03)
are listed below.

Benny

pnfs-all-2.6.37:
  Benny Halevy     6d105b3 pnfsd: Initialize cb_layout clr_recall.cb_work
  Benny Halevy     f8282df pnfsd: add default error case in nfsd4_cb_layout_done
  Benny Halevy     488dbb1 pnfsd: do not clear rpc_resp in nfsd4_cb_done_sequence
  Benny Halevy     9243514 pnfs: fix missing unlock in nfs_client_return_layouts
  Benny Halevy     38a4a8d pnfs: return bool status from nfs4_asynch_forget_layouts
  Benny Halevy     1cabadb pnfs: return NFS4ERR_DELAY from layoutrecall while waiting on lsegs
  Benny Halevy     be52477 pnfs: fix cl_drain_notification indexing
  Benny Halevy     257b10f pnfs: fix nfs4_asynch_forget_layouts accounting
  Benny Halevy     013dffa pnfs: improve nfs4_layoutget_done debug printouts
  Benny Halevy     7355ec0 pnfs: fix lock inversion in pnfs_layout_process

nfs-upstream:
  Trond Myklebust  ec45b78 SUNRPC: Fix a memory leak in rpc_new_task()
  Trond Myklebust  3561b23 SUNRPC: Close a race in __rpc_wait_for_completion_task()
  Trond Myklebust  bcaedce NFS/VFS: Fix the nfs sillyrename regression
  Benny Halevy     4856b2d NFSv4.1: reject zero layout with zeroed stripe unit
  Jim Rees         b76d1d5 NFSv4.1: fix typo in filelayout_check_layout

nfsd-upstream:
  Benny Halevy     767d1a0 NFSD: fix decode_cb_sequence4resok
  Benny Halevy     ebca1bc nfsd41: use SEQ4_STATUS_BACKCHANNEL_FAULT when cb_sequence is invalid

pnfsd:
  Benny Halevy     9bb661a pnfsd: do not clear rpc_resp in nfsd4_cb_done_sequence

pnfsd-lexp:
  Benny Halevy     3e947f3 pnfsd-lexp: recall layout on truncate

pnfs-submit-wave3:
  Andy Adamson     733c2ca NFSv4: remove CONFIG_NFS_V4 from nfs_read_data
  Andy Adamson     e347996 NFSv4.1: put_layout_hdr can remove nfsi->layout
  Andy Adamson     2e5bfda NFS move nfs_client initialization into nfs_get_client
  Andy Adamson     31642d8 NFSv4.1: send zero stateid seqid on v4.1 i/o
  Andy Adamson     078fb11 NFSv4.1: new flag for state renewal check
  Andy Adamson     45429c7b NFSv4.1: new flag for lease time check
  Andy Adamson     a557a45 NFSv4.1: add MDS mount DS only check
  Fred Isaman      42e7c6e NFSv4.1: lseg refcounting
  Fred Isaman      28377e6 NFSv4.1: coelesce across layout stripes
  Fred Isaman      f5650f9 NFSv4.1: shift pnfs_update_layout locations
  Andy Adamson     ab7ffb5 NFSv4.1: generic read
  Andy Adamson     242f5ce NFSv4.1: data server connection
  Fred Isaman      4374a1b NFSv4.1: filelayout i/o helpers
  Andy Adamson     fcb2ee6 NFSv4.1: filelayout read
  Andy Adamson     47c3fd3 NFSv4.1: filelayout async error handler
  Christoph Hellwig  627c22e NFSv4.1 move deviceid cache to filelayout driver
  Andy Adamson     29b9fde NFSv4.1: turn off pNFS on ds connection failure
  Fred Isaman      442d08c NFSv4.1: lseg documentation
  Fred Isaman      6205ddc SQUASHME wave3: address Benny's comment
  Fred Isaman      d3ff5cd SQUASHME wave3: whitespace fix
  Benny Halevy     9d0fcee NFSv4.1: pnfs-submit-wave3: put_lseg_common should use list_del_init

pnfs-submit-wave4:
  Fred Isaman      0479cd6 NFSv4.1: add callback to nfs4_write_done
  Fred Isaman      55f54f7 NFSv4.1: trigger LAYOUTGET for writes
  Fred Isaman      0c992aa NFSv4.1: remove GETATTR from ds writes
  Fred Isaman      7326c07 NFSv4.1: pnfs filelayout driver write

pnfs-submit:
  Benny Halevy     34af0eb NFSv4.1: pnfs-submit-wave3: put_lseg_common should use list_del_init

pnfs:
  Benny Halevy     67e864c pnfs: fix missing unlock in nfs_client_return_layouts
  Benny Halevy     787d5ab pnfs: return bool status from nfs4_asynch_forget_layouts
  Benny Halevy     5564508 pnfs: return NFS4ERR_DELAY from layoutrecall while waiting on lsegs
  Benny Halevy     051d190 pnfs: fix cl_drain_notification indexing
  Benny Halevy     e60a67c pnfs: fix nfs4_asynch_forget_layouts accounting
  Benny Halevy     a86c7ac pnfs: improve nfs4_layoutget_done debug printouts
  Benny Halevy     a92a66b SQUASHME: pnfs: fix lock inversion in pnfs_layout_process
  Benny Halevy     b2005e6 SQUASHME: pnfs: revert layout recall/get/return synchronization
