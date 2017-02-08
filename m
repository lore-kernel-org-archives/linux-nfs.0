Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34514 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750946AbdBHTu3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 14:50:29 -0500
Subject: Re: [PATCH net-next v2 00/12] net: dsa: remove unnecessary phy.h
 include
To: Kalle Valo <kvalo@codeaurora.org>, David Miller <davem@davemloft.net>
References: <20170207230305.18222-1-f.fainelli@gmail.com>
 <20170208.110626.346978547122180233.davem@davemloft.net>
 <87h944ll0w.fsf@kamboji.qca.qualcomm.com>
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
Message-ID: <5fe312c8-e59e-669c-cd29-f6773adcd8e5@gmail.com>
Date: Wed, 8 Feb 2017 11:45:11 -0800
MIME-Version: 1.0
In-Reply-To: <87h944ll0w.fsf@kamboji.qca.qualcomm.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/08/2017 08:11 AM, Kalle Valo wrote:
> David Miller <davem@davemloft.net> writes:
> 
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Tue,  7 Feb 2017 15:02:53 -0800
>>
>>> I'm hoping this doesn't conflict with what's already in net-next...
>>>
>>> David, this should probably go via your tree considering the diffstat.
>>
>> I think you need one more respin.  Are you doing an allmodconfig build?

I did not, instead tried to test each driver individually in different
configurations...

>> If not, for something like this it's a must:
>>
>> drivers/net/wireless/ath/wil6210/cfg80211.c:24:30: error: expected ‘)’ before ‘bool’
>>  module_param(disable_ap_sme, bool, 0444);
>>                               ^
>> drivers/net/wireless/ath/wil6210/cfg80211.c:25:34: error: expected ‘)’ before string constant
>>  MODULE_PARM_DESC(disable_ap_sme, " let user space handle AP mode SME");
>>                                   ^
>> Like like that file needs linux/module.h included.
> 
> Johannes already fixed a similar (or same) problem in my tree:
> 
> wil6210: include moduleparam.h
> 
> https://git.kernel.org/cgit/linux/kernel/git/kvalo/wireless-drivers-next.git/commit/?id=949c2d0096753d518ef6e0bd8418c8086747196b
> 
> I'm planning to send you a pull request tomorrow which contains that
> one.

Thanks Kalle!

David, can you hold on this series until Kalle's pull request gets
submitted? Past this error, allmodconfig builds fine with this patch
series (just tested). Thanks!
-- 
Florian
