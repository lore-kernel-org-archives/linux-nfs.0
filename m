From: sfaibish <sfaibish@emc.com>
Subject: Re: Resent: [pnfs][PATCH 0/3] pnfs-blocklayout client: adding support for complex volume structure
Date: Thu, 10 Jun 2010 13:19:48 -0400
Message-ID: <op.vd3g3apeunckof@usensfaibisl2e.eng.emc.com>
References: <op.vdsfeiz2unckof@usensfaibisl2e.eng.emc.com> <4C110849.8000500@panasas.com> <op.vd3gi4n5unckof@usensfaibisl2e.eng.emc.com> <4C111C83.4070209@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15;
	format=flowed	delsp=yes
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Benny Halevy" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:19088 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498Ab0FJRT5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jun 2010 13:19:57 -0400
In-Reply-To: <4C111C83.4070209@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jun 2010 13:10:27 -0400, Benny Halevy <bhalevy@panasas.com> =
=20
wrote:

> On Jun. 10, 2010, 20:07 +0300, sfaibish <sfaibish@emc.com> wrote:
>> On Thu, 10 Jun 2010 11:44:09 -0400, Benny Halevy <bhalevy-C4P08NqkoRmIwRZHo2/mJg@public.gmane.org=
m>
>> wrote:
>>
>>> On Jun. 04, 2010, 21:09 +0300, sfaibish <sfaibish@emc.com> wrote:
>>>> Apply against 2.6.34-rc3 pnfs branch. For pNFS client submission. =
Only
>>>> touches
>>>> the block layout driver.
>>>
>>> Sorin, I suggest you guys test this set with the linux-pnfs 2.6.35-=
rc2
>>> tree
>> We already tested the patches and they work in our QA lab before we =
sent
>> the
>> patches. We also tested in our labs in France. We used F13 as the ba=
se.
>>
>>> against both the EMC and the spnfs-block server in the Ann Arbor
>> As I mentioned in the patch at this time the spnfs block server does=
n't
>> support complex structures. After we get the pnfs client patches in =
the
>> git we will work to implement the complex volumes support in the spn=
fs
>> server. In principle the testing was done with EMC pnfs server and a=
ll
>> the cthon tests passed so this is what we would do at BAT anyways.
>> I have VM with the code so, if Bruce can have a VM client with the
>> patches we have the pnfs server of EMC in CITI lab.
>>
>
> OK, but I want to sure the new code is backward compatible with
> the spnfs-block server, as it is today.
Yes, that we also tested and we were passing the cthon tests as before.
This is part of our QA test suite. We also tested support of single vol=
ume
=46S.

/Sorin

>
> Benny
>
>>> Bakeathon
>>> and resend.
>> Unfortunatelly, I will not be there and I am not sure if the new pNF=
S =20
>> block
>> developer from CITI will be up to speed. I am busy with the next BAT
>> organization.
>>
>>>
>>> I admit I didn't review this thoroughly yet and hopefully we can fi=
nd
>>> some
>>> time to do it together in Ann Arbor.
>>   :(
>>
>>>
>>> Benny
>>>
>>>>
>>>> This patch set implements support for the complex volumes structur=
es
>>>> such
>>>> as
>>>> stripe of multiple volumes in a single metavolume and slice of
>>>> metavolumes
>>>> into
>>>> smaller metavolumes. The patch set is specific to pnfs blocklayout=
 and
>>>> uses
>>>> simple rpc pipefs to generate messages that are passed to the user=
land
>>>> which is
>>>> using an daemon to discover all the devices in the message. The
>>>> userspace
>>>> daemon
>>>> patches will be sent in a separate patch set.
>>>>
>>>> The patch set replaces the current single volume implementation of=
 the
>>>> pnfs blocklayout
>>>> that has performance limitations and cannot support wide striped f=
ile
>>>> systems.
>>>> The wide stripe is imperious to the performance scalability both f=
or
>>>> single and multiple
>>>> clients configurations. These patches address only the pnfs =20
>>>> blocklayout
>>>> client. Similar
>>>> patches will be implemented for the pnfsd block layout served in t=
he
>>>> second phase.
>>>>
>>>> 0001-pnfs-block-layout-add-simple-rpc-pipefs.patch
>>>> 0002-pnfs-block-layout-remove-device-creation-or-remove-from-kerne=
l.patch
>>>> 0003-pnfs-block-layout-add-block-device-pipe-processing-based-on-s=
imple-rpc.patch
>>>>
>>>> Testing:
>>>> CONFIG_NFS_V4_1 set:
>>>>
>>>> NFSv4.1/pNFS mounts:
>>>> Connectathon tests pass against Celerra/pNFS block layout server w=
ith
>>>> both
>>>> simple
>>>> volumes and complex volumes stripe on 4 volumes and using a slice =
of
>>>> half
>>>> of the
>>>> striped metavolume.
>>>>
>>>> CONFIG_NFS_V4_1 not set:
>>>> NFSv4.0 mount passes Connectathon tests.
>>>>
>>>> /Sorin
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nf=
s" =20
>>>> in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>



--=20
Best Regards

Sorin Faibish
Corporate Distinguished Engineer
Network Storage Group

         EMC=B2
where information lives

Phone: 508-435-1000 x 48545
Cellphone: 617-510-0422
Email : sfaibish@emc.com
