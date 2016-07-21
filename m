Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752175AbcGUNDs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2016 09:03:48 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "hch@infradead.org" <hch@infradead.org>,
        "List Linux" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 24/28] Getattr doesn't require data sync semantics
Date: Thu, 21 Jul 2016 09:05:26 -0400
Message-ID: <70375D08-FCA9-4C73-9991-38490C11B171@redhat.com>
In-Reply-To: <E33497F6-079C-4903-9CC5-0ABDFA149694@primarydata.com>
References: <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-24-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-25-git-send-email-trond.myklebust@primarydata.com>
 <20160718034847.GA1195@infradead.org>
 <A9C18137-87A3-4652-ADD6-E8E1C4BAE27B@primarydata.com>
 <1468817945.5273.2.camel@primarydata.com>
 <20160719035843.GA24437@infradead.org>
 <F879054A-2116-40D5-90C9-473E71977E8A@redhat.com>
 <C44AB0DD-8FA3-42F2-B7DE-C694559A68EF@primarydata.com>
 <AB904138-E761-4F8F-AF97-0E8A4E067DB1@redhat.com>
 <20160721082216.GA15247@infradead.org>
 <A540F5A1-37B3-40EB-876D-EC33E891F0C9@redhat.com>
 <B4719B7F-3FC4-4FD7-929E-CC528CA867F4@redhat.com>
 <9E2543EF-0442-491E-AB22-3E1667DABBA4@redhat.com>
 <E33497F6-079C-4903-9CC5-0ABDFA149694@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 21 Jul 2016, at 8:46, Trond Myklebust wrote:

>> On Jul 21, 2016, at 05:52, Benjamin Coddington <bcodding@redhat.com> 
>> wrote:
>>
>> On 21 Jul 2016, at 5:10, Benjamin Coddington wrote:
>>
>>> On 21 Jul 2016, at 4:32, Benjamin Coddington wrote:
>>>
>>>> On 21 Jul 2016, at 4:22, hch@infradead.org wrote:
>>>>
>>>>> On Wed, Jul 20, 2016 at 11:03:06AM -0400, Benjamin Coddington 
>>>>> wrote:
>>>>>>>> This debug output is identical for every cycle of the loop. 
>>>>>>>> Have to
>>>>>>>> stop for the
>>>>>>>> day.. more tomorrow.
>>>>>>>>
>>>>>>>> Ben
>>>>>>>>
>>>>>>>
>>>>>>> Duh??? It???s this patch: pNFS: Fix post-layoutget error 
>>>>>>> handling in
>>>>>>> pnfs_update_layout()
>>>>>>> We have to pass through fatal errors??? I???ll fix it.
>>>>>>
>>>>>> That's indeed fixed it up, and generic/207 passes now.  Thanks!
>>>>>
>>>>> So I spoke too soon in my last mail, generic/207 still failjs for 
>>>>> me
>>>>> with Trond's linux-next tree, although much later in the test now.
>>>>>
>>>>> Does it include the changes that are supposed to fix the issue?
>>>>
>>>> It should -- the v2 that fixed 207 for me is 
>>>> 56b38a1f7c781519eef09c1668a3c97ea911f86b, the first version was 
>>>> e35c2a0b3cd062a8941d21511719391b64437427, I think.  I'll test again 
>>>> too.
>>>
>>> Looks like we're back to the original problem - it fails with the 
>>> inode size is 4k less than expected.
>>>
>>> The reason it worked for me was I had pnfs_ld debugging turned up 
>>> which slowed things down enough to somehow catch the right size.
>>>
>>> Looks like the right size is returned in the CLOSE, but the inode's 
>>> not getting updated.
>>
>> And the size is right in the last LAYOUTCOMMIT response, of course.  
>> Is this the problem?
>>
>> 6024 static int decode_layoutcommit(struct xdr_stream *xdr,
>> ...
>> 6040     sizechanged = be32_to_cpup(p);
>> 6041
>> 6042     if (sizechanged) {
>> 6043         /* throw away new size */
>> 6044         p = xdr_inline_decode(xdr, 8);
>>
>>
>> Ben
>>
>
> That shouldn’t really matter since we have a GETATTR immediately 
> following the LAYOUTGET operation. Assuming that 
> nfs4_proc_layoutcommit() actually gets called, it is supposed to 
> update the inode correctly.

So back to Christoph's point earlier:

On 17 Jul 2016, at 23:48, Christoph Hellwig wrote:
> This one breaks xfstests generic/207 on block/scsi layout for me.  The
> reason for that is that we need a layoutcommit after writing out all
> data for the file for the file size to be updated on the server.

You responded:

On 18 Jul 2016, at 0:32, Trond Myklebust wrote:
> I’m not understanding this argument. Why do we care if the file size 
> is up
> to date on the server if we’re not sending an actual GETATTR on the 
> wire
> to retrieve the file size?

I guess the answer might be because we can get it back from the last
LAYOUTCOMMIT.

This test has repeated appending 4k and has this pattern on the wire:

NFS 334 V4 Call LAYOUTGET
NFS 290 V4 Reply (Call In 854) LAYOUTCOMMIT
NFS 294 V4 Call GETATTR FH: 0x4f5528b0
NFS 442 V4 Reply (Call In 858) GETATTR
NFS 374 V4 Call LAYOUTCOMMIT
NFS 314 V4 Reply (Call In 856) LAYOUTGET
NFS 334 V4 Call LAYOUTGET
NFS 290 V4 Reply (Call In 860) LAYOUTCOMMIT
NFS 294 V4 Call GETATTR FH: 0x4f5528b0
NFS 442 V4 Reply (Call In 864) GETATTR
NFS 374 V4 Call LAYOUTCOMMIT
NFS 314 V4 Reply (Call In 862) LAYOUTGET
NFS 334 V4 Call LAYOUTGET
NFS 290 V4 Reply (Call In 866) LAYOUTCOMMIT
NFS 294 V4 Call GETATTR FH: 0x4f5528b0
NFS 442 V4 Reply (Call In 870) GETATTR
NFS 314 V4 Reply (Call In 868) LAYOUTGET
NFS 374 V4 Call LAYOUTCOMMIT
NFS 290 V4 Reply (Call In 874) LAYOUTCOMMIT
NFS 314 V4 Call CLOSE StateID: 0x54d9
NFS 294 V4 Reply (Call In 876) CLOSE

That last LAYOUTCOMMIT and the CLOSE have the size we want.  The 
previous
GETATTR is 4k short.

Ben
