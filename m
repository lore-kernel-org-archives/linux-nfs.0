Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D92932E5418
	for <linux-nfs@vger.kernel.org>; Tue, 24 Feb 2026 19:24:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771961094; cv=none; b=e5UlovsVZKN7qpTHiUNUgiznZnZ3TM+JvsJwRDOFkX8kdfOK+aZBw5vlm53pTqy3GvTuhTIjLEap6+f18PnDcAyrmG2XnuC4upuI6OEESZtZIiXTbzjXP0w+g2Cwu5LXPCR3zXa3Eg2ktu8HAXQNbGZhRJnKSPFrF+SqKk/qeWY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771961094; c=relaxed/simple;
	bh=L0M1O+IQpPCjYtFi5eba39+XclJZ/jeswoVOenqUHLc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gIWYXKj8EWseNg/kar4oQ69wBBXPdDlyQJDiw8Bp6wX9rJoPESlj9ytjdrPLkf8QpNUDB6Y2GBQ2V6Jdts2q4Ho0egv2UyecWC84D0HyBK+cONfDUa6SY+PJTbLfwABzEXeDyahRoV0VXVeAYq//+Ftl7sq3DKKWtaG5zHAw5vo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bgSnp6Oz; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bgSnp6Oz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 68736C116D0;
	Tue, 24 Feb 2026 19:24:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771961094;
	bh=L0M1O+IQpPCjYtFi5eba39+XclJZ/jeswoVOenqUHLc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=bgSnp6OzqihQfUiXVtMqScAMZgExmq/IpV3cUofQpIYEsX2gsSetUlKqCX1vmemeq
	 wxgcQCWdLH3jGsQ43zVCTz4s9bPnyce4BZC5YRYi2ZTF0zgtwisB9Emidz+d9djalq
	 S/V6Ub1wu0v/QdLoy6lOIHt2Fn4wXnWBwYHGGkfCKt95/fvJlvy2bBI23mPWq00oa2
	 7zoeRweyBH6EGuI78Wt2dX7iAE4Wi+V4hB4tJb7OPjG3ZDKqiiigODNAKYgpqVSrTq
	 1xoxRyDa3ZMTautVeTpQ+qQcBuXO1QTWQLuVjF4SsvMH01vh5bXCnHOIgUVTmFmQoh
	 +Zbt9yK89AA+Q==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [RFC PATCH v2 11/11] NFSv4: set EXPORT_OP_NFSV4_ACL_PASSTHRU flag
Date: Tue, 24 Feb 2026 14:24:38 -0500
Message-ID: <20260224192438.25351-12-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260224192438.25351-1-snitzer@kernel.org>
References: <20260224192438.25351-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Mike Snitzer <snitzer@hammerspace.com>

NFSv4 implements both .setacl and .getacl and so it is appropriate to
enable nfs4_acl passthru.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/export.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index 6623eb13f4e6..f59839b48721 100644
--- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -182,5 +182,6 @@ const struct export_operations nfs_export_ops = {
 		 EXPORT_OP_REMOTE_FS		|
 		 EXPORT_OP_NOATOMIC_ATTR	|
 		 EXPORT_OP_FLUSH_ON_CLOSE	|
-		 EXPORT_OP_NOLOCKS,
+		 EXPORT_OP_NOLOCKS              |
+		 EXPORT_OP_NFSV4_ACL_PASSTHRU,
 };
-- 
2.44.0

