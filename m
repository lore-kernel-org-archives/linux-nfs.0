Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793628530;
	b=hNeyiSyIykHL/cvvECuEval9lmonU31b7yPg5I5mjfokqyomeQ788HnN/DkmmgzL4FZt
	 8ooy2FdoOaKKvNDB/+J2bRgWb2o4aLf2TwJTbfNhXyKS8p9WBYAL1zsdbxinIZ9K59W2e
	 Zfm2XSlPwNPwO8kHFSkeRv6dlpcFw6ywIiaV98jxFfAxKNktMQcdHgsHPSPt3C2hZIrfe
	 BoG0dZXqfnhQ0JtVJTA3qQGIoDKzqLNe/axsf3Dzoo77VfB3NxE5/rM0iidxjm12Tnrog
	 nNu6MeLCumqLKV2ta5wMFeEDYa8s+iLL+6MX1b9JvWEZxEuQQNHXeRhQ7hdJSs3Ahmw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793628530;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=uHiOF4LsW2xBysTRUmk9qFEJxoCqc42BfVQK5BItBZ4=;
	b=eqWLHQUMlCcvNQBLTTWy83GuyNXBiR6spKLEnrPkIAdiPcXLChBP70Pbuu+iKbgOdUVT
	 x7vIQPQA84kv21smf+UteFcBQG/6HiogELUdS7+H/pJz67BruqmncTJsjQOrUJ9gs/HKq
	 BS+xMGTLId0ZtFb+ObzDSSLeyVSeIoTa4T5PDfzJUYFvrkZxnivMIXfDVlKz+GQ0shpMu
	 Mjru27R7rTRMG9t/k9pkY5kWLCT/aE6xJajvF7B516X5PHZWZw61R+ifG2CKih1nXl2C0
	 PFTUU7l1kJYK+wdTHczG1JFvOs83XRRVjrxUWga4I+sNvQNWmnxxn5su28SqfiMFY8w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b="KW/XEHN3";
	arc=none smtp.remote-ip=209.85.161.42
Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83F03606A33A
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 14:08:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 83F03606A33A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=KW/XEHN3
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-6de1fd5f572so1271041eaf.3
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 06:08:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793628529; x=1794233329; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=uHiOF4LsW2xBysTRUmk9qFEJxoCqc42BfVQK5BItBZ4=;
        b=KW/XEHN3IeFHbrSLZqUjm6D6Kkud4heNYwjcITQhSZ8ATM/V1AhdlHAQG0F0E8D9f3
         LdAJS31MFEHSCRm7yPYeAcQVPLTUU1WJw9gktPeozdvmmeBz5+/SAkMDO0lvoa/dhXQ3
         ZwLtY3sK4zpCnbBqsBGPQKLMnvXAUR4hVEQHv5CpSLvp3mFfVTpQ9kHzrxCvrPF6uO1Y
         N0CsWW8YSoG4ixFicnpDa4w9Ah/WQhyGC1SvFV6PwwH0Y3EYchD7fbOsaHPoo2eNxy7L
         DuZpSgh+jAKZzk+xJ3Rj5EwkXwXp+jxUTNMIwwAunrS/HDs7z8Vr8ePwgb4a7N39p3fu
         qGuA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793628529; x=1794233329;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=uHiOF4LsW2xBysTRUmk9qFEJxoCqc42BfVQK5BItBZ4=;
        b=lxS52tEIHhFUU53O/bVTXDayrU+/+V1WVqzGsKw/iYTyfKbYRA0gP3HHaY+16VI3Yr
         lypG1wBUhv2gFBLxT7ME7nAzLiPON9WMI8Q/3KLnPM7eRFQrWToX89EF+/a9lXHrmgX5
         hFQixcow60PbQE0FydeVR0Ct2bAhd8sWpUpQDlU3837oJUDyI6UHeCloMBdkWgGb09ds
         BCL0I2zx2aNZLCTnbCr5t9ecEe3kKMsltXP4TaEWjzjGBTspIZfRG3eraVtnvXP73+Oh
         1uYxcCDkbyPA6gWnHn5zdtqJmo4GEiGaXNEX+MbjDvnX2BE+B9U0NcrRdYMrSbl5ixLQ
         8NOQ==
X-Gm-Message-State: AFq9FYKk7IVlS02hcno34K6o4qlclE6jmydaAUDsLWRJu0n/aqXQIGE2
	CqPzpcDBRC2PcTx/pd3Hcw4fyVyR1zkcIGJRnQAGPdU2OFD+IBETBc4js09z2sc70p8=
X-Gm-Gg: AYBFou3U9mczTQ/ak+yYHfI/w8vYKCpJpYhgnlYDpVtfraQa44M5GGAB81Wo7NPEDII
	yKuosQqmb64UNMFBt+cZ/8LOR83n/CeWvaIT8oekjVjM3uPN+8LJ5ufBO9FPY6VvtqoDC0Lxdxk
	S3sKKrMQBLznah//gbDdxWsWfGUHy2hE6KQeCVimYW4j1HE9+GmhUBiXDhktfOm4n44KzYkTEgx
	TpU/zD+wV5moMeh4kb7rFc/Yk/AHNWN+pjr0WqCN/5oQFzeV5Pd5aX1jx5sAn29MaV22dke0F5Y
	ajKmvy9SjFov6OrcXMbv0Cp2WjL+vUkiYKtfDPThy8OmWpHVXQO8VFucj10JSFlcUfYjr7905Qn
	pNMJlLqwiytOAQ3mZC+OrJDrDYSWk/tuFBMM9jGwJfq9Y06K0gjwIBdJuArn6wpIY1qY6K2G1NZ
	Gzk5KTPPAfm9izttbhaUiydagtf7mH/CVgsfoSwqOhzyRlKwYEH03tOW/t/tmHuJh9uzK3BQfCg
	BI+uBe3RZ48BBnHLdOnJo8bspMqVDdVVPX4ZJc0cIPgS41KX1M0GQoXq1AAxDu311GcYexCMKq8
	ik5fmLOCevtxfBjdd9NE8KzjjKMzhs8OyNM23QjqLAdyhkC4D+iiTkdunAtcQmtoYwVApzD5
X-Received: by 2002:a05:6820:a515:10b0:704:b7df:f29c with SMTP id 006d021491bc7-714f24b9fbfmr3511916eaf.10.1793628529300;
        Mon, 02 Nov 2026 06:08:49 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-714f2cf11fasm8826390eaf.3.2026.11.02.06.08.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 06:08:48 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 6/6] pNFS/flexfiles: write through the MDS while a recalled layout drains
Date: Mon,  2 Nov 2026 09:08:45 -0500
Message-ID: <20261102140845.377775-2-ben.coddington@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <19211fc88f00f39a513bb1380e4675c066611bf8.1793373378.git.bcodding@hammerspace.com>
References: <cover.1793373378.git.bcodding@hammerspace.com> <19211fc88f00f39a513bb1380e4675c066611bf8.1793373378.git.bcodding@hammerspace.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

sashiko flagged a writeback spin here [1]: with FF_FLAGS_NO_IO_THRU_MDS,
ff_layout_pg_get_mirror_count_write() returns -EAGAIN without waiting
whenever pnfs_update_layout() can't get a layout.  That happens with
NFS_LAYOUT_RW_FAILED set after NFS4ERR_LAYOUTUNAVAILABLE, or while
LAYOUTGETs are blocked by pnfs_commit_and_return_layout().

That came in with 1d62e659c0bf.  This patch takes the draining recall
case out of it and leaves the rest as it was.  The pg_init paths already
wait a second in ff_layout_pg_retry_wait() before retrying
(fde27289503b), and ff_layout_pg_get_mirror_count_write() could do the
same.  I'd rather send that separately.

[1] https://sashiko.dev/#/patchset/cover.1793373378.git.bcodding@hammerspace.com

Ben
