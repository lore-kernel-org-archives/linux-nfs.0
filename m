Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:38950 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755321Ab2BPULz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 15:11:55 -0500
Subject: Re: [PATCH 07/13] NFS: Reduce debugging noise from encode_compound_hdr
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1329422653.4279.26.camel@lade.trondhjem.org>
Date: Thu, 16 Feb 2012 15:11:50 -0500
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <AD538E04-3BB7-4A75-A9E4-E2A791696FA9@oracle.com>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net> <20120215213542.3254.50291.stgit@ellison.1015granger.net> <1329422653.4279.26.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 16, 2012, at 3:04 PM, Myklebust, Trond wrote:

> On Wed, 2012-02-15 at 16:35 -0500, Chuck Lever wrote:
>> When NFSDBG_XDR debugging is enabled, I see a lot of
>> 
>>  encode_compound: tag=
>> 
>> on the console.  This is noise if the tag is empty.  Some might argue
>> that it is noise even if the tag isn't empty...
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> fs/nfs/nfs4xdr.c |    4 +++-
>> 1 files changed, 3 insertions(+), 1 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 606852a..2fb129d 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -889,7 +889,9 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
>> 	 * but this is not required as a MUST for the server to do so. */
>> 	hdr->replen = RPC_REPHDRSIZE + auth->au_rslack + 3 + hdr->taglen;
>> 
>> -	dprintk("encode_compound: tag=%.*s\n", (int)hdr->taglen, hdr->tag);
>> +	if (unlikely(hdr->taglen != 0))
>> +		dprintk("%s: tag=%.*s\n", __func__,
>> +				(int)hdr->taglen, hdr->tag);
>> 	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
>> 	p = reserve_space(xdr, 4 + hdr->taglen + 8);
>> 	p = xdr_encode_opaque(p, hdr->tag, hdr->taglen);
>> 
> 
> Let's just comment out the tag dprintk for now. We don't use the tag
> field at all...

OK.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




