From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 0/2] fix nfsd stateid encoding
Date: Mon, 11 Aug 2008 19:27:42 +0300
Message-ID: <48A0687E.4000606@panasas.com>
References: <48A04820.5000409@panasas.com>	 <20080811155842.GC32193@fieldses.org> <48A064BC.1050302@panasas.com> <76bd70e30808110917y5a9a1950l1d905f081bd7a819@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Chuck Lever <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:11385 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbYHKQ1s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2008 12:27:48 -0400
Received: by nf-out-0910.google.com with SMTP id d3so693682nfc.21
        for <linux-nfs@vger.kernel.org>; Mon, 11 Aug 2008 09:27:46 -0700 (PDT)
In-Reply-To: <76bd70e30808110917y5a9a1950l1d905f081bd7a819-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 11, 2008, 19:17 +0300, "Chuck Lever" <chucklever@gmail.com> wrote:
> Hi Benny-
> 
> On Mon, Aug 11, 2008 at 12:11 PM, Benny Halevy <bhalevy@panasas.com> wrote:
>> On Aug. 11, 2008, 18:58 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> On Mon, Aug 11, 2008 at 05:09:36PM +0300, Benny Halevy wrote:
>>>> Bruce, in a couple locations the nfsd needs to encode the stateid.seqid
>>>> as a uint32_t rather than as opaque.
>>> Agreed, thanks.
>>>
>>> Though I have a hard time figuring out whether this has any impact in
>>> practice.  Presumably the only change on the wire is that we'll get the
>>> endianness of the stateid4.seqid right?  But that field is mostly opaque
>>> to the client anyway; 3530 says
>>>
>>>       The server is required to increment the seqid field
>>>       monotonically at each transition of the stateid.  This is
>>>       important since the client will inspect the seqid in OPEN
>>>       stateids to determine the order of OPEN processing done by the
>>>       server.
>>>
>>> but doesn't say why this is important.  I'm sure this has been brought
>>> up on the ietf list before, but can't recall whether someone came up
>>> with a justification for the importance of this.
>>>
>>> Anyway, so I figure these should be queued up for the next (2.6.28)
>>> merge window.  Thanks!
>> Actually, I think this breaks delegreturn.
>> Since we decode the stateid.si_generation correctly, it will get swabbed
>> in delegreturn on little-endian servers.  This will cause
>> nfs4_preprocess_stateid_op/check_stateid_generation as called by
>> nfsd4_delegreturn to fail. And eventually, unhash_delegation
>> wouldn't be called.
> 
> Sounds plausible, good catch.  Yet another reason we should have an
> easy-to-access delegation counter metric on both the client and
> server.
> 
> I wonder, since you found three separate places where this is needed:

Note, I looked at all other places we encode or decode stateids and
they seem ok at first glance.

> should you construct a helper function?  Certainly there are already
> missed opportunities for sharing XDR encoding and decoding between
> callback and the forward channel.

That's fine with me.  In fact, my first implementation did exactly
that but when I saw that everywhere else the encoding of si_generation
followed by 12 opaque bytes is done inline I reverted to keeping
the current convention.  If everybody is ok with having such helper
functions I'll be happy to send patches implementing them.

The scope of _this_, however, is less urgent and can easily be
done for 2.6.28.

Benny

> 
>> Hence, I think these patches are appropriate for 2.6.27 and
>> even to older stable releases.
>>
>> Benny
>>
>>> --b.
>>>
>>>> Patch #1 fixes that for cb_recall.
>>>> Patch #2 fixes the deleg stateid returned by open.
>>>>
>>>> The patches should apply to linux-2.6/master
>>>> commit 796aadeb1b2db9b5d463946766c5bbfd7717158c
>>>>
>>>> Benny
>>> _______________________________________________
>>> pNFS mailing list
>>> pNFS@linux-nfs.org
>>> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 
> 

