Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34471 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752388AbdBJTo7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2017 14:44:59 -0500
Subject: Re: [PATCH net-next v2 00/12] net: dsa: remove unnecessary phy.h
 include
To: David Miller <davem@davemloft.net>, kvalo@codeaurora.org
References: <87h944ll0w.fsf@kamboji.qca.qualcomm.com>
 <5fe312c8-e59e-669c-cd29-f6773adcd8e5@gmail.com>
 <877f4zjw01.fsf@kamboji.qca.qualcomm.com>
 <20170210.135138.2084086346069765205.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
        linux-nfs@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
        target-devel@vger.kernel.org, andrew@lunn.ch,
        anna.schumaker@netapp.com, derek.chickles@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com, bfields@fieldses.org,
        jlayton@poochiereds.net, jirislaby@gmail.com, mcgrof@do-not-panic.com,
        madalin.bucur@nxp.com, UNGLinuxDriver@microchip.com,
        nab@linux-iscsi.org, mickflemm@gmail.com, nicolas.ferre@atmel.com,
        raghu.vatsavayi@caviumnetworks.com, ralf@linux-mips.org,
        satananda.burla@caviumnetworks.com,
        thomas.petazzoni@free-electrons.com, timur@codeaurora.org,
        trond.myklebust@primarydata.com, vivien.didelot@savoirfairelinux.com,
        woojung.huh@microchip.com
From: Florian Fainelli <f.fainelli@gmail.com>
Message-ID: <68d8c792-5d09-7cdc-4a94-8437bfb0299e@gmail.com>
Date: Fri, 10 Feb 2017 11:44:49 -0800
MIME-Version: 1.0
In-Reply-To: <20170210.135138.2084086346069765205.davem@davemloft.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/10/2017 10:51 AM, David Miller wrote:
> From: Kalle Valo <kvalo@codeaurora.org>
> Date: Thu, 09 Feb 2017 16:10:06 +0200
> 
>> Florian Fainelli <f.fainelli@gmail.com> writes:
>>
>>>>> If not, for something like this it's a must:
>>>>>
>>>>> drivers/net/wireless/ath/wil6210/cfg80211.c:24:30: error: expected ‘)’ before ‘bool’
>>>>>  module_param(disable_ap_sme, bool, 0444);
>>>>>                               ^
>>>>> drivers/net/wireless/ath/wil6210/cfg80211.c:25:34: error: expected ‘)’ before string constant
>>>>>  MODULE_PARM_DESC(disable_ap_sme, " let user space handle AP mode SME");
>>>>>                                   ^
>>>>> Like like that file needs linux/module.h included.
>>>>
>>>> Johannes already fixed a similar (or same) problem in my tree:
>>>>
>>>> wil6210: include moduleparam.h
>>>>
>>>> https://git.kernel.org/cgit/linux/kernel/git/kvalo/wireless-drivers-next.git/commit/?id=949c2d0096753d518ef6e0bd8418c8086747196b
>>>>
>>>> I'm planning to send you a pull request tomorrow which contains that
>>>> one.
>>>
>>> Thanks Kalle!
>>>
>>> David, can you hold on this series until Kalle's pull request gets
>>> submitted? Past this error, allmodconfig builds fine with this patch
>>> series (just tested). Thanks!
>>
>> Just submitted the pull request:
>>
>> https://patchwork.ozlabs.org/patch/726133/
> 
> I've retried this patch series, and will push it out assuming the build
> completes properly.

I see it merged in net-next/master, thanks a lot this is going to save a
lot of cycles in the future, thanks David!
-- 
Florian
