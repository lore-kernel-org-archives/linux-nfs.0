Received: from mail-wm1-f47.google.com (mail-wm1-f47.google.com [209.85.128.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 106743DFC80
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 08:37:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791275871; cv=none; b=k94VkKsz/SyxsV3ruOptWoR9ZwfAJOTQdwy4ZgGdww3Ci19xbT9txYxcxIWPldh4hlp/Fm48TDXGIr4SPb5HEg4fknsHc0pgoVfpNYggvs7K1q+SzsSAabgFR/fehCailKgDB+QNnndwO8GvVtxnTIi7e0ltRYDSCrS0kI3hoK4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791275871; c=relaxed/simple;
	bh=c6XJk30eeiJIQINtl7rTtv74KQp65+5hPbjkmD88LAE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=j8ew8ebG86g83dFB3vfYiKqgL69pOLM+MpYg7KFqpURC5GmMwNzVZ7wBuu/7m0sB4IlSBkby3eTNrkRa1ffmqy5dFQyJQGxqEmNh6e9RdNBvTUoqEG/ByIXecqxXcC8PbYUT33/fIFLNYaZvOst+7UZs0rRJOmex21CgmwfaiI4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=bJb0zNOy; arc=none smtp.client-ip=209.85.128.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bJb0zNOy"
Received: by mail-wm1-f47.google.com with SMTP id 5b1f17b1804b1-4995b0343c1so9753385e9.3
        for <linux-nfs@vger.kernel.org>; Tue, 06 Oct 2026 01:37:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791275868; x=1791880668; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=6lbHUo9RRGPMTrm2WIboNGXIcD4dUALOnxmlEPV05Lo=;
        b=bJb0zNOyKXbYVOnTKoWTPG+w7RUS9pSBIZWLY8YEZoG+ezwUqwe7SdHuSBeyzFEh8E
         ouXnhCf4XnqWhF30yito2P9VCDU4/sUfvCs0EC/AwptsUiXAM/mMZ7jMuRpsZu8r8UM9
         fIuZOmQQ7f3T3xYrvpMZBchUvbqZZjD30KXDc67Dsa77oLu7HthvAsMijaJCRQz7lUQi
         zLjCgRW6+ez+Jre5N1XItg5+D53sJxd0+gMh9s+fEj/xAs0pjd0fpusGf+3DkP9PLTfQ
         oFa4P9bZlDRwMCNPpGYgODViY5gbMCfXBhK7sIuCuTUG8d51UyCEUSR08kXCRlSe1XWx
         VQEg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791275868; x=1791880668;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=6lbHUo9RRGPMTrm2WIboNGXIcD4dUALOnxmlEPV05Lo=;
        b=mrIPcqmXcLvF768zS5Ns22O0oM1tVDxIr6xPQYOtRaKYIXICv9G2+6P33+UJjB/HLn
         dfmYtwN2EuzYN/AomRIQN0mF4/KG6NyBVwBjhCQGlWMqxuUPxkKu6eeiKU+FAxmvpns1
         TB4rAxURVjULwhkJ9p1sQd5ITjQ2nomndGQvXJOeG6nemYC3R9loslnsWemJy2iUxHTL
         CqgG2IRP/CWu/GbVCcptOboK8Hj8hB+RjLZ69e3p+YkTixIlimmstv3L6Mjrl2v/QvUd
         j4yyj+5Nupy8NOoQ0PvIbq2IeKp6ZEHPDrc2NnqXwrx7uqczR9RJsJpVdbHQ2zCAGnA6
         81cw==
X-Gm-Message-State: AFuF++nrvlxwL19C0QDk5ByFo++gZjeMPk3iuyyn3IXRuTYku5v6zvP5
	IXgNalnXrZQCj8kEGwTUfJQc9FAygp+hhe+Bp/2VONrJ/8SoRX+Y5LI4oBz3s5Z5
X-Gm-Gg: AYBFou3VoOhsp4zI4JSJ1ozviyByADRnjvrTyR8CNp6eeXEbJibmOXlOrcviTPdTgVa
	iqAvRFn4wOfaLaQUYMkJYjDigDkXm3jAyIn6M0U0k3fPehMM6eNEg8fzFazH0WoiQXOAk6UFxRE
	7/7t9VxllrmwiFJuJ/P3E3YD6atn160mS4KVUUdiV628i8B3ZF9o9SFvIHfmqe2sTaetFIii2kD
	TH2Ii1s1JeAo0dzm99kx2gOmD3qo7sb20d4vVeVlRI2I6q2Tfq5yZWsySMcxaxC1bQKCbOzTv2B
	3sikQDhWR9WCqkvC27SIu3AaBJ5CevOAVqItKRy2RZ6ot3jgG6DbHQzFNqxcYe/GqX45Av3OfLN
	9bLDrFxWWxZ+gQh7LrScqJdH+1fD0W8faUy6zWmQRLuQSZNUZyx4IfwyjP5SI9zhRASUfvzolSf
	LUeGbh82yvQ9ZnxPkv4sj6hg++iW7a1kYT2kTY28jjMGe812V5m/oyBBC9xIiUxg8Q1plhP4K9j
	7DdPpr8Dq5REp/kdmLq1ynshxigtNbwtyrkvTzA8ONlzQxeHE164t+iryAjVPDWjOge1J9btUpv
	n7zlINVTjPp53Xkj+jT9HknR5Yiu
X-Received: by 2002:a05:600c:3486:b0:4a0:1e68:d28d with SMTP id 5b1f17b1804b1-4a17b53be3amr13033455e9.6.1791275867902;
        Tue, 06 Oct 2026 01:37:47 -0700 (PDT)
Received: from center.jhjvjihww5qejoy14qwv1cc4td.frax.internal.cloudapp.net ([131.189.143.225])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4a178db0929sm55677635e9.12.2026.10.06.01.37.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 06 Oct 2026 01:37:47 -0700 (PDT)
From: Orgad Shaneh <orgads@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Steve Dickson <steved@redhat.com>
Subject: [PATCH rpcbind] rpcbind: bind the TCP listeners to the -h addresses too
Date: Tue,  6 Oct 2026 08:37:46 +0000
Message-ID: <20261006083746.353335-1-orgads@gmail.com>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

-h restricts only the datagram transports: tcp and tcp6 still bind to
the wildcard address, so rpcbind answers on every interface over TCP
even when -h names loopback and a single internal address. A host that
uses -h to keep rpcbind off its external interfaces gets that only for
UDP.

When -h is given, take the stream transports through the same
per-address loop as the datagram ones (AF_LOCAL ones have no address
and keep their own path), with the SO_REUSEADDR and listen() that the
wildcard path already does for them. Without -h nothing changes.

Assisted-by: Claude:claude-opus-5-5
Signed-off-by: Orgad Shaneh <orgads@gmail.com>
---
 man/rpcbind.8 |  2 +-
 src/rpcbind.c | 15 ++++++++++++++-
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/man/rpcbind.8 b/man/rpcbind.8
index 15b70f9..03b5514 100644
--- a/man/rpcbind.8
+++ b/man/rpcbind.8
@@ -85,7 +85,7 @@ checks are shown in detail.
 .It Fl f
 Do not fork and become a background process.
 .It Fl h
-Specify specific IP addresses to bind to for UDP requests.
+Specify specific IP addresses to bind to for UDP and TCP requests.
 This option may be specified multiple times and can be used to
 restrict the interfaces rpcbind will respond to.
 When specifying IP addresses with
diff --git a/src/rpcbind.c b/src/rpcbind.c
index c39df97..1215c73 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -535,7 +535,13 @@ init_transport(struct netconfig *nconf)
 		hints.ai_socktype = si.si_socktype;
 		hints.ai_protocol = si.si_proto;
 	}
-	if (nconf->nc_semantics == NC_TPI_CLTS) {
+	/*
+	 * With -h, bind the stream transports to the given addresses too,
+	 * not only the datagram ones; AF_LOCAL transports have no address.
+	 */
+	if (nconf->nc_semantics == NC_TPI_CLTS ||
+	    (nhosts > 0 && strcmp(nconf->nc_netid, "local") != 0 &&
+	     strcmp(nconf->nc_netid, "unix") != 0)) {
 		/*
 		 * If no hosts were specified, just bind to INADDR_ANY.  Otherwise
 		 * make sure 127.0.0.1 is added to the list.
@@ -621,6 +627,11 @@ init_transport(struct netconfig *nconf)
 			}
 			addrlen = res->ai_addrlen;
 			sa = (struct sockaddr *)res->ai_addr;
+			if (nconf->nc_semantics != NC_TPI_CLTS &&
+			    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on,
+				       sizeof(on)) != 0)
+				syslog(LOG_ERR, "cannot set SO_REUSEADDR on %s",
+				    nconf->nc_netid);
 			oldmask = umask(S_IXUSR|S_IXGRP|S_IXOTH);
                         if (bind(fd, sa, addrlen) != 0) {
 				syslog(LOG_ERR, "cannot bind %s on %s: %m",
@@ -673,6 +684,8 @@ init_transport(struct netconfig *nconf)
 				(void) free(uaddr);
 			}
 #endif
+			if (nconf->nc_semantics != NC_TPI_CLTS)
+				listen(fd, SOMAXCONN);
 			my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf, &taddr, 
                                 RPC_MAXDATASIZE, RPC_MAXDATASIZE);
 			if (my_xprt == (SVCXPRT *)NULL) {
-- 
2.53.0

