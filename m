Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57074 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757895Ab0KOQbM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Nov 2010 11:31:12 -0500
Message-ID: <4CE1604E.1070902@panasas.com>
Date: Mon, 15 Nov 2010 18:31:10 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.37-rc1-2010-11-15
References: <4CD17FC4.6090906@panasas.com>
In-Reply-To: <4CD17FC4.6090906@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The updated tree as of today includes Fred and Andy's latest
patchsets (listed in details below) and the reset rebased on top of it
and fixed up to used the new {setup,cleanup,encode}_layout{commit,return}
layout driver API.

Note that the tree is based off of Linus' current master branch,
0143832cc96d0bf78486297aad5c8fb2c2ead02a, and not on v2.6.37-rc1,
to include some UML goodies to be in v2.6.37-rc2.

I also swapped the order in the -all branch sequence and put the server
pnfs branches on top of the client's to reflect the actual submission order.

The most useful branches are
pnfs-submit, pnfs	client only code.
pnfsd			server only code
pnfsd-all		client + server, files layout only
pnfs-all-latest		everything, serialized.

Cumulative patches can be generated from
git://linux-nfs.org/~bhalevy/linux-pnfs.git
using
git diff 0143832cc96d0bf78486297aad5c8fb2c2ead02a pnfs-all-2.6.37-rc1-2010-11-15

Or, they can be downloaded from the wiki at:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

Latest patches that went in since pnfs-all-2.6.37-rc1-2010-11-03:

pnfs-submit:
  Fred Isaman      9d324dc pnfs-submit: remove RPC_ASSASSINATED(task) checks
  Fred Isaman      2cd4c0d pnfs-submit: remove unnecessary field lgp->status
  Fred Isaman      3d82dc6 pnfs-submit: layoutreturn's rpc_call_op functions need to handle bulk returns
  Fred Isaman      c822486 pnfs-submit: argument to should_free_lseg changed from lseg to range
  Fred Isaman      9c998fd pnfs-submit: change layout state seqlock to a spinlock
  Andy Adamson     8273821 NFSv4.1: Callback share session between ops
  Benny Halevy     6093e91 SQUASHME: pnfs-submit: fixups for nfsv4.1 callbacks
  Fred Isaman      91d40b5 SQUASHME: allow cb_sequence changes to compile without v4.1
  Fred Isaman      2e175be pnfs-submit: change pnfs_layout_segment refcounting from kref to atomic_t
  Fred Isaman      140df06 pnfs-submit: Have LAYOUTGETS wait when lo->plh_block_lgets is set
  Fred Isaman      1843f9a pnfs-submit: remove _pnfs_can_return_lseg call from pnfs_clear_lseg_list
  Fred Isaman      14c8957 pnfs_submit: nfs4_layoutreturn_release should not reference results
  Fred Isaman      66a8ede pnfs-submit: reorganize struct cb_layoutrecallargs
  Fred Isaman      fbb96a5 pnfs-submit: rename lo->state to lo->plh_flags
  Fred Isaman      1a8937d pnfs-submit: change pnfs_layout_hdr refcount to atomic_t
  Fred Isaman      c3deb42 pnfs-submit: rewrite of layout state handling and cb_layoutrecall
  Fred Isaman      80e8d48 pnfs-submit: increase number of outstanding CB_LAYOUTRECALLS we can handle
  Andy Adamson     904c8f9 pnfs-submit: roc add layoutreturn op to close compound
  Andy Adamson     4fda730 pnfs-submit refactor layoutcommit xdr structures
  Andy Adamson     204d330 pnfs-submit refactor pnfs_layoutcommit_setup
  Andy Adamson     cdacedd pnfs_submit: roc add layoutcommit op to close compound
  Fred Isaman      9f2a617 SQUASHME: make roc patches compile without v4.1
  Andy Adamson     ef8d437 pnfs-submit: set back channel highest slot used
  Andy Adamson     61f6466 pnfs-submit: add back channel draining
  Benny Halevy     9225185 SQUASHME: pnfs-submit: highest backchannel slot used for !CONFIG_NFS_V4_1
  Benny Halevy     b4b7f57 SQUASHME: pnfs-submit: encode layoutreturn on close before close
  Benny Halevy     93b7bc6 pnfs-submit: handle NFS4ERR_DELEG_REVOKED for LAYOUTRETURN

pnfs-obj-all:
  Boaz Harrosh     2f7be19 SQUASHME: pnfs-obj: bug in last conversion to embedded pnfs_layout_segment
  Benny Halevy     872a119 SQUASHME: pnfs-obj: fixup encode_layoutcommit arguments

pnfs-block-all:
  Benny Halevy     0ed6d4a SQUASHME: pnfs-block: fixup setup_layoutcommit arguments
  Benny Halevy     b1c1fa3 SQUASHME: pnfs-block: fixup cleanup_layoutcommit arguments
  Benny Halevy     cda0c74 SQUASHME: pnfs-block: fixup encode_layoutcommit arguments

The new tree structure is as follows:

master (v2.6.37-rc1+)
	upstream
		nfsd-upstream
			nfsd41-all
				nfs-upstream
					nfs41-all
						pnfsd-files
							pnfsd
								spnfs
									spnfs-block
								pnfsd-lexp
						pnfs-submit
							pnfs
								pnfs-block
								pnfsd-all
									pnfs-obj-all
										pnfs-exofs-all
											pnfs-block-all
												pnfsd-lexp-all
													spnfs-all
														spnfs-block-all
															pnfs-all-latest
