Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 020B63AD531
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 16:35:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791563714; cv=none; b=i0EYVezwD35t8XOMNB9xpA6df2i6eW6Rt7hQSV6B1kDveoHtBNKqmPQDw8NOLYDfVFSGAJgQfSEUWkd1p7Qka4RHXLMFf/Ej16E1ANv9jUaYtpycutzqkpx5do1St4lctqFQNW3eF6QSKv6StwO3y3wtRpWJKTyKN8OSARU5R6M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791563714; c=relaxed/simple;
	bh=rHr5Q2RKJup1o5d5Oy89oL746Het4prru/LJRCtw9GY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Y0/E61En4kn5DoVZwUj/dx+xAA6jSnwV4eTtEKiYwoTiYHjUWCymJH7lyw8voN8zvfeEJuIWTNUHME43tfzu4F51+uUglftuYBEP8myKPlEcwDw4R1jOE65FmA8jw5/A/0G4NxYwqXdGWDRKJngqXZx9gr4j3rey18KXWd3HVVw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fX3eedVJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fX3eedVJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 594E01F00893;
	Fri,  9 Oct 2026 16:35:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791563706;
	bh=CAuk4hqfpcV46w/VoWuhz/dQvILSwVjgg6BCcANP1Y0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=fX3eedVJ7v2CHH2fDRZHZcp3R9sIMorJwG35PfxPPJY89QkHgzbUEpVjmZ5oEMOme
	 J65FcB4JcCErMGmRiQY5rVqKT2uk61n8TG7JaFxd3jPVdJK1bD+07CFjybChqFtjLY
	 vpjs2tcS2RSDvk/06xqJrRwN/gWmBYYHlmdTiGTVN2zdO0jX2r9OLBQtrBDKOyMfL/
	 8SNBXQ0IX3T0FkRYh0ZlV6YNbsqr/F3bxtYh5ZDH+8Wmah+OWdXJIHOVln7FG2bxXV
	 Mi6QEGSY7qMTfQk64J3m4u9cVKOHjZHTthoJtAUY9ARlCy05srJ5TiFW39mnRTrFCI
	 ooaH+Nt1ovQFA==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 09 Oct 2026 12:34:55 -0400
Subject: [PATCH pynfs v3 1/9] Add helper to report unsupported protocol
 features
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261009-acl-mode-v3-1-ba487c5e66e0@kernel.org>
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
In-Reply-To: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org, aurelien.couderc2002@gmail.com, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=939; i=cel@kernel.org;
 h=from:subject:message-id; bh=7I/Bld5ORyeCCePjLHxIn9JnHUaXYd7+bPsHqq2lW4g=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqyRe4FZODKLOV4nJorzz+HQJpQhBA4iJuhwcBr
 fYdBpYHXBeJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaskXuAAKCRAzarMzb2Z/
 l2ooD/90sEo0ZPsmCifhxmSsJu8TOuKj6/hXD/r0pPUa4KdG2T6LxN3N1ypJGkBJ0Bgm9xq370X
 9A5hZcwxJ4zRXShDsjeMVhimx4qsLaGOwljKxi3cKPCCpAsSFjwEYqWwTOgUvTVVjeeUf0GdtZ0
 QXxTcK9k5rrAGt1cHokDXN2weXijUknPUvUksaLIh0LLAgtz2jPgwf0BNqHI7hFxtl4OlcswFON
 um6PuvfIVfhxczqmR67MiV7FOVMXhVfglo3IYS2iY/gLgRqB2+siH95syDsxXDH5HTE5afcKwTb
 Hyt2XSrMBzavsKm/sUMv2dqA7sJwTyXVNt7qgM6WpSFftyfhbz/07K3qNvcJ4ZlPF9JyAoGmL8h
 92y5LWDn4YcwCtPuMHp0CfvjqKWGbcVa/TtIhclvX7fNUkstZqHt291xmpl0PW2HG81LU3JUo0l
 ZO9nsf1uKH5MEcfBJmDIphHGvAlNY4cDh28WdA9IRRxFhJcC1zITeF9k+86y15wzjsWqDlaXdSS
 9uIwoX5yYrYC6v/xrzYqV0guP+4FwXZZnFIET3iHN0hYbEUEI60tcp5Q+PSWkUm1RXqcFM0d27e
 aGcMSBxc9WeB6hCyg1zguW+7VqIDpG3GwlRdiGReZSF9wt+5LHUscXKeImUrbj2EqMXVf8ZFzcA
 rr4Ge5yKxMPcb3w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

In some cases, specifications permit a server to not implement
a feature (or part of a feature) being tested. That should not
count as a test failure. The helper added here can be used to
indicate that the test did not pass or fail, but that the server
under test does not support the tested feature.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 nfs4.1/server41tests/environment.py | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 3c77153631ae..0d5e686d93b3 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -277,6 +277,9 @@ debug_fail = False
 def fail(msg):
     raise testmod.FailureException(msg)
 
+def unsupported(msg):
+    raise testmod.UnsupportedException(msg)
+
 def check(res, stat=NFS4_OK, msg=None, warnlist=[]):
 
     if type(stat) is str:

-- 
2.54.0

