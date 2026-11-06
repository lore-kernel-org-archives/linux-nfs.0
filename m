Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.171
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793956139;
	b=bvs7Fh6VZxbPz+tJsVt+4gVX99g/DQjy2nvX++9EqlVSl2zgDvwUY9RANInJqUT/HHAA
	 6lSXMVrGKhwTfWUenjKSlWzKR27/x9Xj8+LYff4aOhilNxl4/BhMsW35b+P/7Wd43YaNN
	 owyIvXymFm6RFWCDUHIV/14TTnEmDxjbL4f3pLpdnPxKNE+Ijnoj60+Kf9XtzixZMoXFl
	 Y+seOk3CcJMjcnal7Q0rglllD8qj1LBgFkKAxqkBhhPFNaJAWnXjW48MrCKY0+9N+s3Ho
	 vQ8cYN/2Q13B2+LECm/WuelvbYH3656iqx3Mz/eC/2w0BTbbIKZzWpBLTli7FVwDlmw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793956139;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 MIME-Version:Content-Type:Content-Transfer-Encoding:Subject:From:To:
	 Cc:In-Reply-To:References:Date:Message-Id:X-Mailer;
	bh=D/sV6OmTM/8MD3UVgw1krG89gB2PaHbVX7B4+P/Q8zY=;
	b=O8NTZumFodPIzgpz5F+Y5P/hdEL4UohYHe/tI2gTuIQvlOa5L4vk6prmXoNPmECHtExg
	 QiLCNIDiX6hdAjt6VZa4+n0AIlq5WZdaP5NF8HpdlhZavOeH43wYsl3jSJtN5MVxVgLe0
	 FqPEanwQech3UcUXxN6z6EQ3IPVARyImOAE7vAGEwP40+GDG8gKA4EwQyFN6evqClMp8x
	 lOte2OIVz8Q3ahSODHn78Wl+e8LOpft8fkRWUll71dtA0Mmv0uCZ+ty43DpdLLmYfQkvI
	 4JiJZneCO2p8v5frXf830FcOsp4tkm71eRZPzyiEVWeYXrsiP7HO3qKMul4DQK/Ci2g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=0Z4HVncQ;
	arc=none smtp.remote-ip=74.125.82.171
Received: from mail-dy1-f171.google.com (mail-dy1-f171.google.com [74.125.82.171])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFC39606A32E
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 09:08:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BFC39606A32E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=0Z4HVncQ
Received: by mail-dy1-f171.google.com with SMTP id 5a478bee46e88-37000e7234bso668717eec.1
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 01:08:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793956138; x=1794560938; darn=vger.kernel.org;
        h=message-id:date:references:in-reply-to:cc:to:from:subject
         :content-transfer-encoding:content-type:mime-version:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=D/sV6OmTM/8MD3UVgw1krG89gB2PaHbVX7B4+P/Q8zY=;
        b=0Z4HVncQklKxUYoIvgh2R6AI/hPsiVsLA37zLgWkQpuH/mClbcZLTHcapl9EF8ZZD1
         lk7wk2JOdA2OM5eMaYttdWpOrfBRdknBqAdXoybdGiRALDFyglFKEBbn6mpQJBeFUjEh
         rYP3b73o8VHRwdxmm0rOyuxvBJFgc5OO6LVY7TH6B+9i/09+BvNhTxSSXrW3sAyquPxU
         UiSRbcM42BkZIMLp58bVw1wJ1AfZFuZoBhkR9xvrMGqlJI2lp5kHlUiikXRp07zbGrdj
         6pJkKiMbf0rIWK2PVpXqZ7tkIsIH6F9pAZYj/N+OjiPdgaAQZYn8khqpjal5ytgZxloP
         CnhA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793956138; x=1794560938;
        h=message-id:date:references:in-reply-to:cc:to:from:subject
         :content-transfer-encoding:content-type:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=D/sV6OmTM/8MD3UVgw1krG89gB2PaHbVX7B4+P/Q8zY=;
        b=QbN6h8YgakG4nxXdK8MRf79Y2Mrv6NA1ci8waWbpHBHfR1dkg5FDlRPULD8m9+edF/
         7MOkI+8UnzMUgZMOSrcNL6pKBO8GgL0MbEDrHDbLzvDBOkhzdUjc0a2f7W+0refQ0gwO
         XNy15KbVVpnEy9dwuX/16lLwtGY3bYL6Kag+0bWla9+x2m1aZ8l+9Y2QSo+C/L3E+Rxg
         VCCij/+/oF6l/kv6VlFRx6KZDyef+Bm/dTgM+0L38Dn4vENitzZXeZqciKBa4YVSRCXn
         gIgpbm0rbo57HJUJxgziaLkLn+NFHp7Yk68/bW1sziaepM4GmtoR3NpXWLdjRALhJvq0
         QbPg==
X-Forwarded-Encrypted: i=1; AKwUvBwljOa3U3A28azdCNz2RDLNMg5GgdXQ/C66NmRaloWl76c0c/pf3eOgAV9qLR0K7xj1rJxsmpN1aUc=@vger.kernel.org
X-Gm-Message-State: APuU4Z9xp7iWX1DPOhXSXmUWW9/euxggygYj1vHCkf96OEhcHfgH/Nyd
	fOLzJvLX9FKYxtJ05qd2k0ucHBu1nY7yDDkTUbZs5Qfi3+ZFDinTcS3H
X-Gm-Gg: AYBFou1T8e5pJVDgjdQMRjA2MPrV/l9twJYkOknlQuvV6U3KwmwSp4ZN2JOwX6bHUnK
	us0fh+jdcmrgQmbhse3FC6WGlmQfPiG9fYg7vaDtdvSSVcGaxVK2ekVpf7paVxOOPkjpqdfUJ3A
	vWjiF/d2swhGOchvjchIZB92xGkCAUhDHCFRs8w3l80/CsVe9kV3PgxV3loOzLZjKg5SuB4Yz1u
	lqVO6LHu5MuxNwhnWe8vlmzSHFGl7HYH51AKWKEml2fRxQNx9fFt5B5Q90etn2Yjyqv/ae5b5By
	RUx/6OklYQHc+9yqRpOsObZamVPxvzM5c01dyQ9cpbxfoY6EGWC+DqC1o6MRjFKumIFZhEJeuF+
	vw29lUN18BBs5DWf10lF0O/G6VFRygaLmpdEyrrFGpIBvEceZm7+JTCQN2szCHnCturPgSumBEL
	Ceg7tTqUi2InPVIFhuZK5s0j8mtmZXXSmY5znPaV+hl5z3UAMzbNvxlXBKxPAG97sD1kVt36NrJ
	GEOMrh8EB4+IrGbqWzkirGV4wxhD5x5Uzx2560jWhxUXDaWpAfgFF6IWL0OlDtPDO0GDpE9E79v
	NHdE06Em4R6ZysPht45EdFv738EOCnwISHsL0w==
X-Received: by 2002:a05:7301:19c:b0:36a:1427:3933 with SMTP id 5a478bee46e88-36f76118d3cmr2368614eec.16.1793956137747;
        Fri, 06 Nov 2026 01:08:57 -0800 (PST)
Received: from [192.168.29.85] ([2405:201:8026:213e:f1f1:1284:b05b:3b9a])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-36fa651e6b1sm9966646eec.3.2026.11.06.01.08.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 06 Nov 2026 01:08:57 -0800 (PST)
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
Subject: Re: [PATCH] NFS: idmap: fix race between key revocation and
 payload access
From: mdshahid03@gmail.com
To: Trond Myklebust <trondmy@kernel.org>
Cc: mdshahid03@gmail.com, anna@kernel.org, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org
In-Reply-To: <457aa50d7c217019552b103912a1309f7330c617.camel@kernel.org>
References: <20261105173251.30389-1-mdshahid03@gmail.com>
 <457aa50d7c217019552b103912a1309f7330c617.camel@kernel.org>
Date: Fri, 06 Nov 2026 14:38:12 +0530
Message-Id: <179395609204.21365.4245889481354759103.b4-reply@b4>
X-Mailer: b4 0.16.0

Hi Trond,

Thanks for reviewing the patch and pointing out issue.

if i understand it correctly ,you are suggesting me to drop all
(semaphore and payload-access) changes and fixing the zero length 
return handling , since it currently treats a zero-length result 
as success.

is this intended approach ?

Thanks
Shahid.

On 2026-11-05 13:58 -0500, Trond Myklebust wrote:
> On Thu, 2026-11-05 at 23:02 +0530, mdshahid03@gmail.com wrote:
> > From: Mohammad Shahid <mdshahid03@gmail.com>
> > 
> > NFS idmapping retrieves the user key payload after validating the
> > key, but does not hold key semaphore while accessing the
> > payload.
> > 
> > The key revocation path acquires the key semaphore for writing
> > and clears the payload pointer through user_revoke().
> > 
> > Without holding the semaphore ,revocation can race with payload
> > access.In this case,user_key_payload_rcu can return NULL.
> > 
> > The existing IS_ERR_OR_NULL() check passes this NULL pointer to
> > PTR_ERR(),which returns zero and incoorectly reports scuccess.
> > 
> 
> Let's just fix the real problem, which is that the callers expect
> nfs_idmap_get_key() to return either a non-zero length or an error
> value.
> Right now, it can return a zero length, which is interpreted correctly
> by nfs_idmap_lookup_id(), but incorrectly by nfs_idmap_lookup_name().
> 
> The semaphore is unnecessary.
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trondmy@kernel.org, trond.myklebust@hammerspace.com
> 
> 


