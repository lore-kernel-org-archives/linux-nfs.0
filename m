From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [pnfs] [PATCH RFC v2 0/21] nfs4xdr cleanup v2
Date: Mon, 17 Aug 2009 16:54:45 +0300
Message-ID: <4A896125.2040506@panasas.com>
References: <4A8571E2.8020800@panasas.com>  <4A89338D.1040207@panasas.com> <1250513254.8475.20.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:5299
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752055AbZHQNyt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2009 09:54:49 -0400
In-Reply-To: <1250513254.8475.20.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/17/2009 03:47 PM, Trond Myklebust wrote:
> On Mon, 2009-08-17 at 13:40 +0300, Boaz Harrosh wrote:
>> * So I hate it that the READ32/WRITE32 is open coded. Now it looks like nothing, it
>>   should have an xdr_encode/decode naming convention, all details hidden, consistent calling
>>   convention with the reset of the code.
> 
> The convention is already established. Please see 15 years worth of
> NFSv2/v3 xdr code. The NFSv4 code was the exception not the rule.
> 
> Now, it is obvious what we're doing: we're writing 32-bit big endian
> encoded data into a memory buffer. Furthermore, the process of
> converting from cpu ordered integers into 32-bit big endian is now made
> obvious, making it easily verifiable both by inspection, and using
> 'sparse'.
> Adding wrappers to do this, is just unnecessarily obfuscating the code.
> 

As I said, *sometimes* "obfuscation" is the point. If it has merits to account
for human short concentration span.

>> * I hate it that I have to count (p)"++" now to look for actual code advancements.
> 
> How is that _any_ different from counting WRITE32s?
> 

The size for one. And mainly the symmetry with the other side of the wire.

WRITEXX for every READXX. What now?

>> * I hate that it is called encode_hyper that a dum like me needs to look it up in the dictionary
>>   "32" and "64" will do
> 
> I don't mind changing the name of xdr_encode_hyper() to
> xdr_encode_uint64 or some such alternative, however the point is that we
> should have only _one_ function that encodes 64 bit integers. Not one
> function that everyone else uses, and then a macro that NFSv4 uses.
> 
>> * I hated it before, but I hate it even more now that the same operation is:
>>   reserved(4); p + 1
> 
> Huh? What operation?
> 

Sorry, I meant the mix use of byte_sizes and word_sizes. For example I'd like
reserved(1); p + 1;
and reserved(quad_len(len)); p + quad_len(len);

I see a pattern here. Highly changing code devises these "helpers", that enables
reviewing, for catching bugs. Then once stabilized, code is "un-obfuscated" and
becomes "write-only". Who cares, no one needs to read-it, it works.

I don't want to raise any flame wars here. I come late and I see what I see.

Probably 2, 3 iterations into this I will become blind to this code as well.
I guess current code is fine. How hard can it be, so I spend an hour longer on
a missing "++". New NFS versions are written every 10 years.

Only one request though. Please make nfs and nfsd use the same xdr mechanics

Boaz
