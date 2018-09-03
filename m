Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua1-f52.google.com ([209.85.222.52]:41968 "EHLO
        mail-ua1-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725969AbeICRgS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 13:36:18 -0400
Received: by mail-ua1-f52.google.com with SMTP id h1-v6so380951uao.8
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 06:16:11 -0700 (PDT)
MIME-Version: 1.0
References: <03f45066-5cc4-b99a-edc4-69dc34592101@aixigo.de>
 <CAN-5tyGWO0FLZez+iyJ_EeBdmBcj=gA2iWi5TvjY+gh5pMtrXg@mail.gmail.com> <6a6a9ca4-8457-99e9-0355-b45c122a34ac@aixigo.de>
In-Reply-To: <6a6a9ca4-8457-99e9-0355-b45c122a34ac@aixigo.de>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 3 Sep 2018 09:15:59 -0400
Message-ID: <CAN-5tyE9wJR0dxRwFtVO84yfg7nZyaaAg61y3rfbrU4wSBgdXA@mail.gmail.com>
Subject: Re: nfs4_reclaim_open_state: Lock reclaim failed!
To: harald.dunkel@aixigo.de
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 3, 2018 at 3:49 AM Harald Dunkel <harald.dunkel@aixigo.de> wrote:
>
> Hi Olga,
>
> On 8/31/18 5:41 PM, Olga Kornievskaia wrote:
> >
> > Is your question about how come the timestamp is wrong or are you
> > asking about the errors being logged. Jeff provided some info about
> > the latter piece. However, if you are asking about the timestamps,
> > then my guess would be that your hardware clock and your system clock
> > might be output sync. Check the "sudo hwclock --show" to what your
> > "date" shows. Also check the manual page that say for this option
> > "dmesg -T" there is a warming saying that the timestamps might not be
> > accurate.
> >
>
> date and hwclock show the same time (now, after a reboot).

where they the same before that?

>  I am not sure why NFS should use the hwclock time for the logfile entries.

timestamps have nothing to do with NFS.
