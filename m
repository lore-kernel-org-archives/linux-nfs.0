From: "David Konerding" <dakoner@gmail.com>
Subject: Re: [NFS] I/O Errors with hard mounts
Date: Mon, 9 Jun 2008 10:02:03 -0700
Message-ID: <4f0f0cb0806091002w7f0110fh17e40568c7eb5bb8@mail.gmail.com>
References: <505115.86554.qm@web31405.mail.mud.yahoo.com>
	<4f0f0cb0806061638i35ae4f9bp423148d6acbb953b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Ricardo Labiaga" <labiaga@yahoo.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:55020 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752192AbYFIXHB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 19:07:01 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K5qRy-0008EQ-4m
	for linux-nfs@vger.kernel.org; Tue, 10 Jun 2008 09:06:54 +1000
In-Reply-To: <4f0f0cb0806061638i35ae4f9bp423148d6acbb953b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I collected some more information on the problem we are seeing.

Here's what I've got:

1) SuSE 10.1 (2.6.16 kernel): running ls -R, hit Control-C-- often see
an "I/O Error", for example:

/gne/home/aa/barfod.files/mac.backup/Avi's/TNFR-IgG/Mutants/mAbs:
11.15.91
/bin/ls: reading directory
/gne/home/aa/barfod.files/mac.backup/Avi's/TNFR-IgG/Mutants/mAbs/11.15.91:
Input/output error

Here's what I captured from RPC and NFS debugging.  No "disconnect"
message like I saw before, but:

Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 xprt_transmit(136)
Jun  9 09:50:30 lablnx01 kernel: RPC:      xs_tcp_send_request(136) = 136
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 xmit complete
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 sleep_on(queue
"xprt_pending" time 4340153030)
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 added to queue
ffff81046bca5d20 "xprt_pending"
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 setting alarm for 60000 ms
Jun  9 09:50:30 lablnx01 kernel: RPC:
wake_up_next(ffff81046bca5cd0 "xprt_resend")
Jun  9 09:50:30 lablnx01 kernel: RPC:
wake_up_next(ffff81046bca5c80 "xprt_sending")
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 sync task going to sleep
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 got signal
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 __rpc_wake_up_task (now 4340153035)
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 disabling timer
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 removed from queue
ffff81046bca5d20 "xprt_pending"
Jun  9 09:50:30 lablnx01 kernel: RPC:      __rpc_wake_up_task done
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 sync task resuming
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 deleting timer
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206, return -512, status -512
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 release task
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 release request ffff81046f718000
Jun  9 09:50:30 lablnx01 kernel: RPC:
wake_up_next(ffff81046bca5d70 "xprt_backlog")
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 releasing UNIX cred ffff810c70dbba40
Jun  9 09:50:30 lablnx01 kernel: RPC:
rpc_release_client(ffff81046c15b800, 1)
Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 freeing task
Jun  9 09:50:30 lablnx01 kernel: NFS reply readdir: -512
Jun  9 09:50:30 lablnx01 kernel: NFS: find_dirent_page() returns -5
Jun  9 09:50:30 lablnx01 kernel: NFS: readdir_search_pagecache() returned -5
Jun  9 09:50:30 lablnx01 kernel: NFS: dentry_delete(mAbs/11.15.91, 8)


Note the "reply readdir: -512", is that consistent with what you guys
are saying?

Noticeably, I cannot get the error message on a host with a newer kernel.

Dave

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

