Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38103 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757608AbZHQRdz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Aug 2009 13:33:55 -0400
Date: Mon, 17 Aug 2009 13:33:56 -0400
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, Tom Haynes <tdh@excfb.com>
Subject: [PATCH] Don't give client an empty flavor list
Message-ID: <20090817173356.GF27331@fieldses.org>
References: <4A5F5C4C.3070308@excfb.com> <20090716185642.GB2495@fieldses.org> <4A5F7EA9.9050309@excfb.com> <20090716194546.GG2495@fieldses.org> <4A5F8A00.8000104@excfb.com> <20090722000955.GC20694@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20090722000955.GC20694@fieldses.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

In the absence of an explicit sec= option on an export, rpc.mountd is
returning a zero-length flavor list to clients in the MOUNT results.

The linux client doesn't seem to mind, but the Solaris client
(reasonably enough) is giving up; the symptom is a "security mode does
not match" error on mount.

We could modify the export-parsing code to ensure the secinfo array is
nonzero.  But I think it's slightly simpler to handle this default case
in the implementation of the MOUNT call.  This is more-or-less the same
thing the kernel does when mountd passes it an export without any
security flavors specified.

Thanks to Tom Haynes for bug report and diagnosis.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 utils/mountd/mountd.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index b59f939..888fd8c 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -359,6 +359,11 @@ static void set_authflavors(struct mountres3_ok *ok, nfs_export *exp)
 		flavors[i] = s->flav->fnum;
 		i++;
 	}
+	if (i == 0) {
+		/* default when there is no sec= option: */
+		i = 1;
+		flavors[0] = AUTH_UNIX;
+	}
 	ok->auth_flavors.auth_flavors_val = flavors;
 	ok->auth_flavors.auth_flavors_len = i;
 }
-- 
1.6.0.4

