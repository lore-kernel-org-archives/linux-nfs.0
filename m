Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.trendhosting.net ([195.8.117.5]:40599 "EHLO
        mail1.trendhosting.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753620AbcLKTGo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2016 14:06:44 -0500
Received: from localhost (localhost [127.0.0.1])
        by mail1.trendhosting.net (Postfix) with ESMTP id C5392150B6
        for <linux-nfs@vger.kernel.org>; Sun, 11 Dec 2016 19:01:14 +0000 (GMT)
Received: from mail1.trendhosting.net ([127.0.0.1])
        by localhost (thp003.trendhosting.net [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id mdn7dQGhHBxR for <linux-nfs@vger.kernel.org>;
        Sun, 11 Dec 2016 19:01:12 +0000 (GMT)
To: linux-nfs@vger.kernel.org
From: Daniel Pocock <daniel@pocock.pro>
Subject: improving NFS stability in next Debian release
Message-ID: <4415ff5c-98c3-629d-aefd-a5e677688bbb@pocock.pro>
Date: Sun, 11 Dec 2016 20:01:12 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi all,

NFS was quite stable with previous Debian versions but in Jessie, the
current stable release, it has been prone to crashes under load (kernel
3.16, bug report[1]).  A user also asked[2] about this on the
linux-fsdevel list a few months ago.

With the next Debian release freeze approaching, what will it take to
ensure a stable experience for NFS users?

Are there any known problems for NFS in the current Debian kernel[3]?

Which version of nfs-utils should be distributed?  The current package
is quite old[4].

Debian jessie-backports contains a 4.7.9 kernel, should that be
compatible with the nfs-utils package v1.2.8 and other related things in
jessie?

Regards,

Daniel


1. http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=847549
2. http://www.spinics.net/lists/linux-fsdevel/msg98540.html
3. https://packages.qa.debian.org/l/linux.html
4. https://packages.qa.debian.org/n/nfs-utils.html
