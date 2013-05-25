Return-Path: linux-nfs-owner@vger.kernel.org
Received: from master.debian.org ([82.195.75.110]:44486 "EHLO
	master.debian.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758140Ab3EYWC2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 May 2013 18:02:28 -0400
Date: Sun, 26 May 2013 08:02:17 +1000
From: =?iso-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsidmap: Don't check ENABLE_LDAP twice
Message-ID: <20130525220217.GA4330@master.debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To build the Debian libnfsidmap package, I've used the patch in this
mail for more than a year.

Debian-BTS: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=661215
Author: Steve Langasek <steve.langasek@ubuntu.com>
Description: Don't check ENABLE_LDAP twice
 This source is already being conditionally compiled based on ENABLE_LDAP
 being set in the Makefile.  All this extra check does is cause umich_ldap.so
 to always be compiled as an *EMPTY* object because nothing sets ENABLE_LDAP
 before the #ifdef!
Bug-Ubuntu: https://bugs.launchpad.net/bugs/939232

diff -up a/umich_ldap.c b/umich_ldap.c
--- a/umich_ldap.c	2011-12-06 07:28:10.000000000 +1100
+++ b/umich_ldap.c	2012-02-27 13:21:34.000000000 +1100
@@ -32,8 +32,6 @@
  * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
-#ifdef ENABLE_LDAP
-
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <netdb.h>
@@ -1302,4 +1300,3 @@ struct trans_func *libnfsidmap_plugin_in
 {
 	return (&umichldap_trans);
 }
-#endif
