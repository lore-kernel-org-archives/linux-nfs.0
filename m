Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54885 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751265Ab0JBFUG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Oct 2010 01:20:06 -0400
Date: Sat, 2 Oct 2010 01:19:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH] nfs4: fix channel attribute sanity-checks
Message-ID: <20101002051949.GB18626@fieldses.org>
References: <20100525164224.GC4235@fieldses.org>
 <1274806624.11283.10.camel@heimdal.trondhjem.org>
 <20100525183223.GA6929@fieldses.org>
 <20100907223213.GA24707@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100907223213.GA24707@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

The sanity checks here are incorrect; in the worst case they allow
values that can later cause client crashes.

They're also over-reliant on the preprocessor.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4proc.c |   75 +++++++++++++++++++++++++++++------------------------
 1 files changed, 41 insertions(+), 34 deletions(-)

On Tue, Sep 07, 2010 at 06:32:13PM -0400, J. Bruce Fields wrote:
> On Tue, May 25, 2010 at 02:32:23PM -0400, J. Bruce Fields wrote:
> > On Tue, May 25, 2010 at 12:57:04PM -0400, Trond Myklebust wrote:
> > > Yes. That all looks wrong.
> > > 
> > > Can we please just get rid of that senseless macro, and open code those
> > > checks instead of the above patch? The current code is just pure
> > > obfuscation...
> > 
> > Sounds good to me.  I'm hoping Andy can be roped into it....
> 
> Is anyone willing to work on this?

OK, I cave.  How about something like this?

Minimally tested.  But that goes for the existing code, too....  A pynfs
test or two might not be a bad idea.

--b.

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 089da5b..eed13d6 100644
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
+	 * So, not point even trying to continue if the server won't
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

