From: "howard chen" <howachen@gmail.com>
Subject: Permission denied when mounting NFS (was okay before)
Date: Fri, 26 Sep 2008 19:32:27 +0800
Message-ID: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:12820 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbYIZLc3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2008 07:32:29 -0400
Received: by wa-out-1112.google.com with SMTP id v27so446074wah.21
        for <linux-nfs@vger.kernel.org>; Fri, 26 Sep 2008 04:32:29 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have a sudden problem when my server reboot and mount to a NFS
failed, so I neeed to mount
by hand. (But it was okay before...)

Error:

mount: trying xxxx prog 100003 vers 3 prot udp port 2049
mount: trying xxxx prog 100005 vers 3 prot udp port 891
mount: xxxx:/data0/tmp failed, reason given by server: Permission
denied

Many pages in the web said it is related to the hostname and ip
mapping, which made permission issues,
but in my NFS server,  I see the permission is ok:

(/var/log/message)

authenticated mount request from xxxx for yyyy...

Any idea for this funny problem?

Thanks.
