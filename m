Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33180 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752780Ab1KOEMA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2011 23:12:00 -0500
Received: by bke11 with SMTP id 11so6677120bke.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2011 20:11:59 -0800 (PST)
Message-ID: <4EC1E68B.60405@tonian.com>
Date: Tue, 15 Nov 2011 06:11:55 +0200
From: Benny Halevy <benny@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: pnfs git tree status pnfs-all-3.1-2011-11-14 pnfs-all-3.2-rc1-2011-11-14
References: <4EC13EEA.3030404@tonian.com> <4EC16E3A.9040405@panasas.com>
In-Reply-To: <4EC16E3A.9040405@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-14 21:38, Boaz Harrosh wrote:
> On 11/14/2011 08:16 AM, Benny Halevy wrote:
>> I merged the following patches into pnfs-all-3.1-2011-11-14
>> and rebased the tree onto v3.2-rc1 as pnfs-all-3.2-rc1-2011-11-14.
>>
>> pnfs-block:
>>   Peng Tao         e5b35df pnfsblock: cleanup bl_mark_sectors_init
>>   Peng Tao         60d5135 pnfsblock: move find lock page logic out of bl_write_pagelist
>>   Peng Tao         ab0c07d pnfsblock: set read/write tk_status to pnfs_error
>>   Peng Tao         85e8c84 pnfsblock: remove rpc_call_ops from struct parallel_io
>>   Peng Tao         7c93c37 pnfsblock: clean up _add_entry
>>   Peng Tao         ec11faf pnfsblock: alloc short extent before submit bio
>>
>> pnfsd:
>>   Boaz Harrosh     5e57e48 SQUASHME: pnfsd: Don't call fs_layout_return on a none-file
>>
> 
> What happened to the PNFSD dbg Channel. Was that submitted before?
> 
> Boaz 

It's there,  I probably screwed the base date for my git-log-since-tree-oneline
script.

Anyhow, here is the list of patches that are still in the major branches
since pnfs-all-3.0-2011-08-10:
(according to the script :)

ore-devel:
  Boaz Harrosh     b133b98 RFC: do_xor_speed Broken on UML do to jiffies

pnfs-block:
  Benny Halevy     9158412 pnfs: clean up initiate_file_draining layout lookup
  Peng Tao         e5b35df pnfsblock: cleanup bl_mark_sectors_init
  Peng Tao         657c2f4 pnfsblock: acquire im_lock in _preload_range
  Peng Tao         60d5135 pnfsblock: move find lock page logic out of bl_write_pagelist
  Peng Tao         ab0c07d pnfsblock: set read/write tk_status to pnfs_error
  Peng Tao         85e8c84 pnfsblock: remove rpc_call_ops from struct parallel_io
  Peng Tao         7c93c37 pnfsblock: clean up _add_entry
  Peng Tao         ec11faf pnfsblock: alloc short extent before submit bio

nfsd-upstream:
  Benny Halevy     546e4fa nfsd4: share_access_to_flags should consider only nfs4.x share_access flags
  Benny Halevy     e8e8efb nfsd4: split out share_access want and signel flags while decoding
  Benny Halevy     89be556 nfsd4: implement NFS4_SHARE_WANT_NO_DELEG, NFS4_OPEN_DELEGATE_NONE_EXT, why_no_deleg
  Benny Halevy     7fa5486 nfsd4: DEBUG: XDR_ERROR()

pnfsd:
  Benny Halevy     f89ea60 pnfsd: layout state allocation
  Benny Halevy     7b50379 SQUASHME: update_layout_stateid_locked
  Benny Halevy     bb72dee pnfsd: layout recall layout state
  Benny Halevy     2a9eb41 SQUASHME: pnfsd: initialize fi_layout_states
  Benny Halevy     f5f8a59 SQUASHME: pnfsd: layout recall statid processing
  Boaz Harrosh     5111e3f SQUASHME: pnfsd: Compile warning in pnfs-all-3.1-2011-10-31-1
  Boaz Harrosh     d7e7bec Subject: [PATCH] SQUASHME: pnfsd: nfs4pnfsd.c should dprint under NFSDDBG_PNFS
  Boaz Harrosh     5e57e48 SQUASHME: pnfsd: Don't call fs_layout_return on a none-file

pnfsd-exofs:
  Boaz Harrosh     cb40981 SQUASHME: pnfsd-exofs: Fix export of only one group layout
  Boaz Harrosh     a076d46 SQUASHME: pnfsd-exofs: Type & Name of the devices array changed
  Benny Halevy     ef4e804 SQUASHME: pnfsd-exofs: missing arg to ore_calc_stripe_info call

spnfs:
  Benny Halevy     141caa1 SQUASHME: spnfs: use struct path in vfs_path_lookup as of v3.0

spnfs-block:
  Benny Halevy     27f1cb8 SQUASHME: spnfs-block: use struct path in vfs_path_lookup as of v3.0
  Benny Halevy     400ab8f SQUASHME: spnfs-block: fix oops in device_slice
  Benny Halevy     bd6bc0a SQUASHME: spnfs-block: add dprints for device_slice
