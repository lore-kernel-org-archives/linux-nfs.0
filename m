Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moo.pl ([217.149.240.132]:37090 "EHLO moo.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758760Ab0EYWh3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 18:37:29 -0400
Received: from localhost (localhost [127.0.0.1])
	by moo.pl (Postfix) with ESMTP id EC0AA183FB
	for <linux-nfs@vger.kernel.org>; Wed, 26 May 2010 00:26:59 +0200 (CEST)
Received: from moo.pl ([127.0.0.1])
	by localhost (moo.pl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 78DARryzeNEA for <linux-nfs@vger.kernel.org>;
	Wed, 26 May 2010 00:26:57 +0200 (CEST)
Date: Wed, 26 May 2010 00:26:57 +0200
From: Leszek Urbanski <tgr.kb@moo.pl>
To: linux-nfs@vger.kernel.org
Subject: Deadlock/crash in 2.6.32.12 when copying large files
Message-ID: <20100525222657.GA14891@moo.pl>
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I've hit https://bugzilla.kernel.org/show_bug.cgi?id=15578 again with
2.6.32.12 on amd64.

I can reproduce it every time when copying large (>2G) files over NFS.
The call trace is at https://bugzilla.kernel.org/attachment.cgi?id=26519

Needless to say it results in a system crash (kswapd deadlock, network stack
failure because of memory allocation failure for SKBs, etc.).

Trond Myklebust closed this bug a while ago, but apparently it's not completely
fixed and needs to be re-opened.


-- 
Leszek Urbanski
