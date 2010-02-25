From: wsnyder-12vJDDTx9R9AfugRpC6u6w@public.gmane.org (Wilson Snyder)
Subject: Problem with nfs server reboot causing exports to jumble
Date: Thu, 25 Feb 2010 14:29:10 -0500 (EST)
Message-ID: <20100225192911.09CC318839E@wsnyder.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wsnyder.org ([66.249.9.161]:48913 "EHLO wsnyder.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933028Ab0BYT5M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Feb 2010 14:57:12 -0500
Received: from wsnyder.org (c-24-91-159-26.hsd1.ma.comcast.net [24.91.159.26])
	by wsnyder.org (Postfix) with ESMTP id D6C69E0237
	for <linux-nfs@vger.kernel.org>; Thu, 25 Feb 2010 19:29:11 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


We're using the 2.6.18 x86_64 kernel (RH SL 5.1) with a NFS
v3 server and NFS v3 clients using the automounter with options
(rw,noatime,hard,intr,rsize=32768,wsize=32768,proto=tcp).

Our NFS server had several exports

    /export/a/{files-a}
    /export/b/{files-b}

these were mounted on various clients.

We then added a new mount and export without rebooting:

    /export/a/{files-a}
    /export/b/{files-b}
    /export/c/{files-c}

All were visible on the clients, and everything was fine:

    /nfs/a/{files-a}
    /nfs/b/{files-b}
    /nfs/c/{files-c}

Our NFS server then crashed, and rebooted.  After reboot the
clients then had:

    /nfs/a/{files-c}
    /nfs/b/{files-a}
    /nfs/c/{files-b}

Note the files correspond to the wrong exports.  Remounting
on every client fixed the problem - once we realized what
was going on!  (files-a/b/c were all similar so it wasn't
immediately aparent)

My speculation is the reboot changed some enumeration
causing a mismatch between the clients and servers.

This is a new one by me - is this a known issue, and if so
is a patch available?

Other than patching, are there any precautions we can take
to avoid this in the future?  (Other than not crashing the
server, which we'd be happy to not to do. :)

Thanks
