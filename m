Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41DA5364924
	for <linux-nfs@vger.kernel.org>; Wed,  8 Apr 2026 19:00:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775674820; cv=none; b=q5+HqXGFIYg6ZNv+U483CYImc6V39clMrUAZH02eSYrOhoicAcZn+yzDucDT0N3H3wCtcvb6T+ic5ub3eLczxMBzfu8gzlG316usbtYnjzmEiYj58zNC+okNayUANXE/pRr2vWoMgxyFYtpSLQHI9bePGw1Ov/cBgchCdr0Ci9c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775674820; c=relaxed/simple;
	bh=bd88yO6CNkRaaS+1Ojp+USUExPVzI68DmI6pYYRdd6g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TBJPpINhgZSske9/eG7GfxJifNlOBUYTwesAFEZ/6iojk6dqcb8s0PxJgj/WVgs5yfDszLxHoWvqixdG1pq9mul5otdyB3Mo1RFuxzMzip4Bng5ZlKo1yvQdvHLMJWukmOBPi/BOJnxC+K1/6kAslfYgpKWPNMeMQbZjFlr3YAk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=fyDYiTP6; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="fyDYiTP6"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1775674818;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=G7cLuTkblEe00h2YDY+UxJUcELSu2+p8++AObznoE3Y=;
	b=fyDYiTP6UWYpBU/s57XQnn3ZbDBlVHWOpmNdPNxHuFn/kqOPJobb/gMQ7KOy/LBjek4xWX
	ZD0L53k++G7F3mg4NdrPJVMUOLjpj0n8PhJdAWPVG8e21kPiEjOqvHRsL74I92azKv+Wn0
	prIoieOL6HWB4yV862hE+uavEAjXaLs=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-295-dyfT-VPSOv-qJfJUrgstEQ-1; Wed,
 08 Apr 2026 15:00:14 -0400
X-MC-Unique: dyfT-VPSOv-qJfJUrgstEQ-1
X-Mimecast-MFC-AGG-ID: dyfT-VPSOv-qJfJUrgstEQ_1775674812
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 61C9A1956089;
	Wed,  8 Apr 2026 19:00:12 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.81.138])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id E72B630001BB;
	Wed,  8 Apr 2026 19:00:10 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: chuck.lever@oracle.com,
	jlayton@kernel.org
Cc: linux-nfs@vger.kernel.org,
	neilb@brown.name,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Subject: [PATCH v2 1/3] nfsd: update mtime/ctime on CLONE in presense of delegated attributes
Date: Wed,  8 Apr 2026 15:00:06 -0400
Message-ID: <20260408190008.85082-2-okorniev@redhat.com>
In-Reply-To: <20260408190008.85082-1-okorniev@redhat.com>
References: <20260408190008.85082-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

When delegated attributes are given on open, the file is opened with
NOCMTIME and modifying operations do not update mtime/ctime as to not get
out-of-sync with the client's delegated view. However, for CLONE operation,
the server should update its view of mtime/ctime and reflect that in any
GETATTR queries.

Fixes: e5e9b24ab8fa ("nfsd: freeze c/mtime updates with outstanding WRITE_ATTRS delegation")
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 fs/nfsd/nfs4proc.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 99b44b6ec056..1272f2eb5ff4 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1396,6 +1396,17 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	goto out;
 }
 
+static void nfsd_update_cmtime_attr(struct dentry *dentry)
+{
+	struct iattr attr = {
+		.ia_valid = ATTR_CTIME | ATTR_MTIME | ATTR_DELEG,
+	};
+
+	inode_lock(d_inode(dentry));
+	notify_change(&nop_mnt_idmap, dentry, &attr, NULL);
+	inode_unlock(d_inode(dentry));
+}
+
 static __be32
 nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		union nfsd4_op_u *u)
@@ -1413,6 +1424,9 @@ nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			dst, clone->cl_dst_pos, clone->cl_count,
 			EX_ISSYNC(cstate->current_fh.fh_export));
 
+	if ((READ_ONCE(dst->nf_file->f_mode) & FMODE_NOCMTIME) != 0 && !status)
+		nfsd_update_cmtime_attr(cstate->current_fh.fh_dentry);
+
 	nfsd_file_put(dst);
 	nfsd_file_put(src);
 out:
-- 
2.52.0

