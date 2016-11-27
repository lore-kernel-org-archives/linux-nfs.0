Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:58263 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753222AbcK0G1Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Nov 2016 01:27:24 -0500
From: Tom Haynes <loghyr@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs 01/12] According to RFC7863, this is not an array
Date: Sat, 26 Nov 2016 22:26:30 -0800
Message-ID: <1480228001-64821-2-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And I'm pretty sure we had to change this to be compliant with
the Linux implementation.

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 nfs4.1/xdrdef/nfs4.x | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/nfs4.1/xdrdef/nfs4.x b/nfs4.1/xdrdef/nfs4.x
index 23c6d7c..16870f7 100644
--- a/nfs4.1/xdrdef/nfs4.x
+++ b/nfs4.1/xdrdef/nfs4.x
@@ -897,7 +897,7 @@ typedef change_policy4  fattr4_change_policy;
 typedef uint64_t        fattr4_space_freed;
 typedef change_attr_type4
                 fattr4_change_attr_type;
-typedef sec_label4      fattr4_sec_label<>;
+typedef sec_label4      fattr4_sec_label;
 typedef uint32_t        fattr4_clone_blksize;
=20
 %/*
--=20
2.3.6

