Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:63598 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751551Ab0HRT5F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 15:57:05 -0400
Message-ID: <4C6C3B0D.2080005@panasas.com>
Date: Wed, 18 Aug 2010 22:57:01 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: andros@netapp.com, linux-nfs@vger.kernel.org,
        Fred Isaman <iisaman@citi.umich.edu>
Subject: Re: [PATCH 1/1] nfs41: prevent exchange_id from sending server-only
 flag
References: <1282153092-7228-1-git-send-email-andros@netapp.com> <1282154873.8540.69.camel@heimdal.trondhjem.org>
In-Reply-To: <1282154873.8540.69.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Aug. 18, 2010, 21:07 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Wed, 2010-08-18 at 13:38 -0400, andros@netapp.com wrote:
>> From: Fred Isaman <iisaman@citi.umich.edu>
>>
>> clp->cl_exchange_flags is used both for client output and server input.
>> This causes problems in certain recovery situations, when the server
>> has sent back EXCHGID4_FLAG_CONFIRMED_R, causing the client to erroneously
>> use the flag in future EXCHANGE_ID requests.
>>
>> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4proc.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 198d51d..e5fea95 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -4427,7 +4427,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>>  	nfs4_verifier verifier;
>>  	struct nfs41_exchange_id_args args = {
>>  		.client = clp,
>> -		.flags = clp->cl_exchange_flags,
>> +		.flags = clp->cl_exchange_flags & ~EXCHGID4_FLAG_CONFIRMED_R,
>>  	};
>>  	struct nfs41_exchange_id_res res = {
>>  		.client = clp,
> 
> Wait... This is utterly silly...
> 
> So we start be passing in clp->cl_exchange_flags == 0, then the server
> modifies that to some other value, and then from there on we always use
> the latest value of clp->cl_exchange_flags that resulted from the last
> call to EXCHANGE_ID????
> 
> We should be setting .flags according to the client capabilities, not
> according to the server reply...
> 
> IOW:
> args.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER | EXCHGID4_FLAG_USE_NON_PNFS;
> 
> 

Makes sense for upstream.

For pNFS, besides dropping EXCHGID4_FLAG_USE_NON_PNFS we should retain
EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_PNFS_DS as exchange_id
is called from both the MDS and the DS paths.

Benny
