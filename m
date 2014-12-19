Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ironport01-1.csupomona.edu ([134.71.187.41]:13238 "EHLO
	ironport01-1.csupomona.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751547AbaLSDeD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Dec 2014 22:34:03 -0500
Received: from localhost (localhost [127.0.0.1])
	by tweak.unx.csupomona.edu (Postfix) with ESMTP id 6F06113405D
	for <linux-nfs@vger.kernel.org>; Thu, 18 Dec 2014 19:24:23 -0800 (PST)
Received: from tweak.unx.csupomona.edu ([127.0.0.1])
	by localhost (tweak.unx.csupomona.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Sl6LDD7hqDyY for <linux-nfs@vger.kernel.org>;
	Thu, 18 Dec 2014 19:24:23 -0800 (PST)
Received: from localhost.localdomain (woof.iitsystems.csupomona.edu [134.71.248.29])
	(using SSLv3 with cipher ECDHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: bldewolf)
	by tweak.unx.csupomona.edu (Postfix) with ESMTPSA id 5E274134034
	for <linux-nfs@vger.kernel.org>; Thu, 18 Dec 2014 19:24:22 -0800 (PST)
Date: Thu, 18 Dec 2014 19:24:21 -0800
From: Brian De Wolf <bldewolf@cpp.edu>
To: linux-nfs@vger.kernel.org
Subject: 3.14.27 client hang on specific file
Message-ID: <20141218192421.03a66cac@cpp.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

After updating our kernel from 3.4.x to 3.14.27 (along with nfs-utils
1.2.9), we've had a strange issue with our sec=krb5p NFSv4 mounts.
My initial light testing went fine, but sometimes, on any given host, a
specific file will no longer be accessible.  Any attempt to access it
causes the process to go into uninterruptible sleep.

Reproducing this on another host was fairly quick by dd'ing 30MB
from /dev/zero into a file repeatedly.  Eventually the dd hangs instead
of completing.  Once broken, the simplest test I could think of was
"stat testfile".  tcpdump shows no traffic when I run it.  Turning
rpcdebug all the way up produces:

	kernel: RPC:       looking up Generic cred
	kernel: NFS: permission(0:28/3), mask=0x1, res=0
	kernel: NFS: nfs_lookup_revalidate(/testfile) is valid

Around the time that it breaks, it also prints

	kernel: nfs: server servername not responding, still trying

several times, but I couldn't find a way to get it to print it again.
It doesn't look like it follows up with more timeouts or an "OK", so
that seems pretty odd.

Anyone have any ideas?  I'm happy to provide more debug info.


Thanks,
Brian
