Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792622502;
	b=pWU3Sb/9U8CGuhcVGGApekKkDm9pQKHJAwIAbb5aFPMIqMM/FLdmClL1M3QKX7ALpgbW
	 EBaEaZ4MBTRjZGEQyUSEgdyrcFuFIdePQnQYtoCq/7eUXUfESMS/VPxsX0BtkuOEL+RE0
	 Jye1fcawqcx1e6xW68Kw6wIVCBipffGCNHV/hiO8Rf8501b6P4f6rJKqjT1VyODkagsSM
	 h40ZN+zUkJqMCCjLxqei/ZwEk5DyRMKlSNJzf2KVRsnVcrlU7rJ3wwA32eb29zZtsV5Sc
	 phCowIXs6XbJ02UF2QSZ3/yX6xG5d1J3tjZ7XtuL+3rir4shEB9sZd1nQ1FrQHWY6zA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792622502;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:MIME-Version:Content-Transfer-Encoding:X-Scanned-By;
	bh=1UXuNu2sBriiYiudisIfsddma7apPl0zKPxw59FOJmQ=;
	b=Zwu4gqDtVhgVk/Zft9vU/RNtxRjik0aYkTe8c90m6D1VqInLMsWR2Qzs468PRALyY4jL
	 Ro5gUxFL98kbkIDtWoyIMFFi/yiUnBom2N4wxRj56Th5xckgFRZo9O9Jjp3izNxAX21Gl
	 rnEliP0Kjtf7PNZma4cdMxry23puoIIvhufXUwufnPYup94QYilfymgjT8HpT/pBNY65s
	 2aSKQYGhdYIZcjp8IEAUTSUYyWUMZH1w28LP/4GxCwUzVuyZKyBPpxukBJ0JsjXYqT3q2
	 riIsUxT3Fp3Iq2b8cROlNuQbmkxLIWNugWkD14jwOIN5o9Ir1+vsCfPT/jhPl/mjQ8A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=E4X0zXuH;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D280B606A319
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 22:41:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D280B606A319
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=E4X0zXuH
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792622500;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=1UXuNu2sBriiYiudisIfsddma7apPl0zKPxw59FOJmQ=;
	b=E4X0zXuHUBM0nxs7QMPBnkz4hQ/vD6dL9HSZzuU3HkAEpa05eHI8IsoiGBc40loB4wz5NA
	fYZeD3XnhhQ8w7TgsGUqsnsu+XytAU2RTp6p6l7mnqLX45GoWf/geC1buScR0tWyokYk8L
	IlYScz1t7H98EI+MkHGcvBrtqvnGSGw=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-445-a1ba32qHOeWbxJ_KhzQfpA-1; Wed,
 21 Oct 2026 22:41:38 +0000
X-MC-Unique: a1ba32qHOeWbxJ_KhzQfpA-1
X-Mimecast-MFC-AGG-ID: a1ba32qHOeWbxJ_KhzQfpA_1792622497
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 57D031956067
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 22:41:37 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 2DCEA30000E3;
	Wed, 21 Oct 2026 22:41:37 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 74C5458CD9F4;
	Wed, 21 Oct 2026 18:41:36 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [libtirpc PATCH] __binddynport: honor ip_local_port_range
Date: Wed, 21 Oct 2026 18:41:36 -0400
Message-ID: <20261021224136.2273107-1-smayhew@redhat.com>
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
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

__binddynport() currently binds to ports in the dynamic port range
defined by RFC 6335, which is ports 49152-65535.

If rpcbind is built with remotecalls enabled, it binds 2 dynamic ports
for the remotecall sockets.  The selinux-policy allows rpcbind_t to bind
ports with ephemeral_port_t, which is ports 32768-60999.  It does not
allow rpcbind_t to bind ports with unreserved_port_t, which is ports in
the ranges 61000-65535 and 1024-32767.  Currently, the random port
selected by __binddynport might land in the former range, which triggers
both an AVC error in selinux and an error from rpcbind in the syslog.

Read /proc/sys/net/ipv4/ip_local_port_range and constrain the range of
ports used by __binddynport() to the intersection of the compiled-in
defaults and the range defined by ip_local_port_range.

The default values for ip_local_port_range is "32768 60999", so the
resulting dynamic range used by __binddynport() would be lowport=49152,
highport=60999, nports=11848.

Link: https://bugzilla.redhat.com/show_bug.cgi?id=1758147
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 src/binddynport.c | 90 ++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 81 insertions(+), 9 deletions(-)

diff --git a/src/binddynport.c b/src/binddynport.c
index c2e9a20..52bac17 100644
--- a/src/binddynport.c
+++ b/src/binddynport.c
@@ -57,6 +57,75 @@ enum {
 	NPORTS		= ENDPORT - LOWPORT + 1,
 };
 
+int lowport = LOWPORT;
+int endport = ENDPORT;
+int nports = NPORTS;
+
+/*
+ * Parse the first and last local port numbers from
+ *	/proc/sys/net/ipv4/ip_local_port_range.
+ *
+ * @first - the first (low) port in the range
+ * @last - the last (high) port in the range
+ *
+ * Returns 0 on success, and both @first and @last are updated.
+ * Returns -1 on failure, and neither @first nor @last are updated.
+ */
+static int parse_ip_local_port_range(int *first, int *last)
+{
+	int res, new_first, new_last;
+	FILE *fp;
+
+	fp = fopen("/proc/sys/net/ipv4/ip_local_port_range", "r");
+	if (fp == NULL) {
+		(void) syslog(LOG_ERR,
+			"Unable to open open /proc/sys/net/ipv4/ip_local_port_range.");
+		return -1;
+	}
+
+	res = fscanf(fp, "%d %d", &new_first, &new_last);
+	if (res != 2) {
+		(void) syslog(LOG_ERR,
+			"An error occurred while parsing ip_local_port_range.");
+		fclose(fp);
+		return -1;
+	}
+
+	*first = new_first;
+	*last = new_last;
+
+	fclose(fp);
+	return 0;
+}
+
+/*
+ * Try to update our dynamic port range using information from the kernel.
+ *
+ * Returns 0 on success, and lowport, endport, and nports should be the
+ *	intersection of the compiled-in defaults and the values reported
+ *	by /proc/sys/net/ipv4/ip_local_port_range.
+ * Returns -1 on failure, and lowport, endport, and nports retain their
+ *	default values.
+ *
+ * This function is called by __binddynport() before using any of:
+ *	endport, lowport, nports
+ */
+static int update_dynamic_port_range(void)
+{
+	int ret, low, end;
+
+	ret = parse_ip_local_port_range(&low, &end);
+	if (ret < 0)
+		return -1;
+
+	if (lowport < low)
+		lowport = low;
+	if (endport > end)
+		endport = end;
+	nports = endport - lowport + 1;
+	return 0;
+}
+
 /*
  * This function decodes information about given port from provided array and
  * return if port is reserved or not.
@@ -67,8 +136,8 @@ enum {
  * Returns 0 if port is not reserved, non-negative if port is reserved.
  */
 static int is_reserved(char *reserved_ports, int port) {
-	port -= LOWPORT;
-	if (port < 0 || port >= NPORTS)
+	port -= lowport;
+	if (port < 0 || port >= nports)
 		return 0;
 	return reserved_ports[port/(8*sizeof(char))] & 1<<(port%(8*sizeof(char)));
 }
@@ -82,8 +151,8 @@ static int is_reserved(char *reserved_ports, int port) {
  *
  */
 static void set_reserved(char *reserved_ports, int port) {
-	port -= LOWPORT;
-	if (port < 0 || port >= NPORTS)
+	port -= lowport;
+	if (port < 0 || port >= nports)
 		return;
 	reserved_ports[port/(8*sizeof(char))] |= 1<<(port%(8*sizeof(char)));
 }
@@ -193,13 +262,16 @@ int __binddynport(int fd)
 		goto out;
 	}
 
+	if (update_dynamic_port_range() < 0)
+		(void) syslog(LOG_ERR, "Using default port range.");
+
 	if (!seed) {
 		struct timeval tv;
 
 		gettimeofday(&tv, NULL);
 		seed = tv.tv_usec * getpid();
 	}
-	array_size = NPORTS / (8*sizeof(char)) + 1;
+	array_size = nports / (8*sizeof(char)) + 1;
 	reserved_ports = malloc(array_size);
 	if (!reserved_ports) {
 		goto out;
@@ -208,8 +280,8 @@ int __binddynport(int fd)
 	if (parse_reserved_ports(reserved_ports) < 0)
 		goto out;
 
-	port = (rand_r(&seed) % NPORTS) + LOWPORT;
-	for (i = 0; i < NPORTS; ++i) {
+	port = (rand_r(&seed) % nports) + lowport;
+	for (i = 0; i < nports; ++i) {
 		*portp = htons(port);
 		if (!is_reserved(reserved_ports, port++)) {
 			res = bind(fd, sap, salen);
@@ -220,8 +292,8 @@ int __binddynport(int fd)
 			if (errno != EADDRINUSE)
 				break;
 		}
-		if (port > ENDPORT)
-			port = LOWPORT;
+		if (port > endport)
+			port = lowport;
 	}
 
 out:
-- 
2.55.0

