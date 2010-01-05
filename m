From: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
Subject: Difference between v2.6.31 and v2.6.32 spikes READs
Date: Tue, 5 Jan 2010 17:23:42 -0600
Message-ID: <20100105232342.GA22969@yahoo-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mrout3.yahoo.com ([216.145.54.173]:41333 "EHLO mrout3.yahoo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752434Ab0AEXmA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jan 2010 18:42:00 -0500
Received: from enemycanmeet.champ.corp.yahoo.com (enemycanmeet.champ.corp.yahoo.com [10.74.90.165])
	by mrout3.yahoo.com (8.13.6/8.13.6/y.out) with ESMTP id o05NPOiL081958
	for <linux-nfs@vger.kernel.org>; Tue, 5 Jan 2010 15:25:25 -0800 (PST)
Received: from enemycanmeet.champ.corp.yahoo.com (localhost.localdomain [127.0.0.1])
	by enemycanmeet.champ.corp.yahoo.com (8.13.8/8.13.8) with ESMTP id o05NNgZx023027
	for <linux-nfs@vger.kernel.org>; Tue, 5 Jan 2010 17:23:42 -0600
Received: (from qbarnes@localhost)
	by enemycanmeet.champ.corp.yahoo.com (8.13.8/8.13.8/Submit) id o05NNgjE023026
	for linux-nfs@vger.kernel.org; Tue, 5 Jan 2010 17:23:42 -0600
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I moved from v2.6.31.3 to v2.6.32.2 and noticed a huge spike in the
number of NFSv3 READs issued for the application I'm porting.  The
app has a mixed load of short NFS I/O operations, but about 50% of
the time the app is doing an open(2), append to the file a small
amount of data (~300 bytes), then closes the file.  On v2.6.31.3,
this resulted in a LOOKUP, ACCESS, and a WRITE of 300 bytes.  Now
for the append operations with v2.6.32.2, I see LOOKUP, ACCESS,
READ, and WRITE.

Here's the network trace for an append with 2.6.31.3:
===========
LOOKUP Call, DH:0x0308031e/scr2
LOOKUP Reply, FH:0x29f0b5d0
ACCESS Call, FH:0x29f0b5d0
ACCESS Reply
WRITE Call, FH:0x29f0b5d0 Offset:17284 Len:300 UNSTABLE
WRITE Reply Len:300 UNSTABLE
COMMIT Call, FH:0x29f0b5d0
COMMIT Reply
===========

And for 2.6.32.2:
===========
LOOKUP Call, DH:0x0308031e/scr2
LOOKUP Reply, FH:0x29f0b5d0
ACCESS Call, FH:0x29f0b5d0
ACCESS Reply
READ Call, FH:0x29f0b5d0 Offset:16384 Len:900
READ Reply Len:900
WRITE Call, FH:0x29f0b5d0 Offset:16384 Len:1200 UNSTABLE
WRITE Reply Len:1200 UNSTABLE
COMMIT Call, FH:0x29f0b5d0
COMMIT Reply
===========

My think the behavior change is due to "read-modify-write page
updating" patch with adding the nfs_want_read_modify_write()
function, but that's just a guess.

Even with the additional READs, in some modes of the app performance
has gone up with v2.6.32 by 4.0%.  (Good!)  However, in other modes,
it has dropped 22%.  (Not good!)

If my guess is right, I'm wondering if the read-modify-write
updating patch accounted for files opened read-write, but only
written to or appended to before closing.

Can the read-modify-write page updating be altered to better handle
opens in read-write (O_RDWR) that only end up writing before
closing?

Quentin
