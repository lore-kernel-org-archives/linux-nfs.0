From: riya khanna <riyakhanna1983@gmail.com>
Subject: dev over nfs
Date: Thu, 29 May 2014 13:53:37 -0400
Message-ID: <CALRD3qKzmrvRqBabQQuvVH7jTb0mexZGw4rXVTBkYS3YRc6NtQ__22568.1633143269$1401386217$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: undisclosed-recipients:;
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:54669 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965203AbaE2Rxi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2014 13:53:38 -0400
Received: by mail-ig0-f171.google.com with SMTP id c1so4064791igq.16
        for <linux-nfs@vger.kernel.org>; Thu, 29 May 2014 10:53:37 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm trying to access remote devices locally by mounting/exporting /dev
nodes over NFS. However, looks like the access requests are treated local
based on major minor numbers (e.g. "cat /mnt-dev-over-nfs/kmg" output is
same as "cat /dev/kmsg")

How can I change this behavior? and if it is at all feasible?

Thanks,
Riya
