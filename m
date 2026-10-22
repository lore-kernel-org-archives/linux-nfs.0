Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677226;
	b=1uJdW9aMcmt8pZhmxXaltIGaHGLRIU9n7aWqMr1fwR9rhGVubxOb5MS8vW2IuOBBlTn/
	 W25SmJUEE6REJWk5u4j+7VFhaiAStwrk0/CjWHQfiewVFFwHmxf1sR/MErfWFqsJwdEqf
	 qaULSf+L+6O2GOY4KKhRF361zo2NEphYZOlN8lMzY8LcG5eiu8y9baGxqDjIjeQO5lW7d
	 C293AcrKhWLx4Y2ILFqB2tmxZw4wo80uXWCp5on+/p+0rSB8KGSlOtiaAF1wOWI5HLkzr
	 kz6Q39HxlJYTbMKWzYL0vJBnrJntaa/2ZC+qKKqU/Bb+4Tcmt3EZAlaLkQRAn/e7csg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677226;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=gIF8zch8MPVziojIko+8Qs/AXGzli7sHF9pR93t/eq8=;
	b=d5SusaO8PgHPbm2CrtyEhpi4b+Gh5UZly6r9IvqNylSD8tDi1MANEV2xsBV3WSeR3LCk
	 SfFYBHRxxE0d/Y91SOTU1QZLiXixfHw9fR2jhhxDaNKoPznwbBaZ3ramVcdCbnCwm1RV/
	 EGx8TT6mjHC0NopH8+sdBMR+Xt0LW8agnbiJRvOK0NXNoRFjw4o+zEd1Ii+CjP6wfvZ2l
	 44TyGxB3+5RIU3Bt1lnQhQNxomt21QeoTetzzueD7yWNPNmi8RMf044tHCcoCasY/oVEe
	 +Sf2GViAZIaN3xrZnT7kJoaioc3BCcImAiQQxeDomhq1mVI5gVVTK4IS0d5L57YyJig==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UEOpJgEJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C104B60A262F
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UEOpJgEJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1280D1F000C2;
	Thu, 22 Oct 2026 13:53:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677225;
	bh=gIF8zch8MPVziojIko+8Qs/AXGzli7sHF9pR93t/eq8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=UEOpJgEJXFlbvwzy+R1ua8u62vGmCz6f3jmZJBiiWna3hWvatW6fqmw7e4XVW+eMF
	 wthl+MldUwgq2O8/anC8qqW7eXiQ7wUkVeALCv05tdpHPb6ZS+lGK/CY+Ek9AJGFSv
	 jDO9UNrv4iPWK9TaU7CZfFnxu/gieMTxwwDD6vqzrwLZwx0AmN0H6Tq2e2mc7n7DkX
	 5TSMJ+zZq0bzxx3CHrXPoFSgvC2Bc8lOCxz/ZR+zprTAWDm201pM4vXB21DpRWb9Sf
	 eU3iB88WLT4sP/lo5oeB+BlSKneUS5p+CKvkFo6dhkuECTrq2njUQQEUgfLiyojy2y
	 Hlqw5HtQZHQNA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 04/17] NFSD: Remove the unused NFSACL_MAXWORDS macro
Date: Thu, 22 Oct 2026 09:53:28 -0400
Message-ID: <20261022135341.14265-5-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261022135341.14265-1-cel@kernel.org>
References: <20261022135341.14265-1-cel@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Commit a257cdd0e217 ("[PATCH] NFSD: Add server support for NFSv3
ACLs.") introduced NFSACL_MAXWORDS, but no code has ever referenced
the macro. Remove it.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/nfsacl.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
index 7d7709a0a56e..fc00280e67b1 100644
--- a/include/linux/nfsacl.h
+++ b/include/linux/nfsacl.h
@@ -15,7 +15,6 @@
 /* Maximum number of ACL entries over NFS */
 #define NFS_ACL_MAX_ENTRIES	1024
 
-#define NFSACL_MAXWORDS		(2*(2+3*NFS_ACL_MAX_ENTRIES))
 #define NFSACL_MAXPAGES		((2*(8+12*NFS_ACL_MAX_ENTRIES) + PAGE_SIZE-1) \
 				 >> PAGE_SHIFT)
 
-- 
2.56.0

