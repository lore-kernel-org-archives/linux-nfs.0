From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] mount.nfs: Fix one more double-wide character nit
Date: Thu, 09 Aug 2007 17:36:51 -0400
Message-ID: <20070809213651.16767.2602.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJFgd-0007g1-Ky
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 14:36:55 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IJFgg-0005iN-I4
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 14:36:59 -0700
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 5a56c23..eb59c1f 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -388,7 +388,7 @@ static int probe_port(clnt_addr_t *server, const unsigned long *versions,
 						inet_ntoa(saddr->sin_addr),
 						prog, *p_vers,
 						*p_prot == IPPROTO_UDP ?
-							"udp" : "tcp",
+							_("UDP") : _("TCP"),
 						p_port);
                                 }
 				if (clnt_ping(saddr, prog, *p_vers, *p_prot, NULL))


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
