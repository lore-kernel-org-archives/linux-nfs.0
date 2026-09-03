Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7922B4DA54F
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:48:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788457733; cv=none; b=c+e/PiK8LEEe9lhvm0fCVCtnjQ7o+UAi2dWaJIkNfTRvi2NNwX3R0ZlHW75RK7fk49XXbW5mCypOVHAgyspdY2iYdSFzTyyzwso6urvRf/j1i978EFlqd0tR6D3Qp/yMKVPCsFzhv6+poeBp74oUjsUHlU8mV60POC8noMLjRJ0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788457733; c=relaxed/simple;
	bh=5SHjI9nx5oijBBqAZUHsa4s9vBUumMjquHlTC3NjmBg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Jk0jmDsHGnidaHgPzudy/QLcWbSM5d6gSVH8AMufrA8492tjpM3LH1RBDv8X+x6KGNMA29h50QtlzCQPoGqXKO+UIN735B/YyRykBYOHUcYiwxtIAaKyXJtuxSX6fXikPjRxFi/drlPMns055INX4rKZftQnAgstfWfLgMpIpt8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=JfZMNp14; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="JfZMNp14"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788457730;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=sUnf34i2W+KY2eew1AHihmXwwasr7UK36f5H/FuaZd8=;
	b=JfZMNp14Ko5W6q81KKrd2o4F3sW7XBfH3Mt95190SfWaegLEIWb7AT3C0fND98641aIAEf
	iUu+hwN9XzfLLJRkSGKeF2XpeCt3rW3XVFUb61nwUp/rcBpxp1dJMbl4u8HmFsUluudAeT
	qJ+Vmsirq0EktjY5ybOmkVfZVakIz9U=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-553-GrCrled1O92Yir3EXpO5OA-1; Thu,
 03 Sep 2026 13:48:49 -0400
X-MC-Unique: GrCrled1O92Yir3EXpO5OA-1
X-Mimecast-MFC-AGG-ID: GrCrled1O92Yir3EXpO5OA_1788457728
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 423141860978
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:48:48 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 1B7CC7DA;
	Thu,  3 Sep 2026 17:48:48 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 721395345A75;
	Thu, 03 Sep 2026 13:48:47 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] fsidd: replace assertions with explicit malformed-input handling
Date: Thu,  3 Sep 2026 13:48:47 -0400
Message-ID: <20260903174847.1213636-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

fsidd relies on assert() to ensure that an argument is present after the
command prefix while parsing commands received over the local socket.
Malformed input can cause fsidd to abort.  Replace the assertions with
explicit malformed-input handling and return an error to the client.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 support/reexport/fsidd.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/support/reexport/fsidd.c b/support/reexport/fsidd.c
index 51750ea3..f5c397aa 100644
--- a/support/reexport/fsidd.c
+++ b/support/reexport/fsidd.c
@@ -48,7 +48,11 @@ static void client_cb(evutil_socket_t cl, short ev, void *d)
 		char *answer = NULL;
 		bool found;
 
-		assert(req_path < buf + n );
+		if (req_path >= buf + n) {
+			char answer[] = "- Command failed: Bad input";
+			(void)send(cl, answer, strlen(answer), 0);
+			return;
+		}
 
 		printf("client asks for %s\n", req_path);
 
@@ -70,8 +74,11 @@ static void client_cb(evutil_socket_t cl, short ev, void *d)
 		char *answer = NULL;
 		bool found;
 
-		assert(req_path < buf + n );
-
+		if (req_path >= buf + n) {
+			char answer[] = "- Command failed: Bad input";
+			(void)send(cl, answer, strlen(answer), 0);
+			return;
+		}
 
 		if (dbbackend->fsidnum_by_path(req_path, &fsidnum, true, &found)) {
 			if (found) {
@@ -94,7 +101,11 @@ static void client_cb(evutil_socket_t cl, short ev, void *d)
 		uint32_t fsidnum;
 		bool found;
 
-		assert(req_fsidnum < buf + n );
+		if (req_fsidnum >= buf + n) {
+			char answer[] = "- Command failed: Bad input";
+			(void)send(cl, answer, strlen(answer), 0);
+			return;
+		}
 
 		errno = 0;
 		fsidnum = strtoul(req_fsidnum, &endp, 10);
-- 
2.55.0

