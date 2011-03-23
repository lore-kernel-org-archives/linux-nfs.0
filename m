Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gerard.telenet-ops.be ([195.130.132.48]:47126 "EHLO
	gerard.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754042Ab1CWSEc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 14:04:32 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.boven.lan (Postfix) with SMTP id 1467DD15
	for <linux-nfs@vger.kernel.org>; Wed, 23 Mar 2011 19:04:29 +0100 (CET)
Message-ID: <4D8A3628.9040506@telenet.be>
Date: Wed, 23 Mar 2011 19:04:24 +0100
From: Tom Boven <tom.boven@telenet.be>
To: Kevin Coffman <kwc@citi.umich.edu>
CC: linux-nfs@vger.kernel.org, 619052@bugs.debian.org,
        Bones <bones_was_here@yahoo.com.au>, Luk Claes <luk@debian.org>,
        =?ISO-8859-1?Q?An=EDbal_Monsalve_Salazar?= <anibal@debian.org>
Subject: Re: rpc.gssd: double free or corruption
References: <AANLkTik72b2H3yVx7-YcE1Bmp73LboMzZ+DSOjww=RS0@mail.gmail.com>	<20110323000925.GA6353@master.debian.org> <AANLkTimX=F3gk2_optA5pX315vpPARuP0DsgmBy0YXbO@mail.gmail.com>
In-Reply-To: <AANLkTimX=F3gk2_optA5pX315vpPARuP0DsgmBy0YXbO@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Op 23-03-11 16:32, Kevin Coffman schreef:
> 2011/3/22 Aníbal Monsalve Salazar<anibal@debian.org>:
>    
>> On Wed, Mar 16, 2011 at 09:28:04PM -0400, Kevin Coffman wrote:
>>      
>>> A new version of library libgssglue is now available from:
>>>
>>> http://www.citi.umich.edu/projects/nfsv4/linux/libgssglue/libgssglue-0.2.tar.gz
>>>
>>> Changes since libgssglue-0.1:
>>>
>>>        * Modify the gss_acquire_cred() code to accept, and
>>>          properly handle, an input name of GSS_C_NO_NAME.
>>>          Other misc. changes to support this change.
>>>        * Remove some generated files from git.  Change
>>>          autogen.sh to clean up files that might become
>>>          outdated and incompatible.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>        
>> Hello Kevin,
>>
>> Please have a look at Debian bug#619052.
>>
>> http://bugs.debian.org/619052
>>
>> The attached file is the original bug report.
>>
>> Thank you,
>>
>> Aníbal
>>      
> Hi,
> So far, I'm stumped.  I've been unable to reproduce this on my Fedora
> 13 machine.  I have a slightly different version of libc, an earlier
> version of kerberos, and a later version of nfs-utils (the pnfs
> version).  I went back to stock versions of everything and simply
> replaced libgssglue with the new version.
>
> glibc-2.12.2-1.x86_64
> krb5-libs-1.7.1-17.fc13.x86_64
> krb5-debuginfo-1.7.1-17.fc13.x86_64
> krb5-auth-dialog-0.15-1.fc13.x86_64
> krb5-workstation-1.7.1-17.fc13.x86_64
> pam_krb5-2.3.11-1.fc13.x86_64
> krb5-devel-1.7.1-17.fc13.x86_64
> nfs-utils-lib-devel-1.1.5-1.fc13.x86_64
> nfs-utils-1.2.3-2.pnfs.fc15.x86_64
> nfs-utils-lib-1.1.5-1.fc13.x86_64
> nfs-utils-lib-debuginfo-1.1.5-1.fc13.x86_64
>
> Are you using any special options to gssd?
>
> K.C.
>
>    
I've just checked but no, I don't use any option at all to start rpc.gssd

Tom

