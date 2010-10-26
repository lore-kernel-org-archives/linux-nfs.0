Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7923 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932464Ab0JZNSC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 09:18:02 -0400
Message-ID: <4CC6D4F9.3040402@netapp.com>
Date: Tue, 26 Oct 2010 09:17:45 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: rename idmapper components
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This patch renames the idmapper upcall program from nfs.upcall to nfs.idmap.
It also changes the key type from id_resolver to nfs_idmap.

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
+create	nfs_idmap	*	*		/usr/sbin/nfs.idmap %k %d 600
 
-This will direct all id_resolver requests to the program /usr/sbin/nfs.upcall.
+This will direct all nfs_idmap requests to the program /usr/sbin/nfs.idmap.
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
+create	nfs_idmap	uid:*	*		/some/other/program %k %d 600
+create	nfs_idmap	*	*		/usr/sbin/nfs.idmap %k %d 600
 
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
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index dec47ed..313e878 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -49,10 +49,10 @@
 
 #define NFS_UINT_MAXLEN 11
 
-const struct cred *id_resolver_cache;
+const struct cred *nfs_idmap_cache;
 
-struct key_type key_type_id_resolver = {
-	.name		= "id_resolver",
+struct key_type key_type_nfs_idmap = {
+	.name		= "nfs_idmap",
 	.instantiate	= user_instantiate,
 	.match		= user_match,
 	.revoke		= user_revoke,
@@ -67,13 +67,13 @@ int nfs_idmap_init(void)
 	struct key *keyring;
 	int ret = 0;
 
-	printk(KERN_NOTICE "Registering the %s key type\n", key_type_id_resolver.name);
+	printk(KERN_NOTICE "Registering the %s key type\n", key_type_nfs_idmap.name);
 
 	cred = prepare_kernel_cred(NULL);
 	if (!cred)
 		return -ENOMEM;
 
-	keyring = key_alloc(&key_type_keyring, ".id_resolver", 0, 0, cred,
+	keyring = key_alloc(&key_type_keyring, ".nfs_idmap", 0, 0, cred,
 			     (KEY_POS_ALL & ~KEY_POS_SETATTR) |
 			     KEY_USR_VIEW | KEY_USR_READ,
 			     KEY_ALLOC_NOT_IN_QUOTA);
@@ -86,13 +86,13 @@ int nfs_idmap_init(void)
 	if (ret < 0)
 		goto failed_put_key;
 
-	ret = register_key_type(&key_type_id_resolver);
+	ret = register_key_type(&key_type_nfs_idmap);
 	if (ret < 0)
 		goto failed_put_key;
 
 	cred->thread_keyring = keyring;
 	cred->jit_keyring = KEY_REQKEY_DEFL_THREAD_KEYRING;
-	id_resolver_cache = cred;
+	nfs_idmap_cache = cred;
 	return 0;
 
 failed_put_key:
@@ -104,9 +104,9 @@ failed_put_cred:
 
 void nfs_idmap_quit(void)
 {
-	key_revoke(id_resolver_cache->thread_keyring);
-	unregister_key_type(&key_type_id_resolver);
-	put_cred(id_resolver_cache);
+	key_revoke(nfs_idmap_cache->thread_keyring);
+	unregister_key_type(&key_type_nfs_idmap);
+	put_cred(nfs_idmap_cache);
 }
 
 /*
@@ -150,8 +150,8 @@ static ssize_t nfs_idmap_request_key(const char *name, size_t namelen,
 	if (ret <= 0)
 		goto out;
 
-	saved_cred = override_creds(id_resolver_cache);
-	rkey = request_key(&key_type_id_resolver, desc, "");
+	saved_cred = override_creds(nfs_idmap_cache);
+	rkey = request_key(&key_type_nfs_idmap, desc, "");
 	revert_creds(saved_cred);
 	kfree(desc);
 	if (IS_ERR(rkey)) {
