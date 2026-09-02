Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F068F3A75B1;
	Wed,  2 Sep 2026 19:29:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788377374; cv=none; b=IMZzrJmldpxdB1Q3KaoFxhVvcVvWpFWqe00CdNW5fTnSZvYFWMJ9CMOuVnbpOfAg2my2E7LBSSFoV3bAwkeKa/+Tx7eODpeVPpxc1etDCBXb18We9yAlpMCYneMY2AyJKfdYGWf0lbmRgW6GA+0TPOJ2Z7WTFAznAp1npKR+6YE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788377374; c=relaxed/simple;
	bh=j/QSHRUfrO/KT+a3fsQHrV0wDYoDF5qm9xBGqxvYjUg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Cu6rTU3PjQ7N9hQxpSeaXfGTSxT0iLesi4E4noiD6JdS+EhhPihSc6g+oJPBtvGxL74QVc+LrdwJZ4rR6X7dho5Qer9U4dBpa/1cqPtZ1Bq5os7g+jkEIdsRd4S2OAbKCHkiKxlzLZsmS/5eWIFsFwj+Bzo0bsaI3rZwfRnIxCg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aqEkmehQ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aqEkmehQ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DD79F1F00A3F;
	Wed,  2 Sep 2026 19:29:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788377349;
	bh=2AhqExJ5ImvCkUoJzOUvUEsFmXKytKRmnDUDouDSiM8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=aqEkmehQNMAO7ivXKssNPNDy1QKMEYEAzi3pqKRrmrsRAQKGJscX8LgsOTlSLd/gW
	 X1ZsuG98zIrmYKvm+zRn3fu2JF/684PC8mc1xswDCdTSTzgbceU7OxpBYn+cp+B6gx
	 MRyo5gePyVD65t7vnK/0ciQXNJjnzast+n/Y4ROttsdlfQdHgyMqoAQQD0kvFaYPT5
	 sYDyRZulIGSzy1okMbD86xLBRBHdBySTbGK5Ml1MTeHNSbBY/Niu69aSx3vcTRIiYy
	 l7zf6wspT5bLONqeQ8CXdnYi6fFFdzDNNLCSH2yiCRsh+pFaiCc+/CaO36ryU/o3ds
	 x2du5Byc/97Xg==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 02 Sep 2026 15:28:50 -0400
Subject: [PATCH RFC v2 5/8] workqueue: add workqueue_set_affn_scope()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260902-performance-v2-5-b71c0c082f9d@kernel.org>
References: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
In-Reply-To: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3168; i=cel@kernel.org;
 h=from:subject:message-id; bh=j/QSHRUfrO/KT+a3fsQHrV0wDYoDF5qm9xBGqxvYjUg=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqmHkALBUtrjLkaUKNHiXr2tZCl+DvW3s9kcB1o
 mglhUSQ5wmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaph5AAAKCRAzarMzb2Z/
 l35qD/9SHPbQ6vTgb5vn1aIb0Ug9KgZH4MqWoWq4Pw44bFFFVZS3xztLsPrK9fmiyokSybt96Dj
 mygMlzXaN2YCDDzwwMUF5kpYeuW+QJA6HVAJvFL1KW6o0p7YuOJ4+hgXXJwGyyFiZLSoUE2NYr4
 3a5WikTyytsKBTNCrDKRdGLAA9a/M2qre880CjWMxo9DFrMr/EHZrTXlhJhiHFvYrm7Tfh2/qwv
 Nl7zJwxugaliKWod0ZykfXswiXT3CzHOBsHtZT88O4k2htNJIVM0/m87Q2brRcGsPQb4CYJQeDy
 +FfIv/ivBOvNNyAeqE5LAigrxmsmwyovknX5c7SV4qxskUTVRzvjPhUELVwi/coubOQVI4hPv75
 Bpw0vvPJjcZx6DQQnYusNhC+Z13fbdh6Ipvf0H0MD3WWMvxY7Ll8nzph7UuCriuSmeAF2wIPHUw
 +p/OvAbN7kHlykPH46alkZe1GocIx8Xjn/3zFBvaGRb7iSDqrq1X9LVvoGCs+hszOLPw5p+XvaY
 nj226XADf6bzsM7e0QF6l64hZk02iViCwp7Kvkzz4NlmqjM7moaLERiKTWhxWFwom0gPkF6Th7C
 DP3mokf4qSmHFWgfoVubUkw4Ig8+P4iI88PDu5g3OFkfSV5OwCan/2lGuk5KVr1gkpyvelI3RkD
 GWvoqiu9Rg69GeQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

An unbound workqueue's affinity scope can be changed only through
sysfs. A module whose workqueue contends on the pool lock at the
default scope has no in-kernel way to select a finer one, because
alloc_workqueue_attrs() and apply_workqueue_attrs() are not
exported. Exporting them would also invite a caller to apply freshly
allocated attributes, which resets the nice level, cpumask, and
strict affinity the workqueue already carries.

Add workqueue_set_affn_scope(), which copies the workqueue's current
attributes, replaces only the scope, and applies the result under
wq_pool_mutex, as the sysfs affinity_scope store does. Export it so
that SUNRPC and NFS can set the scope of their workqueues when they
create them.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/workqueue.h |  2 ++
 kernel/workqueue.c        | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+)

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index c8a36423cb34..585c32d8dc98 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -618,6 +618,8 @@ struct workqueue_attrs *alloc_workqueue_attrs_noprof(void);
 void free_workqueue_attrs(struct workqueue_attrs *attrs);
 int apply_workqueue_attrs(struct workqueue_struct *wq,
 			  const struct workqueue_attrs *attrs);
+int workqueue_set_affn_scope(struct workqueue_struct *wq,
+			     enum wq_affn_scope affn_scope);
 extern int workqueue_unbound_housekeeping_update(const struct cpumask *hk);
 
 extern bool queue_work_on(int cpu, struct workqueue_struct *wq,
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 3c034cbc5bb3..0c2b8e87cd59 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -5610,6 +5610,43 @@ int apply_workqueue_attrs(struct workqueue_struct *wq,
 	return ret;
 }
 
+/**
+ * workqueue_set_affn_scope - change the affinity scope of an unbound workqueue
+ * @wq: the target unbound workqueue
+ * @affn_scope: the new scope, or %WQ_AFFN_DFL for the system default
+ *
+ * Reapply @wq's current attributes with only the affinity scope
+ * replaced, so the nice level, cpumask, and strict affinity the
+ * workqueue already carries survive. Pool-workqueue replacement
+ * proceeds as for apply_workqueue_attrs().
+ *
+ * Context: Process context. Takes wq_pool_mutex and performs
+ * GFP_KERNEL allocations.
+ *
+ * Return: 0 on success and -errno on failure.
+ */
+int workqueue_set_affn_scope(struct workqueue_struct *wq,
+			     enum wq_affn_scope affn_scope)
+{
+	struct workqueue_attrs *attrs;
+	int ret = -ENOMEM;
+
+	if ((unsigned int)affn_scope >= WQ_AFFN_NR_TYPES)
+		return -EINVAL;
+
+	mutex_lock(&wq_pool_mutex);
+	attrs = alloc_workqueue_attrs();
+	if (attrs) {
+		copy_workqueue_attrs(attrs, wq->attrs);
+		attrs->affn_scope = affn_scope;
+		ret = apply_workqueue_attrs_locked(wq, attrs);
+	}
+	mutex_unlock(&wq_pool_mutex);
+	free_workqueue_attrs(attrs);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(workqueue_set_affn_scope);
+
 /**
  * unbound_wq_update_pwq - update a pwq slot for CPU hot[un]plug
  * @wq: the target workqueue

-- 
2.55.0

