Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63076 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753213Ab1GNGsL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jul 2011 02:48:11 -0400
Message-ID: <4E1E91A9.1@cn.fujitsu.com>
Date: Thu, 14 Jul 2011 14:50:17 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2 v4] nfsd41: error out when client sets maxreq_sz or, maxresp_sz
 too small
References: <4E0EDE78.1060208@cn.fujitsu.com> <20110706162650.GB30349@fieldses.org> <4E17CE8C.8000504@cn.fujitsu.com> <20110712110950.GC2162@fieldses.org>
In-Reply-To: <20110712110950.GC2162@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

According to RFC5661, 18.36.3, 

 "if the client selects a value for ca_maxresponsesize such that
  a replier on a channel could never send a response,the server
  SHOULD return NFS4ERR_TOOSMALL in the CREATE_SESSION reply."

This patch let server error out when client sets maxreq_sz less than
SEQUENCE request size, and maxresp_sz less than a SEQUENCE reply size.

v4:
    Bruce said "Let's not bother with check_backchannel_attrs()
    until it actually does something.". So delete the function, 
    only check fore channel attr.

v3:
    use constant for min request size and min response size,
    add two function for channel attrs checking(back channel checking
    not be implement),
    move size check from xdr create_session to nfsd4_create_session,

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e98f3c2..72899ec 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1507,6 +1507,29 @@ nfsd4_replay_create_session(struct nfsd4_create_session *cr_ses,
 	return slot->sl_status;
 }
 
+#define NFSD_MIN_REQ_HDR_SEQ_SZ	((\
+			2 * 2 + /* credential,verifier: AUTH_NULL, length 0 */ \
+			1 +	/* MIN tag is length with zero, only length */ \
+			3 +	/* version, opcount, opcode */ \
+			XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + \
+				/* seqid, slotID, slotID, cache */ \
+			4 ) * sizeof(__be32))
+
+#define NFSD_MIN_RESP_HDR_SEQ_SZ ((\
+			2 +	/* verifier: AUTH_NULL, length 0 */\
+			1 +	/* status */ \
+			1 +	/* MIN tag is length with zero, only length */ \
+			3 +	/* opcount, opcode, opstatus*/ \
+			XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + \
+				/* seqid, slotID, slotID, slotID, status */ \
+			5 ) * sizeof(__be32))
+
+static __be32 check_forechannel_attrs(struct nfsd4_channel_attrs fchannel)
+{
+	return fchannel.maxreq_sz < NFSD_MIN_REQ_HDR_SEQ_SZ
+		|| fchannel.maxresp_sz < NFSD_MIN_RESP_HDR_SEQ_SZ;
+}
+
 __be32
 nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
@@ -1575,6 +1598,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	cr_ses->flags &= ~SESSION4_PERSIST;
 	cr_ses->flags &= ~SESSION4_RDMA;
 
+	status = nfserr_toosmall;
+	if (check_forechannel_attrs(cr_ses->fore_channel))
+		goto out;
+
 	status = nfserr_jukebox;
 	new = alloc_init_session(rqstp, conf, cr_ses);
 	if (!new)
-- 
1.7.5.4



