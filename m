Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44106 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932084AbbLGSWX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 13:22:23 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 16CFF49DBE
	for <linux-nfs@vger.kernel.org>; Mon,  7 Dec 2015 18:22:23 +0000 (UTC)
Received: from tonberry.usersys.redhat.com (dhcp145-110.rdu.redhat.com [10.13.145.110])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tB7IMMFB028012
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 7 Dec 2015 13:22:22 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.15.2/8.14.5) with ESMTP id tB7IMM7U019883
	for <linux-nfs@vger.kernel.org>; Mon, 7 Dec 2015 13:22:22 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.15.2/8.15.2/Submit) id tB7IMM86019867
	for linux-nfs@vger.kernel.org; Mon, 7 Dec 2015 13:22:22 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2] statd: make statd_canonical_name return the presentation address if it maps to an empty hostname
Date: Mon,  7 Dec 2015 13:22:22 -0500
Message-Id: <1449512542-19826-1-git-send-email-smayhew@redhat.com>
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
address instead.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/statd/hostname.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
index c61087c..8cccdb8 100644
--- a/utils/statd/hostname.c
+++ b/utils/statd/hostname.c
@@ -180,9 +180,6 @@ get_nameinfo(const struct sockaddr *sap,
  * Incoming hostnames are looked up to determine the canonical hostname,
  * and incoming presentation addresses are converted to canonical
  * hostnames.
- *
- * We won't monitor peers that don't have a reverse map.  The canonical
- * name gives us a key for our monitor list.
  */
 __attribute__((__malloc__))
 char *
@@ -207,7 +204,7 @@ statd_canonical_name(const char *hostname)
 		result = get_nameinfo(ai->ai_addr, ai->ai_addrlen,
 					buf, (socklen_t)sizeof(buf));
 		freeaddrinfo(ai);
-		if (!result)
+		if (!result || buf[0] == '\0')
 			/* OK to use presentation address,
 			 * if no reverse map exists */
 			return strdup(hostname);
-- 
2.4.3

