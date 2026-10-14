Received: from mx1.white.stw.pengutronix.de (mx1.white.stw.pengutronix.de [185.203.200.13])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C231A4746B4
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 13:18:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=185.203.200.13
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791983906; cv=pass; b=TpD9rtpKYq9jlHG1icSPBOG8Fsl6ECPKmS3Fu9Tc88sCt4RHPsoKtXr8u25Tl0BQYQfzDN1pROB0JYx/MbVQ/4gHEbmDY88bo6yBo1L11toO78/K+XPrCF71xAEg3WhVmdGb81L7q19TFuHzx1oU/S50KUVrifbkZW4pP02nMWg=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791983906; c=relaxed/simple;
	bh=aw0tRmF79ID3voeirmW2J4qZveWT8KuDhMpN45C/Wm0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=qj6dbpwBASKprn2OkMpOTajICTizf+HkHpHCfEMA/1ldQFF6ff37lmja66KGz3MjWM8J9PM+cY8HUfIMbivFrzNkJu2zGNeBScL2dwDVPfAmt2pv4LqvYyny7WFXiMpyMsAg/JcmjowfiXFnjBbKScPV2QvEn7AhqR5hTvy4RUw=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=pengutronix.de; spf=pass smtp.mailfrom=pengutronix.de; dkim=pass (2048-bit key) header.d=pengutronix.de header.i=@pengutronix.de header.b=T9zcASYD; arc=pass smtp.client-ip=185.203.200.13
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=pengutronix.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=pengutronix.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=pengutronix.de header.i=@pengutronix.de header.b="T9zcASYD"
Received: from drehscheibe.grey.stw.pengutronix.de (drehscheibe.grey.stw.pengutronix.de [IPv6:2a0a:edc0:0:c01:1d::a2])
	(Authenticated sender: relay-from-drehscheibe.grey.stw.pengutronix.de)
	by mx1.white.stw.pengutronix.de (Postfix) with ESMTPSA id C4BB32018A0;
	Wed, 14 Oct 2026 15:18:21 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=pengutronix.de;
	s=20260414; t=1791983901;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=vbSf9EvKWKZmhjC3Y7oO5YeQ4qHZxORfnOTCUDaB6J8=;
	b=T9zcASYDRKDe/+Xi4rOOLYAMI26vibL6dHF5Hp2bqY0oG1Oz7vxMIR4j74RUCpNOSEWvaX
	r3GiK1d0QwbxsNwnj6oxhV/TtdhTe+GJObwGYI7SJTm4dJZaBDca+eDshymuOaPcGHZ2/W
	EAVY5Nh2lew1X5f6jMJDjQc8v7PZmv4/yl/YbgqAOXCkUqTG+eISsaqJ0YbTkouhu6meFI
	lQLamJF0+BoBxGaizLpvP3qeLbIa6gQNOZnuRmK0Mib/sZa2H+kJloTYgyxnd7c2DDgZho
	mvMRHhSlstT3HmIML9WwAr90K6PwWRhM59obrR0+lIf5g3A8NewKAwWPD0bI8g==
ARC-Seal: i=1; s=20260414; d=pengutronix.de; t=1791983901; a=rsa-sha256;
	cv=none;
	b=EFvYCzm8NllRT1pEGI0t4flKmPh3HKEeYgwn1uhyqYgUKNcxRDqdRdw9w1Qgk5/wMsLKEf
	LMLJxWPTrWEREGtiV4vdGbnoMXSej8NiVxrUb8hSZ9BZHKQ9gjZMfH6tG+ZH03drjMw3VR
	N/+OT41UiH7YmO+yvqiuZhskLIDHycI34rRMzIvxjt6kHz+v2tpZ076nENtZglY30fm9Sm
	q/luFp7OzKvAySt+7p9G0ffskekvqiss45uJvY4lOHN69412V0If6vzFlriSbV3Eq5yRhH
	JxAANztFi+ixHzQrf1APT6T/rOWrvTRTixeOJyITT01ASa3a+KzVZYGoAijIyw==
ARC-Authentication-Results: i=1;
	ORIGINATING;
	auth=pass smtp.auth=relay-from-drehscheibe.grey.stw.pengutronix.de smtp.mailfrom=s.pueschel@pengutronix.de
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=pengutronix.de;
	s=20260414; t=1791983901;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=vbSf9EvKWKZmhjC3Y7oO5YeQ4qHZxORfnOTCUDaB6J8=;
	b=IH9TT45DA2A4V3+vo8KybU/9riHCLQyqNJMSDWkBP2cifSJoLmJUPUGE24cdCGhE315dcD
	2ktgKH6iQSR+L2l+H3vaB0Tz2/d3qfL659ABeANK9y6ZThpHjmCZO2mHUA5N31uZ+nWep6
	OqrBo14esoBieDIzqwk7JUJIggh6HtCPXJorWROHN87k3pn+T2le09wniiK+byfeOybZTa
	cq5Tloa2q3wZSYWlfilXryhfNPUd32ooEdOQVsnlSV1EmjyqitBr38PSUp3crmev1YSIeP
	v7JOwwNF6HEsy/xtoROmKCME+YqtpINjqVGQEUFbMvd855UA8c2TKLs9o+b3wA==
Received: from ptz.office.stw.pengutronix.de ([2a0a:edc0:0:900:1d::77] helo=peter.mobile.pengutronix.de)
	by drehscheibe.grey.stw.pengutronix.de with esmtp (Exim 4.96)
	(envelope-from <s.pueschel@pengutronix.de>)
	id 1xGys9-005rdH-2B;
	Wed, 14 Oct 2026 15:18:21 +0200
From: =?utf-8?q?Sven_P=C3=BCschel?= <s.pueschel@pengutronix.de>
Date: Wed, 14 Oct 2026 15:17:59 +0200
Subject: [nfs-utils PATCH] configure: use AS_IF when PKG_CHECK_MODULES is
 used
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20261014-fixconfigureasif-v1-1-0d2013f719e4@pengutronix.de>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yXMyw5AMBCF4VeRWWuidfcqYlE1ZSxKOohEvLti+
 SXn/BcwekKGJrrA40FMiwuQcQRm0m5EQUMwqEQVMpGZsHSaxVkad4+ayYoS87pMq9yqoYZwWz2
 GzZdsu9+89zOa7e3AfT+CnVaadAAAAA==
X-Change-ID: 20261014-fixconfigureasif-7e597385f2d9
To: linux-nfs@vger.kernel.org
Cc: kernel@pengutronix.de, 
 =?utf-8?q?Sven_P=C3=BCschel?= <s.pueschel@pengutronix.de>
X-Mailer: b4 0.15.2

Use AS_IF when PKG_CHECK_MODULES is used to avoid it's required macros
being expanded inside the test. Otherwise these required macros are not
available to subsequent PKG_CHECK_MODULES invocations, if the first
invocation is disabled, which therefore fails to find the package.

Without this running `./configure --disable-nfsrahead` fails:

   checking for libnl-3.0 >= 3.1... no
   configure: error: in '[redacted]/nfs-utils':
   configure: error: A pkg-config implementation could not be found or
   is too old.  Make sure it is in your PATH or set the PKG_CONFIG
   environment variable to the full path to pkg-config.

Signed-off-by: Sven Püschel <s.pueschel@pengutronix.de>
---
Noticed while updating the version in PTXDist, which disables most
options in it's host package of nfs-utils.
---
 configure.ac | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/configure.ac b/configure.ac
index 71ec1841..de6e63a4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -242,10 +242,10 @@ AC_ARG_ENABLE(nfsrahead,
 	enable_nfsrahead=$enableval,
 	enable_nfsrahead="yes")
 	AM_CONDITIONAL(CONFIG_NFSRAHEAD, [test "$enable_nfsrahead" = "yes" ])
-	if test "$enable_nfsrahead" = yes; then
+	AS_IF([test "$enable_nfsrahead" = yes], [
 		dnl Check for -lmount
 		PKG_CHECK_MODULES([LIBMOUNT], [mount])
-	fi
+	])
 
 AC_ARG_ENABLE(nfsdcltrack,
 	[AS_HELP_STRING([--enable-nfsdcltrack],[enable NFSv4 clientid tracking programs @<:@default=no@:>@])],
@@ -276,11 +276,11 @@ AC_ARG_ENABLE(nfsdctl,
 	enable_nfsdctl=$enableval,
 	enable_nfsdctl="yes")
 	AM_CONDITIONAL(CONFIG_NFSDCTL, [test "$enable_nfsdctl" = "yes" ])
-	if test "$enable_nfsdctl" = yes; then
+	AS_IF([test "$enable_nfsdctl" = yes], [
 		AC_DEFINE([HAVE_NFSD_NETLINK], 1,
 	  		[Define to 1 if nfsd generic netlink support is available])
 		PKG_CHECK_MODULES(LIBREADLINE, readline)
-	fi
+	])
 
 AC_ARG_ENABLE(nfsv4server,
 	[AS_HELP_STRING([--enable-nfsv4server],[enable support for NFSv4 only server  @<:@default=no@:>@])],

---
base-commit: 5090e0bb662c53b4552b28b121ac2c2c434adb2e
change-id: 20261014-fixconfigureasif-7e597385f2d9

Best regards,
--  
Sven Püschel <s.pueschel@pengutronix.de>

