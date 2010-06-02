Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44239 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755447Ab0FBDly (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jun 2010 23:41:54 -0400
Date: Wed, 2 Jun 2010 13:41:45 +1000
From: Neil Brown <neilb@suse.de>
To: linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org, jeffm@suse.com
Subject: NFS exporting btrfs subvolumes.
Message-ID: <20100602134145.0d523a75@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


NFS needs a unique identifier for a filesystem to be able to export it.

This can be set by the admin (fsid= in /etc/exports) but that is a hassle
and it is best to set it automatically.

nfs-utils currently uses the UUID returned by libblkid if that works,
or the fsid returned by statfs64 if libblkid finds nothings and 
fsid is non-zero. Otherwise it uses device major/minor.

This doesn't work well for btrfs as all subvolumes are mounted from the same
device and so report the same UUID.  But the fsid provides better uniqueness
(despite being only half as many bits), at least between different 
subvolumes of the same filesystem.

This wasn't a problem between Aug 2008 (nfs-utils 1.1.4) when using fsid was
added, and Jan 2009 (util-linux 2.15-rc1) when UUID support for btrfs was
added to libblkid.

But with libblkid from util-linux 2.15 or later, nfs-utils needs a different
approach to synthesising a UUID for a btrfs filesystem.

The simplest would be to explicitly ignore btrfs results from libblkid as
the following patch does.  However this is rather hackish, and wastes half
of the bits in the uuid.

Can anyone suggest a better way to get a good uuid for a btrfs filesystem?

Thanks,
NeilBrown

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index caef5b2..ffc5ac7 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -176,7 +176,8 @@ static const char *get_uuid_blkdev(char *path)
 	blkid_tag_iterate iter;
 	blkid_dev dev;
 	const char *type;
-	const char *val = NULL;
+	const char *val;
+	const char *uuid_val = NULL;
 
 	if (cache == NULL)
 		blkid_get_cache(&cache, NULL);
@@ -193,11 +194,16 @@ static const char *get_uuid_blkdev(char *path)
 	iter = blkid_tag_iterate_begin(dev);
 	if (!iter)
 		return NULL;
-	while (blkid_tag_next(iter, &type, &val) == 0)
+	while (blkid_tag_next(iter, &type, &val) == 0) {
 		if (strcmp(type, "UUID") == 0)
+			uuid_val = val;
+		if (strcmp(type, "TYPE") == 0 &&
+		    strcmp(val, "btrfs") == 0) {
+			uuid_val = NULL;
 			break;
+	}
 	blkid_tag_iterate_end(iter);
-	return val;
+	return uuid_val;
 }
 #else
 #define get_uuid_blkdev(path) (NULL)
