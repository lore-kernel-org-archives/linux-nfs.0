Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:49789 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134Ab2BPOXY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 09:23:24 -0500
Message-ID: <4F3D115A.5060008@netapp.com>
Date: Thu, 16 Feb 2012 09:23:22 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Danny Kukawka <danny.kukawka@bisect.de>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Danny Kukawka <dkukawka@suse.de>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] fs/nfs/dns_resolve.c: included linux/nfs_fs.h twice
References: <1329400481-31627-1-git-send-email-danny.kukawka@bisect.de> <4F3D101C.6080805@netapp.com>
In-Reply-To: <4F3D101C.6080805@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/16/12 09:18, Bryan Schumaker wrote:

> On 02/16/12 08:54, Danny Kukawka wrote:
> 
>> fs/nfs/dns_resolve.c: included 'linux/nfs_fs.h' twice. No need
> 
>          ^^^^^^^^^^^^^
> You probably meant idamp.c here...
> 
> Good catch.  My idmapper fallback changes from a few weeks ago should have already done this see:
> 
> e6499c6f4b5f56a16f8b8ef60529c1da28b13aea  NFS: Fall back on old idmapper if request_key() fails
> 3cd0f37a2cc9e4d6188df10041a2441eaa41d991  NFS: Keep idmapper include files in one place
> 
> in Trond's nfs-for-next branch.


After looking closer, I see that I'm still including <linux/nfs_fs.h> twice even after those commits.  It's gone after the patches I plan on submitting today...

- Bryan

> 
> - Bryan
> 
>> to include it in the 'CONFIG_NFS_USE_NEW_IDMAPPER not defined'
>> block since it's already included at the top of the file.
>>
>> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
>> ---
>>  fs/nfs/idmap.c |    2 --
>>  1 files changed, 0 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
>> index 2c05f19..1526b5f 100644
>> --- a/fs/nfs/idmap.c
>> +++ b/fs/nfs/idmap.c
>> @@ -374,8 +374,6 @@ int nfs_map_gid_to_group(const struct nfs_server *server, __u32 gid, char *buf,
>>  #include <linux/workqueue.h>
>>  #include <linux/sunrpc/rpc_pipe_fs.h>
>>  
>> -#include <linux/nfs_fs.h>
>> -
>>  #include "nfs4_fs.h"
>>  
>>  #define IDMAP_HASH_SZ          128
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


