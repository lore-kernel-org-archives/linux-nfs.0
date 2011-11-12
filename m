Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:56222 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753194Ab1KLPxj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2011 10:53:39 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RPFrG-0003ID-Un
	for linux-nfs@vger.kernel.org; Sat, 12 Nov 2011 10:51:07 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] idmapper.txt: Fix the upcall binary name.
Date: Sat, 12 Nov 2011 10:53:37 -0500
Message-Id: <1321113217-10018-3-git-send-email-steved@redhat.com>
In-Reply-To: <1321113217-10018-1-git-send-email-steved@redhat.com>
References: <1321113217-10018-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The binary that handles the upcalls from is kernel is called
nfsidmap not nfs.idmap.

The '-k' flag is now used to specify the timeout

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 Documentation/filesystems/nfs/idmapper.txt |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/Documentation/filesystems/nfs/idmapper.txt b/Documentation/filesystems/nfs/idmapper.txt
index 120fd3c..18276ef 100644
--- a/Documentation/filesystems/nfs/idmapper.txt
+++ b/Documentation/filesystems/nfs/idmapper.txt
@@ -6,7 +6,7 @@ Id mapper is used by NFS to translate user and group ids into names, and to
 translate user and group names into ids.  Part of this translation involves
 performing an upcall to userspace to request the information.  Id mapper will
 user request-key to perform this upcall and cache the result.  The program
-/usr/sbin/nfs.idmap should be called by request-key, and will perform the
+/usr/sbin/nfsidmap should be called by request-key, and will perform the
 translation and initialize a key with the resulting information.
 
  NFS_USE_NEW_IDMAPPER must be selected when configuring the kernel to use this
@@ -20,12 +20,12 @@ direct the upcall.  The following line should be added:
 
 #OP	TYPE	DESCRIPTION	CALLOUT INFO	PROGRAM ARG1 ARG2 ARG3 ...
 #======	=======	===============	===============	===============================
-create	id_resolver	*	*		/usr/sbin/nfs.idmap %k %d 600
+create	id_resolver	*	*		/usr/sbin/nfsidmap -t 600 %k %d
 
-This will direct all id_resolver requests to the program /usr/sbin/nfs.idmap.
-The last parameter, 600, defines how many seconds into the future the key will
-expire.  This parameter is optional for /usr/sbin/nfs.idmap.  When the timeout
-is not specified, nfs.idmap will default to 600 seconds.
+This will direct all id_resolver requests to the program /usr/sbin/nfsidmap.
+The '-k 600' arguemnt defines how many seconds into the future the key will
+expire.  This parameter is optional for /usr/sbin/nfsidmap.  When the timeout
+is not specified, nfsidmap will default to 600 seconds.
 
 id mapper uses for key descriptions:
 	  uid:  Find the UID for the given user
@@ -39,29 +39,29 @@ would edit your request-key.conf so it look similar to this:
 
 #OP	TYPE	DESCRIPTION	CALLOUT INFO	PROGRAM ARG1 ARG2 ARG3 ...
 #======	=======	===============	===============	===============================
-create	id_resolver	uid:*	*		/some/other/program %k %d 600
-create	id_resolver	*	*		/usr/sbin/nfs.idmap %k %d 600
+create	id_resolver	uid:*	*		/some/other/program %k %d
+create	id_resolver	*	*		/usr/sbin/nfsidmap -t 600 %k %d
 
 Notice that the new line was added above the line for the generic program.
 request-key will find the first matching line and corresponding program.  In
 this case, /some/other/program will handle all uid lookups and
-/usr/sbin/nfs.idmap will handle gid, user, and group lookups.
+/usr/sbin/nfsidmap will handle gid, user, and group lookups.
 
 See <file:Documentation/security/keys-request-key.txt> for more information
 about the request-key function.
 
 
 =========
-nfs.idmap
+nfsidmap
 =========
-nfs.idmap is designed to be called by request-key, and should not be run "by
+nfsidmap is designed to be called by request-key, and should not be run "by
 hand".  This program takes two arguments, a serialized key and a key
 description.  The serialized key is first converted into a key_serial_t, and
 then passed as an argument to keyctl_instantiate (both are part of keyutils.h).
 
-The actual lookups are performed by functions found in nfsidmap.h.  nfs.idmap
+The actual lookups are performed by functions found in nfsidmap.h.  nfsidmap
 determines the correct function to call by looking at the first part of the
 description string.  For example, a uid lookup description will appear as
 "uid:user@domain".
 
-nfs.idmap will return 0 if the key was instantiated, and non-zero otherwise.
+nfsidmap will return 0 if the key was instantiated, and non-zero otherwise.
-- 
1.7.7

