Received: from eu-smtp-delivery-195.mimecast.com (eu-smtp-delivery-195.mimecast.com [185.58.86.195])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9682E3E51F5
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 14:48:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.58.86.195
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791816494; cv=none; b=AgmibYNV/QNVDkGeN709clViYQDmdQk42sepCL037kVytfM2ehi4Eo3iILtnYd1Ib7t17lsMf1PMiI+5ECaLmH3ZeUGXsEnDYF36s2e3w7NGUKm72b18y00C1+KNrFAukINGEqMS5tiJSLa0WjFpYBf7luMpDu8isu3CcKANb5g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791816494; c=relaxed/simple;
	bh=67FnptXVfLhYHgKInxUI9NWGFi7BxQzUQJy/d6ZjW20=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=sszTVqy1pD9a1c6GoF+uZm/gC+iF0qZ4jjNbmPYbfK8qzHBl/QUFfavRAwVLNFQ5D8w0USTSD0LiZr6bfz1fbJoYF+SmCaKidh+I4acOvYmWaHp5cJOgu5SuuzanOxnXP6x9etmoKsL2VBpnjA4Rgue4NhnymbzReRPT9tdGkXY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com; spf=pass smtp.mailfrom=gsacapital.com; dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b=MVyL1zqU; arc=none smtp.client-ip=185.58.86.195
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b="MVyL1zqU"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gsacapital.com;
	s=mimecast20170115; t=1791816484;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=t5OD8mzP8NNTzfgF7qjbG+ibVyIxOYz8He20qNd1qIU=;
	b=MVyL1zqUXaE5ndDphNMc2xPrwEtX4p7z4cxWv5oLVvCnkJCAxbqDIAN6yALTa3WphjpPMw
	s4E3amwVM9wWE4tVB7trfi8RNcXRbvT6DCsLpIgg7WXlDNGQsr2tvLiWEi0JnZOuzRg5Z8
	Gmhzv7rp52tWp25uIDo8QeCpbvROEio=
Received: from mailrelay.gsacapital.com (185.137.2.10 [185.137.2.10]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id uk-mta-65-RYGA9m2YNc2MTDi2mLBi0g-1; Mon,
 12 Oct 2026 14:48:02 +0000
X-MC-Unique: RYGA9m2YNc2MTDi2mLBi0g-1
X-Mimecast-MFC-AGG-ID: RYGA9m2YNc2MTDi2mLBi0g_1791816481
From: Rushil Patel <rushil.patel@gsacapital.com>
To: Anna Schumaker <anna@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>,
	Jorge Mora <Jorge.Mora@netapp.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Scott Mayhew <smayhew@redhat.com>,
	Benjamin Coddington <ben.coddington@hammerspace.com>,
	Tim Saunders <tim.saunders@gsacapital.com>,
	Mark Brading <mark.brading@gsacapital.com>,
	Ben Roberts <ben.roberts@gsacapital.com>,
	linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Subject: [RFC PATCH v2 2/3] NFS: make fsync's writeback wait killable
Date: Mon, 12 Oct 2026 15:47:52 +0100
Message-ID: <20261012144753.3400341-3-rushil.patel@gsacapital.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261012144753.3400341-1-rushil.patel@gsacapital.com>
References: <d39afd89-0543-410c-8c3a-c8869ba643bb@app.fastmail.com>
 <20261012144753.3400341-1-rushil.patel@gsacapital.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: -U9tHs8NSkmZPbyWh8ckK9AYqKmvh1oTLb_G-hlPojQ_1791816481
X-Mimecast-Originator: gsacapital.com
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

If the server stops responding, a task in fsync() sits in
__filemap_fdatawait_range() -> folio_wait_writeback(), which is
TASK_UNINTERRUPTIBLE, so SIGKILL can't get it out. On a hard mount the
only way to recover is to reboot the client.

Do the wait in NFS with folio_wait_writeback_killable() instead. Only the
wait for writeback to complete becomes killable. Submission is unchanged
and can still block. When the wait is interrupted, fsync returns -EINTR
without advancing the file's writeback error cursor, so any error is still
reported to a later caller. Writeback itself carries on in the background.

The wait loop is a copy of __filemap_fdatawait_range() built from existing
exports, so mm doesn't need to change. The interruption is reported
separately from the submission error so that an -EINTR from submission
(e.g. a pNFS layout wait for an exiting task) is handled exactly as before.

Signed-off-by: Rushil Patel <rushil.patel@gsacapital.com>
---
 fs/nfs/file.c     |  2 +-
 fs/nfs/internal.h |  2 ++
 fs/nfs/write.c    | 64 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 67 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index e1bdd10b35f1..ce160051b0c6 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -270,7 +270,7 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t =
end, int datasync)
 =09trace_nfs_fsync_enter(inode);
=20
 =09for (;;) {
-=09=09ret =3D file_write_and_wait_range(file, start, end);
+=09=09ret =3D nfs_file_write_and_wait_range(file, start, end);
 =09=09if (ret !=3D 0)
 =09=09=09break;
 =09=09ret =3D nfs_file_fsync_commit(file, datasync);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index abc81f5ae578..c7bb7133afa5 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -592,6 +592,8 @@ int  nfs_show_stats(struct seq_file *, struct dentry *)=
;
 int  nfs_reconfigure(struct fs_context *);
=20
 /* write.c */
+extern int nfs_file_write_and_wait_range(struct file *file, loff_t start,
+=09=09=09=09=09 loff_t end);
 extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 =09=09=09struct inode *inode, int ioflags, bool force_mds,
 =09=09=09const struct nfs_pgio_completion_ops *compl_ops);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 623e7ef1f73d..c5a911305da7 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1985,6 +1985,70 @@ int nfs_filemap_write_and_wait_range(struct address_=
space *mapping,
 }
 EXPORT_SYMBOL_GPL(nfs_filemap_write_and_wait_range);
=20
+/*
+ * Like filemap_write_and_wait_range(), but a fatal signal interrupts the =
wait
+ * for writeback to complete, and errors are left for the caller to collec=
t.
+ * Starting writeback can still block.  *@interrupted tells an interrupted
+ * wait apart from an error returned by writeback itself.
+ */
+static int nfs_write_and_wait_range_killable(struct address_space *mapping=
,
+=09=09=09=09=09     loff_t start, loff_t end,
+=09=09=09=09=09     bool *interrupted)
+{
+=09pgoff_t index =3D start >> PAGE_SHIFT;
+=09pgoff_t last =3D end >> PAGE_SHIFT;
+=09struct folio_batch fbatch;
+=09unsigned int i, nr;
+=09int err;
+
+=09*interrupted =3D false;
+=09if (!mapping->nrpages)
+=09=09return 0;
+=09err =3D filemap_fdatawrite_range(mapping, start, end);
+=09if (err =3D=3D -EIO)
+=09=09return err;
+=09folio_batch_init(&fbatch);
+=09while (index <=3D last &&
+=09       (nr =3D filemap_get_folios_tag(mapping, &index, last,
+=09=09=09=09=09    PAGECACHE_TAG_WRITEBACK, &fbatch))) {
+=09=09for (i =3D 0; i < nr; i++) {
+=09=09=09if (folio_wait_writeback_killable(fbatch.folios[i])) {
+=09=09=09=09folio_batch_release(&fbatch);
+=09=09=09=09*interrupted =3D true;
+=09=09=09=09return -EINTR;
+=09=09=09}
+=09=09}
+=09=09folio_batch_release(&fbatch);
+=09=09cond_resched();
+=09}
+=09return err;
+}
+
+/**
+ * nfs_file_write_and_wait_range - killable file_write_and_wait_range()
+ * @file: file to write back
+ * @start: first byte of the range
+ * @end: last byte of the range (inclusive)
+ *
+ * Return: 0 on success, -EINTR if a fatal signal interrupted the wait, in
+ * which case the file's writeback error cursor is not advanced, or anothe=
r
+ * negative error code.
+ */
+int nfs_file_write_and_wait_range(struct file *file, loff_t start, loff_t =
end)
+{
+=09bool interrupted;
+=09int err, err2;
+
+=09if (end < start)
+=09=09return 0;
+=09err =3D nfs_write_and_wait_range_killable(file->f_mapping, start, end,
+=09=09=09=09=09=09&interrupted);
+=09if (interrupted)
+=09=09return err;
+=09err2 =3D file_check_and_advance_wb_err(file);
+=09return err ? err : err2;
+}
+
 /*
  * flush the inode to disk.
  */
--=20
2.47.3

For details of how GSA uses your personal information, please see our Priva=
cy Notice here: https://www.gsacapital.com/privacy-notice=20

This email and any files transmitted with it contain confidential and propr=
ietary information and is solely for the use of the intended recipient.
If you are not the intended recipient please return the email to the sender=
 and delete it from your computer and you must not use, disclose, distribut=
e, copy, print or rely on this email or its contents.
This communication is for informational purposes only.
It is not intended as an offer or solicitation for the purchase or sale of =
any financial instrument or as an official confirmation of any transaction.
Any comments or statements made herein do not necessarily reflect those of =
GSA Capital.
GSA Capital Partners LLP is authorised and regulated by the Financial Condu=
ct Authority and is registered in England and Wales at Stratton House, 5 St=
ratton Street, London W1J 8LA, number OC309261.
GSA Capital Services Limited is registered in England and Wales at the same=
 address, number 5320529.

