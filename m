Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59979 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab0IJVLQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 17:11:16 -0400
Received: by bwz11 with SMTP id 11so2622692bwz.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 14:11:15 -0700 (PDT)
In-Reply-To: <1284147111.10062.74.camel@heimdal.trondhjem.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	<1283450419-5648-9-git-send-email-iisaman@netapp.com>
	<1284147111.10062.74.camel@heimdal.trondhjem.org>
Date: Fri, 10 Sep 2010 14:11:14 -0700
Message-ID: <AANLkTi=6vcQC1k28B=aKJbN=jRBipoff3+79BpgLxtXw@mail.gmail.com>
Subject: Re: [PATCH 08/13] RFC: pnfs: filelayout: introduce minimal file
 layout driver
From: Fred Isaman <iisaman@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 10, 2010 at 12:31 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2010-09-02 at 14:00 -0400, Fred Isaman wrote:
>> From: The pNFS Team <linux-nfs@vger.kernel.org>
>>
>> This driver just registers itself and supplies trivial mount/umount functions.
>>
>> Signed-off-by: TBD - melding/reorganization of several patches
>> ---
>>  fs/nfs/Kconfig          |    5 +++
>>  fs/nfs/Makefile         |    3 ++
>>  fs/nfs/nfs4filelayout.c |   89 +++++++++++++++++++++++++++++++++++++++++++++++
>>  include/linux/nfs_fs.h  |    1 +
>>  4 files changed, 98 insertions(+), 0 deletions(-)
>>  create mode 100644 fs/nfs/nfs4filelayout.c
>>
>> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
>> index 5f1b936..980f2dc 100644
>> --- a/fs/nfs/Kconfig
>> +++ b/fs/nfs/Kconfig
>> @@ -82,6 +82,11 @@ config NFS_V4_1
>>
>>         If unsure, say N.
>>
>> +config PNFS_FILE_LAYOUT
>> +     tristate
>> +     depends on NFS_FS && NFS_V4_1
>> +     default m
>
> Should be 'default y', otherwise it has an implicit dependency on
> CONFIG_MODULES.
>

The idea was that normally the driver would compile as a module, and
use loading/unloading of it to control whether pnfs is supported.

Is there a way to do this that does not introduce the implicit dependency?


>> +
>>  config ROOT_NFS
>>       bool "Root file system on NFS"
>>       depends on NFS_FS=y && IP_PNP
>> diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
>> index bb9e773..08a8889 100644
>> --- a/fs/nfs/Makefile
>> +++ b/fs/nfs/Makefile
>> @@ -18,3 +18,6 @@ nfs-$(CONFIG_NFS_V4)        += nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
>>  nfs-$(CONFIG_NFS_V4_1)       += pnfs.o
>>  nfs-$(CONFIG_SYSCTL) += sysctl.o
>>  nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
>> +
>> +obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
>> +nfs_layout_nfsv41_files-y := nfs4filelayout.o
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> new file mode 100644
>> index 0000000..c685196
>> --- /dev/null
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -0,0 +1,89 @@
>> +/*
>> + *  Module for the pnfs nfs4 file layout driver.
>> + *  Defines all I/O and Policy interface operations, plus code
>> + *  to register itself with the pNFS client.
>> + *
>> + *  Copyright (c) 2002
>> + *  The Regents of the University of Michigan
>> + *  All Rights Reserved
>> + *
>> + *  Dean Hildebrand <dhildebz@umich.edu>
>> + *
>> + *  Permission is granted to use, copy, create derivative works, and
>> + *  redistribute this software and such derivative works for any purpose,
>> + *  so long as the name of the University of Michigan is not used in
>> + *  any advertising or publicity pertaining to the use or distribution
>> + *  of this software without specific, written prior authorization. If
>> + *  the above copyright notice or any other identification of the
>> + *  University of Michigan is included in any copy of any portion of
>> + *  this software, then the disclaimer below must also be included.
>> + *
>> + *  This software is provided as is, without representation or warranty
>> + *  of any kind either express or implied, including without limitation
>> + *  the implied warranties of merchantability, fitness for a particular
>> + *  purpose, or noninfringement.  The Regents of the University of
>> + *  Michigan shall not be liable for any damages, including special,
>> + *  indirect, incidental, or consequential damages, with respect to any
>> + *  claim arising out of or in connection with the use of the software,
>> + *  even if it has been or is hereafter advised of the possibility of
>> + *  such damages.
>> + */
>> +
>> +#include <linux/nfs_fs.h>
>> +#include "pnfs.h"
>> +
>> +#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
>> +
>> +MODULE_LICENSE("GPL");
>> +MODULE_AUTHOR("Dean Hildebrand <dhildebz@umich.edu>");
>> +MODULE_DESCRIPTION("The NFSv4 file layout driver");
>> +
>> +int
>> +filelayout_initialize_mountpoint(struct nfs_client *clp)
>> +{
>> +     return 0;
>> +}
>> +
>> +int
>> +filelayout_uninitialize_mountpoint(struct nfs_client *clp)
>> +{
>> +     dprintk("--> %s\n", __func__);
>> +
>> +     return 0;
>> +}
>> +
>> +struct layoutdriver_io_operations filelayout_io_operations = {
>
> Should definitely be declared as 'const' (and possibly 'static').
>

OK

>> +     .initialize_mountpoint   = filelayout_initialize_mountpoint,
>> +     .uninitialize_mountpoint = filelayout_uninitialize_mountpoint,
>> +};
>> +
>> +
>> +struct pnfs_layoutdriver_type filelayout_type = {
>
> Ditto.

This includes a list_head field which is set by the generic layer.

>
>> +     .id = LAYOUT_NFSV4_1_FILES,
>> +     .name = "LAYOUT_NFSV4_1_FILES",
>> +     .ld_io_ops = &filelayout_io_operations,
>
> Why do we need a separate 'struct layoutdriver_io_operations'? Any
> reason those can't just be embedded in struct pnfs_layoutdriver_type?

I believe this decision was primarily aesthetics.  However, keeping
the static io_ops seperate from the variable list_head seems like a
good idea.

Perhaps having a driver structure that includes the io_ops and static
portions of pnfs_layoutdriver_type, with the generic layer allocating
a wrapper structure that is basically:
struct {
    struct list_head list;
    struct pnfs_layoutdriver_type *driver_info;
}


Fred


>
>> +};
>> +
>> +static int __init nfs4filelayout_init(void)
>> +{
>> +     printk(KERN_INFO "%s: NFSv4 File Layout Driver Registering...\n",
>> +            __func__);
>> +
>> +     /*
>> +      * Need to register file_operations struct with global list to indicate
>> +      * that NFS4 file layout is a possible pNFS I/O module
>> +      */
>> +     return pnfs_register_layoutdriver(&filelayout_type);
>> +}
>> +
>> +static void __exit nfs4filelayout_exit(void)
>> +{
>> +     printk(KERN_INFO "%s: NFSv4 File Layout Driver Unregistering...\n",
>> +            __func__);
>> +
>> +     /* Unregister NFS4 file layout driver with pNFS client*/
>> +     pnfs_unregister_layoutdriver(&filelayout_type);
>> +}
>> +
>> +module_init(nfs4filelayout_init);
>> +module_exit(nfs4filelayout_exit);
>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>> index 042c2bd..a0f49a3 100644
>> --- a/include/linux/nfs_fs.h
>> +++ b/include/linux/nfs_fs.h
>> @@ -614,6 +614,7 @@ extern void * nfs_root_data(void);
>>  #define NFSDBG_MOUNT         0x0400
>>  #define NFSDBG_FSCACHE               0x0800
>>  #define NFSDBG_PNFS          0x1000
>> +#define NFSDBG_PNFS_LD               0x2000
>>  #define NFSDBG_ALL           0xFFFF
>>
>>  #ifdef __KERNEL__
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
