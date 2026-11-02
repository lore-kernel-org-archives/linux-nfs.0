Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793628529;
	b=Q/7VJWHAZTUXj2eR1oXNI43Rr9HbASwUtg/hD2FAXAco8PJuDdPCZOZFPAjbRjJW2X0c
	 FGT7tl6jTv1TM+V49XSVAoSRAK7TmBCEmVRIaRgG6rb2efoeuXCQsBDOKeqp0XYP/qURh
	 DgdnyGk/m9VbF7vQOSSjUIFMiiug+G+an4TzsQjdSHJLUFy14+kLr6A5x7LlWRXsQGuFv
	 L7Vw38AwgrObW/dGM8SslmgMHatg5lRs8KmgG+oiStyzE8XGSiqmBx92RUe631ocFUeU/
	 9vMi20LYmIXOlj5orFRtxOtYnp+QuAIuDxmhVuloefFS7LAKGyjt1HQBYbUkMQG8sjQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793628529;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=wyrBww5sfzVjBLFAhQxqrAg0t/cy6G2gOCeJIiJUl3w=;
	b=vRNwRyDTtUhshd1vY+p+GRJ1jANSGpgu3MkqjfLLdFCV/F6Nuic4k9vcIpRHWNy3PLCU
	 QMJeTXmoDSEd3VaPOphwgxi1iD2qJo5SF5jdhkteGlZHt1lrc4NnvqFP2GmEk82KQT1S5
	 T9iXHp8ROkZOc7pDkCBTQTBXayIrkuZy/Dpr/aw3YArTzq9alYxtbRAbPJsdCq3UW7KYE
	 7smlwxFyWyrZJgpDSMCoJkNNTSW4MEtmdiHpeoDOcW1qrcSnT5O1dxpnnHoATEm0SiRor
	 zqL1vAr+EQZZ4tXBH5PB18rK+uKLuo6HfYSFdkBWhBrNPBfThaYRA5w54zwOV6qmaZQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=KMW4qho6;
	arc=none smtp.remote-ip=209.85.161.50
Received: from mail-oo1-f50.google.com (mail-oo1-f50.google.com [209.85.161.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 58ABF606A332
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 14:08:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 58ABF606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=KMW4qho6
Received: by mail-oo1-f50.google.com with SMTP id 006d021491bc7-6deb848ddd7so2352417eaf.0
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 06:08:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793628528; x=1794233328; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=wyrBww5sfzVjBLFAhQxqrAg0t/cy6G2gOCeJIiJUl3w=;
        b=KMW4qho6bzG6yf6AN2KLoolnCmCP1FJQSyJlus3aHIRzlJjudsTY28wth6l47h0ZHK
         zqm2KPAvADxyi54YAr7KvNk8fCGQlrOhrgLwPlpOu6SAjAKT93rAgo9mCZFUboKzPk5Q
         5FVlNSliFdNyZpK5RuY7AiVdCwa9CM2kLOjs8njuQEqQ6eavVQlvxZwWK859UY1Y7izX
         xUxPazIGpoU1C1AINTgFiOfEKjnM91Z1J4UB/ROhucq61NZl9RCu1gEWoFwiUEZloTiB
         O7XI5WLtrZT2bKCjs5Yox0AiNT7oemABOYqxXPpmclHEQ+HD/zQqLBHC9x3nfTjWvKjl
         NWSQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793628528; x=1794233328;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=wyrBww5sfzVjBLFAhQxqrAg0t/cy6G2gOCeJIiJUl3w=;
        b=sTVnBFHc7icvbb6H5Jrl+ZwhdfaIMecaDMNJGn1idI+d+gETWmSghcCmVEyFt4sWof
         skK0SwaH81hjwvoCuqoq1UUXB73bMo4si27rD1xWrBY9lLB4HxOWqOQ8eq4VhXqi1+uQ
         7haYONFuO1YFvawnF7Wxw3yhD5SESceGjgSTmm+XtbC3VGv9TmOKKRT/o4yJB4QykA3+
         7p03G1N1VLtJqLs2sd2OV2qEaBCxAMmoFA0VaBhw1LDUOXm/0OXIO2MNxArAVirKiFIC
         Xb+YgPnz9Kmnqrm6wcMvBxi2gIPkFFjsa0N+FzIb3blOakICx7HGJPeNA6luRFxjDJUt
         iTYA==
X-Gm-Message-State: AFq9FYLe7QHXU/Q8QkKEVZs01mre71KjNU8SywSfDRFZsHNo/fn9k1yG
	BKVvdmPlYLfqgggQI2f72Ihm3N/QP6BQAlAiOCXHOOtMPnVZsyOyyl61SzKGkX23lhw=
X-Gm-Gg: AYBFou0YwAD0vSEm5n5SUfQ+/jMNdiPe1JSlspyr9gOWtpAwxd5hezpslgukNjUfT3v
	E+4jFgB7PdFWc5GB4l0BGq1CHosOv+vQoReMCunCimwAXzhzyua+Xl+t56fF7z3KkFXGQo83SnZ
	BF9JL5jQTCk/ph8nfd6sULqjlGJA3Mz9pBwc1/wxa8BP4MZ3Nj+TBBGfLS6pwTdbz89u1FFrn2C
	pZ8zFSP3eYHMh6NLv0LdQsAKFeKeURtWKqaQ1ZgGwZHJ65BrT/RhXJbM2n4TOCmSmIkqR93axCf
	+Q0WPyX184DOpElytTu0MY85UPj5jzgT5M9aO0/nHCEspNgzJOxbAWFOL4g7QiL8MjxJ06XFcnd
	f9IkXjM281dapTi6fNX5Oone+g9jkJlNI20vLw0CZZXgM0XxREj9AcH/bO/nSpIPYSvm8ZBzby2
	0Np0g3Rt1TkpSqhNGZy/DGOFp921r9wPLrrC1HmuqPIBZrFu2pqwyP+W5BmZoN0CoQwym8WirmL
	jDWrUzD4MKualodsACk5p2ZdpmUVlBh9OiRvoL5UiA41RSRi4A6qy27clY/SBrcrTiblU5hjenX
	rdHjtNzXdUP59FCra5kPKFJObk10oLH4gNkOd+FwXQWJvUXs4SXoWyqZXHyCjO/YY8KSG3XYAgl
	RY/m2Xb2qBauCdXJi8g==
X-Received: by 2002:a05:6820:1517:b0:6f4:9618:badf with SMTP id 006d021491bc7-714f1fdbb1emr5712260eaf.10.1793628528109;
        Mon, 02 Nov 2026 06:08:48 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-714f2cf11fasm8826390eaf.3.2026.11.02.06.08.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 06:08:47 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 5/6] pNFS: answer a file recall with NFS4ERR_DELAY while I/O drains
Date: Mon,  2 Nov 2026 09:08:44 -0500
Message-ID: <20261102140845.377775-1-ben.coddington@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <4b7f08366e3ae2b89f01527e3a63e89cf7202e22.1793373378.git.bcodding@hammerspace.com>
References: <cover.1793373378.git.bcodding@hammerspace.com> <4b7f08366e3ae2b89f01527e3a63e89cf7202e22.1793373378.git.bcodding@hammerspace.com>
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

sashiko raised two points on this patch [1].  I don't think either needs
a change:

1. A file recall with clora_changed set doesn't cancel I/O if an earlier
   recall already set NFS_LAYOUT_BULK_RECALL.  That's what the valid
   layout path does too: it answers NFS4ERR_DELAY on BULK_RECALL before
   it gets to pnfs_mark_matching_lsegs_return().  The I/O drains instead
   of being cancelled, and the recall gets NFS4ERR_DELAY until it has.

2. After a recall of part of an invalid layout gets
   NFS4ERR_NOMATCHING_LAYOUT, NFS_LAYOUT_BULK_RECALL stays set while I/O
   on other segments is outstanding.  Patch 2 clears it when the last
   segment is freed, the same as after a bulk recall, and writes go
   through the MDS until then.

[1] https://sashiko.dev/#/patchset/cover.1793373378.git.bcodding@hammerspace.com

Ben
