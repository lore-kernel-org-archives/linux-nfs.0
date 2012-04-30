Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36309 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752073Ab2D3Q64 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 12:58:56 -0400
Message-ID: <4F9EC4CA.3080604@netapp.com>
Date: Mon, 30 Apr 2012 12:58:50 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH v3 25/25] NFS: rewrite directio write to use async coalesce
 code
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com> <1334947677-28864-26-git-send-email-iisaman@netapp.com> <4F9EB992.9040501@netapp.com>
In-Reply-To: <4F9EB992.9040501@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/30/2012 12:10 PM, Bryan Schumaker wrote:

> Hi Fred,
> 
> On 04/20/2012 02:47 PM, Fred Isaman wrote:
> 
>> This also has the advantage that it allows directio to use pnfs.
>>
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>>  fs/nfs/direct.c         |  527 +++++++++++++++++++++--------------------------
>>  fs/nfs/internal.h       |   18 ++-
>>  fs/nfs/nfs4filelayout.c |   44 ++++-
>>  fs/nfs/pnfs.h           |   17 ++
>>  fs/nfs/write.c          |   36 ++--
>>  5 files changed, 319 insertions(+), 323 deletions(-)
>>
>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>> index 4ba9a2c..d44de2f 100644
>> --- a/fs/nfs/direct.c
>> +++ b/fs/nfs/direct.c
>> @@ -56,6 +56,7 @@
>>  
>>  #include "internal.h"
>>  #include "iostat.h"
>> +#include "pnfs.h"
>>  
>>  #define NFSDBG_FACILITY		NFSDBG_VFS
>>  
>> @@ -81,16 +82,19 @@ struct nfs_direct_req {
>>  	struct completion	completion;	/* wait for i/o completion */
>>  
>>  	/* commit state */
>> -	struct list_head	rewrite_list;	/* saved nfs_write_data structs */
>> -	struct nfs_commit_data *commit_data;	/* special write_data for commits */
>> +	struct nfs_mds_commit_info mds_cinfo;	/* Storage for cinfo */
>> +	struct pnfs_ds_commit_info ds_cinfo;	/* Storage for cinfo */
> 
> 
> 
> When I compile without CONFIG_NFS_V4 enabled, I see this error:


Actually, it's when CONFIG_NFS_V4_1 isn't enabled, I just happened to find it with v4 turned off.

> 
>   CC [M]  fs/nfs/super.o
>   CC [M]  fs/nfs/direct.o
> fs/nfs/direct.c:86:29: error: field 'ds_cinfo' has incomplete type
> make[2]: *** [fs/nfs/direct.o] Error 1
> make[1]: *** [fs/nfs] Error 2
> make: *** [fs] Error 2
> 
> - Bryan
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


