Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51102 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751644AbdBIOKl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2017 09:10:41 -0500
From: Kalle Valo <kvalo@codeaurora.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-mips@linux-mips.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-wireless@vger.kernel.org, target-devel@vger.kernel.org,
        andrew@lunn.ch, anna.schumaker@netapp.com,
        derek.chickles@caviumnetworks.com, felix.manlunas@caviumnetworks.com,
        bfields@fieldses.org, jlayton@poochiereds.net, jirislaby@gmail.com,
        mcgrof@do-not-panic.com, madalin.bucur@nxp.com,
        UNGLinuxDriver@microchip.com, nab@linux-iscsi.org, mickflemm@gmail.com,
        nicolas.ferre@atmel.com, raghu.vatsavayi@caviumnetworks.com,
        ralf@linux-mips.org, satananda.burla@caviumnetworks.com,
        thomas.petazzoni@free-electrons.com, timur@codeaurora.org,
        trond.myklebust@primarydata.com, vivien.didelot@savoirfairelinux.com,
        woojung.huh@microchip.com
Subject: Re: [PATCH net-next v2 00/12] net: dsa: remove unnecessary phy.h include
References: <20170207230305.18222-1-f.fainelli@gmail.com>
        <20170208.110626.346978547122180233.davem@davemloft.net>
        <87h944ll0w.fsf@kamboji.qca.qualcomm.com>
        <5fe312c8-e59e-669c-cd29-f6773adcd8e5@gmail.com>
Date: Thu, 09 Feb 2017 16:10:06 +0200
In-Reply-To: <5fe312c8-e59e-669c-cd29-f6773adcd8e5@gmail.com> (Florian
        Fainelli's message of "Wed, 8 Feb 2017 11:45:11 -0800")
Message-ID: <877f4zjw01.fsf@kamboji.qca.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

>>> If not, for something like this it's a must:
>>>
>>> drivers/net/wireless/ath/wil6210/cfg80211.c:24:30: error: expected =E2=
=80=98)=E2=80=99 before =E2=80=98bool=E2=80=99
>>>  module_param(disable_ap_sme, bool, 0444);
>>>                               ^
>>> drivers/net/wireless/ath/wil6210/cfg80211.c:25:34: error: expected =E2=
=80=98)=E2=80=99 before string constant
>>>  MODULE_PARM_DESC(disable_ap_sme, " let user space handle AP mode SME");
>>>                                   ^
>>> Like like that file needs linux/module.h included.
>>=20
>> Johannes already fixed a similar (or same) problem in my tree:
>>=20
>> wil6210: include moduleparam.h
>>=20
>> https://git.kernel.org/cgit/linux/kernel/git/kvalo/wireless-drivers-next=
.git/commit/?id=3D949c2d0096753d518ef6e0bd8418c8086747196b
>>=20
>> I'm planning to send you a pull request tomorrow which contains that
>> one.
>
> Thanks Kalle!
>
> David, can you hold on this series until Kalle's pull request gets
> submitted? Past this error, allmodconfig builds fine with this patch
> series (just tested). Thanks!

Just submitted the pull request:

https://patchwork.ozlabs.org/patch/726133/

--=20
Kalle Valo
