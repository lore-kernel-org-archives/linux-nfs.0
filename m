Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [195.159.176.226] ([195.159.176.226]:33659 "EHLO
        blaine.gmane.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1751307AbeECXDI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 May 2018 19:03:08 -0400
Received: from list by blaine.gmane.org with local (Exim 4.84_2)
        (envelope-from <glN-linux-nfs@m.gmane.org>)
        id 1fENDb-00079H-1a
        for linux-nfs@vger.kernel.org; Fri, 04 May 2018 01:00:55 +0200
To: linux-nfs@vger.kernel.org
From: scar <scar@drigon.com>
Subject: Re: RDMA connection lost and not re-opened
Date: Thu, 3 May 2018 16:02:58 -0700
Message-ID: <pcg4b0$qcc$1@blaine.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I did also notice these errors on the NFS server 10.10.11.10:

May  2 21:27:59 pac kernel: svcrdma: failed to send reply chunks, rc=-5
May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!


