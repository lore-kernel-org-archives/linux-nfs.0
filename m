From: "Aaron Wiebe" <epiphani@gmail.com>
Subject: nlm bad unlocking condition (results in stuck lock serverside)
Date: Thu, 27 Mar 2008 12:33:47 -0400
Message-ID: <e7ca40f70803270933vb526f3bxb93be24b4f791926@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bseibel@gmail.com
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:25830 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761004AbYC0Qds (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Mar 2008 12:33:48 -0400
Received: by wa-out-1112.google.com with SMTP id v27so4892202wah.23
        for <linux-nfs@vger.kernel.org>; Thu, 27 Mar 2008 09:33:47 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Folks, we've been hunting an NLM bug here for a few days and I
think we've got enough information to bring this one to the community.

This exists, as far as we can tell, in the current tree, and goes back
at least as early as .22.

Two clients(one process per client), clientA holds a lock a full file
lock on a file.  The clientB is waiting on the lock.

If a signal is received for the process on clientB, the lock is
cancelled, then re-requested:

[11269.808195] lockd: server 10.1.230.34 CANCEL (async) status 0 pid 0
(0) type 0x1 0 -> 9223372036854775807 fh(32) 0x003d71ae 0x107ebab1
0x00000020 0xb799de00 0x06c2e532 0x5b0098
a0 0x003d71ae 0x007ebab1
[11269.819230] lockd: server 10.1.230.34 LOCK status 3 pid 1 (0) type
0x1 0 -> 9223372036854775807 fh(32) 0x003d71ae 0x107ebab1 0x00000020
0xb799de00 0x06c2e532 0x5b0098a0 0x003d7
1ae 0x007ebab1


The pid being incremented between requests, as it should.  Now, if
clientA releases its lock, clientB gets the callback properly, and
successfully gains the lock:

[11298.158595] lockd: server 10.1.230.34 GRANTED status 0 pid 1 (1)
type 0x1 0 -> 9223372036854775807 fh(32) 0x003d71ae 0x107ebab1
0x00000020 0xb799de00 0x06c2e532 0x5b0098a0 0x00
3d71ae 0x007ebab1


Now, clientB's process dies, releasing the lock:

[11306.465702] lockd: server 10.1.230.34 UNLOCK (async) status 0 pid 2
(0) type 0x2 0 -> 9223372036854775807 fh(32) 0x003d71ae 0x107ebab1
0x00000020 0xb799de00 0x06c2e532 0x5b0098a0 0x003d71ae 0x007ebab1

Note the pid here has incorrectly incremented.

We dug into this a bit and found that __nlm_find_lockowner() did not
correctly match the lock we were trying to find and unlock, so it
created a new lock "pid".  This results in the server ignoring the
unlock, and the file being permenently locked up.

We're no kernel wizards here, so we're looking for a bit of help.  Any
suggestions on where to look from here would be appreciated.

Thanks!

-Aaron
