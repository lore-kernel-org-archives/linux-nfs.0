Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793473046;
	b=1cj378vURzfV7ReoBedredj8prm3/E5F5pdMNYQsLYIRxsu7CY16S3IZOgP4ehwWBOyg
	 HJNngjUPKe1uYDLiLiW+R1ukSc3s9WyUSbR7L6EKnlmF+dY41BLQRv+6mH2MDhLw6/l2d
	 SImJYf4M61i9M54Q+jLhgTxwM+b0Va88NSlVdGWGUQm74x/v0x0ntvirLMVA+0OA1CMDG
	 7eD98P1qprcJvlI/EkftTgrpBfIiVOejn1xvUQk7Gpicsp+82oqL8pOhpZozv2RfjAmdV
	 AWGrksYP1MKie2RkuiPQv7fsLTkiwfCPkmNuyaXECOBxmnLZw8T8V9nP8I8vlB2g8NQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793473046;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=z25C4agnQblskxb4WaOy3UX7zztZGIB741WF3MNIsNk=;
	b=Yzh0kGEVq97LsVVopz91NdKNkzDN8NQ987Ao3dQWeptR2mqiyO1gBQI/B6nt8Z23r2pI
	 nN6QgSuDjn54zFAOmi8wJIhUDEmzKoLhMMGLbi73z6tM/W4979A9ZhhGkBC58m7PGJKMA
	 I9R19iOfEef/abH2Aaw8izpXyyBFkiXv2lA/rYarjt8RQQpCYlZRq6X7Eg+YSenPCzsPf
	 MQ/kM9kPvbtY6RrOGrG15ajUkkFcst3LTpCHmlGb0jZnmCh9D5bQQ0KM6ZpitOrMTAP0Q
	 Z/l8SEZp6vXttwd9CKmOazUc5f/qBTmazBGfaq2Znty90BprJTHkRfCsG0BBhma6bbA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=xvIxMZSF;
	arc=none smtp.remote-ip=209.85.218.51
Received: from mail-ej1-f51.google.com (mail-ej1-f51.google.com [209.85.218.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F2C9606A31A
	for <linux-nfs@vger.kernel.org>; Sat, 31 Oct 2026 18:57:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7F2C9606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=xvIxMZSF
Received: by mail-ej1-f51.google.com with SMTP id a640c23a62f3a-c4322d310e7so286848466b.0
        for <linux-nfs@vger.kernel.org>; Sat, 31 Oct 2026 11:57:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793473045; x=1794077845; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=z25C4agnQblskxb4WaOy3UX7zztZGIB741WF3MNIsNk=;
        b=xvIxMZSFg5ZqzaYHjlQ1lGYtmQY7gMNT3GDDzNogZfSY0pe1gDN6uLl6FWRX3UPDox
         +5ok0BfnLAMm6D+ZzF8BNGc/RkX/8oPEbeU5lXAPku5hPPf2uFU7ZWw4JfrfrsTrbGi4
         jCUHMhKwe20UrQx52gMrw7SmeJhF9oDm+TwVzzSNebRMRnQeieuX4ulHsNdGeVhkbDYP
         BsxAMtWfAjyrXNSB8EpeKPOloSq7s8KlYRHA6OAi57v92j91owrq5sAlVWhk+uaOsn1I
         dWOQZFT2tlzzHXzK1Ntd9aDjrFfU1WC6SUtVNKJGsgakCdFT9osU6Qa6XBFhBio0U3rG
         ZZzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793473045; x=1794077845;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=z25C4agnQblskxb4WaOy3UX7zztZGIB741WF3MNIsNk=;
        b=2iKidJjlvWm0WdDTUH9TS+GqYonL5P819zbJKMN4yhAMEBjc3CnAlybkGpiwUU+8Cn
         1Q9HxZeReqmVAyAUVtsaTb7gnl0QFyHMmpRxcxYlqc5/m/3kLtSFJQQ5XSjLr5QpsncY
         IPhf0AQAEargB7rVKipeDInbJy5EBrcSA+JVkDkcv8SXRLCMpEGaHoNXq3Fl3rixaxA6
         ukGN1wmOMbsotG13+ne6G57JArrRlvoVyk0xtVi3R2zjWzUsesLaWGHxcjOLebmoKfFs
         uJoTyNl2xJ8fopv04ro5Ii1hHIom+ROvIQPjNynB936yfTa3fE75/ah2K1sGvJbOOvdR
         XnAA==
X-Forwarded-Encrypted: i=1; AKwUvBwYRto9MjHoY26OAZKHO62WeEIDcMwBXTgLbk3/dbOUTAEijhWRKaV9jiRFSKiD9QF/lvwpE3Xsc8M=@vger.kernel.org
X-Gm-Message-State: AFq9FYKgFbLf988MEq3xFkJaJWtaE8Bh9b1UHQ4z0yyRxMFrmp7y4QOW
	omV/wpqbsVL4QGHIspFip90otlFSZCvwHE06SNjPjg8xg22BqZkn8XGr
X-Gm-Gg: AYBFou0YvEWR9L0M1YVl+Jurjhl7BjmlxmXWzK+B6x9V/UktRURVNTGsxW1iyNqb4qn
	2ji7ZXFt5mmZ2NOt7PzRRnv/DNbzU4lbjYiMhz1IKVULtoZq/rvchgbZ+xZka4PEDdIiNDbZmNk
	SqBHURvk+MUzmHcXAPl3sR1PLwFQ1U0uubGBtBvs/dyMQlxcFDTpPc7C+tBxNLPdceMBgsXwYTw
	O7VZ9rB11fPGHIRMnQu5+HIrJATP4UV3I5tkyOCSh/h48lkoo0+pmzyeCRH1RSP3U0Ihwz2aFQL
	NGX1C4LmYH/+iDd4AHjEfAAbspNN4NlaDrhvM5HO4uLgvXb2TOqlwgoqXe99kpEe6rjg4eE/rzj
	6FJsHwBzVqBEn9K8NKJHTDHMgh6nbPx2/KHAwBMzgqZqkUXFQlx+KAurpal4fPmkxDS2tYUCMq0
	uhkmRLoFi+E+GtGS+7WNTFN5+fVC+aVdPVc9Zgp2rePyd/d+2/d0sT74KgD3zl3Ku4y44Qg/vU6
	ckbGXlgzsalDetms1PVtoigxAcEBQnDzmZZ9kl2u3ibv1TDJCodqHhbg5RNueWA3ZToMnCgdM/m
	j8AEcgRDG/kvI0aPqjQZHxczDBkJIFun7OmIa9hgLm/fyZmnG0Ar3W+/2x/1XdhCTEB5mZ24
X-Received: by 2002:a17:907:160f:b0:c42:102f:15db with SMTP id a640c23a62f3a-c4ca7ab0b1bmr475744466b.34.1793473044703;
        Sat, 31 Oct 2026 11:57:24 -0700 (PDT)
Received: from localhost.localdomain (173.242.112.181.16clouds.com. [173.242.112.181])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c4cabcfd21asm208144066b.18.2026.10.31.11.57.21
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 31 Oct 2026 11:57:24 -0700 (PDT)
From: VeroFess <coderzeng@gmail.com>
To: cel@kernel.org
Cc: jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 0/3] NFSD: Enforce export security after a deferred PUTFH check
Date: Sun,  1 Nov 2026 02:57:13 +0800
Message-ID: <20261031185714.1021-1-coderzeng@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261030-verofess-v5-0-242eea2991f3@kernel.org>
References: <20261030-verofess-v5-0-242eea2991f3@kernel.org>
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

On Sat, Oct 31, 2026 at 05:27:34AM +0800, Chuck Lever wrote:
> The series as posted has not been run against the reproducer yet.

Thanks for splitting the series. I tested it incrementally in an
x86_64 KASAN guest on d9130c9f6535: patch 1 alone, then patches 1 and
2, then the full series. I'm happy to test further revisions.

With only patch 1 applied, the NFSv4.0 reproducer returned
NFS4ERR_WRONGSEC at PUTFH for AUTH_SYS PUTFH; SAVEFH; READ and
PUTFH; SAVEFH; WRITE. The file was unchanged and the Kerberos client
could still read it, so patch 1 by itself stops the reported sequence.

Adding patch 2: with patch 1 only, an AUTH_SYS local COPY of a krb5p
source still completed and changed the destination; with patch 2 the
saved-source check made COPY and CLONE return NFS4ERR_ACCESS and leave
the destination unchanged. A permitted AUTH_SYS local COPY still
succeeded.

Adding patch 3: LOOKUPP into a krb5p parent, which succeeded before
patch 3, returned WRONGSEC, while SECINFO_NO_NAME(PARENT) still
succeeded. READDIR with rdattr_error reported WRONGSEC for the strict
child, and the NFSv2/v3 CREATE cases returned ACCESS. Over plaintext
TCP, SECINFO into an xprtsec=tls child returned NFS4ERR_ACCESS while
LOOKUP returned WRONGSEC.

On the full series I reran the earlier regression suite: Btrfs local
COPY and reflink CLONE succeeded with matching destination bytes, and
asynchronous inter-server COPY completed 4096 bytes between two guests.

I also rebuilt the full series with CONFIG_TLS=y for an RPC-over-TLS
run. On NFSv4.0, v4.1, and v4.2, a plaintext client could read the
parent export but could not enter its xprtsec=tls child; a TLS client
could read the child. For an xprtsec=mtls child, TLS without a client
certificate was denied, and mTLS with a trusted certificate succeeded
on all three versions. A raw NFSv4.0 PUTROOTFH; SECINFO request
returned NFS4_OK over both TLS and mTLS.

The W=1 fs/nfsd/nfs4proc.o build and the 259-case ASan/UBSan check
passed, with no KASAN reports.

Tested-by: VeroFess <coderzeng@gmail.com>

Thanks,
VeroFess
