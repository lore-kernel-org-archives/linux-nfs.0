Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63857 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909Ab2CAWAd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:00:33 -0500
Received: by mail-iy0-f174.google.com with SMTP id z16so1389076iag.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Mar 2012 14:00:32 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/15] NFS: Clean up debugging in decode_pathname()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 01 Mar 2012 17:00:31 -0500
Message-ID: <20120301220031.2138.39892.stgit@degas.1015granger.net>
In-Reply-To: <20120301215755.2138.73488.stgit@degas.1015granger.net>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I noticed recently that decode_attr_fs_locations() is not generating
very pretty debugging output.  The pathname components each appear on
a separate line of output, though that does not appear to be the
intended display behavior.  The preferred way to generate continued
lines of output on the console is to use pr_cont().

Note that incoming pathname4 components contain a string that is not
necessarily NUL-terminated.  I did actually see some trailing garbage
on the console.  In addition to correcting the line continuation
problem, add a string precision format specifier to ensure that each
component string is displayed properly, and that vsnprintf() does
not Oops.

Someone pointed out that allowing incoming network data to possibly
generate a console line of unbounded length may not be such a good
idea.  Since this output will rarely be enabled, and there is a hard
upper bound (NFS4_PATHNAME_MAXCOMPONENTS) in our implementation, this
is probably not a major concern.

It might be useful to additionally sanity-check the length of each
incoming component, however.  RFC 3530bis15 does not suggest a maximum
number of UTF-8 characters per component for either the pathname4 or
component4 types.  However, we could invent one that is appropriate
for our implementation.

Another possibility is to scrap all of this and print these pathnames
in upper layers after a reasonable amount of sanity checking in the
XDR layer.  This would give us an opportunity to allocate a full
buffer so that the whole pathname would be output via a single
dprintk.

Introduced by commit 7aaa0b3b: "NFSv4: convert fs-locations-components
to conform to RFC3530," (June 9, 2006).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ae78343..4ca87cb 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3514,16 +3514,17 @@ static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
 	n = be32_to_cpup(p);
 	if (n == 0)
 		goto root_path;
-	dprintk("path ");
+	dprintk("pathname4: ");
 	path->ncomponents = 0;
 	while (path->ncomponents < n) {
 		struct nfs4_string *component = &path->components[path->ncomponents];
 		status = decode_opaque_inline(xdr, &component->len, &component->data);
 		if (unlikely(status != 0))
 			goto out_eio;
-		if (path->ncomponents != n)
-			dprintk("/");
-		dprintk("%s", component->data);
+		if (unlikely(nfs_debug & NFSDBG_XDR))
+			pr_cont("%s%.*s ",
+				(path->ncomponents != n ? "/ " : ""),
+				component->len, component->data);
 		if (path->ncomponents < NFS4_PATHNAME_MAXCOMPONENTS)
 			path->ncomponents++;
 		else {
@@ -3532,14 +3533,13 @@ static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
 		}
 	}
 out:
-	dprintk("\n");
 	return status;
 root_path:
 /* a root pathname is sent as a zero component4 */
 	path->ncomponents = 1;
 	path->components[0].len=0;
 	path->components[0].data=NULL;
-	dprintk("path /\n");
+	dprintk("pathname4: /\n");
 	goto out;
 out_eio:
 	dprintk(" status %d", status);
@@ -3565,7 +3565,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	/* Ignore borken servers that return unrequested attrs */
 	if (unlikely(res == NULL))
 		goto out;
-	dprintk("%s: fsroot ", __func__);
+	dprintk("%s: fsroot:\n", __func__);
 	status = decode_pathname(xdr, &res->fs_path);
 	if (unlikely(status != 0))
 		goto out;
@@ -3586,7 +3586,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		m = be32_to_cpup(p);
 
 		loc->nservers = 0;
-		dprintk("%s: servers ", __func__);
+		dprintk("%s: servers:\n", __func__);
 		while (loc->nservers < m) {
 			struct nfs4_string *server = &loc->servers[loc->nservers];
 			status = decode_opaque_inline(xdr, &server->len, &server->data);

