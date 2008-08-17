From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [pnfs] [PATCH 7/7] nfsd: nfs4xdr decode_stateid helper function
Date: Sun, 17 Aug 2008 15:02:01 +0300
Message-ID: <48A81339.9010302@panasas.com>
References: <48A1CB0C.4090906@panasas.com>	<1218563178-25480-1-git-send-email-bhalevy@panasas.com>	<20080812190410.GC30729@fieldses.org> <48A28DEA.5060406@panasas.com>	<20080813150329.GF21004@fieldses.org> <1218650349.9042.20.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Chuck Lever <chucklever@gmail.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:24082 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752549AbYHQMCi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Aug 2008 08:02:38 -0400
In-Reply-To: <1218650349.9042.20.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Wed, 2008-08-13 at 11:03 -0400, J. Bruce Fields wrote:
>> On Wed, Aug 13, 2008 at 10:31:54AM +0300, Benny Halevy wrote:
>>> On Aug. 12, 2008, 22:04 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>> On Tue, Aug 12, 2008 at 08:46:18PM +0300, Benny Halevy wrote:
>>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>>> ---
>>>>>  fs/nfsd/nfs4xdr.c |   99 +++++++++++++++++++++++++++++-----------------------
>>>>>  1 files changed, 55 insertions(+), 44 deletions(-)
>>>>>
>>>>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>>>>> index 47ac498..9570b1b 100644
>>>>> --- a/fs/nfsd/nfs4xdr.c
>>>>> +++ b/fs/nfsd/nfs4xdr.c
>>>>>  static __be32
>>>>> @@ -929,9 +939,10 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
>>>>>  	int len;
>>>>>  	DECODE_HEAD;
>>>>>  
>>>>> -	READ_BUF(sizeof(stateid_opaque_t) + 20);
>>>>> -	READ32(write->wr_stateid.si_generation);
>>>>> -	COPYMEM(&write->wr_stateid.si_opaque, sizeof(stateid_opaque_t));
>>>>> +	status = nfsd4_decode_stateid(argp, &write->wr_stateid);
>>>>> +	if (status)
>>>>> +		return status;
>>>>> +	READ_BUF(16);
>>>> How did that 20 become a 16?
>>> It was sizeof(stateid_opaque_t) + 20 == sizeof(stateid_t) - 4 + 20 ==
>>> sizeof(stateid_t) + 16.
>> Whoops!  Even now I still fall into the stateid_opaque_t/stateid_t trap!
> 
> Which is a good reason for ditching the entire confusing typedef, and
> replacing it with a packed structure instead:
> 
> struct stateid {
> 	__be32 generation;
> 	char opaque[12];
> } __attribute__((packed));
> 
> Trond
> 

Please use the "__packed" Kernel macro for better compilers support.

And Yes I would suggest using "__packed" where ever a struct is defined
for on-the-wire. Even just for indication to fellow programmers that this 
is going on the wire as is.

Boaz
