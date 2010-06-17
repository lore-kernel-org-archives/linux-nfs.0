Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:61172 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756746Ab0FQQg2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 12:36:28 -0400
Received: by qyk1 with SMTP id 1so1405053qyk.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 09:36:26 -0700 (PDT)
Message-ID: <4C1A4F0E.5070406@panasas.com>
Date: Thu, 17 Jun 2010 12:36:30 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.35-rc3-2010-06-17
References: <4C111B9C.3080603@panasas.com>
In-Reply-To: <4C111B9C.3080603@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here's the list of patches that went into the latest linux-pnfs tree as of 2010-06-17
since last update (pnfs-all-2.6.35-rc2-2010-06-10):

Note that this include Trond's nfs41 patches that I pulled from
his nfs-for-2.6.36 branch.

nfs-upstream:
Andy Adamson (1):
      nfs4 use mandatory attribute file type in nfs4_get_root

Trond Myklebust (15):
      NFSv41: Fix a memory leak in nfs41_proc_async_sequence()
      NFSv4.1: Clean up nfs4_setup_sequence
      NFSv4.1: Simplify nfs41_sequence_done()
      NFSv4: Kill nfs4_async_handle_error() abuses by NFSv4.1
      NFSv4.1: Merge the nfs41_proc_async_sequence() and nfs4_proc_sequence()
      NFSv4.1: Make nfs4_setup_sequence take a nfs_server argument
      NFSv41: Further cleanup for nfs4_sequence_done
      NFSv41: Don't store session state in the nfs_client->cl_state
      NFSv41: Clean up the NFSv4.1 minor version specific operations
      NFSv41: Convert the various reboot recovery ops etc to minor version ops
      NFSv41: Fix nfs_async_inode_return_delegation() ugliness
      NFSv41: Deprecate nfs_client->cl_minorversion
      NFSv41: Clean up exclusive create
      NFSv41: Cleanup for nfs4_alloc_session.
      NFSv4.1: There is no need to init the session more than once...

nfs41-all:
Benny Halevy (1):
      SQUASHME: DEVONLY: nfs41: improve nfs41_sequence_done debug message on NFS4ERR_DELAY

Boaz Harrosh (1):
      UMLFIX: Fc13 uml brokenness

John Fastabend (1):
      net: fix deliver_no_wcard regression on loopback device

pnfs-submit:
Andy Adamson (5):
      pnfs-submit: add data server session to nfs4_setup_sequence
      SQUASHME pnfs-submit: update to new nfs41_sequence_call_done
      pnfs-submit: add ds session to nfs4_async_handle_error
      SQUASHME pnfs-submit: export nfs_write_prepare
      pnfs: trim write count to wsize when retrying via MDS

Benny Halevy (19):
      SQUASHME: pnfs-submit: destroy layout rather than return on state reclaim
      SQUASHME: pnfs-submit: handle NULL in pnfs_destroy_layout
      SQUASHME: pnfs-submit: delete unused nfs_validate_delegation_stateid
      SQUASHME: pnfs-submit: merge pnfs4_proc_setattr into nfs4_proc_setattr
      SQUASHME: pnfs4_read_done status variable is unused
      SQUASHME: pnfs-submit: optionally pass nfs_client to nfs4_async_handle_error
      SQUASHME: pnfs-submit: merge pnfs4_read_done into nfs4_read_done - part 2
      SQUASHME: pnfs-submit: merge pnfs4_read_done into nfs4_read_done - part 3
      SQUASHME: pnfs-submit: get rid of pnfs4_read_done
      SQUASHME: pnfs-submit: merge pnfs4_write_done into nfs4_write_done - part 1
      SQUASHME: pnfs-submit: merge pnfs4_write_done into nfs4_write_done - part 3
      SQUASHME: pnfs-submit: merge pnfs4_write_done into nfs4_write_done - part 4
      SQUASHME: pnfs-submit: get rid of pnfs4_write_done
      SQUASHME: pnfs-submit: merge pnfs4_commit_done into nfs4_commit_done - part 2
      SQUASHME: pnfs-submit: merge pnfs4_commit_done into nfs4_commit_done - part 3
      SQUASHME: pnfs-submit: get rid of pnfs4_commit_done
      SQUASHME: pnfs-submit: merge pnfs4_proc_write_setup into nfs4_proc_write_setup
      SQUASHME: pnfs-submit: merge pnfs4_proc_commit_setup into nfs4_proc_commit_setup
      SQUASHME: pnfs-submit: get rid of pnfs_v4_clientops

Fred Isaman (10):
      pnfs-submit: Revert "pnfs: pnfs_redirty_request"
      pnfs-submit: Reorder arguments to pnfs_update_layout
      SQUASHME: pnfs-submit: avoid NULL dereference in filelayout_commit dprintk
      pnfs-submit: filelayout: Stop using pnfs_call_done and friends
      pnfs-submit: Remove checks for non-rpc drivers
      pnfs-submit: Remove pnfs_call_done and friends
      pnfs-submit: Remove pnfs_error
      SQUASHME: pnfs-submit: test for sending LAYOUTRETURN was reversed
      SQUASHME: pnfs-submit: Remove lo_lock and use i_lock instead
      pnfs-submit: filelayout: Support dense layouts

pnfs:
Benny Halevy (3):
      Revert "pnfs-submit: Remove pnfs_error"
      Revert "pnfs-submit: Remove pnfs_call_done and friends"
      Revert "pnfs-submit: Remove checks for non-rpc drivers"

pnfs-block:
Fred Isaman (8):
      HACK: propagate fsdata into nfs_writepage_setup
      SQUASHME: pnfs: export get_lseg and put_lseg
      SQUASHME: pnfsblock: write_begin adjust for removed fields
      SQUASHME: pnfsblock: write_end adjust for removed ok_to_use_pnfs
      SQUASHME: pnfsblock: write_end_cleanup adjust for removed ok_to_use_pnfs
      SQUASHME: pnfsblock: bl_write_pagelist support functions adjust for missing PG_USE_PNFS
      SQUASHME: pnfsblock: bl_write_pagelist adjust for missing PG_USE_PNFS
      pnfs: Revert "pnfs_post_submit: Restore "pnfs: pnfs_do_flush" part 2"

Zhang Jingwang (1):
      SQAUSHME: blocklayoutdriver: NULL pointer reference when committing too many extents

pnfsd-files:
Andy Adamson (1):
      SQUASHME: pnfsd: fix dlm device naming

Eric Anderle (1):
      pnfsd: Add IP address validation to nfsd4_set_pnfs_dlm_device()

pnfsd:
Benny Halevy (1):
      SQUASHME: pnfsd: fix error handling for s_pnfs_op->get_device_info
