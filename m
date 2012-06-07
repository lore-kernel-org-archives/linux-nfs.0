Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64464 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753015Ab2FGPRu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jun 2012 11:17:50 -0400
Message-ID: <4FD0C613.7020400@netapp.com>
Date: Thu, 07 Jun 2012 11:17:39 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Joerg Roedel <joro@8bytes.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFS regression in v3.5-rc1: mount.nfs yells about incorrect mount
 option
References: <20120607150456.GO12795@8bytes.org> <4FD0C4C2.8020605@netapp.com>
In-Reply-To: <4FD0C4C2.8020605@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/07/2012 11:12 AM, Bryan Schumaker wrote:
> On 06/07/2012 11:04 AM, Joerg Roedel wrote:
>> Hi,
>>
>> since Linux v3.5-rc1 I experience problems using NFS between my
>> machines. One of my test-machines gives me:
>>
>> root@chrom:~# mount lemmy:/data/repos /data/lemmy
>> mount.nfs: an incorrect mount option was specified
> 
> Hi,
> 
> Can you use `mount -v` to get more output?

Ah, I'm getting my patch titles confused.  I think I found this bug earlier in the week, does this patch fix it for you?

commit cdf66442fab82916fe38f928b4f91815195a294c
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Tue Jun 5 14:59:54 2012 -0400

    NFS4: Set parsed mount data version to 4
    
    This patch only affects mounting through "-t nfs4" since it doesn't set
    up an nfs version to use in the mount data.  The nfs client was trying
    to mount using NFS v0, causing either a BUG() or a protocol not
    supported message.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ff656c0..bdd6731 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2637,6 +2637,8 @@ static int nfs4_validate_mount_data(void *options,
 	if (data == NULL)
 		goto out_no_data;
 
+	args->version = 4;
+
 	switch (data->version) {
 	case 1:
 		if (data->host_addrlen > sizeof(args->nfs_server.address))


> 
> - Bryan
>>
>> The same works fine on v3.4. I tried to bisect but got different errors
>> in between. In the end, using every non-working case as bad, bisection
>> pointed to:
>>
>> 	db83335 NFS: Let mount data parsing set the NFS version
>>
>> but that at that commit the kernel panics when trying to mount the NFS
>> tree. Please let me know if you need any additional information.
>>
>> Regards,
>>
>> 	Joerg
>>
>>
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


