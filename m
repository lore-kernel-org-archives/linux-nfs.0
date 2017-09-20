Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:48841 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751787AbdITWR5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Sep 2017 18:17:57 -0400
Received: by mail-qk0-f171.google.com with SMTP id a128so4161665qkc.5
        for <linux-nfs@vger.kernel.org>; Wed, 20 Sep 2017 15:17:57 -0700 (PDT)
MIME-Version: 1.0
From: Manjunath Patil <mbpatil.linux@gmail.com>
Date: Wed, 20 Sep 2017 15:17:56 -0700
Message-ID: <CANnNPBYoZFcXZJopjcPWZ5jdRQoQV16VVHM+=A=Pm2=_GZ=Msw@mail.gmail.com>
Subject: [Bug ?] Permanent FIN_WAIT_2 state on NFS client with bad NFS server
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

With autoclose trying to close the connection, after the idle timeout
in NFSv3 mounts,
a bad NFS server may not send the final FIN, leading the client stay
in FIN_WAIT_2 state forever.
This is easily reproducible by simulating the bad server behavior. I
used 'netstat -an | grep 2049' to observer socket state.

This is will also stall the other RPC requests from connecting and
proceeding as XPRT_CLOSING flag is already set.

This can be observed in the 4.14-rc1 as well.
This behavior is introduced with the following commit -
caf4ccd SUNRPC: Make xs_tcp_close() do a socket shutdown rather than a
sock_release

Once we reverse this commit, the FIN_WAIT_2 state lasts only for 60 seconds.

Any thoughts correcting this behavior?
or is this behavior expected?

-Thanks,
Manjunath
