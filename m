Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from paneer.cc.columbia.edu ([128.59.29.4]:64369 "EHLO
	paneer.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756650Ab1BCSKx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Feb 2011 13:10:53 -0500
Received: from ebox.rath.org (ebox.rath.org [173.255.235.238])
	(user=nr2303 mech=PLAIN bits=0)
	by paneer.cc.columbia.edu (8.14.4/8.14.3) with ESMTP id p13I4vKa001525
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 3 Feb 2011 13:04:58 -0500 (EST)
Received: from inspiron.ap.columbia.edu ([128.59.145.39])
	by ebox.rath.org with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.71)
	(envelope-from <Nikolaus@rath.org>)
	id 1Pl3Y8-0003AM-AL
	for linux-nfs@vger.kernel.org; Thu, 03 Feb 2011 18:04:57 +0000
Message-ID: <4D4AEE47.8080504@rath.org>
Date: Thu, 03 Feb 2011 13:04:55 -0500
From: Nikolaus Rath <Nikolaus@rath.org>
To: linux-nfs@vger.kernel.org
Subject: Client hangs in __mutex_lock_slowpath, network connection maxed out
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I'm mounting an NFS4 volume from a kernel 2.6.32-27 server in a
2.6.37-020637rc2 client.
Very often, when there is significant IO on the mounted volume, the
client hangs. The process accessing the mountpoint is stuck in D
state. Any more attempts to access the mountpoint get stuck in D state
as well. Shortly after, the kernel reports the task as hanging:

[ 3120.620125] Call Trace:
[ 3120.620138]  [<c05ec44d>] ? _raw_spin_lock+0xd/0x10
[ 3120.620146]  [<c05eb4b6>] __mutex_lock_slowpath+0xc6/0x120
[ 3120.620152]  [<c05eb1c5>] mutex_lock+0x25/0x40
[ 3120.620158]  [<c022e3b3>] do_lookup+0xc3/0x120
[ 3120.620164]  [<c022fbb2>] link_path_walk+0x402/0x9b0
[ 3120.620171]  [<c0167b5a>] ? queue_work+0x1a/0x20

Additional tasks hang at a slightly different point:

[ 3120.620304]  [<f90b863d>] ? nfs_access_add_cache+0xcd/0x120 [nfs]
[ 3120.620326]  [<f90b8709>] ? nfs_do_access+0x79/0xc0 [nfs]
[ 3120.620333]  [<c05eb4b6>] __mutex_lock_slowpath+0xc6/0x120
[ 3120.620339]  [<c05eb1c5>] mutex_lock+0x25/0x40
[ 3120.620344]  [<c022e3b3>] do_lookup+0xc3/0x120
[ 3120.620350]  [<c022fbb2>] link_path_walk+0x402/0x9b0
[ 3120.620356]  [<c0230697>] path_walk+0x47/0xa0
[ 3120.620361]  [<c0230819>] do_path_lookup+0x59/0xb0
[ 3120.620367]  [<c02311ff>] user_path_at+0x3f/0x70
[ 3120.620374]  [<c02005b8>] ? do_linear_fault+0x58/0x70
[ 3120.620380]  [<c020133a>] ? handle_mm_fault+0xda/0x230
[ 3120.620387]  [<c0228899>] vfs_fstatat+0x49/0x70


Finally, the client saturates the 100 MBit connection with sending and
receiving from the NFS server. I'm pretty sure this is garbage data,
even if the client would copy the entire mountpoint there wouldn't be
that much data to copy.


There are no visible symptoms on the server.



Anyone able to help?


Thanks,


   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C
