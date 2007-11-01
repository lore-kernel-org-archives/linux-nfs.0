From: Neil Brown <neilb@suse.de>
Subject: [PATCH nfs-utils] probe_port should not try other versions in
	a version was explicitly given.
Date: Thu,  1 Nov 2007 16:26:54 +1100
Message-ID: <1193894817-20622-1-git-send-email-neilb@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InSa5-0004D8-Th
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 22:27:02 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1InSaB-000354-A5
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 22:27:07 -0700
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

Currently if probe port is asked to probe for a specific version, and
that version is not supported, it will probe other versions too.
This means that if mountd is run with "--no-nfs-version 3",
It will first probe for NFS version 3, which will succeed (assuming the
kernel supported NFSv3), then it will check the matching mountd version (3)
and probe_port on discovering that isn't supported will try other versions,
find "1" is supported will succeed.

This leaves up using mount version 1 for an NFSv3 mount, which doesn't work
and leads to a SIGSEGV

There is no case where trying other versions is needed the request one is
not supported, so simply remove that code.

Signed-off-by: Neil Brown <neilb@suse.de>
---
 utils/mount/network.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 63d5f5a..2b09457 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -417,10 +417,6 @@ static int probe_port(clnt_addr_t *server, const unsigned long *versions,
 				continue;
 			p_prot = protos;
 		}
-		if (vers == pmap->pm_vers) {
-			p_vers = versions;
-			vers = 0;
-		}
 		if (vers || !*++p_vers)
 			break;
 	}
-- 
1.5.3.4


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
