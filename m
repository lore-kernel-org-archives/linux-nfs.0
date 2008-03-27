From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nlm bad unlocking condition (results in stuck lock
  serverside)
Date: Thu, 27 Mar 2008 16:21:39 -0400
Message-ID: <EXNANE01YTHrdusluCB000001cc@exnane01.hq.netapp.com>
References: <e7ca40f70803270933vb526f3bxb93be24b4f791926@mail.gmail.com> <e7ca40f70803270933vb526f3bxb93be24b4f791926@mail.gmail.com
 >
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	bseibel@gmail.com
To: "Aaron Wiebe" <epiphani@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16737 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756664AbYC0UVm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Mar 2008 16:21:42 -0400
In-Reply-To: <e7ca40f70803270933vb526f3bxb93be24b4f791926-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org
 >
References: <e7ca40f70803270933vb526f3bxb93be24b4f791926-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Aaron - I've been looking into this here, it does appear to be a
client issue. I suspect the lockowner is not being properly linked
into the per-server list, in the case where the lock request is
retried. It appears to be related to the use/reuse of the file_lock
struct that comes down with the call.

In kernels prior to 2.6.9, this may have worked fine because the same
lockowner was always used for a given process. It's not yet clear to
me if the lost-unlock behavior was also introduced there however.

I can reproduce some slightly different behavior using three flock(1)
commands, ^Z and ^C. I haven't been able to leave abandoned
locks on the server with these yet, however. More later...

Tom.

At 12:33 PM 3/27/2008, Aaron Wiebe wrote:
>Hey Folks, we've been hunting an NLM bug here for a few days and I
>think we've got enough information to bring this one to the community.
>
>This exists, as far as we can tell, in the current tree, and goes back
>at least as early as .22.
>
>Two clients(one process per client), clientA holds a lock a full file
>lock on a file.  The clientB is waiting on the lock.
>
>If a signal is received for the process on clientB, the lock is
>cancelled, then re-requested:
>
>[11269.808195] lockd: server 10.1.230.34 CANCEL (async) status 0 pid 0
>(0) type 0x1 0 -> 9223372036854775807 fh(32) 0x003d71ae 0x107ebab1
>0x00000020 0xb799de00 0x06c2e532 0x5b0098
>a0 0x003d71ae 0x007ebab1
>[11269.819230] lockd: server 10.1.230.34 LOCK status 3 pid 1 (0) type
>0x1 0 -> 9223372036854775807 fh(32) 0x003d71ae 0x107ebab1 0x00000020
>0xb799de00 0x06c2e532 0x5b0098a0 0x003d7
>1ae 0x007ebab1
>
>
>The pid being incremented between requests, as it should.  Now, if
>clientA releases its lock, clientB gets the callback properly, and
>successfully gains the lock:
>
>[11298.158595] lockd: server 10.1.230.34 GRANTED status 0 pid 1 (1)
>type 0x1 0 -> 9223372036854775807 fh(32) 0x003d71ae 0x107ebab1
>0x00000020 0xb799de00 0x06c2e532 0x5b0098a0 0x00
>3d71ae 0x007ebab1
>
>
>Now, clientB's process dies, releasing the lock:
>
>[11306.465702] lockd: server 10.1.230.34 UNLOCK (async) status 0 pid 2
>(0) type 0x2 0 -> 9223372036854775807 fh(32) 0x003d71ae 0x107ebab1
>0x00000020 0xb799de00 0x06c2e532 0x5b0098a0 0x003d71ae 0x007ebab1
>
>Note the pid here has incorrectly incremented.
>
>We dug into this a bit and found that __nlm_find_lockowner() did not
>correctly match the lock we were trying to find and unlock, so it
>created a new lock "pid".  This results in the server ignoring the
>unlock, and the file being permenently locked up.
>
>We're no kernel wizards here, so we're looking for a bit of help.  Any
>suggestions on where to look from here would be appreciated.
>
>Thanks!
>
>-Aaron

