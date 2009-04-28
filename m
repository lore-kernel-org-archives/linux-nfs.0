From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 19/19] lockd: clean up 64-bit alignment fix in nsm_init_private()
Date: Tue, 28 Apr 2009 18:14:20 -0400
Message-ID: <DDD0EA71-D48C-4F39-BC37-ABFBA742F7C2@oracle.com>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net> <20090423233340.17283.29580.stgit@ingres.1015granger.net> <20090428163101.GK17891@fieldses.org> <1AF02847-8D16-4387-81CB-F36969CA9883@oracle.com> <20090428164027.GO17891@fieldses.org> <9A6CA37F-0D4D-48C3-AEF8-E47B2836EDCC@oracle.com> <20090428213638.GL23924@fieldses.org> <yw1x63gozb9f.fsf@ps3.mansr.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: linux-nfs@vger.kernel.org
To: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:17769 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbZD1WO2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 18:14:28 -0400
In-Reply-To: <yw1x63gozb9f.fsf-O+uoZmgXk1l54TAoqtyWWQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 28, 2009, at 6:03 PM, M=E5ns Rullg=E5rd wrote:

> "J. Bruce Fields" <bfields@fieldses.org>
> writes:
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
>>>>>>> contents of RPC opaque data types.  This permits us to continue
>>>>>>> to define these as simple character arrays, as most legacy RPC
>>>>>>> code does, and to rely on gcc to pack the fields in in-core
>>>>>>> structures optimally without breaking on platforms that require
>>>>>>> strict alignment.
>>>>>>
>>>>>> OK, I'm confused.  What structures will get packed differently?
>>>>>
>>>>> Any struct that has an nsm_private embedded in it, such as struct
>>>>> nlm_reboot.
>>>>
>>>> I don't see how that or any structure is changed by this patch.
>>>
>>> It's not.  Note the phrase above in the description: "permits us to
>>> _continue_ to define these" -- meaning, I'm not changing the =20
>>> structures.
>>
>> Err, but that's not right either, is it?:  We don't need to apply =20
>> this
>> patch in order to continue to define the structures as they're =20
>> currently
>> defined.
>>
>> Help! I'm confused!
>
> I too fail to see the reasoning with the memcpy().  It achieves
> exactly the same end result using twice as much work.

Well, OK, but then you might want to review all the other places we =20
use memcpy() to access an RPC opaque field.  There's no reason to =20
treat nsm_private any differently than, say, an NFS readdir cookie.  =20
If there is, then it should be documented here.

> Also, what if
> SM_PRIV_SIZE is ever increased?  Then it will be copying "random" dat=
a
> from the stack into the nsm_private data.  This strikes me as a littl=
e
> fragile.

SM_PRIV_SIZE is a size defined by the NSM network protocol.  It will =20
never change.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com