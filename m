Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55506 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752834AbdBHQlC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 11:41:02 -0500
From: Kalle Valo <kvalo@codeaurora.org>
To: David Miller <davem@davemloft.net>
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
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
Date: Wed, 08 Feb 2017 18:11:59 +0200
In-Reply-To: <20170208.110626.346978547122180233.davem@davemloft.net> (David
        Miller's message of "Wed, 08 Feb 2017 11:06:26 -0500 (EST)")
Message-ID: <87h944ll0w.fsf@kamboji.qca.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Tue,  7 Feb 2017 15:02:53 -0800
>
>> I'm hoping this doesn't conflict with what's already in net-next...
>>=20
>> David, this should probably go via your tree considering the diffstat.
>
> I think you need one more respin.  Are you doing an allmodconfig build?
> If not, for something like this it's a must:
>
> drivers/net/wireless/ath/wil6210/cfg80211.c:24:30: error: expected =E2=80=
=98)=E2=80=99 before =E2=80=98bool=E2=80=99
>  module_param(disable_ap_sme, bool, 0444);
>                               ^
> drivers/net/wireless/ath/wil6210/cfg80211.c:25:34: error: expected =E2=80=
=98)=E2=80=99 before string constant
>  MODULE_PARM_DESC(disable_ap_sme, " let user space handle AP mode SME");
>                                   ^
> Like like that file needs linux/module.h included.

Johannes already fixed a similar (or same) problem in my tree:

wil6210: include moduleparam.h

https://git.kernel.org/cgit/linux/kernel/git/kvalo/wireless-drivers-next.gi=
t/commit/?id=3D949c2d0096753d518ef6e0bd8418c8086747196b

I'm planning to send you a pull request tomorrow which contains that
one.

--=20
Kalle Valo
