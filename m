Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5034 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326Ab1A0UhR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jan 2011 15:37:17 -0500
Message-ID: <4D41D77B.2010605@panasas.com>
Date: Thu, 27 Jan 2011 22:37:15 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.37-2011-01-06
References: <4CD17FC4.6090906@panasas.com> <4CE1604E.1070902@panasas.com> <4CEBCDF1.4010705@panasas.com>
In-Reply-To: <4CEBCDF1.4010705@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The pnfs-all-2.6.37 branch, based on v2.6.37, is tagged as pnfs-all-2.6.37-2011-01-06

Cumulative patches can be generated from
git://linux-nfs.org/~bhalevy/linux-pnfs.git
using
git diff v2.6.37 pnfs-all-2.6.37-2011-01-06

Or, they can be downloaded from the wiki at:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

Latest patches that went in since pnfs-all-2.6.37-rc3-2010-11-23:

  Andy Adamson     8ec9cf0 NFS dont free shared socket on backchannel put xprt
  Andy Adamson     1a50e87 NFS implement v4.0 callback_ident
  Andy Adamson     d54419f NFS associate sessionid with callback connection
  Andy Adamson     e036acb NFS reference nfs_client across cb_compound processing
  Andy Adamson     75767b5 NFS RPC_AUTH_GSS unsupported on v4.1 back channel
  Andy Adamson     1e55cfb NFS add session back channel draining
  Andy Adamson     c0f97fa NFS only set bc_xprt upon success
  Andy Adamson     f69846b NFS fix the setting of exchange id flag
  Fred Isaman      419e6b8 pnfs-submit: wave2: rewrite validate_bitmap_values to obey spec
  Fred Isaman      a00d5cc pnfs-submit: wave2: NFS4ERR_RESOURCE is not a valid error for CB_LAYOUTRECALL
  Fred Isaman      8978415 pnfs-submit: wave2: check that partial LAYOUTGET return is ignored
  Fred Isaman      5d7c2c7 pnfs-submit: wave2: remove cl_layoutrecalls list
  Fred Isaman      6b90058 pnfs-submit: wave2: change plh_outstanding to atomic_t
  Fred Isaman      02731c2 pnfs-submit: wave2: change lseg->valid from bool to a bit flag
  Fred Isaman      d2a0ab1 pnfs-submit: wave2: Remove LAYOUTRETURN from return on close
  Fred Isaman      25180ca pnfs-submit: wave2: remove all LAYOUTRETURN code
  Fred Isaman      c23f64a pnfs-submit: wave2: Revert "pnfs_submit: update nfs4_async_handle_error for data server"
  Fred Isaman      70f4ea3 pnfs-submit: wave2: remove forgotten layoutreturn struct definitions
  Fred Isaman      b7ec707 pnfs-submit: wave2: Remove smp barrier in get_layout_hdr
  Fred Isaman      2d87a2c pnfs-submit: wave2: make put_layout_hdr have args consistent with related functions
  Fred Isaman      7264acc wave 2: restore removed comment in nfs4_evict_inode
  Fred Isaman      cfed8e0 wave 2: remove gratuitous changes to nfs4_layoutget_done
  Fred Isaman      233ca9a wave 2: remove pnfs_ld_layoutret_on_setattr()
  Fred Isaman      84446ae wave 2: share code between put_lseg and pnfs_free_lseg_list
  Fred Isaman      a851528 wave 2: remove notify_drained
  Fred Isaman      f38b63f wave 2: rename notify fields
  Fred Isaman      3f937e3 wave 2: remove trigger_flush
  Fred Isaman      99f81a6 wave 2: Fix outdated comment above _pnfs_return_layout
  Fred Isaman      c258f80 wave 2: remove unneeded include from pnfs.h
  Fred Isaman      362dc1a wave 2: remove unneeded includes from callback_proc.c
  Fred Isaman      94ee6f7 debug: add assert_spin_locked
  Fred Isaman      012a2c7 pnfs-submit: wave4: fix bug dealing with commit split between DS and MDS
  Fred Isaman      447d2e4 pnfs-submit: Turn off layoutcommits
  Benny Halevy     b53b08c Revert "pnfs-submit: wave2: remove forgotten layoutreturn struct definitions"
  Benny Halevy     1896997 Revert "pnfs-submit: Turn off layoutcommits"
  Benny Halevy     5d7a3fc Revert "pnfs-submit: wave2: remove all LAYOUTRETURN code"
  Benny Halevy     a534dcf Revert "pnfs-submit: wave2: Remove LAYOUTRETURN from return on close"
  Benny Halevy     3c5e897 FIXME: roc should return layout on last close
  Benny Halevy     751b783 Revert "pnfs-submit: wave2: remove cl_layoutrecalls list"
  Benny Halevy     ae5ccc3 Revert "pnfs-submit: wave2: Pull out all recall initiated LAYOUTRETURNS"
  Benny Halevy     98dba28 Revert "pnfs-submit: wave2: Don't wait in layoutget"
  Benny Halevy     bd49095 Revert "pnfs-submit: wave2: check that partial LAYOUTGET return is ignored"
  Benny Halevy     7893f29 SQUASHME: pnfs-obj: fixup layoutcommit methods args
  Benny Halevy     7f5ffb4 SQUASHME: pnfs-block: fixup layoutcommit methods args
