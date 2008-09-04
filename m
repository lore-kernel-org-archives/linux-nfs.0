From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: fix nfs_parse_ip_address() corner case
Date: Thu, 4 Sep 2008 16:23:02 -0400
Message-ID: <20080904202302.GD13981@fieldses.org>
References: <20080903203414.3322.97607.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52161 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757297AbYIDUXE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 16:23:04 -0400
In-Reply-To: <20080903203414.3322.97607.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 03, 2008 at 04:35:57PM -0400, Chuck Lever wrote:
> Bruce observed that nfs_parse_ip_address() will successfully parse an
> IPv6 address that looks like this:
> 
>   "::1%"
> 
> A scope delimiter is present, but there is no scope ID following it.
> This is harmless, as it would simply set the scope ID to zero.  However,
> in some cases we would like to flag this as an improperly formed
> address.
> 
> We are now also careful to reject addresses where garbage follows the
> address (up to the length of the string), instead of ignoring the
> non-address characters; and where the scope ID is nonsense (not a valid
> device name, but also not numeric).  Before, both of these cases would
> result in a harmless zero scope ID.

Slightly irrelevant, but same comment as before--wouldn't it be easier
to follow the logic if instead of:

	p = kstrndup(...)
	if (p) {
		do stuff for successful case
		....
		return 1;
	}

	return 0;

it were:

	p = kstrndup(...)
	if (!p)
		return 0;
	do stuff for successful case
	...
	return 1;

e.g., the below, on top of yours. (Untested.)

Might also combine the two final exits in the usual way:

	out:
		kfree(p);
		return ret;

--b.

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a9f5a12..fcee897 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -733,6 +733,8 @@ static int nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
 {
 	size_t len = (string + str_len) - delim - 1;
 	char *p;
+	unsigned long scope_id = 0;
+	struct net_device *dev;
 
 	if (len == 0)
 		return 1;
@@ -744,29 +746,25 @@ static int nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
 		return 0;
 
 	p = kstrndup(delim + 1, len, GFP_KERNEL);
-	if (p) {
-		unsigned long scope_id = 0;
-		struct net_device *dev;
-
-		dev = dev_get_by_name(&init_net, p);
-		if (dev != NULL) {
-			scope_id = dev->ifindex;
-			dev_put(dev);
-		} else {
-			if (strict_strtoul(p, 10, &scope_id) == 0) {
-				kfree(p);
-				return 0;
-			}
-		}
-
-		kfree(p);
+	if (!p)
+		return 0;
 
-		sin6->sin6_scope_id = scope_id;
-		dfprintk(MOUNT, "NFS: IPv6 scope ID = %lu\n", scope_id);
-		return 1;
+	dev = dev_get_by_name(&init_net, p);
+	if (dev != NULL) {
+		scope_id = dev->ifindex;
+		dev_put(dev);
+	} else {
+		if (strict_strtoul(p, 10, &scope_id) == 0) {
+			kfree(p);
+			return 0;
+		}
 	}
 
-	return 0;
+	kfree(p);
+
+	sin6->sin6_scope_id = scope_id;
+	dfprintk(MOUNT, "NFS: IPv6 scope ID = %lu\n", scope_id);
+	return 1;
 }
 
 static void nfs_parse_ipv6_address(char *string, size_t str_len,
