Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56F16224B13
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 14:00:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787061639; cv=none; b=RPZRL0tuRPzWmV8KKTnBRmJ6JIILZLE8g5Mpu96/el0HIlNdIewpW4UI6EXfmSop0kYNr1wogpTJFFdD2VdFTecMD4YUqBQCOd9TzPc38zGM5LKYfcwchC6oer/ZzRyynNPo/29XI8VXdK+3SqShz3pcJJ9blDusnFeMvldNcWU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787061639; c=relaxed/simple;
	bh=YDdoA+VaKBgUGyfQ4uqxQ5A8Wkdib36d7dUf4SGL/do=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ox0wTRR640mLziPxoi8AFUDjKCRfnNjurzopo7CUQXUneuQLkmi83pPqPDeNOfHcU/Jbtp86rsiGSSTljTqBLpzL9OBsJUjXiQXCtpN/qSmO+Vyc001oQNpq8Vcxe+ApvY/tEVG479EoleCGzVgppSTDgNmsKN38Who62wdS6nc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RjjnE9aU; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RjjnE9aU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8F15E1F00A3E;
	Tue, 18 Aug 2026 14:00:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787061638;
	bh=yVp2RbzEW2aVnIp2HQtJhQOVNQkcK6awwLHQvsYhFLk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RjjnE9aUG67bGTnM8nJ25m8sCEj043hvK7A0/F/DlTzSnk4J2t/4rgQBfjvYDks0g
	 9Kk83kLGXNYK9I6/aRVcX9UCsYq8EAHNKxeuvuZGFtIUiQEn9FgwHKooC83bBqKPDX
	 7rUT+oc/2DE+HuYCj5+J74CQCXc0XNpAaiNza/fPfbXOvjVD2dmPV9vYAwPrQIPob0
	 JbndxtGG68tepJ/t1hQhU6T5C6xy7llhfDmAHbIB7s7Af347P0ginGAq+1AjU/sLlr
	 fmERD5y0Ffn1ffc1KRZP5f6SD59E7SRJtCQekGKF0liT9T1hocJ6shfwvoLCw6uFYW
	 C7lfwdTjA+Z9w==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] NFSD: Include <linux/nfs_fh.h> where struct nfs_fh is used
Date: Tue, 18 Aug 2026 10:00:34 -0400
Message-ID: <20260818140035.12740-2-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260818140035.12740-1-cel@kernel.org>
References: <20260818140035.12740-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

struct nfsd4_copy embeds a struct nfs_fh, and nlm_fopen() reads the
size and data fields of one. Neither fs/nfsd/xdr4.h nor
fs/nfsd/lockd.c includes the header that defines the type; both
reach it by way of nfsd.h, which pulls in <linux/nfs.h>.

Add the direct include to both files, so nfsd.h can later drop the
<linux/nfs.h> it carries for no use of its own.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/lockd.c | 1 +
 fs/nfsd/xdr4.h  | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
index 5ec0f5456063..f24e45dc37a0 100644
--- a/fs/nfsd/lockd.c
+++ b/fs/nfsd/lockd.c
@@ -9,6 +9,7 @@
 
 #include <linux/file.h>
 #include <linux/lockd/bind.h>
+#include <linux/nfs_fh.h>
 #include "nfsd.h"
 #include "nfserr.h"
 #include "vfs.h"
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 7bbb375874ef..b841bc462dac 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -37,6 +37,8 @@
 #ifndef _LINUX_NFSD_XDR4_H
 #define _LINUX_NFSD_XDR4_H
 
+#include <linux/nfs_fh.h>
+
 #include "state.h"
 #include "vfs.h"
 
-- 
2.54.0

