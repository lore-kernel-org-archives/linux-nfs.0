Return-Path: linux-nfs-owner@vger.kernel.org
Received: from avon.tiger-computing.co.uk ([87.237.68.148]:47489 "EHLO
	avon.tiger-computing.co.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932202Ab2LRQhH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Dec 2012 11:37:07 -0500
Received: from static-87-243-207-6.adsl.hotchilli.net ([87.243.207.6] helo=mail1.tiger-computing.co.uk)
	by avon.tiger-computing.co.uk with esmtps (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <kae@midnighthax.com>)
	id 1TkzTO-0004Yk-5U
	for linux-nfs@vger.kernel.org; Tue, 18 Dec 2012 15:52:50 +0000
Received: from kae.tiger-computing.wbp ([10.90.90.100])
	by mail1.tiger-computing.co.uk with esmtp (Exim 4.72)
	(envelope-from <kae@midnighthax.com>)
	id 1TkzTN-0000iX-Ma
	for linux-nfs@vger.kernel.org; Tue, 18 Dec 2012 15:52:49 +0000
Date: Tue, 18 Dec 2012 15:52:48 +0000
From: Keith Edmunds <kae@midnighthax.com>
To: linux-nfs@vger.kernel.org
Subject: NFS access slow
Message-ID: <20121218155248.49dfa1fd@kae.tiger-computing.wbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Accessing disks locally on a server gives read speeds around 100MB/s,
write speeds around 267MB/s.

Mounting the same disks on the same server via NFS (ie, not using the
network at all) gives read speeds around 30MB/s, write speeds around
80MB/s.

That's about 30% of the local access speed.

Is that to be expected? I'd expect a 10-15% slowdown, but not this much.

This is using NFSv4; using NFSv3 improves the speeds slightly (36MB/s
read, 95MB/s write).

Other parameters we've changed, none of which have a significant impact:

 - UDP/TCP
 - rsize and wsize
 - noatime
 - noacl
 - nocto

If that's an unexpected slow down, where should we be looking?

Thanks.
