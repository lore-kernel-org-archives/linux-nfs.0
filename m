Received: from flow-a7-smtp.messagingengine.com (flow-a7-smtp.messagingengine.com [103.168.172.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 78F923B388A;
	Mon, 29 Jun 2026 06:59:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782716398; cv=none; b=imc0IdnDILMuA+0pFDpBCMy5b2GjI4XTMI4KSFec028QDeDbsPkY6D6fwEgKRa3ZLDSlU3SLXgz8x8z8pGnFCaPujZkYypToGxCETHCpc6IyQhjEJNc/hm2mFmsOkEdkJZF0Gj1vWmRLVxs/UTQFfilJPDMh8hVt8gYEp6xpkyE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782716398; c=relaxed/simple;
	bh=6qzG+s+o0ntSMLj3f0AMOalFGqBsSo63rEgrfvI/OqQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jgyErqX5dW5y8lKS2IqgC4bKClViHVDRV1GCcKzfrhhzE4VLJtt0/jcbycnwHCgB5/ODTjKZSEB1lfNNWmjdi1p3XGn5nkZxTBTVfZ6ZaJnY40j7eeP2b15rDuQs2PWIOla2QsOqmanKn4CIrbzZwlkDptV2QzOdVl9T4VW7QFo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=Obsidian.Systems; spf=fail smtp.mailfrom=Obsidian.Systems; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=HvjgLc9t; arc=none smtp.client-ip=103.168.172.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=Obsidian.Systems
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=Obsidian.Systems
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="HvjgLc9t"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailflow.phl.internal (Postfix) with ESMTP id C743913801A0;
	Mon, 29 Jun 2026 02:59:56 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Mon, 29 Jun 2026 02:59:56 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1782716396; x=1782723596; bh=O
	dOkzuKr6PMGP0Swb+3TBhVRv/cseWllGDt56sDblRs=; b=HvjgLc9t3YyxCa4ow
	ky52JhgHPeriumxhHt8q6kcpfaWO9XKn122fSgobz8Fx4DjCp/tT/4/CJEcUvJCz
	yqHgpd7xDZGMnPcKH8m48tqvnqd/SQFcpcmcpvQmAaraS4tbcZ9LVB0TC9Wn8Cum
	QnOG32skVZNbCRu0EvSBUT7Fr3aae6r0vsLFC0rAbYeZ8uLZqwZG2yWpXU3KV4sT
	MBLFlKNgU+5JKOiak7cGLO3rKYHFWKCdJlm41ujEZHF5z1375pUvU8Y69EX29zZ2
	R60EoZjqOvrp4g7oH/gipnqvs4WP/INR+oG2ap6FaYHLJzsl6oIHDZ+ena8eGiXQ
	Y1PNA==
X-ME-Sender: <xms:7BdCak_wuhvrZWx21VNQGeJeuzjiFYtQgeNw3YAYuseM_cF5x7CvGw>
    <xme:7BdCavWKSGGdsYA00MhsvQ9Jbn-6KtrmmUIzP8XbJYZxtUK2M2fYJvABDRuBbFuEH
    dKXQD9yseTgiUYuqldmciCSm6enOlYsIhYATeUIDshbUwyBYwfZJGM>
X-ME-Received: <xmr:7BdCapj2sIJY4U8eI2AXIpMp-3WWEcQGcYzfsgEdi_5lIPvUx5Wl5-PzCOHKhGoq6kZ3ynlvhrQqgQrh6fH5I5eeB_REQ_HTmEkFTg>
X-ME-Proxy-Cause: dmFkZTFXRXqXXHQig7aOEXscQpb861yO5R1n/JZ6/neobiLJxdwcQzvLtKpg3rAKseaAOK
    QsJhQwi62/No698HcwnilN3sG7YXlAfqWy/lDrcLEbeiS6jMSOcpT8xMw4CYYBtDSPh9ua
    fbkHZ4sq8c9RILgSHAvyMaHp4hjTZcdv0ZCaXt3xRyvWX2TfrkxRsebc3IizW4gRw8G5PK
    egy7dn1PuCGj8lbOqc95xmreGYhBGeCRsZ8NvMQ3TGqmgXLN4na69GZ07y8Q5aNxwOSqVq
    phXG20pRAzX8AuKD1hIURFKnXT3/UUySz0y1LRBFEWGzEXoNvnA32P6m9f2FXjRHKlHnr/
    zWYb3y4oIArybB1B6dKf5EZT9gG4pXqx8qAtOT6OkrlP4d40o72eIvDP6NvR0sp1XjsgUb
    9AgebZ+ED5ZSb5HIlRcCUZWXWpo+SvWI/xu08Ai6fZP51goYJgSchB48NX3dt0BhAx/A/G
    NVzQIIiqroByFKkdSv7bHbZiQ8OjMCiUrvXBQi75M7Ge2lgm8fRqmF7k0pmuAJymrBhFRJ
    iDsMOFEduArHeOQqBqzSGb3YkpYRwSqxQwic95jXUrvnIICJWRMt8qKayX9DvzauKEiuo2
    IaipwU+ZfJjAk0qzW3cDwjlDuQYqn6IdfFN3qLY/JsJdBDb9kD7/POtIDHJA
X-ME-Proxy: <xmx:7BdCalyCi3bFm0sipMMoR9dgxkruyI4uCGTAeslIddje3ODzPihr5g>
    <xmx:7BdCanpPx6jj-a5Mh2pwZWmE2Rn4imia49U6ehlBgla0KJKfbuuQJw>
    <xmx:7BdCaol0T_gS5Y_NelxguUGHVmOTjiHCTb7FGb6YpJJmVhmZkJSvng>
    <xmx:7BdCaqpflORfKOWzwSYhzKo57-Yb26o9mveikzD7FcD4_o_eVQ_0LA>
    <xmx:7BdCas3bMn6sxD1z4DrX373wpl6HY2BI2yUmUxN5vcssHQUyYDHtp4kc>
Feedback-ID: i91b946ab:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 29 Jun 2026 02:59:55 -0400 (EDT)
From: John Ericson <John.Ericson@Obsidian.Systems>
To: "Andy Lutomirski" <luto@kernel.org>,	"Al Viro" <viro@zeniv.linux.org.uk>,
	"Christian Brauner" <brauner@kernel.org>,	"Jan Kara" <jack@suse.cz>,
	"David Howells" <dhowells@redhat.com>,	"Chuck Lever" <cel@kernel.org>,
	"Jeff Layton" <jlayton@kernel.org>,
	"Shuah Khan" <skhan@linuxfoundation.org>,
	"David Laight" <david.laight.linux@gmail.com>,
	"H. Peter Anvin" <hpa@zytor.com>,	"Li Chen" <me@linux.beauty>,
	"Cong Wang" <cwang@multikernel.io>,	"Arnd Bergmann" <arnd@arndb.de>,
	"Thomas Gleixner" <tglx@kernel.org>,	"Ingo Molnar" <mingo@redhat.com>,
	"Borislav Petkov" <bp@alien8.de>,
	"Dave Hansen" <dave.hansen@linux.intel.com>,
	"Jonathan Corbet" <corbet@lwn.net>,	"Kees Cook" <kees@kernel.org>,
	"Sergei Zimmerman" <sergei@zimmerman.foo>,
	"Farid Zakaria" <farid.m.zakaria@gmail.com>,
	linux-arch <linux-arch@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-api <linux-api@vger.kernel.org>,	netfs <netfs@lists.linux.dev>,
	linux-nfs <linux-nfs@vger.kernel.org>
Cc: John Ericson <mail@JohnEricson.me>
Subject: [RFC PATCH 1/3] fs: Add documentation to some `struct fs_struct` fields
Date: Mon, 29 Jun 2026 02:58:20 -0400
Message-ID: <20260629065934.1425479-2-John.Ericson@Obsidian.Systems>
X-Mailer: git-send-email 2.51.2
In-Reply-To: <20260629065934.1425479-1-John.Ericson@Obsidian.Systems>
References: <20260629065934.1425479-1-John.Ericson@Obsidian.Systems>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: John Ericson <mail@JohnEricson.me>

This will be expanded upon in the next commit.

Link: https://lore.kernel.org/all/a49ce818-f38d-41b0-bbf7-80b8aad998b1@app.fastmail.com/
Signed-off-by: John Ericson <mail@JohnEricson.me>
---
 include/linux/fs_struct.h | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/linux/fs_struct.h b/include/linux/fs_struct.h
index 0070764b790a..b5db5de9eb01 100644
--- a/include/linux/fs_struct.h
+++ b/include/linux/fs_struct.h
@@ -12,7 +12,21 @@ struct fs_struct {
 	seqlock_t seq;
 	int umask;
 	int in_exec;
-	struct path root, pwd;
+
+	/*
+	 * The root directory for the task(s) that points to this
+	 * `fs_struct`. The root directory also controls how `..`
+	 * resolve; path traversal is not allowed to resolve upwards
+	 * beyond the root directory. (It is for this latter reason that
+	 * `chroot` is a privileged operation.)
+	 */
+	struct path root;
+
+	/*
+	 * The current working directory for the task(s) that points to
+	 * this `fs_struct`.
+	 */
+	struct path pwd;
 } __randomize_layout;
 
 extern struct kmem_cache *fs_cachep;
-- 
2.51.2

