Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:58982 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756721Ab0GDDac (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Jul 2010 23:30:32 -0400
Received: by qyk35 with SMTP id 35so965912qyk.19
        for <linux-nfs@vger.kernel.org>; Sat, 03 Jul 2010 20:30:31 -0700 (PDT)
Message-ID: <4C300049.7040603@gmail.com>
Date: Sat, 03 Jul 2010 23:30:17 -0400
From: Doug Nazar <nazard.michi@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: gssd picking wrong creds
Content-Type: multipart/mixed;
 boundary="------------020801000701050304040608"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------020801000701050304040608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

  I'm running rpc.gssd with the the -n option. Noticed that with the new 
version it's now creating the machine cache file which is also owned by 
root so when it scans the cache files it matches the root user and then 
depending on the timestamp it can grab the wrong file.

Doug


--------------020801000701050304040608
Content-Type: text/plain;
 name="nfs-utils-ignore-machine-cred.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nfs-utils-ignore-machine-cred.diff"

commit 891bf46cd23dbbb24188456aad29ac0ead2bc31f
Author: Doug Nazar <nazard.michi@gmail.com>
Date:   Sat Jul 3 23:12:27 2010 -0400

    When not using machine credentials for root, if the machine
    credential cache file is newer than the root credential file
    the wrong file will get picked. Ignore the machine file in this
    case.

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index dccbeb6..d23654f 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -224,6 +224,13 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 				free(namelist[i]);
 				continue;
 			}
+			if (uid == 0 && !root_uses_machine_creds && 
+				strstr(namelist[i]->d_name, "_machine_")) {
+				printerr(3, "CC file '%s' not available to root\n",
+					 statname);
+				free(namelist[i]);
+				continue;
+			}
 			if (!query_krb5_ccache(buf, &princname, &realm)) {
 				printerr(3, "CC file '%s' is expired or corrupt\n",
 					 statname);

--------------020801000701050304040608--
