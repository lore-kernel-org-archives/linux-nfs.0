Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 434953A8740
	for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2026 17:41:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786902118; cv=none; b=EmT11FBWSCQLRWRJpBbmlDQlzhj7fHXg/UdyTbjw6cZI1G79tnFQ+sTicae6T0OSDLShS0R1LBTvnX+ZWmg04MuCU1Y9ZgYwKe3ZC82Rj3rLXdv6i/vP0wmLMMS17ZJuGaN1qNxZXAr/C51NX7/pdxNpCmdO+8UMDg+mu4oqpmM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786902118; c=relaxed/simple;
	bh=zCcbkjJgDUK+d3Jt+QgNBFNQ+aDZLScvaxV3AxudI+E=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Qh3fKDHkS7JXQ9en6UD9FMLpB18RaBF8SnQRP5S0a0Io4LCkHusYQrJhZcRCNdDRIpcyUFaI0DcdfstzeB5nNnBOlMQ09rThF1hnlUy9OBjcI9cInXF1ts3j/9y2iRjtNgeqaQ07YukaWgQHZiZxSIHtagRa7lsZ639d2PmoMrQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Omob97V+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Omob97V+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6ACE31F000E9;
	Sun, 16 Aug 2026 17:41:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786902117;
	bh=Fn50s3qeOPaGirGpQXJw6dqRPL8EOHGZV4p8BcXrMzM=;
	h=From:To:Cc:Subject:Date;
	b=Omob97V++0L6wccXO94MC57O7csJe6A2jm1gUfCW/V7CED5LeLEfNlOJE59O4ui5T
	 9UuSGz5d7+ipVjjFTKK9+R7wUSKC8D4y8H4CvMj4t8rcKqxZLXqVwCsVnIgQLGamsZ
	 2D+JPCtC7h+QN4PCm+c602Q7wKb8CeKBhffR6Uhl280iokEdUJNVt1BLvgureqWQpb
	 Hb1CwXlLF4LoYCo78/MnIpgbtSHxoxFufw68SRPY77oT2ZSUDEVPLsqJNSJnCXfhRz
	 UwdtOttNnYx/ecZYWzezqTI7ck0nIW6dzQcmfrsMrsbFL+8fESYAOPR9JpmrqaO1+y
	 3RFyd2FPL5n8Q==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	David Laight <david.laight.linux@gmail.com>
Subject: [PATCH v1] NFSD: Fail a pool_threads read whose reply does not fit
Date: Sun, 16 Aug 2026 13:41:54 -0400
Message-ID: <20260816174154.1442685-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The reply to a pool_threads read is the list of per-pool thread counts,
formatted into a buffer of SIMPLE_TRANSACTION_LIMIT bytes. snprintf()
truncates its last write and strlen() measures only what fit, so a reply
too long for that buffer ends mid-number with no terminating newline. A
pool running 4096 threads is reported as 40. Nothing marks the reply as
incomplete, so an administrator reads a plausible but wrong count.

Take snprintf()'s return value, which reports the truncation strlen()
cannot see, and fail the read with -ENAMETOOLONG when the list does
not fit. That is the errno svc_one_xprt_name() already returns for the
same condition.

Suggested-by: David Laight <david.laight.linux@gmail.com>
Fixes: eed2965af1ba ("[PATCH] knfsd: allow admin to set nthreads per node")
Link: https://patch.msgid.link/20260812193349.13347-1-david.laight.linux@gmail.com
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsctl.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 4e5e083d8477..f9fd6df57b79 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -479,7 +479,7 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 	char *mesg = buf;
 	int i;
 	int rv;
-	int len;
+	size_t len;
 	int npools;
 	int *nthreads;
 	struct net *net = netns(file);
@@ -533,9 +533,13 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 
 	mesg = buf;
 	size = SIMPLE_TRANSACTION_LIMIT;
-	for (i = 0; i < npools && size > 0; i++) {
-		snprintf(mesg, size, "%d%c", nthreads[i], (i == npools-1 ? '\n' : ' '));
-		len = strlen(mesg);
+	for (i = 0; i < npools; i++) {
+		len = snprintf(mesg, size, "%d%c", nthreads[i],
+			       (i == npools - 1 ? '\n' : ' '));
+		if (len >= size) {
+			rv = -ENAMETOOLONG;
+			goto out_free;
+		}
 		size -= len;
 		mesg += len;
 	}
-- 
2.54.0

