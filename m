Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 63458883F
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 01:13:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788743615; cv=none; b=WW4CdgE1n0Bmvy1vv24KRJfMYdUw6GhWV5w0MdXiTjT7UwqjvTYHPfSCFI4Ot3Q6DFHx6GS/T7aTTijdd7X+nWKw4OsKChjSQGecf2uNvhlmF0n4iX+1tcGF62EQKQFg35gOvK5kKqw6ultl8yHb2H5qI44HvJC0hhn/q7KWvzE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788743615; c=relaxed/simple;
	bh=jaWlZQ8ZlepsXQeU/Fu3ZhfWxiqbDlA2okrOO0lKyEs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=BNml0znn5CA0YenR/wseuwUOky0eVpRckMfXdCzUybrtMg8e4Kie1Hayvfu/KVclhBAlKXP1tGn1hSvNmHq5+8Ucm0ZnNdl++YVkY28kVxWwPaHF8WPJpOVyra+xihcMUvY/k8PZusbp7eZjzmjhbSvLXRLz63lfaKbTUbphZ+w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=ddzGR1Rv; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ddzGR1Rv"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788743612;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=QMWXx1ovvXjj2qdmg/hVr5qGuFy+Konf1Hz2tVgqduU=;
	b=ddzGR1RvkdH02lX80z0RSmOVzFCVnbze56CqPzkJ1mMwuXjTrCz2jPJKOF2NvM6V7pG0Sm
	HJdNlnACPcrtAOtkZxcf6qHrqq/KaFuur79ELLwKRZMHs3zy26EGgW08oBdHP+uv8ABIN1
	BJ9In4/1o6gWC/9lHHW8IbCoATah53A=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-175-Lf1Fr1W2MJibI5aWQGjlBA-1; Sun,
 06 Sep 2026 21:13:30 -0400
X-MC-Unique: Lf1Fr1W2MJibI5aWQGjlBA-1
X-Mimecast-MFC-AGG-ID: Lf1Fr1W2MJibI5aWQGjlBA_1788743610
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id EBF271954219
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 01:13:29 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.64.31])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 5A0AA1800347;
	Mon,  7 Sep 2026 01:13:29 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] fsidd: require root credentials on abstract socket
Date: Sun,  6 Sep 2026 21:13:25 -0400
Message-ID: <20260907011328.21425-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

fsidd listens on an abstract UNIX domain socket which has no
filesystem-level access control.  Any local unprivileged user can
connect and issue mutating commands (get_or_create_fsidnum) that
grow the reexport database without limit, degrading mountd
performance.

Add a SO_PEERCRED check to reject connections from non-root
clients.  The only legitimate client is mountd, which runs as root.

Fixes: 6fd2732d ("export: Add fsidd")
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 support/reexport/fsidd.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/support/reexport/fsidd.c b/support/reexport/fsidd.c
index 9b80b451..c714386e 100644
--- a/support/reexport/fsidd.c
+++ b/support/reexport/fsidd.c
@@ -7,6 +7,7 @@
 #include <dlfcn.h>
 #endif
 #include <event2/event.h>
+#include <sys/socket.h>
 #include <sys/un.h>
 #include <unistd.h>
 
@@ -147,6 +148,8 @@ static void srv_cb(evutil_socket_t fd, short ev, void *d)
 {
 	int cl = accept4(fd, NULL, NULL, SOCK_NONBLOCK);
 	struct event *client_ev;
+	struct ucred cred;
+	socklen_t clen = sizeof(cred);
 
 	if (cl == -1) {
 		if (errno == EMFILE || errno == ENFILE || errno == ENOMEM ||
@@ -162,6 +165,12 @@ static void srv_cb(evutil_socket_t fd, short ev, void *d)
 	(void)ev;
 	(void)d;
 
+	if (getsockopt(cl, SOL_SOCKET, SO_PEERCRED, &cred, &clen) < 0 ||
+	    cred.uid != 0) {
+		close(cl);
+		return;
+	}
+
 	client_ev = event_new(evbase, cl, EV_READ | EV_PERSIST | EV_CLOSED, client_cb, event_self_cbarg());
 	if (!client_ev || event_add(client_ev, NULL) == -1) {
 		if (client_ev)
-- 
2.52.0

