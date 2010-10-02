Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53910 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751159Ab0JBTTT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Oct 2010 15:19:19 -0400
Date: Sat, 2 Oct 2010 15:19:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jim Rees <rees@umich.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH v2] nfs4: fix channel attribute sanity-checks
Message-ID: <20101002191901.GA18079@fieldses.org>
References: <20100525164224.GC4235@fieldses.org>
 <1274806624.11283.10.camel@heimdal.trondhjem.org>
 <20100525183223.GA6929@fieldses.org>
 <20100907223213.GA24707@fieldses.org>
 <20101002051949.GB18626@fieldses.org>
 <20101002090444.GB17395@merit.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101002090444.GB17395@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

The sanity checks here are incorrect; in the worst case they allow
values that crash the client.

They're also over-reliant on the preprocessor.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4proc.c |   75 +++++++++++++++++++++++++++++------------------------
 1 files changed, 41 insertions(+), 34 deletions(-)

On Sat, Oct 02, 2010 at 05:04:44AM -0400, Jim Rees wrote:
> J. Bruce Fields wrote:
> 
>   +	 * Our requested max_ops is the minimum we need; we're not
>   +	 * prepared to break up compounds into smaller pieces than that.
>   +	 * So, not point even trying to continue if the server won't
>   +	 * cooperate:
> 
> "not" should be "no".

Whoops, fixed.

> Also seems odd that max_ops is actually the minimum, but I guess the code is
> clear enough.

Yeah.  The naming's a little odd, at least; however this field was
imagined being used when the spec was written, I don't think clients are
likely to dynamically adjust their compounds somehow to optimize for the
max_ops that the server gives them.  The linux client behavior seems
more likely: calculate the length of the longest compound the client
needs to be able to send, send that as max_ops, error out if the server
won't give at least much, and ignore the server if it grants more....

--b.

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 089da5b..fdc79e5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4914,49 +4914,56 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 		args->bc_attrs.max_reqs);
 }
 
-static int _verify_channel_attr(char *chan, char *attr_name, u32 sent, u32 rcvd)
+static int nfs4_verify_fore_channel_attrs(struct nfs41_create_session_args *args, struct nfs4_session *session)
 {
-	if (rcvd <= sent)
-		return 0;
-	printk(KERN_WARNING "%s: Session INVALID: %s channel %s increased. "
-		"sent=%u rcvd=%u\n", __func__, chan, attr_name, sent, rcvd);
-	return -EINVAL;
+	struct nfs4_channel_attrs *sent = &args->fc_attrs;
+	struct nfs4_channel_attrs *rcvd = &session->fc_attrs;
+
+	if (rcvd->headerpadsz > sent->headerpadsz)
+		return -EINVAL;
+	if (rcvd->max_resp_sz > sent->max_resp_sz)
+		return -EINVAL;
+	/*
+	 * Our requested max_ops is the minimum we need; we're not
+	 * prepared to break up compounds into smaller pieces than that.
+	 * So, no point even trying to continue if the server won't
+	 * cooperate:
+	 */
+	if (rcvd->max_ops < sent->max_ops)
+		return -EINVAL;
+	if (rcvd->max_reqs == 0)
+		return -EINVAL;
+	return 0;
 }
 
-#define _verify_fore_channel_attr(_name_) \
-	_verify_channel_attr("fore", #_name_, \
-			     args->fc_attrs._name_, \
-			     session->fc_attrs._name_)
+static int nfs4_verify_back_channel_attrs(struct nfs41_create_session_args *args, struct nfs4_session *session)
+{
+	struct nfs4_channel_attrs *sent = &args->bc_attrs;
+	struct nfs4_channel_attrs *rcvd = &session->bc_attrs;
 
-#define _verify_back_channel_attr(_name_) \
-	_verify_channel_attr("back", #_name_, \
-			     args->bc_attrs._name_, \
-			     session->bc_attrs._name_)
+	if (rcvd->max_rqst_sz > sent->max_rqst_sz)
+		return -EINVAL;
+	if (rcvd->max_resp_sz < sent->max_resp_sz)
+		return -EINVAL;
+	if (rcvd->max_resp_sz_cached > sent->max_resp_sz_cached)
+		return -EINVAL;
+	/* These would render the backchannel useless: */
+	if (rcvd->max_ops  == 0)
+		return -EINVAL;
+	if (rcvd->max_reqs == 0)
+		return -EINVAL;
+	return 0;
+}
 
-/*
- * The server is not allowed to increase the fore channel header pad size,
- * maximum response size, or maximum number of operations.
- *
- * The back channel attributes are only negotiatied down: We send what the
- * (back channel) server insists upon.
- */
 static int nfs4_verify_channel_attrs(struct nfs41_create_session_args *args,
 				     struct nfs4_session *session)
 {
-	int ret = 0;
-
-	ret |= _verify_fore_channel_attr(headerpadsz);
-	ret |= _verify_fore_channel_attr(max_resp_sz);
-	ret |= _verify_fore_channel_attr(max_ops);
-
-	ret |= _verify_back_channel_attr(headerpadsz);
-	ret |= _verify_back_channel_attr(max_rqst_sz);
-	ret |= _verify_back_channel_attr(max_resp_sz);
-	ret |= _verify_back_channel_attr(max_resp_sz_cached);
-	ret |= _verify_back_channel_attr(max_ops);
-	ret |= _verify_back_channel_attr(max_reqs);
+	int ret;
 
-	return ret;
+	ret = nfs4_verify_fore_channel_attrs(args, session);
+	if (ret)
+		return ret;
+	return nfs4_verify_back_channel_attrs(args, session);
 }
 
 static int _nfs4_proc_create_session(struct nfs_client *clp)
-- 
1.7.0.4

