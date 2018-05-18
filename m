Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:40491 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbeERLJu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2018 07:09:50 -0400
Received: by mail-wm0-f47.google.com with SMTP id j5-v6so14421945wme.5
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2018 04:09:50 -0700 (PDT)
MIME-Version: 1.0
From: Naruto Nguyen <narutonguyen2018@gmail.com>
Date: Fri, 18 May 2018 18:09:49 +0700
Message-ID: <CANpxKHFczD0v7O39zzR_dyOYEV7n5bwjJmEQxLnNuxf4HHJCqQ@mail.gmail.com>
Subject: Conflict tcp port between rpcinfo and other applications
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello everyone,

When I use "rpcinfo -T tcp $Host_A nfs 3" to query NFS program
information on the Host_A, rpcinfo opens a tcp connection to query and
return sucessfully but the problem is after that the tcp port is in
TIME_WAITstate for 1 minutes. So during this 1 minutes, there is a
chance that another application opens the same port as the current
TIME_WAIT port, then it cannot start because the port is in TIME_WAIT
state.

For example, rpcinfo opens tcp port 830 to query, then after that port
830 goes to TIME_WAIT state. Later during that time, ssh netconfig
starts and use 830 (830 is NETCONF over SSH) -> fails to start with
the reason the port is in use.

My question is if we have any ways to prevent this:

1. I found no option in rpcinfo command to specify tcp port to use when querying
2. Change tcp_fin_timeout but it is not a good option
3. Reserve 830 port by calling "nc" to listen on 830 port, then start
rpcinfo, after rpcinfo returns, we will the "nc" process". This option
has a limitation that we have to reserve all welknown ports before
calling rpcinfo, and we have to kill all "nc" process after rpcinfo
returns.

Could you please let me know if we have any good way to avoid that?

Thanks a lot,

Brs,
Naruto
