Received: from mail-oa1-f48.google.com (mail-oa1-f48.google.com [209.85.160.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1C24F5A0AD8
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 18:02:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792173761; cv=none; b=Gzr4aWM7q1hxJ0dJEI3nTeeCAWSNFvlqx6ZzU8bYAU5NDQADoETEbn7Cvr2lPhMX5ifnu1f8djZZgJ3B8Tk5O+hzPvEuOaviO3wdOJhQ6OkQ6Pa/arxW3EWcIg4DRtlg5LZy8ZZX71S59Kq/JXwSOb/sAWCmirp/LT3GvqwqABw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792173761; c=relaxed/simple;
	bh=X/II/HqkRKtjiHEED6+pCdIXhg7PUR/Sgh7qsFkcd/E=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=cN1elO3ft2xT8bOev8hIoZ5u1ZUOzrQmaTy+Qh3n6tF/n9uu6m6G3RJXVqpF1Lmq6wCDZidNzrisLwy3OjmGVRGMqS+/djBu64h/zs/M2DCz23tuZb8fjv8R9vOkRmGHik1cbTGsu6LtQkV4DXb2g2ifWiaz9YBUh0a255HgOAc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=fGznvevJ; arc=none smtp.client-ip=209.85.160.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="fGznvevJ"
Received: by mail-oa1-f48.google.com with SMTP id 586e51a60fabf-48e2d5a69c4so134549fac.3
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 11:02:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792173759; x=1792778559; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=X/II/HqkRKtjiHEED6+pCdIXhg7PUR/Sgh7qsFkcd/E=;
        b=fGznvevJ5IBIkmLjfQqcNMhH3Ft78oL1pF0TeLMuSWvSvCtTsyGp1gFxtxbqn6V4R+
         9Maw/viKVzO/fd77pO8HrsLd2oFfQgKwul2F5qDEwPtfTvXZlsdY3uzrnaIStwazKt1X
         UwlsEFa3hwtHka3+Pks1jNnIbU7OCgI9TkaSsvE5SOtlxA9K8hQFF4v7s/J1t4I9QTq/
         oPR5Si2IMvZYcM1CkTH/ToCTl1C3QrMvsa83sgSz/mtwBYUXBt8m1Fd4DRROSgoA9tKZ
         gvw/XDVHlUiT5GluaQ8VDrg7w0SkCyNzmbHM7GuwTzgHrL8mN7oYyj686AnefKj0Bhz0
         xAww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792173759; x=1792778559;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=X/II/HqkRKtjiHEED6+pCdIXhg7PUR/Sgh7qsFkcd/E=;
        b=ETP541ncPcpZd9UtGPWjCWn13S3b4a5AKASYVxSwCbWHWnceKBJt/QNxo4EOvYf/+L
         ggdTEMlGI5TRW3ew4Lhd2oUEx4Pa1EZr5h08ApQfCXq4HQOyN3Bqzu+Ro95pc3usPfGA
         ZV9rUI7IXpNVHGjdmIF8c7UNs5y8xP5qnezgxTRCW17w43bhZ6LEIDpEcUq9ujk9iJGs
         4YJ2+Eryt7ivVfqHAd3qTH4bKfRzAGp3ZUzW/bBcx9XWS9YrMsUcTSfYdjiRXhI7WrbO
         r/hG9x2s4pO5wMesecApWg/Hsh8x0WV+6exsXa2+1ab1pjsavMm6Cz/y4XMe+Ri5Wxa6
         vldA==
X-Forwarded-Encrypted: i=1; AKwUvBylOGG5xaxK6wzB0oiC3xLg3GnuKgvaulWNdzBoqcsc/kOl1SlnibX/qg+AAXyMP40t28RuC1unXeE=@vger.kernel.org
X-Gm-Message-State: AFq9FYI3CVNUHXW0TisJ7UpPO+G+bvqp9HbOnlveKD1lnnlB52DqKN29
	Iyqr8dUz1mLlS8iC06en/vK1kstGwhplFKfIXbtODiuTPX3YZNt7qg+9yN68ijntQXqExS2zT5q
	wa9KX
X-Gm-Gg: AYBFou3VcGFCytuUKT4UqcdWJ9G8MxiOEMscu1fT6e5GnOkUYPet68jlLlsvS6sAD0n
	/z9BC1aOna1JEjjro586rOgqJLTZbSQh4GbaHrHbeu2hqw3kXhNhEeEIkwS7iaC+9qlHGiW4LCJ
	pBVxx/kF5Agv80jLBpVwhCNO2qKgbklFLMZaj9SCij8uwbzwiDw3S1xScWrruePWcMcv7v9SkKm
	pUJ+DTQDh9GmcdWW0Ix952MZ+GwO3aGzACKM0Z6a6rhXAQXVNA3pXRz4Ozy7f9gJRKk2zX8/7kw
	KbJD62RwBsItQENLEHQ3DlvZZPFz3GGxPW75nZzZ3G1uNZtzHxeNumq9NHuZ3imLJ94jJGc5vnX
	7wKrB0tNgi0mpscflZnjnKIs94a/5nzohIjiJqYEFuOAlV1FrolpsHZMsLuUhQ6EVZNTC54K9i1
	KrQz86w5wkFGx3WRArBtZ+Uh50quaB0hG4O/kz63j4jjsUyBv2NtD4u+aNaWyFORCWN8CVXf3MT
	FRpuLrpdCivp6w5LA==
X-Received: by 2002:a05:6870:c06:b0:494:9268:70ca with SMTP id 586e51a60fabf-4a757b17342mr555163fac.43.1792173758585;
        Fri, 16 Oct 2026 11:02:38 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a73adff016sm2384816fac.0.2026.10.16.11.02.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Oct 2026 11:02:38 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Jeff Layton <jlayton@kernel.org>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils 0/7] mountd/exportfs/nfsref: netlink loose ends
 and bug fixes
Date: Fri, 16 Oct 2026 14:02:36 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <B52F9136-5054-4513-9825-7D12C4B042E8@hammerspace.com>
In-Reply-To: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
References: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 16 Oct 2026, at 10:15, Jeff Layton wrote:

> There are some cases where mountd will use /proc even when netlink is
> available, and agentic review of this code also found some bugs.
>
> This set fixes it to use netlink in more situations when it's available,
> and also throws in some bugfixes and cleanups. The last patch in the
> series adds a MAINTAINERS file and the machinery that allows b4
> workflows to work properly with nfs-utils.
>
> Signed-off-by: Jeff Layton <jlayton@kernel.org>

I'm going to base some prototype knfsd and netlink stuff off this - so
sent it through my

Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>

Ben
