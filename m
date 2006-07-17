From: Mario Fetka <mario-fetka@gmx.at>
Subject: Heimdal compile error
Date: Mon, 17 Jul 2006 10:49:29 +0200
Message-ID: <200607171049.31126.mario-fetka@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2Opk-0007hx-5b
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 01:52:08 -0700
Received: from mail.gmx.net ([213.165.64.21])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1G2Opj-00020Y-VJ
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 01:52:08 -0700
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

the following patch corrects the error.

diff -urN nfs-utils-1.0.7.org/utils/gssd/context_heimdal.c 
nfs-utils-1.0.7/utils/gssd/context_heimdal.c
--- nfs-utils-1.0.7.org/utils/gssd/context_heimdal.c    2005-07-10 
12:14:01.526867000 +0200
+++ nfs-utils-1.0.7/utils/gssd/context_heimdal.c        2005-07-10 
12:14:32.815110736 +0200
@@ -46,6 +46,20 @@
 #include "gss_oids.h"
 #include "write_bytes.h"

+typedef struct gss_ctx_id_t_desc_struct {
+  struct krb5_auth_context_data *auth_context;
+  gss_name_t source, target;
+  OM_uint32 flags;
+  enum { LOCAL = 1, OPEN = 2,
+         COMPAT_OLD_DES3 = 4,
+         COMPAT_OLD_DES3_SELECTED = 8,
+  } more_flags;
+  struct krb5_ticket *ticket;
+  OM_uint32 lifetime;
+  pthread_mutex_t ctx_id_mutex;
+  struct gss_msg_order *order;
+} gss_ctx_id_t_desc;
+
 #define MAX_CTX_LEN 4096

 int write_heimdal_keyblock(char **p, char *end, krb5_keyblock *key)

wfg
Mario




-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
