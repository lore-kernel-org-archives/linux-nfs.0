Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794841556;
	b=vc5sNIu3DDSQmmKFMEX71jl5Y5ZqQKhG7mDgi2uPEHQvbRj4TbWOu5M1U+tVwnhjVtnv
	 9/T5xEqxBTlvFxTmUIa129d1yMAEoHfdK5GHugXou8zreVvHtULn0IiSjqwGgayZ1tohl
	 ttmACKUHHBDOCgQ+x2OB71xOGW+nxkq+bS1Z+bqgoOhPE/fNVwFFm9b2d+EJz3FlJC4VV
	 43NATXf3vKQnRC6Mp36EL3qlc2DNVua9UFEbY4O3Ldw47c/ATvBc4CVdShkQFnUtEArOr
	 ijrNu0pnOWiE802m3i2vxjwVpzMXAWXaXokzsX8ODRaE6sk1/qY32/iCnvGTtMwtC9A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794841556;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=GshjUkVFwFINfqlZSJ4uRGe88l6TmbD7OIlti+2Bc/4=;
	b=nICOGUXNV+C7zTobnntm5M4QNeT2Cml2Pzfk8TwdqL8H+EM9fuZIUznWTNR+psWgrCQf
	 SBFhBleyUVq//gv3ekrjlgYrfE0MMF7dAuxEv2FoKyVwI5jnd83iVlM2p9t1H7h4aIw26
	 YHIl9sgpr+D3M2OFzYN3mqSw+FiCTStlOZ4AKPB4mwX8Bxjj3Sn1TbZ04sB29iSDc5+xE
	 /7y37SRhhtMpmoD4OrDboTATl0SlMXYbrnUOThPzk5R7Fsn6kpZBIiuKLHC5spuN1QQMm
	 qXb/bFF9lLFsNOrUBhwgbsPLaux/P1YuPIuZyONXhk5g+Nk1vD9hnK52ixZQQP90EKw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=QfRI8cs3;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=F7xKpJVd;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 19871606A333
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 15:05:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 19871606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=QfRI8cs3;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=F7xKpJVd
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794841555;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=GshjUkVFwFINfqlZSJ4uRGe88l6TmbD7OIlti+2Bc/4=;
	b=QfRI8cs3Fwlc9Uhy1MknQodn2RQfXYLAl27ca/InviNZ91ploaiqRqq4aDFDOhe8AIYuG6
	IxRa1jExvUYJ4b+NUx4G47VyKxGzn+lPnqVvyBr+1jFkKNxN7e1vupgfb+/HmJSkGcoL8J
	Go/O9oOkQvGcwI6IZOH0OxutTmr+I7Y=
Received: from mail-yw1-f199.google.com (mail-yw1-f199.google.com
 [209.85.128.199]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-510-3QGGVJoHN7KO0rirI-qTRw-1; Mon, 16 Nov 2026 10:05:53 -0500
X-MC-Unique: 3QGGVJoHN7KO0rirI-qTRw-1
X-Mimecast-MFC-AGG-ID: 3QGGVJoHN7KO0rirI-qTRw_1794841553
Received: by mail-yw1-f199.google.com with SMTP id 00721157ae682-8b4bb8bf464so38461157b3.2
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 07:05:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1794841553; x=1795446353; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=GshjUkVFwFINfqlZSJ4uRGe88l6TmbD7OIlti+2Bc/4=;
        b=F7xKpJVdTFKhi2NCLZu0o/7oNH+/lF15aYvwJl8r+ykMoK0Ux5I1sXCh6u2qx5wVUv
         ay7wClxZNCkJL7WjqfDMLkVvhdzNFqUCobMdz1nJwsl640yA7Fe/MPcAtSDja45tpZiw
         BKdNpn+6qyKUWkoy1LxEcsbWMGuAnNrHXWMHGDaI7KulM07N5iGh5mRJg9ihhROSkp9O
         5/Pknrwip2Eb5p/1eop9SCTaBx84/rZB2acpQhDitpdCN3P/oWcX97zWiZ8a7OofUfy7
         Nc0LJq27XEJT7cNPwwwW9dXEU27Uq+tD/9JldXqOdFPVntBD8CsQpkvkOOlgh8rK0qcG
         8Qvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794841553; x=1795446353;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=GshjUkVFwFINfqlZSJ4uRGe88l6TmbD7OIlti+2Bc/4=;
        b=RPZ+Kh16bDkaB7LJMp6BfWqJszUXUoBQXRAdLwXI95uteSx4rvbK12C6aQ9skktsSh
         4vZwCLXD/ubKK0eK5lrwjsQiRfMUAU3aJ2RDh6SMl/YCfnd/jSvwaLugD9QKgWOUZAu5
         t04Er6fJCngPgMWQtn+yJ/nAaef/Br+UeSf4L1vy4f161R0MzIJRKtTl4m8nk/HesARb
         k8Bd8kHArcUHyPO4kIhck9AuH1+Ty+4dDg60T5Yxt7Z2M3O0KAACrLXk/sKC7h4aYeNe
         Yd9m0L2jyqDET4JJrFo5WMTTEG0s44Woj2brduFEhu9eMD3HGCbavG/rMWkcM4mPYGAm
         eEow==
X-Gm-Message-State: APuU4Z+qxewU5k/u8oh8+9UY+cYrp8zL+ZoViPqHWlXFIfrqH9sV6MWm
	UCyckvNYqsrxaH6qbc25SaAlboh5sSkbzbMJ6WTCEWY6ZCdGwbDhlutz2eOeZN3r2pSEcZkECt/
	a3MJgYZul0/1RcFR/c6TPQJ20wfGClz+g6JfCU+wO/sxq8QoO1kAAgmBrksyDOA==
X-Gm-Gg: AZFdTZfr285VDe9htSa6H6m9G7CTSDK7S0l6N3P3uVAOeH4x4dUuKpAg/PK2RHAwGUP
	JIEzlwqVUrEPuLExnFLZKzIN2D1YDVdL1R7Xwr+u5AIKx2Eh2gWFFOjOKAKP66Huy3mupd7bsgc
	+uapawfuK9qoRz790E5CKwnXqlhWjHgnqxb/oqsYHwXe2vYOG5CDtYSE5E0Aytg4Jaflmv/Wrfa
	+dNupF8T/c+ys6xgo8Cv6ub3rkbd6O39zCA35CBAYaiCEB1SCI5eQo/Utsse+OtLWhHxPXHxkwD
	HNwCCNTWF9pk0x4pD8cYZdv9/PYbA1mTdHVbq9IyS5Jn4bkmcxLUxaG5x4X37IwQ7p8nXhH6Vp0
	0Dyvw+Ce7Yqc7Ols791dvgjdvSTR4NaEVLSLTOoH6oGJJWHYr
X-Received: by 2002:a05:690e:1487:b0:67d:c305:ca1f with SMTP id 956f58d0204a3-67dc305ce0cmr387751d50.53.1794841552759;
        Mon, 16 Nov 2026 07:05:52 -0800 (PST)
X-Received: by 2002:a05:690e:1487:b0:67d:c305:ca1f with SMTP id 956f58d0204a3-67dc305ce0cmr387735d50.53.1794841552242;
        Mon, 16 Nov 2026 07:05:52 -0800 (PST)
Received: from [172.31.1.12] ([70.105.240.105])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9494c870f31sm868549985a.27.2026.11.16.07.05.49
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 16 Nov 2026 07:05:49 -0800 (PST)
Message-ID: <b28191a0-1bc1-44bd-bf9d-6e4b33953b9c@redhat.com>
Date: Mon, 16 Nov 2026 10:05:48 -0500
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] rpc.svcgssd: stop using raw pointers as continuation
 handles
To: Minsu Kim <gsnake7@naver.com>
Cc: linux-nfs@vger.kernel.org, bobtobabz@gmail.com
References: <20261112052054.29215-1-gsnake7@naver.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20261112052054.29215-1-gsnake7@naver.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 11/12/26 12:20 AM, Minsu Kim wrote:
> rpc.svcgssd currently serializes gss_ctx_id_t itself as the continuation
> handle when gss_accept_sec_context() returns GSS_S_CONTINUE_NEEDED. A
> client then sends that value back in a CONTINUE_INIT request, where the
> daemon converts it directly into a live GSS context.
> 
> This exposes a daemon address and trusts a client-controlled value as a
> live GSS context pointer. An unauthenticated NFS client can replace or
> replay the handle before rpc.svcgssd passes it to the GSS implementation.
> 
> Keep pending contexts in a daemon-owned search tree. Return a random
> 64-bit ID from /dev/urandom instead of the context pointer. Take the
> matching entry before processing a continuation, return the same ID if
> negotiation needs another step, and reject unknown IDs with
> GSS_S_NO_CONTEXT. Discard the saved context if writing its reply fails.
> 
> The behavior was introduced in commit 62c4197d5b41 and first shipped in
> nfs-utils 1.0.8-rc1. It remains present in nfs-utils 3.1.1.
> rpc.svcgssd is built only when --enable-svcgss is selected, which is
> disabled by default.
> 
> On an unpatched x86_64 build, an INIT request that required another GSS
> step returned an 8-byte value matching the in-process gss_ctx_id_t
> address. Modified and stale continuation handles caused invalid memory
> accesses and daemon termination.
> 
> With this patch, an unknown ID and a consumed ID both returned
> GSS_S_NO_CONTEXT, initial negotiations returned opaque 8-byte IDs, and
> 63 outstanding negotiations produced 63 distinct IDs. I also completed
> an NFSv4.2 sec=krb5 mount with the patched daemon, which remained active
> throughout the tests. The reproducer and complete logs are available
> privately on request.
> 
> The vulnerability research and validation were conducted by members of
> the Tobabz team as part of the Best of the Best 15th program.
> 
> Fixes: 62c4197d5b41 ("Updates from Kevin Coffman at UMich")
> Assisted-by: LLM
> Signed-off-by: Minsu Kim <gsnake7@naver.com>
Committed... (tag: nfs-utils-2-1-2.rc4)

steved.
> ---
>   utils/gssd/svcgssd_proc.c | 159 ++++++++++++++++++++++++++++++++++----
>   1 file changed, 145 insertions(+), 14 deletions(-)
> 
> diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
> index 7fecd1aa..81216c38 100644
> --- a/utils/gssd/svcgssd_proc.c
> +++ b/utils/gssd/svcgssd_proc.c
> @@ -42,6 +42,11 @@
>   #include <rpc/rpc.h>
>   
>   #include <pwd.h>
> +#include <stdint.h>
> +/* <search.h> and nfs_prot.h both define struct entry. */
> +#define entry search_entry
> +#include <search.h>
> +#undef entry
>   #include <stdio.h>
>   #include <unistd.h>
>   #include <ctype.h>
> @@ -74,6 +79,109 @@ struct svc_cred {
>   	gid_t	cr_groups[NGROUPS];
>   };
>   
> +struct pending_context {
> +	uint64_t id;
> +	gss_ctx_id_t ctx;
> +};
> +
> +static void *pending_contexts;
> +
> +static int
> +pending_context_compare(const void *a, const void *b)
> +{
> +	const struct pending_context *pa = a;
> +	const struct pending_context *pb = b;
> +
> +	return (pa->id > pb->id) - (pa->id < pb->id);
> +}
> +
> +static struct pending_context *
> +pending_context_find(uint64_t id)
> +{
> +	struct pending_context key = { .id = id };
> +	void *result;
> +
> +	result = tfind(&key, &pending_contexts, pending_context_compare);
> +	return result ? *(struct pending_context **)result : NULL;
> +}
> +
> +static int
> +pending_context_new_id(uint64_t *id)
> +{
> +	unsigned char *p = (unsigned char *)id;
> +	size_t done = 0;
> +	ssize_t len;
> +	int fd;
> +
> +	fd = open("/dev/urandom", O_RDONLY);
> +	if (fd < 0)
> +		return -1;
> +	while (done < sizeof(*id)) {
> +		len = read(fd, p + done, sizeof(*id) - done);
> +		if (len > 0) {
> +			done += len;
> +			continue;
> +		}
> +		if (len < 0 && errno == EINTR)
> +			continue;
> +		close(fd);
> +		return -1;
> +	}
> +	close(fd);
> +	return 0;
> +}
> +
> +static struct pending_context *
> +pending_context_take(uint64_t id)
> +{
> +	struct pending_context *pending = pending_context_find(id);
> +
> +	if (pending)
> +		tdelete(pending, &pending_contexts, pending_context_compare);
> +	return pending;
> +}
> +
> +static struct pending_context *
> +pending_context_save(struct pending_context *pending, gss_ctx_id_t *ctx)
> +{
> +	void *result;
> +
> +	if (!pending) {
> +		pending = calloc(1, sizeof(*pending));
> +		if (!pending)
> +			return NULL;
> +		do {
> +			if (pending_context_new_id(&pending->id) != 0) {
> +				free(pending);
> +				return NULL;
> +			}
> +		} while (pending->id == 0 ||
> +			 pending_context_find(pending->id));
> +	}
> +
> +	result = tsearch(pending, &pending_contexts,
> +			 pending_context_compare);
> +	if (!result) {
> +		free(pending);
> +		return NULL;
> +	}
> +	pending->ctx = *ctx;
> +	*ctx = GSS_C_NO_CONTEXT;
> +	return pending;
> +}
> +
> +static void
> +pending_context_discard(struct pending_context *pending)
> +{
> +	OM_uint32 min_stat;
> +
> +	tdelete(pending, &pending_contexts, pending_context_compare);
> +	if (pending->ctx != GSS_C_NO_CONTEXT)
> +		gss_delete_sec_context(&min_stat, &pending->ctx,
> +				       GSS_C_NO_BUFFER);
> +	free(pending);
> +}
> +
>   static int
>   do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
>   		gss_OID mech, gss_buffer_desc *context_token,
> @@ -337,11 +445,13 @@ handle_nullreq(char *cp) {
>   	gss_ctx_id_t		ctx = GSS_C_NO_CONTEXT;
>   	gss_name_t		client_name = NULL;
>   	gss_OID			mech = GSS_C_NO_OID;
> +	struct pending_context	*pending = NULL;
>   	u_int32_t		maj_stat = GSS_S_FAILURE, min_stat = 0;
>   	u_int32_t		ignore_min_stat;
>   	struct svc_cred		cred;
>   	int32_t			ctx_endtime;
>   	char			*hostbased_name = NULL;
> +	uint64_t		context_id;
>   
>   	printerr(1, "handling null request\n");
>   
> @@ -358,15 +468,21 @@ handle_nullreq(char *cp) {
>   #endif
>   
>   	if (in_handle.length != 0) { /* CONTINUE_INIT case */
> -		if (in_handle.length != sizeof(ctx)) {
> +		if (in_handle.length != sizeof(context_id)) {
>   			printerr(0, "WARNING: handle_nullreq: "
>   				    "input handle has unexpected length %zd\n",
>   				    in_handle.length);
> +			maj_stat = GSS_S_NO_CONTEXT;
> +			goto out_err;
> +		}
> +		memcpy(&context_id, in_handle.value, sizeof(context_id));
> +		pending = pending_context_take(context_id);
> +		if (!pending) {
> +			maj_stat = GSS_S_NO_CONTEXT;
>   			goto out_err;
>   		}
> -		/* in_handle is the context id stored in the out_handle
> -		 * for the GSS_S_CONTINUE_NEEDED case below.  */
> -		memcpy(&ctx, in_handle.value, in_handle.length);
> +		ctx = pending->ctx;
> +		pending->ctx = GSS_C_NO_CONTEXT;
>   	}
>   
>   	if (svcgssd_limit_krb5_enctypes()) {
> @@ -380,10 +496,19 @@ handle_nullreq(char *cp) {
>   	if (maj_stat == GSS_S_CONTINUE_NEEDED) {
>   		printerr(1, "gss_accept_sec_context GSS_S_CONTINUE_NEEDED\n");
>   
> -		/* Save the context handle for future calls */
> -		out_handle.length = sizeof(ctx);
> -		memcpy(out_handle.value, &ctx, sizeof(ctx));
> -		goto continue_needed;
> +		pending = pending_context_save(pending, &ctx);
> +		if (!pending) {
> +			maj_stat = GSS_S_FAILURE;
> +			goto out_err;
> +		}
> +		out_handle.length = sizeof(pending->id);
> +		memcpy(out_handle.value, &pending->id, out_handle.length);
> +		if (send_response(&in_handle, &in_tok, maj_stat, min_stat,
> +				  &out_handle, &out_tok) != 0) {
> +			pending_context_discard(pending);
> +			pending = NULL;
> +		}
> +		goto out;
>   	}
>   	else if (maj_stat != GSS_S_COMPLETE) {
>   		printerr(1, "WARNING: gss_accept_sec_context failed\n");
> @@ -402,11 +527,17 @@ handle_nullreq(char *cp) {
>   		goto out_err;
>   	}
>   
> -	/* Context complete. Pass handle_seq in out_handle to use
> -	 * for context lookup in the kernel. */
> -	handle_seq++;
> -	out_handle.length = sizeof(handle_seq);
> -	memcpy(out_handle.value, &handle_seq, sizeof(handle_seq));
> +	/* Preserve the handle throughout a multi-step negotiation. */
> +	if (pending) {
> +		out_handle.length = sizeof(pending->id);
> +		memcpy(out_handle.value, &pending->id, out_handle.length);
> +		free(pending);
> +		pending = NULL;
> +	} else {
> +		handle_seq++;
> +		out_handle.length = sizeof(handle_seq);
> +		memcpy(out_handle.value, &handle_seq, sizeof(handle_seq));
> +	}
>   
>   	/* kernel needs ctx to calculate verifier on null response, so
>   	 * must give it context before doing null call: */
> @@ -421,7 +552,6 @@ handle_nullreq(char *cp) {
>   
>   	do_svc_downcall(&out_handle, &cred, mech, &ctx_token, ctx_endtime,
>   			hostbased_name);
> -continue_needed:
>   	send_response(&in_handle, &in_tok, maj_stat, min_stat,
>   			&out_handle, &out_tok);
>   out:
> @@ -436,6 +566,7 @@ out:
>   	return;
>   
>   out_err:
> +	free(pending);
>   	if (ctx != GSS_C_NO_CONTEXT)
>   		gss_delete_sec_context(&ignore_min_stat, &ctx, &ignore_out_tok);
>   	send_response(&in_handle, &in_tok, maj_stat, min_stat,
> 
> base-commit: c2dc3ff598dec9786217d22e40eaca3f295e8b45

