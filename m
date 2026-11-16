Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794840788;
	b=DZUV9pdcJNXeq+QEtqgxVJy0nSh7wD5jZtVNbclH+CdHBEBO341flPfC+QkIPTDc802j
	 zplOgcrNGjGvc0kDHWDnsQ05Q/EUaZ0IZoAZXxCn+f4Nrvv40Vfrh5BwEP5H7KwtxG7ZR
	 +GzydeYh8p/Kf0hHnfvjhJkwn6kxLkQKKLBAJ2MEtA8foGFxZQ1ScJYbLfQuyGNyvHpnR
	 N1OJyAdF5rbaBN5ERl48hkQj/6V7uQtgUAy/hRQM7FEy+dfCSuVK4DbEHsrqXrLQFtDoW
	 WvifrDMEJ6OZpjz/lWwcA8H43t7h+6I0o94hqMs3vJyS03VdSHuGF/VoguIVeuJderg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794840788;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:Message-ID:Date:MIME-Version:User-Agent:Subject:
	 To:Cc:References:Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=I1EXZXp9l4c7aM3b15jJQ+9FXtAI9KA9ZuBfHbrNsJA=;
	b=dSNLqnBsCz2p8D25BNvmaCwLXjOQ+g7yJftzHEWp86wWDH9Iy38LkgbKkwa5Hf2ZZ4As
	 QZOyw+dmc2OKdAUESG10L1RLzOaGW/A1CdEGUoin+N7hS7s3pObE5SySFAUGbrltQgaQI
	 BFfTcx41vZYtxsKMR7JUXjrbjnnxaGc+QE82t5f+uudaw2xvflM9iyPzLo6McXppsoBwC
	 o+ZvpEZy4oQPFbyt78h2D/krJ6ky7LyWTOY8W6d+afJ5BjykYT5qZF2+AkuxWieGBXzzC
	 +adohVPpJnpQcgHw50oXLnA5TzcuPNd+WoUZCO0TGb+hRwC2Gik6NXAw5h1tbBW0ahg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Fji44hKZ;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=AnHqHbHy;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F12C606A31C
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 14:53:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9F12C606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Fji44hKZ;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=AnHqHbHy
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794840786;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=I1EXZXp9l4c7aM3b15jJQ+9FXtAI9KA9ZuBfHbrNsJA=;
	b=Fji44hKZbBs75vvmibChPAU9XoCVQx9cByPvSkWoTLXB+2KiJ6ZWxHr29rOu/ngwrRXMcN
	jWMhCo6XUZbo4edxvd3M40y1posattq6flvrDf/OTD86QlK/WUFIcZotrpnTKP9xaxa/sE
	OrZRdbUz78gu+7fk8bhyRvEkb70SEJU=
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com
 [209.85.222.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-53-tOjY_H9hN3y_SKQdOJZSYQ-1; Mon, 16 Nov 2026 09:53:05 -0500
X-MC-Unique: tOjY_H9hN3y_SKQdOJZSYQ-1
X-Mimecast-MFC-AGG-ID: tOjY_H9hN3y_SKQdOJZSYQ_1794840785
Received: by mail-qk1-f200.google.com with SMTP id af79cd13be357-94970ad532bso254117085a.0
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 06:53:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1794840785; x=1795445585; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=I1EXZXp9l4c7aM3b15jJQ+9FXtAI9KA9ZuBfHbrNsJA=;
        b=AnHqHbHydP6E+TqdX2B3lb3vVhg7dL6XOJqsO75jJRbgZ6pK01Jelf1fbK0Ml6ZOBS
         Ve0RTz3cQET/PR/MGV06QnERlC0PYtlEi2H9wUCaefBhMHiA4b31iYYd+TvNo/4YkFe1
         QGhbbavghMYHkHpHqYq/IBKMNpr7toi5mi+ZtyzKbhK1bBJmOtr/JW8yuDlK1kFmCkHu
         pIz13Y5l18v/RrKh455q/tRlxSLDO8ipAx9dZINMwcCUQB4C2la+Ty0bMUEs24i509ey
         WcfxRBCTx4DrAfcgcEff7IjXKWdJbDgifezTv45lZGAzo/+8Qhzqz6cHtV+Xu+8zm79R
         obCQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794840785; x=1795445585;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=I1EXZXp9l4c7aM3b15jJQ+9FXtAI9KA9ZuBfHbrNsJA=;
        b=XI89TikdGzdOkbsQ/lytVgVIooqz8Da5LH5gNUhswc1C5gdcJTAf2cgVbP2s+MPZxw
         M03mHlGbNHVNNF4c6Sfa1ELoZ3miy1uY9zTgSNrlPcywJglLS/9LNxg1x/e3F3QEKiXN
         OlO/BlyP4YeYz2XiOh+pOxg0hJtKE1n6l6l2Uhf7Sj7pTW1/70IQw8Ls9qyWam01TSIq
         tyT3HvXnduMWgeWtJQh0V0h+zAYQQ6YUnYIOWm0VJmKHzJ3Ril45oZ6rA4NVCV02c8Fl
         ZXX7c6cTNqntg6x7OvCildIWCbICaFXxcHJfsDaSHN/WDX9owq20JOD0VllR9VsU8Fqb
         nJ2g==
X-Forwarded-Encrypted: i=1; AL+hErHeqnxbaq3HyM0EcG0FmEpnSfRbS1njnhRW4JtFnbruWMetB2xps2lBYEaAXcdb5PgnTjc2RSS+wuU=@vger.kernel.org
X-Gm-Message-State: APuU4Z/O0j4YKriXzpyMvg5fjLHw65XcTj0YjVYw8uLJFid2IvJAB9Mn
	3clranOvfX+4dNdu498ZQUw1bNC3zFi1eKVZ4Yynd1TARNqyPzuC1zRseE2aQ6r80TspJSHVcxQ
	5xucE1pRZfc0N4ft2A7KsqxcWuJbEpf6511wwSVwXZS6zCzY2A3WuWzX4Kt+UeQ==
X-Gm-Gg: AYBFou33G9IFIkWM5lHS4kmnzBqxrhVsASmArbWzFoWlFGhvS+j1+xl8VOkcxkmFOX5
	pjbuTYbygAnfzmLvO0zXTtcXzjdvQSCZm57IiXUZazskL2TM6I4jgf7lGsoBWL3znD3Z8T33iwM
	oBUFuhFsmPE1909I0rm8MbARB6AKS3wZcrCmEfs54wX08GTZuRpNwVauB2ypAtwZGj3aUFq07TW
	UmGzUBjmKZFJWVcdGrVNsx+yWKEz+wQUs/qltUvm5qVPFsRF3L48hsY+KXt1yYnzEhJaRJ2+cYl
	nxKzJnbrn6KqJ/nN11H8Kteuuc7uDFav0OulzEDH8KO/VOPmHl/vW+yII9sBwn8QtWovESt4vf2
	yYnF1j7gjhasIIMl6HN+ucAqNYF7SBd2OOBhTCL72lZOzqxJt
X-Received: by 2002:a05:620a:6287:b0:93e:c12c:9b6c with SMTP id af79cd13be357-9494bce8c48mr1710975685a.71.1794840784698;
        Mon, 16 Nov 2026 06:53:04 -0800 (PST)
X-Received: by 2002:a05:620a:6287:b0:93e:c12c:9b6c with SMTP id af79cd13be357-9494bce8c48mr1710971485a.71.1794840784100;
        Mon, 16 Nov 2026 06:53:04 -0800 (PST)
Received: from [172.31.1.12] ([70.105.240.105])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9496c9f1e7bsm516305385a.13.2026.11.16.06.53.01
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 16 Nov 2026 06:53:02 -0800 (PST)
Message-ID: <3ed15a24-1926-4d4b-80b8-64148c3380be@redhat.com>
Date: Mon, 16 Nov 2026 09:53:01 -0500
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
Subject: Re: [PATCH v2] gssd: fix build failure with musl libc
To: Giulio Benetti <giulio.benetti@benettiengineering.com>,
 linux-nfs@vger.kernel.org
Cc: "Claude Opus 5.5" <noreply@anthropic.com>
References: <20261112172732.397411-1-giulio.benetti@benettiengineering.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20261112172732.397411-1-giulio.benetti@benettiengineering.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 11/12/26 12:27 PM, Giulio Benetti wrote:
> gssd prints thread IDs with the '%lx' format specifier, which assumes
> pthread_t is an unsigned long. This holds on glibc, but on musl
> pthread_t is an opaque pointer type ('struct __pthread *'), so building
> with -Werror=format fails:
> 
> gssd.c:546:78: error: format '%lx' expects argument of type 'long unsigned int', but argument 3 has type 'pthread_t' {aka 'struct __pthread *'} [-Werror=format=]
> 
> Fix this by explicitly casting pthread_t to unsigned long wherever it
> is printed with '%lx' in gssd.c, gssd_proc.c and krb5_util.c. The cast
> is safe since the value is only used for logging and unsigned long is
> pointer-sized on all Linux ABIs. The output is unchanged on glibc.
> 
> Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
> Signed-off-by: Giulio Benetti <giulio.benetti@benettiengineering.com>
Committed... (tag: nfs-utils-2-1-2.rc4)

steved.> ---
> V1->V2:
> * fixed and improved commit log
> ---
>   utils/gssd/gssd.c      | 14 +++++++-------
>   utils/gssd/gssd_proc.c | 18 +++++++++---------
>   utils/gssd/krb5_util.c | 10 +++++-----
>   3 files changed, 21 insertions(+), 21 deletions(-)
> 
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index 022f0a89..5203d0a7 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -544,7 +544,7 @@ cleanup_active_thread_list(void)
>   		default:
>   			/* EDEADLK, EINVAL, and ESRCH... none of which should happen! */
>   			printerr(0, "watchdog: attempt to join thread id 0x%lx returned %d (%s)!\n",
> -					info->tid, err, strerror(err));
> +					(unsigned long)info->tid, err, strerror(err));
>   			break;
>   		}
>   	}
> @@ -554,12 +554,12 @@ cleanup_active_thread_list(void)
>   			switch (err) {
>   			case EBUSY:
>   				printerr(0, "watchdog: thread id 0x%lx still busy on shutdown\n",
> -					 info->tid);
> +					 (unsigned long)info->tid);
>   				/* fall through */
>   			default:
>   				/* EDEADLK, EINVAL, and ESRCH... none of which should happen! */
>   				printerr(0, "watchdog: attempt to join thread id 0x%lx returned %d (%s)!\n",
> -						info->tid, err, strerror(err));
> +						(unsigned long)info->tid, err, strerror(err));
>   				/* fall through */
>   			case 0:
>   				saveprev = info->list.tqe_prev;
> @@ -611,7 +611,7 @@ scan_active_thread_list(void)
>   			 */
>   			if (tret == PTHREAD_CANCELED)
>   				printerr(2, "watchdog: thread id 0x%lx cancelled successfully\n",
> -						info->tid);
> +						(unsigned long)info->tid);
>   			saveprev = info->list.tqe_prev;
>   			TAILQ_REMOVE(&active_thread_list, info, list);
>   			free(info);
> @@ -628,14 +628,14 @@ scan_active_thread_list(void)
>   			if (now.tv_sec >= info->timeout.tv_sec) {
>   				if (cancel_timed_out_upcalls && !(info->flags & UPCALL_THREAD_CANCELED)) {
>   					printerr(0, "watchdog: thread id 0x%lx timed out\n",
> -							info->tid);
> +							(unsigned long)info->tid);
>   					pthread_cancel(info->tid);
>   					info->flags |= (UPCALL_THREAD_CANCELED|UPCALL_THREAD_WARNED);
>   					do_error_downcall(info->fd, info->uid, -ETIMEDOUT);
>   				} else {
>   					if (!(info->flags & UPCALL_THREAD_WARNED)) {
>   						printerr(0, "watchdog: thread id 0x%lx running for %lld seconds\n",
> -								info->tid,
> +								(unsigned long)info->tid,
>   								(long long int)(now.tv_sec - info->timeout.tv_sec + upcall_timeout));
>   						info->flags |= UPCALL_THREAD_WARNED;
>   					}
> @@ -656,7 +656,7 @@ scan_active_thread_list(void)
>   		default:
>   			/* EDEADLK, EINVAL, and ESRCH... none of which should happen! */
>   			printerr(0, "watchdog: attempt to join thread id 0x%lx returned %d (%s)!\n",
> -					info->tid, err, strerror(err));
> +					(unsigned long)info->tid, err, strerror(err));
>   			break;
>   		}
>   	}
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index d59c8a19..6bf5f2b5 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -186,7 +186,7 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
>   
>   	if (get_verbosity() > 1)
>   		printerr(2, "do_downcall(0x%lx): lifetime_rec=%s acceptor=%.*s\n",
> -			tid, sec2time(lifetime_rec), (int)acceptor->length, (char *)acceptor->value);
> +			(unsigned long)tid, sec2time(lifetime_rec), (int)acceptor->length, (char *)acceptor->value);
>   	buf_size = sizeof(uid) + sizeof(timeout) + sizeof(pd->pd_seq_win) +
>   		sizeof(pd->pd_ctx_hndl.length) + pd->pd_ctx_hndl.length +
>   		sizeof(context_token->length) + context_token->length +
> @@ -212,7 +212,7 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
>   	return;
>   out_err:
>   	free(buf);
> -	printerr(1, "do_downcall(0x%lx): Failed to write downcall!\n", tid);
> +	printerr(1, "do_downcall(0x%lx): Failed to write downcall!\n", (unsigned long)tid);
>   	return;
>   }
>   
> @@ -225,7 +225,7 @@ do_error_downcall(int k5_fd, uid_t uid, int err)
>   	int	zero = 0;
>   	pthread_t tid = pthread_self();
>   
> -	printerr(2, "do_error_downcall(0x%lx): uid %d err %d\n", tid, uid, err);
> +	printerr(2, "do_error_downcall(0x%lx): uid %d err %d\n", (unsigned long)tid, uid, err);
>   
>   	if (WRITE_BYTES(&p, end, uid)) goto out_err;
>   	if (WRITE_BYTES(&p, end, timeout)) goto out_err;
> @@ -388,7 +388,7 @@ create_auth_rpc_client(struct clnt_info *clp,
>   	/* create an rpc connection to the nfs server */
>   
>   	printerr(3, "create_auth_rpc_client(0x%lx): creating %s client for server %s\n",
> -		tid, clp->protocol, clp->servername);
> +		(unsigned long)tid, clp->protocol, clp->servername);
>   
>   	protocol = IPPROTO_TCP;
>   	if ((strcmp(clp->protocol, "udp")) == 0)
> @@ -432,7 +432,7 @@ create_auth_rpc_client(struct clnt_info *clp,
>   		tgtname = clp->servicename;
>   
>   	printerr(3, "create_auth_rpc_client(0x%lx): creating context with server %s\n",
> -		tid, tgtname);
> +		(unsigned long)tid, tgtname);
>   #ifdef HAVE_TIRPC_GSS_SECCREATE
>   	memset(&req, 0, sizeof(req));
>   	req.my_cred = sec.cred;
> @@ -583,7 +583,7 @@ krb5_not_machine_creds(struct clnt_info *clp, uid_t uid, char *tgtname,
>   	pthread_t tid = pthread_self();
>   
>   	printerr(2, "krb5_not_machine_creds(0x%lx): uid %d tgtname %s\n",
> -		tid, uid, tgtname);
> +		(unsigned long)tid, uid, tgtname);
>   
>   	*chg_err = change_identity(uid);
>   	if (*chg_err) {
> @@ -632,7 +632,7 @@ krb5_use_machine_creds(struct clnt_info *clp, uid_t uid,
>   	pthread_t tid = pthread_self();
>   
>   	printerr(2, "krb5_use_machine_creds(0x%lx): uid %d tgtname %s\n",
> -		tid, uid, tgtname);
> +		(unsigned long)tid, uid, tgtname);
>   
>   	do {
>   		gssd_refresh_krb5_machine_credential(clp->servername,
> @@ -976,7 +976,7 @@ start_upcall_thread(void (*func)(struct clnt_upcall_info *), struct clnt_upcall_
>   		return ret;
>   	}
>   	printerr(2, "start_upcall_thread(0x%lx): created thread id 0x%lx\n",
> -		tid, th);
> +		(unsigned long)tid, (unsigned long)th);
>   
>   	tinfo->tid = th;
>   	pthread_mutex_lock(&active_thread_list_lock);
> @@ -1041,7 +1041,7 @@ handle_gssd_upcall(struct clnt_info *clp)
>   	}
>   	lbuf[lbuflen-1] = 0;
>   
> -	printerr(2, "\n%s(0x%lx): '%s' (%s)\n", __func__, tid,
> +	printerr(2, "\n%s(0x%lx): '%s' (%s)\n", __func__, (unsigned long)tid,
>   		 lbuf, clp->relpath);
>   
>   	for (p = strtok(lbuf, " "); p; p = strtok(NULL, " ")) {
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 7ad67131..0e8f889b 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -435,7 +435,7 @@ gssd_get_single_krb5_cred(krb5_context context,
>   	pthread_mutex_lock(&ple_lock);
>   	if (ple->ccname && ple->endtime > now && !nocache && !force_renew) {
>   		printerr(3, "%s(0x%lx): Credentials in CC '%s' are good until %s",
> -			 __func__, tid, ple->ccname, ctime((time_t *)&ple->endtime));
> +			 __func__, (unsigned long)tid, ple->ccname, ctime((time_t *)&ple->endtime));
>   		code = 0;
>   		pthread_mutex_unlock(&ple_lock);
>   		goto out;
> @@ -495,7 +495,7 @@ gssd_get_single_krb5_cred(krb5_context context,
>   
>   	code = 0;
>   	printerr(2, "%s(0x%lx): principal '%s' ccache:'%s'\n",
> -		__func__, tid, pname, ple->ccname);
> +		__func__, (unsigned long)tid, pname, ple->ccname);
>     out:
>   	if (opts)
>   		krb5_get_init_creds_opt_free(context, opts);
> @@ -631,7 +631,7 @@ get_full_hostname(const char *inhost, char *outhost, int outhostlen)
>   	retval = getaddrinfo(inhost, NULL, &hints, &addrs);
>   	if (retval) {
>   		printerr(1, "%s(0x%lx): getaddrinfo(%s) failed: %s\n",
> -			 __func__, tid, inhost, gai_strerror(retval));
> +			 __func__, (unsigned long)tid, inhost, gai_strerror(retval));
>   		goto out;
>   	}
>   	strncpy(outhost, addrs->ai_canonname, outhostlen);
> @@ -642,7 +642,7 @@ get_full_hostname(const char *inhost, char *outhost, int outhostlen)
>   
>   	if (get_verbosity() && strcmp(inhost, outhost))
>   		printerr(1, "%s(0x%0lx): inhost '%s' different than outhost '%s'\n",
> -			 __func__, tid, inhost, outhost);
> +			 __func__, (unsigned long)tid, inhost, outhost);
>   
>   	retval = 0;
>   out:
> @@ -990,7 +990,7 @@ find_keytab_entry(krb5_context context, krb5_keytab kt,
>   					tried_upper = 1;
>   				}
>   			} else {
> -				printerr(2, "find_keytab_entry(0x%lx): Success getting keytab entry for '%s'\n",tid, spn);
> +				printerr(2, "find_keytab_entry(0x%lx): Success getting keytab entry for '%s'\n", (unsigned long)tid, spn);
>   				retval = 0;
>   				goto out;
>   			}

