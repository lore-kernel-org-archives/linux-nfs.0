Received: from mail-qv1-f42.google.com (mail-qv1-f42.google.com [209.85.219.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6E8DC2773E5
	for <linux-nfs@vger.kernel.org>; Wed,  1 Jul 2026 11:44:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782906287; cv=none; b=b6kq94Z6L7XhEHCNGdijjY7dibFWOAgGnALTP8UPSeEbl/HP4GbG7uRPsGqGRXCz3nZ3KreaVAYzP2k8tSvsw+rPHqAn0/rYRoz5oZunNmyDjxOZ83D6U49CZwb1FUFZ3KOij+FuORUDXaxPnVStPJehl6yL4U2FMeXDNLuwP0E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782906287; c=relaxed/simple;
	bh=Bn7cpK7c9P1Ng+xQTLrX5oRSvaP7UkoJRFYhjK+iQcU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=mFWneMlfQPa6h/zeU9J/2u7mLzTEuni7MedDUj15ZG5T2xHSEd01YvLFTTMIr8z27SH7eryJBxr0ytZTbpZ6g0zZmHxzuFGebOQw7RJEKgHl31hJePap4FTql4hRTFN1hTNgszw5wLZPF/Q9kGCco2l/gKpr/je1DWjIsRo6RDs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=trailofbits.com; spf=pass smtp.mailfrom=trailofbits.com; dkim=pass (2048-bit key) header.d=trailofbits.com header.i=@trailofbits.com header.b=C0e0vY33; arc=none smtp.client-ip=209.85.219.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=trailofbits.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=trailofbits.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=trailofbits.com header.i=@trailofbits.com header.b="C0e0vY33"
Received: by mail-qv1-f42.google.com with SMTP id 6a1803df08f44-8ef7b7651ecso17144016d6.1
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jul 2026 04:44:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=trailofbits.com; s=google; t=1782906282; x=1783511082; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=CWuXB5G6o/EOutDklrz0KDK/EngRzHI91oIWGAEJRck=;
        b=C0e0vY333zeAMCS/zM/pqIYUkT/ypLoAkXN5K7p8Sd3JoEhBloB5jC3LghM1QSXQ53
         9v/SHNallheASGhxKVytCtMb5RzQxCr/z+JoeaW3Cn7xpeBBlNC5ewKyiDfA6KEXV3ng
         8QEc1DuOO0Es0pbUn4FR5DeNdATltUAdi0shnf/eeM57mwBEDjatSQaNcaVQbmWeDDHl
         JER10VKk8fQF8KFQ20MTcP9TK9v02gKqj78yRWZwXHccz6oFQ02plz5WswNqCOqP5rWP
         0LdKX9rZJONPayNPmWQuBmzK4U8ITV8FnwWf97bqDM+rEOCLj92O1wDrGESr6xf0HZwd
         9ysw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1782906282; x=1783511082;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=CWuXB5G6o/EOutDklrz0KDK/EngRzHI91oIWGAEJRck=;
        b=Lfrdo1Eq8/cBZEavrSPy6KyLnqQVLSPlCD3vhsKqJXTtdNXOrB8Ne6Y3AhN2QvLGtc
         C6Ph5VF8HoW1OYPILotniafYc2jIVBxv6Sufpjy2XQk2nfvwAkd0B9Jss2E+kVok01Hx
         fhS9q4gTO6QJ8Cj2qXEHFyAK1ENGK+PvG73eYxKxopm/7wDZtrMD1kwvA8olMUFr4RcC
         1YJn/XEhCdV7Z318RB7avJXKGHFdhz5Z/NiGdnfqIWG4TPuFZcu44ZF4TZpsMB1qPzpU
         twZT0lI/68T9rQ+6pv/ny7QdjH4UVm9do1N5khiBFTKIkUOWWZIhgUrOMYZm2do5nDrF
         8PYg==
X-Forwarded-Encrypted: i=1; AHgh+RpBgN+4SN0kMzckaI8TNOk60kWHHDgv3jbuiSDgeeNonnMBf3pOXSQnrKjjz8E2iQb8uQ6FcwKjaM0=@vger.kernel.org
X-Gm-Message-State: AOJu0YzQVMSqm4HslWCbLLzf6maa2ADon3E+j7080ZiZT6MZ3WU0R6KF
	HGmvwXfU8f8N/tfdA2td8XZ2Yu+XYcNj4huiiGq50zKR/2Od91phDyas0+w0NO2mmWk=
X-Gm-Gg: AfdE7ckF1t635LVggoPwzVmFi2rA68aIkzLPx8yP/o8mwPhm2qf0EhUoCQyrLS4zOhu
	vZNkjrRuRAxk+R1D+tW57DiTy1jbCoiGL+VCIVf1JgoISzZVl6mzcTbZX78Y0DorCVR5gcZVSXM
	tpq/2ptr2ekUbIEx/3VDmZhy1lF3SFmcqBM6YIHflGEMpjgAknbe5MubtcsTIXewgMXYJoIsekf
	y6w0OHGCBeEw71mLL/Bfz/Bmo6ke9L5KN8/of+XRoUUQFMCTGywPDkFqKy4nUvsOJdPG8nsNyb/
	yBIJlaysC2Eokb8mflhV8BhMKkCxSA9FDZpPQZddvcby4S6lL410Kdefx47C7sCGre65a9XzJxF
	mtFvauJ42lvhFNgu8LVttOLueIJJyVi+SUKjZzia6tdTuVYOnpir5AX4HKQZjCG+LJMQFXwFZ4I
	QZFS1uxTi0Jwl9dSPD3Q==
X-Received: by 2002:a05:6214:4e90:b0:8e5:8d7b:5188 with SMTP id 6a1803df08f44-8f2526fa04emr73202606d6.9.1782906282086;
        Wed, 01 Jul 2026 04:44:42 -0700 (PDT)
Received: from localhost ([146.190.222.192])
        by smtp.gmail.com with UTF8SMTPSA id 6a1803df08f44-8f3611dec91sm19921376d6.29.2026.07.01.04.44.41
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 01 Jul 2026 04:44:41 -0700 (PDT)
From: David Lee <david.lee@trailofbits.com>
To: viro@zeniv.linux.org.uk,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>
Cc: David Lee <david.lee@trailofbits.com>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Jann Horn <jannh@google.com>,
	Dominik 'Disconnect3d' Czarnota <dominik.czarnota@trailofbits.com>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: [PATCH] fhandle: reject detached mounts in capable_wrt_mount()
Date: Wed,  1 Jul 2026 11:44:28 +0000
Message-ID: <20260701114438.24431-1-david.lee@trailofbits.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The recent fhandle RCU fix moved the mount namespace capability check
into capable_wrt_mount(), so a non-NULL mnt_namespace survives the
ns_capable() dereference. The helper still assumes the later
READ_ONCE(mount->mnt_ns) must be non-NULL because may_decode_fh()
checked is_mounted() first.

That assumption is not stable. A detached mount from
open_tree(..., OPEN_TREE_CLONE) can be dissolved on fput while
open_by_handle_at() is between those checks, and umount_tree() can
clear mount->mnt_ns. If the helper observes NULL, it dereferences
mnt_ns->user_ns and panics.

Return false when the RCU read observes a detached mount. This keeps
the relaxed permission path conservative: a mount no longer attached
to a namespace cannot authorize open_by_handle_at() access.

Fixes: 620c266f3949 ("fhandle: relax open_by_handle_at() permission checks")
Cc: stable@vger.kernel.org
Signed-off-by: David Lee <david.lee@trailofbits.com>
Assisted-by: Codex:gpt-5
---
Bug found and triaged by David Lee from Trail of Bits.

Trail of Bits has a minimal PoC that triggers this crash on a custom
kernel build, which can be shared further if needed.

 fs/fhandle.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/fhandle.c b/fs/fhandle.c
index 1ca7eb3a6cb5..f8829231e3d7 100644
--- a/fs/fhandle.c
+++ b/fs/fhandle.c
@@ -295,7 +295,7 @@ static bool capable_wrt_mount(struct mount *mount)
 	 */
 	guard(rcu)();
 	mnt_ns = READ_ONCE(mount->mnt_ns);
-	return ns_capable(mnt_ns->user_ns, CAP_SYS_ADMIN);
+	return mnt_ns && ns_capable(mnt_ns->user_ns, CAP_SYS_ADMIN);
 }
 
 static inline int may_decode_fh(struct handle_to_path_ctx *ctx,
-- 
2.43.0
