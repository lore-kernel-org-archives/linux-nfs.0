From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] DefineSimpleCache macro problem
Date: Thu, 13 May 2004 10:22:45 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040513082245.GM22052@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="s2ZSL+KKDSLx8OML"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BOBXW-0007aN-VZ
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 01:26:02 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BOBXW-0002ro-B1
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 01:26:02 -0700
Received: from hermes.suse.de (Hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id BA4F859E9D1
	for <nfs@lists.sourceforge.net>; Thu, 13 May 2004 10:22:45 +0200 (CEST)
To: nfs@lists.sourceforge.net
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


--s2ZSL+KKDSLx8OML
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

the 2.6 code has this new cache stuff to create caches for various
things, which is used for the export table and ip client list.

I came across a strange problem where a host exported several directories
to a group of clients, but clients were unable to mount more than one.

It turned out that the problem was caused by svc_export_lookup, which
will create bogus entries even if called in lookup-only mode.  This caused
bogus export entries to be created, which didn't have the VALID flag set.

Essentially, the macro-defined function in sunrpc/cache.h will always
create entries in the cache, even if "set == 0". The attached patch
fixes this, and changes the lookup functions to return NULL in this
case, rather than a bogus entry.

However, this change uncovered another problem. AIX clients will
do a NULL procedure call before attempting the mount (I think this
is a known issue). If the file system is exported to a wildcard
group, the kernel will not know about the client when this call
arrives.

Previously, this would always succeed, because the ip_map_lookup() call
from svcauth_unix_accept() would always return an entry, even if it was
a bogus one. With the change to cache.h, ip_map_lookup() will now return
NULL for unknown clients, causing the NULL call from the AIX client
to be dropped. The second patch attached below will fix this issue
as well.

Cheers
Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--s2ZSL+KKDSLx8OML
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=sunrpc-bogus-export-entry

--- linux-2.6.5/include/linux/sunrpc/cache.h.bug	2004-03-12 12:17:26.000000000 +0100
+++ linux-2.6.5/include/linux/sunrpc/cache.h	2004-05-10 13:19:58.000000000 +0200
@@ -223,7 +223,7 @@
 	else read_unlock(&(DETAIL)->hash_lock);						\
 	if (new && set)									\
 		cache_fresh(DETAIL, &new->MEMBER, item->MEMBER.expiry_time);		\
-	if (new)				       					\
+	if (new || !set)			       					\
 		return new;								\
 	new = kmalloc(sizeof(*new), GFP_KERNEL);					\
 	if (new) {									\

--s2ZSL+KKDSLx8OML
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=sunrpc-null-noauth

--- linux-2.6.5/net/sunrpc/svcauth_unix.c.aix	2004-05-12 21:40:41.000000000 +0200
+++ linux-2.6.5/net/sunrpc/svcauth_unix.c	2004-05-13 10:05:38.000000000 +0200
@@ -390,7 +390,13 @@
 			break;
 		default: BUG();
 		}
-	else rv = SVC_DROP;
+	else if (rqstp->rq_proc == 0) {
+		/* We always accept calls to NULL. AIX clients try
+		   a NULL call before mounting, so when we get here
+		   we may not know about the export entry yet. */
+		rv = SVC_OK;
+	} else
+		rv = SVC_DROP;
 
 	if (rqstp->rq_client == NULL && rqstp->rq_proc != 0)
 		*authp = rpc_autherr_badcred;

--s2ZSL+KKDSLx8OML--


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
