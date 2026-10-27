Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793134355;
	b=YLc1XCOhS6ywd15x7R7IoBFlwS7rGvlN34A/xusgtXquqU0OuVsRrbPRzZPEpppb3fzn
	 ufO2C+BQQ1E5JHPEwYIkaqToImDhoCGM7HDPkr22Rs/Z1aT42kTok0cbCYiGmEmWc5MIy
	 GDAyJYKk5ZLWdGefFx1LXfeISrIvz4CPlNeOOp6imLzJto9vaDvH83cO33bU5Xb4oIDbp
	 Tp0bgPnNM5RektvfB9UzmM/Mi0QvujBBNJxCo4COy1zqCNk/Vgk2eO5xhi81I85LR94xv
	 YwvcKrXTorZ1XrRPkB9W0N5QHusAIpTutqHwYnjgXlzQdma32oAmb+IbIJIyTM/lOwA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793134355;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:X-Google-Original-From:To:Cc:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type;
	bh=35VQ/fR8oiUUzDAD8RIvkzl0eS3zvQ5tNCfYkxf/9rM=;
	b=wVx05hD75fGm0g15aX8VY907cFFt5DEM3yRKnZ5B77h5OuLYem2+HEiQgBuzx7TIiprJ
	 H7BzfQExAJwb/ST+z/CFdIrtD0PcKZ4CvO0sGtzLPogwj8TCw1kUzyLPFAPMbYfVkLXzt
	 yAgV6KrjK6rMhXvIhbPtO8bGmZujnOAOpRSIDN5AYJ7YR71GuzYnXiupagOYPMptcYY02
	 TC5iQ1e3I791T3JKARZmi4MoFoi5NgleZ75eI1Wg3Eu7TcfVnSCToLsReMW39ka1WhVVb
	 mXfp3MNsMfDmk5dlsPtiJOzsvHiEZbsWF3+W/3eEosLpSVezwaK9um3IWbgQtEmpcTw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=K+ejH1yO;
	arc=none smtp.remote-ip=209.85.160.45
Received: from mail-oa1-f45.google.com (mail-oa1-f45.google.com [209.85.160.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 19A11606A31A
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 20:52:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 19A11606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=K+ejH1yO
Received: by mail-oa1-f45.google.com with SMTP id 586e51a60fabf-49429181ce9so223440fac.0
        for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 13:52:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793134354; x=1793739154; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=35VQ/fR8oiUUzDAD8RIvkzl0eS3zvQ5tNCfYkxf/9rM=;
        b=K+ejH1yOqz1/6xhBeq8yvP0JKm3gXQT5/MhSjgmMhzNLkxNn1fr7upW/ibpMy9RGcx
         gMhuxMMyHVJXcLtPuIbE5kNTK2vFZE91VLwtECSwIRYHMu8wk7Ry2dJxwH9woAHFlJIr
         bqkRXHg2w+hk75ZRrn21cpgBhLx5d/rmmr0Bl10WwZVGV3ttjMq6t2D4aIhayykwjrXC
         m7QJXO6QPBtzvtq2wDDkM9rA9siE8pku438RsLbkwRbrs/2XxpxfoSwpMs/B6IJR5V9b
         OlAgtNKV9kELcIVSJWLe1w1497yO147G5ZEpKyRp3lH8znBYpy+9GO2Sfe97QQnmKlyh
         w2nA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793134354; x=1793739154;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=35VQ/fR8oiUUzDAD8RIvkzl0eS3zvQ5tNCfYkxf/9rM=;
        b=Cul7mT/JhQDVowshDCkDD9iTXjLZkj2avAj6jVR8uHxv/2ewiZhbRQMNHhbGi7OnBW
         3REvRRKbzY2b0OiSrmko6i4bQNlxEfI6Rxy1QNziCuYeBmTWhju8WSZz3DCg/ZONsaxP
         2PxsS/6bb8BT/pFYPTrOgBgw60QZDjGCX9SOBnvrFGeeYIWu8OkgV381+oaoy/sk8P6c
         PDye9EoZrtyyrRZuvq6UfEBu3pOyosAgtMc2kTkrCFcpZqUYAYvtME7emmgLGZgazAlJ
         udkLnGrGgpcaUQnAwrkHWb89rD/dhleVWiXPql1rjUQavbteO2Mo5qUZtjC4Hy8w7orO
         nhwg==
X-Forwarded-Encrypted: i=1; AKwUvBxCUY1Kx1alAKdCoBF0UyoRk8rnrfGywm00c62xc1+/QBcahH/hUnqzX/+RWAIe26KQpWcg1JHiWW8=@vger.kernel.org
X-Gm-Message-State: AFq9FYLTkSD43w1wVm9xChxJsmyLNcH0HrRKx8jqSL03gl7vL0FR/2p9
	7rUFRN4rJ9ReFNAvWW4gA0kXbrqOhfVk1+1afrhZYsSDtECedGSHcr4kSZvZ1wrxOGU=
X-Gm-Gg: AYBFou10uLTMdAeejHmq0r0HwX67VvpxhRKW08lhTPr0lU+iBaUv5c6bQkOdm9+cmr+
	tBAZfH1Q++6YNIG7cLX872ejRgMx2EnEny9ZxBxqrlBUZLlP8ESMNvnXzO2KqUIoNrM4imABepM
	ugy78kUBSEpwsiaZPz4NVb+UDQZ7w/O7sxga7C7G56vjgQXnlbl3OZRuervWhxpn0caL1d/zj/i
	sCcWGXJKiVMlrPcrLh71iQVpg6MUiigOjKYhySd6QbJa29olX3uGzWoYdM0sttcJUZOCkp0T4W0
	CyLqKPQG59Rnp18IOf7GoXererTMVY+77L8UtjMffnwdwoDe0qo1BtcV8yfPJNHNwZ56THNYpFm
	a0fAUstZGWTgMy7PiUv8FRVbpBrCGPI/LCIQWmd5m9T2T61PyrFC/uOXy8ahfHsUhe2HesdYCk0
	69viuZmmIYwdplySWJWG5gBnYQ/sbt0I0cv96SIPLR6nXWJqgif4pqQxDpCoR1T5JG5NjBeGtpM
	lNqMcNs2nRKqwwNfBZ4r7KBN4jrjicoYHJZWsHRNeHZHsRLa0in795zaNBzi70b0Y50ogrvDPrx
	jvg=
X-Received: by 2002:a05:6808:1686:b0:50a:6fcf:d287 with SMTP id 5614622812f47-5638328b713mr238455b6e.37.1793134353829;
        Tue, 27 Oct 2026 13:52:33 -0700 (PDT)
Received: from [192.168.254.51] ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a8b790298csm975281fac.14.2026.10.27.13.52.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 27 Oct 2026 13:52:33 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pNFS: don't send _NOMATCHING_LAYOUT if still doing IO on
 a layout
Date: Tue, 27 Oct 2026 13:52:31 -0700
X-Mailer: MailMate (2.0r6272)
Message-ID: <C997640D-ADBF-422B-9406-AA7E90BC83DF@hammerspace.com>
In-Reply-To: <490422e102050d938d9aca83b4e00b6687978e32.1793126664.git.bcodding@hammerspace.com>
References: <490422e102050d938d9aca83b4e00b6687978e32.1793126664.git.bcodding@hammerspace.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain

On 27 Oct 2026, at 11:45, Benjamin Coddington wrote:

> From: Benjamin Coddington <bcodding@hammerspace.com>

Sashiko immediately found a problem with this one - it can spin the state
manager.  I'll send a v2 tomorrow.

Ben

