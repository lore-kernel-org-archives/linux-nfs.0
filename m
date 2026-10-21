Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792622410;
	b=g0Fkvv4D6GDBXWXw5dkZBo26McBAf2pQZBaxw50QHi6GEf1RLNOc3xpl3pouEciaDeOj
	 X7fwICX3KTbBXn7PgzxH4gaD3970zvr5Lqf/RLk/EUdf6I5aGGb5CdactgR1iDCufL0Kt
	 Mmit0r3hyYpvhCryriL7nB0X3KOYaMejhb4N7V/UXhc3xfy/OwWMiNi9xjj+WtUJuG+r9
	 hGIXG8oAjaNyyVctiQqdC1NBuJNLzo5fG4ziuNlxA4ufVy0ehdeTtOSH1K8rN4K1qVWrb
	 j3bWDm+8YNZffuc91VUqioZsUbgP9B0V6D0FbmRhyCLPVREOxn4xCYbBPLiQ0i/fNBQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792622410;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=THnx3CbKvvguVnJ0sa7DV2tZvGozRHmSYmGqBHiIQIU=;
	b=zI+R+P3mgie+gXeRrmQCJsNFqtyMRAYBfgvFoXRiSYrv89P3VQpL4a0YRix58mwbffND
	 DbxF64/f6e5/7m9OmtgSHpygi/Zis5a6Y5sMfDYa3wq6wHHVZMRx2bokptqXN2EYSH1pw
	 MdwPZ1rZS/7sIVVQS/JVxdo7b5+2h42slFGxGIgEP8gGsChZ2sHuBcww4s3jmvS8ynVtO
	 vKOcjmy3pkoEEasrjR4ZW8NWXnmu/7yHFxNIHuTMgUPwccVblCu+6G5nW9mGmrf5P2Zj3
	 uR3IyBlRyaOD4ixDEAOdgwQyOhmlsFQsdJbaOP8VntUjSUiCh5Q6ak4yZUg+1A7k2Vg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Dw2Y11ei;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C2FC660A2603
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 22:40:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C2FC660A2603
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Dw2Y11ei
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792622408;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=THnx3CbKvvguVnJ0sa7DV2tZvGozRHmSYmGqBHiIQIU=;
	b=Dw2Y11eiWcZlm5fE4QM3J2J9mMIpmAAWjgHGH8Pe23U/KnGibr9L7S/n8BqGp0sqJbjlAL
	VYF878hakCyFuLgW6GPXY1LDtxkGMP6NEp0ezYwCLIoFU7BFgjv1Q8bS/jLclk6rKRMIMZ
	adC7vI/eX9mTFH+tM8kGecJhnBjIYe4=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-557-z6qipyR4Mi2nikyYXtX-Ng-1; Wed,
 21 Oct 2026 22:40:07 +0000
X-MC-Unique: z6qipyR4Mi2nikyYXtX-Ng-1
X-Mimecast-MFC-AGG-ID: z6qipyR4Mi2nikyYXtX-Ng_1792622406
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 0D3CD195607D
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 22:40:06 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id B6A8E1956042;
	Wed, 21 Oct 2026 22:40:05 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 0BC8A58CD886;
	Wed, 21 Oct 2026 18:40:05 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 2/2] sm-notify: use a separate socket per address family
Date: Wed, 21 Oct 2026 18:40:04 -0400
Message-ID: <20261021224004.2273010-3-smayhew@redhat.com>
In-Reply-To: <20261021224004.2273010-1-smayhew@redhat.com>
References: <20261021224004.2273010-1-smayhew@redhat.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Previously sm-notify sent all of its RPC traffic over a single AF_INET6
socket with IPV6_V6ONLY disabled, relying on the network stack to reach
IPv4 peers via IPv4-mapped IPv6 addresses.  That approach is fragile:

 - It depends on IPv4-mapped IPv6 addresses being usable, which is not
   true on all configurations, and requires getaddrinfo(3) to be asked
   for mapped addresses (AI_V4MAPPED) or the IPv4 results are unsendable.

 - A socket bound to a specific source address (via -v / outgoing-addr)
   takes on that address's family, so an IPv6 source address cannot send
   to IPv4 peers (and vice versa), failing with ENETUNREACH.

Create one datagram socket per address family instead, each strictly
single-family (IPV6_V6ONLY is now enabled on the IPv6 socket), and send
each host's notification on the socket matching the destination's family.
Peer names are resolved with native address families (no AI_V4MAPPED),
and IPv4 peers once again use PMAP_GETPORT, which is also understood by
legacy portmappers.

When a specific source address is requested, each family's socket is
bound to the matching address from that name; a name that resolves to
both families can now notify peers of both families from a single
invocation.  A host that only resolves to a family for which no socket
is available is skipped with a warning, leaving its on-disk monitor
record intact so a later run can retry.

Assisted-by: LLM
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/statd/sm-notify.c | 253 ++++++++++++++++++++++++++--------------
 1 file changed, 163 insertions(+), 90 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index affaea28..89e67c49 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -68,15 +68,26 @@ struct nsm_host {
 
 static char		nsm_hostname[SM_MAXSTRLEN + 1];
 static int		nsm_state;
-static int		nsm_family = AF_INET;
 static int		opt_debug = 0;
 static _Bool		opt_update_state = true;
 static unsigned int	opt_max_retry = 15 * 60;
 static char *		opt_srcaddr = NULL;
 static char *		opt_srcport = NULL;
 
-static void		notify(const int sock);
-static int		notify_host(int, struct nsm_host *);
+/*
+ * sm-notify uses one datagram socket per address family so that it can
+ * reach both IPv4 and IPv6 peers without relying on IPv4-mapped IPv6
+ * addresses.  Either descriptor may be -1 when that family is
+ * unavailable (eg. IPv6 is disabled, or a source address was requested
+ * for one family only).
+ */
+struct nsm_sockets {
+	int	v4;
+	int	v6;
+};
+
+static void		notify(const struct nsm_sockets *socks);
+static int		notify_host(const struct nsm_sockets *, struct nsm_host *);
 static void		recv_reply(int);
 static void		insert_host(struct nsm_host *);
 static struct nsm_host *find_host(uint32_t);
@@ -90,7 +101,11 @@ smn_lookup(const char *name)
 {
 	struct addrinfo	*ai = NULL;
 	struct addrinfo hint = {
-		.ai_family	= (nsm_family == AF_INET ? AF_INET: AF_UNSPEC),
+#ifdef IPV6_SUPPORTED
+		.ai_family	= AF_UNSPEC,
+#else	/* !IPV6_SUPPORTED */
+		.ai_family	= AF_INET,
+#endif	/* !IPV6_SUPPORTED */
 		.ai_protocol	= (int)IPPROTO_UDP,
 	};
 	int error;
@@ -276,78 +291,53 @@ smn_get_host(const char *hostname,
 	return 1;
 }
 
-#ifdef IPV6_SUPPORTED
-static int smn_socket(void)
+/*
+ * Create a non-blocking datagram socket of the given address family.
+ *
+ * Returns the socket descriptor, or -1 if the family is unavailable
+ * or an error occurs.
+ */
+static int
+smn_socket(const int family)
 {
 	int sock;
 
-	/*
-	 * Use an AF_INET socket if IPv6 is disabled on the
-	 * local system.
-	 */
-	sock = socket(AF_INET6, SOCK_DGRAM, 0);
+	sock = socket(family, SOCK_DGRAM, 0);
 	if (sock == -1) {
-		if (errno != EAFNOSUPPORT) {
-			xlog(L_ERROR, "Failed to create RPC socket: %m");
+		/* The family being unsupported is not an error: the
+		 * caller simply won't use a socket for it. */
+		if (errno == EAFNOSUPPORT)
 			return -1;
-		}
-		sock = socket(AF_INET, SOCK_DGRAM, 0);
-		if (sock < 0) {
-			xlog(L_ERROR, "Failed to create RPC socket: %m");
-			return -1;
-		}
-	} else
-		nsm_family = AF_INET6;
+		xlog(L_ERROR, "Failed to create RPC socket: %m");
+		return -1;
+	}
 
 	if (fcntl(sock, F_SETFL, O_NONBLOCK) == -1) {
 		xlog(L_ERROR, "fcntl(3) on RPC socket failed: %m");
-		goto out_close;
+		(void)close(sock);
+		return -1;
 	}
 
+#ifdef IPV6_SUPPORTED
 	/*
-	 * TI-RPC over IPv6 (udp6/tcp6) does not handle IPv4.  However,
-	 * since sm-notify open-codes all of its RPC support, it can
-	 * use a single socket and let the local network stack provide
-	 * the correct mapping between address families automatically.
-	 * This is the same thing that is done in the kernel.
+	 * Keep the IPv6 socket strictly IPv6; the AF_INET socket is used
+	 * to reach IPv4 peers.  This avoids any dependence on IPv4-mapped
+	 * IPv6 addresses, which are not usable on all configurations.
 	 */
-	if (nsm_family == AF_INET6) {
-		const int zero = 0;
-		socklen_t zerolen = (socklen_t)sizeof(zero);
+	if (family == AF_INET6) {
+		const int one = 1;
 
 		if (setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
-					(char *)&zero, zerolen) == -1) {
+				(char *)&one, (socklen_t)sizeof(one)) == -1) {
 			xlog(L_ERROR, "setsockopt(3) on RPC socket failed: %m");
-			goto out_close;
+			(void)close(sock);
+			return -1;
 		}
 	}
+#endif	/* IPV6_SUPPORTED */
 
 	return sock;
-
-out_close:
-	(void)close(sock);
-	return -1;
 }
-#else	/* !IPV6_SUPPORTED */
-static int smn_socket(void)
-{
-	int sock;
-
-	sock = socket(AF_INET, SOCK_DGRAM, 0);
-	if (sock == -1) {
-		xlog(L_ERROR, "Failed to create RPC socket: %m");
-		return -1;
-	}
-
-	if (fcntl(sock, F_SETFL, O_NONBLOCK) == -1) {
-		xlog(L_ERROR, "fcntl(3) on RPC socket failed: %m");
-		(void)close(sock);
-		return -1;
-	}
-
-	return sock;
-}
-#endif	/* !IPV6_SUPPORTED */
 
 /*
  * If admin specified a source address or srcport, then convert those
@@ -355,12 +345,12 @@ static int smn_socket(void)
  */
 __attribute__((__malloc__))
 static struct addrinfo *
-smn_bind_address(const char *srcaddr, const char *srcport)
+smn_bind_address(const char *srcaddr, const char *srcport, const int family)
 {
 	struct addrinfo *ai = NULL;
 	struct addrinfo hint = {
-		.ai_flags	= AI_NUMERICSERV | AI_V4MAPPED,
-		.ai_family	= nsm_family,
+		.ai_flags	= AI_NUMERICSERV,
+		.ai_family	= family,
 		.ai_protocol	= (int)IPPROTO_UDP,
 	};
 	int error;
@@ -374,6 +364,17 @@ smn_bind_address(const char *srcaddr, const char *srcport)
 	else
 		error = getaddrinfo(srcaddr, srcport, &hint, &ai);
 	if (error != 0) {
+		/*
+		 * When a specific source address was requested, it is normal
+		 * for it to have no address in one of the families; that
+		 * family is simply not served by this invocation.
+		 */
+		if (srcaddr != NULL) {
+			xlog(D_GENERAL, "No %s source address for '%s': %s",
+				family == AF_INET ? "IPv4" : "IPv6",
+				srcaddr, gai_strerror(error));
+			return NULL;
+		}
 		xlog(L_ERROR,
 			"Invalid bind address or port for RPC socket: %s",
 				gai_strerror(error));
@@ -410,17 +411,17 @@ smn_bindresvport(int sock, struct sockaddr *sap)
  * an error occurs.
  */
 static int
-smn_create_socket(const char *srcaddr, const char *srcport)
+smn_create_socket(const int family, const char *srcaddr, const char *srcport)
 {
 	int sock, retry_cnt = 0;
 	struct addrinfo *ai;
 
 retry:
-	sock = smn_socket();
+	sock = smn_socket(family);
 	if (sock == -1)
 		return -1;
 
-	ai = smn_bind_address(srcaddr, srcport);
+	ai = smn_bind_address(srcaddr, srcport, family);
 	if (ai == NULL) {
 		(void)close(sock);
 		return -1;
@@ -503,8 +504,9 @@ read_smnotify_conf(char **argv)
 int
 main(int argc, char **argv)
 {
-	int	c, sock;
+	int	c;
 	char *	progname;
+	struct nsm_sockets socks;
 
 	progname = strrchr(argv[0], '/');
 	if (progname != NULL)
@@ -610,14 +612,21 @@ usage:		fprintf(stderr,
 		close(2);
 	}
 
-	sock = smn_create_socket(opt_srcaddr, opt_srcport);
-	if (sock == -1)
+	socks.v4 = smn_create_socket(AF_INET, opt_srcaddr, opt_srcport);
+#ifdef IPV6_SUPPORTED
+	socks.v6 = smn_create_socket(AF_INET6, opt_srcaddr, opt_srcport);
+#else	/* !IPV6_SUPPORTED */
+	socks.v6 = -1;
+#endif	/* !IPV6_SUPPORTED */
+	if (socks.v4 == -1 && socks.v6 == -1) {
+		xlog(L_ERROR, "Failed to create an RPC socket");
 		exit(1);
+	}
 
 	if (!nsm_drop_privileges(-1))
 		exit(1);
 
-	notify(sock);
+	notify(&socks);
 
 	if (hosts) {
 		struct nsm_host	*hp;
@@ -633,11 +642,50 @@ usage:		fprintf(stderr,
 	exit(0);
 }
 
+/*
+ * Return the socket descriptor to use for the given address family,
+ * or -1 if no socket is available for it.
+ */
+static int
+smn_sock_for_family(const struct nsm_sockets *socks, const int family)
+{
+	switch (family) {
+	case AF_INET:
+		return socks->v4;
+	case AF_INET6:
+		return socks->v6;
+	}
+	return -1;
+}
+
+/*
+ * Move the first address on a host's list to the end, so the next
+ * attempt uses a different address.  A no-op if there is only one.
+ */
+static void
+smn_rotate_address(struct nsm_host *host)
+{
+	if (host->ai->ai_next != NULL) {
+		struct addrinfo *first = host->ai;
+		struct addrinfo **next;
+
+		/* remove the first entry from the list */
+		host->ai = first->ai_next;
+		first->ai_next = NULL;
+		/* find the end of the (new) list */
+		next = &host->ai;
+		while ( *next )
+			next = & (*next)->ai_next;
+		/* put first entry at end */
+		*next = first;
+	}
+}
+
 /*
  * Notify hosts
  */
 static void
-notify(const int sock)
+notify(const struct nsm_sockets *socks)
 {
 	time_t	failtime = 0;
 
@@ -645,7 +693,8 @@ notify(const int sock)
 		failtime = time(NULL) + opt_max_retry;
 
 	while (hosts) {
-		struct pollfd	pfd;
+		struct pollfd	pfd[2];
+		int		nfds, i;
 		time_t		now = time(NULL);
 		unsigned int	sent = 0;
 		struct nsm_host	*hp;
@@ -663,7 +712,7 @@ notify(const int sock)
 			hp = hosts;
 			hosts = hp->next;
 
-			if (notify_host(sock, hp))
+			if (notify_host(socks, hp))
 				continue;
 
 			/* Set the timeout for this call, using an
@@ -682,16 +731,27 @@ notify(const int sock)
 		xlog(D_GENERAL, "Host %s due in %ld seconds",
 				hosts->name, wait);
 
-		pfd.fd = sock;
-		pfd.events = POLLIN;
+		nfds = 0;
+		if (socks->v4 != -1) {
+			pfd[nfds].fd = socks->v4;
+			pfd[nfds].events = POLLIN;
+			nfds++;
+		}
+		if (socks->v6 != -1) {
+			pfd[nfds].fd = socks->v6;
+			pfd[nfds].events = POLLIN;
+			nfds++;
+		}
 
 		wait *= 1000;
 		if (wait < 100)
 			wait = 100;
-		if (poll(&pfd, 1, wait) != 1)
+		if (poll(pfd, (nfds_t)nfds, wait) <= 0)
 			continue;
 
-		recv_reply(sock);
+		for (i = 0; i < nfds; i++)
+			if (pfd[i].revents & POLLIN)
+				recv_reply(pfd[i].fd);
 	}
 }
 
@@ -699,10 +759,13 @@ notify(const int sock)
  * Send notification to a single host
  */
 static int
-notify_host(int sock, struct nsm_host *host)
+notify_host(const struct nsm_sockets *socks, struct nsm_host *host)
 {
 	struct sockaddr *sap;
 	socklen_t salen;
+	unsigned int naddr, tried;
+	struct addrinfo *a;
+	int sock;
 
 	if (host->ai == NULL) {
 		host->ai = smn_lookup(host->name);
@@ -719,26 +782,36 @@ notify_host(int sock, struct nsm_host *host)
 	 * point.
 	 */
 	if (host->retries >= 4) {
-		/* don't rotate if there is only one addrinfo */
-		if (host->ai->ai_next != NULL) {
-			struct addrinfo *first = host->ai;
-			struct addrinfo **next;
-
-			/* remove the first entry from the list */
-			host->ai = first->ai_next;
-			first->ai_next = NULL;
-			/* find the end of the (new) list */
-			next = &host->ai;
-			while ( *next )
-				next = & (*next)->ai_next;
-			/* put first entry at end */
-			*next = first;
-		}
-
+		smn_rotate_address(host);
 		nfs_set_port(host->ai->ai_addr, 0);
 		host->retries = 0;
 	}
 
+	/*
+	 * Select the socket matching the address family of the current
+	 * address.  If we have no socket for that family (eg. a source
+	 * address was requested for the other family only), rotate through
+	 * the remaining addresses looking for one we can send from.  If
+	 * none is usable, give up on this host, leaving its on-disk record
+	 * so a later run can retry.
+	 */
+	naddr = 0;
+	for (a = host->ai; a != NULL; a = a->ai_next)
+		naddr++;
+
+	for (tried = 0; ; tried++) {
+		sock = smn_sock_for_family(socks, host->ai->ai_addr->sa_family);
+		if (sock != -1)
+			break;
+		if (tried + 1 >= naddr) {
+			xlog_warn("No usable source address to notify %s; "
+				"giving up", host->name);
+			return 1;
+		}
+		smn_rotate_address(host);
+		nfs_set_port(host->ai->ai_addr, 0);
+	}
+
 	sap = host->ai->ai_addr;
 	salen = host->ai->ai_addrlen;
 
-- 
2.55.0

