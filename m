Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49810 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751369Ab1FNX41 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2011 19:56:27 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NFS: (d)printks should use %zd for ssize_t arguments
Cc: David Howells <dhowells@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Date: Wed, 15 Jun 2011 00:55:44 +0100
Message-ID: <20110614235544.4403.36702.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

(d)printks should use %zd for ssize_t arguments not %ld, otherwise they might
get a warning.  I see the following with MN10300.

fs/nfs/objlayout/objlayout.c: In function 'objlayout_read_done':
fs/nfs/objlayout/objlayout.c:294: warning: format '%ld' expects type 'long int', but argument 3 has type 'ssize_t'

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: linux-nfs@vger.kernel.org
---

 fs/nfs/objlayout/objlayout.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index dc3956c..1d06f8e 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -291,7 +291,7 @@ objlayout_read_done(struct objlayout_io_state *state, ssize_t status, bool sync)
 	struct nfs_read_data *rdata;
 
 	state->status = status;
-	dprintk("%s: Begin status=%ld eof=%d\n", __func__, status, eof);
+	dprintk("%s: Begin status=%zd eof=%d\n", __func__, status, eof);
 	rdata = state->rpcdata;
 	rdata->task.tk_status = status;
 	if (status >= 0) {

