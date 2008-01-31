From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [NFS] [PATCH] nfs-utils: fix CROSSMOUNT test in utils/mountd/cache.c
Date: Thu, 31 Jan 2008 11:19:53 -0800
Message-ID: <1201807193.1517.8.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS List <nfs@lists.sourceforge.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43559 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760995AbYAaTXz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jan 2008 14:23:55 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JKf0m-0006TC-7b
	for linux-nfs@vger.kernel.org; Fri, 01 Feb 2008 06:23:48 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While debugging problems with nfs-utils, I noticed the following bit of
code:


			/* If one is a CROSSMOUNT, then prefer the longest path */
			if (((found->m_export.e_flags & NFSEXP_CROSSMOUNT) ||
			     (found->m_export.e_flags & NFSEXP_CROSSMOUNT)) &&
			    strlen(found->m_export.e_path) !=
			    strlen(found->m_export.e_path)) {

This will never actually be hit since the two strlens are always the
same!

Here is a simple patch to fix this to what I assume the intent was:

Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>

--- ./utils/mountd/cache.c.orig	2008-01-31 11:09:10.000000000 -0800
+++ ./utils/mountd/cache.c	2008-01-31 11:09:53.000000000 -0800
@@ -708,9 +708,9 @@ void nfsd_export(FILE *f)
 			}
 			/* If one is a CROSSMOUNT, then prefer the longest path */
 			if (((found->m_export.e_flags & NFSEXP_CROSSMOUNT) ||
-			     (found->m_export.e_flags & NFSEXP_CROSSMOUNT)) &&
+			     (exp->m_export.e_flags & NFSEXP_CROSSMOUNT)) &&
 			    strlen(found->m_export.e_path) !=
-			    strlen(found->m_export.e_path)) {
+			    strlen(exp->m_export.e_path)) {
 
 				if (strlen(exp->m_export.e_path) >
 				    strlen(found->m_export.e_path)) {



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

