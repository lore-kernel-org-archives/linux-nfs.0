From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] libexport.a: Reduce code duplication in client_init()
Date: Mon, 12 Apr 2010 15:57:16 -0400
Message-ID: <20100412195715.9839.87962.stgit@localhost.localdomain>
References: <20100412195538.9839.76495.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:33204 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744Ab0DLT5S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Apr 2010 15:57:18 -0400
Received: by qyk9 with SMTP id 9so642107qyk.1
        for <linux-nfs@vger.kernel.org>; Mon, 12 Apr 2010 12:57:17 -0700 (PDT)
In-Reply-To: <20100412195538.9839.76495.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  Most cases in client_init() set clp->m_naddr to zero.  Move
it to the common part of the function, and simplify the logic.  This
will make adding IPv6 support here more straightforward.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index aa28fcf..e06c874 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -137,6 +137,7 @@ client_init(nfs_client *clp, const char *hname, struct hostent *hp)
 
 	clp->m_exported = 0;
 	clp->m_count = 0;
+	clp->m_naddr = 0;
 
 	if (clp->m_type == MCL_SUBNETWORK) {
 		char	*cp = strchr(clp->m_hostname, '/');
@@ -160,10 +161,10 @@ client_init(nfs_client *clp, const char *hname, struct hostent *hp)
 			}
 		}
 		*cp = '/';
-		clp->m_naddr = 0;
-	} else if (!hp) {
-		clp->m_naddr = 0;
-	} else {
+		return;
+	}
+
+	if (hp) {
 		char	**ap = hp->h_addr_list;
 		int	i;
 

