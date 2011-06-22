Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:62443 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753924Ab1FVMdY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 08:33:24 -0400
Received: by qwk3 with SMTP id 3so347016qwk.19
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2011 05:33:23 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, neilb@suse.de, chuck.lever@oracle.com,
        bfields@fieldses.org
Subject: [PATCH] nfs: fix host_reliable_addrinfo
Date: Wed, 22 Jun 2011 08:33:19 -0400
Message-Id: <1308745999-6551-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

According to Neil Brown:

    The point of the word 'reliable' is to check that the name we get
    really does belong to the host in question - ie that both the
    forward and reverse maps agree.

    But the new code doesn't do that check at all.  Rather it simply
    maps the address to a name, then discards the address and maps the
    name back to a list of addresses and uses that list of addresses as
    "where the request came from" for permission checking.

Fix this by instead using the forward lookup of the hostname just to
verify that the original address is in the list. Then do a numeric
lookup using the address and stick the hostname in the ai_canonname.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: NeilBrown <neilb@suse.de>
---
 support/export/hostname.c |   26 ++++++++++++++++++++++++--
 1 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/support/export/hostname.c b/support/export/hostname.c
index efcb75c..595333e 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -268,7 +268,7 @@ __attribute_malloc__
 struct addrinfo *
 host_reliable_addrinfo(const struct sockaddr *sap)
 {
-	struct addrinfo *ai;
+	struct addrinfo *ai, *a;
 	char *hostname;
 
 	hostname = host_canonname(sap);
@@ -276,9 +276,31 @@ host_reliable_addrinfo(const struct sockaddr *sap)
 		return NULL;
 
 	ai = host_addrinfo(hostname);
+	if (!ai)
+		goto out_free_hostname;
 
-	free(hostname);
+	/* make sure there's a matching address in the list */
+	for (a = ai; a; a = a->ai_next)
+		if (nfs_compare_sockaddr(a->ai_addr, sap))
+			break;
+
+	freeaddrinfo(ai);
+	if (!a)
+		goto out_free_hostname;
+
+	/* get addrinfo with just the original address */
+	ai = host_numeric_addrinfo(sap);
+	if (!ai)
+		goto out_free_hostname;
+
+	/* and populate its ai_canonname field */
+	free(ai->ai_canonname);
+	ai->ai_canonname = hostname;
 	return ai;
+
+out_free_hostname:
+	free(hostname);
+	return NULL;
 }
 
 /**
-- 
1.7.5.4

