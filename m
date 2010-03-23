From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] libexport.a: Remove unused function client_checkaddr()
Date: Tue, 23 Mar 2010 12:53:13 -0400
Message-ID: <20100323165313.4368.20351.stgit@localhost.localdomain>
References: <20100323165122.4368.43659.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:48378 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755118Ab0CWQxR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Mar 2010 12:53:17 -0400
Received: by mail-qy0-f179.google.com with SMTP id 9so951500qyk.1
        for <linux-nfs@vger.kernel.org>; Tue, 23 Mar 2010 09:53:17 -0700 (PDT)
In-Reply-To: <20100323165122.4368.43659.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 42bf45a..419a4a7 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -32,7 +32,6 @@ extern int	innetgr(char *netgr, char *host, char *, char *);
 static char	*add_name(char *old, const char *add);
 static void	client_init(nfs_client *clp, const char *hname,
 					struct hostent *hp);
-static int	client_checkaddr(nfs_client *clp, struct in_addr addr);
 
 nfs_client	*clientlist[MCL_MAXTYPES] = { NULL, };
 
@@ -448,12 +447,6 @@ client_check(nfs_client *clp, struct hostent *hp)
 	return 0;
 }
 
-static int
-client_checkaddr(nfs_client *clp, struct in_addr addr)
-{
-	return 0;
-}
-
 int
 client_gettype(char *ident)
 {

