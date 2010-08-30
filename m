Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:39598 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754098Ab0H3QCt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 12:02:49 -0400
Message-ID: <4C7BD626.2030906@panasas.com>
Date: Mon, 30 Aug 2010 19:02:46 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.35-2010-08-24
References: <4C111B9C.3080603@panasas.com> <4C1A4F0E.5070406@panasas.com> <4C455C58.8040300@panasas.com> <4C5ADF14.6090901@panasas.com> <4C5AE988.4050605@panasas.com>
In-Reply-To: <4C5AE988.4050605@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For the record, here's the list of patches that went in at pnfs-all-2.6.35-2010-08-24
since last 2.6.35 update (pnfs-all-2.6.35-2010-08-05)

nfsd-upstream:
  Andy Adamson     e205af4 nfsd: remove duplicate NFS4_STATEID_SIZE declaration

nfs-upstream:
  Fred Isaman      f130c18 nfs41: prevent exchange_id from sending server-only flag
  Benny Halevy     7c7966b SUNRPC: define xdr_decode_opaque_fixed
  Benny Halevy     05b7977 SUNRPC: don't shorten buflen twice in xdr_shrink_pagelen
  Benny Halevy     6a8f625 SUNRPC: clean up xdr_shrink_pagelen use of temporary pointer
  Benny Halevy     eaed6b0 SUNRPC: don't use the copy variable in nested block
  Benny Halevy     e206d65 SUNRPC: simplify xdr_shrink_pagelen use of "copy"
  Trond Myklebust  6e50a73 SUNRPC: Don't truncate tail data unnecessarily in xdr_shrink_pagelen

pnfs-submit: (revised patchset w/ updated sign-offs and naming convention)
  The pNFS Team    6b6970c pnfs_submit: pnfs and nfslayoutdriver kconfig
  The pNFS Team    5a723d9 pnfs_submit: introduce include/linux/nfs4_pnfs.h
  The pNFS Team    db1a56c pnfs_submit: introduce fs/nfs/pnfs.h
  The pNFS Team    dd0aa15 pnfs_submit: introduce fs/nfs/pnfs.c
  The pNFS Team    91162b2 pnfs_submit: register unregister pnfs module
  The pNFS Team    7e9c5a8 pnfs_submit: set and unset pnfs layoutdriver modules
  The pNFS Team    5b3b2ad pnfs_submit: generic pnfs deviceid cache
  The pNFS Team    0af7dd6 pnfs_submit: introduce nfs4layoutdriver module
  The pNFS Team    8ee80ad pnfs_submit: filelayout data server cache
  The pNFS Team    2d9fd56 pnfs_submit: filelayout deviceid cache
  The pNFS Team    70a6cdc pnfs_submit: generic getdeviceinfo
  The pNFS Team    8f3251d pnfs_submit: filelayout getdeviceinfo
  The pNFS Team    6782a46 pnfs-submit: change stateid to be a union
  The pNFS Team    7c22f02 pnfs_submit: layout header alloc,reference, and destroy
  The pNFS Team    091b28b pnfs_submit: filelayout alloc_layout and free_layout
  The pNFS Team    d9f2f32 pnfs_submit: layout segment alloc, reference, destroy
  The pNFS Team    3a64b06 pnfs_submit: layoutget
  The pNFS Team    1a33c42 pnfs_submit: layout helper functions
  The pNFS Team    01919e1 pnfs_submit: filelayout layout segment alloc and free
  The pNFS Team    aa87591 pnfs_submit: layoutcommit helper functions
  The pNFS Team    1335f72 pnfs_submit: layoutcommit
  The pNFS Team    df68077 pnfs_submit: layoutreturn helper functions
  The pNFS Team    6a50166 pnfs_submit: layoutreturn
  The pNFS Team    0b7ce58 pnfs_submit: add data server session to nfs4_setup_sequence
  The pNFS Team    a6fda6e pnfs_submit: update nfs4_async_handle_error for data server
  The pNFS Team    5c3a44e pnfs_submit: update state renewal for data servers
  Andy Adamson     6793140 pnfs_submit-pageio-helpers.patch
  Andy Adamson     d4eed6c pnfs_submit: associate layout segmennt with nfs_page
  The pNFS Team    2e0f058 pnfs_submit: filelayout policy operations
  The pNFS Team    409b04d pnfs_submit: filelayout i/o helpers
  The pNFS Team    b09d538 pnfs_submit: generic read
  The pNFS Team    9409d81 pnfs_submit: filelayout read
  The pNFS Team    e1df6dd pnfs_submit: generic write
  The pNFS Team    2ff0463 pnfs_submit: data server write with no getattr
  The pNFS Team    b9bd85c pnfs_submit: filelayout write
  The pNFS Team    05a2257 pnfs_submit: signal layoutdriver commit
  The pNFS Team    77c846f pnfs_submit: generic commit
  The pNFS Team    b8c5f02 pnfs_submit: data server commit with no getattr
  The pNFS Team    76a69f8 pnfs_submit: filelayout commit
  The pNFS Team    1a267aa pnfs_submit: cb_layoutrecall
  The pNFS Team    f5f4f98 pnfs_submit: increase NFS_MAX_FILE_IO_SIZE
  Benny Halevy     6606305 SQUASHME: pnfs-submit: rename layoutrecall related types

pnfs:
  Andy Adamson     73a08d2 SQUASHME pnfs_post_submit: direct i/o
  Andy Adamson     5cfa46f SQUASHME pnfs_post_submit: cb notify deviceid declarations
  Andy Adamson     aac7937 SQUASHME pnfs_submit: remove this unused code?

pnfs-obj:
  Benny Halevy     ecdcfc0 SQUASHME: pnfs-obj: apply types rename

pnfs-block:
  Benny Halevy     d50bd6d SQUASHME: pnfs-block: apply types rename

As mentioned in a different message this concludes pnfs-all-2.6.35
and it is now opened only for fixes.

The development branches and pnfs-all-latest in particular are now
rebased onto v2.6.36-rc3.

Benny

On 2010-08-05 19:40, Benny Halevy wrote:
> Hit Send too soon.
> Subject is correct now.
> 
> On Aug. 05, 2010, 18:56 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
>> pnfs-all-2.6.35-2010-08-05 is based over v2.6.35
>> I started with the pnfs-submit branch squashing but there's
>> a lot of work to be done there to tidy it up and prepare
>> a series for review.
>> Andy has graciously offered his help with this task. Thanks!
>>
>> At this point we'll hold off with new patches for submission
>> until we're done with squashing the series and then every
>> new SQUASHME patch sent must indicate which patch(es) it needs
>> to be squashed into so not to create a huge back log like we have today.
>>
>> Here's the list of patches that went into the latest linux-pnfs tree as of 2010-08-05
>> since last update pnfs-all-2.6.35-rc5-2010-07-20:
>>
>> pnfs-submit:
>>   Andy Adamson     83c4c44 SQUASHME pnfs-submit remove pnfs4_layout_reclaim
>>   Andy Adamson     67282c6 SQUASHME pnfs-submit destroy all layouts upon lease expiration
>>   Ricardo Labiaga  f20c76e SQUASHME: pnfs-submit: Use generic layout name to load layout modules
>>   Benny Halevy     fa73e39 SQUASHME: pnfs-submit: reduce nesting level in set_pnfs_layoutdriver
>>
>> pnfs-block:
>>   Jim Rees         b51aad4 pnfs-block: Add support for simple rpc pipefs
>>   Jim Rees         123741a pnfs-block: Remove device creation from kernel
>>
>>
>> http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree is updated
>> with the latest information.
>>
>> Note that Ricardo's "Use generic layout name to load layout modules"
>> patch renamed the nfslayoutdriver module to "nfs_layout_nfsv41_files"
>> so it can be loaded automagically by the kernel. The blocks and objects
>> modules should be renamed along the same lines (TODO).
>>
>> Benny
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
