From: Dan McGee <dpmcgee@gmail.com>
Subject: [PATCH] showmount: try v3 before falling back to v1
Date: Mon,  4 Jan 2010 19:34:07 -0600
Message-ID: <1262655247-16849-1-git-send-email-dpmcgee@gmail.com>
Cc: Dan McGee <dpmcgee@gmail.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f211.google.com ([209.85.217.211]:59664 "EHLO
	mail-gx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481Ab0AEBeL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2010 20:34:11 -0500
Received: by gxk3 with SMTP id 3so3305318gxk.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2010 17:34:11 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A lot of people don't have anything below v3 enabled, so showmount is
completely unusable. Try v3 {tcp, udp} first; if they don't work, fall back
to v1 {tcp, udp}; if those don't work then just fail as before.

Signed-off-by: Dan McGee <dpmcgee@gmail.com>
---

First (and quick) attempt at a patch here for showmount. Let me know if you see
serious problems with it or the approach. It seemed relatively sane to me and
fixed my problems after brief testing.

See a report like this for some proof this is an issue in the wild:
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=557954

Thanks,

-Dan

 utils/showmount/showmount.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index 418e8b9..716c06d 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -96,6 +96,14 @@ static CLIENT *nfs_get_mount_client(const char *hostname)
 	rpcprog_t program = nfs_getrpcbyname(MOUNTPROG, nfs_sm_pgmtbl);
 	CLIENT *client;
 
+	client = clnt_create(hostname, program, MOUNTVERS_NFSV3, "tcp");
+	if (client)
+		return client;
+
+	client = clnt_create(hostname, program, MOUNTVERS_NFSV3, "udp");
+	if (client)
+		return client;
+
 	client = clnt_create(hostname, program, MOUNTVERS, "tcp");
 	if (client)
 		return client;
-- 
1.6.6

