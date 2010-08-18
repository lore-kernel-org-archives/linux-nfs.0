Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:47130 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334Ab0HRU5r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:57:47 -0400
Received: by ewy23 with SMTP id 23so755206ewy.19
        for <linux-nfs@vger.kernel.org>; Wed, 18 Aug 2010 13:57:45 -0700 (PDT)
Message-ID: <4C6C4944.7030501@panasas.com>
Date: Wed, 18 Aug 2010 23:57:40 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: andros@netapp.com, linux-nfs@vger.kernel.org,
        Fred Isaman <iisaman@citi.umich.edu>
Subject: Re: [PATCH 1/1] nfs41: prevent exchange_id from sending server-only
 flag
References: <1282153092-7228-1-git-send-email-andros@netapp.com>	 <1282154873.8540.69.camel@heimdal.trondhjem.org>	 <4C6C3B0D.2080005@panasas.com> <1282162601.8540.106.camel@heimdal.trondhjem.org>
In-Reply-To: <1282162601.8540.106.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Aug. 18, 2010, 23:16 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Wed, 2010-08-18 at 22:57 +0300, Benny Halevy wrote:
>> On Aug. 18, 2010, 21:07 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
>>> On Wed, 2010-08-18 at 13:38 -0400, andros@netapp.com wrote:
>>>> From: Fred Isaman <iisaman@citi.umich.edu>
>>>>
>>>> clp->cl_exchange_flags is used both for client output and server input.
>>>> This causes problems in certain recovery situations, when the server
>>>> has sent back EXCHGID4_FLAG_CONFIRMED_R, causing the client to erroneously
>>>> use the flag in future EXCHANGE_ID requests.
>>>>
>>>> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> ---
>>>>  fs/nfs/nfs4proc.c |    2 +-
>>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>> index 198d51d..e5fea95 100644
>>>> --- a/fs/nfs/nfs4proc.c
>>>> +++ b/fs/nfs/nfs4proc.c
>>>> @@ -4427,7 +4427,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>>>>  	nfs4_verifier verifier;
>>>>  	struct nfs41_exchange_id_args args = {
>>>>  		.client = clp,
>>>> -		.flags = clp->cl_exchange_flags,
>>>> +		.flags = clp->cl_exchange_flags & ~EXCHGID4_FLAG_CONFIRMED_R,
>>>>  	};
>>>>  	struct nfs41_exchange_id_res res = {
>>>>  		.client = clp,
>>>
>>> Wait... This is utterly silly...
>>>
>>> So we start be passing in clp->cl_exchange_flags == 0, then the server
>>> modifies that to some other value, and then from there on we always use
>>> the latest value of clp->cl_exchange_flags that resulted from the last
>>> call to EXCHANGE_ID????
>>>
>>> We should be setting .flags according to the client capabilities, not
>>> according to the server reply...
>>>
>>> IOW:
>>> args.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER | EXCHGID4_FLAG_USE_NON_PNFS;
>>>
>>>
>>
>> Makes sense for upstream.
>>
>> For pNFS, besides dropping EXCHGID4_FLAG_USE_NON_PNFS we should retain
>> EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_PNFS_DS as exchange_id
>> is called from both the MDS and the DS paths.
> 
> No. As I read the spec, a pNFS-capable client should _retain_
> EXCHGID4_FLAG_USE_NON_PNFS, and OR in the EXCHGID4_FLAG_USE_PNFS_MDS |
> EXCHGID4_FLAG_USE_PNFS_DS flags too (see section 13.1).

Oh, I meant that the function should retain the flags at the level
it is being called, but the flags should be initialized by the respective
callers appropriately. The server-returned values should not be retained,
as you correctly noted.

As for EXCHGID4_FLAG_USE_NON_PNFS, the server value can be retained, but
I see no harm in probing it again (for a pNFS capable client), in case
the server capabilities has changed in the meanwhile.  E.g., the admin
loaded the the magic pnfs module on the server and restarted the nfs
service.

Benny

> 
> The server will then reply with a subset of those 3 flags that tells the
> client whether it is an MDS, a DS, or a non-MDS (or a valid combination
> of 2 of those flags).
> 
> Trond
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

