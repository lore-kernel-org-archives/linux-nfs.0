X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Google-Smtp-Source: ABdhPJwgMkdiTauYu+oieIS4qmAPC3QThXjnASMTenellKmNg41mab2+9sEQDcYu5pACvsiWz0WD
X-Received: by 2002:a05:6402:450:: with SMTP id
 p16mr13007643edw.162.1633288969291; Sun, 03 Oct 2021 12:22:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1633288969; cv=none; d=google.com;
 s=arc-20160816;
 b=W5Jm/J03z/BgfqACEEiQwFeOkZClRpZv9nvpgZzTMHt8E31YVosP0ZfhonUqiBKz97
 4YgOut0wQiwvjcSVsX+dD2yjoJFZGQ8neMOtZKNcS9jXdiJ9oSsXALwq/emFrML8K0Ou
 IYYOmItsRKK7ETe0/jQmdIbcd8fyVpJuHs0gzCxU5WzMarBy37a3XtpgceMLEkoZ25Bz
 862ORI8htJuSDkSC+aQv5RYeH6ySMyW0XtysJKs/86Eg0ICPYNJphVx4mda4vNcUNu/f
 zZGCy6+J8bJiSHRPdNNv7Gjw2/GIulH7/0WpsZU+58LV0ES/BLFzG6e1mLfgCcJnokzx d0tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com;
 s=arc-20160816; h=references:in-reply-to:message-id:date:subject:cc:to:from
 :delivered-to; bh=s/ZfeZOjZZzrckKpwSqT/AHynvj4PLjMOpapX/6qlPw=;
 b=C0K/13MDOjwCagxrcfpblJrRb6moVXNnPVEzCi9sD0XCFqIcC3iAmCaVHqbXcrpRZP
 g6TREvv4EdqG/bIvx+sHAKTqITGr0YM++nHS1ZJ3Np+YkZIr+75Gkmz53BWk2NuhEwIQ
 gaBx9m0odtZTQmoOn5Ca3KcjUjdAlErG1s+mVyOZDsdnewyqECntrny98SXCV4qnOGHq
 P3GdXfSr+bWmP8PhPCD+hDosU/5mkei9XZerTh2RWtYqmDhNB64wUdQUgoaj0ldhOHZm
 rsGmE2flU9HRLM8TA43p6dwg1XT7NWzE7HVK3IP+6jWiQOeikEf3YSqo7XAsWDnEui2v H7tQ==
ARC-Authentication-Results: i=1; mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 205.139.110.61 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Return-Path: <dwysocha@redhat.com>
Received: from us-smtp-1.mimecast.com (us-smtp-2.mimecast.com.
 [205.139.110.61]) by mx.google.com with ESMTPS id
 gn42si3504465ejc.441.2021.10.03.12.22.48 for <dhowells@gapps.redhat.com>
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128); Sun, 03
 Oct 2021 12:22:49 -0700 (PDT)
Received-SPF: pass (google.com: domain gapps.redhat.com configured
 205.139.110.61 as internal address)
Authentication-Results: mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 205.139.110.61 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-6-vK5sNePDO8WjVvJ6pD8TkQ-1; Sun, 03 Oct 2021 15:22:47 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com
 [10.5.11.15]) (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits)) (No
 client certificate requested) by mimecast-mx01.redhat.com (Postfix) with
 ESMTPS id CAE9D802C9B for <dhowells@gapps.redhat.com>; Sun,  3 Oct 2021
 19:22:45 +0000 (UTC)
Received: by smtp.corp.redhat.com (Postfix) id C71465F4E9; Sun,  3 Oct 2021
 19:22:45 +0000 (UTC)
Received: from dwysocha.rdu.csb (unknown [10.22.8.148]) by
 smtp.corp.redhat.com (Postfix) with ESMTPS id 326135F4E8; Sun,  3 Oct 2021
 19:22:45 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: Trond Myklebust <trondmy@hammerspace.com>, Anna Schumaker
 <anna.schumaker@netapp.com>, David Howells <dhowells@redhat.com>
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v1 3/7] NFS: Cleanup usage of nfs_inode in fscache interface
 and handle i_size properly
Date: Sun,  3 Oct 2021 15:22:34 -0400
Message-Id: <1633288958-8481-4-git-send-email-dwysocha@redhat.com>
In-Reply-To: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
References: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
Authentication-Results: relay.mimecast.com; auth=pass smtp.auth=CUSA124A263
 smtp.mailfrom=dwysocha@redhat.com
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
List-Id: <linux-nfs.vger.kernel.org>
Content-Type: text/plain; charset="US-ASCII"

A number of places in the fscache interface used nfs_inode when inode could
be used, simplifying the code.  Also, handle the read of i_size properly by
utilizing the i_size_read() interface.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 fs/nfs/fscache.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index d3efb8ba4fb7..8f17fda5b8c9 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -226,16 +226,16 @@ void nfs_fscache_release_super_cookie(struct super_block *sb)
 }
 
 static void nfs_fscache_update_auxdata(struct nfs_fscache_inode_auxdata *auxdata,
-				  struct nfs_inode *nfsi)
+				  struct inode *inode)
 {
 	memset(auxdata, 0, sizeof(*auxdata));
-	auxdata->mtime_sec  = nfsi->vfs_inode.i_mtime.tv_sec;
-	auxdata->mtime_nsec = nfsi->vfs_inode.i_mtime.tv_nsec;
-	auxdata->ctime_sec  = nfsi->vfs_inode.i_ctime.tv_sec;
-	auxdata->ctime_nsec = nfsi->vfs_inode.i_ctime.tv_nsec;
+	auxdata->mtime_sec  = inode->i_mtime.tv_sec;
+	auxdata->mtime_nsec = inode->i_mtime.tv_nsec;
+	auxdata->ctime_sec  = inode->i_ctime.tv_sec;
+	auxdata->ctime_nsec = inode->i_ctime.tv_nsec;
 
-	if (NFS_SERVER(&nfsi->vfs_inode)->nfs_client->rpc_ops->version == 4)
-		auxdata->change_attr = inode_peek_iversion_raw(&nfsi->vfs_inode);
+	if (NFS_SERVER(inode)->nfs_client->rpc_ops->version == 4)
+		auxdata->change_attr = inode_peek_iversion_raw(inode);
 }
 
 /*
@@ -251,13 +251,13 @@ void nfs_fscache_init_inode(struct inode *inode)
 	if (!(nfss->fscache && S_ISREG(inode->i_mode)))
 		return;
 
-	nfs_fscache_update_auxdata(&auxdata, nfsi);
+	nfs_fscache_update_auxdata(&auxdata, inode);
 
 	nfsi->fscache = fscache_acquire_cookie(NFS_SB(inode->i_sb)->fscache,
 					       &nfs_fscache_inode_object_def,
 					       nfsi->fh.data, nfsi->fh.size,
 					       &auxdata, sizeof(auxdata),
-					       nfsi, nfsi->vfs_inode.i_size, false);
+					       nfsi, i_size_read(inode), false);
 }
 
 /*
@@ -271,7 +271,7 @@ void nfs_fscache_clear_inode(struct inode *inode)
 
 	dfprintk(FSCACHE, "NFS: clear cookie (0x%p/0x%p)\n", nfsi, cookie);
 
-	nfs_fscache_update_auxdata(&auxdata, nfsi);
+	nfs_fscache_update_auxdata(&auxdata, inode);
 	fscache_relinquish_cookie(cookie, &auxdata, false);
 	nfsi->fscache = NULL;
 }
@@ -311,7 +311,7 @@ void nfs_fscache_open_file(struct inode *inode, struct file *filp)
 	if (!fscache_cookie_valid(cookie))
 		return;
 
-	nfs_fscache_update_auxdata(&auxdata, nfsi);
+	nfs_fscache_update_auxdata(&auxdata, inode);
 
 	if (inode_is_open_for_write(inode)) {
 		dfprintk(FSCACHE, "NFS: nfsi 0x%p disabling cache\n", nfsi);
@@ -319,7 +319,7 @@ void nfs_fscache_open_file(struct inode *inode, struct file *filp)
 		fscache_disable_cookie(cookie, &auxdata, true);
 	} else {
 		dfprintk(FSCACHE, "NFS: nfsi 0x%p enabling cache\n", nfsi);
-		fscache_enable_cookie(cookie, &auxdata, nfsi->vfs_inode.i_size,
+		fscache_enable_cookie(cookie, &auxdata, i_size_read(inode),
 				      nfs_fscache_can_enable, inode);
 		if (fscache_cookie_enabled(cookie))
 			set_bit(NFS_INO_FSCACHE, &NFS_I(inode)->flags);
-- 
1.8.3.1

