Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E73624A3F21
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 16:25:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789143949; cv=none; b=W6QzKgEQ11byz2TpkCAJ6mMqpJ8aFIsAh/jmdQwM8aOumlCn1zMa0g+ZGvc8uo9qdkj7w0APYbzMIms9+0EUwTYh0kxWeXA/fAGmWOYNAwYkZPP5BfmbhGn8PgFLJr4WXmEvip6FaWDFd/RklckArTb18u+PTbnjFFlciija4qg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789143949; c=relaxed/simple;
	bh=R+FiQL4VwraRuKeJ3+xVxROFTa6pTqaJ9H3b7qdLbhY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=BDJHRb8yv0BvjYG4xWxveiaAIMmdGiQlkUj9QcZ8KWeD4nbbOSl5wk4ZKHW4fE8e45aAdbFAAafX/sraSGKTboJ9nUhbNRXXu6fbc6G7TjDQyE28OYoy5MdgzGYrvJl9e9uyXmDLSTRxl7xltOfqeh81oTd9eI806muYkwKd0N0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OyLRDrpD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OyLRDrpD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 72EB21F000FF;
	Fri, 11 Sep 2026 16:25:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789143947;
	bh=WFeEVYW5TMtjOoPbKk9yJV03+nbeBZ88khCQ3JgrB/E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OyLRDrpDsMLZ2LLI/JFPbB8sSfZ0tIGqoASRsqC28C9qIAlq4RkWYnVWLKSBp1YoA
	 oH83uIHpb/AGme/Pm8TXO4oqLgohpnz+W2JVoPgOpnung4zZD4GOANJ5+HczBs8Rui
	 3Kn872y2UoLqQsoPfnxlbTI31B9o9P6yhPcFK+maQgn8Lf2EGMHnQXT1983wPbz1Cc
	 tlfbHm7atV7IgP2UkHsTi9ge80lOPRnfAOnv8qtZIpDC6XAG5FjHChmDpXPIW+OFr8
	 zXRz/XY0EDg8Yb7iP8KmCzIPF9SRDtOHqvddRisAgFP++pc6bN9WXFoCXkMu+I31NQ
	 Vu50fQkSQOwIg==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 11 Sep 2026 12:25:35 -0400
Subject: [PATCH nfs-utils v2 10/10] mountd: bound the retry queues
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260911-nl-crossmnt-v2-10-f4d869951c5e@kernel.org>
References: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
In-Reply-To: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4953; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=R+FiQL4VwraRuKeJ3+xVxROFTa6pTqaJ9H3b7qdLbhY=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqpCuEEiY1LmdTz/ErLfsfJTSl9ma2MoSkrn8rF
 T4zK5T53mOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqQrhAAKCRAADmhBGVaC
 FQoND/9yCHN6FxHpxIrs8s2FTWWLOVCPiRrh9l3FASNe5MBRvpvndGBWX86oPt94ETmN/sUL3KN
 1syHZ33VqnLh+b5v4C0q/t3NR1OE1wH6Lrcn220CUJ5biphGNBlJaFmIjS+5a4CTx+zz+Yf7HRh
 78PrQVF3eV8LmHlW4MDB3najURTHAsXdZK2eaH1qywlgGCEqOEAapeNXC+y9r+oW6zwxirU13Ma
 zSyQAcQX3wW/JJ9H2lbncD+UPcyJ3bExcNQwCLGWC7X3h6Rlj7jxk8MVYTUgwKLB6LX9zkdJrra
 gMP4b/ObQapi8QxPzHwO4IHA3CDUvqlDpkphubA8ZADMe5MMzDdAQ6dxG6gJEe7KhLmucMrTi3x
 iGJSXOxZBp02ypqhT8IL6KZvYvgxJzHwRVdlZMuJ08T1Kwnt2YavHepTR+LUS3FjE7udMwOU7QB
 Dz1JrLfylah+LP6avz5NABmB4f36wPNunmrnQyCbIBwpLPD/uxM+iC/2cq5qsxKLF1oWDS/PRyP
 SO7Vi25t7vnhrzhmJk1lWEEYbqHhuol+9754pb2bklcUBxb8fsoCH8Z2HhmTo24agTYIvIx3p/a
 DX2D/VI+o6iBkiJVqv91UOe+w/AvNTjKS6d918toNtcD7EWym0yMFB/z6IZMsEwSSj5lqz+qil0
 fw2WbI3sh0k1i3A==
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
index ba82a30d295b..02d7296c75d2 100644
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
 
@@ -2026,12 +2063,17 @@ static void delayed_export_remove(char *dom, char *path)
 
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
@@ -2378,12 +2420,17 @@ static void delayed_expkey_remove(struct expkey_req *req)
 
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

