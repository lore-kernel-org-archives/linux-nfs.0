From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH] nfs-utils-1.0.6 permission denied on mount after 'exportfs
 -u'
Date: Thu, 26 Aug 2004 15:50:49 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1093560649.14283.33.camel@w-bwa3.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0T5G-0007We-3v
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 15:51:06 -0700
Received: from e35.co.us.ibm.com ([32.97.110.133])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C0T5F-0002xt-JY
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 15:51:06 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi Neil,

There is a problem with rpc.mountd after doing an 'exportfs -u' such as
in the following:

[server]# exportfs *:/foo
[client]# mount server:/foo /mnt
[client]# umount /mnt
[server]# exportfs -u *:/foo
[server]# exportfs client:/foo
[client]# mount server:/foo /mnt
mount: server:/foo failed, reason given by server: Permission denied

In the above situation, the static my_client doesn't get cleared as a
result of the unexporting.  Since the client address is the same in both
mount requests it won't perform a new lookup and will continue to use
the previous hostname, i.e. "*".  Unfortunately, the list of clients in
the exportlist no longer contains "*" for a hostname (only contains the
hostname "client") and will return a NULL pointer with a not_exported
error.

--- nfs-utils-1.0.6/utils/mountd/auth.c	2003-07-14 15:10:12.000000000 -0700
+++ nfs-utils-1.0.6-auth.c/utils/mountd/auth.c	2004-08-26 14:52:40.000000000 -0700
@@ -30,6 +30,8 @@ enum auth_error
 
 static void		auth_fixpath(char *path);
 static char	*export_file = NULL;
+static nfs_export my_exp;
+static nfs_client my_client;
 
 extern int new_cache;
 
@@ -55,6 +57,7 @@ auth_reload()
 	last_modified = stb.st_mtime;
 
 	export_freeall();
+	memset(&my_client, 0, sizeof(nfs_client));
 	// export_read(export_file);
 	xtab_export_read();
 
@@ -69,8 +72,6 @@ auth_authenticate_internal(char *what, s
 	nfs_export		*exp;
 
 	if (new_cache) {
-		static nfs_export my_exp;
-		static nfs_client my_client;
 		int i;
 		/* return static nfs_export with details filled in */
 		if (my_client.m_naddr != 1 ||

Regards,
---
Bruce Allan  <bwa@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
