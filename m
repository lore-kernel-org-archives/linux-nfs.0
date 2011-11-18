Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36671 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758029Ab1KRQJc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 11:09:32 -0500
Received: by bke11 with SMTP id 11so3602229bke.19
        for <linux-nfs@vger.kernel.org>; Fri, 18 Nov 2011 08:09:31 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <081C1E0B-795E-4138-B66A-479F73BB3AC5@netapp.com>
References: <CAGue13oSMCs=mSMHsX2f_=+Eqc3i3rG8vkq0rSnMTm_sqpwcnw@mail.gmail.com>
	<081C1E0B-795E-4138-B66A-479F73BB3AC5@netapp.com>
Date: Fri, 18 Nov 2011 17:09:30 +0100
Message-ID: <CAGue13pFCq22xUmJny7+7czc8WkPhjos2A+_BombOf3G8icwJA@mail.gmail.com>
Subject: Re: server reboot recovery is broken with 3.1 (3.2?) with nfsv41 clients
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both!

On Fri, Nov 18, 2011 at 3:08 PM, Adamson, Andy
<William.Adamson@netapp.com> wrote:
>
> On Nov 18, 2011, at 8:57 AM, Tigran Mkrtchyan wrote:
>
>> Dear  nfs hackers,
>>
>> it looks like with kernel 3.1 client cant recover from server reboots.
>> The nfs mount hangs and there are no packages sent from a client to the server.
>> This was IO with pnfs.
>
>
> Hi Tigran
>
> Is this an MDS reboot? DS reboot?
>
> Thanks
>
> -->Andy
>>
>> Regards,
>>   Tigran.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
