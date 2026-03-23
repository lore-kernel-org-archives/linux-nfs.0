Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ACC0A26738B
	for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2026 18:21:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774290118; cv=none; b=LD+W5PXnh56XkgtSrmn5rO7fKJBVUAVBqfbacGlJkI5L5NKeNGWPfaaEvcowwn/vTs1txt2Bq8kfuKD993WPcoCsej2OqvcUhjCY2sGdoUfPXWrwqhvikHfvNTvuFm8cB11UaJzhIkd3JMPX03XwnZhMBWZboJYPCiBsMAz0p0A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774290118; c=relaxed/simple;
	bh=kgL2fXdeEDYFWvHUbR8vlyNar7L8DphrAa2gTf3lVh8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=YcEzLiOocqJkZkHZ+/IFfZEzVfK5TwfyX2WTyLc/krRClTW2fZuXhqrwQLgEd47CH4jT8TFJwmzu7KHAg4JhQkDYI3VKKS1VwfvTi6h8H39ilo0oR5NbwV9u1azfmebchmN7fFdM/uBDCCYgHjM/V0IvGsAzdyVMZg8LXajAgl4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=AG/yKfMS; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="AG/yKfMS"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1774290106;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=1HQFsfAF2g9WeMUzu6us32U9wC0hrcpgFCtz44CjCqQ=;
	b=AG/yKfMSuDksQER8ZdHk2OT3Mk008MWN5uXHE1qN1BZtRsc4y9dS6YAwlo/BFK+BFQzRWt
	o1tnR/JNspsAN0FMeDb9nv9jnbaOrfSptSlgS8g31/7ww6t7hClj8+V5NI1KZQpC1xerEC
	7sDrf9osVyBDtf4cAP3Hyk7wd0HJWHM=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-380-SVGXJ9GNPaeMc4hsmlr_5A-1; Mon,
 23 Mar 2026 14:21:45 -0400
X-MC-Unique: SVGXJ9GNPaeMc4hsmlr_5A-1
X-Mimecast-MFC-AGG-ID: SVGXJ9GNPaeMc4hsmlr_5A_1774290104
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 3DD3F195609F
	for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2026 18:21:44 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.65.38])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id A098219560B1;
	Mon, 23 Mar 2026 18:21:43 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] nfsdctl: check for listeners before starting threads
Date: Mon, 23 Mar 2026 14:21:42 -0400
Message-ID: <20260323182142.79465-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

When a thread command is executed and yet no listeners have been
added prior to it, instead of failing with EIO error print an
informative error. Also, "thread 0" command should not error
regardless of the listener status.

Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 utils/nfsdctl/nfsdctl.c | 52 ++++++++++++++++++++++++++++++++---------
 1 file changed, 41 insertions(+), 11 deletions(-)

diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index 6a20d180..d03e2c9f 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -162,6 +162,9 @@ static const char *nfsd4_ops[] = {
 	[OP_REMOVEXATTR]	= "OP_REMOVEXATTR",
 };
 
+static int fetch_current_listeners(struct nl_sock *sock);
+static int print_listeners(int output);
+
 static int error_handler(struct sockaddr_nl *nla, struct nlmsgerr *err,
 			 void *arg)
 {
@@ -720,7 +723,7 @@ static int threads_func(struct nl_sock *sock, int argc, char **argv)
 	uint8_t cmd = NFSD_CMD_THREADS_GET;
 	int *pool_threads = NULL;
 	int minthreads = -1;
-	int opt, pools = 0;
+	int opt, pools = 0, zero_threads = 0;
 
 	optind = 1;
 	while ((opt = getopt_long(argc, argv, "hm:", threads_options, NULL)) != -1) {
@@ -762,12 +765,31 @@ static int threads_func(struct nl_sock *sock, int argc, char **argv)
 			}
 
 			pool_threads[i] = strtol(targv[i], &endptr, 0);
+			if (!pool_threads[i])
+				zero_threads++;
 			if (!endptr || *endptr != '\0') {
 				xlog(L_ERROR, "Invalid threads value %s.", argv[1]);
 				return 1;
 			}
 		}
 	}
+	/* check if there are listeners added */
+	if (fetch_current_listeners(sock)) {
+		xlog(L_ERROR, "Unable to determine if listeners were added\n");
+		return 1;
+	}
+	if (!print_listeners(0)) {
+		if (zero_threads && zero_threads == pools) {
+			/* Note: we can never have a server with threads and no
+			 * listeners. If we ever add functionality to remove
+			 * listeners on an active server, we need to revisit this.
+			 */
+			return 0;
+		}
+		xlog(L_ERROR, "No listeners added, not starting threads\n");
+		return 1;
+	}
+
 	return threads_doit(sock, cmd, 0, 0, pools, pool_threads, NULL, minthreads);
 }
 
@@ -1077,9 +1099,9 @@ out:
 	return ret;
 }
 
-static void print_listeners(void)
+static int print_listeners(int output)
 {
-	int i;
+	int i, count = 0;
 	const char *res;
 
 	for (i = 0; i < MAX_NFSD_SOCKETS; ++i) {
@@ -1098,26 +1120,34 @@ static void print_listeners(void)
 			res = inet_ntop(AF_INET, &((struct sockaddr_in *)(&sock->ss))->sin_addr,
 					addr, INET6_ADDRSTRLEN);
 			port = ((struct sockaddr_in *)(&sock->ss))->sin_port;
-			if (res == NULL)
+			if (res == NULL && output)
 				perror("inet_ntop");
-			else
-				printf("%s:%s:%hu\n", sock->name, addr, ntohs(port));
+			else {
+				count++;
+				if (output)
+					printf("%s:%s:%hu\n", sock->name, addr, ntohs(port));
+			}
 			break;
 		case AF_INET6:
 			res = inet_ntop(AF_INET6, &((struct sockaddr_in6 *)(&sock->ss))->sin6_addr,
 					addr, INET6_ADDRSTRLEN);
 			port = ((struct sockaddr_in6 *)(&sock->ss))->sin6_port;
-			if (res == NULL)
+			if (res == NULL && output)
 				perror("inet_ntop");
-			else
-				printf("%s:[%s]:%hu\n", sock->name, addr, ntohs(port));
+			else {
+				count++;
+				if (output)
+					printf("%s:[%s]:%hu\n", sock->name, addr, ntohs(port));
+			}
 			break;
 		default:
-			snprintf(addr, INET6_ADDRSTRLEN, "Unknown address family: %d\n",
+			if (output)
+				snprintf(addr, INET6_ADDRSTRLEN, "Unknown address family: %d\n",
 					sock->ss.ss_family);
 			addr[INET6_ADDRSTRLEN - 1] = '\0';
 		}
 	}
+	return count;
 }
 
 static bool ipv6_is_enabled(void)
@@ -1394,7 +1424,7 @@ static int listener_func(struct nl_sock *sock, int argc, char ** argv)
 		return set_listeners(sock);
 	}
 
-	print_listeners();
+	print_listeners(1);
 	return 0;
 }
 
-- 
2.52.0

