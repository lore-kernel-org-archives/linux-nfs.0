Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A07CF2773CC;
	Sun,  1 Mar 2026 01:35:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772328908; cv=none; b=JxbLGBDC1Es4fhsWptlUYcPfWRQRc1nUTVtd6fXYOtJJm+E3ODMM43CA917yrPuqobH2PanJ+Zb8v3Jf3ipEbp3LL6i5ZXfV1DS1ELu04NM4zdA9mnX0s9un74qufO3jhYOjIFG7tc5oF1GObnW5cxaDGXJ6zZ6pkJAyA3wbMpM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772328908; c=relaxed/simple;
	bh=Ntp31ErqYenaEIQFnd0YrWmoeRJbxesSnqQA6coNEYw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=QhXTKKDEa0baqu7D6vMpYLWvCsy6rKN8qrfj3SpFUN2GMkh3Urv+t8J1lI1RbDeBBTm9wlFOehMC0p5sMZCgMZgeEahoD4ulJ9cbBEE5qISiuB3dQrNlj81rPRuSqaSael6z4jJW2UTBqE9IQUzKhs3ey+LEVivU8dg4vwYQmVE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XU2QW5ys; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XU2QW5ys"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8E66CC19421;
	Sun,  1 Mar 2026 01:35:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772328908;
	bh=Ntp31ErqYenaEIQFnd0YrWmoeRJbxesSnqQA6coNEYw=;
	h=From:To:Cc:Subject:Date:From;
	b=XU2QW5ys9XfNFp4ntws9+WbtBiBHS9GIV/QhsVJOtUkDjnjoWwESv0ynRLU5EvdiC
	 3rx+OHhP377LDkYC+nQozsEQ0c2SZy+IIH+LJvaEvhSbP6Xt9OPaJYFyG5QB+N+fP7
	 H8QhyqsLhBUt1EAQjCGJImG/KnCJvWlFkrOC8h+kBJpT6RWyoB7OC4Hh0EOlHlNiw9
	 H/Yc42pAs0npcrfHo/OsyHhNtuOd/5i1/JA+MSxC/ICpSo3KztAYbC4rxrdi2RIEwp
	 TgkeqbIhJ47iWxoJIPe2IQv9zttp4jad/zrXI7JJwkwuCZI2UqLHYLQmAySlr0QHMT
	 PATW4EA4wGCbQ==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org,
	chuck.lever@oracle.com
Cc: Xingjing Deng <micro6947@gmail.com>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Subject: FAILED: Patch "SUNRPC: auth_gss: fix memory leaks in XDR decoding error paths" failed to apply to 6.6-stable tree
Date: Sat, 28 Feb 2026 20:35:06 -0500
Message-ID: <20260301013506.1694676-1-sashal@kernel.org>
X-Mailer: git-send-email 2.51.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: ignore
X-stable: review
Content-Transfer-Encoding: 8bit

The patch below does not apply to the 6.6-stable tree.
If someone wants it applied there, or to any other stable or longterm
tree, then please email the backport, including the original git commit
id to <stable@vger.kernel.org>.

Thanks,
Sasha

------------------ original commit in Linus's tree ------------------

From 3e6397b056335cc56ef0e9da36c95946a19f5118 Mon Sep 17 00:00:00 2001
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 26 Dec 2025 10:15:32 -0500
Subject: [PATCH] SUNRPC: auth_gss: fix memory leaks in XDR decoding error
 paths

The gssx_dec_ctx(), gssx_dec_status(), and gssx_dec_name()
functions allocate memory via gssx_dec_buffer(), which calls
kmemdup(). When a subsequent decode operation fails, these
functions return immediately without freeing previously
allocated buffers, causing memory leaks.

The leak in gssx_dec_ctx() is particularly relevant because
the caller (gssp_accept_sec_context_upcall) initializes several
buffer length fields to non-zero values, resulting in memory
allocation:

    struct gssx_ctx rctxh = {
        .exported_context_token.len = GSSX_max_output_handle_sz,
        .mech.len = GSS_OID_MAX_LEN,
        .src_name.display_name.len = GSSX_max_princ_sz,
        .targ_name.display_name.len = GSSX_max_princ_sz
    };

If, for example, gssx_dec_name() succeeds for src_name but
fails for targ_name, the memory allocated for
exported_context_token, mech, and src_name.display_name
remains unreferenced and cannot be reclaimed.

Add error handling with goto-based cleanup to free any
previously allocated buffers before returning an error.

Reported-by: Xingjing Deng <micro6947@gmail.com>
Closes: https://lore.kernel.org/linux-nfs/CAK+ZN9qttsFDu6h1FoqGadXjMx1QXqPMoYQ=6O9RY4SxVTvKng@mail.gmail.com/
Fixes: 1d658336b05f ("SUNRPC: Add RPC based upcall mechanism for RPCGSS auth")
Cc: stable@vger.kernel.org
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/auth_gss/gss_rpc_xdr.c | 82 ++++++++++++++++++++++++-------
 1 file changed, 64 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index 7d2cdc2bd374e..f320c0a8e6049 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -320,29 +320,47 @@ static int gssx_dec_status(struct xdr_stream *xdr,
 
 	/* status->minor_status */
 	p = xdr_inline_decode(xdr, 8);
-	if (unlikely(p == NULL))
-		return -ENOSPC;
+	if (unlikely(p == NULL)) {
+		err = -ENOSPC;
+		goto out_free_mech;
+	}
 	p = xdr_decode_hyper(p, &status->minor_status);
 
 	/* status->major_status_string */
 	err = gssx_dec_buffer(xdr, &status->major_status_string);
 	if (err)
-		return err;
+		goto out_free_mech;
 
 	/* status->minor_status_string */
 	err = gssx_dec_buffer(xdr, &status->minor_status_string);
 	if (err)
-		return err;
+		goto out_free_major_status_string;
 
 	/* status->server_ctx */
 	err = gssx_dec_buffer(xdr, &status->server_ctx);
 	if (err)
-		return err;
+		goto out_free_minor_status_string;
 
 	/* we assume we have no options for now, so simply consume them */
 	/* status->options */
 	err = dummy_dec_opt_array(xdr, &status->options);
+	if (err)
+		goto out_free_server_ctx;
 
+	return 0;
+
+out_free_server_ctx:
+	kfree(status->server_ctx.data);
+	status->server_ctx.data = NULL;
+out_free_minor_status_string:
+	kfree(status->minor_status_string.data);
+	status->minor_status_string.data = NULL;
+out_free_major_status_string:
+	kfree(status->major_status_string.data);
+	status->major_status_string.data = NULL;
+out_free_mech:
+	kfree(status->mech.data);
+	status->mech.data = NULL;
 	return err;
 }
 
@@ -505,28 +523,35 @@ static int gssx_dec_name(struct xdr_stream *xdr,
 	/* name->name_type */
 	err = gssx_dec_buffer(xdr, &dummy_netobj);
 	if (err)
-		return err;
+		goto out_free_display_name;
 
 	/* name->exported_name */
 	err = gssx_dec_buffer(xdr, &dummy_netobj);
 	if (err)
-		return err;
+		goto out_free_display_name;
 
 	/* name->exported_composite_name */
 	err = gssx_dec_buffer(xdr, &dummy_netobj);
 	if (err)
-		return err;
+		goto out_free_display_name;
 
 	/* we assume we have no attributes for now, so simply consume them */
 	/* name->name_attributes */
 	err = dummy_dec_nameattr_array(xdr, &dummy_name_attr_array);
 	if (err)
-		return err;
+		goto out_free_display_name;
 
 	/* we assume we have no options for now, so simply consume them */
 	/* name->extensions */
 	err = dummy_dec_opt_array(xdr, &dummy_option_array);
+	if (err)
+		goto out_free_display_name;
 
+	return 0;
+
+out_free_display_name:
+	kfree(name->display_name.data);
+	name->display_name.data = NULL;
 	return err;
 }
 
@@ -649,32 +674,34 @@ static int gssx_dec_ctx(struct xdr_stream *xdr,
 	/* ctx->state */
 	err = gssx_dec_buffer(xdr, &ctx->state);
 	if (err)
-		return err;
+		goto out_free_exported_context_token;
 
 	/* ctx->need_release */
 	err = gssx_dec_bool(xdr, &ctx->need_release);
 	if (err)
-		return err;
+		goto out_free_state;
 
 	/* ctx->mech */
 	err = gssx_dec_buffer(xdr, &ctx->mech);
 	if (err)
-		return err;
+		goto out_free_state;
 
 	/* ctx->src_name */
 	err = gssx_dec_name(xdr, &ctx->src_name);
 	if (err)
-		return err;
+		goto out_free_mech;
 
 	/* ctx->targ_name */
 	err = gssx_dec_name(xdr, &ctx->targ_name);
 	if (err)
-		return err;
+		goto out_free_src_name;
 
 	/* ctx->lifetime */
 	p = xdr_inline_decode(xdr, 8+8);
-	if (unlikely(p == NULL))
-		return -ENOSPC;
+	if (unlikely(p == NULL)) {
+		err = -ENOSPC;
+		goto out_free_targ_name;
+	}
 	p = xdr_decode_hyper(p, &ctx->lifetime);
 
 	/* ctx->ctx_flags */
@@ -683,17 +710,36 @@ static int gssx_dec_ctx(struct xdr_stream *xdr,
 	/* ctx->locally_initiated */
 	err = gssx_dec_bool(xdr, &ctx->locally_initiated);
 	if (err)
-		return err;
+		goto out_free_targ_name;
 
 	/* ctx->open */
 	err = gssx_dec_bool(xdr, &ctx->open);
 	if (err)
-		return err;
+		goto out_free_targ_name;
 
 	/* we assume we have no options for now, so simply consume them */
 	/* ctx->options */
 	err = dummy_dec_opt_array(xdr, &ctx->options);
+	if (err)
+		goto out_free_targ_name;
+
+	return 0;
 
+out_free_targ_name:
+	kfree(ctx->targ_name.display_name.data);
+	ctx->targ_name.display_name.data = NULL;
+out_free_src_name:
+	kfree(ctx->src_name.display_name.data);
+	ctx->src_name.display_name.data = NULL;
+out_free_mech:
+	kfree(ctx->mech.data);
+	ctx->mech.data = NULL;
+out_free_state:
+	kfree(ctx->state.data);
+	ctx->state.data = NULL;
+out_free_exported_context_token:
+	kfree(ctx->exported_context_token.data);
+	ctx->exported_context_token.data = NULL;
 	return err;
 }
 
-- 
2.51.0




