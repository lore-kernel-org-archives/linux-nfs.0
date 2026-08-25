Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6767B3B52E4
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 18:53:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787684013; cv=none; b=SgOhiqjqaOVgaZafYL5rSsOLzW4YLz0V8M9SETI7MtbZAhHzCX1rbtMh/bPb+mS9fV11TiyEXCt4fVP4K5VFhnUgVms8uUUAFNz0dftgXAC3JMVwlJmq6s8eDdtf5Buy3XiHFuAGHxRo49N90HcsgPUU15HVbG/xDrBwsD+uCfg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787684013; c=relaxed/simple;
	bh=et4o/4ArFT7m3Jj2HN966kV98akTAezCMUwk+WVtCXM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=PD2WfdMWl4Obbk9dkS+QRzGI2TNzo/BrnAv1VH73sN1QIkIMs1RqXPY/dvo+962RbF2oVSg/ofHwXhAUqYL75c6fQfnzGWEvx1MphBN55TvY6cxHoebCsk1m8GS8kbGqMLdwE0KGggW4IDSNh8tdqR5IP29LDLrGMw4RnY7VaiY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=G18pK1u0; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="G18pK1u0"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1787684008;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=s6g+jgS4AYH9q3p0juegUbL1vP0pHfbSXsAnBRSGuCY=;
	b=G18pK1u0t+fu99ezGO7Wncabvk7l96A0SD8h19TJeH0mHnucq4DRFwbph9t6DgnRSr0k6E
	OAEZ9DDbKoGSnfkbJnmstATCtlFAjT4siWhoGpnU2DOeHLVbADekIiLDVcFR826uBy5yoR
	cmzpTXCI2O7J/yWbg+SCtuCkTXaAiT8=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-483-IFcZyYINNKemMgd1gaLrPQ-1; Tue,
 25 Aug 2026 14:53:25 -0400
X-MC-Unique: IFcZyYINNKemMgd1gaLrPQ-1
X-Mimecast-MFC-AGG-ID: IFcZyYINNKemMgd1gaLrPQ_1787684005
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id DD2A718C0FF4
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 18:53:24 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.80.220])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 4CC85362;
	Tue, 25 Aug 2026 18:53:24 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] nfs-utils: mount: fix snprintf return value handling in error formatting
Date: Tue, 25 Aug 2026 14:53:23 -0400
Message-ID: <20260825185323.27151-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

snprintf() returns the number of bytes that would have been written
if sufficient space were available, not the number actually written.
When the formatted string exceeds PATH_MAX (e.g. due to a long
progname), the return value exceeds the buffer size. Using that
unclamped value as an index into errbuf produces an out-of-bounds
pointer, and subsequent snprintf() calls write past the buffer.

Add errbuf_clamp() to bound the position to the valid range before
it is used as a buffer index. Apply it in rpc_mount_errors(),
sys_mount_errors(), and rpc_strerror().

Fixes: 6e54f6179cb9 ("text-based mount.nfs: Add text-based error reporting function")
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 utils/mount/error.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/utils/mount/error.c b/utils/mount/error.c
index d6cbdea1..4dace8f5 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -54,6 +54,21 @@ extern char *progname;
 static char errbuf[PATH_MAX];
 static char *erreob = &errbuf[PATH_MAX];
 
+/*
+ * Clamp a buffer position to the valid range for errbuf.
+ * snprintf() returns the number of bytes that would have been written,
+ * which can exceed the buffer size on truncation.  Using that unclamped
+ * value as an index into errbuf produces an out-of-bounds pointer.
+ */
+static int errbuf_clamp(int pos)
+{
+	if (pos < 0)
+		return 0;
+	if (pos >= PATH_MAX)
+		return PATH_MAX - 1;
+	return pos;
+}
+
 /* Convert RPC errors into strings */
 static int rpc_strerror(int spos)
 {
@@ -62,6 +77,8 @@ static int rpc_strerror(int spos)
 	char *ptr, *estr = clnt_sperrno(cf_stat);
 	char *tmp;
 
+	spos = errbuf_clamp(spos);
+
 	if (estr) {
 		if ((ptr = strchr(estr, ':')))
 			estr = ++ptr;
@@ -72,9 +89,9 @@ static int rpc_strerror(int spos)
 					_("System Error: %s"),
 						strerror(cf_errno));
 		else {
-			if (cf_errno) 
+			if (cf_errno)
 				pos = snprintf(tmp, (erreob - tmp),
-					_("RPC Error:%s; errno = %s"), 
+					_("RPC Error:%s; errno = %s"),
 					estr, strerror(cf_errno));
 			else
 				pos = snprintf(tmp, (erreob - tmp),
@@ -109,6 +126,7 @@ void rpc_mount_errors(char *server, int will_retry, int bg)
 				_("%s: mount to NFS server '%s' failed: "),
 					progname, server);
 
+	pos = errbuf_clamp(pos);
 	tmp = &errbuf[pos];
 	if (rpc_createerr.cf_stat == RPC_TIMEDOUT) {
 		if (will_retry)
@@ -119,6 +137,7 @@ void rpc_mount_errors(char *server, int will_retry, int bg)
 					_("timed out, giving up"));
 	} else {
 		pos += rpc_strerror(pos);
+		pos = errbuf_clamp(pos);
 		tmp = &errbuf[pos];
 		if (bg) {
 			if (will_retry)
@@ -164,6 +183,7 @@ void sys_mount_errors(char *server, int error, int will_retry, int bg)
 				_("%s: mount to NFS server '%s' failed: "),
 					progname, server);
 
+	pos = errbuf_clamp(pos);
 	tmp = &errbuf[pos];
 	if (error == ETIMEDOUT) {
 		if (will_retry)
-- 
2.52.0

