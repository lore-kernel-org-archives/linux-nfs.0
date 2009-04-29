From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 19/19] lockd: clean up 64-bit alignment fix in nsm_init_private()
Date: Wed, 29 Apr 2009 11:16:53 -0400
Message-ID: <B08D6051-8FF8-47A4-813E-1420C5545C5C@oracle.com>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net> <20090423233340.17283.29580.stgit@ingres.1015granger.net> <20090428163101.GK17891@fieldses.org> <1AF02847-8D16-4387-81CB-F36969CA9883@oracle.com> <20090428164027.GO17891@fieldses.org> <9A6CA37F-0D4D-48C3-AEF8-E47B2836EDCC@oracle.com> <20090428213638.GL23924@fieldses.org> <CAA58A55-4ED9-4D45-BE54-66DD8CEF191C@oracle.com> <yw1xws94xved.fsf@ps3.mansr.com> <84E7491E-840B-4F1A-A9BD-B74D5D0EB955@oracle.com> <yw1xskjsxuff.fsf@ps3.mansr.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:56317 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754533AbZD2PR1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Apr 2009 11:17:27 -0400
In-Reply-To: <yw1xskjsxuff.fsf-O+uoZmgXk1l54TAoqtyWWQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 28, 2009, at 6:52 PM, M=E5ns Rullg=E5rd wrote:
> Chuck Lever <chuck.lever@oracle.com> writes:
>> On Apr 28, 2009, at 6:31 PM, M=E5ns Rullg=E5rd wrote:
>>> Chuck Lever <chuck.lever@oracle.com> writes:
>>>> On Apr 28, 2009, at 5:36 PM, J. Bruce Fields wrote:
>>>>
>>>>> On Tue, Apr 28, 2009 at 01:24:24PM -0400, Chuck Lever wrote:
>>>>>> On Apr 28, 2009, at 12:40 PM, J. Bruce Fields wrote:
>>>>>>> On Tue, Apr 28, 2009 at 12:35:50PM -0400, Chuck Lever wrote:
>>>>>>>> On Apr 28, 2009, at 12:31 PM, J. Bruce Fields wrote:
>>>>>>>>> On Thu, Apr 23, 2009 at 07:33:40PM -0400, Chuck Lever wrote:
>>>>>>>>>> Recently, commit ad5b365c fixed a data type alignment issue =
=20
>>>>>>>>>> in
>>>>>>>>>> nsm_init_private() by introducing put_unaligned().  We don't
>>>>>>>>>> actually _require_ an unaligned access to nsm_private here.
>>>>>>>>>>
>>>>>>>>>> Instead, we should always use memcpy/memcmp to access the
>>>>>>>>>> contents of RPC opaque data types.  This permits us to
>>>>>>>>>> continue to define these as simple character arrays, as most
>>>>>>>>>> legacy RPC code does, and to rely on gcc to pack the fields =
=20
>>>>>>>>>> in
>>>>>>>>>> in-core structures optimally without breaking on platforms
>>>>>>>>>> that require strict alignment.
>>>>>>>>>
>>>>>>>>> OK, I'm confused.  What structures will get packed =20
>>>>>>>>> differently?
>>>>>>>>
>>>>>>>> Any struct that has an nsm_private embedded in it, such as =20
>>>>>>>> struct
>>>>>>>> nlm_reboot.
>>>>>>>
>>>>>>> I don't see how that or any structure is changed by this patch.
>>>>>>
>>>>>> It's not.  Note the phrase above in the description: "permits =20
>>>>>> us to
>>>>>> _continue_ to define these" -- meaning, I'm not changing the
>>>>>> structures.
>>>>>
>>>>> Err, but that's not right either, is it?:  We don't need to apply
>>>>> this
>>>>> patch in order to continue to define the structures as they're
>>>>> currently
>>>>> defined.
>>>>>
>>>>> Help! I'm confused!
>>>>
>>>> This patch is simply a clean up.  We don't need to use =20
>>>> put_unaligned
>>>> in nsm_init_private.  There is absolutely nothing special about th=
e
>>>> nsm_private data type that would require this.  It should be =20
>>>> accessed
>>>
>>> The "special" thing is has not guaranteed alignment.  Hence, any
>>> access to it must use unaligned-safe methods.
>>>
>>>> and modified the way all other RPC opaques are, via memset/memcpy.
>>>
>>> What is so special about put_unaligned() that you insist on
>>> replacing it?
>>>
>>>> Take a look at http://thread.gmane.org/gmane.linux.nfs/25607 and
>>>> commit ad5b365c.
>>>>
>>>> The controversy is over how to define opaques so they are =20
>>>> accessible
>>>> on both 32- and 64-bit hardware platforms.  My first pass at
>>>> nsm_init_private worked on 32-bit systems, but broke on 64-bit
>>>> systems.  An expedient fix for this was to add the put_unaligned i=
n
>>>> there so 64-bit systems could access the field no matter how it wa=
s
>>>> aligned.  I argue this is unneeded complexity, and inconsistent =20
>>>> with
>>>> the way most other RPC opaques are treated in the kernel.
>>>>
>>>> Andrew Morton proposed making RPC opaques a union of u8, u32 (or
>>>> __be32), and u64 -- the u8 would allow us to treat an opaque as a
>>>> byte
>>>> array when needed, the u32 would allow access via XDR quads, and =20
>>>> the
>>>> u64 would force 64-bit alignment.  The issues with this are:
>>>>
>>>> 1.  Defined this way, opaque fields in data structures will force =
=20
>>>> the
>>>> encompassing structures to be large enough to honor the alignment
>>>> requirements of the fields, and
>>>>
>>>> 2.  Most other RPC opaques are already defined as character
>>>> arrays, so we would have to visit all of them to see if there were
>>>> issues.
>>>>
>>>> If we insist on accessing opaques only via memset() and memcpy()
>>>> problem 1 goes away and we remain compatible with the traditional
>>>> definition of an RPC opaque as an array of bytes, on both 64- and =
=20
>>>> 32-
>>>> bit systems.
>>>
>>> I still don't see what problem put_unaligned() poses.  Think of it =
=20
>>> as
>>> a more efficient memcpy().  We don't want the code to be larger and
>>> slower than necessary, do we?
>>
>> The problem put_unaligned() poses is that it's harder to read and
>> comprehend this code.  Why call put_unaligned() here, but not for
>> other RPC opaques, such as nfs4_verifier?  With put_unaligned()
>> readers have to chase down asm/unaligned.h.  With memcpy() it is
>> precisely clear what is going on.
>
> I thought put_unaligned() was precisely clear when I wrote that code.

In fact it wasn't.  Your patch description and code were so unclear =20
that Andrew Morton chastised all of us for not recognizing that this =20
was a _fix_ that also belonged in -stable:

   --- Quote ---
 > A patch just went upstream for 2.6.30 that addresses that
[ ... commit ad5b365c snipped ... ]

Is this the best way of fixing it?  We'll crash again if some other
code starts to access .data with non-byte-sized accesses.  What makes
this especially risky is that the code will pass testing on x86.

__aligned would be one way.  But it would be far far cleaner to just do


--- a/include/linux/lockd/xdr.h~a
+++ a/include/linux/lockd/xdr.h
@@ -17,7 +17,7 @@
#define SM_PRIV_SIZE		16

struct nsm_private {
-	unsigned char		data[SM_PRIV_SIZE];
+	u64 data[SM_PRIV_SIZE/sizeof(u64)];
};

struct svc_rqst;

all the typecasting and the put_unaligned()s just go away then.
 > but did not mention that it fixed an oops.
That was a fairly significant failing. Guys, please please do remember =
=20
that we're also maintaining the stable kernels. When merging a patch =20
please always think whether it needs to be backported.

   --- End Quote ---

It appears that Andrew did not find your patch to be sufficient.

The fact that you have repeated the "what if SM_PRIV_SIZE changes" =20
argument suggests that you still haven't become familiar with the body =
=20
of this code to see what it does, how it works, and what would be a =20
consistent and correct fix.

> I would have thought anyone working on the kernel would be familiar
> with it, or at the very least be able to guess what it did.

> Your reasoning above is the kind of thing I'd expect in some silly
> corporate environment, not from Linux kernel developers.

How adorable!

We are striving for a code base that is easier to review by people who =
=20
are outside our small community.  I find that goal to be perfectly =20
aligned with the stated goals of Linux kernel developers.

>> Again, this is just a clean up.  The current code works.  But I thin=
k
>> it's inconsistent with other areas of the code, and harder to
>> understand.
>
> I'll leave the decision to the maintainers of the code.

Bruce, please drop patch 19.  A simple clean up like this is not worth =
=20
the heartburn.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com