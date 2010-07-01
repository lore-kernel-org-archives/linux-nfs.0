From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: mount - Fedora13 - Nfsv4.1 mode
Date: Thu, 01 Jul 2010 19:35:57 +0300
Message-ID: <4C2CC3ED.1010000@panasas.com>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6D1@us-email.terastack.bluearc.com> <4C2CA404.601@panasas.com> <A062FCC8662DA848949F7C3046B9BEAE01F3A6E1@us-email.terastack.bluearc.com> <4C2CC154.608@RedHat.com> <op.ve6ath0runckof@usensfaibisl2e.eng.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: linux-nfs@vger.kernel.org
To: sfaibish <sfaibish@emc.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:45535 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752826Ab0GAQgA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 12:36:00 -0400
In-Reply-To: <op.ve6ath0runckof-sXut7+96orlxdPWQvOaHCoI83tS8F2Zb0E9HWUfgJXw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No call today as far as I know.
Bruce asked to skip this week.
http://marc.info/?l=linux-nfs&m=127739788623079&w=2

Benny

On Jul. 01, 2010, 19:30 +0300, sfaibish <sfaibish@emc.com> wrote:
> Do we have a call today?
> 
> /Sorin
> 
> On Thu, 01 Jul 2010 12:24:52 -0400, Steve Dickson <SteveD@redhat.com>  
> wrote:
> 
>>
>>
>> On 07/01/2010 10:24 AM, Sandeep Joshi wrote:
>>> I am using fedora version from SteveD's website
>>>
>>> 2.6.33.5-112.2.2.pnfs.fc13.x86_64
>>>
>>> I guess I have to upgrade.
>> hmm... that kernel is based on the pnfs-all-2_6_35-2010-06-01
>> release which I guess that is a bit old...
>>
>> Benny should I go ahead a update to  pnfs-all-2.6.35-rc3-2010-06-21
>> or wait for the next release?
>>
>> steved.
>>
>>>
>>> regards,
>>> Sandeep
>>>
>>>
>>> -----Original Message-----
>>> From: Benny Halevy [mailto:bhalevy@panasas.com]
>>> Sent: Thu 7/1/2010 7:19 AM
>>> To: Sandeep Joshi
>>> Cc: linux-nfs@vger.kernel.org
>>> Subject: Re: mount - Fedora13 - Nfsv4.1 mode
>>>
>>> What version of the kernel are you using?
>>> I sent a patchset that fixes this:
>>> http://marc.info/?l=linux-nfs&m=127678603202678&w=2
>>> That's in the latest linux-pnfs tree
>>> at tag pnfs-all-2.6.35-rc3-2010-06-21
>>>
>>> Benny
>>>
>>> On Jul. 01, 2010, 0:15 +0300, "Sandeep Joshi" <sjoshi-Pe6u2o1+k2hBDgjK7y7TUQ@public.gmane.org>  
>>> wrote:
>>>> I am using  NFS 4.1 client with nfslayoutdriver loaded. (using Fedora  
>>>> 13)
>>>> If I try to mount the same directory twice from client. I see two  
>>>> exchange id's
>>>> being sent to server. I was expecting only one exchange id.
>>>>
>>>> Here are the steps that I am executing:
>>>>
>>>> modprobe nfslayoutdriver
>>>> mount -t nfs4 -o minorversion=1 <serv-ip-address>:/ /mnt/<dir>
>>>> mount -t nfs4 -o minorversion=1 <serv-ip-address>:/ /mnt/<dir>
>>>>
>>>> Is this expected behavior?
>>>>
>>>>
>>>> regards,
>>>>
>>>> Sandeep
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
> 
> 
> 
