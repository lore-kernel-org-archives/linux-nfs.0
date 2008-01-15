From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] nfs(5): Redress some nits in the description of the timeo
	option
Date: Tue, 15 Jan 2008 12:48:06 -0500
Message-ID: <20080115174806.30730.67197.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:57037 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbYAORsx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 12:48:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown noted:

 - It says UDP defaults to 7/10 of a second, but
      nfs_init_timeout_values()
   says:
		if (!to->to_initval)
			to->to_initval = 11 * HZ / 10;

   which suggests 11/10 of a second.

 - It says 
    If the retrans option is not specified, the NFS client retries
    each request three times.

  but nfs_init_timeout_values() says

	if (!to->to_retries)
		to->to_retries = 2;

   which suggests it retries 2 time (or tries 3 times).

 - It says:
      After each retransmission, the NFS client doubles the timeout
      for that request, up to a maximum timeout length of 60 seconds.

   but doesn't (to me) make it clear that only applies to UDP.  For
   TCP, the timeouts appear to increase linearly up to 600 seconds.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index bc1a6c6..2c0b687 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -121,25 +121,29 @@ option.
 .BI timeo= n
 The time (in tenths of a second) the NFS client waits for a 
 response before it retries an NFS request. If this 
-option is not specified, requests are retried after 
-60 seconds for NFS over TCP, and are retried after 7/10 of a second for
-NFS over UDP.
+option is not specified, requests are retried every
+60 seconds for NFS over TCP.
+The NFS client does not perform any kind of timeout backoff
+for NFS over TCP.
 .IP
-For NFS over TCP, the client uses a fixed timeout, as specified by the
-.B timeo
-option. However, for NFS over UDP, the client uses an adaptive
+However, for NFS over UDP, the client uses an adaptive
 algorithm to estimate an appropriate timeout value for frequently used
 request types (such as READ and WRITE requests), but uses the 
 .B timeo
 setting for infrequently used request types (such as FSINFO requests).
-After each retransmission, the NFS client doubles the timeout for that
-request, up to a maximum timeout length of 60 seconds.
+If the
+.B timeo
+option is not specified,
+infrequently used request types are retried after 1.1 seconds.
+After each retransmission, the NFS client doubles the timeout for
+that request,
+up to a maximum timeout length of 60 seconds.
 .TP 1.5i
 .BI retrans= n
 The number of times the NFS client retries a request before
 it attempts further recovery action. If the 
 .B retrans
-option is not specified, the NFS client retries each request 
+option is not specified, the NFS client tries each request 
 three times.
 .IP
 The NFS client generates a "server not responding" message

