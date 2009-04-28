From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 19/19] lockd: clean up 64-bit alignment fix in nsm_init_private()
Date: Tue, 28 Apr 2009 23:31:38 +0100
Message-ID: <yw1xws94xved.fsf@ps3.mansr.com>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
	<20090423233340.17283.29580.stgit@ingres.1015granger.net>
	<20090428163101.GK17891@fieldses.org>
	<1AF02847-8D16-4387-81CB-F36969CA9883@oracle.com>
	<20090428164027.GO17891@fieldses.org>
	<9A6CA37F-0D4D-48C3-AEF8-E47B2836EDCC@oracle.com>
	<20090428213638.GL23924@fieldses.org>
	<CAA58A55-4ED9-4D45-BE54-66DD8CEF191C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agrajag.mansr.com ([78.86.181.102]:39141 "EHLO mail.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752791AbZD1Wip convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 18:38:45 -0400
In-Reply-To: <CAA58A55-4ED9-4D45-BE54-66DD8CEF191C@oracle.com> (Chuck Lever's message of "Tue, 28 Apr 2009 18:11:06 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever <chuck.lever@oracle.com> writes:

> On Apr 28, 2009, at 5:36 PM, J. Bruce Fields wrote:
>
>> On Tue, Apr 28, 2009 at 01:24:24PM -0400, Chuck Lever wrote:
>>> On Apr 28, 2009, at 12:40 PM, J. Bruce Fields wrote:
>>>> On Tue, Apr 28, 2009 at 12:35:50PM -0400, Chuck Lever wrote:
>>>>> On Apr 28, 2009, at 12:31 PM, J. Bruce Fields wrote:
>>>>>> On Thu, Apr 23, 2009 at 07:33:40PM -0400, Chuck Lever wrote:
>>>>>>> Recently, commit ad5b365c fixed a data type alignment issue in
>>>>>>> nsm_init_private() by introducing put_unaligned().  We don't
>>>>>>> actually _require_ an unaligned access to nsm_private here.
>>>>>>>
>>>>>>> Instead, we should always use memcpy/memcmp to access the
>>>>>>> contents of RPC opaque data types.  This permits us to
>>>>>>> continue to define these as simple character arrays, as most
>>>>>>> legacy RPC code does, and to rely on gcc to pack the fields in
>>>>>>> in-core structures optimally without breaking on platforms
>>>>>>> that require strict alignment.
>>>>>>
>>>>>> OK, I'm confused.  What structures will get packed differently?
>>>>>
>>>>> Any struct that has an nsm_private embedded in it, such as struct
>>>>> nlm_reboot.
>>>>
>>>> I don't see how that or any structure is changed by this patch.
>>>
>>> It's not.  Note the phrase above in the description: "permits us to
>>> _continue_ to define these" -- meaning, I'm not changing the
>>> structures.
>>
>> Err, but that's not right either, is it?:  We don't need to apply th=
is
>> patch in order to continue to define the structures as they're
>> currently
>> defined.
>>
>> Help! I'm confused!
>
> This patch is simply a clean up.  We don't need to use put_unaligned
> in nsm_init_private.  There is absolutely nothing special about the
> nsm_private data type that would require this.  It should be accessed

The "special" thing is has not guaranteed alignment.  Hence, any
access to it must use unaligned-safe methods.

> and modified the way all other RPC opaques are, via memset/memcpy.

What is so special about put_unaligned() that you insist on replacing i=
t?

> Take a look at http://thread.gmane.org/gmane.linux.nfs/25607 and
> commit ad5b365c.
>
> The controversy is over how to define opaques so they are accessible
> on both 32- and 64-bit hardware platforms.  My first pass at
> nsm_init_private worked on 32-bit systems, but broke on 64-bit
> systems.  An expedient fix for this was to add the put_unaligned in
> there so 64-bit systems could access the field no matter how it was
> aligned.  I argue this is unneeded complexity, and inconsistent with
> the way most other RPC opaques are treated in the kernel.
>
> Andrew Morton proposed making RPC opaques a union of u8, u32 (or
> __be32), and u64 -- the u8 would allow us to treat an opaque as a byt=
e
> array when needed, the u32 would allow access via XDR quads, and the
> u64 would force 64-bit alignment.  The issues with this are:
>
> 1.  Defined this way, opaque fields in data structures will force the
> encompassing structures to be large enough to honor the alignment
> requirements of the fields, and
>
> 2.  Most other RPC opaques are already defined as character arrays, s=
o
> we would have to visit all of them to see if there were issues.
>
> If we insist on accessing opaques only via memset() and memcpy()
> problem 1 goes away and we remain compatible with the traditional
> definition of an RPC opaque as an array of bytes, on both 64- and 32-
> bit systems.

I still don't see what problem put_unaligned() poses.  Think of it as
a more efficient memcpy().  We don't want the code to be larger and
slower than necessary, do we?

--=20
M=E5ns Rullg=E5rd
mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org
