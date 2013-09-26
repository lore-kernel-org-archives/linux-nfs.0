Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f180.google.com ([209.85.213.180]:38931 "EHLO
	mail-ye0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834Ab3IZUG3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 16:06:29 -0400
Received: by mail-ye0-f180.google.com with SMTP id m15so556175yen.25
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 13:06:28 -0700 (PDT)
Message-ID: <524493C2.2080509@primarydata.com>
Date: Thu, 26 Sep 2013 16:06:26 -0400
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: NFS list <linux-nfs@vger.kernel.org>, Lev Solomonov <solo@primarydata.com>,
        Idan Kedar <idank@primarydata.com>,
        Nadav Shemer <nadav@primarydata.com>
Subject: Re: [PATCH RFC v0 0/49] pnfsd-dlm
References: <52447EA0.7070004@primarydata.com> <20130926194454.GA24894@pad.fieldses.org>
In-Reply-To: <20130926194454.GA24894@pad.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-09-26 15:44, J. Bruce Fields wrote:
> On Thu, Sep 26, 2013 at 02:36:16PM -0400, Benny Halevy wrote:
>> The following patchset implements an extension to nfsd
>> providing a complete minimal pnfs server exporting
>> DLM-based clustered file systems such as GFS2 or OCFS2.
>>
>> The pNFS operations that are implemented are
>> GETDEVICELIST and GETDEVICEINFO,
>> LAYOUTGET and LAYOUTRETURN.
>>
>> The server does the bookkeeping of the outstanding layout
>> state in response to layout get and return.
>>
>> Also, the implementation cleans up the client layout state
>> opon client expiry and on CLOSE when the return_on_close
>> flag is set on the LAYOUTGET response.  The latter is the
>> default behavior until layout recalls are implemented
>> with which the server can reclaim its resources in case
>> the client holds layout state post closing files.
>>
>> The patchset is based on v3.12-rc2 and it's available also online here:
>> git://linux-nfs.org/~bhalevy/linux-pnfs.git pnfsd-dlm-3.12-rc2-2013-09-26
> 
> Is there any userland support code required?

There is a small change to exportfs and mountd to provide for the pnfs export option:
http://git.linux-nfs.org/?p=bhalevy/pnfs-nfs-utils.git;a=commitdiff;h=b3632132ed8f3682ee5e8cc979cd7129b8ab4d4a

> 
> What's the quickest way to get a test setup--is
> 
> 	http://wiki.linux-nfs.org/wiki/index.php/PNFS_Setup_Instructions
> 
> accurate?

It should be, though I admit I haven't tested these instructions in a long while.

Benny

> 
> --b.
> 
>>
>> Benny
>>
>> General infrastructure:
>> [PATCH RFC v0 01/49] pnfsd: Define CONFIG_PNFSD
>> [PATCH RFC v0 02/49] pnfsd: define NFSDDBG_PNFS
>> [PATCH RFC v0 03/49] pnfsd: return pnfs flags on exchange_id
>> [PATCH RFC v0 04/49] pnfsd: don't set up back channel on create_session for ds
>> [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
>> [PATCH RFC v0 06/49] pnfsd: define pnfs_export_operations
>> [PATCH RFC v0 07/49] pnfsd: add pnfs export option
>> [PATCH RFC v0 08/49] pnfsd: layout verify
>> [PATCH RFC v0 09/49] pnfsd: initial stub
>>
>> Device ops:
>> [PATCH RFC v0 10/49] pnfsd: use sbid hash table to map super_blocks to devid major identifiers
>> [PATCH RFC v0 11/49] NFSD: introduce exp_xdr.h
>> [PATCH RFC v0 12/49] pnfsd: get device list/info
>> [PATCH RFC v0 13/49] pnfsd: filelayout: get device list/info
>> [PATCH RFC v0 14/49] pnfsd: provide helper for xdr encoding of deviceid
>> [PATCH RFC v0 15/49] pnfsd: add helper functions for identifying DS filehandles
>> [PATCH RFC v0 16/49] pnfsd: accept all ds stateids
>>
>> layout get:
>> [PATCH RFC v0 17/49] DEBUG: nfsd: more client_lock asserts
>> [PATCH RFC v0 18/49] pnfsd: nfs4_assert_state_locked
>> [PATCH RFC v0 19/49] pnfsd: layout get
>> [PATCH RFC v0 20/49] pnfsd: filelayout: layout encoding
>>
>> layout state handling for layout get:
>> [PATCH RFC v0 21/49] nfsd: no need to unhash_stid before free
>> [PATCH RFC v0 22/49] nfsd: cleanup free_stid
>> [PATCH RFC v0 23/49] pnfsd: layout state allocation
>> [PATCH RFC v0 24/49] pnfsd: process the layout stateid
>> [PATCH RFC v0 25/49] pnfsd: layout state per client tracking
>> [PATCH RFC v0 26/49] pnfsd: layout state per file tracking
>> [PATCH RFC v0 27/49] pnfsd: hash layouts on layout state
>> [PATCH RFC v0 28/49] pnfsd: support layout segment merging
>>
>> pnfs attributes:
>> [PATCH RFC v0 29/49] pnfsd: support layout_type attribute
>> [PATCH RFC v0 30/49] pnfsd: make pnfs server return layout_blksize when the client asks for it
>> [PATCH RFC v0 31/49] pnfsd: add support for per-file layout_types attribute
>>
>> pnfsd over dlm:
>> [PATCH RFC v0 32/49] pnfsd: per block device dlm data server list cache
>> [PATCH RFC v0 33/49] pnfsd: Add IP address validation to nfsd4_set_pnfs_dlm_device()
>> [PATCH RFC v0 34/49] pnfsd: new nfsd filesystem file: pnfs_dlm_device
>> [PATCH RFC v0 35/49] pnfsd: nfsd4_pnfs_dlm_getdeviter
>> [PATCH RFC v0 36/49] pnfsd: nfsd4_pnfs_dlm_getdevinfo
>> [PATCH RFC v0 37/49] pnfsd: make /proc/fs/nfsd/pnfs_dlm_device report dlm device list.
>> [PATCH RFC v0 38/49] pnfsd: nfsd4_pnfs_dlm_layoutget
>> [PATCH RFC v0 39/49] pnfsd: DLM file layout only support read iomode layouts
>> [PATCH RFC v0 40/49] pnfsd: add dlm file layout layout-type
>> [PATCH RFC v0 41/49] pnfsd: dlm pnfs_export_operations
>> [PATCH RFC v0 42/49] pnfsd: gfs2: use generic file layout pnfs operations vector
>>
>> layout return / expire / return_on_close:
>> [PATCH RFC v0 43/49] pnfsd: release state lock around iput in put_nfs4_file
>> [PATCH RFC v0 44/49] posix_acl: resolve compile dependency in posix_acl.h
>> [PATCH RFC v0 45/49] nfs: resolve compile dependency in nfs_xdr.h
>> [PATCH RFC v0 46/49] pnfsd: layout return generic implementation
>> [PATCH RFC v0 47/49] pnfsd: pnfs_expire_client
>> [PATCH RFC v0 48/49] pnfsd: return on close
>> [PATCH RFC v0 49/49] pnfsd: dlm set return_on_close to true
