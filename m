From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 19/19] lockd: clean up 64-bit alignment fix in nsm_init_private()
Date: Tue, 28 Apr 2009 18:11:06 -0400
Message-ID: <CAA58A55-4ED9-4D45-BE54-66DD8CEF191C@oracle.com>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net> <20090423233340.17283.29580.stgit@ingres.1015granger.net> <20090428163101.GK17891@fieldses.org> <1AF02847-8D16-4387-81CB-F36969CA9883@oracle.com> <20090428164027.GO17891@fieldses.org> <9A6CA37F-0D4D-48C3-AEF8-E47B2836EDCC@oracle.com> <20090428213638.GL23924@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, Mans Rullgard <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:42259 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754274AbZD1WLX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 18:11:23 -0400
In-Reply-To: <20090428213638.GL23924@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 28, 2009, at 5:36 PM, J. Bruce Fields wrote:

> On Tue, Apr 28, 2009 at 01:24:24PM -0400, Chuck Lever wrote:
>> On Apr 28, 2009, at 12:40 PM, J. Bruce Fields wrote:
>>> On Tue, Apr 28, 2009 at 12:35:50PM -0400, Chuck Lever wrote:
>>>> On Apr 28, 2009, at 12:31 PM, J. Bruce Fields wrote:
>>>>> On Thu, Apr 23, 2009 at 07:33:40PM -0400, Chuck Lever wrote:
>>>>>> Recently, commit ad5b365c fixed a data type alignment issue in
>>>>>> nsm_init_private() by introducing put_unaligned().  We don't
>>>>>> actually
>>>>>> _require_ an unaligned access to nsm_private here.
>>>>>>
>>>>>> Instead, we should always use memcpy/memcmp to access the
>>>>>> contents of
>>>>>> RPC opaque data types.  This permits us to continue to define  
>>>>>> these
>>>>>> as
>>>>>> simple character arrays, as most legacy RPC code does, and to
>>>>>> rely on
>>>>>> gcc to pack the fields in in-core structures optimally without
>>>>>> breaking
>>>>>> on platforms that require strict alignment.
>>>>>
>>>>> OK, I'm confused.  What structures will get packed differently?
>>>>
>>>> Any struct that has an nsm_private embedded in it, such as struct
>>>> nlm_reboot.
>>>
>>> I don't see how that or any structure is changed by this patch.
>>
>> It's not.  Note the phrase above in the description: "permits us to
>> _continue_ to define these" -- meaning, I'm not changing the  
>> structures.
>
> Err, but that's not right either, is it?:  We don't need to apply this
> patch in order to continue to define the structures as they're  
> currently
> defined.
>
> Help! I'm confused!

This patch is simply a clean up.  We don't need to use put_unaligned  
in nsm_init_private.  There is absolutely nothing special about the  
nsm_private data type that would require this.  It should be accessed  
and modified the way all other RPC opaques are, via memset/memcpy.

Take a look at http://thread.gmane.org/gmane.linux.nfs/25607 and  
commit ad5b365c.

The controversy is over how to define opaques so they are accessible  
on both 32- and 64-bit hardware platforms.  My first pass at  
nsm_init_private worked on 32-bit systems, but broke on 64-bit  
systems.  An expedient fix for this was to add the put_unaligned in  
there so 64-bit systems could access the field no matter how it was  
aligned.  I argue this is unneeded complexity, and inconsistent with  
the way most other RPC opaques are treated in the kernel.

Andrew Morton proposed making RPC opaques a union of u8, u32 (or  
__be32), and u64 -- the u8 would allow us to treat an opaque as a byte  
array when needed, the u32 would allow access via XDR quads, and the  
u64 would force 64-bit alignment.  The issues with this are:

1.  Defined this way, opaque fields in data structures will force the  
encompassing structures to be large enough to honor the alignment  
requirements of the fields, and

2.  Most other RPC opaques are already defined as character arrays, so  
we would have to visit all of them to see if there were issues.

If we insist on accessing opaques only via memset() and memcpy()  
problem 1 goes away and we remain compatible with the traditional  
definition of an RPC opaque as an array of bytes, on both 64- and 32- 
bit systems.

The description for this patch can be rewritten this way:

"Clean up: There is nothing special about the nsm_private data type  
that requires the use of put_unaligned() to access it.  Rewrite  
nsm_init_private so it accesses nsm_private the way other code  
accesses other RPC opaques.

See kernel bugzilla 12995."

>> It has been suggested that we use a union or __aligned attribute  
>> for RPC
>> opaques.  The problem with that is that it would cause structs like
>> nlm_reboot to balloon in size; char x[] is aligned on bytes, but a  
>> union
>> of u8, u32, and u64 would be aligned on a double-word boundary.  That
>> would make such structures larger.
>
> OK, I agree, so let's not do that.
>
>
> --b.
>
>> Legacy RPC code, and any code generated by rpcgen, generally  
>> defines an
>> opaque as a character array.  So again, using a union would be
>> inconsistent with other uses of RPC opaques.
>>
>> The point is we want to define and access RPC opaque's consistently,
>> using memset() and memcpy(), since these are nothing more than byte
>> arrays.  The code in nsm_init_private() was an exception to this,  
>> for no
>> reason.  We don't really need special alignment macros in there, as  
>> long
>> as we access the RPC opaque field with the byte sets and copies.
>>
>> Would it help if I described this patch as a "clean up" ?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




