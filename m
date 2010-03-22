From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] libexport.a: e_fslocdata should be freed with free(3)
Date: Sun, 21 Mar 2010 20:38:32 -0400
Message-ID: <20100322003832.30360.25119.stgit@localhost.localdomain>
References: <20100322003317.30360.18289.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:40049 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492Ab0CVAif (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Mar 2010 20:38:35 -0400
Received: by qyk9 with SMTP id 9so2899439qyk.1
        for <linux-nfs@vger.kernel.org>; Sun, 21 Mar 2010 17:38:34 -0700 (PDT)
In-Reply-To: <20100322003317.30360.18289.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Since e_fslocdata is allocated with strdup(3), and not
xstrdup(), it should be freed with free(3), and not xfree().

It looks like we could get rid of the "if (thing I'm freeing isn't
NULL)" checks too, but that's for another day.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/export.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/support/export/export.c b/support/export/export.c
index ba643b2..42e78f6 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -277,7 +277,7 @@ export_freeall(void)
 			if (exp->m_export.e_mountpoint)
 				free(exp->m_export.e_mountpoint);
 			if (exp->m_export.e_fslocdata)
-				xfree(exp->m_export.e_fslocdata);
+				free(exp->m_export.e_fslocdata);
 			xfree(exp->m_export.e_hostname);
 			xfree(exp);
 		}

