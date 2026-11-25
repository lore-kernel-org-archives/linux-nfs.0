Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.228
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795638593;
	b=gc6AlHbbicrJWCiHIkpa5MGZ+Yj135jgSl0mi8riR58P7JNEwFs6R3jDThyotCl/c0gp
	 4dpZ2RoEqe2KWwXPZ6eLOOHC6VbBfJ21jG8di0NKEP/A/yWXSQKMbn+HD5MkUlIHOrIq4
	 +EiGkqscJgpzJ1RaqW/9JoAZg+AR8qbj6TM9cP1YDv/jT6yr8k9Y7tWOLjh9TaWBGJgQO
	 mT/z64o1AodVUU7NaGgRITE8TKqyzOvXusSMrnbotHHMun9SesRzU0H0zQWrQeDwVa2UK
	 SiliELij9npX2GEbM29dAJBIoGpSUqC+/p7lV8y7i+MdMHFjlAKcAOXHZt5yYw16tIw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795638593;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Subject:From:To:Cc:In-Reply-To:References:
	 Date:Message-Id:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=5by1QEX/cGC23E25Nzrw5GrZTEPj5OnY/lGT7wIEPVw=;
	b=EZmX0Uii+pdnhYcMatkntdtH3G7giMt77d1lLDLg2Z/QaI4ZoGcIoeqpzP/NJFsTY9ir
	 VrkPLd/tTpoz/Kc7KEkrom1sMexajoZhr3M48H3NPBb/CN7Yzcl2ntj/fsUf61yiGuWPJ
	 kKmXDPA2M6PiuuefPxdpqsY64538aEbX00/Dr4P4hyxKcve04GPEoSi4DumEd6+YXvGv2
	 wySjzm2N9Rz9v7pRwoUz4qFSpnboA3TbMokpEqKyMx27DETwtdzRjrgEkC6H8Rc6UCl/Z
	 H1KTZ+b4BqdmRNvlfDf8hfe+RLiytrzpiGrBzu3FnO+YvMbPUDhILVpsE7Qm8VI/iKw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=purestorage.com;
	spf=pass smtp.mailfrom=purestorage.com;
	dkim=pass header.d=purestorage.com header.i=@purestorage.com header.a=rsa-sha256 header.s=google2022 header.b="I+MxKs/p";
	arc=none smtp.remote-ip=74.125.82.228
Received: from mail-dy1-f228.google.com (mail-dy1-f228.google.com [74.125.82.228])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96DD2606A31E
	for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 20:29:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 96DD2606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.a=rsa-sha256 header.s=google2022 header.b=I+MxKs/p
Received: by mail-dy1-f228.google.com with SMTP id 5a478bee46e88-3863db981d4so8779979eec.0
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 12:29:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1795638592; x=1796243392; darn=vger.kernel.org;
        h=message-id:date:references:in-reply-to:cc:to:from:subject
         :content-transfer-encoding:content-type:mime-version:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=5by1QEX/cGC23E25Nzrw5GrZTEPj5OnY/lGT7wIEPVw=;
        b=I+MxKs/pMhX9Lj7v1b+pmXCQGTFkou16/qGRsto0wbGAUWQ3XXn+aSRSICAMwXsnkN
         Lir3Ad13iPHE/klgrh1D1amjN7jyUF14MN4Hf5XwHQ23CXLJgptV6+7655hf0dMcFkM7
         f37KztvfT8gUm0Tc21eq75yL/QjOQ+RnKIaARtYTnIIBcuaf3/y6XoFy6eTpASUtOVkQ
         u9jO17NSMpZQFnKDv4D8MTtY6CY3HoX4AswUfqWxpKRO/IBI6kfcZKkNh9c/62jdEr2y
         PmE4pCnc15x+tCmJY1nBLRghFI4OCiKsr0liwdqIgjg6a/q1qJT3ixv5I7I6W1b7Myws
         XT3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795638592; x=1796243392;
        h=message-id:date:references:in-reply-to:cc:to:from:subject
         :content-transfer-encoding:content-type:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=5by1QEX/cGC23E25Nzrw5GrZTEPj5OnY/lGT7wIEPVw=;
        b=ac5kjJiXJDNMlxblKPyMmVI6pGNONg6sJ8kS53CNKmAENnfZTtygfkXeP7ZaslhBnq
         Vmq9spFWQs9dEibjil46R54W+ZtIUbEviwEw2M0NmnDyk25tsGY42iC8ej9P7JTIbVNr
         AmjlhUzYy506QgpD694VOgn8dvKikvTcp+ZtpY9d8N7jLRsOihSSAYJ2qHn5WA2AH1DR
         0RzLhdL9z4CKaib3FrJPpaxwUQWxDj6ZbzeHYVrTRS9VS3ggzNvs0jA+s/rVN2guQhDV
         eWTkt5W/1iwVbuS2yTD7WWMrWiugAujd4nNozX39bX57KEXa/rdbtQQ3o7EsFcnbDKUM
         waEQ==
X-Forwarded-Encrypted: i=1; AL+hErF0nFcKIUAtEv/dA3dKz1DeVvF0Oa1uQOsio/iBw+CbGVIcN04de2QiA8NwYVsYzVmtIiwJq1ZgAtA=@vger.kernel.org
X-Gm-Message-State: APuU4Z/7VBeh5+RpfzOOyb1LNcuyQHuTt83R0O/vL84xXCNy44fa0JuY
	ltTo0M/yfrtngdffKuXhK2CiZi7I45FuLHIYjs3Ur/K6fi/7WawT+h7YmYLpHkxyxYpz3xUIWU6
	CU9tkAzqZN9e1wgGR2qCTZZSxMpGqLwZWkSLkXgsGNvjchem5Ic3JWyU0IGxkDneO3TWTpiQkj8
	k4brSkXaAF6dEGxnbHQMbYHK9eP9gnu8blSdPLZWE6CF7j26c2kHlXgIOrIDV2cyFgV/WHJC/0s
	t8g87sI2qgCCuyQpq6XGvRwH08=
X-Gm-Gg: AZFdTZe+yh040hNhKsvS8I6+y27OdDmfmf04hhxFETiA8U7ltbEYrCcFEQoCA3cjtwA
	rFGl8LJ8z1ZuaiRh8ge/gZUDw7rjwkzO44ZmALILpm/qorIcGGrcySQ64oauxh+uFlnXj8RzlnQ
	Rtq9rNIlWLyQIAYiFEPmCoZ4Pzg0yWlp6K04NTScIAeUepeD0bAoFPErt20dPq/r0RUFl+WpQ28
	DmzOW/vxC/2YGfd8GU2oVHbdeRkARJ+bHs6VGsYYDjdMxLkn7bH9aWxqduwFXssbIpHPvey4CuJ
	ppmMAWWHWPOxgJBNuJnr9wjVAZIAm0TAgn72vTeD7Vrror3FYaq10ahkSzbKT/wd8mFiYAYXd8d
	gs07ncFvwxuCYyXg5unw6qEwzgPEgYs7caeW0Ow==
X-Received: by 2002:a05:7301:391c:b0:379:f7aa:1013 with SMTP id 5a478bee46e88-3856fd59fcemr19297575eec.15.1795638591450;
        Wed, 25 Nov 2026 12:29:51 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 5a478bee46e88-386c213b6c6sm1225263eec.5.2026.11.25.12.29.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 25 Nov 2026 12:29:51 -0800 (PST)
X-Relaying-Domain: purestorage.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id AC32934038A;
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
Subject: Re: [PATCH v3 3/3] xprtrdma: Wake connect worker on device removal
From: tmenninger@purestorage.com
To: Li Xiasong <lixiasong1@huawei.com>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org, 
 stable@vger.kernel.org, yuehaibing@huawei.com, zhangchangzhong@huawei.com, 
 weiyongjun1@huawei.com
In-Reply-To: <20261124021842.130141-4-lixiasong1@huawei.com>
References: <20261124021842.130141-1-lixiasong1@huawei.com>
 <20261124021842.130141-4-lixiasong1@huawei.com>
Date: Wed, 25 Nov 2026 20:29:19 +0000
Message-Id: <179563855914.3954750.11018048330217114132.b4-review@b4>
X-Mailer: b4 0.16.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1795638560; l=2167;
 i=tmenninger@everpuredata.com; s=20261125; h=from:subject:message-id;
 bh=Kd2c2EKrkQoXWQCM5emjG4zJKJ8aBSctLvqtZYaDmn0=;
 b=1V7sWT7lWWf0f8yfMDpj+BIRdbhVgODSyOZTykZ9roGfZtm7tD1sUCxO14/jnJRB0pHPY/wI1
 EgFk+lSkYfJDaPC2jMoNoxwp/6D3les2LPYNSdfYjt9mCQz3/cfkBmY
X-Developer-Key: i=tmenninger@everpuredata.com; a=ed25519;
 pk=nZPlfTnkwWNTqraxDCv+eNh7JBZRFxAoLY1xeLR6zXI=

> Device removal only forces a transport disconnect, leaving a connect
> worker asleep while re_connect_status is zero and blocking endpoint
> cleanup.
> 
> Set -ENODEV and wake pending connects on removal. Give -ENODEV
> precedence over other failures so late CM events cannot mask device
> removal. Force established connections to disconnect and use atomic
> transitions to prevent late ESTABLISHED events from overwriting errors.
> Handle REJECTED with an atomic status update. Wake the connect worker
> if the connection is still pending, or force an established connection
> to disconnect without relying on CQ flushes.
> 
> The final endpoint put can free id->context before rdma_destroy_id()
> synchronizes with CM callbacks. Destroy the CM ID in the endpoint
> destructor before freeing its context to close this window. Remove the
> CM callback get/put pairs so final puts occur outside CM callbacks.
> Initialize the connect waitqueue before notification registration.

A bit of a nit...

Could you split these endpoint/CM ID lifetime changes into a separate
patch, ahead of the connect-worker wakeup changes?

Moving rdma_destroy_id() into the endpoint destructor and removing the
CM callback get/put pairs changes the endpoint ownership and teardown
rules. That addresses a different failure mode from the connect worker
remaining asleep during device removal, and I think it warrants its own
commit and explanation.

> 
> If transport pinning fails, fail and wake a pending connect under the
> device mutex before skipping the notification. The final transport put
> can be waiting for that worker to release XPRT_LOCKED.
> 
> Translate -ENODEV from the connection status to -ENOTCONN so pending
> RPCs retry on a hard mount when the device disappears during setup.
> 
> Fixes: 3f4eb9ff9234 ("xprtrdma: Handle device removal outside of the CM event handler")
> Signed-off-by: Li Xiasong <lixiasong1@huawei.com>
>

I have no other feedback on this series that wasn't already brought up
by Chuck.

I'm still working on a reproducer to give you a tested tag.

-- 
Tim Menninger <tmenninger@everpuredata.com>
