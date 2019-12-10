Return-Path: <SRS0=N5nt=2A=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1802C2D0BF
	for <linux-nfs@archiver.kernel.org>; Tue, 10 Dec 2019 12:32:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 985FB20836
	for <linux-nfs@archiver.kernel.org>; Tue, 10 Dec 2019 12:32:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="OrS64Vf2"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727590AbfLJMbY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 10 Dec 2019 07:31:24 -0500
Received: from us-smtp-delivery-1.mimecast.com ([207.211.31.120]:43977 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1727500AbfLJMbX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Dec 2019 07:31:23 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1575981082;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=H7RAmFZ02wbWW49ouv1oPyIzXMB87yUgwWLrN0yoU6w=;
        b=OrS64Vf2UJCKDDkxkZN7FTI+lzkzyO4Tn2af/kwD2WDiSjdrgQpMvQVZVUAwQy/dOyrnv/
        RMuZZ/yQ+eIsYI5ug8uJoDWABomPqy7CAMnC6PfWATCLOEiU2ms74hCmCJ3SV4I+z83tCm
        LSzlmpCgUAm0dvYiAoGvitDgWfVCOOE=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-285-k2ZS61UuOIieYAk1dsV5ag-1; Tue, 10 Dec 2019 07:31:18 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 2A88F107ACC5;
        Tue, 10 Dec 2019 12:31:17 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-123-90.rdu2.redhat.com [10.10.123.90])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 083606FEF3;
        Tue, 10 Dec 2019 12:31:17 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id C1E4B20C23; Tue, 10 Dec 2019 07:31:15 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     anna.schumaker@netapp.com, trond.myklebust@hammerspace.com
Cc:     dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: [PATCH v6 11/27] nfs: unexport nfs_fs_mount_common()
Date:   Tue, 10 Dec 2019 07:30:59 -0500
Message-Id: <20191210123115.1655-12-smayhew@redhat.com>
In-Reply-To: <20191210123115.1655-1-smayhew@redhat.com>
References: <20191210123115.1655-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-MC-Unique: k2ZS61UuOIieYAk1dsV5ag-1
X-Mimecast-Spam-Score: 0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Make it static, even.  And remove a stale extern of (long-gone)
nfs_xdev_mount_common() from internal.h, while we are at it.

Reviewed-by: David Howells <dhowells@redhat.com>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/nfs/internal.h | 3 ---
 fs/nfs/super.c    | 5 +++--
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index e338558b7908..310f81a149b2 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -396,10 +396,7 @@ bool nfs_auth_info_match(const struct nfs_auth_info *,=
 rpc_authflavor_t);
 struct dentry *nfs_try_mount(int, const char *, struct nfs_mount_info *);
 int nfs_set_sb_security(struct super_block *, struct dentry *, struct nfs_=
mount_info *);
 int nfs_clone_sb_security(struct super_block *, struct dentry *, struct nf=
s_mount_info *);
-struct dentry *nfs_fs_mount_common(int, const char *, struct nfs_mount_inf=
o *);
 struct dentry *nfs_fs_mount(struct file_system_type *, int, const char *, =
void *);
-struct dentry * nfs_xdev_mount_common(struct file_system_type *, int,
-=09=09const char *, struct nfs_mount_info *);
 void nfs_kill_super(struct super_block *);
 void nfs_fill_super(struct super_block *, struct nfs_mount_info *);
 void nfs_clone_super(struct super_block *, struct nfs_mount_info *);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 60845dc864e7..0bedac041272 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1893,6 +1893,8 @@ static struct nfs_server *nfs_try_mount_request(struc=
t nfs_mount_info *mount_inf
 =09return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
 }
=20
+static struct dentry *nfs_fs_mount_common(int, const char *, struct nfs_mo=
unt_info *);
+
 struct dentry *nfs_try_mount(int flags, const char *dev_name,
 =09=09=09     struct nfs_mount_info *mount_info)
 {
@@ -2648,7 +2650,7 @@ static void nfs_set_readahead(struct backing_dev_info=
 *bdi,
 =09bdi->io_pages =3D iomax_pages;
 }
=20
-struct dentry *nfs_fs_mount_common(int flags, const char *dev_name,
+static struct dentry *nfs_fs_mount_common(int flags, const char *dev_name,
 =09=09=09=09   struct nfs_mount_info *mount_info)
 {
 =09struct super_block *s;
@@ -2730,7 +2732,6 @@ struct dentry *nfs_fs_mount_common(int flags, const c=
har *dev_name,
 =09deactivate_locked_super(s);
 =09goto out;
 }
-EXPORT_SYMBOL_GPL(nfs_fs_mount_common);
=20
 struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 =09int flags, const char *dev_name, void *raw_data)
--=20
2.17.2

