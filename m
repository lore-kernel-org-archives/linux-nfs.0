Received: from eu-smtp-delivery-195.mimecast.com (eu-smtp-delivery-195.mimecast.com [185.58.86.195])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 969BD489FD7
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 14:48:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.58.86.195
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791816494; cv=none; b=UNx8HO0ie7O+5jY9NcnEdGGS0tSMAmvIKLM3XHD+GVrvIjA9Opra8odf0fRd16WLwt+uISE5CcaZ0fkOh8RSftCp8+xNSR+My/ZN+dvGu5awRwdWjzREpH638Cj7PZ+7BL8oNiHGWPUlVie2qzrRKfbQ1LZVqy7aiu0xQNuEsXc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791816494; c=relaxed/simple;
	bh=BGxiCWJ9Q45isuatJYhQbyCsj7iYCgDKlmS7UqxxOh4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=fV2Yj71QgmyBKqOc9Qai/BL11XU4yY1x//WrZ8sCu8TYS6zYTl843X88YoX/0UByJ6NsvDSGq1WOZsFb3DZPDCWjM0UQ7hnhqNdyeeVWYHjez2jct5LPPsXGPgGzy4FQUR+M2CEdVa5MOzyn2wabx/DuhphDLDu5zvS05TwtAPo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com; spf=pass smtp.mailfrom=gsacapital.com; dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b=ZZz+lSXA; arc=none smtp.client-ip=185.58.86.195
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b="ZZz+lSXA"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gsacapital.com;
	s=mimecast20170115; t=1791816484;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=BplKtSgbg/sM5sJqfkWubbrcMLeK6QqzS/Nu4h2mje8=;
	b=ZZz+lSXAuYuE8oOulJm1Jc6VNDtSYLw2Vgg7gaWR3GG6FnFaizjs0eIWZ/+d/WuSiDQinf
	wY78/Nq9YbFz8mCXy5hITAeE2v2S4NjWhkFMu2dw3nObw2fVf4nUA8TAPKc668o842fmlq
	lRMC/mv8eS6MbprLzzfutf7oPw/A1dc=
Received: from mailrelay.gsacapital.com (185.137.2.10 [185.137.2.10]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id uk-mta-65-t3QSa_hbNq-FzWQhngc6bg-1; Mon,
 12 Oct 2026 14:48:02 +0000
X-MC-Unique: t3QSa_hbNq-FzWQhngc6bg-1
X-Mimecast-MFC-AGG-ID: t3QSa_hbNq-FzWQhngc6bg_1791816482
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
Subject: [RFC PATCH v2 3/3] NFS: don't wait for the server when a killed task closes a file
Date: Mon, 12 Oct 2026 15:47:53 +0100
Message-ID: <20261012144753.3400341-4-rushil.patel@gsacapital.com>
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
X-Mimecast-MFC-PROC-ID: x3ZHMPC334qOnkCtP7-upNTavGOx7rWkn3FlAEHLVEw_1791816482
X-Mimecast-Originator: gsacapital.com
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

Once a task has been killed it can't be signalled again, so if it closes a
file on an unresponsive server it hangs in D state. This can happen in
do_exit() -> filp_flush() -> ->flush() -> nfs_wb_all(), or in the final
NFSv4 CLOSE when nothing is dirty. The same happens if the kill arrives
while close() is already waiting in nfs_wb_all().

Only do this when the thread group is being killed by a signal, i.e. when
waitpid() will report WIFSIGNALED. A normal exit() or exit_group() keeps
the synchronous flush and close-to-open, even though exit_group() sends
SIGKILL to the other threads. So does a handled SIGTERM followed by exit().
Checking PF_EXITING alone would change every normal exit. Checking SIGKILL
alone would miss an unhandled SIGTERM, which starts the group exit
immediately, after which any later SIGKILL is dropped.

For a killed task:

 - ->flush returns without waiting, and asks the flusher threads to write
   back the data and send the COMMIT if anything is dirty or waiting to be
   committed. This is best effort and gives no per-inode guarantee.
 - ->flush uses a killable wait. If the wait is interrupted and the group
   was really killed, it does the same as above. Otherwise, e.g. an
   exit_group(0) sibling or an exec, it falls back to the normal wait.
 - the final open context put is asynchronous, so the CLOSE doesn't block
   the task. Dirty and commit requests hold a reference to the open
   context, so the CLOSE still can't go out before their WRITE or COMMIT.

The killed writer loses close-to-open for data that hadn't reached the
server yet. Other clients may see it a little after the task is reaped
rather than before.

Exit-time lock cleanup (do_unlk() -> nfs_wb_all()) still waits and isn't
changed here.

Signed-off-by: Rushil Patel <rushil.patel@gsacapital.com>
---
 fs/nfs/file.c     |  6 ++++-
 fs/nfs/inode.c    |  6 ++++-
 fs/nfs/internal.h | 38 ++++++++++++++++++++++++++
 fs/nfs/nfs4file.c |  6 ++++-
 fs/nfs/write.c    | 69 ++++++++++++++++++++++++++++++++++++++++++++---
 5 files changed, 118 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index ce160051b0c6..db495721e8fe 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -151,10 +151,14 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 =09nfs_inc_stats(inode, NFSIOS_VFSFLUSH);
 =09if ((file->f_mode & FMODE_WRITE) =3D=3D 0)
 =09=09return 0;
+=09if (nfs_current_task_killed()) {
+=09=09nfs_flush_killed(inode);
+=09=09return 0;
+=09}
=20
 =09/* Flush writes to the server and return any errors */
 =09since =3D filemap_sample_wb_err(file->f_mapping);
-=09nfs_wb_all(inode);
+=09nfs_wb_all_close(inode);
 =09return filemap_check_wb_err(file->f_mapping, since);
 }
=20
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3022454f7698..a9ab7e02c4ae 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1332,7 +1332,11 @@ void nfs_file_clear_open_context(struct file *filp)
 =09=09if (ctx->error < 0)
 =09=09=09invalidate_inode_pages2(inode->i_mapping);
 =09=09filp->private_data =3D NULL;
-=09=09put_nfs_open_context_sync(ctx);
+=09=09/* A killed task must not wait for the CLOSE */
+=09=09if (nfs_current_task_killed())
+=09=09=09put_nfs_open_context(ctx);
+=09=09else
+=09=09=09put_nfs_open_context_sync(ctx);
 =09}
 }
=20
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c7bb7133afa5..f72abedc4bbc 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -592,6 +592,8 @@ int  nfs_show_stats(struct seq_file *, struct dentry *)=
;
 int  nfs_reconfigure(struct fs_context *);
=20
 /* write.c */
+extern void nfs_flush_killed(struct inode *inode);
+extern int nfs_wb_all_close(struct inode *inode);
 extern int nfs_file_write_and_wait_range(struct file *file, loff_t start,
 =09=09=09=09=09 loff_t end);
 extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
@@ -937,6 +939,42 @@ static inline bool nfs_current_task_exiting(void)
 =09return (current->flags & PF_EXITING) !=3D 0;
 }
=20
+/*
+ * Is the current thread group being killed by a signal, i.e. will waitpid=
()
+ * report WIFSIGNALED?  An ordinary exit() or exit_group() records a statu=
s
+ * with the low seven bits clear, even though exit_group() sends SIGKILL t=
o
+ * the other threads.  Read the group exit flag and status under siglock.
+ * Kernel threads exit with arbitrary codes.
+ */
+static inline bool nfs_current_group_killed(void)
+{
+=09struct task_struct *tsk =3D current;
+=09const struct signal_struct *sig =3D tsk->signal;
+=09bool killed;
+
+=09if (tsk->flags & PF_KTHREAD)
+=09=09return false;
+=09spin_lock_irq(&tsk->sighand->siglock);
+=09killed =3D (sig->flags & SIGNAL_GROUP_EXIT) &&
+=09=09 (sig->group_exit_code & 0x7f);
+=09spin_unlock_irq(&tsk->sighand->siglock);
+=09return killed;
+}
+
+/*
+ * Is the current task dying because its thread group was killed?  It eith=
er
+ * still has the SIGKILL pending, e.g. while close(2) finishes, or is exit=
ing
+ * and can no longer be signalled.  Either way it must not wait for the
+ * server when it closes files.  A thread writing a core dump has neither,
+ * unless the dump is aborted with SIGKILL.
+ */
+static inline bool nfs_current_task_killed(void)
+{
+=09if (!(current->flags & PF_EXITING) && !fatal_signal_pending(current))
+=09=09return false;
+=09return nfs_current_group_killed();
+}
+
 static inline bool nfs_error_is_fatal(int err)
 {
 =09switch (err) {
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 6401f6363f75..7738c4c3915b 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -120,6 +120,10 @@ nfs4_file_flush(struct file *file, fl_owner_t id)
 =09nfs_inc_stats(inode, NFSIOS_VFSFLUSH);
 =09if ((file->f_mode & FMODE_WRITE) =3D=3D 0)
 =09=09return 0;
+=09if (nfs_current_task_killed()) {
+=09=09nfs_flush_killed(inode);
+=09=09return 0;
+=09}
=20
 =09/*
 =09 * If we're holding a write delegation, then check if we're required
@@ -130,7 +134,7 @@ nfs4_file_flush(struct file *file, fl_owner_t id)
=20
 =09/* Flush writes to the server and return any errors */
 =09since =3D filemap_sample_wb_err(file->f_mapping);
-=09nfs_wb_all(inode);
+=09nfs_wb_all_close(inode);
 =09return filemap_check_wb_err(file->f_mapping, since);
 }
=20
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c5a911305da7..980c3a74aa80 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1985,6 +1985,24 @@ int nfs_filemap_write_and_wait_range(struct address_=
space *mapping,
 }
 EXPORT_SYMBOL_GPL(nfs_filemap_write_and_wait_range);
=20
+/**
+ * nfs_flush_killed - flush on close for a task killed by a signal
+ * @inode: inode being closed
+ *
+ * A task that has been killed must not wait for the server.  Ask the flus=
her
+ * threads to write back the dirty data and commit unstable writes instead=
,
+ * without waiting.  This covers the whole superblock and is best effort: =
the
+ * request coalesces with a pass that is already running, and gives no
+ * guarantee about when this inode's data reaches the server.
+ */
+void nfs_flush_killed(struct inode *inode)
+{
+=09if (mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY) ||
+=09    atomic_long_read(&NFS_I(inode)->commit_info.ncommit))
+=09=09wakeup_flusher_threads_bdi(inode_to_bdi(inode), WB_REASON_SYNC);
+}
+EXPORT_SYMBOL_GPL(nfs_flush_killed);
+
 /*
  * Like filemap_write_and_wait_range(), but a fatal signal interrupts the =
wait
  * for writeback to complete, and errors are left for the caller to collec=
t.
@@ -2050,15 +2068,27 @@ int nfs_file_write_and_wait_range(struct file *file=
, loff_t start, loff_t end)
 }
=20
 /*
- * flush the inode to disk.
+ * If @interrupted is non-NULL, a fatal signal interrupts the wait for
+ * writeback, and *@interrupted is set if it did.
  */
-int nfs_wb_all(struct inode *inode)
+static int __nfs_wb_all(struct inode *inode, bool *interrupted)
 {
-=09int ret;
+=09struct address_space *mapping =3D inode->i_mapping;
+=09int ret, err;
=20
 =09trace_nfs_writeback_inode_enter(inode);
=20
-=09ret =3D filemap_write_and_wait(inode->i_mapping);
+=09if (interrupted) {
+=09=09ret =3D nfs_write_and_wait_range_killable(mapping, 0, LLONG_MAX,
+=09=09=09=09=09=09=09interrupted);
+=09=09if (*interrupted)
+=09=09=09goto out;
+=09=09err =3D filemap_check_errors(mapping);
+=09=09if (!ret)
+=09=09=09ret =3D err;
+=09} else {
+=09=09ret =3D filemap_write_and_wait(mapping);
+=09}
 =09if (ret)
 =09=09goto out;
 =09ret =3D nfs_commit_inode(inode, FLUSH_SYNC);
@@ -2071,8 +2101,39 @@ int nfs_wb_all(struct inode *inode)
 =09trace_nfs_writeback_inode_exit(inode, ret);
 =09return ret;
 }
+
+/*
+ * flush the inode to disk.
+ */
+int nfs_wb_all(struct inode *inode)
+{
+=09return __nfs_wb_all(inode, NULL);
+}
 EXPORT_SYMBOL_GPL(nfs_wb_all);
=20
+/**
+ * nfs_wb_all_close - flush the inode to disk on close
+ * @inode: inode being closed
+ *
+ * Like nfs_wb_all(), but a fatal signal interrupts the wait for writeback=
.
+ * If the signal is killing the thread group, the data is left to the flus=
her
+ * threads.  An exit_group() by another thread also sends SIGKILL; that wa=
its
+ * as before.
+ */
+int nfs_wb_all_close(struct inode *inode)
+{
+=09bool interrupted;
+=09int ret =3D __nfs_wb_all(inode, &interrupted);
+
+=09if (!interrupted)
+=09=09return ret;
+=09if (!nfs_current_group_killed())
+=09=09return nfs_wb_all(inode);
+=09nfs_flush_killed(inode);
+=09return 0;
+}
+EXPORT_SYMBOL_GPL(nfs_wb_all_close);
+
 int nfs_wb_folio_cancel(struct inode *inode, struct folio *folio)
 {
 =09struct nfs_page *req;
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

