Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:45945 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750927Ab2CSMiQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 08:38:16 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1S9bqn-0000W7-P7
	for linux-nfs@vger.kernel.org; Mon, 19 Mar 2012 08:38:14 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] idmapd: logging of Local-Realms only lists the last realm
Date: Mon, 19 Mar 2012 08:36:56 -0400
Message-Id: <1332160616-4522-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Juno Krahn <Juno.Krahn@gmail.com>

The list of local realms can be logged with a massage like the following:
   rpc.idmapd: libnfsidmap: Realms list: 'EXAMPLE2.COM'
Instead of printing a list of realms, only the last realm in the list is shown.

https://bugzilla.redhat.com/show_bug.cgi?id=804152

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 libnfsidmap.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libnfsidmap.c b/libnfsidmap.c
index 57bb6c3..641d766 100644
--- a/libnfsidmap.c
+++ b/libnfsidmap.c
@@ -285,8 +285,9 @@ int nfs4_init_name_mapping(char *conffile)
 			}
 			buf = malloc(siz);
 			if (buf) {
+				*buf = 0;
 				TAILQ_FOREACH(r, &local_realms->fields, link) {
-					sprintf(buf, "'%s' ", r->field);
+					sprintf(buf+strlen(buf), "'%s' ", r->field);
 				}
 				IDMAP_LOG(1, ("libnfsidmap: Realms list: %s", buf));
 				free(buf);
-- 
1.7.7.5

