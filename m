Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:50001 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932438Ab2GENd4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jul 2012 09:33:56 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1SmloG-0003YK-1W
	for linux-nfs@vger.kernel.org; Thu, 05 Jul 2012 09:09:28 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsidmap: Default domain not being set.
Date: Thu,  5 Jul 2012 09:11:43 -0400
Message-Id: <1341493903-20835-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsidmap is not calling the nfs4_init_name_mapping()
function which initializes the default domain from
either the DNS domain or the Domain variable in /etc/idmap.conf

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsidmap/nfsidmap.c |   20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index b767395..e14543c 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -37,17 +37,6 @@ static int keyring_clear(char *keyring);
 #define GIDKEYS 0x2
 
 /*
- * Check to the config file for the verbosity level
- */
-int
-get_config_verbose(char *path)
-{
-	conf_path = path;
-	conf_init();
-	return conf_get_num("General", "Verbosity", 0);
-}
-
-/*
  * Find either a user or group id based on the name@domain string
  */
 int id_lookup(char *name_at_domain, key_serial_t key, int type)
@@ -282,9 +271,14 @@ int main(int argc, char **argv)
 			break;
 		}
 	}
-	if (!verbose) {
-		verbose = get_config_verbose(PATH_IDMAPDCONF);
+
+	if (nfs4_init_name_mapping(PATH_IDMAPDCONF))  {
+		xlog_err("Unable to create name to user id mappings.");
+		return 1;
 	}
+	if (!verbose)
+		verbose = conf_get_num("General", "Verbosity", 0);
+
 	if (keystr) {
 		rc = key_revoke(keystr, keymask);
 		return rc;		
-- 
1.7.10.2

