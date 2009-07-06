From: Andy Adamson <andros@netapp.com>
Subject: Re: [pnfs] [PATCH 4/5] nfsd41: set the session maximum response sizecached
Date: Mon, 6 Jul 2009 15:27:43 -0400
Message-ID: <4F969509-933A-45B1-B365-CB70F812A120@netapp.com>
References: <> <1245872278-18743-1-git-send-email-andros@netapp.com><1245872278-18743-2-git-send-email-andros@netapp.com><1245872278-18743-3-git-send-email-andros@netapp.com><1245872278-18743-4-git-send-email-andros@netapp.com> <1245872278-18743-5-git-send-email-andros@netapp.com> <5BDF2F31-6F9B-4214-95F9-4EE9B40E5538@netapp.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
	<bfields@citi.umich.edu>, <linux-nfs@vger.kernel.org>,
	<pnfs@linux-nfs.org>
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30380 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752882AbZGFT1m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jul 2009 15:27:42 -0400
In-Reply-To: <5BDF2F31-6F9B-4214-95F9-4EE9B40E5538@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 1, 2009, at 7:09 PM, Alexandros Batsakis wrote:

>
> On Jun 24, 2009, at 12:37 PM, Adamson, Andy wrote:
>
>> From: Andy Adamson <andros@netapp.com>
>>
>> NFSD_SLOT_CACHE_SIZE holds the encoded operations past the SEQUENCE  
>> operation.
>> ca_maxresponsesize_cached (draft-ietf-nfsv4-minorversion1-29) is  
>> the xdr
>> encoded size of the request including the RPC header. Since the RPC  
>> header
>> size varies with security flavor credential and verifier. we cannot  
>> set an
>> accurate ca_maxresponsesize_cached. Use NFSD_SLOT_CACHE_SIZE as an
>> approximate ca_maxresponsesize_cached - we will have at least that  
>> much space.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfsd/nfs4state.c |   11 ++++++++---
>> 1 files changed, 8 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 991c3cc..a0bd6da 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -464,9 +464,14 @@ static int init_forechannel_attrs(struct  
>> svc_rqst *rqstp,
>>                fchan->maxresp_sz = maxcount;
>>        session_fchan->maxresp_sz = fchan->maxresp_sz;
>>
>> -       /* Set the max response cached size our default which is
>> -        * a multiple of PAGE_SIZE and small */
>> -       session_fchan->maxresp_cached = NFSD_PAGES_PER_SLOT *  
>> PAGE_SIZE;
>> +       /*
>> +        * The ca_maxresponssize_cached definition includes the xdr
>> +        * encoded size of the rpc header with the variable length  
>> security
>> +        * flavor credential plus verifier as well as the encoded  
>> SEQUENCE
>> +        * operation response size which are not included in
>> +        * NFSD_SLOT_CACHE_SIZE. We err on the side of being a bit  
>> small.
>> +        */
>> +       session_fchan->maxresp_cached = NFSD_SLOT_CACHE_SIZE;
>>        fchan->maxresp_cached = session_fchan->maxresp_cached;
>>
>>
> Here we set the maxresp_cached equal to 512 which is normally much  
> less than the maxresp_sz, and we return this value to client in  
> CREATE_SESSION.

The max response size cached is supposed to be a lot less than the max  
response size.  Since it is a nfsd memory resource, we would like to  
keep it as low as possible.

NFSv4.1 clients should not expect READ and READDIR results to be  
cached, and the linux client does not ask for these operations to be  
cached. GETATTR with an acl request should also not be cached - there  
is no way to tell how large the acl is.

>
> This leads to a bunch of NFSERR_TOO_BIG_TO_CACHE errors for OPENs,  
> READs, etc.

Argh. I chose the 512 byte DRC buffer size because it does service the  
responses of the Linux (and Solaris) clients. The 512 bytes were  
designed to hold operation results past the sequence operation. This  
was tested at the last bakeathon.

The maxresponse_size_cached is supposed to hold the RPC response,  
including verifier and the encoded operations. In the previous DRC  
patch set, which was tested at the bakeathon, the max response size  
cached was set to 512+size of encoded SEQUENCE + RPC max size.

Bruce suggested that we just use the DRC buffer size for the max  
response size cached which is what the current code uses.

I just  ran connectathon tests against the nfsd41-all 2.6.31-rc1  
server and saw the NFS4ERR_TOO_BIG_TO_CACHE on OPEN, CREATE, RENAME  
etc - all of which had a total response of 548 bytes or so - just past  
the max response size cached limit. This is with AUTH_SYS, and a NULL  
RPC verifier.

The sequence operation always returns 44 bytes. The minimal RPC reply  
is 32 bytes (NULL RPC verifier).

Here is what I suggest.

1) max response size should be the DRC buffer slot size (currently  
512) + 44 + 32. The RPC GSS verifier will still not be accounted for,  
but the rest of the known sizes are.
2) Perhaps bump the 512 to 512+64.  The current code shows we are  
cutting it a bit close, we want to ensure that nfsd can service normal  
operation responses with several GETATTR's with a lot of attributes.


-->Andy



>
> In theory the client should be able to recover (or better prevent  
> this by not setting cachethis=1).
> Is there a reason that maxresp_cached is so small ?
>
> -alexandros
>>        /* Use the client's maxops if possible */
>> --
>> 1.5.4.3
>>
>> _______________________________________________
>> pNFS mailing list
>> pNFS@linux-nfs.org
>> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>>
>

