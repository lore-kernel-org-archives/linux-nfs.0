From: joe@perches.com
Subject: [PATCH] [279/2many] MAINTAINERS - KERNEL NFSD
Date: Sun, 12 Aug 2007 23:30:45 -0700
Message-ID: <46bffa95.aPjsc88tjaey80vh%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: torvalds@linux-foundation.org, nfs@lists.sourceforge.net,
	neilb@suse.de, linux-kernel@vger.kernel.org, bfields@fieldses.org,
	akpm@linux-foundation.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKTSG-00061s-Vm
	for nfs@lists.sourceforge.net; Sun, 12 Aug 2007 23:31:09 -0700
Received: from dsl022.labridge.com ([206.117.136.22] helo=perches.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKTSK-0004dT-Mn
	for nfs@lists.sourceforge.net; Sun, 12 Aug 2007 23:31:13 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 0ac42ee..6e955c9 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2675,6 +2675,8 @@ M:	neilb@suse.de
 L:	nfs@lists.sourceforge.net
 W:	http://nfs.sourceforge.net/
 S:	Supported
+F:	fs/nfsd/
+F:	include/linux/nfsd/
 
 KERNEL VIRTUAL MACHINE (KVM)
 P:	Avi Kivity

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
