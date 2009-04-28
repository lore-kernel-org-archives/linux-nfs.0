From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 19/19] lockd: clean up 64-bit alignment fix in nsm_init_private()
Date: Tue, 28 Apr 2009 23:03:40 +0100
Message-ID: <yw1x63gozb9f.fsf@ps3.mansr.com>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net> <20090423233340.17283.29580.stgit@ingres.1015granger.net> <20090428163101.GK17891@fieldses.org> <1AF02847-8D16-4387-81CB-F36969CA9883@oracle.com> <20090428164027.GO17891@fieldses.org> <9A6CA37F-0D4D-48C3-AEF8-E47B2836EDCC@oracle.com> <20090428213638.GL23924@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:40842 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754136AbZD1WFI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 18:05:08 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1LyvQE-0002FA-9q
	for linux-nfs@vger.kernel.org; Tue, 28 Apr 2009 22:05:02 +0000
Received: from unicorn.mansr.com ([78.86.181.103])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 28 Apr 2009 22:05:02 +0000
Received: from mans by unicorn.mansr.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 28 Apr 2009 22:05:02 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org>
writes:

> On Tue, Apr 28, 2009 at 01:24:24PM -0400, Chuck Lever wrote:
>> On Apr 28, 2009, at 12:40 PM, J. Bruce Fields wrote:
>>> On Tue, Apr 28, 2009 at 12:35:50PM -0400, Chuck Lever wrote:
>>>> On Apr 28, 2009, at 12:31 PM, J. Bruce Fields wrote:
>>>>> On Thu, Apr 23, 2009 at 07:33:40PM -0400, Chuck Lever wrote:
>>>>>> Recently, commit ad5b365c fixed a data type alignment issue in
>>>>>> nsm_init_private() by introducing put_unaligned().  We don't
>>>>>> actually _require_ an unaligned access to nsm_private here.
>>>>>>
>>>>>> Instead, we should always use memcpy/memcmp to access the
>>>>>> contents of RPC opaque data types.  This permits us to continue
>>>>>> to define these as simple character arrays, as most legacy RPC
>>>>>> code does, and to rely on gcc to pack the fields in in-core
>>>>>> structures optimally without breaking on platforms that require
>>>>>> strict alignment.
>>>>>
>>>>> OK, I'm confused.  What structures will get packed differently?
>>>>
>>>> Any struct that has an nsm_private embedded in it, such as struct
>>>> nlm_reboot.
>>>
>>> I don't see how that or any structure is changed by this patch.
>>
>> It's not.  Note the phrase above in the description: "permits us to =
=20
>> _continue_ to define these" -- meaning, I'm not changing the structu=
res.
>
> Err, but that's not right either, is it?:  We don't need to apply thi=
s
> patch in order to continue to define the structures as they're curren=
tly
> defined.
>
> Help! I'm confused!

I too fail to see the reasoning with the memcpy().  It achieves
exactly the same end result using twice as much work.  Also, what if
SM_PRIV_SIZE is ever increased?  Then it will be copying "random" data
from the stack into the nsm_private data.  This strikes me as a little
fragile.

--=20
M=E5ns Rullg=E5rd
mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org

