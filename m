From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 07/12] Use the gssglue version of gssapi.h for
	svcgssd_mech2file.c
Date: Thu, 08 Feb 2007 17:27:25 -0500
Message-ID: <20070208222724.23464.41717.stgit@rock.citi.umich.edu>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFHk6-0006sl-IG
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:50 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HFHk7-0004QQ-9A
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:52 -0800
In-Reply-To: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
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

From: Kevin Coffman <kwc@citi.umich.edu>

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>

Remove Kerberos implementation dependency from svcgssd_mech2file.c
---

 utils/gssd/svcgssd_mech2file.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/utils/gssd/svcgssd_mech2file.c b/utils/gssd/svcgssd_mech2file.c
index f44f7c6..22c3ed8 100644
--- a/utils/gssd/svcgssd_mech2file.c
+++ b/utils/gssd/svcgssd_mech2file.c
@@ -36,11 +36,7 @@
 
 #include "config.h"
 
-#ifdef HAVE_KRB5
-#include <gssapi/gssapi_generic.h>
-#elif HAVE_HEIMDAL
-#include <gssapi.h>
-#endif
+#include <gssapi/gssapi.h>
 #include <string.h>
 
 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
