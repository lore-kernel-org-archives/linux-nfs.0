From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/4] NFS: Remove checks for scope id's in v6 addresses in
	the fs-locations code
Date: Thu, 09 Oct 2008 15:00:32 -0400
Message-ID: <20081009190032.18388.30136.stgit@localhost.localdomain>
References: <20081009190031.18388.95039.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64609 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760752AbYJITEh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 15:04:37 -0400
In-Reply-To: <20081009190031.18388.95039.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

The concensus on the list is that servers should not be allowed to send
anything other than ordinary IPv6 addresses, or DNS hostnames in the
fs-locations attribute.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/internal.h      |    2 --
 fs/nfs/nfs4namespace.c |    2 --
 fs/nfs/super.c         |    2 ++
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5d2a5d3..be091cb 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -277,8 +277,6 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
 		PAGE_SIZE - 1) >> PAGE_SHIFT;
 }
 
-#define IPV6_SCOPE_DELIMITER	'%'
-
 /*
  * Set the port number in an address.  Be agnostic about the address
  * family.
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 30befc3..13c37de 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -118,8 +118,6 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 
 		mountdata->addr = (struct sockaddr *)&addr;
 
-		if (memchr(buf->data, IPV6_SCOPE_DELIMITER, buf->len))
-			continue;
 		nfs_parse_ip_address(buf->data, buf->len,
 				mountdata->addr, &mountdata->addrlen);
 		if (mountdata->addr->sa_family == AF_UNSPEC)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 20dc4cc..6b447f5 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -716,6 +716,8 @@ static void nfs_parse_ipv4_address(char *string, size_t str_len,
 	*addr_len = 0;
 }
 
+#define IPV6_SCOPE_DELIMITER	'%'
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static void nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
 				    const char *delim,

