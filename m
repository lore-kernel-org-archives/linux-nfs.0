Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:36788 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab1HKVxp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 17:53:45 -0400
Message-ID: <4E444F45.60907@panasas.com>
Date: Thu, 11 Aug 2011 14:53:09 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Randy Dunlap <rdunlap@xenotime.net>
CC: Benny Halevy <bhalevy@tonian.com>, Sorin Faibish <sfaibish@emc.com>,
        peter honeyman <honey@citi.umich.edu>, <tao.peng@emc.com>,
        <torvalds@linux-foundation.org>, <bergwolf@gmail.com>,
        <Trond.Myklebust@netapp.com>, <linux-raid@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        "Welch, Brent" <welch@panasas.com>
Subject: Re: [PATCH v2] pnfs: Automatically select blocks & objects layouts
References: <CA+55aFwkJdyEpyNY64aAQ5ChrPZ8Kvx9iRUwy1J6_SRaxoN=zA@mail.gmail.com> <20110810122304.96b8be67.rdunlap@xenotime.net> <CA+a=Yy5izxiyvW5eYiWuute9E1vXwNTj4frdzNeEwsLDrszesg@mail.gmail.com> <20110810175829.a834d80f.rdunlap@xenotime.net> <CA+55aFzcSLrhkexEn=J7BN8F3P3Vy+EAjwgGwMQPdeoYoQG+Bw@mail.gmail.com> <F19688880B763E40B28B2B462677FBF805BF0EAC8A@MX09A.corp.emc.com> <4E43AAD1.7090806@tonian.com> <4E4422FD.3060706@panasas.com> <4E444552.9030105@panasas.com> <4E4449B5.3050309@panasas.com> <20110811144354.c47a5c26.rdunlap@xenotime.net>
In-Reply-To: <20110811144354.c47a5c26.rdunlap@xenotime.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/11/2011 02:43 PM, Randy Dunlap wrote:
> On Thu, 11 Aug 2011 14:29:25 -0700 Boaz Harrosh wrote:
> 
>>
>> Just like files-layout, blocks & objects layouts are part of the
>> NFS 4.1 protocol and should be automatically selected if NFS_4_1
>> is selected. The small problem is that these depend on other
>> Kernel support being present, while files only depends on NFS
>> itself.
>>
>> This patch removes from the user choice the presence of objects
>> and blocks layout. But makes sure these are selected only if
>> the depended subsystems are present in the Kernel.
>>
>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> 
> v1 applied & built OK for me.

Sorry about the mixup, my bad

v1 is the one you need for linux-3.1-rc1.

> v2 didn't apply to linux-3.1-rc1 cleanly, but I think I got it right.

v2 should apply cleanly ontop of linus/master as off:
	1d229d5 Merge branch 'perf-urgent-for-linus'

Because of the other patch already submitted by Linus.

The result of the two patches should give you the same exact
Kconfig file. Just applied on two different tips.

Again sorry!
Boaz

> Maybe not.  I got all of this from it:
> 
> warning: (NFS_V4_1) selects MD which has unmet direct dependencies (BLOCK)
>   CC [M]  fs/nfs/blocklayout/blocklayout.o
>   CC [M]  fs/nfs/blocklayout/extents.o
> In file included from fs/nfs/blocklayout/blocklayout.h:35,
>                  from fs/nfs/blocklayout/extents.c:33:
> include/linux/device-mapper.h:49: warning: 'struct bio' declared inside parameter list
> include/linux/device-mapper.h:49: warning: its scope is only this definition or declaration, which is probably not what you want
> include/linux/device-mapper.h:51: warning: 'struct request' declared inside parameter list
> include/linux/device-mapper.h:63: warning: 'struct bio' declared inside parameter list
> include/linux/device-mapper.h:66: warning: 'struct request' declared inside parameter list
> include/linux/device-mapper.h:83: warning: 'struct bvec_merge_data' declared inside parameter list
> include/linux/device-mapper.h:95: warning: 'struct queue_limits' declared inside parameter list
> include/linux/device-mapper.h:300: warning: 'struct bio' declared inside parameter list
> include/linux/device-mapper.h:301: warning: 'struct request' declared inside parameter list
> include/linux/device-mapper.h:475: warning: 'struct request' declared inside parameter list
> include/linux/device-mapper.h:476: warning: 'struct request' declared inside parameter list
> include/linux/device-mapper.h:477: warning: 'struct request' declared inside parameter list
> include/linux/device-mapper.h:478: warning: 'struct request_queue' declared inside parameter list
> In file included from fs/nfs/blocklayout/blocklayout.h:35,
>                  from fs/nfs/blocklayout/blocklayout.c:40:
> include/linux/device-mapper.h:49: warning: 'struct bio' declared inside parameter list
> include/linux/device-mapper.h:49: warning: its scope is only this definition or declaration, which is probably not what you want
> include/linux/device-mapper.h:51: warning: 'struct request' declared inside parameter list
> include/linux/device-mapper.h:63: warning: 'struct bio' declared inside parameter list
> include/linux/device-mapper.h:66: warning: 'struct request' declared inside parameter list
> include/linux/device-mapper.h:83: warning: 'struct bvec_merge_data' declared inside parameter list
> include/linux/device-mapper.h:95: warning: 'struct queue_limits' declared inside parameter list
> include/linux/device-mapper.h:300: warning: 'struct bio' declared inside parameter list
> include/linux/device-mapper.h:301: warning: 'struct request' declared inside parameter list
> include/linux/device-mapper.h:475: warning: 'struct request' declared inside parameter list
> include/linux/device-mapper.h:476: warning: 'struct request' declared inside parameter list
> include/linux/device-mapper.h:477: warning: 'struct request' declared inside parameter list
> include/linux/device-mapper.h:478: warning: 'struct request_queue' declared inside parameter list
> fs/nfs/blocklayout/blocklayout.c: In function 'bl_submit_bio':
> fs/nfs/blocklayout/blocklayout.c:132: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:133: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:133: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:136: error: implicit declaration of function 'submit_bio'
> fs/nfs/blocklayout/blocklayout.c: In function 'bl_alloc_init_bio':
> fs/nfs/blocklayout/blocklayout.c:148: error: implicit declaration of function 'bio_alloc'
> fs/nfs/blocklayout/blocklayout.c:148: warning: assignment makes pointer from integer without a cast
> fs/nfs/blocklayout/blocklayout.c:152: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:153: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:154: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:155: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c: In function 'bl_add_page_to_bio':
> fs/nfs/blocklayout/blocklayout.c:171: error: implicit declaration of function 'bio_add_page'
> fs/nfs/blocklayout/blocklayout.c: In function 'bl_end_io_read':
> fs/nfs/blocklayout/blocklayout.c:192: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:193: error: 'BIO_UPTODATE' undeclared (first use in this function)
> fs/nfs/blocklayout/blocklayout.c:193: error: (Each undeclared identifier is reported only once
> fs/nfs/blocklayout/blocklayout.c:193: error: for each function it appears in.)
> fs/nfs/blocklayout/blocklayout.c:193: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:193: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:194: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:194: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:198: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:200: error: decrement of pointer to unknown structure
> fs/nfs/blocklayout/blocklayout.c:200: error: arithmetic on pointer to an incomplete type
> fs/nfs/blocklayout/blocklayout.c:200: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:201: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:204: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:210: error: implicit declaration of function 'bio_put'
> fs/nfs/blocklayout/blocklayout.c: In function 'bl_end_io_write_zero':
> fs/nfs/blocklayout/blocklayout.c:355: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:356: error: 'BIO_UPTODATE' undeclared (first use in this function)
> fs/nfs/blocklayout/blocklayout.c:356: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:356: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:357: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:357: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:361: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:363: error: decrement of pointer to unknown structure
> fs/nfs/blocklayout/blocklayout.c:363: error: arithmetic on pointer to an incomplete type
> fs/nfs/blocklayout/blocklayout.c:363: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:364: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:368: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c: In function 'bl_end_io_write':
> fs/nfs/blocklayout/blocklayout.c:381: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:382: error: 'BIO_UPTODATE' undeclared (first use in this function)
> fs/nfs/blocklayout/blocklayout.c:382: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:382: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c: In function 'map_block':
> fs/nfs/blocklayout/blocklayout.c:440: error: implicit declaration of function 'set_buffer_mapped'
> fs/nfs/blocklayout/blocklayout.c:441: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:442: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:445: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:445: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c: In function 'init_page_for_write':
> fs/nfs/blocklayout/blocklayout.c:469: error: implicit declaration of function 'alloc_page_buffers'
> fs/nfs/blocklayout/blocklayout.c:469: warning: assignment makes pointer from integer without a cast
> fs/nfs/blocklayout/blocklayout.c:477: error: implicit declaration of function 'bh_uptodate_or_lock'
> fs/nfs/blocklayout/blocklayout.c:478: error: implicit declaration of function 'bh_submit_read'
> fs/nfs/blocklayout/blocklayout.c:486: error: implicit declaration of function 'free_buffer_head'
> make[4]: *** [fs/nfs/blocklayout/blocklayout.o] Error 1
> 
> and more errors in drivers/md/
> 
> 
>> ---
>>  fs/nfs/Kconfig |   18 ++++--------------
>>  1 files changed, 4 insertions(+), 14 deletions(-)
>>
>> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
>> index 0d30613..dbcd821 100644
>> --- a/fs/nfs/Kconfig
>> +++ b/fs/nfs/Kconfig
>> @@ -89,24 +89,14 @@ config PNFS_FILE_LAYOUT
>>  	tristate
>>  
>>  config PNFS_BLOCK
>> -	tristate "Provide support for the pNFS Block Layout Driver for NFSv4.1 pNFS (EXPERIMENTAL)"
>> +	tristate
>>  	depends on NFS_FS && NFS_V4_1 && BLK_DEV_DM
>> -	help
>> -	  Say M here if you want your pNFS client to support the Block Layout Driver
>> -	  (RFC 5663). Requires Multiple devices driver support (DM) and Device mapper
>> -	  support (BLK_DEV_DM).
>> -
>> -	  If unsure, say N.
>> +	default m
>>  
>>  config PNFS_OBJLAYOUT
>> -	tristate "Provide support for the pNFS Objects Layout Driver for NFSv4.1 pNFS (EXPERIMENTAL)"
>> +	tristate
>>  	depends on NFS_FS && NFS_V4_1 && SCSI_OSD_ULD
>> -	help
>> -	  Say M here if you want your pNFS client to support the Objects Layout Driver.
>> -	  Requires the SCSI osd initiator library (SCSI_OSD_INITIATOR) and
>> -	  upper level driver (SCSI_OSD_ULD).
>> -
>> -	  If unsure, say N.
>> +	default m
>>  
>>  config ROOT_NFS
>>  	bool "Root file system on NFS"
>> -- 
> 
> 
> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code ***

