Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from maxilla.fim.uni-passau.de ([132.231.4.25]:34258 "EHLO
        maxilla.fim.uni-passau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753072AbeDQMSF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2018 08:18:05 -0400
Received: from localhost (localhost [127.0.0.1])
        by maxilla.fim.uni-passau.de (Postfix) with ESMTP id B4752140729
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2018 14:11:21 +0200 (CEST)
Received: from maxilla.fim.uni-passau.de ([127.0.0.1])
        by localhost (maxilla.fim.uni-passau.de [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id Vm7r7kR7Mkc5 for <linux-nfs@vger.kernel.org>;
        Tue, 17 Apr 2018 14:11:21 +0200 (CEST)
Received: from [132.231.64.89] (bach.fim.uni-passau.de [132.231.64.89])
        by maxilla.fim.uni-passau.de (Postfix) with ESMTPSA
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2018 14:11:21 +0200 (CEST)
From: =?UTF-8?B?QXJtaW4gR3LDtsOfbGluZ2Vy?=
        <armin.groesslinger@uni-passau.de>
Subject: Tasks blocked uninterruptibly with NFSv4.0 and Kerberos
To: linux-nfs@vger.kernel.org
Message-ID: <e00225e0-17d9-3355-11b0-784a1456ec1e@uni-passau.de>
Date: Tue, 17 Apr 2018 14:11:21 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

last September I reported some NFS client hangs related to NFSv4.0 and Kerberos
we are seeing on our system to this list [1]. Unfortunately, the issue is still
there and seems to affect Kernels 3.x up to 4.17-rc1. We are observing this
problem in production (on our workstations and compute cluster nodes), certain
lseek-write-fsync patterns seem to trigger the problem. Affected processes hang
indefinitely (and uninterruptibly).

I have written a demo program which performs the lseek-write-fsync cycle and
reliably demonstrates the hangs on our systems. To (hopefully) make reproducing
the issue easier for people who know how to debug/fix the issue, I have written
a little script, see [2], which sets up two virtual machines and configures
them the required way (NFSv4.0 export with Kerberos):

 $ ./build.sh       # set up the two VMs using debootstrap
 $ ./server.sh      # start the NFS server in QEMU
 $ ./client.sh      # start the NFS client in QEMU

Then, log into the client (as "user" with password "pass"), call "kinit"
(entering "pass" again) and run

 $ /hang.sh

Then, the process should hang rather quickly ("INFO: task writesync:1443
blocked for more than 120 seconds.") and the system cannot recover from that
state (kernel messages see [1]). In recent kernels (e.g., 4.17-rc1), it seems
that, at least sometimes, instead of a hanging task one gets a kernel panic
after the OOM killer has killed all processes.

I couldn't "git bisect" the problem because I was unable to find a kernel not
affected by the problem (the oldest kernel I could try was 3.16).

We observe the hangs only when NFSv4.0 (not 4.1 or 4.2) is used, Kerberos is
used (sec=krb5 or sec=krb5i or sec=krb5p; it seems that sec=krb5p is most
likely to show the behavior) and the client and server are fast enough, i.e.,
slowing down either the client or the server (putting more load on the server,
running the client VM without -enable-kvm, etc.) makes the hangs go away.

On our production systems, the NFS server is a Nexenta system, so it seems to
be independent from the NFS server. When the server is quite busy, he hangs
occur seldom; when the server has a low load, the hangs on the clients happen
much more often.

I hope somebody has an idea how to eliminate this problem?

Regards,
Armin


[1] https://marc.info/?l=linux-nfs&m=150620442017672

[2] https://gitlab.infosun.fim.uni-passau.de/groessli/nfs-krb5-vms

