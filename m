Received: from mail-dy2-f12.google.com (mail-dy2-f12.google.com [74.125.229.12])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1EC7D38A725
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 05:47:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.229.12
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790142452; cv=none; b=uEdNiEwXnKI5ysyoAzIFmMVv4OwJ3nwNAGEzSwWfasVzEHMYiUn8PnoKqiO4aJbKJCdWyS+ZvnSH5tg+bggnmrpkH3DZ8a8FNA6ncHaENf/O4ezADsn0d1czC/sL04DzkAwDI7HNdl9z0LrZGUthvq5HvskbJ3t3+M/iB6w+XaE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790142452; c=relaxed/simple;
	bh=1OnYKMl2XWktPJJ6Jhx0e5rT/lhXluCuS9KSbydDVVM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=UuK+mGm6V1E04dX8D+T/3rA2h9A2JqCUGkfOB9T1ROJxgbSohCZTLeo+o7ybWEUel3WlmIr5UXPTuNUyHxTj/ShHU6172hAz/qV5mqdmxU2n4i6Ak27PVlbyR7TMt20iD0y12mdC4AaURzzx7TAPN+IqFrKqVQOZo82NHTHt+zo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=NkzeVsOi; arc=none smtp.client-ip=74.125.229.12
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NkzeVsOi"
Received: by mail-dy2-f12.google.com with SMTP id 5a478bee46e88-32dbbe82e13so456491eec.0
        for <linux-nfs@vger.kernel.org>; Tue, 22 Sep 2026 22:47:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790142450; x=1790747250; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=aRqiCyg7QjWUYzc30IrbHUyebbb5bfOflWp78hNWcp0=;
        b=NkzeVsOiC/yd8pEMoIH9bAavW4RFfW6Cv8a/cEZVoem+rFB8l3WldiBBNYDGIHBf03
         NlsfAnj/C/KewGVL7jdZRPrFR6pGwkALtpfHqv9+YiKrZEyJKEIcw1zUsmYVk2Gmx/IL
         Gub/74GLM/fyJkZVYNsL2dB5Yzl9f5CQgLsuuPOGD9xunc7Qt5MTd8aHHfrsSc1ltjbZ
         ZSED8GG7rZIgxfFIOX9QXaWTrn/kJniQddboQvWjwlsxfA/Mw0+b7mSLTYQ9Nn3xBWby
         R74h6cdR4TH0ixA4IeNS2QjRv4I27nppg1fAqjzFiCpr7Oa1c7ZHoJvozVrkZZt5I/NR
         yf5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790142450; x=1790747250;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=aRqiCyg7QjWUYzc30IrbHUyebbb5bfOflWp78hNWcp0=;
        b=Xe7omG9o9CYuHWvtaw6OrOGGeYnn44LzZbyy2pW/mq8hEhDoTnmZCw/G8Q/RNzgfQZ
         18TgV298/mr9Y1GhOcsXBg5EIbdkbWkFmeIsn+84ZQk/Rn0xz3Fko08m6Hmp+k4XRRh+
         iqcsy7NlWohMluE1ADqkgUCS2wWPxAMnVOVML40Sx4LzcMnK6IhNHSU2C7koHlukH0f5
         Qp0HUOK/To8UUI4nDC5yfRcFO4eOQzifi3Eb4BluL6rJJpz5qGKyHD4BjKrJr94hFbKr
         cCOaH5yI0zGQV6cawD6N13ridm8CNjhWpiVdyd+nH9htepWNN9MRnMUGhWctKn70uy/u
         exTQ==
X-Gm-Message-State: AFuF++k7T+xZVHzKEh1lX35o5rt6Zqn+NHBwByHcxYkRAZgdFm9VQGKq
	7ufWPc/vWw88JYnvj8X9Vv+lHA6MkdcYr4qUi8Vk4yvwGDZNzUiTT/g4M+y+Ew==
X-Gm-Gg: AYBFou0fPtZJkFZqy6hQhkxE5JVDw2Mf7RbSNRRpyICM7dCV54gJoLKWSb5UCuaaX1a
	a741P+MCxTUtr0Rtx2omF/ZxtrsxlH0UogiSDmz+dO5AzPUidk+gI//1On2cPHlaItkj9yJFakd
	xDoGE+yJ57aVr06PNHC2W3CLLnIunsqtubg3Hexj4M/srUg+SiJlMVkVtG0mnIzn+K3Qo9iwiUf
	LCWQnnMI7Z8tpWTVeaGu6cMoB54DASxbwO2Rwj/3Vl5mQ5oIhGVC/4KSNcW9Ah1BFSjeAnDzfRH
	F+ATERC8SUHhTG6xIKSS3RlZXQDgLowhB/MAjTnx19htlCjly49vL+MrEsKVkNvXxjF3nOnzwIK
	jinWtScpZmE2x7wgCgKhMQIRWEMUq4/qC7REYMZYVV3aSK8vdLcnl8hzpK3N2K7egERi+a1eRG6
	MLUZwc33g46YPzUoRwLGUGdQL+tNr2lwdYfX2aUBh+EOLsSj0ewO/B42WSrabz49GS73Xf35CUD
	LlISY+3hhKszEnWyCfqa6nAiulwZCpsS3delmnRKNn3eiJqdRaUOL/d7axM/nLymRe2nWPJQJ/5
	rc+OPQ3WpsWmjkgqrfZqeNULvhIzEqaiZYvUSZWzPIDSJY0c8xLwVGKlfk5xaThgcPhDGG2jb/L
	bvPbERSFrHuFQiUNrNN92djrYxXSjH1ujXPMo2l93CBuYyTEJAS3urZns/HOQJ43GT52JGImuEE
	pcOqFxseUAIThXnxg+RWf+PYHSnR4PWnDEFUeHIA==
X-Received: by 2002:a05:7301:211c:b0:33e:c6b4:b368 with SMTP id 5a478bee46e88-33ec6b4b380mr1020488eec.4.1790142449825;
        Tue, 22 Sep 2026 22:47:29 -0700 (PDT)
Received: from apollo.localdomain ([208.95.233.74])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-33e96952605sm3421643eec.22.2026.09.22.22.47.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 22 Sep 2026 22:47:29 -0700 (PDT)
From: Khem Raj <raj.khem@gmail.com>
X-Google-Original-From: Khem Raj <khem.raj@oss.qualcomm.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org,
	Khem Raj <raj.khem@gmail.com>
Subject: [PATCH] Make the TIRPC_1.3.7 symbol version conditional
Date: Tue, 22 Sep 2026 22:47:22 -0700
Message-ID: <20260923054722.1556838-1-khem.raj@oss.qualcomm.com>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Khem Raj <raj.khem@gmail.com>

Commit 468d4e66da9f ("Add missing exports for rpc_gss_getcred +
authdes_getucred") added a TIRPC_1.3.7 version node which lists both
symbols unconditionally. However:

- authdes_getucred() is defined in svc_auth_des.c, which is only
  compiled when --enable-authdes is used (default: no)
- rpc_gss_getcred() is defined in svc_auth_gss.c, which is only
  compiled when --enable-gssapi is used

so in the default configuration neither symbol is built, and linkers
which validate version script assignments (lld always, GNU ld with
--no-undefined-version) refuse to link the library:

  ld.lld: error: version script assignment of 'TIRPC_1.3.7' to symbol 'authdes_getucred' failed: symbol not defined
  ld.lld: error: version script assignment of 'TIRPC_1.3.7' to symbol 'rpc_gss_getcred' failed: symbol not defined

This is the same problem that the conditional version script support
was added for in 1.3.7, the new node simply bypassed the mechanism.

Route the two names through the same substitution used for the other
optional symbol sets, so that the node only lists what was actually
compiled in. When both features are disabled the node is emitted empty,
which both GNU ld and lld accept, and which keeps the version
definition (and therefore the ABI of the existing versions) unchanged.

Signed-off-by: Khem Raj <raj.khem@gmail.com>
---
 configure.ac        | 8 ++++++++
 src/Makefile.am     | 2 ++
 src/libtirpc.map.in | 6 ++++--
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/configure.ac b/configure.ac
index b0a1d81..f524498 100644
--- a/configure.ac
+++ b/configure.ac
@@ -115,15 +115,21 @@ if test "x$enable_gssapi" = "xyes"; then
     GSS_SYMBOLS="_svcauth_gss; authgss_create; authgss_create_default; authgss_free_private_data; authgss_get_private_data; authgss_service; gss_log_debug; gss_log_hexdump; gss_log_status; rpc_gss_get_error; rpc_gss_get_mech_info; rpc_gss_get_mechanisms; rpc_gss_get_principal_name; rpc_gss_get_versions; rpc_gss_qop_to_num; rpc_gss_seccreate; rpc_gss_set_callback; rpc_gss_set_defaults; rpc_gss_set_svc_name; rpc_gss_svc_max_data_length;"

     GSS_SYMBOLS_031="svcauth_gss_get_principal; svcauth_gss_set_svc_name;"
+
+    GSS_SYMBOLS_137="rpc_gss_getcred;"
 else
     GSS_SYMBOLS=""
     GSS_SYMBOLS_031=""
+    GSS_SYMBOLS_137=""
 fi

 if test "x$enable_authdes" = "xyes"; then
     DES_SYMBOLS="cbc_crypt; ecb_crypt; xdr_authdes_cred; xdr_authdes_verf; xdr_rpc_gss_cred; xdr_rpc_gss_data; xdr_rpc_gss_init_args; xdr_rpc_gss_init_res;"
+
+    DES_SYMBOLS_137="authdes_getucred;"
 else
     DES_SYMBOLS=""
+    DES_SYMBOLS_137=""
 fi

 if test "x$enable_rpcdb" = "xyes"; then
@@ -134,7 +140,9 @@ fi

 AC_SUBST([GSS_SYMBOLS])
 AC_SUBST([GSS_SYMBOLS_031])
+AC_SUBST([GSS_SYMBOLS_137])
 AC_SUBST([DES_SYMBOLS])
+AC_SUBST([DES_SYMBOLS_137])
 AC_SUBST([RPCDB_SYMBOLS])

 AC_CANONICAL_BUILD
diff --git a/src/Makefile.am b/src/Makefile.am
index cfda770..be88999 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -23,7 +23,9 @@ libtirpc.map: $(srcdir)/libtirpc.map.in
 	$(AM_V_GEN)$(SED) \
 		-e 's|@GSS_SYMBOLS@|$(GSS_SYMBOLS)|g' \
 		-e 's|@GSS_SYMBOLS_031@|$(GSS_SYMBOLS_031)|g' \
+		-e 's|@GSS_SYMBOLS_137@|$(GSS_SYMBOLS_137)|g' \
 		-e 's|@DES_SYMBOLS@|$(DES_SYMBOLS)|g' \
+		-e 's|@DES_SYMBOLS_137@|$(DES_SYMBOLS_137)|g' \
 		-e 's|@RPCDB_SYMBOLS@|$(RPCDB_SYMBOLS)|g' \
 		< $(srcdir)/libtirpc.map.in > $@ || rm -f $@

diff --git a/src/libtirpc.map.in b/src/libtirpc.map.in
index 6c0b9b2..2f4535c 100644
--- a/src/libtirpc.map.in
+++ b/src/libtirpc.map.in
@@ -296,8 +296,10 @@ TIRPC_0.3.3 {
 } TIRPC_0.3.2;

 TIRPC_1.3.7 {
-    authdes_getucred;
-    rpc_gss_getcred;
+    # DES crypto symbols (conditionally included)
+@DES_SYMBOLS_137@
+    # GSS-API symbols (conditionally included)
+@GSS_SYMBOLS_137@
 } TIRPC_0.3.3;

 TIRPC_PRIVATE {
