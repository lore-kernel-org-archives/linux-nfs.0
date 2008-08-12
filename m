From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 0/2] fix nfsd stateid encoding
Date: Tue, 12 Aug 2008 20:40:28 +0300
Message-ID: <48A1CB0C.4090906@panasas.com>
References: <48A04820.5000409@panasas.com> <20080811155842.GC32193@fieldses.org> <48A064BC.1050302@panasas.com> <76bd70e30808110917y5a9a1950l1d905f081bd7a819@mail.gmail.com> <20080811162830.GB772@fieldses.org> <48A0796F.20402@panasas.com> <20080811175026.GA1781@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chucklever@gmail.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:8984 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751351AbYHLRk6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2008 13:40:58 -0400
In-Reply-To: <20080811175026.GA1781@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 11, 2008, 20:50 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Mon, Aug 11, 2008 at 08:39:59PM +0300, Benny Halevy wrote:
>> On Aug. 11, 2008, 19:28 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> On Mon, Aug 11, 2008 at 12:17:35PM -0400, Chuck Lever wrote:
>>>> Hi Benny-
>>>>
>>>> On Mon, Aug 11, 2008 at 12:11 PM, Benny Halevy <bhalevy@panasas.com> wrote:
>>>>> On Aug. 11, 2008, 18:58 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>>> On Mon, Aug 11, 2008 at 05:09:36PM +0300, Benny Halevy wrote:
>>>>>>> Bruce, in a couple locations the nfsd needs to encode the stateid.seqid
>>>>>>> as a uint32_t rather than as opaque.
>>>>>> Agreed, thanks.
>>>>>>
>>>>>> Though I have a hard time figuring out whether this has any impact in
>>>>>> practice.  Presumably the only change on the wire is that we'll get the
>>>>>> endianness of the stateid4.seqid right?  But that field is mostly opaque
>>>>>> to the client anyway; 3530 says
>>>>>>
>>>>>>       The server is required to increment the seqid field
>>>>>>       monotonically at each transition of the stateid.  This is
>>>>>>       important since the client will inspect the seqid in OPEN
>>>>>>       stateids to determine the order of OPEN processing done by the
>>>>>>       server.
>>>>>>
>>>>>> but doesn't say why this is important.  I'm sure this has been brought
>>>>>> up on the ietf list before, but can't recall whether someone came up
>>>>>> with a justification for the importance of this.
>>>>>>
>>>>>> Anyway, so I figure these should be queued up for the next (2.6.28)
>>>>>> merge window.  Thanks!
>>>>> Actually, I think this breaks delegreturn.
>>>>> Since we decode the stateid.si_generation correctly, it will get swabbed
>>>>> in delegreturn on little-endian servers.  This will cause
>>>>> nfs4_preprocess_stateid_op/check_stateid_generation as called by
>>>>> nfsd4_delegreturn to fail. And eventually, unhash_delegation
>>>>> wouldn't be called.
>>>> Sounds plausible, good catch.  Yet another reason we should have an
>>>> easy-to-access delegation counter metric on both the client and
>>>> server.
>>>>
>>>> I wonder, since you found three separate places where this is needed:
>>>> should you construct a helper function?
>>> A stateid encoder/decoder?  Sure, that could be a good idea.
>> Cool.  Would you like me to rework the patches I've already sent
>> or send a patch adding the helpers on top of them?
> 
> I'm fine with whichever you think makes the most sense.
> 
> --b.

OK.  It's better to separate the fixes from the refactoring of code.
The 7-patch patchset in reply to this message does the following:

[PATCH 1/7] nfsd: properly xdr-encode stateid4.seqid as uint32_t for cb_recall

encoding fix for cb_recall.

There's no helper defined since there's only one use.
I've defined a helper and used in the nfs41 series since
there, there are 2 (cb_recall and cb_layoutrecall).

[PATCH 2/7] nfsd: properly xdr-encode deleg stateid returned from open
[PATCH 3/7] nfsd: fix nfsd4_encode_open buffer space reservation

xdr encoding fixes

[PATCH 4/7] nfsd: nfs4xdr encode_stateid helper function
[PATCH 5/7] nfsd: don't declare p in ENCODE_SEQID_OP_HEAD


xdr encode_stateid refactoring

[PATCH 6/7] nfsd: properly xdr-decode NFS4_OPEN_CLAIM_DELEGATE_CUR stateid

xdr decoding fix

[PATCH 7/7] nfsd: nfs4xdr decode_stateid helper function

xdr decode_stateid refactoring

Benny

