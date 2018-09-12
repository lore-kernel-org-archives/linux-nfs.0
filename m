Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tau.solarneutrino.net ([66.199.224.231]:44360 "EHLO
        tau.solarneutrino.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727839AbeILXtf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Sep 2018 19:49:35 -0400
Received: from ryan by tau.solarneutrino.net with local (Exim 4.80)
        (envelope-from <ryan@tau.solarneutrino.net>)
        id 1g09hz-0001yi-Ls
        for linux-nfs@vger.kernel.org; Wed, 12 Sep 2018 14:17:47 -0400
Date: Wed, 12 Sep 2018 14:17:47 -0400
From: Ryan Richter <ryan@tau.solarneutrino.net>
To: linux-nfs@vger.kernel.org
Subject: mkdir disregards umask
Message-ID: <20180912181747.GQ31400@tau.solarneutrino.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All directories created over nfs have 777 permissions.

# umask
022
# mkdir aaaa
# ls -ld aaaa
drwxrwxrwx 2 root root 2 Sep 12 13:45 aaaa
# rmdir aaaa
# mount|grep /mnt
mazuelo:/home/sbio/ryan on /mnt type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=132.204.84.95,mountvers=3,mountport=38634,mountproto=udp,local_lock=none,addr=132.204.84.95)

The same happens for regular users.

This is a very serious bug.  The server is runnig the debian stretch 4.9
kernel, and the client is running a vanilla 4.4.155.  Is there anything
in the configuration causing this, or is it a kernel bug?

Thanks,
-ryan
