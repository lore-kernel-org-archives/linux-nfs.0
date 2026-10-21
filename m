Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.46
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792592814;
	b=SLGTZveD+IjzdrmuYI8vi7Fpr1WytL3CqUss/CobjtllG+8npKOHRBB/YJavtb78nFMX
	 F3kTFSCOJtv2FOz03z4jvUo0185wTI4EuFIVVlqwigfrdJWICE4mSwjRrU0X8yU8nu/zO
	 EX3T8y+bOcISnA3HvtjxlN/7xV3h/Zv8JFIrJxvoKKYWeCl7QUt5KlkZLP/sepPZlZ4Em
	 PSisLHUHtWUQ65vfx84jyoVGpCi8BJMOfEX02wlGXtNLjzk9YHAdIS58F+vdKJ2d6rvGT
	 Hzb8wFqh0T7kbgnC9WJ4IriujFkilwKtJQjxMWQks/cjmzTaA7/3LN8yZMR5zrebb3g==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792592814;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type;
	bh=HZWCDTWe8myvVLhLnC3gRwnDw2Z9dfDRU9KvUScIux8=;
	b=np/+hQCx37JvdD/UBCzrah3aWrfQSOYcA0bmMVYNlnHhGn9UGVTlsfjatPkia/5jDxOd
	 LjEQGJ2Ma5nyd2Yjz/bn2LNxpzcX+EPKoNadYpeme/yQbi5AQnXqXCiA8JcaIRCTd/qaC
	 HXJAwt6cmdZW19O8L3R2fla+Ro8XmYV58FbGbSgySseOI5Uy+tCKwdm9oO7kaXM2Bf55N
	 Wkc8SH6Q1liR4bgRnRm7ECkNvNA4OTSkOg77v5l5IbKZk0JCR4L8lL3ZymZdrGQe0ivFb
	 s+BFrwfqHZ7mjTykPzULHMNtUyRfy5T5wBp0AlVnOVr/NUtyer86oYP5ovsQBDbwwDA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=BRqHAhOJ;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.46
Received: from mail-ed1-f46.google.com (mail-ed1-f46.google.com [209.85.208.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C37E606A321
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 14:26:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2C37E606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=BRqHAhOJ
Received: by mail-ed1-f46.google.com with SMTP id 4fb4d7f45d1cf-6b1ec41d8e9so825391a12.0
        for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 07:26:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792592812; cv=none;
        d=google.com; s=arc-20260327;
        b=N/2FsWKTcAb/tfK5DmD7D9240rR7fL3fPlsYWJD3eGw70e6Bh6gaqLmS0o1uhVaHej
         2tUusDtj46STmSa9Jh9gcrGCF98gq2AjvsIp7FTpGvZu9UK4R3xVRqi3qOZ7Qum1g4hR
         1TTbOMu3rqJKf6YbW+Hm5fbRrrtRSqPteDJ7vD4S8xQbbqrKKshzRwEwYcv/CGn7SrDw
         SqF7HoGJZUq+5+iTnD3xMeF7SvWAHUapmKx/+kF9cm+ZmhtxA4lMgzzeJv5Fa4NIeq/w
         j6Io/g22QqYcf/zx8A86QSK0Vl6EvrpFouTaey57YlYbv2jczO9fJ7e3innyyWe4lT6I
         7YGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HZWCDTWe8myvVLhLnC3gRwnDw2Z9dfDRU9KvUScIux8=;
        fh=NMuVGTsJhdjoE8CM+2LGz3kaR8Gdfs2sIF+X7kZBOew=;
        b=QPyWterVygKL5JDLo7GxOfXjTzvuWXS4Fek7m+ZdLvihWw5RmLi4RVeZs1p7kFZCTF
         53pn4vCuusY+hPSXzeZIwHGrtRy8SeoIifmKgx2SxJYZlc+tBwHoIDMIghlSzjlCqSR1
         5VEf2vaISKHGJQhTITAvbg6uhMkucsyfP1m6e7PMch1i1b1Y9sMfaOnemlncDnM0JDFV
         R/wB1zsKsCWfrn3CIu37bpuRcJj+ZfGnWOXy0umxeij6pcok9HgY6Tv2DxJMv4aA0Jnq
         J/k+uA3gX+HqJ3T5fNepPOv9dcTzk+sd1wZogbUIeYFrXDQS+alCVD+6/XgdIJ0su4Uw
         DnXQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792592812; x=1793197612; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=HZWCDTWe8myvVLhLnC3gRwnDw2Z9dfDRU9KvUScIux8=;
        b=BRqHAhOJRFQGCZ0436cerbXsvDGcjOTtcEFCOpJRV+nbVKbSAKMl662tBLFTfb2Sg5
         NFxQNyHoxxgYHQR13h13k71ankQp/N0fxgwfPZdFZZwD0LZwBvhOQiky2tnvBNcGVE92
         vpRJ7hzp6lhKrZveGyDGkQ94JZjS5rrim4/SQCOenhyqo5st97RuKWVFwTkWZQ5bTbIw
         iWX7FjROAHIvHplEaKREmJYGpSp7sUQFKLAPhXVjYlSpM8WQnUK4iSviJf2DCzgxJwf5
         mmlBS+ISZT3vDsrX9Xx3+f3KYgz6TnHUVdIwJP9bY9OfNIdfJdTh5lFsIo+qwhCRzOmH
         nAiA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792592812; x=1793197612;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=HZWCDTWe8myvVLhLnC3gRwnDw2Z9dfDRU9KvUScIux8=;
        b=thV5CZM/eg4qEP1cbJjriRLt1+HSD1Gj5swzK7w92VGcjzvRMqclHzZLyXKQKPyG+I
         0EmscDr5nIRGslm4/joDmTEpnUv/xcUGBZ2/c/oa7J4kN0f/Tt1ylVS/efV0dWu4+Rdl
         liRrA3+hA8jYBIeh0xavfoOGsiWidd128qFcBTNMTMIuN+UpMh/t+CyFnMwpzRhxkG+5
         SUHgvmYw/WxJUcdS96zFVTNXkSb+hK86IIgnTWQ/t4Uj8fvudZQZWXrJ1m9fFyBHDVpA
         yxoMsoZQj26ftXMzLJnrpbITYxie1/X0r5T+DKqpMpdcYsWFKVEALGE7V0NtZncOqEqS
         WbbQ==
X-Forwarded-Encrypted: i=1; AKwUvBx/Psbnb8NheYISYnsxFIBSc2Ky6mYIuXnjGaQmzZHtlvQ7EGL4oD8NQ49VUOE/NdTfs9WEJvpXd8w=@vger.kernel.org
X-Gm-Message-State: AFq9FYISVDicoljQeL6HgO5JxiO5Hiuidu7wFRauYwQmicSLmfjIOj9f
	ytroiVEiSZhl1eBnOkOJC/1EYcaafMiOYI4MHiJSMgdmiCos12aWdqiQjZYbiGx4t/CUy6LM0uz
	i2JPk7eqBiIXvxwEbByqg1QnfcWESPqw=
X-Gm-Gg: AYBFou33p0hDb4oNbYGyfQ1kGPVErVAjp17cWS3CrRyYtSlDYAFdWOTxpYRIr0GmAri
	KI/WjM2tiBVtJqNfn9ADTNS0ay+FrvdlVbW2n2B4/uwJaeDU+qwrKif6+4sPoKBiBEwUDSUnV8i
	2qFEbQ42MtHdBhMEVGOivNtRvGANIx9DEaBhMvifPiLLVcWd+CtARQcUgFnmJ09MvH0JdAF97GT
	QylAzRuBM2fhHztZw11q5cO61O+zdRE7qRE8nkZLRzcEazTTyeBsu4JiP3l7ZVtEXGPu/1UeNMS
	FQLLLGYww/TKREqcgyuqEDfaLBDyjU6KjfJDRwGATiFD5sgd5kTvcWBYaTQKyLj256maiYTcR3a
	9OJhJsLnmFeziXNMJoUhjFNT0ItNQFD1zAzII
X-Received: by 2002:a17:906:c105:b0:c33:ca5e:8ddb with SMTP id
 a640c23a62f3a-c46796b58cdmr190770166b.28.1792592812271; Wed, 21 Oct 2026
 07:26:52 -0700 (PDT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <cover.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
From: Lionel Cons <lionelcons1972@gmail.com>
Date: Wed, 21 Oct 2026 16:26:15 +0200
X-Gm-Features: AclHuK9oo5ZYObAiFZur0ih7xDKEBxlKdO-BvoDx6w0mXhpoTx1_PdEXJcogV54
Message-ID: <CAPJSo4UJPnhLFAYRXE-_M2_Nin6=Ff02AjayD10cB7946MvJDQ@mail.gmail.com>
Subject: Adding dreaded Windows SID-style, or. Repeating history, the bad
 chapters. UUID/GUIDRe: [RFC PATCH v2 00/41] UUID and GUID user and group ids
 (*_r system calls)
To: Jan Koester <jan.koester@tuxist.de>
Cc: Christian Brauner <brauner@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Jan Kara <jack@suse.cz>, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Paul Moore <paul@paul-moore.com>, Arnd Bergmann <arnd@arndb.de>, linux-fsdevel@vger.kernel.org, 
	linux-api@vger.kernel.org, linux-security-module@vger.kernel.org, 
	linux-arch@vger.kernel.org, linux-ext4@vger.kernel.org, 
	linux-nfs <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, 
	netdev@vger.kernel.org, audit@vger.kernel.org, keyrings@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Wed, 21 Oct 2026 at 13:24, Jan Koester <jan.koester@tuxist.de> wrote:
>
> Hi,
>
> this RFC series lets a user or group id be a UUID (RFC 9562, version 4)
> or a Microsoft GUID as well as a classic 32-bit number. Processes can run
> as such a user, files can be owned by one, and credentials, ACLs, keys,
> System V IPC, sockets, signals, audit and procfs carry the whole id.

Are you Linnux guys aware that this is just a variation of the
*DREADED* Windows SID that this patch tries to introduce, just with a
new name?
Maybe, before doing this, read about Windows SIDs, and why they are so hated.

Secondly, the whole idea of doing 128bit hashes as UUID is not new,
IBM DFS had it, and had many iterations of security issues via hash
collision exploits. 40 years later all this horror comes back. Does
history really have to repeat itself?

Lionel
