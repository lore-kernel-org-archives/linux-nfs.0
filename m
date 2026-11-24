Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.72
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795543907;
	b=VEKKndvqJHBCLPpHX/wZzMoyf2cRkbsRIl3djJZOM5TsIwEKF00QI0QesqN9RArrJxAa
	 flpbD2IgoMtStzJ96Xl49RqBSZVlQ73o0LeB2Bggz3v3+sNLPuSswY/jJsVDr5TVcCDdX
	 8MCzx+NrQNughPpFkBOSZefSuIQJvOHuyuPmWP/Qm09hHzH0irzwu9uflQ2LX6qISH2yh
	 kuzLWh6K1IqhCo67J8ojK0p6mbn8W4aXgEzlBJHFVW1VCCAMObmy4Da8da1+rLoffAFLq
	 njrGXc8uLWJXUaMDIi4lc864qsQncK731TNKFEv5mnmWP0UlTZXres0twcmKw234ukA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795543907;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=aiZpNl+uwE4TnFcTqpYk+3BvyMy/85ssubMrmipa0eo=;
	b=uB0QTanx3xtOAIFgc2qL5Q717dSrC8x5//h3vgg53TczMGLIOyVTWdD0YpJHfD1c3eAl
	 BBiWzKDsFrwD1zhC9rQ0CYcLqMfmWJl1CdLVh+torK6RQRwbLGdsswi34LrBesWiY7aY0
	 ohpAYtIzL2HfyFhmdwSYTZotFPPkb0dLVbjZ2LdbnwkQJJFArUIrI3VrSHo2wIMgN130A
	 56f0ATK9N0W5Od7gSoDsAAU9z3k6JgmcfnCwHnrqII8DK+B27NoyRcbP5CdCfNbDjscIJ
	 IW4HEnKdZ2xOVo2NVUSFdgoQ1YnJRFgidTR6oSCVTKDal/dGaDysHV3PEVuU7YIGYqg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=OcZHRr4j;
	arc=none smtp.remote-ip=209.85.128.72
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03F43606A321
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 18:11:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 03F43606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=OcZHRr4j
Received: by mail-wm1-f72.google.com with SMTP id 5b1f17b1804b1-4a009f82bedso34627655e9.0
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 10:11:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795543905; x=1796148705; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=aiZpNl+uwE4TnFcTqpYk+3BvyMy/85ssubMrmipa0eo=;
        b=OcZHRr4jdmY8U1ocHDa9fLLOko5ZZG0AkgUFFlk1yatOxrpwA1tgw+c7XH0C20+FL1
         JbUymkY0L5CI11NlQYNdhPmNNCJN83L3bvNAUiskDP8ejYQoTqHGNyNXRVVs9liiSDsp
         Pu419xLFrjN0EyIJUxwCOkn+G760jmx66EdIlMM6p6F4NuPyn30bKdCC3awy1+21BtBt
         GaVbYYYbXcvuhbFgdvi8oI3tU88qx/C+ZdI7QlMiDmEU+EfkTRz2OvDgdtpbTSmsotoD
         XTSHO0emKCfBfhqqqVXoxaWiH15/OvtT/PBc61U4vmAoNX4iJYJWU537vYx4HJRThemN
         XuNA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795543905; x=1796148705;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=aiZpNl+uwE4TnFcTqpYk+3BvyMy/85ssubMrmipa0eo=;
        b=s0vEMQSlalqP6y90rLP7tSbsTCBEDfeCUa5NFm7WGzSC6ZLrOzFl19mmA5pgVRaGs6
         01pm2k5TfWe7D/ZhTGOqNcNEkBDfOovEq4Zb46ZHhkObxnNM9Kr2vZ/1h9SRKvtUZVB+
         Tt0MMWzqLo/Q5BL7rvno70sbJuPsuNSw2iaQE+4dLlF9jaTRzGxfhwGvgyzsj4q3QdEk
         0SDdebTbb6hmY5fmPR918JYvhRQfHOZNh9NeI64KsKSMm72izj/AzblzAI6kPh2XfQpX
         qC9gw8ZotXdCYIrycwXy0WUutK2IS2xxI15GuxxqwC7lbloVWAkBD32Q3LbrfsjKpAIf
         Wi4g==
X-Forwarded-Encrypted: i=1; AL+hErEi1fYAjAsG1FnGSNiegZCcCgcQvoIlqVu2tgA8c//9Xk9eNVXKj1kKPXGDSDRwAQfGa9Ym1xdcJXw=@vger.kernel.org
X-Gm-Message-State: APuU4Z86lE8Vzq9+G172CVTIEspGiZix+th1Ggw2qWH1DiA10HlJnqsJ
	pJYVv6qSa9D4b/zwZQxjSiCfihjYYFZxF5XzCBKN94yAlTriu3UkIlrP4NfAhGMvl3MjnIAzbA=
	=
X-Received: from wmlv25.prod.google.com ([2002:a05:600c:2159:b0:4a2:6ed:d59b])
 (user=dmnk job=prod-delivery.src-stubby-dispatcher) by 2002:a05:600d:600b:b0:4a2:167a:c939
 with SMTP id 5b1f17b1804b1-4bb88815f1fmr319343915e9.21.1795543904970; Tue, 24
 Nov 2026 10:11:44 -0800 (PST)
Date: Tue, 24 Nov 2026 18:11:44 +0000
In-Reply-To: <c029dfb0-0745-4b63-9577-1a373f7ff184@slotpi15m67>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
References: <c029dfb0-0745-4b63-9577-1a373f7ff184@slotpi15m67>
X-Mailer: git-send-email 2.56.1.663.g77904e546d
Message-ID: <20261124181144.143605-1-dmnk@google.com>
Subject: Re: [PATCH 2/2] nfsd: enforce cross-export and may_linkat() checks in nfsd_link()
From: Dominik Maier <dmnk@google.com>
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, Christian Brauner <brauner@kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	dmnk+artist@google.com
Content-Type: text/plain; charset="UTF-8"

Hi Chuck,

Sounds good, I'll wait for v7.5-rc so Daejun's fix lands first and
resend rebased for Christian's tree then. Thanks for checking (and
thanks Jan for reviewing patch 1/2)!

Best
Dominik
