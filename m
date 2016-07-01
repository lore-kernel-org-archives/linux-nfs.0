Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0047.hostedemail.com ([216.40.44.47]:58485 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752152AbcGAV0O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jul 2016 17:26:14 -0400
Date: Fri, 1 Jul 2016 17:24:01 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: LKML <linux-kernel@vger.kernel.org>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        "Andrew Morton" <akpm@linux-foundation.org>,
        Fields Bruce <bfields@fieldses.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Revert: SUNRPC: xs_sock_mark_closed() does not need to trigger
 socket autoclose
Message-ID: <20160701172401.3ba89015@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A while back, rkhunter reported a "hidden port" on my main server,
making me nervous that I had been hacked. Doing lots of debugging, I
found that it was happening from xprt code in NFS. I found a way to
trigger the bug, which happened because my wife's machine was NFS
mounting a directory of my main server. She does this to upload her
photos quickly to gallery2.

  "Warning: Hidden ports found:
         Port number: TCP:871"

A hidden port is one that has no socket connected to it. That is, it's
a dead resource. Nothing can ever use that port. It's not something
that is "reserved", it's just a leaked bit of info. rkhunter treats
this as a possible root kit attack.

I did a bisect and found the culprit and worked with the NFS folks who
came up with a fix that made rkhunter happy again.

Link: http://lkml.kernel.org/r/20150611234929.7b48d314@gandalf.local.home

The previous fix was 4876cc779ff5 ("SUNRPC: Ensure we release the TCP
socket once it has been closed")

Recently, after traveling with my wife, she decided to upload pictures
again and mounted the directory, and lo and behold the hidden port
re-appeared. I noticed that the mounting of the NFS directory caused
this to happen again. I did lots of debugging to see why and asked for
help from the NFS folks again. But this time I didn't receive much help.

Link: http://lkml.kernel.org/r/20160630085950.61e5c7e0@gandalf.local.home

Frustrated, I spent all day bisecting this, and found that this bug was
created in the next release. And I even found the commit that causes
this bug: 4b0ab51db32e ("SUNRPC: xs_sock_mark_closed() does not need to
trigger socket autoclose"). This commit states:

   "Under all conditions, it should be quite sufficient just to mark
    the socket as disconnected. It will then be closed by the
    transport shutdown or reconnect code."

Well, this isn't quite correct. And doing a little git blaming, the
line that it removed was added by the first commit above that
previously fixed my issue.

Reverting this commit makes rkhunter and myself quite happy again.

I consider this userland breakage, as rkhunter is a userland tool and
this commit causes it to report a problem that does not exist.

Fixes: 4b0ab51db32e ("SUNRPC: xs_sock_mark_closed() does not need to trigger socket autoclose")
Cc: stable@vger.kernel.org # v4.3+
Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7e2b2fa189c3..5579d13e253f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -768,6 +768,7 @@ static void xs_sock_mark_closed(struct rpc_xprt *xprt)
 	xs_sock_reset_connection_flags(xprt);
 	/* Mark transport as closed and wake up all pending tasks */
 	xprt_disconnect_done(xprt);
+	xprt_force_disconnect(xprt);
 }
 
 /**
