Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7DEA92475CB
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2026 19:31:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783884688; cv=none; b=TYDoPznb7PrVjXtjz3suOLDcYIrnrd/syGHgo6T8dKYG+KTbEgNlmkJt7krlv+wIwp/QWv9tfhVprYJaL+2wrUskuHDoeJzrCreAtBWAa6bfKnYESFMEdWauQ/fCzg/PZm2R0zEUwlyWOCXH1gZsaAOMQpWWMSWZrxyySWSVC2M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783884688; c=relaxed/simple;
	bh=y0UzX9qyPwfd/tjGCP1WHd8VoypPhcGmA0ohJOjzQMM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TSXCA0kKjq+hO22710/3Tev+/h42Eb3JB8QcNkmv4/aYd+kIqaz7JP6JFxeeNYpYRx4T5xL4JOy+yb9tWL6DL7X/0F0vdvCOjhyPF7KvA48ZMDmYK0026o6jR/2BdOBtc5D4kg1gHSd4R4E2G57z5uQlWuEXA9aa5QqOsB7zVNI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kYUFaKOo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kYUFaKOo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BD06F1F00A3D;
	Sun, 12 Jul 2026 19:31:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783884687;
	bh=wzWc7RY+DyoMJLQ8qg5ERujVxs9rQ62rjDj9W/Ftg/Y=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=kYUFaKOo+/J9kMTcp4aLpFoPDxsOeFauHKc9y/MgDPmZVjv3j834+OVE0frQFo8eo
	 HKARbKb3tOGLvJ87c9S25Pc/HBft0leSo/ASw3+Fh91sboXjTG28ec3gcxdhMm4YXW
	 ehm8e/p7YhqmFgG6ROsBY5Attmw4BJ754s+4cdxiElpu9JMHkc/GbX3mWVTC/hBA1m
	 UBLhMNlCNof7N0ahKg0dKxpwtdZ3utE3Ut50f3bq4UuaOyGp5K7AHUCF5kVaQjci/J
	 FhAdWNY8IX/KddcK2jTf20ZYEo25pCPfHNAGZah8fTfZ1cXqJ3xyaMXIIYb83Gl9YI
	 lNTve8A3XBrmA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/5] xdrgen: Add XDR width macros for short integer types
Date: Sun, 12 Jul 2026 15:31:21 -0400
Message-ID: <20260712193122.116845-5-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260712193122.116845-1-cel@kernel.org>
References: <20260712193122.116845-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Commit ae78eb497868 ("xdrgen: Implement short (16-bit) integer
types") taught the generator to emit XDR_short and
XDR_unsigned_short in the computed maxsize macros and added the
matching encode and decode primitives to _builtins.h, but it left
the two width macros themselves undefined in _defs.h.

Define XDR_short and XDR_unsigned_short, each one XDR unit wide, to
match the width the generator's maxsize table assigns them.

Fixes: ae78eb497868 ("xdrgen: Implement short (16-bit) integer types")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/xdrgen/_defs.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/sunrpc/xdrgen/_defs.h b/include/linux/sunrpc/xdrgen/_defs.h
index 20c7270aa64d..8f3776ef3229 100644
--- a/include/linux/sunrpc/xdrgen/_defs.h
+++ b/include/linux/sunrpc/xdrgen/_defs.h
@@ -25,6 +25,8 @@ typedef struct {
 
 #define XDR_void		(0)
 #define XDR_bool		(1)
+#define XDR_short		(1)
+#define XDR_unsigned_short	(1)
 #define XDR_int			(1)
 #define XDR_unsigned_int	(1)
 #define XDR_long		(1)
-- 
2.54.0

