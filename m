Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f181.google.com ([74.125.82.181]:52349 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab3I2Kxa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Sep 2013 06:53:30 -0400
Received: by mail-we0-f181.google.com with SMTP id p61so4438484wes.12
        for <linux-nfs@vger.kernel.org>; Sun, 29 Sep 2013 03:53:29 -0700 (PDT)
Message-ID: <524806A5.4090007@primarydata.com>
Date: Sun, 29 Sep 2013 13:53:25 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 06/49] pnfsd: define pnfs_export_operations
References: <52447EA0.7070004@primarydata.com> <1380220815-12955-1-git-send-email-bhalevy@primarydata.com> <20130927143929.GC9946@pad.fieldses.org>
In-Reply-To: <20130927143929.GC9946@pad.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-09-27 17:39, J. Bruce Fields wrote:
> On Thu, Sep 26, 2013 at 02:40:15PM -0400, Benny Halevy wrote:
>> From: Benny Halevy <bhalevy@panasas.com>
>>
>> struct pnfs_export_operations defines the VFS level API for pNFS,
>> not including callbacks.  A pnfs-exportable filesystem sets
>> a pointer to its pnfs export vector in its struct super_block.s_pnfs_op.
>>
>> The file system provides the per-superblock layout_type method that
>> determines if it supports pnfs for the filesystem identified by
>> the superblock, and if so, with which layout type (only one per-sb is
>> supported).
>>
>> Device ops:
>> get_device_iter is used to fill-in the device list for GETDEVICELIST
>> and get_device_info is used to encode the device info for GETDEVICEINFO.
>>
>> Layout ops:
>> layout_get, layout_commit, and layout_return implement the file system- and
>> layout type- specific parts of their respective protocol operations: LAYOUTGET,
>> LAYOUTCOMMIT, and LAYOUTRETURN.
>>
>> The following methods are mandatory to be implemented:
>> layout_type, get_device_info, and layout_get.
>>
>> Note: define pnfs export operations in a stub form in this patch.
>> Actual operations are defined along with their usage.
> 
> Patches touching the superblock or the new pnfs export operations should
> probably all be cc'd to linux-fsdevel.

Absolutely.
I'll add linux-fsdevel in the next iteration.

Benny

> 
> --b.
> 
>>
>> [pnfsd: provide default no-op operations]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> [pnfsd: compile fixes for pnfsd branch]
>> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>> [gfs2: set pnfs_dlm_export_ops only for CONFIG_PNFSD]
>> [pnfsd: handle s_pnfs_op==NULL]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
>> ---
>>  fs/nfsd/export.c                |  2 +-
>>  include/linux/fs.h              |  2 ++
>>  include/linux/nfsd/nfsd4_pnfs.h | 14 ++++++++++++++
>>  3 files changed, 17 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
>> index 5f38ea3..f26b0b9 100644
>> --- a/fs/nfsd/export.c
>> +++ b/fs/nfsd/export.c
>> @@ -16,7 +16,7 @@
>>  #include <linux/module.h>
>>  #include <linux/exportfs.h>
>>  #include <linux/sunrpc/svc_xprt.h>
>> -
>> +#include <linux/nfsd/nfsd4_pnfs.h>
>>  #include <net/ipv6.h>
>>  
>>  #include "nfsd.h"
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index 3f40547..d9186a4 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -34,6 +34,7 @@
>>  #include <uapi/linux/fs.h>
>>  
>>  struct export_operations;
>> +struct pnfs_export_operations;
>>  struct hd_geometry;
>>  struct iovec;
>>  struct nameidata;
>> @@ -1251,6 +1252,7 @@ struct super_block {
>>  	const struct dquot_operations	*dq_op;
>>  	const struct quotactl_ops	*s_qcop;
>>  	const struct export_operations *s_export_op;
>> +	const struct pnfs_export_operations *s_pnfs_op;
>>  	unsigned long		s_flags;
>>  	unsigned long		s_magic;
>>  	struct dentry		*s_root;
>> diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
>> index 9e7d95e..ff6613e 100644
>> --- a/include/linux/nfsd/nfsd4_pnfs.h
>> +++ b/include/linux/nfsd/nfsd4_pnfs.h
>> @@ -34,4 +34,18 @@
>>  #ifndef _LINUX_NFSD_NFSD4_PNFS_H
>>  #define _LINUX_NFSD_NFSD4_PNFS_H
>>  
>> +/*
>> + * pNFS export operations vector.
>> + *
>> + * The filesystem must implement the following methods:
>> + *   layout_type
>> + *   get_device_info
>> + *   layout_get
>> + *
>> + * All other methods are optional and can be set to NULL if not implemented.
>> + */
>> +struct pnfs_export_operations {
>> +	/* stub */
>> +};
>> +
>>  #endif /* _LINUX_NFSD_NFSD4_PNFS_H */
>> -- 
>> 1.8.3.1
>>
