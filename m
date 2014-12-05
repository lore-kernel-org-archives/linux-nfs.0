Return-Path: linux-kernel-owner@vger.kernel.org
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>, <stable@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH v2] fs: nfsd: Fix signedness bug in compare_blob
Date: Fri,  5 Dec 2014 16:40:07 +0100
Message-Id: <1417794008-16944-1-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1417706452-30204-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1417706452-30204-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bugs similar to the one in acbbe6fbb240 (kcmp: fix standard comparison
bug) are in rich supply.

In this variant, the problem is that struct xdr_netobj::len has type
unsigned int, so the expression o1->len - o2->len _also_ has type
unsigned int; it has completely well-defined semantics, and the result
is some non-negative integer, which is always representable in a long
long. But this means that if the conditional triggers, we are
guaranteed to return a positive value from compare_blob.

In this case it could be fixed by

-       res = o1->len - o2->len;
+       res = (long long)o1->len - (long long)o2->len;

but I'd rather eliminate the usually broken 'return a - b;' idiom.

Reviewed-by: Jeff Layton <jlayton@primarydata.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---

Notes:
    How this could ever have worked is beyond me - compare_blob seems to
    be used to maintain an rbtree, and I wouldn't expect rbtrees to behave
    well if the comparison function doesn't satisfy the basic invariant
    sign(cmp(a, b)) == -sign(cmp(b, a)).
    
    v2: Same patch. Slightly less generic subject. Added Jeff's
    Reviewed-by and Cc stable.

 fs/nfsd/nfs4state.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e9c3afe4b5d3..d504cd6927f8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1711,15 +1711,14 @@ static int copy_cred(struct svc_cred *target, struct svc_cred *source)
 	return 0;
 }
 
-static long long
+static int
 compare_blob(const struct xdr_netobj *o1, const struct xdr_netobj *o2)
 {
-	long long res;
-
-	res = o1->len - o2->len;
-	if (res)
-		return res;
-	return (long long)memcmp(o1->data, o2->data, o1->len);
+	if (o1->len < o2->len)
+		return -1;
+	if (o1->len > o2->len)
+		return 1;
+	return memcmp(o1->data, o2->data, o1->len);
 }
 
 static int same_name(const char *n1, const char *n2)
@@ -1907,7 +1906,7 @@ add_clp_to_name_tree(struct nfs4_client *new_clp, struct rb_root *root)
 static struct nfs4_client *
 find_clp_in_name_tree(struct xdr_netobj *name, struct rb_root *root)
 {
-	long long cmp;
+	int cmp;
 	struct rb_node *node = root->rb_node;
 	struct nfs4_client *clp;
 
-- 
2.0.4

