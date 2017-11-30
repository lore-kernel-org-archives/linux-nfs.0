Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:43585 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752248AbdK3OtR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Nov 2017 09:49:17 -0500
Received: by mail-wr0-f176.google.com with SMTP id z34so6852725wrz.10
        for <linux-nfs@vger.kernel.org>; Thu, 30 Nov 2017 06:49:17 -0800 (PST)
MIME-Version: 1.0
From: Emil Flink <emil.flink@bublar.com>
Date: Thu, 30 Nov 2017 15:49:15 +0100
Message-ID: <CAELMAQQGxK=2CgfqLnajhvt-ParO6WoX-gBY19Z4pN9DRaArtQ@mail.gmail.com>
Subject: Client locks up with nfs4_reclaim_open_state: Lock reclaim failed!
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm not sure where to go with this issue so please free to point me to
a more suitable forum if necessary.

My issue is that a client mounting a NFS share frequently locks up
with massive amounts of "nfs4_reclaim_open_state: Lock reclaim
failed!" in the kernel logs. Meanwhile the NFS server does not log any
errors as far as I can tell.

I only encounter this when the client is doing a lot of I/O against
the NFS share.

To recover from this I have to kill all processes on the client using
the NFS share, unmount the NFS share and remount it.

The NFS export is mounted with:
10.0.1.203:/nfs/lxc-office on /var/lib/lxc type nfs4
(rw,noatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.1.231,local_lock=none,addr=10.0.1.203)

Both the server and the client is running up-to-date installations of
Debian 9 ("stretch"), meaning kernel 4.9.0-4 and nfs-common /
nfs-kernel-server 1.3.4-2.1.


Regards,

Emil Flink
