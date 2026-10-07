Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 874883290D1
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 23:02:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791414171; cv=none; b=f6qtUw83owgUVYQP9Mpo8YcZORYrruA6ihI/quWj5XGXB+2sWTGeYQqz1n33tU5WPmAjUcva9ANA9Yg5l3s50nKfrBu6urZR9Xn7HdVSX+So+M2n0AVF2trZxoQ6tRMxrpfaJ7/kMhJfiCzy6EOyZSSAVbHuxEYj9jFX6DIWrnQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791414171; c=relaxed/simple;
	bh=QVJJq3gpSBghM6bBANcxHNWePeMTSUc2nNQuQ3yxy8s=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ibVt5gSAu9lMvKOem3FYwBw/6Twa+sumC7LmtpxSWxrVNDMaR+n8/8t05I16FknyV7xkvE2NR4Uix+OT6nBct8SrtnvpCFyNUZV/5quyLnWFNgEvOlF4YSBFiY2rkdXbi/J0q3HxsGuE0cg2d19trhw63/WpmpDAEo6JVHx51fM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=f3Y03g10; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="f3Y03g10"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791414169;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=1UXuNu2sBriiYiudisIfsddma7apPl0zKPxw59FOJmQ=;
	b=f3Y03g10V2qca9EBhpLGc73RTNAh+LrMJ0UCUtGtk7H+3f2kqlj862TUxztzx8EwyJyDex
	p6CQYiVZ6qmNTrA45Wd8gKbZGup5IJpmA6wLW1crlpN0zg5jjX/cAFI69J4PyeHi2+QINe
	/9/mlMTzTQqsiKJg6GBUhS3tUNYPf4I=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-609-_Oyqmc5vNkObzhq8jlGZpA-1; Wed,
 07 Oct 2026 19:02:48 -0400
X-MC-Unique: _Oyqmc5vNkObzhq8jlGZpA-1
X-Mimecast-MFC-AGG-ID: _Oyqmc5vNkObzhq8jlGZpA_1791414167
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 1E231180AEFB;
	Wed,  7 Oct 2026 23:02:47 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet03.pony-001.prod.iad2.dc.redhat.com [10.2.32.114])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id D5C3C1944CC0;
	Wed,  7 Oct 2026 23:02:46 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 1DC94576375D;
	Wed, 07 Oct 2026 19:02:46 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: libtirpc-devel@lists.sourceforge.net,
	linux-nfs@vger.kernel.org
Subject: [libtirpc RFC PATCH] __binddynport: honor ip_local_port_range
Date: Wed,  7 Oct 2026 19:02:45 -0400
Message-ID: <20261007230245.449569-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

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

