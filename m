Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:6399 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1732298AbeHBOvt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Aug 2018 10:51:49 -0400
From: Nixiaoming <nixiaoming@huawei.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "jlayton@kernel.org" <jlayton@kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "trondmy@hammerspace.com" <trondmy@hammerspace.com>,
        "andros@netapp.com" <andros@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [PATCH v2] fs/nfsd: Delete invalid assignment statements in
 nfsd4_decode_exchange_id
Date: Thu, 2 Aug 2018 13:00:26 +0000
Message-ID: <E490CD805F7529488761C40FD9D26EF12A730A64@dggemm507-mbx.china.huawei.com>
References: <20180723015711.27961-1-nixiaoming@huawei.com>
 <20180801151820.GA18338@fieldses.org>
In-Reply-To: <20180801151820.GA18338@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday, August 01, 2018 11:18 PM ,  J. Bruce Fields  wrote: 
>On Mon, Jul 23, 2018 at 09:57:11AM +0800, nixiaoming wrote:
>> READ_BUF(8);
>> dummy = be32_to_cpup(p++);
>> dummy = be32_to_cpup(p++);
>> ...
>> READ_BUF(4);
>> dummy = be32_to_cpup(p++);
>> 
>> Assigning value to "dummy" here, but that stored value
>> is overwritten before it can be used.
>> At the same time READ_BUF() will re-update the pointer p.
>> 
>> delete invalid assignment statements
>
>Thanks, applying with a minor comment tweak to clarify that we're
>intentionally not reading these:
>
>-		/* ssp_window and ssp_num_gss_handles */
>+		/* ignore ssp_window and ssp_num_gss_handles: */
> 		READ_BUF(8);
> 		break;
>
>--b.
>

Thanks for your advice
I will update the patch as soon as possible according to your advice.

>> 
>> Signed-off-by: nixiaoming <nixiaoming@huawei.com>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>2
>> Signed-off-by: Trond Myklebust <trondmy@hammerspace.com>
>> ---
>>  fs/nfsd/nfs4xdr.c | 2 --
>>  1 file changed, 2 deletions(-)
>> 
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index a96843c..375ad4b 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -1392,8 +1392,6 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
>>  
>>  		/* ssp_window and ssp_num_gss_handles */
>>  		READ_BUF(8);
>> -		dummy = be32_to_cpup(p++);
>> -		dummy = be32_to_cpup(p++);
>>  		break;
>>  	default:
>>  		goto xdr_error;
>> -- 
>> 2.10.1



