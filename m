Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A0DB94A1D
	for <linux-nfs@vger.kernel.org>; Thu, 25 Jan 2024 21:49:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1706219364; cv=none; b=XdFZq5NJNwzYcNIVG/eTOe1AZx2xP4THzG4kSfX1ggqTXqyKvGRpw+zQU69dxHU6g7CNfMBEd2BRsMGvLrDPaQbf45g0UsszVQWcZ3OrfqtfTiG+1Znd2jGtD0Q1TPsSz/EvaptBW6ESDWkF+hyOTjEEe79FEWZt3o5/oCcE+Kc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1706219364; c=relaxed/simple;
	bh=yb1efWTZSkKgXiF3nObnBbnY7OVpP5beNK+ePUDMNu8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=l6IGwYrjS1z9XWxYeBLhihOeCpziPx/CNAxjNTPOgy+ULzLcqWIfOSPdmEstXG4LLBsrDjGZ+nAStzqG5Y7mb3TIU4RomyZ5aRLvOLHmIwQQtySLUphv2iu7BkwRpm/qMSWi/dFMEQwkwF+BL07zcPOD1F/OICjZpSVnb7EW59g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=WRVGi6HL; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="WRVGi6HL"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1706219361;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=C3DUgTcRmzpr0Uq5Ghc3n882LJ7/Kd41FL//RIjWHsQ=;
	b=WRVGi6HLquwTQkbHYqqjhb1Ij5hiS+k2mWmbH5OkGPAws4yBCSIRnOHBy/2QdsrmXIw1Xo
	Q7uBt+8CFVL64mi/8/TqGmEYnVDlQ1D3iSs/GJxdtjYfBINHw6fDtRS9PQK3u3yZqOBylB
	mya6dNk08yLhW7CTyidSpq9lCul4J/U=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-157-tGyKSP_xMp2ik62aklSs4g-1; Thu, 25 Jan 2024 16:49:19 -0500
X-MC-Unique: tGyKSP_xMp2ik62aklSs4g-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 1C4B51064FAB;
	Thu, 25 Jan 2024 21:49:19 +0000 (UTC)
Received: from [192.168.37.1] (ovpn-0-9.rdu2.redhat.com [10.22.0.9])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A0499200A08E;
	Thu, 25 Jan 2024 21:49:18 +0000 (UTC)
From: Benjamin Coddington <bcodding@redhat.com>
To: Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 07/13] NFSD: Add callback operation lifetime trace
 points
Date: Thu, 25 Jan 2024 16:49:17 -0500
Message-ID: <86789B68-0271-4AEB-9941-CFDB956E84EE@redhat.com>
In-Reply-To: <170620016455.2833.5426224225062159088.stgit@manet.1015granger.net>
References: <170619984210.2833.7173004255003914651.stgit@manet.1015granger.net>
 <170620016455.2833.5426224225062159088.stgit@manet.1015granger.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
X-Scanned-By: MIMEDefang 3.4.1 on 10.11.54.4

On 25 Jan 2024, at 11:29, Chuck Lever wrote:

> From: Chuck Lever <chuck.lever@oracle.com>
>
> Help observe the flow of callback operations.
>
> bc_shutdown() records exactly when the backchannel RPC client is
> destroyed and cl_cb_client is replaced with NULL.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/nfs4callback.c   |    7 +++++++
>  fs/nfsd/trace.h          |   42 ++++++++++++++++++++++++++++++++++++++=
++++
>  include/trace/misc/nfs.h |   34 ++++++++++++++++++++++++++++++++++
>  3 files changed, 83 insertions(+)
>
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 1c85426830b1..4d5a6370b92c 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -887,6 +887,7 @@ static struct workqueue_struct *callback_wq;
>
>  static bool nfsd4_queue_cb(struct nfsd4_callback *cb)
>  {
> +	trace_nfsd_cb_queue(cb->cb_clp, cb);
>  	return queue_work(callback_wq, &cb->cb_work);
>  }
>
> @@ -1106,6 +1107,7 @@ static void nfsd41_destroy_cb(struct nfsd4_callba=
ck *cb)
>  {
>  	struct nfs4_client *clp =3D cb->cb_clp;
>
> +	trace_nfsd_cb_destroy(clp, cb);
>  	nfsd41_cb_release_slot(cb);
>  	if (cb->cb_ops && cb->cb_ops->release)
>  		cb->cb_ops->release(cb);
> @@ -1220,6 +1222,7 @@ static bool nfsd4_cb_sequence_done(struct rpc_tas=
k *task, struct nfsd4_callback
>  	goto out;
>  need_restart:
>  	if (!test_bit(NFSD4_CLIENT_CB_KILL, &clp->cl_flags)) {
> +		trace_nfsd_cb_restart(clp, cb);
>  		task->tk_status =3D 0;
>  		cb->cb_need_restart =3D true;

I think you want to call the tracepoint /after/ setting cb_need_restart h=
ere..

>  	}
> @@ -1333,11 +1336,14 @@ static void nfsd4_process_cb_update(struct nfsd=
4_callback *cb)
>  	struct nfsd4_conn *c;
>  	int err;
>
> +	trace_nfsd_cb_bc_update(clp, cb);
> +
>  	/*
>  	 * This is either an update, or the client dying; in either case,
>  	 * kill the old client:
>  	 */
>  	if (clp->cl_cb_client) {
> +		trace_nfsd_cb_bc_shutdown(clp, cb);
>  		rpc_shutdown_client(clp->cl_cb_client);
>  		clp->cl_cb_client =3D NULL;
>  		put_cred(clp->cl_cb_cred);
> @@ -1349,6 +1355,7 @@ static void nfsd4_process_cb_update(struct nfsd4_=
callback *cb)
>  	}
>  	if (test_bit(NFSD4_CLIENT_CB_KILL, &clp->cl_flags))
>  		return;
> +

I'm in favor of this whitespace change, but did you mean to include it?

Ben

