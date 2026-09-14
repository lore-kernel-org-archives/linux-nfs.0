Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68848476040
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 13:14:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789391677; cv=none; b=let3QHI/uiGwUpKsl3FVlS3qOCrpAayDndWWj9h/6BUio/sQmx0AH1kerw0Cry54dMLN99xlptWIUoBzicul/rm/oeVpcCMk2oCBuw4Kuo85PGSwwxt96PMpwEUzTMVg8eLK50p8FK/Pi7N0oW1BH6PDD+/bWomDWw6xtd7Bb8s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789391677; c=relaxed/simple;
	bh=w0RsmikSFQo/zU5YjmjUnojH6ZS05HjBP7EMA088xv8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=jidkpMzcCSV+sMNxm3xcrSMSORNVe9Dmwjhzu2WUjn6qSDtj92Iwy0DwRr2JMfcyNwBowvFefyMQaJZPIvroQjy4JWYKv2RTmdmYPognrrLJ6oF6wjpc6En2xtvkwGvMglizR4hfz5vF2zOGO4s76cldhc1bsdYp1I/QYEW/ELI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OoJVEUe4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OoJVEUe4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E97621F0089D;
	Mon, 14 Sep 2026 13:14:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789391676;
	bh=l+vIgdV2SPnuwSUW3I62WSfvce0Gax650KUVNjuXIKU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OoJVEUe4v8a1Ekniu/oHjRr8txTmroZDUUMkpf3Yt3cPqYE7w4MpufJzEnQ/6gA3Z
	 y5JxB25IcndIbeCJxF16Y1VOljmwcQQYu27iVa9AY8sbARtkwi9GzFpcj6vtytjqCX
	 1wgRQJtPG9E46ttyqhcOBg4eEjXIwY1xZa4xXz7jZkR1zmG/jUvIxzgW7xw1aGkDEH
	 gbI3RM/HqE3dvX/dmtxNRrtdCEDy5VcrK0hus3KfyAWwmJs50lmgB/7p08AZskiVLC
	 aH20mkkjSsdXR1DEllSZd/S7zkBIMXVD7oUn69QUte85A4TaXdclx8L87f5VY5JI9j
	 06XocE8cb/QBA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 09:14:20 -0400
Subject: [PATCH nfs-utils v3 11/11] mountd: don't warn about pipefs
 submounts nobody asked to export
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nl-crossmnt-v3-11-a984a6c94829@kernel.org>
References: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
In-Reply-To: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1102; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=w0RsmikSFQo/zU5YjmjUnojH6ZS05HjBP7EMA088xv8=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqp/M0//JSIwMvBA7oh5pGGK6veh8VWq+iF0iIq
 oIO3JjvEquJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqfzNAAKCRAADmhBGVaC
 FbTdEACkInNuqJwPiF+HaA/Ts2dIcAtyfqeYypcAXvEHtZVunqs/zSNcBm2V63xzaQ2M6phXdOk
 9rLyVjG6CXVShEh7vbFfE5UebyBRbK6zemNOciPLtM/tb4NfDSn9TDRSZx9OJDjocGJFN6/+NRo
 Poprz/w0FAvstNn8/dEXPkFEF7eOpyjQWqApH8u7QDLaS3aNchrnTfvyKbbOhPYogOn6yVWFTu9
 Yv1mR3xOAg2pUaD1JHBWlba8OBrAyISKaqPC0cA0rJbJw4ufQkRPkhdEbCSiA1fkXaHC6O/eRsq
 Q2mzvJL1HJTNc/HDP22Xcvwl8/lD8paMS/LwF16p5KaQ1lC0xxOf+AOPW/KswsBiP9viPCDaLI+
 s6GwYpXdQcSOGHDdBi3E9LUXPCPWMFCghtlMui5SHrboAhAfIoR42L4tiZXWzqYOvFhTl/bOjDJ
 ZvtCuY2f1QkWilPRh/9s+BebfPaJSQMFggrT0mXDN7lKdCbkxLtKgUgDCyiNGOtAF/cSgvi0ORU
 Wh0gSjreZbh5R/UBxlVu02Ba1UTiQFrQGQNDF4hJLgQZ0/+8/T9glup0nwy39V9rqS4dIN4+XNk
 Rf108ywJNsGaJmYV6dnhHMl2PsYwKpzjwi4ZzeabeWgLE0UtXxFC25uLvAzbc/8RaX3m0Wy8jHr
 giUxngpPM89TWkg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_export() warns whenever dump_to_cache() cannot work out the
attributes for a path, including a crossmnt submount the admin never
asked to export.  With "/" exported crossmnt that is one warning per
proc, sys or autofs mount per TTL, and nothing the admin can act on.

Use the same test the netlink downcall now uses: warn only when the
request is for a path exported in its own right.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/cache.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index d1fef23a6c0f..c1201f24bfd4 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -3750,7 +3750,8 @@ static void nfsd_export(int f)
 			 */
 			if (errno == EAGAIN)
 				goto out;
-			xlog(L_WARNING,
+			xlog(export_is_explicit(found, path) ? L_WARNING
+							     : D_GENERAL,
 			     "Cannot export %s, possibly unsupported filesystem"
 			     " or fsid= required", path);
 			dump_to_cache(f, buf, sizeof(buf), dom, path, NULL, 0);

-- 
2.55.0

