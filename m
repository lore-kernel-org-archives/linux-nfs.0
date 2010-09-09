Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:49699 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753455Ab0IIVQD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Sep 2010 17:16:03 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1OtoTR-0008Pp-FV
	for linux-nfs@vger.kernel.org; Thu, 09 Sep 2010 23:16:02 +0200
Received: from inferno.cora.nwra.com ([65.44.101.162])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 09 Sep 2010 23:16:01 +0200
Received: from orion by inferno.cora.nwra.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 09 Sep 2010 23:16:01 +0200
To: linux-nfs@vger.kernel.org
From: Orion Poplawski <orion@cora.nwra.com>
Subject: locking and setgid files
Date: Thu, 9 Sep 2010 21:15:51 +0000 (UTC)
Message-ID: <loom.20100909T231305-758@post.gmane.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Is this expected?

$ ls -l /data/sw/svn/dombroski/supergran_paper/db/txn-current-lock
-rw-rwSr--. 1 dombroski superg    0 Aug 30 16:27 txn-current-lock

$ id
uid=6412(aaronb) gid=1001(cora) groups=1001(cora),1041(superg)
context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

open("/data/sw/svn/dombroski/supergran_paper/db/txn-current-lock", O_RDWR) = 3
fcntl64(3, F_GETLK, {type=F_WRLCK, whence=SEEK_SET, start=0, len=0,
pid=10771680}) = -1 ENOLCK (No locks available)

I guess I could somewhat understand it, though the fcntl64() call succeeds on
the server (CentOS 5.5).

