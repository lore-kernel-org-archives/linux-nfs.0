Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53160 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162000Ab2GLWmH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jul 2012 18:42:07 -0400
Date: Thu, 12 Jul 2012 18:42:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism
 for nfsd
Message-ID: <20120712224207.GG24162@fieldses.org>
References: <1337983796-26476-1-git-send-email-simo@redhat.com>
 <20120710204913.GA6038@fieldses.org>
 <20120710210511.GB6038@fieldses.org>
 <20120712123916.GB16822@fieldses.org>
 <1342130717.2718.32.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1342130717.2718.32.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 12, 2012 at 06:05:17PM -0400, Simo Sorce wrote:
> On Thu, 2012-07-12 at 08:39 -0400, J. Bruce Fields wrote:
> > And this is reproduceable after applying the first patch
> > ("conditionally
> > return endtime...") but not before.  The patch seems obviously
> > innocent,
> > but maybe my eyes are playing tricks on me.
> > 
> missing braces around the if statement where I inserted the if (endtime)
> contion, causing instead to always kfree(ctx)
> 
> Sorry about that, it completely escaped my review of it multiple times
> over.

I also looked straight at it without seeing it.  It's tough to make my
eyes not trust the indentation!

--b.

diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index a32bb4f..3bc4a23 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -695,11 +695,11 @@ gss_import_sec_context_kerberos(const void *p, size_t len,
 	else
 		ret = gss_import_v2_context(p, end, ctx, gfp_mask);
 
-	if (ret == 0)
+	if (ret == 0) {
 		ctx_id->internal_ctx_id = ctx;
 		if (endtime)
 			*endtime = ctx->endtime;
-	else
+	} else
 		kfree(ctx);
 
 	dprintk("RPC:       %s: returning %d\n", __func__, ret);
