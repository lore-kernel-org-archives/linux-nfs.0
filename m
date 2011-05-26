Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:26437 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757996Ab1EZQOW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 12:14:22 -0400
Message-ID: <4DDE7C59.2090205@panasas.com>
Date: Thu, 26 May 2011 19:14:17 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCHSET v8 0/32] pnfs for 2.6.40
References: <4DDD7392.6040505@panasas.com> <4DDE6A6F.3080303@panasas.com>
In-Reply-To: <4DDE6A6F.3080303@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-26 17:57, Boaz Harrosh wrote:
> On 05/26/2011 12:24 AM, Benny Halevy wrote:
>> Trond,
>>
>> This patchset includes the latest fixes from Boaz and it is ready
>> in my opinion for linux-next.
>>
> 
> Benny you have dropped a lot of my fixes. What's going on? You will need a V9.
> 
> I'll resend you SQUASHMEs each as reply to the patch that needs fixing.
> (Again)

Thanks.  My apologies.
I'm really not sure how that happened.
Probably a pilot error on my side when doing the git fu

Benny

> 
> Boaz
> 
>> Last 5 patches include the changes we discussed for pg_test and
>> their use by pnfs-obj, please review carefully.
>>
>> Note that I skipped v7.  It was pushed up to the git tree but no patches were sent.
>>
>> I released the series to git://linux-nfs.org/~bhalevy/linux-pnfs.git pnfs-submit
>> under this tag: pnfs-for-2.6.40-v8-2011-05-25
>>
>> Rebased on top of it are the pnfs-obj, pnfs, pnfsd-all, pnfsd-lexp-all,
>> and pnfs-exofs-all branches, marked with tag pnfs-exofs-all-2.6.39-2011-05-25
>>
>> Changes in v8: (Benny)
>> * removed EXPORT_SYMBOL_GPL from nfs4_deviceid_purge_client
>> * split "NFSv4.1: use layout driver in global device cache"
>> * squashed "Bug in new global-device-cache code"
>> * squashed "BUG in _deviceid_purge_client"
>> * squashed "layout_driver MUST set free_deviceid_node if using dev-cache"
>> * committed "layout_driver MUST set free_deviceid_node if using dev-cache"
>> * squashed "pnfs_osd_xdr.h Remove server definitions"
>>   - updated commit message
>> * squashed "xdr_cli: Wrong type in comments"
>> * squashed "objio alloc/free lseg Bugs fixes"
>> * squashed "use layout driver in global device cache"
>> * squashed "Bugs in new global-device-cache code"
>> * squashed "objlayout wants to cache devices until unmount"
>> * squashed "Fall out from: non-rpc layout drivers"
>> * squashed "objio read/write patch: Bugs fixes"
>> * fixed NULL deref in _pnfs_return_layout
>> * removed "reclaim" member of nfs4_layoutreturn_args
>> * removed "extern" from function definitions
>>
>> * committed "NFSv4.1: unify pnfs_pageio_init functions"
>> * committed "NFSv4.1: change pg_test return type to bool"
>> * committed "NFSv4.1: use pnfs_generic_pg_test directly by layout driver"
>> * committed "NFSv4.1: define nfs_generic_pg_test"
>> * committed "pnfs-obj: pg_test check for max_io_size"
>>
>> Changes in v6: (Benny)
>> * squashed all SQUASHMEs
>> * reverted "SQUASHME: initialize data->task on the non-rpc io done
>> success paths"
>> * reverted "per mount layout driver private data"
>> * reverted "pnfs: set/unset layoutdriver"
>> * applied (in reverse) "SQUASHME: pnfs-obj: Important fallout from the
>> last rebase"
>>
>> Changes in v5: (Benny)
>> * use struct nfs_client to qualify deviceid
>> * make device cache global
>> * use be32 res in nfs4_callback_devicenotify
>> * use gfp_flags
>> * xdr_init_decode_pages
>> * fix layout stateid used for layoutreturn args
>> * commit message for layoutret_on_setattr
>> * use global deviceid cache for pnfs-obj
>>   - revert per-mount hook and related {.un}set_layoutdriver methods
>> * use layout driver in global device cache
>>
>> changes in v4: (Boaz)
>> * See the long SQUASHME patchset I sent yesterday for all the changes.
>>   titled: [PATCHSET 00/13] SQUASHME pnfs-obj: Lots of changes addressing
>> comments by Trond and Benny
>> * I have united all 3 raid-engine read/write patches to a single patch
>> * I've united the two error-reporting and error-encoding into one patch
>> * Some checkpatch love
>> * small cleanups here and there.
>> (I'll send a diff as reply to this mail)
>>
>> changes in v3: (Benny)
>> * removed direct i/o patch
>> * align layoutget requests on page boundaries
>> * fix lseg ordering
>> * cleanup pnfs_insert_lseg
>> * pnfs: clean up pnfs_find_lseg lseg arg
>> * remove unnecessary FIXME
>>
>> changes in v2:
>> * fix CB_NOTIFY_DEVICEID
>> * call pnfs_return_layout right before pnfs_destroy_layout
>> * remove assert_spin_locked from pnfs_clear_lseg_list
>> * remove wait parameter from the layoutreturn path.
>> * remove return_type field from nfs4_layoutreturn_args
>> * remove range from nfs4_layoutreturn_args
>> * no need to send layoutcommit from _pnfs_return_layout
>> * don't wait on sync layoutreturn
>> * get rid of PNFS_USE_RPC_CODE
>> * get rid of __nfs4_write_done_cb
>> * get rid of ds_[rw]size
>> * rename pnfs_{read,write}_done -> pnfs_ld_{read,write}_done
>> * reorganize and reorder the pnfs-obj patchset to expose dependencies
>>   and separate api changes
>> * some cleaning up of the pnfs-obj patches
>> * add xdr space reservation for pnfs-obj opaque layoutreturn
>>   and layoutcommit payloads
>>
>> List of patches:
>>
>> generic:
>> [PATCH v8 01/32] NFSv4.1: fix typo in filelayout_check_layout
>> [PATCH v8 02/32] NFSv4.1: use struct nfs_client to qualify deviceid
>> [PATCH v8 03/32] pnfs: resolve header dependency in pnfs.h
>> [PATCH v8 04/32] NFSv4.1: make deviceid cache global
>> [PATCH v8 05/32] NFSv4.1: purge deviceid cache on nfs_free_client
>> [PATCH v8 06/32] pnfs: CB_NOTIFY_DEVICEID
>> [PATCH v8 07/32] NFSv4.1: use layout driver in global device cache
>> [PATCH v8 08/32] SUNRPC: introduce xdr_init_decode_pages
>> [PATCH v8 09/32] pnfs: Use byte-range for layoutget
>> [PATCH v8 10/32] pnfs: align layoutget requests on page boundaries
>> [PATCH v8 11/32] pnfs: Use byte-range for cb_layoutrecall
>> [PATCH v8 12/32] pnfs: client stats
>>
>> Basic ld driver and some std definitions:
>> [PATCH v8 13/32] pnfs-obj: objlayoutdriver module skeleton
>> [PATCH v8 14/32] pnfs-obj: pnfs_osd XDR definitions
>> [PATCH v8 15/32] pnfs-obj: pnfs_osd XDR client implementation
>>
>> layoutget:
>> [PATCH v8 16/32] pnfs-obj: decode layout, alloc/free lseg
>>
>> getdeviceinfo:
>> [PATCH v8 17/32] pnfs-obj: objio_osd device information retrieval and caching
>>
>> read/write:
>> [PATCH v8 18/32] pnfs: alloc and free layout_hdr layoutdriver methods
>> [PATCH v8 19/32] pnfs-obj: define per-inode private structure
>> [PATCH v8 20/32] pnfs: support for non-rpc layout drivers
>> [PATCH v8 21/32] pnfs-obj: osd raid engine read/write implementation
>>
>> layoutreturn:
>> [PATCH v8 22/32] pnfs: layoutreturn
>> [PATCH v8 23/32] pnfs: layoutret_on_setattr
>> [PATCH v8 24/32] pnfs: encode_layoutreturn
>> [PATCH v8 25/32] pnfs-obj: report errors and .encode_layoutreturn Implementation.
>>
>> layoutcommit:
>> [PATCH v8 26/32] pnfs: encode_layoutcommit
>> [PATCH v8 27/32] pnfs-obj: objlayout_encode_layoutcommit implementation
>>
>> pg-test:
>> [PATCH v8 28/32] NFSv4.1: unify pnfs_pageio_init functions
>> [PATCH v8 29/32] NFSv4.1: change pg_test return type to bool
>> [PATCH v8 30/32] NFSv4.1: use pnfs_generic_pg_test directly by layout driver
>> [PATCH v8 31/32] NFSv4.1: define nfs_generic_pg_test
>> [PATCH v8 32/32] pnfs-obj: pg_test check for max_io_size
>>
> 

