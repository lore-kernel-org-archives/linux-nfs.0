Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:53004 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752496AbcIOWcT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 18:32:19 -0400
Received: from [192.168.100.149] (firewall.candelatech.com [50.251.239.81])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.candelatech.com (Postfix) with ESMTPSA id A706D40A5C4
        for <linux-nfs@vger.kernel.org>; Thu, 15 Sep 2016 15:32:18 -0700 (PDT)
To: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
From: Ben Greear <greearb@candelatech.com>
Subject: nfs broken on Fedora-24, 32-bit?
Message-ID: <de68a5b5-fa21-1ca4-68e9-feeea009e6d3@candelatech.com>
Date: Thu, 15 Sep 2016 15:32:18 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a Fedora-24 machine mounting an NFS server running Fedora-13 (kernel 2.6.34.9-69.fc13.x86_64).

F24 machine has this in /etc/fstab:

192.168.100.3:/mnt/d2 /mnt/d2                   nfs     nfsvers=3       0 0

When I copy a file from f24-32 to the F-13 machine, the file size is the same,
but the file is corrupted on the file server.  I see a different md5sum each time.

Various other systems (F21, F19, etc) can all copy to the F13 machine fine.

And, F24-64 machine can copy to the F13 machine fine.

Anyone seen something similar?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

