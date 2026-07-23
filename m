Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3EDEE307AF4
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 14:01:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784815285; cv=none; b=YxCB0UJ5FcUC192n0ptbgewgE+Stf6DswZ+N0G0TZc5OdRuze+BUufQP71lc4mNxsclD6f5oJTR5rTgP6TpyZQmNy1P/b+0sGweV9lEe6XHSWGdBq+ECDqIJqU/cfkPEKILPQP3GUYqJDWpRXtkdfyC9ICesmFCirVPH1yY/Ja0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784815285; c=relaxed/simple;
	bh=iYLny04njctp7RgfAssuJrvBt8I7jhukvGOyqFk4rnU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=axCdqBr8Rk2X2LepCBAKjFjQRBfgQe5PKPj7mSbqWsY3T5xI/pZlto+g86pXJCLRo44l5T4wPQ2pM5PMSrh1yZ/KR2ngwVaS18NJiFqtDOOM80KJIUBAdZN/MrGX5lf+iwBDpz/Td8uK16BAzc1YfNxCmUY19KbjVyt9SelcbQ4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=YzNnojdx; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="YzNnojdx"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1784815283;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=lIFtl054eZnchKyoFYLOJTrZAAEw6mvK7wz7Es5Uyrk=;
	b=YzNnojdxZHIEQkXcUn+bknaXd+lHzCt2OaBeAyC5ExFK89jhrxzR9RTehQrK2xP4FOwfQL
	ZcLaZ1VHXinQiolPPu2eflsf1wTmIlwRJuY2yMyY90d0Qj3J9jb4hGt+dMZjM1L0yz+g2f
	pwzmDC4z4in7+lFGQl+V0SxZyvdODhk=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-549-y9FNiQxAP-aXeAPBiDA_zg-1; Thu,
 23 Jul 2026 10:01:16 -0400
X-MC-Unique: y9FNiQxAP-aXeAPBiDA_zg-1
X-Mimecast-MFC-AGG-ID: y9FNiQxAP-aXeAPBiDA_zg_1784815270
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 6BACF1977649;
	Thu, 23 Jul 2026 14:01:09 +0000 (UTC)
Received: from warthog.procyon.org.com (unknown [10.44.33.159])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 90BD41956053;
	Thu, 23 Jul 2026 14:01:04 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <christian@brauner.io>
Cc: David Howells <dhowells@redhat.com>,
	Marc Dionne <marc.dionne@auristor.com>,
	Jeffrey Altman <jaltman@auristor.com>,
	Steve French <sfrench@samba.org>,
	linux-afs@lists.infradead.org,
	openafs-devel@openafs.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Etienne Champetier <champetier.etienne@gmail.com>,
	Chet Ramey <chet.ramey@case.edu>,
	Cheyenne Wills <cwills@sinenomine.net>,
	Christian Brauner <brauner@kernel.org>
Subject: [PATCH v2 2/2] afs, bash: Fix open(O_CREAT) on an extant AFS file in a sticky dir
Date: Thu, 23 Jul 2026 15:00:45 +0100
Message-ID: <20260723140047.702495-3-dhowells@redhat.com>
In-Reply-To: <20260723140047.702495-1-dhowells@redhat.com>
References: <20260723140047.702495-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

Since version 1.11 (January 1992) Bash has a work around in redir_open()
that causes open(O_CREAT) of a file to be retried without O_CREAT if open()
fails with an EACCES error if bash was built with AFS workarounds
configured:

        #if defined (AFS)
              if ((fd < 0) && (errno == EACCES))
            {
              fd = open (filename, flags & ~O_CREAT, mode);
              errno = EACCES;    /* restore errno */
            }

        #endif /* AFS */

The ~O_CREAT fallback logic was introduced to workaround a bug[1] in the
IBM AFS 3.1 cache manager and server which can return EACCES in preference
to EEXIST if the requested file exists but the caller is neither granted
explicit PRSFS_READ permission nor is the file owner and is granted
PRSFS_INSERT permission on the directory.  IBM AFS 3.2 altered the cache
manager permission checks but failed to correct the permission checks in
the AFS server.  As of this writing, all IBM AFS derived servers continue
to return EACCES in preference to EEXIST when these conditions are met.
Bug reports have been filed with all implementations.

As an unintended side effect, the Bash fallback logic also undermines the
Linux kernel protections against O_CREAT opening FIFOs and regular files
not owned by the user in world writeable sticky directories - unless the
owner is the same as that of the directory - as was added in commit
30aba6656f61e ("namei: allow restricted O_CREAT of FIFOs and regular
files").

As a result the Bash fallback logic masks an incompatibility between the
ownership checks performed by may_create_in_sticky() and network
filesystems such as AFS where the uid namespace is disjoint from the uid
namespace of the local system.

However, the bash work around is going to be removed[2].

Fix this in the kernel by using a preceding patch that allows the user ID
comparisons to be overridden by:

 (1) Implement the ->is_owned_by_me() inode op for kafs to determine if the
     caller owns the file by checking to see if the server indicated the
     ADMINISTER bit was set in the access rights returned by the
     FS.FetchStatus and suchlike instead of checking the i_uid to
     current_fsuid().

     Unfortunately, this check doesn't work for directories, but none of
     the ops should require that.

     Note that anonymous accesses to AFS will never see the ADMINISTER bit
     being set and so will not be perceived as owning an anonymously-owned
     file.

 (2) Implement the ->have_same_owner() inode op, for kafs to compare the
     AFS owner IDs retrieved by FS.FetchStatus (which are 64-bit integers
     with AuriStor's YFS server and, as such, won't fit in a kuid_t).

     Note that whilst an anonymously-owned file will match an
     anonymously-owned parent directory, an anonymously-owned directory
     cannot have the sticky bit set.

This can be tested by creating a sticky directory (the user must have a
token to do this) and creating a file in it.  Then strace bash doing "echo
foo >>file" and look at whether bash does a single, successful O_CREAT open
on the file or whether that one fails and then bash does one without
O_CREAT that succeeds.

Fixes: 30aba6656f61 ("namei: allow restricted O_CREAT of FIFOs and regular files")
Reported-by: Etienne Champetier <champetier.etienne@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
cc: Marc Dionne <marc.dionne@auristor.com>
cc: Jeffrey Altman <jaltman@auristor.com>
cc: Chet Ramey <chet.ramey@case.edu>
cc: Cheyenne Wills <cwills@sinenomine.net>
cc: Alexander Viro <viro@zeniv.linux.org.uk>
cc: Christian Brauner <brauner@kernel.org>
cc: Steve French <sfrench@samba.org>
cc: linux-afs@lists.infradead.org
cc: openafs-devel@openafs.org
cc: linux-cifs@vger.kernel.org
cc: linux-fsdevel@vger.kernel.org
Link: https://groups.google.com/g/gnu.bash.bug/c/6PPTfOgFdL4/m/2AQU-S1N76UJ [1]
Link: https://git.savannah.gnu.org/cgit/bash.git/tree/redir.c?h=bash-5.3-rc1#n733 [2]
---
 fs/afs/dir.c      |  2 ++
 fs/afs/file.c     |  2 ++
 fs/afs/inode.c    |  1 +
 fs/afs/internal.h |  3 +++
 fs/afs/security.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 54 insertions(+)

diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index 6df56fe9163f..ee2f5ec0b2c6 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -69,6 +69,8 @@ const struct inode_operations afs_dir_inode_operations = {
 	.permission	= afs_permission,
 	.getattr	= afs_getattr,
 	.setattr	= afs_setattr,
+	.is_owned_by_me	= afs_is_owned_by_me,
+	.have_same_owner = afs_have_same_owner,
 };
 
 const struct address_space_operations afs_dir_aops = {
diff --git a/fs/afs/file.c b/fs/afs/file.c
index 0467742bfeee..ba44493ccaf6 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -49,6 +49,8 @@ const struct inode_operations afs_file_inode_operations = {
 	.getattr	= afs_getattr,
 	.setattr	= afs_setattr,
 	.permission	= afs_permission,
+	.is_owned_by_me	= afs_is_owned_by_me,
+	.have_same_owner = afs_have_same_owner,
 };
 
 const struct address_space_operations afs_file_aops = {
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 14f39a9bea6c..af85a88d943d 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -91,6 +91,7 @@ static int afs_inode_init_from_status(struct afs_operation *op,
 	inode->i_flags |= S_NOATIME;
 	inode->i_uid = make_kuid(&init_user_ns, status->owner);
 	inode->i_gid = make_kgid(&init_user_ns, status->group);
+	inode->i_opflags |= IOP_OWNERSHIP_OVERRIDE;
 	set_nlink(&vnode->netfs.inode, status->nlink);
 
 	i_size_write(inode, status->size);
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 601f01e5c15f..e10cf7636f65 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -1530,6 +1530,9 @@ extern struct key *afs_request_key(struct afs_cell *);
 extern struct key *afs_request_key_rcu(struct afs_cell *);
 extern int afs_check_permit(struct afs_vnode *, struct key *, afs_access_t *);
 extern int afs_permission(struct mnt_idmap *, struct inode *, int);
+int afs_is_owned_by_me(struct mnt_idmap *idmap, struct inode *inode);
+int afs_have_same_owner(struct mnt_idmap *idmap, struct inode *inode1,
+			struct inode *inode2);
 extern void __exit afs_clean_up_permit_cache(void);
 
 /*
diff --git a/fs/afs/security.c b/fs/afs/security.c
index 6d00d62a65ed..7092f5acdcd6 100644
--- a/fs/afs/security.c
+++ b/fs/afs/security.c
@@ -510,6 +510,52 @@ int afs_permission(struct mnt_idmap *idmap, struct inode *inode,
 	return ret;
 }
 
+/*
+ * Determine if an inode is owned by 'me' - whatever that means for the
+ * filesystem.  In the case of AFS, this means that the file is owned by the
+ * AFS user represented by the Rx Security Class token held in a key.  Returns
+ * 0 if owned by me, 1 if not; can also return an error.
+ */
+int afs_is_owned_by_me(struct mnt_idmap *idmap, struct inode *inode)
+{
+	struct afs_vnode *vnode = AFS_FS_I(inode);
+	afs_access_t access;
+	struct key *key;
+	int ret;
+
+	if (S_ISDIR(inode->i_mode))
+		return 1; /* The ADMIN right check doesn't work for directories. */
+
+	key = afs_request_key(vnode->volume->cell);
+	if (IS_ERR(key))
+		return PTR_ERR(key);
+
+	/* Get the access rights for the key on this file. */
+	ret = afs_check_permit(vnode, key, &access);
+	if (ret < 0)
+		goto error;
+
+	/* We get the ADMINISTER bit if we own the file. */
+	ret = (access & AFS_ACE_ADMINISTER) ? 0 : 1;
+error:
+	key_put(key);
+	return ret;
+}
+
+/*
+ * Determine if a file has the same owner as its parent - whatever that means
+ * for the filesystem.  In the case of AFS, this means comparing their AFS
+ * UIDs.  Returns 0 if same, 1 if not same; can also return an error.
+ */
+int afs_have_same_owner(struct mnt_idmap *idmap, struct inode *inode1,
+			struct inode *inode2)
+{
+	const struct afs_vnode *vnode1 = AFS_FS_I(inode1);
+	const struct afs_vnode *vnode2 = AFS_FS_I(inode2);
+
+	return vnode1->status.owner != vnode2->status.owner;
+}
+
 void __exit afs_clean_up_permit_cache(void)
 {
 	int i;

