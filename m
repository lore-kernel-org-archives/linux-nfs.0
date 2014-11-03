Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436AbaKCRtk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Nov 2014 12:49:40 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com
Subject: [PATCH 2/2] nfsidmap: Correct a failure to set key timeout values
Date: Mon,  3 Nov 2014 12:49:33 -0500
Message-Id: <13a6c96c4a94b19e4e4e9f95250dca6e46c1969d.1415036893.git.bcodding@redhat.com>
In-Reply-To: <cover.1415036893.git.bcodding@redhat.com>
References: <cover.1415036893.git.bcodding@redhat.com>
In-Reply-To: <cover.1415036893.git.bcodding@redhat.com>
References: <cover.1415036893.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The caller must be a possesor of the key to set the attributes, so link the
destination keyring to the current thread's keyring before instantiation so
that after instantiation the timeout can be set.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 utils/nfsidmap/nfsidmap.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 4da7f5c..b141f9e 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -329,6 +329,9 @@ int main(int argc, char **argv)
 			key, type, value, timeout);
 	}
 
+	/* become a possesor of the to-be-instantiated key to set the key's timeout */
+	request_key("keyring", DEFAULT_KEYRING, NULL, KEY_SPEC_THREAD_KEYRING);
+
 	if (strcmp(type, "uid") == 0)
 		rc = id_lookup(value, key, USER);
 	else if (strcmp(type, "gid") == 0)
-- 
1.7.1

