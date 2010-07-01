From: sfaibish <sfaibish@emc.com>
Subject: Re: mount - Fedora13 - Nfsv4.1 mode
Date: Thu, 01 Jul 2010 12:30:43 -0400
Message-ID: <op.ve6ath0runckof@usensfaibisl2e.eng.emc.com>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6D1@us-email.terastack.bluearc.com> <4C2CA404.601@panasas.com> <A062FCC8662DA848949F7C3046B9BEAE01F3A6E1@us-email.terastack.bluearc.com> <4C2CC154.608@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15;
	format=flowed	delsp=yes
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:30709 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826Ab0GAQaz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 12:30:55 -0400
Received: from hop04-l1d11-si02.isus.emc.com (HOP04-L1D11-SI02.isus.emc.com [10.254.111.55])
	by mexforward.lss.emc.com (Switch-3.3.2/Switch-3.1.7) with ESMTP id o61GUsPv027700
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 1 Jul 2010 12:30:54 -0400
Received: from mailhub.lss.emc.com (numailhub.lss.emc.com [10.254.144.16]) by hop04-l1d11-si02.isus.emc.com (RSA Interceptor) for <linux-nfs@vger.kernel.org>; Thu, 1 Jul 2010 12:30:43 -0400
Received: from usensfaibisl2e.eng.emc.com (USENSFAIBISL2E.eng.emc.com [10.240.12.52])
	by mailhub.lss.emc.com (Switch-3.4.2/Switch-3.3.2mp) with ESMTP id o61GUhaA023150
	for <linux-nfs@vger.kernel.org>; Thu, 1 Jul 2010 12:30:43 -0400
In-Reply-To: <4C2CC154.608-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do we have a call today?

/Sorin

On Thu, 01 Jul 2010 12:24:52 -0400, Steve Dickson <SteveD@redhat.com> =20
wrote:

>
>
> On 07/01/2010 10:24 AM, Sandeep Joshi wrote:
>> I am using fedora version from SteveD's website
>>
>> 2.6.33.5-112.2.2.pnfs.fc13.x86_64
>>
>> I guess I have to upgrade.
> hmm... that kernel is based on the pnfs-all-2_6_35-2010-06-01
> release which I guess that is a bit old...
>
> Benny should I go ahead a update to  pnfs-all-2.6.35-rc3-2010-06-21
> or wait for the next release?
>
> steved.
>
>>
>> regards,
>> Sandeep
>>
>>
>> -----Original Message-----
>> From: Benny Halevy [mailto:bhalevy@panasas.com]
>> Sent: Thu 7/1/2010 7:19 AM
>> To: Sandeep Joshi
>> Cc: linux-nfs@vger.kernel.org
>> Subject: Re: mount - Fedora13 - Nfsv4.1 mode
>>
>> What version of the kernel are you using?
>> I sent a patchset that fixes this:
>> http://marc.info/?l=3Dlinux-nfs&m=3D127678603202678&w=3D2
>> That's in the latest linux-pnfs tree
>> at tag pnfs-all-2.6.35-rc3-2010-06-21
>>
>> Benny
>>
>> On Jul. 01, 2010, 0:15 +0300, "Sandeep Joshi" <sjoshi-Pe6u2o1+k2hBDgjK7y7TUQ@public.gmane.org> =20
>> wrote:
>>> I am using  NFS 4.1 client with nfslayoutdriver loaded. (using Fedo=
ra =20
>>> 13)
>>> If I try to mount the same directory twice from client. I see two =20
>>> exchange id's
>>> being sent to server. I was expecting only one exchange id.
>>>
>>> Here are the steps that I am executing:
>>>
>>> modprobe nfslayoutdriver
>>> mount -t nfs4 -o minorversion=3D1 <serv-ip-address>:/ /mnt/<dir>
>>> mount -t nfs4 -o minorversion=3D1 <serv-ip-address>:/ /mnt/<dir>
>>>
>>> Is this expected behavior?
>>>
>>>
>>> regards,
>>>
>>> Sandeep
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
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
