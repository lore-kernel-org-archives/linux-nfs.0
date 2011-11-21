Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37616 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753698Ab1KUOJZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Nov 2011 09:09:25 -0500
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "<tigran.mkrtchyan@desy.de>" <tigran.mkrtchyan@desy.de>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: server reboot recovery is broken with 3.1 (3.2?) with nfsv41
 clients
Date: Mon, 21 Nov 2011 14:08:59 +0000
Message-ID: <BDBD055B-D003-4FFA-A604-7A30F3DC81CC@netapp.com>
References: <CAGue13oSMCs=mSMHsX2f_=+Eqc3i3rG8vkq0rSnMTm_sqpwcnw@mail.gmail.com>
 <081C1E0B-795E-4138-B66A-479F73BB3AC5@netapp.com>
 <CAGue13pFCq22xUmJny7+7czc8WkPhjos2A+_BombOf3G8icwJA@mail.gmail.com>
 <CAGue13r+vZRkmpiHVPodyoYXt+SVCfDdgHJOF74TmL5=ci=q1w@mail.gmail.com>
 <CAGue13pkwG=S-yXQFUGLv9JMN0s7jXjFgL21LHw-6dVECQOzdA@mail.gmail.com>
In-Reply-To: <CAGue13pkwG=S-yXQFUGLv9JMN0s7jXjFgL21LHw-6dVECQOzdA@mail.gmail.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK. I'll look into it today.

-->Andy

On Nov 21, 2011, at 5:05 AM, Tigran Mkrtchyan wrote:

> On Mon, Nov 21, 2011 at 10:51 AM, Tigran Mkrtchyan
> <tigran.mkrtchyan@desy.de> wrote:
>> RHEL6.2 has the same issue. I just rebooted server (mds + ds) during read.
>> 
>> Kernel thread dump attached.
>> 
>> Tigran.
>> 
>> On Fri, Nov 18, 2011 at 5:09 PM, Tigran Mkrtchyan
>> <tigran.mkrtchyan@desy.de> wrote:
>>> Both!
>>> 
>>> On Fri, Nov 18, 2011 at 3:08 PM, Adamson, Andy
>>> <William.Adamson@netapp.com> wrote:
>>>> 
>>>> On Nov 18, 2011, at 8:57 AM, Tigran Mkrtchyan wrote:
>>>> 
>>>>> Dear  nfs hackers,
>>>>> 
>>>>> it looks like with kernel 3.1 client cant recover from server reboots.
>>>>> The nfs mount hangs and there are no packages sent from a client to the server.
>>>>> This was IO with pnfs.
>>>> 
>>>> 
>>>> Hi Tigran
>>>> 
>>>> Is this an MDS reboot? DS reboot?
>>>> 
>>>> Thanks
>>>> 
>>>> -->Andy
>>>>> 
>>>>> Regards,
>>>>>   Tigran.
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> 
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> 
>>> 
>> 
> <kernel-threads.txt>

