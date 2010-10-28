Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og107.obsmtp.com ([64.18.0.184]:47818 "HELO
	exprod5og107.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753003Ab0J1Ngp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 09:36:45 -0400
Message-ID: <4CC97C6A.80200@panasas.com>
Date: Thu, 28 Oct 2010 15:36:42 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.36-2010-10-28
References: <4C7BDD8C.40509@panasas.com> <4CA31DC3.8070300@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This version is based on v2.6.36

Cumulative patches can be generated from
git://linux-nfs.org/~bhalevy/linux-pnfs.git
using
git diff v2.6.36-rc6 pnfs-all-2.6.36-2010-10-28

Or, they can be downloaded from the wiki at:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

Note that I'm in the process of rebasing the whole tree onto linux-2.6/master
(to be v2.6.37-rc1) and it's taking some time due to conflicts and significant
changes both on the client and on the server side.
I'll send an announcement when the 2.6.37 tree is ready to go.

In the meanwhile pnfs-all-latest == pnfs-all-2.6.36 but the rest of the branches
were not updated.

Latest patches that went in since pnfs-all-2.6.36-rc6-2010-09-29:

upstream:
  Jan Kara         db02183 bdi: Initialize inode->i_mapping.backing_dev_info to sb->s_bdi

nfsd-upstream:
  Benny Halevy     8dcd082 nfsd4: adjust buflen for encoded attrs bitmap based on actual bitmap length

pnfsd-files:
  Benny Halevy     c5a841c SQUASHME: pnfsd-files: update layout stateid properly

pnfsd:
  Benny Halevy     12e7883 SQUASHME: pnfsd: FATTR4_WORD2_LAYOUT_BLKSIZE is supported only under CONFIG_PNFSD

spnfs:
  Benny Halevy     e129405 SQUASHME: pnfsd: factor out pnfsd check_export crap out of check_export

pnfs-submit-layoutget:
  Bian Naimeng     2e16f9a SQUASHME: pnfs-submit: specify the layout type before initialize mountpoint
  Fred Isaman      8781381 SQUASHME: pnfs-devinfo-submit: misc small fixes
  Fred Isaman      07c9c9a SQUASHME: pnfs-devinfo-submit: Use only asynch error handler for LAYOUTGET
  Fred Isaman      c17dfaa SQUASHME: pnfs-submit: Don't check exchange flags unless using v4.1 try 2

pnfs-submit:
  Fred Isaman      43db3d4 SQUASHME: pnfs-devinfo-submit: fix comments in pnfs_layout*_release
  Benny Halevy     57a08c9 SQUASHME: pnfs-submit: handle NULL lseg in filelayout_get_stripesize
  Fred Isaman      2a90270 SQUASHME: pnfs-submit: misc small rebase fixes
  Fred Isaman      e141824 SQUASHME: pnfs_submit: remove inlines from *.c files
  Fred Isaman      f60c230 nfs: change end of line commas to semicolons
  Fred Isaman      625834c SQUASHME: pnfs_submit: Only use asynch error handler for LAYOUTCOMMIT
  Fred Isaman      9bc5857 SQUASHME: pnfs_submit: only use asynch error handler for LAYOUTRETURN
  Benny Halevy     67f8ba9 SQUASHME: pnfs-submit: init pg_lseg to NULL when !CONFIG_NFS_V4_1
  Fred Isaman      a262d18 pnfs_submit: Remove nonsensical check
  Fred Isaman      0561b05 pnfs_submit: Only update stateid if it is more recent than current
  Fred Isaman      48f0c0f pnfs_submit: simplify nfs4_callback_layoutrecall
  Fred Isaman      dc08d69 pnfs_submit: Fix clp refcounting in layout recalls
  Fred Isaman      df7c832 pnfs_submit: Remove the get_stripesize function
  Andy Adamson     4e97d26 pnfs_submit: move layout segment valid test
  Andy Adamson     a40a6ae pnfs_submit: fix deadlock in pnfs_clear_lseg_list
  Andy Adamson     5155659 pnfs_submit: enforce requested DS only pNFS role
  Benny Halevy     1664201 SQUASHME: pnfs-submit: fail init_clientid if a DS is not really a DS
  Benny Halevy     424dea1 SQUASHME: pnfs-submit: do not get_lseg in pnfs_has_layout
  Benny Halevy     86dc18d SQUASHME: pnfs: get_lseg in nfs4_layoutget_prepare rather than in pnfs_has_layout
  Fred Isaman      ba39b5a pnfs_submit: Restore forgetful mode io draining
  Andy Adamson     6328fa0 pnfs_submit: fix layoutreturn layout stateid processing
  Andy Adamson     767d1da pnfs_submit: replace pnfs_layoutget_release with put_layout_hdr
  Benny Halevy     0c407c7 pnfs: do not change layout stateid when dropping layouts.

pnfs:
  Benny Halevy     c249cff SQUASHME: pnfs: loga_minlength must not be greater than loga_length
  Benny Halevy     2ec6978 pnfs: mark page with error in readpage_async_filler when crossing lsegs
  Fred Isaman      23b3e65 SQUASHME: pnfs: filelayout: call print_ds under ifdebug(FACILITY)

pnfs-obj:
  Benny Halevy     456ac6e SQUASHME: pnfs-obj: deprecate get_stripesize

pnfs-block:
  Steve Dickson    97127f0 SQUASHME: pnfsblock: compile error in blocklayout code
  Benny Halevy     81197a6 SQUASHME: pnfs-block: deprecate get_stripesize
  Jim Rees         3bf1cd1 move include lines out of include file

