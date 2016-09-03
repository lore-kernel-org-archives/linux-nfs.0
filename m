Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mfb02-md.ns.itscom.net ([175.177.155.110]:41797 "EHLO
        mfb02-md.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751123AbcICEk4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Sep 2016 00:40:56 -0400
Received: from mail02-md.ns.itscom.net (mail02-md.ns.itscom.net [175.177.155.112])
        by mfb02-md.ns.itscom.net (Postfix) with ESMTP id F1151170CFBD
        for <linux-nfs@vger.kernel.org>; Sat,  3 Sep 2016 13:31:58 +0900 (JST)
From: "J. R. Okajima" <hooanon05g@gmail.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
cc: linux-nfs@vger.kernel.org
Subject: 4.8-rcN nfs O_DYSNC, write(2) doesn't return ENOSPC
Date: Sat, 03 Sep 2016 13:31:56 +0900
Message-ID: <3647.1472877116@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hello NFS folks,

I am not subscribing this ML. Please CC to me explicitly when you reply.

I found a problem of NFS in linux-v4.8-rc[123]. Here is a reproducible
sequence.

- mount a rather small tmpfs, for example /tmp/srvr
- export it to localhost
- mount localhost:/tmp/srvr /tmp/clnt
- dd if=/dev/zero of=/tmp/clnt/full

After a while, dd ends with ENOSPC expectedly. But if I add "oflag=dsync"
to dd(1), it never ends. strace(1) shows dd repeats write(512bytes) and
gets the value 512.

If this is a known issue, please tell me the commit id of the fix.


J. R. Okajima
