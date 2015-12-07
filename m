Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60485 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932184AbbLGQmF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 11:42:05 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 40D8767C20
	for <linux-nfs@vger.kernel.org>; Mon,  7 Dec 2015 16:42:05 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] statd: make statd_canonical_name emit a warning if the presentation address maps to an empty hostname
Date: Mon,  7 Dec 2015 11:42:03 -0500
Message-Id: <1449506523-21897-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Certain name resolution misconfigurations (for example, a hosts file
entry with an ip address but no hostnames) can cause get_nameinfo() to
return an empty string in buf, which will lead to this cryptic failure:

Dec  7 09:37:44 hostname rpc.statd[8024]: Failed to insert: creating
/var/lib/nfs/statd/sm/: Is a directory
Dec  7 09:37:44 hostname rpc.statd[8024]: STAT_FAIL to
hostname.example.com for SM_MON of 192.168.1.2
Dec  7 09:37:44 hostname kernel: lockd: cannot monitor 192.168.1.2

It's better in that case to just go ahead and use the presentation
address and log a more helpful warning:

Dec  7 10:24:52 hostname rpc.statd[14224]: get_nameinfo returned empty
hostname for 10.10.183.219.  Fix your name resolution!

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/statd/hostname.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
index c61087c..86d11ca 100644
--- a/utils/statd/hostname.c
+++ b/utils/statd/hostname.c
@@ -211,6 +211,12 @@ statd_canonical_name(const char *hostname)
 			/* OK to use presentation address,
 			 * if no reverse map exists */
 			return strdup(hostname);
+		else if (buf[0] == '\0') {
+			xlog_warn("get_nameinfo returned empty hostname for "
+					"%s. Fix your name resolution!",
+					hostname);
+			return strdup(hostname);
+		}
 		return strdup(buf);
 	}
 
-- 
2.4.3

