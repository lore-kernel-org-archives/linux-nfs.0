Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F34453D7D86
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 13:14:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789391677; cv=none; b=mnibcPFbdK77NeNFOHIhOXyppR+4li2y1fGqNfogNpy471zibXCiOgQxNr98idoWCVZKDhfXQX0+6y0aDAXXHVTFSS2mtUJOqqE86YoaZnpjLQyxSfXglur3WXiFndtW270QAl54CSQ7vHptHH4do1sLcWAnW4dpAfsgtK9NfbY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789391677; c=relaxed/simple;
	bh=WzMMz7RUefxyolD+IUc9iY91At6SJ1VgiPYTNJpWIlY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ojHznuTN6JUvjpQ6oQE8zpwGEHkr6sfDp83+x4P8Qwi5K4f1YB/frtJpGO4jjWN6uWDyozekRQ5/i7zXGST2ymZlfjlNcWrB69ZA5tlIoxOmQT8PkDC+JYV6XFFrwbXNlcVZ1tpuImmj3ktAdQab7WKOdmxg5gyvkE1bFxziol8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=k7ljE1YV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="k7ljE1YV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 542D11F00893;
	Mon, 14 Sep 2026 13:14:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789391675;
	bh=kpsQpFSRtuqt57stfKhxJcadUEclx4dsUVby2zPTGiE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=k7ljE1YVzynyV+Emd+HA/3wHauGH/iXNyiOEG4bmF31F2XdNxchqEwPpxOdIyrfpC
	 W33QAQP842fc/gKaghNgWn314BioUUKyqPZrqHZ+pEp+veUjS+NTJ1uFuhZHkKWjVe
	 bNOsW5nz+Sy+djJr1kueUjJN71bslWSKCKbKkW3eohI/jaE8gNF8bDfsSEtmUn5NnT
	 BNtUJQKHbfT2P1yCcUKj7TGWCOKvC2KllpAcFFw2X36r3aCrW3osjbX+fBST7HF6b3
	 SDwXd1aUnkZtbfiUdnnf44zYUztfJqWRkpz+maPG2ahsqptbNcTLyja8QsSxiM0gm1
	 HtACSoNqoleRg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 09:14:19 -0400
Subject: [PATCH nfs-utils v3 10/11] mountd: bound the retry queues
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nl-crossmnt-v3-10-a984a6c94829@kernel.org>
References: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
In-Reply-To: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4953; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=WzMMz7RUefxyolD+IUc9iY91At6SJ1VgiPYTNJpWIlY=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqp/M0fAQtGXkX9aSCny+oekLZPCb/ZL1S/+phC
 ZDxSKKxeWOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqfzNAAKCRAADmhBGVaC
 FaUsEACnvA8edBuO0BzASzCA2p8AqnRZ8vSdfoMY7GszRVvfwST9EitBlqTmldofU782+EBJ4u7
 9kOBpqI6zbrihczwW9WD3D6y/hDeJJvFxHkme9fJbEv915JEgenOUnlPYSL27Z3Z83dk4JfdUO6
 pLwGYtgXutsU1zlTP/Q6w271guav0seE0EHCXElwerlcEA0vYlOVbsh+FrECnY72FX5BEEe0VKR
 sk9jIni6nRd54wTzV8kxwNWBB7/Q/2jdBwflbyL4jOMshNTsZAVEO7/xi887+ZE/wCV4dB8YO68
 DQ4dH3llEAB/F/xQDDcL80EToJFzOAv4Wd2IWe+ahg/KVaVJHJuzYNXxal31EZycTkBOIMZXc4b
 ZG1BqUTNySj+Ur0yFzMZAnjCJjzAXeHCRCZNZFSe+pEMLs/cs3o5sNWKo5Wcyukmkdb9XcN1k+2
 llduRRVGkofkLyNfhO+AzzFVfiqknz2xWbuqWGsrWYK2jUHCPEtufg/cRH+OROHicyBgGZtP4oj
 2aOcpnU1LafytErdGDSrFxQ3iPbtu7RAmhmh3OgpbIWsSv60AQr0rWaw+5pFEL9sKMPW90VeCQH
 ZrDnVY28zFvPM43owTr7su0T+DQVVOJeS9brujtWvuAX8WKuHAuU9YivGUrNYc22w99zsS/9wD8
 chmQBSChtJywU5g==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A request is deferred when we cannot yet say whether its path or fsid is
exportable.  lookup_fsid() defers on "!found && dev_missing", and
dev_missing counts any export whose "mountpoint" is not mounted, whatever
fsid was asked for.  The fsid comes out of the filehandle the client sent,
so on a server with one unmounted mountpoint= export - the case this retry
logic exists for - every fsid a client invents gets a queue entry.

None of the three queues has a limit.  The pre-existing "delayed" queue
nfsd_fh() feeds is the worst: it strndup()s the whole upcall message and
does not deduplicate at all, so even a repeated fsid allocates again.
delayed_export and delayed_expkey dedup, but still grow without end, and
the dedup walk makes each insertion O(n).

Cap all three at MAX_DELAYED and drop the new request once full.  Queuing
is only an optimisation: the kernel repeats the upcall when the client
retries, so a dropped deferral costs latency, not correctness - the same
trade the existing allocation-failure paths already make.

The cap applies only where a record is created.  nfsd_retry_fh(),
nl_retry_export() and nl_retry_expkey() re-queue a record they already
dequeued and own, and must not be refused.

nfsd_fh() had no dedup walk, so it gets a counting one; it ends at the tail
the append needs anyway.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: LLM
---
 support/export/cache.c | 57 +++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 52 insertions(+), 5 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index 6c887cd50327..d1fef23a6c0f 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -777,6 +777,38 @@ static struct addrinfo *lookup_client_addr(char *dom)
 }
 
 #define RETRY_SEC 120
+
+/*
+ * Cap on each retry queue.  A request is deferred when we cannot yet say
+ * whether its path or fsid is exportable, and the client picks the fsid out of
+ * the filehandle it sends, so the queues are reachable from the network: any
+ * export with an unmounted "mountpoint" makes lookup_fsid() defer every fsid it
+ * cannot match, invented ones included.  Queuing is only an optimisation - the
+ * kernel repeats the upcall when the client retries - so refusing to grow past
+ * this costs latency, not correctness.
+ */
+#define MAX_DELAYED 1024
+
+/*
+ * Has the queue holding @count entries hit the cap?  Warns once when it fills,
+ * and arms the warning again only once it has properly drained, so a queue
+ * sitting at the limit does not turn into a stream of log messages.
+ */
+static bool delayed_is_full(unsigned int count, bool *warned, const char *what)
+{
+	if (count < MAX_DELAYED / 2)
+		*warned = false;
+	if (count < MAX_DELAYED)
+		return false;
+
+	if (!*warned) {
+		*warned = true;
+		xlog(L_WARNING, "%s retry queue is full (%u), dropping requests;"
+		     " the kernel will ask again", what, MAX_DELAYED);
+	}
+	return true;
+}
+
 struct delayed {
 	char *message;
 	time_t last_attempt;
@@ -1008,8 +1040,10 @@ out:
 
 static void nfsd_fh(int f)
 {
+	static bool queue_full_warned;
 	struct delayed *d, **dp;
 	char inbuf[RPC_CHAN_BUF_SIZE];
+	unsigned int count = 0;
 	int blen;
 
 	blen = cache_read(f, inbuf, sizeof(inbuf));
@@ -1029,6 +1063,11 @@ static void nfsd_fh(int f)
 	 * We cannot tell the kernel to retry, so we have to
 	 * retry ourselves.
 	 */
+	for (dp = &delayed; *dp; dp = &(*dp)->next)
+		count++;
+	if (delayed_is_full(count, &queue_full_warned, "filehandle"))
+		return;
+
 	d = malloc(sizeof(*d));
 
 	if (!d)
@@ -1041,9 +1080,7 @@ static void nfsd_fh(int f)
 	d->f = f;
 	d->last_attempt = time(NULL);
 	d->next = NULL;
-	dp = &delayed;
-	while (*dp)
-		dp = &(*dp)->next;
+	/* the count above left dp at the tail */
 	*dp = d;
 }
 
@@ -2072,12 +2109,17 @@ static void delayed_export_remove(char *dom, char *path)
 
 static void nl_delay_export(char *dom, char *path)
 {
+	static bool queue_full_warned;
+	unsigned int count = 0;
 	struct delayed_export *d;
 
-	for (d = delayed_export; d; d = d->next)
+	for (d = delayed_export; d; d = d->next, count++)
 		if (!strcmp(d->client, dom) && !strcmp(d->path, path))
 			return;
 
+	if (delayed_is_full(count, &queue_full_warned, "export"))
+		return;
+
 	d = calloc(1, sizeof(*d));
 	if (!d)
 		return;
@@ -2428,12 +2470,17 @@ static void delayed_expkey_remove(struct expkey_req *req)
 
 static void nl_delay_expkey(struct expkey_req *req)
 {
+	static bool queue_full_warned;
+	unsigned int count = 0;
 	struct delayed_expkey *d;
 
-	for (d = delayed_expkey; d; d = d->next)
+	for (d = delayed_expkey; d; d = d->next, count++)
 		if (delayed_expkey_matches(d, req))
 			return;
 
+	if (delayed_is_full(count, &queue_full_warned, "fsid"))
+		return;
+
 	d = calloc(1, sizeof(*d));
 	if (!d)
 		return;

-- 
2.55.0

