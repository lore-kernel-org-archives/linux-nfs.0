From: Bryan Schumaker <bjschuma@netapp.com>
Subject: NFS: rename nfs.upcall -> nfs.idmap
Date: Tue, 26 Oct 2010 13:16:48 -0400
Message-ID: <4CC70D00.2020804@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1909 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754233Ab0JZRQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 13:16:50 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This patch renames the idmapper upcall program from nfs.upcall to nfs.idmap.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
diff --git a/Documentation/filesystems/nfs/idmapper.txt b/Documentation/filesystems/nfs/idmapper.txt
index c385204..18ee6f5 100644
--- a/Documentation/filesystems/nfs/idmapper.txt
+++ b/Documentation/filesystems/nfs/idmapper.txt
@@ -6,7 +6,7 @@ Id mapper is used by NFS to translate user and group ids into names, and to
 translate user and group names into ids.  Part of this translation involves
 performing an upcall to userspace to request the information.  Id mapper will
 user request-key to perform this upcall and cache the result.  The program
-/usr/sbin/nfs.upcall should be called by request-key, and will perform the
+/usr/sbin/nfs.idmap should be called by request-key, and will perform the
 translation and initialize a key with the resulting information.
 
  NFS_USE_NEW_IDMAPPER must be selected when configuring the kernel to use this
@@ -20,12 +20,12 @@ direct the upcall.  The following line should be added:
 
 #OP	TYPE	DESCRIPTION	CALLOUT INFO	PROGRAM ARG1 ARG2 ARG3 ...
 #======	=======	===============	===============	===============================
-create	id_resolver	*	*		/usr/sbin/nfs.upcall %k %d 600
+create	id_resolver	*	*		/usr/sbin/nfs.idmap %k %d 600
 
-This will direct all id_resolver requests to the program /usr/sbin/nfs.upcall.
+This will direct all id_resolver requests to the program /usr/sbin/nfs.idmap.
 The last parameter, 600, defines how many seconds into the future the key will
-expire.  This parameter is optional for /usr/sbin/nfs.upcall.  When the timeout
-is not specified, nfs.upcall will default to 600 seconds.
+expire.  This parameter is optional for /usr/sbin/nfs.idmap.  When the timeout
+is not specified, nfs.idmap will default to 600 seconds.
 
 id mapper uses for key descriptions:
 	  uid:  Find the UID for the given user
@@ -39,29 +39,29 @@ would edit your request-key.conf so it look similar to this:
 
 #OP	TYPE	DESCRIPTION	CALLOUT INFO	PROGRAM ARG1 ARG2 ARG3 ...
 #======	=======	===============	===============	===============================
-create	id_resolver	uid:*	*		/some/other/program  %k %d 600
-create	id_resolver	*	*		/usr/sbin/nfs.upcall %k %d 600
+create	id_resolver	uid:*	*		/some/other/program %k %d 600
+create	id_resolver	*	*		/usr/sbin/nfs.idmap %k %d 600
 
 Notice that the new line was added above the line for the generic program.
 request-key will find the first matching line and corresponding program.  In
 this case, /some/other/program will handle all uid lookups and
-/usr/sbin/nfs.upcall will handle gid, user, and group lookups.
+/usr/sbin/nfs.idmap will handle gid, user, and group lookups.
 
 See <file:Documentation/keys-request-keys.txt> for more information about the
 request-key function.
 
 
-==========
-nfs.upcall
-==========
-nfs.upcall is designed to be called by request-key, and should not be run "by
+=========
+nfs.idmap
+=========
+nfs.idmap is designed to be called by request-key, and should not be run "by
 hand".  This program takes two arguments, a serialized key and a key
 description.  The serialized key is first converted into a key_serial_t, and
 then passed as an argument to keyctl_instantiate (both are part of keyutils.h).
 
-The actual lookups are performed by functions found in nfsidmap.h.  nfs.upcall
+The actual lookups are performed by functions found in nfsidmap.h.  nfs.idmap
 determines the correct function to call by looking at the first part of the
 description string.  For example, a uid lookup description will appear as
 "uid:user@domain".
 
-nfs.upcall will return 0 if the key was instantiated, and non-zero otherwise.
+nfs.idmap will return 0 if the key was instantiated, and non-zero otherwise.
