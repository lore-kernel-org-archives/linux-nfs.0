Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:40300 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964926Ab2HHSCD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 14:02:03 -0400
Received: by ggdk6 with SMTP id k6so351574ggd.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 11:02:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMFXNOxxP=+u37Ju_-15RViFrVtmAAufsGiYRQoE87QurFBphw@mail.gmail.com>
References: <CAMFXNOxxP=+u37Ju_-15RViFrVtmAAufsGiYRQoE87QurFBphw@mail.gmail.com>
From: "bjschuma@gmail.com" <bjschuma@gmail.com>
Date: Wed, 8 Aug 2012 14:01:42 -0400
Message-ID: <CAMFXNOyz7iC45dd+9XWONXSxkL-XZHWb_W3rYrvP+QmLH39b5Q@mail.gmail.com>
Subject: [PATCH 2/2] NFS: Alias the nfs module to nfs4
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I forgot to CC the mailing list... oops.


---------- Forwarded message ----------
From: bjschuma@gmail.com <bjschuma@gmail.com>
Date: Wed, Aug 8, 2012 at 1:57 PM
Subject: [PATCH 2/2] NFS: Alias the nfs module to nfs4
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, jlayton@redhat.com


This allows distros to remove the line from their modprobe
configuration.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c  | 2 ++
 1 files changed, 2 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c4a15c5..239aff7 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2680,4 +2680,6 @@ MODULE_PARM_DESC(max_session_slots, "Maximum
number of outstanding NFSv4.1 "
 module_param(send_implementation_id, ushort, 0644);
 MODULE_PARM_DESC(send_implementation_id,
                "Send implementation ID with NFSv4.1 exchange_id");
+MODULE_ALIAS("nfs4");
+
 #endif /* CONFIG_NFS_V4 */
--
1.7.11.4
