From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 19/19] lockd: clean up 64-bit alignment fix in nsm_init_private()
Date: Wed, 29 Apr 2009 19:02:37 +0100
Message-ID: <yw1xr5zbwd6q.fsf@ps3.mansr.com>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
	<20090423233340.17283.29580.stgit@ingres.1015granger.net>
	<20090428163101.GK17891@fieldses.org>
	<1AF02847-8D16-4387-81CB-F36969CA9883@oracle.com>
	<20090428164027.GO17891@fieldses.org>
	<9A6CA37F-0D4D-48C3-AEF8-E47B2836EDCC@oracle.com>
	<20090428213638.GL23924@fieldses.org>
	<CAA58A55-4ED9-4D45-BE54-66DD8CEF191C@oracle.com>
	<yw1xws94xved.fsf@ps3.mansr.com>
	<84E7491E-840B-4F1A-A9BD-B74D5D0EB955@oracle.com>
	<yw1xskjsxuff.fsf@ps3.mansr.com>
	<B08D6051-8FF8-47A4-813E-1420C5545C5C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	akpm@linux-foundation.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agrajag.mansr.com ([78.86.181.102]:41906 "EHLO mail.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779AbZD2SCj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Apr 2009 14:02:39 -0400
In-Reply-To: <B08D6051-8FF8-47A4-813E-1420C5545C5C@oracle.com> (Chuck Lever's message of "Wed, 29 Apr 2009 11:16:53 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever <chuck.lever@oracle.com> writes:

> On Apr 28, 2009, at 6:52 PM, M=E5ns Rullg=E5rd wrote:
>> Chuck Lever <chuck.lever@oracle.com> writes:
>>> On Apr 28, 2009, at 6:31 PM, M=E5ns Rullg=E5rd wrote:
>>>> Chuck Lever <chuck.lever@oracle.com> writes:
>>>>> On Apr 28, 2009, at 5:36 PM, J. Bruce Fields wrote:
>>>>>
>>>>>> On Tue, Apr 28, 2009 at 01:24:24PM -0400, Chuck Lever wrote:
>>>>>>> On Apr 28, 2009, at 12:40 PM, J. Bruce Fields wrote:
>>>>>>>> On Tue, Apr 28, 2009 at 12:35:50PM -0400, Chuck Lever wrote:
>>>>>>>>> On Apr 28, 2009, at 12:31 PM, J. Bruce Fields wrote:
>>>>>>>>>> On Thu, Apr 23, 2009 at 07:33:40PM -0400, Chuck Lever wrote:
>>>>>>>>>>> Recently, commit ad5b365c fixed a data type alignment issue
>>>>>>>>>>> in
>>>>>>>>>>> nsm_init_private() by introducing put_unaligned().  We don'=
t
>>>>>>>>>>> actually _require_ an unaligned access to nsm_private here.
>>>>>>>>>>>
>>>>>>>>>>> Instead, we should always use memcpy/memcmp to access the
>>>>>>>>>>> contents of RPC opaque data types.  This permits us to
>>>>>>>>>>> continue to define these as simple character arrays, as mos=
t
>>>>>>>>>>> legacy RPC code does, and to rely on gcc to pack the fields
>>>>>>>>>>> in
>>>>>>>>>>> in-core structures optimally without breaking on platforms
>>>>>>>>>>> that require strict alignment.
>>>>>>>>>>
>>>>>>>>>> OK, I'm confused.  What structures will get packed
>>>>>>>>>> differently?
>>>>>>>>>
>>>>>>>>> Any struct that has an nsm_private embedded in it, such as
>>>>>>>>> struct
>>>>>>>>> nlm_reboot.
>>>>>>>>
>>>>>>>> I don't see how that or any structure is changed by this patch=
=2E
>>>>>>>
>>>>>>> It's not.  Note the phrase above in the description: "permits
>>>>>>> us to
>>>>>>> _continue_ to define these" -- meaning, I'm not changing the
>>>>>>> structures.
>>>>>>
>>>>>> Err, but that's not right either, is it?:  We don't need to appl=
y
>>>>>> this
>>>>>> patch in order to continue to define the structures as they're
>>>>>> currently
>>>>>> defined.
>>>>>>
>>>>>> Help! I'm confused!
>>>>>
>>>>> This patch is simply a clean up.  We don't need to use
>>>>> put_unaligned
>>>>> in nsm_init_private.  There is absolutely nothing special about t=
he
>>>>> nsm_private data type that would require this.  It should be
>>>>> accessed
>>>>
>>>> The "special" thing is has not guaranteed alignment.  Hence, any
>>>> access to it must use unaligned-safe methods.
>>>>
>>>>> and modified the way all other RPC opaques are, via memset/memcpy=
=2E
>>>>
>>>> What is so special about put_unaligned() that you insist on
>>>> replacing it?
>>>>
>>>>> Take a look at http://thread.gmane.org/gmane.linux.nfs/25607 and
>>>>> commit ad5b365c.
>>>>>
>>>>> The controversy is over how to define opaques so they are
>>>>> accessible
>>>>> on both 32- and 64-bit hardware platforms.  My first pass at
>>>>> nsm_init_private worked on 32-bit systems, but broke on 64-bit
>>>>> systems.  An expedient fix for this was to add the put_unaligned =
in
>>>>> there so 64-bit systems could access the field no matter how it w=
as
>>>>> aligned.  I argue this is unneeded complexity, and inconsistent
>>>>> with
>>>>> the way most other RPC opaques are treated in the kernel.
>>>>>
>>>>> Andrew Morton proposed making RPC opaques a union of u8, u32 (or
>>>>> __be32), and u64 -- the u8 would allow us to treat an opaque as a
>>>>> byte
>>>>> array when needed, the u32 would allow access via XDR quads, and
>>>>> the
>>>>> u64 would force 64-bit alignment.  The issues with this are:
>>>>>
>>>>> 1.  Defined this way, opaque fields in data structures will force
>>>>> the
>>>>> encompassing structures to be large enough to honor the alignment
>>>>> requirements of the fields, and
>>>>>
>>>>> 2.  Most other RPC opaques are already defined as character
>>>>> arrays, so we would have to visit all of them to see if there wer=
e
>>>>> issues.
>>>>>
>>>>> If we insist on accessing opaques only via memset() and memcpy()
>>>>> problem 1 goes away and we remain compatible with the traditional
>>>>> definition of an RPC opaque as an array of bytes, on both 64- and
>>>>> 32-
>>>>> bit systems.
>>>>
>>>> I still don't see what problem put_unaligned() poses.  Think of it
>>>> as
>>>> a more efficient memcpy().  We don't want the code to be larger an=
d
>>>> slower than necessary, do we?
>>>
>>> The problem put_unaligned() poses is that it's harder to read and
>>> comprehend this code.  Why call put_unaligned() here, but not for
>>> other RPC opaques, such as nfs4_verifier?  With put_unaligned()
>>> readers have to chase down asm/unaligned.h.  With memcpy() it is
>>> precisely clear what is going on.
>>
>> I thought put_unaligned() was precisely clear when I wrote that code=
=2E
>
> In fact it wasn't.  Your patch description and code were so unclear

I demand an apology for that.  There is absolutely nothing about the
patch or the description that is the slightest bit unclear to anyone
with a decent knowledge of C and half a brain.

> that Andrew Morton chastised all of us for not recognizing that this
> was a _fix_ that also belonged in -stable:

I didn't realise it fixed an oops on some machines.  I only saw a
warning since the trap handler fixed the unaligned on access on both
ARM and Alpha.

>   --- Quote ---
>> A patch just went upstream for 2.6.30 that addresses that
> [ ... commit ad5b365c snipped ... ]
>
> Is this the best way of fixing it?  We'll crash again if some other
> code starts to access .data with non-byte-sized accesses.  What makes
> this especially risky is that the code will pass testing on x86.
>
> __aligned would be one way.  But it would be far far cleaner to just =
do
>
> --- a/include/linux/lockd/xdr.h~a
> +++ a/include/linux/lockd/xdr.h
> @@ -17,7 +17,7 @@
> #define SM_PRIV_SIZE		16
>
> struct nsm_private {
> -	unsigned char		data[SM_PRIV_SIZE];
> +	u64 data[SM_PRIV_SIZE/sizeof(u64)];
> };
>
> struct svc_rqst;
>
> all the typecasting and the put_unaligned()s just go away then.

You already rejected this due to the inflation of struct sizes it
would cause, a viewpoint I am inclined to agree with unless the
structs in question can be rearranged to avoid it.  Depending on the
number of these objects involved, and the frequency of access to them,
I could probably be persuaded either way.

>> but did not mention that it fixed an oops.
> That was a fairly significant failing. Guys, please please do remembe=
r
> that we're also maintaining the stable kernels. When merging a patch
> please always think whether it needs to be backported.

I did consider this, and since I did not experience an oops, I did not
think it would be necessary.

> It appears that Andrew did not find your patch to be sufficient.

That is not how I interpret what he said.  The patch clearly fixes the
*current* issue.  Andrew was concerned that similar errors might show
up again in the future unless the field was made aligned.  The fact
that it happened once is evidence that these concerns are valid and
should be addressed.  This does not imply that an immediate fix for an
oops (as it turns out to be) should be delayed while a broader fix is
developed.  Even less does it imply that a "cleanup" of the working
code is warranted before a final decision has been reached.

> The fact that you have repeated the "what if SM_PRIV_SIZE changes"
> argument suggests that you still haven't become familiar with the bod=
y

No, I did not read hundreds of pages of protocol specifications before
fixing one simple unaligned access in the most obvious way I could
imagine.  Besides, a future revision of the standard could change the
SM_PRIV_SIZE value.

> of this code to see what it does, how it works, and what would be a
> consistent and correct fix.

Your arguments about consistency are nothing short of hypocritical.
Where was consistency when YOU wrote the broken code using pointer
casts and direct assignments rather than the memcpy() you now seem to
cherish so?

=46urthermore, YOU yourself approved my original patch.  How could you
do that if you, as you now claim, did not understand what it did?  Why
did you not request a rewrite using memcpy() then?

>>> Again, this is just a clean up.  The current code works.  But I thi=
nk
>>> it's inconsistent with other areas of the code, and harder to
>>> understand.
>>
>> I'll leave the decision to the maintainers of the code.
>
> Bruce, please drop patch 19.  A simple clean up like this is not wort=
h
> the heartburn.

One man's cleanup is another man's obfuscation, apparently.

--=20
M=E5ns Rullg=E5rd
mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org
