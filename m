Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752448Ab1CEVmH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Mar 2011 16:42:07 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p25Lg7KE009602
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sat, 5 Mar 2011 16:42:07 -0500
Message-ID: <4D72AE2E.2040700@RedHat.com>
Date: Sat, 05 Mar 2011 16:42:06 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Masatake YAMATO <yamato@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] Read /etc/exports.d/*.export as extra export files
References: <4D6FFF80.6030102@RedHat.com>	<20110304.151026.946624858093159104.yamato@redhat.com>	<4D7111A2.9050700@RedHat.com> <20110306.015430.825430197519907711.yamato@redhat.com>
In-Reply-To: <20110306.015430.825430197519907711.yamato@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 03/05/2011 11:54 AM, Masatake YAMATO wrote:
> On Fri, 04 Mar 2011 11:21:54 -0500, Steve Dickson <SteveD@redhat.com> wrote
>>
>>
>> On 03/04/2011 01:10 AM, Masatake YAMATO wrote:
>>> Hi,
>>>
>>> thank you for replying.
>> Again.. my apologies for taking so long... 
>>
>>>
>>>> On 03/03/2011 09:01 AM, Masatake YAMATO wrote:
>>>>> No comment?
>>>> Sorry about that... I was traveling for the couple weeks... 
>>>>
>>>> Would you happen to have an example script on how 
>>>> this new feature would be used? I just want to run 
>>>> some quick tests...
>>>>
>>>> tia,
>>>>
>>>> steved.
>>>
>>> Could you try following one?
>>>
>>> # cd /tmp
>>> # mkdir /tmp/alpha
>>> # mkdir /tmp/beta
>>> # mkdir /etc/exports.d
>>> # mkdir /etc/exports.d
>>> # echo '/tmp/alpha *(ro)' > /etc/exports.d/alpha.export
>>> # echo '/tmp/beta *(ro)'  > /etc/exports.d/beta.export
>>> # /etc/init.d nfs restart
>>>
>>> After above setting up, when you do `exportfs', following lines 
>>> may be included in the output:
>>>
>>>     /tmp/alpha	 <world>
>>>     /tmp/beta        <world>
>> Question... Where is the race? Meaning who is reading the exports
>> file while its being modified?
> 
> Sorry, I don't understand well. Are you talking about race condition
> introduced with my patch?
I thought you were doing this because some one trying to read
the exports as they were being updated... but after reading 
your entire email I see I was mistaken... 

> 
>> The reason I ask is exporting (or re-exporting) pretty serial:
>>
>> exportfs read /etc/exports
>> exportfs writes the new exports to /var/lib/nfs/etab
>> mountd notices etab has changed and rereads its.
>> mountd flush the kernel cache cause the kernel to do upcalls to get the new exports.
> 
> With my patch doesn't change match this sequence:
> 
> (S1) exportfs read /etc/exports
> (S2) exportfs read /etc/exports.d/*.export 
> (S3) exportfs writes the new exports to /var/lib/nfs/etab
> (S4) mountd notices etab has changed and rereads its.
> (S5) mountd flush the kernel cache cause the kernel to do upcalls to get the new exports.
> 
> I've added (Sn) to make discussion easier. I've just added S2 stage.
>  
>> So since exportfs command not a daemon I don't see why 
>>    cp exports.new /etc/exports && exportfs -arv
>>
>> isn't all that is needed.  What am I missing?
> 
> Consider the case when an user wants to add following entry to /etc/exports:
> 
> 	 '/tmp/alpha *(ro)'
> 
> How one will do? Without my patch I image following sequence (sequence 1).
> 
>     cp /etc/exports exports.new
>     echo '/tmp/alpha *(ro)' >> exports.new
>     cp exports.new /etc/exports && exportfs -arv    
> 
> With my patch this sequence becomes simplified as (sequence 1'):
> 
>      echo '/tmp/alpha *(ro)' > /etc/exports.d/alpha.export
>      exportfs -arv    
> 
> When duplicated entries must be considered the sequence 1 may become
> more complex.
> 
> 
> Next, consider removing the export entry from /etc/exports.
> Without my patch I image following sequence (sequence 2).
> 
>     cp /etc/exports exports.old
>     grep -v '/tmp/alpha *(ro)' < exports.old > /etc/exports
>     exportfs -arv        
> 
> With my patch this sequence becomes simplified as (sequence 2'):
>     rm /etc/exports.d/alpha.export
>     exportfs -arv 
I understand and its a good idea.. thanks for the explanation...

> 
> 
> More background I'm thinking expanding the area of utilizing rpm package
> in system management. Consider installing an export entry to a system
> via rpm package. Without my patch you have to write down sequence 1
> to %post and sequence 2 to %postun of the spec file. With my patch
> you have to just put /etc/exports.d/alpha.export to %files section.
> 
> This story of rpm is just my application. However, I thik my patch may be
> useful for other purposes. 
I agree but I do have a question on the first patch which I will ask
in replay to that email...

Thanks again!

steved.
