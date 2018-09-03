Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([5.145.142.10]:10228 "EHLO mail.aixigo.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725898AbeICMHr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Sep 2018 08:07:47 -0400
Subject: Re: nfs4_reclaim_open_state: Lock reclaim failed!
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
References: <03f45066-5cc4-b99a-edc4-69dc34592101@aixigo.de>
 <CAN-5tyGWO0FLZez+iyJ_EeBdmBcj=gA2iWi5TvjY+gh5pMtrXg@mail.gmail.com>
From: Harald Dunkel <harald.dunkel@aixigo.de>
Message-ID: <6a6a9ca4-8457-99e9-0355-b45c122a34ac@aixigo.de>
Date: Mon, 3 Sep 2018 09:48:50 +0200
MIME-Version: 1.0
In-Reply-To: <CAN-5tyGWO0FLZez+iyJ_EeBdmBcj=gA2iWi5TvjY+gh5pMtrXg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On 8/31/18 5:41 PM, Olga Kornievskaia wrote:
> 
> Is your question about how come the timestamp is wrong or are you
> asking about the errors being logged. Jeff provided some info about
> the latter piece. However, if you are asking about the timestamps,
> then my guess would be that your hardware clock and your system clock
> might be output sync. Check the "sudo hwclock --show" to what your
> "date" shows. Also check the manual page that say for this option
> "dmesg -T" there is a warming saying that the timestamps might not be
> accurate.
> 

date and hwclock show the same time (now, after a reboot). I am not sure
why NFS should use the hwclock time for the logfile entries.


Regards
Harri
