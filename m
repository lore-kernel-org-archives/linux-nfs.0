From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Should truncated READDIR replies return -EIO?
Date: Tue, 12 Feb 2008 08:20:38 -0500
Message-ID: <20080212082038.7e75670e@tleilax.poochiereds.net>
References: <1202483082-5334-1-git-send-email-jlayton@redhat.com>
	<1202483596.8914.13.camel@heimdal.trondhjem.org>
	<20080208105659.3bfb8a6b@tleilax.poochiereds.net>
	<1202487187.10337.25.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47575 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757005AbYBLNU4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Feb 2008 08:20:56 -0500
In-Reply-To: <1202487187.10337.25.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 08 Feb 2008 11:13:07 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Fri, 2008-02-08 at 10:56 -0500, Jeff Layton wrote:
> 
> > If it looks like the above, but EOF is 0, then we *do* "goto
> > short_pkt", and that case would be affected by this. But in that case
> > we currently reset EOF to 1. The client won't retry the request. I'm
> > not sure that's what we want to do either...
> 
> That is to deal with the afore-mentioned broken server. I'm not
> unwilling to change this (I _hate_ client side fixes for server bugs),
> but it's important to note that there may be consequences if we do.

Perhaps we can just narrow down this special case so that this server
still works, but we can return a proper error when we get other bogus
packets? We currently have this:

	if (!nr && (entry[0] != 0 || entry[1] == 0))

...but if nr==0, then I think entry[0] must be 0 as well. So, I'm
guessing that the server always set value_follows=0 and EOF=0. Is that
correct?

If so, what about something like the following patch? This should
hopefully make it so that packets that are badly sized return -EIO, but
the special case you mention should continue to work.

Note that this patch is just an RFC, untested and v2-only. If this
seems reasonable, I can do similar patches for later revs though my
suggestion would be that we remove this hackery from v4 (and maybe v3
if it's not truly needed there).

I also added some comments to clarify the logic.

>From fd52250cebdaeabdd6f6d561f3ffed7e0e1cdc74 Mon Sep 17 00:00:00 2001
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 12 Feb 2008 08:19:43 -0500
Subject: [PATCH] NFS: clean up short packet handling for NFSv2

Try to make sure that bogus responses with no entries return error.
Also try to preserve existing workaround for servers that send empty
responses with the EOF marker unset. Finally, add some comments to
clarify the logic in nfs_xdr_readdirres().

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs2xdr.c |   33 ++++++++++++++++++++++++++-------
 1 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 1f7ea67..008caec 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -452,6 +452,11 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	kaddr = p = kmap_atomic(*page, KM_USER0);
 	end = (__be32 *)((char *)p + pglen);
 	entry = p;
+
+	/* Make sure the packet actually has a value_follows and EOF entry */
+	if ((entry + 1) > end)
+		goto short_pkt;
+
 	for (nr = 0; *p++; nr++) {
 		if (p + 2 > end)
 			goto short_pkt;
@@ -467,18 +472,32 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 			goto short_pkt;
 		entry = p;
 	}
-	if (!nr && (entry[0] != 0 || entry[1] == 0))
-		goto short_pkt;
+
+	/*
+	 * Apparently some server sends responses that are a valid size, but
+	 * contain no entries, and have value_follows==0 and EOF==0. For
+	 * those, just set the EOF marker.
+	 */
+	if (!nr && entry[1] == 0) {
+		dprintk("NFS: readdir reply truncated!\n");
+		entry[1] = 1;
+	}
  out:
 	kunmap_atomic(kaddr, KM_USER0);
 	return nr;
  short_pkt:
+	/*
+	 * When we get a short packet there are 2 possibilities. We can
+	 * return an error, or fix up the response to look like a valid
+	 * response and return what we have so far. If there are no
+	 * entries and the packet was short, then return -EIO. If there
+	 * are valid entries in the response, return them and pretend that
+	 * the call was successful, but incomplete. The caller can retry the
+	 * readdir starting at the last cookie.
+	 */
 	entry[0] = entry[1] = 0;
-	/* truncate listing ? */
-	if (!nr) {
-		dprintk("NFS: readdir reply truncated!\n");
-		entry[1] = 1;
-	}
+	if (!nr)
+		nr = -errno_NFSERR_IO;
 	goto out;
 err_unmap:
 	nr = -errno_NFSERR_IO;
-- 
1.5.3.8

