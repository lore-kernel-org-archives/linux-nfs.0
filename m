Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:40278 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933516AbbHDPE6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 11:04:58 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: TEST_STATEID during lock recovery
Date: Tue, 4 Aug 2015 11:04:55 -0400
Message-Id: <A0DBB287-CF36-42D7-8EB3-69327DA48544@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

One of our testers stumbled on an interesting phenomenon yesterday.
He purposely caused a client to run out the grace period clock
during lock recovery on an NFSv4.1 mount. He did this by taking
thousands of two-byte locks on the same file, and then rebooting
his server.

The client detects the reboot and starts reclaiming locks. When
the grace period expires, the server replies NO_GRACE to the
current LOCK(reclaim). The client responds with RECLAIM_COMPLETE,
then goes into a hard TEST_STATEID loop.

If I understand the recovery logic, this is trying a TEST_STATEID
on every lock that was held by the client. The thing is, all the
locks use the same stateid, since they are on the same file.

So the client is sending TEST_STATEID with the same stateid
argument over and over and over. All work on the client's mount
point stops until that loop completes (which it eventually does).

Is there room for some optimization here? Performing one
TEST_STATEID per lockowner/FH pair is probably better, but I'm
not clear on how post-grace period recovery is supposed to work.


--
Chuck Lever



