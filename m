Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51900 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751782AbeFDOux (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Jun 2018 10:50:53 -0400
Received: from smtp.corp.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7A0C93640F7
        for <linux-nfs@vger.kernel.org>; Mon,  4 Jun 2018 14:50:53 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-215.phx2.redhat.com [10.3.116.215])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 31F7D30012D0
        for <linux-nfs@vger.kernel.org>; Mon,  4 Jun 2018 14:50:53 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/4] xtab.c: Removed overflow in implicit constant conversion errors
Date: Mon,  4 Jun 2018 10:50:48 -0400
Message-Id: <20180604145051.146390-2-steved@redhat.com>
In-Reply-To: <20180604145051.146390-1-steved@redhat.com>
References: <20180604145051.146390-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xtab.c: In function 'xtab_read':
xtab.c:60:4: error: overflow in implicit constant conversion
[-Werror=overflow]
    exp->m_xtabent = 1;
    ^
xtab.c:61:4: error: overflow in implicit constant conversion
[-Werror=overflow]
    exp->m_mayexport = 1;

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/include/exportfs.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 8af47a8..a82a9b8 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -97,7 +97,7 @@ typedef struct mexport {
 	struct mclient *	m_client;
 	struct exportent	m_export;
 	int			m_exported;	/* known to knfsd. */
-	int			m_xtabent  : 1,	/* xtab entry exists */
+	unsigned int m_xtabent : 1,	/* xtab entry exists */
 				m_mayexport: 1,	/* derived from xtabbed */
 				m_changed  : 1, /* options (may) have changed */
 				m_warned   : 1; /* warned about multiple exports
-- 
1.8.3.1

