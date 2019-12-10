Return-Path: <SRS0=N5nt=2A=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 534BDC43603
	for <linux-nfs@archiver.kernel.org>; Tue, 10 Dec 2019 12:33:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2897F214AF
	for <linux-nfs@archiver.kernel.org>; Tue, 10 Dec 2019 12:33:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="VTNBqBZE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727505AbfLJMdK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 10 Dec 2019 07:33:10 -0500
Received: from us-smtp-1.mimecast.com ([207.211.31.81]:37616 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1727448AbfLJMbX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Dec 2019 07:31:23 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1575981082;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=iTwtQMcDj/AiSV92e7jTz17J61UISJVqdTIBvCkXxaw=;
        b=VTNBqBZEvjYhgI5HMojBG6Kz32+RpsdUd5UE60rSwfXNtEexjrOGRFVIkYfIukvORdd64T
        bpyefOX1njiP6HUo7J7Y1JxN0NB/Oonqf6AbyghEoiRphczWiyxwBfgfd50Ig+e/vEbdaX
        dGc1u+GvZpdfXh2jiJlAw/ne1rcNsYM=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-425-pb7EhZwpOB-ESrGlEY7Lvg-1; Tue, 10 Dec 2019 07:31:18 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 36FCE2F29;
        Tue, 10 Dec 2019 12:31:17 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-123-90.rdu2.redhat.com [10.10.123.90])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 183585C219;
        Tue, 10 Dec 2019 12:31:17 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id D09C620C27; Tue, 10 Dec 2019 07:31:15 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     anna.schumaker@netapp.com, trond.myklebust@hammerspace.com
Cc:     dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: [PATCH v6 14/27] nfs_clone_sb_security(): simplify the check for server bogosity
Date:   Tue, 10 Dec 2019 07:31:02 -0500
Message-Id: <20191210123115.1655-15-smayhew@redhat.com>
In-Reply-To: <20191210123115.1655-1-smayhew@redhat.com>
References: <20191210123115.1655-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-MC-Unique: pb7EhZwpOB-ESrGlEY7Lvg-1
X-Mimecast-Spam-Score: 0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

We used to check ->i_op for being nfs_dir_inode_operations.  With
separate inode_operations for v3 and v4 that became bogus, but
rather than going for protocol-dependent comparison we could've
just checked ->i_fop instead; _that_ is the same for all protocol
versions.

Reviewed-by: David Howells <dhowells@redhat.com>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/nfs/super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2bcf0f8295e0..bec6c341f72c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2578,7 +2578,7 @@ int nfs_clone_sb_security(struct super_block *s, stru=
ct dentry *mntroot,
 =09unsigned long kflags =3D 0, kflags_out =3D 0;
=20
 =09/* clone any lsm security options from the parent to the new sb */
-=09if (d_inode(mntroot)->i_op !=3D NFS_SB(s)->nfs_client->rpc_ops->dir_ino=
de_ops)
+=09if (d_inode(mntroot)->i_fop !=3D &nfs_dir_operations)
 =09=09return -ESTALE;
=20
 =09if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL)
--=20
2.17.2

