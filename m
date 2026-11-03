Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793669597;
	b=AHCTRGTkdzigy8dY8VlARRY6UnoOx7e7kIPYtfkf51gKTymDA99uDgt23i388SICU5xx
	 C9SUx6f1NQEvySwmfYGVrgy+owzAmUKWY0WMxlTtHo4sz+og2tNsHKV3Fuz1A8AELZD96
	 +uGIPsKnqlFwP/l8bihBo6iTS3OIO6DR06YKaSU9eBBJP4rTRjdPPfAZ08N9PIqhHiTFn
	 FMfTJ9jRMubsVwMfb3Ay1qV4SMBAPaWf9eMJua2jXf8zSmwra4vJf5gGOBc0m7Jjugh8m
	 XTkHF0jfmGMyEIRd0dU1Kvio1vGfzd2j9/6T1zQGc+6Ih4mhSrLkMHS6XdvmmOVsrWA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793669597;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=uzWgJiFatKECvt6+IQeOhN0iD5aHi1ZdWkX8/e3YhPU=;
	b=UIg/jqtdjIJ8a2uEikXkwpekdozgk8NlR8uTnjlQzFVvdWDkuAuvl6kcuUXViZawil+5
	 fOjXFFg5ch4OQL3DAIt0YPs52Dg18CwgwS90U1NF7sHtdAbkRs6sYdx/O7C6Q1rAkvgnD
	 CyJKabX9VyEkOvdq4oWg0QuHmj5Pstb5FqJTNY/5Ua3c/SG6xJtTiqkPplYhhQ+NsgoL5
	 +RFiqQTALzoWgR95rCedKWBjSvfPATNh5MFRWqQGmxUV60E8M6CR44wMm9stKuXYJvyAy
	 ncZZS5mlP5Pw/4wYfvhdTy+D8SLZ2lyAQYPgcUvVPAbBtPAv5modtFNMCBOYP94TtdQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=wuhJdTou;
	arc=none smtp.remote-ip=209.85.218.50
Received: from mail-ej1-f50.google.com (mail-ej1-f50.google.com [209.85.218.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F212606A326
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 01:33:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6F212606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=wuhJdTou
Received: by mail-ej1-f50.google.com with SMTP id a640c23a62f3a-c46bd7a7345so40956166b.0
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 17:33:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793669596; x=1794274396; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=uzWgJiFatKECvt6+IQeOhN0iD5aHi1ZdWkX8/e3YhPU=;
        b=wuhJdTouGtBWUL1Qt3UZr2TM0T9Gn/5S+xdhi/+uLR1CYOqY2i9E+/ZheHx347v1fw
         WIUIb331iTHTvEUg+igChxbRhKbRi5e3D77UIpqWcAQYx3ErMmgNrR5vUBMuQ1Lb207W
         R8FtHfl2sIhl34gIfdfLE6WseL7yDWqXHogTOX2yZSUpj4Min/S0YptjL1QjAVY4seaf
         xdC6/DzZRsDJljsvyCld/kYZvAv6eM4EqpLHzZUBPX6hbgCZjsuIQU0AYJYj9TfDlVmr
         ZtshhkEU0S3j2Mn4q7u1br76Bls90Fz+/Ji+uBZBIeP7zPsF4oDHtZxu4tCqytISLKWW
         4xQg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793669596; x=1794274396;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=uzWgJiFatKECvt6+IQeOhN0iD5aHi1ZdWkX8/e3YhPU=;
        b=2V2WWSiNQ1JbN9srSmYkK5ttafpM403yMZInRb50zoyt+4FnGSvdBD7t4ooPKwd/PD
         rvxgRAmy8UZ6tPj8pftIxqlOoEcfVTCMEJUC0JP6XWhdc2fHjxtKDQEixBvatnyksevh
         d1O7QUe9pN/jQUszOzqU81yhdT22aTxySnABw46DC0GPf+qSPsCgUv+CB2tn1wCpLgHf
         jPk7ymgGEwif7evFHVvUvJPSZez/uWtfgHSbhGStaPC+0Lx7bna+7tbAsWdBkxpA5ZHG
         QxL0YLlBK8jzc5D6UYO/7jm8/SO72nr7XuvLUmF2nrv4sSZaBPCkmFOjYGEl4BzEpG8h
         jVHA==
X-Forwarded-Encrypted: i=1; AKwUvBxN6rbjfol/xqxX5mAGW11qLuV+lwkYy2J/vXJybyOy5c/2GRI8DBAgHOz6FfohULbCWFRFmK8SEK0=@vger.kernel.org
X-Gm-Message-State: APuU4Z+G1QB+C2TJ2inSJdf+y0l/8338HBkW1GGK0WDxAaeeVblw8EMq
	uz9Stq5xkk0SaCV03sES/zcr6lqioeLIl4eRb0Rg8It7tysR7osdbzos
X-Gm-Gg: AYBFou0tFGO66oV/XSAtfyMQYAjt5qWkE3zJ2RsjDXClidv5FfzZaDpioucwcwyGjd+
	7CjNWsFnL43ynCM6rZWfv8Q+wY4KThtk08ffI7f2kTaEAMZBoeAmDE001any3rw8pA7k0OCbKcd
	6/QLqshEh4dMNj0CIo/dY//PTncYue9h/Fg4JqLDKx4NFLes7L1y+dsn7+5VC8PlWz820IMuiuo
	MYHi8sQkoV/dD11ZijQOGPAnXPH6lbd8xWTcQi4giMP9t6KCU4xusjXOkLfnstON6WqRN/hPiwX
	On+qweQtpwF7USCCvlASFifVx79V/n9VKDaK4RLKriz9QA1Q6h6FIemPS+TbNkirclSe2H9r6A2
	YN+SiV8qSQHlq1mzMvRJwdlGcPKUY0HfkHQLwk3nVY1nrFNjWhQ/TcUo5BzCVMakEqZxm4JhiIJ
	ScBY6MBKZnHXuVPa+Gx2JiZJ6YosfvswOMkGPBmDMab2n+deLfetmJ0uCjkhsfwojQM+cD6Yqlv
	AcpnEd/Rvvr1A1YLka9NVZ6DoRuSoJtehHvrLaIjmsSZAj2htrOvYkWi++y3oJPI9egoiu0PaaY
	u8sXnLo7ya0wr9My8BOMVMmy18HaUtzEV4daA62X0ZonbVRdDPmQ20sYHJViBzm+BFU/LWSc
X-Received: by 2002:a17:907:3f25:b0:c46:9711:e30e with SMTP id a640c23a62f3a-c49d14dbc5emr1209078166b.29.1793669595739;
        Mon, 02 Nov 2026 17:33:15 -0800 (PST)
Received: from localhost.localdomain (173.242.112.181.16clouds.com. [173.242.112.181])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c4cebec0735sm38282466b.27.2026.11.02.17.33.12
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 17:33:15 -0800 (PST)
From: VeroFess <coderzeng@gmail.com>
To: cel@kernel.org
Cc: jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v7 0/5] NFSD: Enforce export security after a deferred PUTFH check
Date: Tue,  3 Nov 2026 09:33:08 +0800
Message-ID: <20261103013308.1174565-1-coderzeng@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261102-verofess-v7-0-d2cc0de4d44e@kernel.org>
References: <20261102-verofess-v7-0-d2cc0de4d44e@kernel.org>
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

Chuck,

I finished testing the posted v7 series on an x86-64 KASAN guest with
NFSv2/v3/v4, Btrfs, inter-server COPY, and kernel TLS enabled. The
five patches applied in order to d9130c9f6535 and the bzImage built.
The tested image has SHA-256
99c8dad605aba384985097b6fad00f26db19ea8074b5b862d145b928e9b4b975.

The original NFSv4.0 AUTH_SYS SAVEFH reproducer returned WRONGSEC for
READ and WRITE against the krb5p export. The destination was unchanged,
and none of 108 candidate stateids returned the protected data. The
v4.2 saved-source COPY and CLONE tests returned ACCESS on the denied
source and left the destination unchanged. Authorized local COPY and
CLONE, inter-server COPY with COPY_NOTIFY and OFFLOAD_STATUS, and the
asynchronous negative cases behaved as expected.

I also reran the v6 regression matrix on v7: SAVEFH and RESTOREFH
boundaries, error ordering, LOOKUP and LOOKUPP, OPEN by name and by
filehandle, SECINFO and SECINFO_NO_NAME, READDIR with rdattr_error,
LINK and RENAME, NFSv2/v3 CREATE, v4 OPEN UNCHECKED, and export policy
changes from sec=sys to krb5p. The GSS cases covered krb5, krb5i,
and krb5p on v4.0, v4.1, and v4.2. These checks passed.

For patches 4 and 5, I ran the GSS cases against the changed SECINFO
and PUTFH paths. PUTFH deferred the flavor error where required;
SECINFO returned the available flavors; a following operation did not
use a stale current filehandle. I repeated the root and child-export
checks over plaintext, TLS, and mTLS on v4.0, v4.1, and v4.2, and ran
krb5p over TLS 1.3 on v4.1 and v4.2. The permitted requests succeeded
and the denied requests returned the expected errors. No KASAN report
or kernel oops appeared in the guest log.

The W=1 NFSD object builds passed with NFSD_V4_2_INTER_SSC enabled and
disabled. The need_wrongsec_check() decision harness passed 259/259
cases.

Tested-by: VeroFess <coderzeng@gmail.com>

VeroFess
