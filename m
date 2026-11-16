Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.70
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794830457;
	b=nVVVXstUr8PV5pHTbc1wrOhds/RPBJtO+BWgjzd1ymgrNC5i5sJiGXHwY26+KtA4S7kj
	 lgxSM7lKnGKbwjGluGJ81napB52QjrY4kyga8uJzeRs9BUOUOZf5DKHwY3ju8KUVTfu4L
	 7/C43uhfqn/kvptkAYRFNfCzyAPk29cikD0PS7YwtRcUocoM35kCc48tvn+BitBjQT9wt
	 6mXLq7yZrA4oIfyo6q5kpF+37mIOgZiGnaAoMGn6+8L9qnw8ux2sN89argHWBYsDxQcGl
	 DHzIJMrEb1Czej7vKNZ+nwk4vyadI+Q2a/7tmQDqkQkaWrG88hWFz2tZMoquxhyCz/g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794830457;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=kLAz6sn1EqmF7aJ7KDEBtraVgj4ybxLcfJJY1MY6K34=;
	b=tPLwZwXRPdw2KdCaOegLLqTCswnD8wq5uA2ya7tS2bzF3/ZAByXqPRTbwgNQXNAE5eW5
	 fG4ga2OaV3z7zGGoMzFf9KJmfnDzPBIGnTMWBxBN3/WVWnu5ZRIoUk3upnoqAdYBICbpS
	 5Y7pIsutlTwfcMS7EFV+GXCOG4noGhRFHQTCKPeKP9t9EZguBGM2Md/K2BGt7A06jZT+x
	 m3yUdu9fYjAIolxFPUQU5Ic0OmNPV7ur9Ms2xpCf0aAu59sjkASSfQcz6gFBeUELdFO4w
	 +ucRRPSJtRU93mXGNfl8zSlSpZWQ/S6RcRE8XhP77RZT371+pzC4QWUgPFWUv1/nb7Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--aliceryhl.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=O4rHL3AM;
	arc=none smtp.remote-ip=209.85.221.70
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 24E33606A32F
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 12:00:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 24E33606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--aliceryhl.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=O4rHL3AM
Received: by mail-wr1-f70.google.com with SMTP id ffacd0b85a97d-48e0461e040so2973438f8f.0
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 04:00:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1794830455; x=1795435255; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=kLAz6sn1EqmF7aJ7KDEBtraVgj4ybxLcfJJY1MY6K34=;
        b=O4rHL3AM8g7HMj7xZzkNnKWsQ68P7OhGhMaTci2p92KRiCQKBRod6d2IiBWvipb+DC
         vxIULYuCXp15OPRCoakat7UXJvZIlTm3l608ZOpeQ2tSQXP8F1JduWNlJvmJluBhwx82
         /zjz5RQKsdngqWq2MmIuxSHyh06B4MAfnWmvKvQxetAbGOpMt4tj9yv1/rUEGuXhF3Op
         l1j81S/wHFyKHwmHIqKvzrYEnY13ONP2ciqmD/iT3Hmn84+4ykJqyBiqChsToNXVzSp+
         o+ANBoTZBCPfy4AMYnFAKcCDqm4IN6I9woJSAZjp0OJbMp9884FpNNs3o+ebUrN8UDGH
         OZVQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794830455; x=1795435255;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=kLAz6sn1EqmF7aJ7KDEBtraVgj4ybxLcfJJY1MY6K34=;
        b=uh0DNDp5knkYnBNBaaMzCBCrvjAVQx5IzsoQu+o2lj0ZuFutJz/w31hqzpk6XuhoL2
         E1Icamzq4ih1r4A/2pDK8SbLRapbwDo7wziCYWN8+KdS9l+33pXmYswvFXSKpz5xDJgX
         eGc8utmXC0BG6SXvODq2kmkcIbfaDNtS7w3jZn2rkv2asei37MGG2Zm1NLE11dsVTdkC
         JbdM6dhvu2L0+Dbm+Wsxg3naTS1NkdU9bRGIi6coG92PQYUG0Xe1CuJl7weD1n8HXK/q
         8wX6PdWVtFNsaJuiEI8p13RmJXbC6eHR348u0cj7c94RRLGk0XvN2c/H3ZQPVzzxcvAE
         l4lw==
X-Forwarded-Encrypted: i=1; AL+hErHIXuWjHhQvw1EKfoedO4DE9QTFaRp7NDhEbSAiDjC1BUBrwDIlR/jUcoomFAQjAMS2vZ1ae2CZGbc=@vger.kernel.org
X-Gm-Message-State: APuU4Z/UB9KKdiJc5LlpFFPpn37muDtsa/G5O1npdzvtMk9NNdftfoTS
	u6J7fhyf8Li0+paQm51lwDzN7kd/TVl1xxsDL1fZyunxsLOkpZb9LAvS8ESLiglqKPx9zwI8IZt
	4gQDpHriWBj/kwWp1iA==
X-Received: from wrso13.prod.google.com ([2002:a5d:474d:0:b0:493:3d97:6e88])
 (user=aliceryhl job=prod-delivery.src-stubby-dispatcher) by
 2002:adf:e007:0:20b0:48e:3697:708d with SMTP id ffacd0b85a97d-49c70ed8e41mr16698595f8f.12.1794830455230;
 Mon, 16 Nov 2026 04:00:55 -0800 (PST)
Date: Mon, 16 Nov 2026 12:00:53 +0000
In-Reply-To: <20261116-work-loop-pseudo-v3-12-8cbbea1cf34f@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org> <20261116-work-loop-pseudo-v3-12-8cbbea1cf34f@kernel.org>
X-Mailer: git-send-email 2.56.0.611.g1030f0b940-goog
Message-ID: <20261116120053.371591-1-aliceryhl@google.com>
Subject: Re: [PATCH RFC v3 12/44] rust_binderfs: use fc_init_pseudo()
From: Alice Ryhl <aliceryhl@google.com>
To: Christian Brauner <brauner@kernel.org>
Cc: Alice Ryhl <aliceryhl@google.com>, linux-fsdevel@vger.kernel.org, 
	Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>, 
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
	driver-core@lists.linux.dev, linux-mm@kvack.org, bpf@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org, 
	xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev, 
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
	linux-usb@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, 
	linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Mon, Nov 16, 2026 at 12:04:45PM +0100, Christian Brauner wrote:
> Initialize binderfs as a pseudo filesystem instead of raising SB_I_NOEXEC
> by hand. This adds SB_I_PSEUDO. binderfs_fill_super() keeps clearing
> SB_I_NODEV for the binder device nodes.
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alice Ryhl <aliceryhl@google.com>
