From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 19/19] lockd: clean up 64-bit alignment fix in nsm_init_private()
Date: Tue, 28 Apr 2009 18:43:25 -0400
Message-ID: <84E7491E-840B-4F1A-A9BD-B74D5D0EB955@oracle.com>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net> <20090423233340.17283.29580.stgit@ingres.1015granger.net> <20090428163101.GK17891@fieldses.org> <1AF02847-8D16-4387-81CB-F36969CA9883@oracle.com> <20090428164027.GO17891@fieldses.org> <9A6CA37F-0D4D-48C3-AEF8-E47B2836EDCC@oracle.com> <20090428213638.GL23924@fieldses.org> <CAA58A55-4ED9-4D45-BE54-66DD8CEF191C@oracle.com> <yw1xws94xved.fsf@ps3.mansr.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:27829 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104AbZD1Wnj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 18:43:39 -0400
In-Reply-To: <yw1xws94xved.fsf-O+uoZmgXk1l54TAoqtyWWQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 28, 2009, at 6:31 PM, M=E5ns Rullg=E5rd wrote:
> Chuck Lever <chuck.lever@oracle.com> writes:
>> On Apr 28, 2009, at 5:36 PM, J. Bruce Fields wrote:
>>
>>> On Tue, Apr 28, 2009 at 01:24:24PM -0400, Chuck Lever wrote:
>>>> On Apr 28, 2009, at 12:40 PM, J. Bruce Fields wrote:
>>>>> On Tue, Apr 28, 2009 at 12:35:50PM -0400, Chuck Lever wrote:
>>>>>> On Apr 28, 2009, at 12:31 PM, J. Bruce Fields wrote:
>>>>>>> On Thu, Apr 23, 2009 at 07:33:40PM -0400, Chuck Lever wrote:
>>>>>>>> Recently, commit ad5b365c fixed a data type alignment issue in
>>>>>>>> nsm_init_private() by introducing put_unaligned().  We don't
>>>>>>>> actually _require_ an unaligned access to nsm_private here.
>>>>>>>>
>>>>>>>> Instead, we should always use memcpy/memcmp to access the
>>>>>>>> contents of RPC opaque data types.  This permits us to
>>>>>>>> continue to define these as simple character arrays, as most
>>>>>>>> legacy RPC code does, and to rely on gcc to pack the fields in
>>>>>>>> in-core structures optimally without breaking on platforms
>>>>>>>> that require strict alignment.
>>>>>>>
>>>>>>> OK, I'm confused.  What structures will get packed differently?
>>>>>>
>>>>>> Any struct that has an nsm_private embedded in it, such as struc=
t
>>>>>> nlm_reboot.
>>>>>
>>>>> I don't see how that or any structure is changed by this patch.
>>>>
>>>> It's not.  Note the phrase above in the description: "permits us t=
o
>>>> _continue_ to define these" -- meaning, I'm not changing the
>>>> structures.
>>>
>>> Err, but that's not right either, is it?:  We don't need to apply =20
>>> this
>>> patch in order to continue to define the structures as they're
>>> currently
>>> defined.
>>>
>>> Help! I'm confused!
>>
>> This patch is simply a clean up.  We don't need to use put_unaligned
>> in nsm_init_private.  There is absolutely nothing special about the
>> nsm_private data type that would require this.  It should be accesse=
d
>
> The "special" thing is has not guaranteed alignment.  Hence, any
> access to it must use unaligned-safe methods.
>
>> and modified the way all other RPC opaques are, via memset/memcpy.
>
> What is so special about put_unaligned() that you insist on =20
> replacing it?
>
>> Take a look at http://thread.gmane.org/gmane.linux.nfs/25607 and
>> commit ad5b365c.
>>
>> The controversy is over how to define opaques so they are accessible
>> on both 32- and 64-bit hardware platforms.  My first pass at
>> nsm_init_private worked on 32-bit systems, but broke on 64-bit
>> systems.  An expedient fix for this was to add the put_unaligned in
>> there so 64-bit systems could access the field no matter how it was
>> aligned.  I argue this is unneeded complexity, and inconsistent with
>> the way most other RPC opaques are treated in the kernel.
>>
>> Andrew Morton proposed making RPC opaques a union of u8, u32 (or
>> __be32), and u64 -- the u8 would allow us to treat an opaque as a =20
>> byte
>> array when needed, the u32 would allow access via XDR quads, and the
>> u64 would force 64-bit alignment.  The issues with this are:
>>
>> 1.  Defined this way, opaque fields in data structures will force th=
e
>> encompassing structures to be large enough to honor the alignment
>> requirements of the fields, and
>>
>> 2.  Most other RPC opaques are already defined as character arrays, =
=20
>> so
>> we would have to visit all of them to see if there were issues.
>>
>> If we insist on accessing opaques only via memset() and memcpy()
>> problem 1 goes away and we remain compatible with the traditional
>> definition of an RPC opaque as an array of bytes, on both 64- and 32=
-
>> bit systems.
>
> I still don't see what problem put_unaligned() poses.  Think of it as
> a more efficient memcpy().  We don't want the code to be larger and
> slower than necessary, do we?

The problem put_unaligned() poses is that it's harder to read and =20
comprehend this code.  Why call put_unaligned() here, but not for =20
other RPC opaques, such as nfs4_verifier?  With put_unaligned() =20
readers have to chase down asm/unaligned.h.  With memcpy() it is =20
precisely clear what is going on.

nsm_init_private() is called infrequently, and SM_PRIV_SIZE is just 16 =
=20
bytes.  And, memcpy() on most platforms is careful to do only the =20
unaligned parts with single byte moves.  The rest is usually performed =
=20
by 64-bit copies.  So I think we're talking about a handful of =20
instructions difference here.  It's hardly worth the effort of making =20
this different than how the other opaques are handled.

Again, this is just a clean up.  The current code works.  But I think =20
it's inconsistent with other areas of the code, and harder to =20
understand.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com