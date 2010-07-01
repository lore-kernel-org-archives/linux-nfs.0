From: sfaibish <sfaibish@emc.com>
Subject: Re: mount - Fedora13 - Nfsv4.1 mode
Date: Thu, 01 Jul 2010 12:37:28 -0400
Message-ID: <op.ve6a4qmqunckof@usensfaibisl2e.eng.emc.com>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6D1@us-email.terastack.bluearc.com> <4C2CA404.601@panasas.com> <A062FCC8662DA848949F7C3046B9BEAE01F3A6E1@us-email.terastack.bluearc.com> <4C2CC154.608@RedHat.com> <op.ve6ath0runckof@usensfaibisl2e.eng.emc.com> <4C2CC3ED.1010000@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15;
	format=flowed	delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Benny Halevy" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:32426 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752979Ab0GAQhe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 12:37:34 -0400
In-Reply-To: <4C2CC3ED.1010000@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks.

/Sorin

On Thu, 01 Jul 2010 12:35:57 -0400, Benny Halevy <bhalevy@panasas.com> =
=20
wrote:

> No call today as far as I know.
> Bruce asked to skip this week.
> http://marc.info/?l=3Dlinux-nfs&m=3D127739788623079&w=3D2
>
> Benny
>
> On Jul. 01, 2010, 19:30 +0300, sfaibish <sfaibish@emc.com> wrote:
>> Do we have a call today?
>>
>> /Sorin
>>
>> On Thu, 01 Jul 2010 12:24:52 -0400, Steve Dickson <SteveD@redhat.com=
>
>> wrote:
>>
>>>
>>>
>>> On 07/01/2010 10:24 AM, Sandeep Joshi wrote:
>>>> I am using fedora version from SteveD's website
>>>>
>>>> 2.6.33.5-112.2.2.pnfs.fc13.x86_64
>>>>
>>>> I guess I have to upgrade.
>>> hmm... that kernel is based on the pnfs-all-2_6_35-2010-06-01
>>> release which I guess that is a bit old...
>>>
>>> Benny should I go ahead a update to  pnfs-all-2.6.35-rc3-2010-06-21
>>> or wait for the next release?
>>>
>>> steved.
>>>
>>>>
>>>> regards,
>>>> Sandeep
>>>>
>>>>
>>>> -----Original Message-----
>>>> From: Benny Halevy [mailto:bhalevy@panasas.com]
>>>> Sent: Thu 7/1/2010 7:19 AM
>>>> To: Sandeep Joshi
>>>> Cc: linux-nfs@vger.kernel.org
>>>> Subject: Re: mount - Fedora13 - Nfsv4.1 mode
>>>>
>>>> What version of the kernel are you using?
>>>> I sent a patchset that fixes this:
>>>> http://marc.info/?l=3Dlinux-nfs&m=3D127678603202678&w=3D2
>>>> That's in the latest linux-pnfs tree
>>>> at tag pnfs-all-2.6.35-rc3-2010-06-21
>>>>
>>>> Benny
>>>>
>>>> On Jul. 01, 2010, 0:15 +0300, "Sandeep Joshi" <sjoshi-Pe6u2o1+k2hBDgjK7y7TUQ@public.gmane.org>
>>>> wrote:
>>>>> I am using  NFS 4.1 client with nfslayoutdriver loaded. (using Fe=
dora
>>>>> 13)
>>>>> If I try to mount the same directory twice from client. I see two
>>>>> exchange id's
>>>>> being sent to server. I was expecting only one exchange id.
>>>>>
>>>>> Here are the steps that I am executing:
>>>>>
>>>>> modprobe nfslayoutdriver
>>>>> mount -t nfs4 -o minorversion=3D1 <serv-ip-address>:/ /mnt/<dir>
>>>>> mount -t nfs4 -o minorversion=3D1 <serv-ip-address>:/ /mnt/<dir>
>>>>>
>>>>> Is this expected behavior?
>>>>>
>>>>>
>>>>> regards,
>>>>>
>>>>> Sandeep
>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-n=
fs" =20
>>>>> in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.htm=
l
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nf=
s" =20
>>>> in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
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
