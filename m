Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39495 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab0JGRy2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 13:54:28 -0400
Received: from bfields by fieldses.org with local (Exim 4.71)
	(envelope-from <bfields@fieldses.org>)
	id 1P3ufg-0008Vm-Gk
	for linux-nfs@vger.kernel.org; Thu, 07 Oct 2010 13:54:24 -0400
Date: Thu, 7 Oct 2010 13:54:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Subject: Re: server 4.1 issues list
Message-ID: <20101007175424.GA31443@fieldses.org>
References: <20101007155306.GA28053@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101007155306.GA28053@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 07, 2010 at 11:53:06AM -0400, bfields wrote:
> Someone also asked whether we've fixed the backchannel attribute
> checking.  We haven't, but that should be fairly quick--I'll take a look
> at it now.

Actually there's a bit of tedious arithmetic to do here to figure out
what we need e.g. for the maximum request size.  I'm setting this aside
for now, so this is up for grabs.

--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6233917..0f8e90b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1493,6 +1493,23 @@ nfsd4_replay_create_session(struct nfsd4_create_session *cr_ses,
 	return slot->sl_status;
 }
 
+static __be32 verify_backchannel_attributes(struct nfsd4_create_session *cr_ses)
+{
+	struct nfsd4_channel_attrs *attrs;
+
+	if (!cses->flags & SESSION4_BACK_CHAN)
+		return nfs_ok;
+	if (attrs.maxreqs < 1)
+		return nfserr_inval;
+	/* XXX: check other fields here; see
+	 * http://tools.ietf.org/search/rfc5661#section-18.36 to
+	 * determine when we can modify the fields to be acceptable, and
+	 * when we must return inval.  We'll need to figure out the
+	 * things like how large a callback request we need to be able to
+	 * send. */
+	return nfs_ok;
+}
+
 __be32
 nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
@@ -1553,6 +1570,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	cr_ses->flags &= ~SESSION4_PERSIST;
 	cr_ses->flags &= ~SESSION4_RDMA;
 
+	status = verify_backchannel_attributes(cr_ses);
+	if (status)
+		goto out;
 	status = nfserr_jukebox;
 	new = alloc_init_session(rqstp, conf, cr_ses);
 	if (!new)
