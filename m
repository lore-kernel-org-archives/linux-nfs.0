From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/30] What's in the NFS queue for 2.6.27
Date: Wed, 8 Oct 2008 15:31:14 -0400
Message-ID: <20081008193114.GA12386@fieldses.org>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59727 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754572AbYJHTbQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 15:31:16 -0400
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 07, 2008 at 06:19:52PM -0400, Trond Myklebust wrote:
> Most of the following patches are bugfixes:
>   There are a couple of spin locking fixes to follow up the BKL removal.
>   There are some attribute update fixups, mainly to make the spin
>   locking more efficient
>   A fix for the problem of autobind on cloned RPC clients
> 
> The one feature that has been added is the lookup revalidation mount
> option to allow clients to specify that they might not want to cache
> negative dentries, and that they might want strict dentry revalidation.

The version of the fs_locations fixes are slightly older than my most
recent.  Looking back through the archive, I think it may have been my
mistake.  Sorry!

There's a missing patch from Chuck that makes the ip address parsing a
bit more paranoid.  I'll resend that, followed by the newer versions of
the other patches.

Aside from the missing patch from Chuck, the only difference between the
versions you have and my latest are summarized below.  it's just:

	- a cosmetic change to set_port to address your complaints about
	  blocks used just to define local variables, and
	- changes to stop bothering to check for scope id's in v6
	  addresses.

So--could you just take the following patches, and throw out the 4
corresponding patches from me in your current tree?

--b.

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 625abae..14199c2 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -277,24 +277,21 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
 		PAGE_SIZE - 1) >> PAGE_SHIFT;
 }
 
-#define IPV6_SCOPE_DELIMITER	'%'
-
 /*
  * Set the port number in an address.  Be agnostic about the address
  * family.
  */
 static inline void nfs_set_port(struct sockaddr *sap, unsigned short port)
 {
+	struct sockaddr_in *ap = (struct sockaddr_in *)sap;
+	struct sockaddr_in6 *ap6 = (struct sockaddr_in6 *)sap;
+
 	switch (sap->sa_family) {
-	case AF_INET: {
-	      struct sockaddr_in *ap = (struct sockaddr_in *)sap;
-	      ap->sin_port = htons(port);
-	      break;
-	}
-	case AF_INET6: {
-	       struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
-	       ap->sin6_port = htons(port);
-	       break;
-	}
+	case AF_INET:
+		ap->sin_port = htons(port);
+		break;
+	case AF_INET6:
+		ap6->sin6_port = htons(port);
+		break;
 	}
 }
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
index b173653..78c0dd9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -705,6 +705,8 @@ static void nfs_parse_ipv4_address(char *string, size_t str_len,
 	*addr_len = 0;
 }
 
+#define IPV6_SCOPE_DELIMITER	'%'
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static void nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
 				    const char *delim,
