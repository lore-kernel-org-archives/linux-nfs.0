Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.173
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793957703;
	b=WpdG3Ys21My4Uc8t++Br0xzqndSCRZ44vjbe1Owscy3Pem9Gu7HoEL2KQCWkmGgnUflH
	 JNic2g0dsm1RgWInQmLIQQDz9v7gorXtNPIu27NWCHef+q/PS8f4l90hRe8QOKoEdAysO
	 vUIncQq4uyhu52i9Gapz5zBa41SH930JjDbkDOsI2GYzfT7N75b7wtEy4Hg81kIS10/zu
	 k0N7ck4zJmawZpMvpY5z08DNA1mEgBFRc39t17z7KSdmDuzGHI1x4HbqByMS3035VMckt
	 mmvk2IbBxtURJLKAG14p6qMSZ+wfiMaL6g0failiS5kCWqGz6sgU7Ctpd6sDeEuKodA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793957703;
	h=DMARC-Filter:Received:X-Google-DKIM-Signature:X-Gm-Message-State:
	 X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:Date:Message-Id:
	 X-Mailer:In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=/nagoJvCaOuoTBjnnbQlXdvxMNcYkalOnvwcPXVBDCg=;
	b=q0vRyHefL/DH/yX5IhxthBDJ14WRvzfFJ9ad39ES+PTu6o6gXz5hAxZiL/bz2Uj7xryE
	 D30TdfYWKd8FQP08ZuWFSv8LGdayefcRLiEUHZl42j4XWj//xJZNtGmTNmTaI13M+YyXq
	 AF0Cm6R7hKIeo1S+nOTuUrU4TjnPa608OxUupMT+VSrkvjZaoWGv35keJ7mofQlFgW0bY
	 7jTKf2PBNqLzlkimms3ifxgbinwStXN5LsCBMKS9I3MdNItIYSmscjbPUplBKL5/vZPq3
	 3qUWA91VrwAUpJSoi+V+tiAcbXpCXHjyCok+uXLiLD4YtlT7Xma7lY0t3EyKvhL6uKg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=fail header.from=gluesys.com;
	spf=pass smtp.mailfrom=gmail.com;
	arc=none smtp.remote-ip=74.125.82.173
Received: from mail-dy1-f173.google.com (mail-dy1-f173.google.com [74.125.82.173])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 16E71606A333
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 09:35:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 16E71606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=gluesys.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Received: by mail-dy1-f173.google.com with SMTP id 5a478bee46e88-36d499f6ab6so47832eec.3
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 01:35:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793957702; x=1794562502;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=/nagoJvCaOuoTBjnnbQlXdvxMNcYkalOnvwcPXVBDCg=;
        b=kOSCoeRIaF8lxMnL99BCP8rOO/eMbX7m3+SFAqvNv0womPRocN52jlZbKCu+S6mXdR
         youedonvIcFGJdpaVXq0rKGCFdqGjLLhPecUgIBu8bELhz3Wyqb4tIRqhSfJSAc0ss0M
         S8krwRsznm7k5LaIHnfeA4IZjEptAmSFT/vgP8cCsxW7REkDR5CcPLltIL1tgTMmEtmS
         JVt+/3AWA7qnyvAVclXWhJVcGShsJX5wByiihRwzs8it8Yy153QwVQseHNqVnVmSlya3
         YQSAsk8n7IrlwgAphDlni/T8guvxfinbVAo+5JskX1w/1nUkBbFmm00zWrwz/2P7uwO2
         YZ6Q==
X-Gm-Message-State: APuU4Z+isrSU4DCwbYYkz8AoFGKE/OI8twOLJZu03ONeZfLO8qMAuDRT
	Rsjqx4xpDH7R1RprhZsxwpo0iAUG+bIXrCkqzskSCDAViPu0ULKNUeeXHEEZHkW48K4=
X-Gm-Gg: AYBFou3foDtcPBf9B4xBFO1XXdEcsVx+HPwEyTSSxh6rk/Y0fGkzRl3DdMP/0QnmbDO
	twDOUymDiDvVG+mtcChg0dP0GHQWJ5hZDx+BKzgrX5XVQPITd34Ds3kMs7VOjGKe0Twro3jATry
	TysUZEWUo0ui5mnvyeZ+ZPEPZ5rwFfFA6n/vx37BHrl8kY6qV3tSLVgjmJr+/UnnCz3Nvmwquc2
	0EWL82fYHUsxX2t7AlwtI2t1MXrG78VIAjn1IbCtCMYbSOgF9934SIc4+2ZKCJ7kbqf5SiHm1Qx
	MU/MhSzh5T7EDu13wh2VD6/7uNnesKX/dNuJsIYbvmxok8nXsW2QEgJ8l630GekOFYup7EbQ4OQ
	/mXq8QvI1l2B/uArcFVmE/c037B+M9poBS7lspANVIVQB7Pifze+mwUMm1ZWJKFNLCzI6nJtePu
	pmLxmAfJU73ztmUa3IQMR0bLGovXA8BV6GV/gauBuM6/bbv6ok+nh03W5J8C0E7M/iMZrprx47f
	CvqrQCMQM1fGX9lHfiyk76/OcJd3aFtAK7Kl0mPfpRKD3rHi07HFVKjZ5PsWzThaD8UJpclqXnN
	VAYV+dxoWOR3X6nsBo+6RhCWGL7RYmttjViqOZm8Mw==
X-Received: by 2002:a05:7022:b88b:b0:147:d430:7322 with SMTP id a92af1059eb24-1b25d2fa635mr3592738c88.1.1793957701818;
        Fri, 06 Nov 2026 01:35:01 -0800 (PST)
Received: from localhost.localdomain ([112.220.91.130])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-1b25e4f03f5sm4297856c88.21.2026.11.06.01.34.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 06 Nov 2026 01:35:01 -0800 (PST)
From: HeonJe Lee <lhj4125@gluesys.com>
To: linux-nfs@vger.kernel.org
Cc: cel@kernel.org,
	jlayton@kernel.org
Subject: Re: [PATCH] NFSD: wait for nfsdcld to open the cld pipe
Date: Fri,  6 Nov 2026 18:34:57 +0900
Message-Id: <20261106093457.1682504-1-lhj4125@gluesys.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20261015114755.33331-1-lhjnano@gmail.com>
References: <20261015114755.33331-1-lhjnano@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Friendly ping on the nfsdcld daemon_init()/daemon_ready() conversion
posted earlier in this thread.  Happy to rework it if there is
feedback.

Thanks,
HeonJe Lee
