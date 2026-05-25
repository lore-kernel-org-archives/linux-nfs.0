Received: from mail-qt1-f170.google.com (mail-qt1-f170.google.com [209.85.160.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3287437FF64
	for <linux-nfs@vger.kernel.org>; Mon, 25 May 2026 12:19:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779711574; cv=none; b=R4KMOW3oBmPJ196SCrc3vQZa73hCfcpwJO1Sa/jb1us90Y7x4ZNffeaynIuRxSHQnHT3V/3179qpa2VbBxOKpRd45zBktmEs3rt6lrX67v0J70ntBC0Brs01YG+vzuhKcLo1IyTH3YZLE+XNk/IvWBV6cDfyJYhzZz1C2kNaKZc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779711574; c=relaxed/simple;
	bh=WzPCO9gLDcbBMU5BoJ7zMH9AIATN2YIHyfy5SWW7xUs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=RjodalvSQ9gEg4dt1PRVz65hN+yz8GkdZ6oxn52/8XAT8csPRxCnXNXbVdKAkcMKuv2stJtg2yMwFipHX/e9SiThn1hP6/8fzO04Ijgwx4oNm5ShncMvyOdWIQaMItzodYO0XpgnCjvNuYdYmLAdc+3h1VyzQSe7pt/qPB4k7bI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=fail smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=Tq9To+KB; arc=none smtp.client-ip=209.85.160.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Tq9To+KB"
Received: by mail-qt1-f170.google.com with SMTP id d75a77b69052e-516cbe16bcfso25210571cf.2
        for <linux-nfs@vger.kernel.org>; Mon, 25 May 2026 05:19:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1779711572; x=1780316372; darn=vger.kernel.org;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:from:to:cc:subject:date:message-id:reply-to;
        bh=PsSjlGTpZWL/2k9lFtJdhUdlf8UBtg09lUhGCMelAgA=;
        b=Tq9To+KB8YfL8kI8Q1HazS16sWFGf91j1TU5OwQJDq2l5iUEPsYYCZ0nWFmzgSoYuq
         jSzkLe8zsTLlOBv6K8omote5iyn3PcZu52TnaxcnVuTSyiTGkOEAgSoox2Xg2TcU5efd
         Da9xEBhlmIVWtEezPoTzB2Vh+nKQEJ6zPTeJLktEV8f96iicz1hf4HjRuAUR/3a9H8kj
         B+LB/dqZEyECCkz1VjfK35AQrQcFPDXoCyNmqKDYfHUSCMsMSrFthyQ+tU9wqHVEX2lV
         6YkFqFCFklE1VXrx7IsC7iaK09kkpg62GGeFsfW0GBKaKa737H44mBUCXsT60fUfl6To
         Jcsw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1779711572; x=1780316372;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=PsSjlGTpZWL/2k9lFtJdhUdlf8UBtg09lUhGCMelAgA=;
        b=L5s9PvwUHr8v2Spho8eaSxXs4wWTcBPxqLts10ASrqz3ppX1FSQEhOXl5eGp8ZRq4I
         +gxCUHnmtrLdmTBZA6X8m0sVfzfSD0f2U/wzy3pXAvBnUjRq+Z9pFiuTm/FGFrITZu3e
         Jd0DMacpRzHGeivm722UK9rt2mec17J69laleoetVbJyOT5h9tBb2ECQMw4Hu1/DmxxG
         ONeCE/YvLqt3ETTQ2lQ1Hy4vSpirwQHmi1EmgKjdrP/sMWdhYbqHR5SHzihNEf2Gx3Y1
         7YPyPU9yQ+MoGlefv62y6sOh1ngCdjmgSbbIwEKxt05PQC7YiiUxUZKj/8x9DSOlZJfe
         K2mg==
X-Forwarded-Encrypted: i=1; AFNElJ+r3xUlNFIa+qCrSUy9aBsA9FOt2HLxJKIeSww7Q7f1LBcGEThJNKVr2JSiLdIHLVkfeOqSOzXI4eo=@vger.kernel.org
X-Gm-Message-State: AOJu0YxwvyDZV+OEGrnK+odrP76zUGZuc8iwH7ZVki8FY+pXWBgVlpJR
	LuCKuKru9KnWgTBsDDDxooGqV8CJi0kdhnx+tgLZJMmkdlHwlfy19EczVyGNfV9RZsk=
X-Gm-Gg: Acq92OF+AR131M3XjVlb5amITXqxNd847rh+5ob/sMVMKEA90LDxodMh/yF7h9ARvjL
	v+tYwytcxqO1RPRVY09R/jEE80n/jGSAmeZRjbX4bkFgUz2O14mWm63RM9e07W/HuCsjiu5oZCk
	Qu26g79laI/1KOZ44MzbqTPvf60KBiR28NRSKMCt214xcf0vM4pyPh3bBb4JyziUT1Moe4hboOS
	4V1hm2p2R5/sDy1N5GS0KEsZeLmMuwJ97sWYC3fHSPCSeUcFDjYFrydbaDSLA4netwv1cDqojjw
	Bcq2IBWk4wsM2Z9kLBfFFj05E6ZlnhOzy96ceBRR170LB1eUXwQREj7bddayTLPuOMFU3ixYyCY
	5x7Kh75y4UU3TFe9DxisQ60R/jvzlc6eO3zEUnPbBt3x5ke5KMFc3FLii9mOBsgOhbwjNMfU96n
	HuSp8GjXLPtLwiNLLY+eC1Ni0ffNJE/pUOVVkqSQXb
X-Received: by 2002:a05:622a:9011:b0:50d:6b13:bb14 with SMTP id d75a77b69052e-516d436db29mr157358021cf.34.1779711571902;
        Mon, 25 May 2026 05:19:31 -0700 (PDT)
Received: from [192.168.37.1] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-8cc81316d44sm107456886d6.42.2026.05.25.05.19.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 25 May 2026 05:19:31 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: NeilBrown <neil@brown.name>
Cc: Christian Brauner <brauner@kernel.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>,
 Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>,
 Benjamin Coddington <bcodding@redhat.com>, linux-nfs@vger.kernel.org,
 linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] VFS: fix possible failure to unlock in
 nfsd4_create_file()
Date: Mon, 25 May 2026 08:19:30 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <D21CFD27-5D06-4CB2-AC48-B79F3C6A287A@hammerspace.com>
In-Reply-To: <177969022571.3379282.16448744624428323496@noble.neil.brown.name>
References: <177969022571.3379282.16448744624428323496@noble.neil.brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 25 May 2026, at 2:23, NeilBrown wrote:

> atomic_create() in fs/namei.c drops the reference to the dentry
> when it returns an error.
> This behaviour was imported into dentry_create() so that it
> will drop the reference if an error is returned from atomic_create(),
> though not if vfs_create() returns an error (in the case where
> ->atomic_create is not supported).
>
> The caller - nfsd4_create_file() - is made aware of this by checking
> path->dentry, which will either be a counted reference to a dentry, or
> an error pointer.
>
> However the change to use start_creating()/end_creating() (which landed
> shortly before the dentry_create() change landed, though was likely
> developed around the same time) means that nfsd4_create_file() *needs* a
> valid dentry so that it can unlock the parent.
>
> The net result is that if NFSD exports a filesystem which uses
> ->atomic_create, and if a call to ->atomic_create returns an error, then
> nfsd4_create_file() will pass an error pointer to end_creating()
> and the parent will not be unlocked.
>
> Fix this by changing dentry_create() to make sure path->dentry is always
> a valid dentry, never an error-pointer.  The actual error is already
> returned a different way.
>
> Note that if ->atomic_create() returns a different dentry (which may not
> be possible in practice) we are guaranteed (because it is only ever
> provided by d_spliace_alias()) that it will have the same d_parent and
> so it will have the same effect when passed to end_creating().
>
> Fixes: 64a989dbd144 ("VFS/knfsd: Teach dentry_create() to use atomic_open()")
> Signed-off-by: NeilBrown <neil@brown.name>

Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>

Ben
