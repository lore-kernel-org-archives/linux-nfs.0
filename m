Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48036 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822Ab1KUJvi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Nov 2011 04:51:38 -0500
Received: by bke11 with SMTP id 11so6316924bke.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Nov 2011 01:51:37 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <CAGue13pFCq22xUmJny7+7czc8WkPhjos2A+_BombOf3G8icwJA@mail.gmail.com>
References: <CAGue13oSMCs=mSMHsX2f_=+Eqc3i3rG8vkq0rSnMTm_sqpwcnw@mail.gmail.com>
	<081C1E0B-795E-4138-B66A-479F73BB3AC5@netapp.com>
	<CAGue13pFCq22xUmJny7+7czc8WkPhjos2A+_BombOf3G8icwJA@mail.gmail.com>
Date: Mon, 21 Nov 2011 10:51:36 +0100
Message-ID: <CAGue13r+vZRkmpiHVPodyoYXt+SVCfDdgHJOF74TmL5=ci=q1w@mail.gmail.com>
Subject: Re: server reboot recovery is broken with 3.1 (3.2?) with nfsv41 clients
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RHEL6.2 has the same issue. I just rebooted server (mds + ds) during read.

Kernel thread dump attached.

Tigran.

On Fri, Nov 18, 2011 at 5:09 PM, Tigran Mkrtchyan
<tigran.mkrtchyan@desy.de> wrote:
> Both!
>
> On Fri, Nov 18, 2011 at 3:08 PM, Adamson, Andy
> <William.Adamson@netapp.com> wrote:
>>
>> On Nov 18, 2011, at 8:57 AM, Tigran Mkrtchyan wrote:
>>
>>> Dear  nfs hackers,
>>>
>>> it looks like with kernel 3.1 client cant recover from server reboots.
>>> The nfs mount hangs and there are no packages sent from a client to the server.
>>> This was IO with pnfs.
>>
>>
>> Hi Tigran
>>
>> Is this an MDS reboot? DS reboot?
>>
>> Thanks
>>
>> -->Andy
>>>
>>> Regards,
>>>   Tigran.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
