From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Fix send buffer length calculation in nfs3_xdr_setaclargs()
Date: Thu, 16 Apr 2009 09:52:42 -0400
Message-ID: <5E1C743F-6C25-47E6-9658-4868EDFD8771@oracle.com>
References: <49E5EAE6.7000507@suse.de> <1239818456.5177.88.camel@heimdal.trondhjem.org> <49E6BF7C.8040505@suse.de>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:28010 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbZDPOYf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Apr 2009 10:24:35 -0400
In-Reply-To: <49E6BF7C.8040505@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 16, 2009, at 1:17 AM, Suresh Jayaraman wrote:
> Trond Myklebust wrote:
>> On Wed, 2009-04-15 at 19:40 +0530, Suresh Jayaraman wrote:
>>> The recent posixacl fix(commit  
>>> ae46141ff08f1965b17c531b571953c39ce8b9e2)
>>> seems to have introduced a bug that will lead to -EINVAL errors  
>>> during
>>> normal setfacl operations on file or dir. This patch attempts to fix
>>> this.
>>
>> To start with, your len_in_head is in units of 32-bit _words_,  
>> whereas
>> len, base, and req->rq_slen are in units of bytes.
>>
>> Then, 'len' is initialised to the length of the currently encoded  
>> part
>> of the RPC header before subtracting 'len_in_head'. The resulting  
>> number
>
> Doh, I got it wrong totally. Thanks for the explaination.
>
> On a side note, I think it would be nice to add little comments in xdr
> code to explain non-obvious pieces.

As an aside, I think implementing this with xdr_streams might have  
some clarity benefits.

>> Please check if the following patch fixes things for you.
>
> Yes, the below patch fixes the issue for me too.
>
> Thanks,
>
>> Trond
>> ------------------------------------------------------------
>>> From b273b42f8b793a4a446015b50a5c1473553af48b Mon Sep 17 00:00:00  
>>> 2001
>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Date: Wed, 15 Apr 2009 13:58:45 -0400
>> Subject: [PATCH] NFS: Fix the XDR iovec calculation in  
>> nfs3_xdr_setaclargs
>>
>> Commit ae46141ff08f1965b17c531b571953c39ce8b9e2 (NFSv3: Fix posix  
>> ACL code)
>> introduces a bug in the calculation of the XDR header iovec. In the  
>> case
>> where we are inlining the acls, we need to adjust the length of the  
>> iovec
>> req->rq_svec, in addition to adjusting the total buffer length.
>>
>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>> ---
>> fs/nfs/nfs3xdr.c |    3 ++-
>> 1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
>> index e6a1932..35869a4 100644
>> --- a/fs/nfs/nfs3xdr.c
>> +++ b/fs/nfs/nfs3xdr.c
>> @@ -713,7 +713,8 @@ nfs3_xdr_setaclargs(struct rpc_rqst *req,  
>> __be32 *p,
>> 	if (args->npages != 0)
>> 		xdr_encode_pages(buf, args->pages, 0, args->len);
>> 	else
>> -		req->rq_slen += args->len;
>> +		req->rq_slen = xdr_adjust_iovec(req->rq_svec,
>> +				p + XDR_QUADLEN(args->len));
>>
>> 	err = nfsacl_encode(buf, base, args->inode,
>> 			    (args->mask & NFS_ACL) ?
>
>
> -- 
> Suresh Jayaraman
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




