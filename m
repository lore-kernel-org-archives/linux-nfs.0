Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:39037 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727574AbeHaTtW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Aug 2018 15:49:22 -0400
Received: by mail-vk0-f42.google.com with SMTP id e139-v6so5624621vkf.6
        for <linux-nfs@vger.kernel.org>; Fri, 31 Aug 2018 08:41:18 -0700 (PDT)
MIME-Version: 1.0
References: <03f45066-5cc4-b99a-edc4-69dc34592101@aixigo.de>
In-Reply-To: <03f45066-5cc4-b99a-edc4-69dc34592101@aixigo.de>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 31 Aug 2018 11:41:05 -0400
Message-ID: <CAN-5tyGWO0FLZez+iyJ_EeBdmBcj=gA2iWi5TvjY+gh5pMtrXg@mail.gmail.com>
Subject: Re: nfs4_reclaim_open_state: Lock reclaim failed!
To: harald.dunkel@aixigo.de
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 29, 2018 at 5:16 AM Harald Dunkel <harald.dunkel@aixigo.de> wrote:
>
> Hi folks,
>
> dmesg -T shows me a large list of messages
>
> :
> [Wed Aug 29 11:13:02 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [Wed Aug 29 11:13:02 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [Wed Aug 29 11:13:02 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [Wed Aug 29 11:13:03 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [Wed Aug 29 11:13:03 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [Wed Aug 29 11:13:04 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [Wed Aug 29 11:13:05 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> :
>
> with a modification date appr 9 minutes in the future. NFS server and
> client have the correct time and are in sync, afaict. How comes?

Is your question about how come the timestamp is wrong or are you
asking about the errors being logged. Jeff provided some info about
the latter piece. However, if you are asking about the timestamps,
then my guess would be that your hardware clock and your system clock
might be output sync. Check the "sudo hwclock --show" to what your
"date" shows. Also check the manual page that say for this option
"dmesg -T" there is a warming saying that the timestamps might not be
accurate.

>
>
> Kernel is 4.9.88-1+deb9u1 on the client, 4.16.5-1~bpo9+1 on the NFS server.
>
>
> Every helpful comment is highly appreciated.
> Harri
