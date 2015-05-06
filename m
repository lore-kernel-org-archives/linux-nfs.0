Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33029 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbbEFNT2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 09:19:28 -0400
Message-ID: <554A14DB.1020504@gmail.com>
Date: Wed, 06 May 2015 21:19:23 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 1/4] fs_pin: Fix uninitialized value in fs_pin
References: <554A149B.5060102@gmail.com>
In-Reply-To: <554A149B.5060102@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Without initialized, done in fs_pin at stack space may
contains strange value.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/fs_pin.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/fs_pin.h b/include/linux/fs_pin.h
index 3886b3b..18fad53 100644
--- a/include/linux/fs_pin.h
+++ b/include/linux/fs_pin.h
@@ -16,6 +16,7 @@ static inline void init_fs_pin(struct fs_pin *p, void (*kill)(struct fs_pin *))
 	INIT_HLIST_NODE(&p->s_list);
 	INIT_HLIST_NODE(&p->m_list);
 	p->kill = kill;
+	p->done = 0;
 }
 
 void pin_remove(struct fs_pin *);
-- 
2.4.0


