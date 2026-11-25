Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.216.99
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795638563;
	b=kzrmfEqwu95pRlEjDyFhE1BsDIGCjdtQuQNkWA4i4/q1hLe5znrGWeX9If0m0Tn2jyNt
	 w9nC4McMDEScYgLVrbeg1uU0CCvlfsln+0bLDY34/6j2WZVVg8vuMDla6koTSxnDv7rdi
	 HvJjt9GerXM8q89XvLihf0zmcT9CpY7VevjhJSK3EMMyVieS9YCnZJN6+s101h1B2dfI+
	 M6UwrjhE6NfDIH1NtH3+ESoCpqCXbXLFtmtRmKl1Habnx+m+IlR2TUTU/ExeZTQR7aiLF
	 MseFdHygnT3LjLRVChJ0QcL4cqGs4xAItFfensNnBYjnlHZ+hQ1aS1NClYF8EjcxqxQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795638563;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Subject:From:To:Cc:In-Reply-To:References:
	 Date:Message-Id:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=l8Vm7b6mvicOGbNITWz8S9UqTwj9675iuxlFyNmsQcY=;
	b=hZZjWq2f+AVPUU9+4L8X8FtkOLq6ZexHuQjoJOB6jHmZGdurEIdbIp/G/2nC+dry0+aj
	 OVRnmtCoDY8/8zmQLUdVDS/OuPjNwlVj1Tv6t99G1PJh+SU8lLkoMJPMN1EgKPoRzTDpZ
	 t5YG0fOtI0lmjHUMtL/cDgdFTCnS4kfsYgomV+PRLsv5yzEaLOiRrCRZSliU8QRRQTORY
	 WhfK+K3pPLEe3FMX/MGXbwTqtTrH7nmOeDt8TgLtxlQSEycC6ckwwxB5+r5RBEuVgB/wg
	 nOtSe93MGCCxuRzhycrEEP3c+BL08e50vZFf7m07nyAltufE/MS2UYZ/DATLiceAjEQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=purestorage.com;
	spf=pass smtp.mailfrom=purestorage.com;
	dkim=pass header.d=purestorage.com header.i=@purestorage.com header.a=rsa-sha256 header.s=google2022 header.b=faYLAvB1;
	arc=none smtp.remote-ip=209.85.216.99
Received: from mail-pj1-f99.google.com (mail-pj1-f99.google.com [209.85.216.99])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4BA86606A321
	for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 20:29:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4BA86606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.a=rsa-sha256 header.s=google2022 header.b=faYLAvB1
Received: by mail-pj1-f99.google.com with SMTP id 98e67ed59e1d1-3b09a83d12aso4291506a91.2
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 12:29:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1795638562; x=1796243362; darn=vger.kernel.org;
        h=message-id:date:references:in-reply-to:cc:to:from:subject
         :content-transfer-encoding:content-type:mime-version:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=l8Vm7b6mvicOGbNITWz8S9UqTwj9675iuxlFyNmsQcY=;
        b=faYLAvB18L/VuJp3Y4kep9bswU0Is/J4eU3X+N6HKQ1Y6d/r0+JYs0W0pr2VhNogDa
         +ZuaoOV9m3L/8kPFTqT84PiZwSeNtYbLMmuK3j+JqzLJ+dbwiKMjzKbW6pthM1brzavP
         H4nwCnPlkkZ4dyHU/XQAy0qN5NS6UateiHim6uO+08KJdx38PdN212mRCiMbXc+mYQjW
         CeC17Lf2lHqQonUSHkYxxXa4BbV5ZrswAz03uYbFEO0YBKHnTlDQvf6eyQzDy1LBpYm4
         JIly3sSK9m66gwWCcH5HEspTuV+HNFuwt14CLXr9uZvYNscBYHn3nfEmwS+941Sga6Mt
         70vw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795638562; x=1796243362;
        h=message-id:date:references:in-reply-to:cc:to:from:subject
         :content-transfer-encoding:content-type:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=l8Vm7b6mvicOGbNITWz8S9UqTwj9675iuxlFyNmsQcY=;
        b=LiIPBRlAzzV8KGThIm5oIaNSnsQ6dixRYpxxLmJg/ZglfTcE0ziQxWMX1uPWx2jn+L
         hLeMwzaOx+UDkVdKkw1ZjAS6QgAOorifUi52C6ArutAqics+uMp0bombb7YYqmx4pkQM
         jMGYOh72GDVygGTeSkXaoB+GYEbdZjL3GtT2tSahkIRKk19fyx9LpdlrsvR1zpxQrU69
         AFxvfAM8U4Vl72IJ2rVeIaq6I5cpyIs5qOkOCC4XQGS8O6JmFcJYA3Cl0nIBfBcxdY8Q
         uBGONL57HmTdbhJhZcG9Nkx4v5Yn6nC0ykD0HV4mS2GbVa5lCjRIYePjJe5Uxt5XttCG
         j0xg==
X-Forwarded-Encrypted: i=1; AL+hErGJLHAsT8BqTNy8F/B+u/oBfaiWHQsNLKURZJcIHdOqioyVvXxU/7VePQJN3YvPvYX/XGRznNfd7SU=@vger.kernel.org
X-Gm-Message-State: APuU4Z9HTpAaUC/hptwMHzOVxop6sn1KfOSV+073owijmYC2take21bH
	Vf85zqyog+leAQoc6oLLK0c3kqWNdx+MWKuxuoPVxIPo2gbJrMkMD5Fz3IhY4AzWie7ZE/GPsLF
	er0gknRNXlSiXEbPLYtD+k6h2MLmEVFM+0Yha9jxtKJaaNs6Dz4yPd8px3GXN9yAeVxXlSv6sG8
	0Chm/PzfEElwHk+11AVaZSRL1PCrDshtLSVTGdrJ/BCwQlcLFuSAj89ENCI4f15ItqbVf0QszH9
	k/A4NOBy7p2/trcSi17uksZfhM=
X-Gm-Gg: AZFdTZctcVNbgfqyBb9aUUgugmLYLKGuP+I8OTPhYapAmkWGR5nNKyi3q7eSl36z4uj
	mArt5FLfNyXTBE/nK41LWyg77BCqUDX2f+7Ma/NO7GPGRMFauAJKL5sIH4iWEPqJXCQREkr4nZp
	AY6O7bp3Kt0QoKtbYAjIf8mH1cbCjijFjhBQrd0qns35nJ1LHvddX+ISJepUHTCIuWZwQWrnW9A
	3rveOU/4i3Mr9EJJvhvHfcnwcUbwbGmY8AUpfm8cuhLbM+RSMpv3CHOQrMYsR4SFvy9EYxH2YHm
	OMljoQKAAh3gntpXxBP7yOwsi0Nr3iM2CNldCQJAgLTJ9tPOBwK2nty9GPek06qHL7WcMLn1mrJ
	QT6Svlrlz/2R+O8Ds1PN10m+faZtbIQ3mXRQzHw==
X-Received: by 2002:a17:90a:ec86:b0:3b4:889:883a with SMTP id 98e67ed59e1d1-3b41c9bacbbmr19118124a91.66.1795638561597;
        Wed, 25 Nov 2026 12:29:21 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 98e67ed59e1d1-3b41ffad038sm6179778a91.3.2026.11.25.12.29.21
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 25 Nov 2026 12:29:21 -0800 (PST)
X-Relaying-Domain: purestorage.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id A45EC3400BB;
	Wed, 25 Nov 2026 12:29:20 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v3 1/3] rpcrdma: Serialize notification registration
 with device removal
From: tmenninger@purestorage.com
To: Li Xiasong <lixiasong1@huawei.com>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org, 
 stable@vger.kernel.org, yuehaibing@huawei.com, zhangchangzhong@huawei.com, 
 weiyongjun1@huawei.com
In-Reply-To: <20261124021842.130141-2-lixiasong1@huawei.com>
References: <20261124021842.130141-1-lixiasong1@huawei.com>
 <20261124021842.130141-2-lixiasong1@huawei.com>
Date: Wed, 25 Nov 2026 20:29:19 +0000
Message-Id: <179563855914.3954750.1491302687768867001.b4-review@b4>
X-Mailer: b4 0.16.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1795638560; l=523;
 i=tmenninger@everpuredata.com; s=20261125; h=from:subject:message-id;
 bh=K/W7Ttia59kCaqhW00kObD6UYvl0Cy15KvgQbFPRCIA=;
 b=K3KNfLNZW+MlbKg74QBHj05k2lRDd141UEooqOB2WaXr5NbI41rEq9YGVr/e2MQ8pyMpgsa08
 4c/z4AJoO9ABaP2mrNVrAEwbDZbx926CtRckrQhyMUoC7Oo+j0qU8il
X-Developer-Key: i=tmenninger@everpuredata.com; a=ed25519;
 pk=nZPlfTnkwWNTqraxDCv+eNh7JBZRFxAoLY1xeLR6zXI=

> @@ -187,8 +209,11 @@ static void rpcrdma_remove_one(struct ib_device *device,
>  	}
>  
>  	trace_rpcrdma_client_remove_one_done(device);
> +	mutex_lock(&rpcrdma_device_mutex);
> +	ib_set_client_data(device, &rpcrdma_ib_client, NULL);
>  	xa_destroy(&rd->rd_xa);
>  	kfree(rd);
> +	mutex_unlock(&rpcrdma_device_mutex);

Seconding Chuck's nit that you can mutex_unlock before xa_destroy and
kfree.

Reviewed-by: Tim Menninger <tmenninger@everpuredata.com>

-- 
Tim Menninger <tmenninger@everpuredata.com>
