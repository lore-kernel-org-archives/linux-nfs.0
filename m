From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH][RESEND2] nfs-utils-1.0.6 permission denied on mount after
 'exportfs -u'
Date: Fri, 03 Dec 2004 10:49:20 -0800
Message-ID: <1102099760.4708.13.camel@w-bwa3.beaverton.ibm.com>
Reply-To: bwa@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CaIUl-00038h-Qv
	for nfs@lists.sourceforge.net; Fri, 03 Dec 2004 10:49:31 -0800
Received: from e3.ny.us.ibm.com ([32.97.182.143])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CaIUi-000225-80
	for nfs@lists.sourceforge.net; Fri, 03 Dec 2004 10:49:31 -0800
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iB3InLv5028515
	for <nfs@lists.sourceforge.net>; Fri, 3 Dec 2004 13:49:22 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iB3InLet284232
	for <nfs@lists.sourceforge.net>; Fri, 3 Dec 2004 13:49:21 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iB3InLXi006857
	for <nfs@lists.sourceforge.net>; Fri, 3 Dec 2004 13:49:21 -0500
To: neilb@cse.unsw.edu.au
Sender: nfs-admin@lists.sourceforge.net
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

Neil,

Have you had a chance to look at this yet? [I assume not since it is not in the latest nfs-utils-1.0.7-pre1]

Thanks,
Bruce Allan

-----Forwarded Message-----
From: Bruce Allan <bwa@us.ibm.com>
To: Neil Brown <neilb@cse.unsw.edu.au>
Cc: nfs@lists.sf.net
Subject: [PATCH] nfs-utils-1.0.6 permission denied on mount after 'exportfs -u'
Date: Thu, 26 Aug 2004 15:50:49 -0700

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
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
