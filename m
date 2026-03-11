Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C2153D3CE6
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2026 10:47:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773226062; cv=none; b=Qoq4OzOxgympGwTI+GbawDUesOzkBpN3rRlBjAPheq4/Dzv8OaRy1784NNz6mQk8T+03TfCq5+pXA/N1swpmEi/0MRKlfM1eJTGB+rDylV7lEuhNX23ge4B3siyXPr62oTxxhBRDV+fFnkvQrjMgfYEUVxYmyGF/8UC7aGMHKLI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773226062; c=relaxed/simple;
	bh=zRCIOZXGAulewyBbqGE0TlQlTPqeFeIDTbPGyy24MV0=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=M/Kvey38hxllltljXfUMcc0Q0tWF+/5PyKrN9phktKQxGWnHkG3ATtbdm6KS0CpsAme7GrSDTLiT9fBCVdIL57ALELxUEsO1pj0IgxmWrCUGRlRMNdO7Et2C3DSFDYEl0Y2ARDIs2wdfyOtsmkSOaIdm1vxK5oWecDvWPZ648R4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=l+NfnaGG; arc=none smtp.client-ip=209.85.128.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l+NfnaGG"
Received: by mail-wm1-f45.google.com with SMTP id 5b1f17b1804b1-485409ab264so6052225e9.1
        for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2026 03:47:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1773226059; x=1773830859; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:from:to:cc:subject:date
         :message-id:reply-to;
        bh=us9WYwCiTBLLsk5cVeG22xmuXfkRkjPu0Kbcd1njBZs=;
        b=l+NfnaGGhGE/Qag8NAZKtowOcVY2wLQCbEgf8MnpvieTQKfxTgLXG7gVpu41GQE3Cp
         lhcuSJ3ojhuoA+XvMW4ZK8DqWwguSBIQJdzHM+m0gGn1i58Im+PG8aw4GSSmMwNkHayu
         W9J2Et5BO3MOuAYEpSQbP4o8f9J9gsDj/OANzpqDRda1qkC6GXeo6tLR1/FbLVhhy7Cf
         MUxhHc5jx0lvSaHnxQ6WahuluHX1XzGqARVN8PyVe1PrQbU+agAKtUfEmOiyxhtTA+gY
         BR6kn5ugraDiB91Rov4L/mant481Z758KVbs1s66hkgz+KSI4U1uv3Da1yI4gGWMgZ4d
         Uvjg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1773226059; x=1773830859;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=us9WYwCiTBLLsk5cVeG22xmuXfkRkjPu0Kbcd1njBZs=;
        b=CISN/DECOtAbgbf/+5xMctUtyweHV4Q5FHyFYEs3t5Hdh/x4mOddYudu55/RSAcm2o
         lwojJiwlyGLLnDYptneYx6ht4t7kg4psyx7PShoDy3oq+KGiFlSBhYmUvvNE685Rxh5H
         dFSbLh+El5iQdKN6T47A8CrQgaWrstZE9gFhXFsrcPIChjAQQX2vQWmkzqZwAS5e5k8I
         fLAxloHO14T7BiXfm1WqWcp3wXhj6s+G90OHiLZ5e5nQnJniHsyDw9qGu5kJqTXHxUKY
         /tIUU6rnYCtSzhydPc2DzAxqLRCKLNd7hmSDZLnHg43E0crzzGykwX7GZblNht1BYzxS
         3fMw==
X-Forwarded-Encrypted: i=1; AJvYcCWEaMxGCzqL32qeW3sAMfYHxn08xcGnccP6tpYcxraYgnxZgZ6PUFXCuapC5nreZc8jBIzIKl077LA=@vger.kernel.org
X-Gm-Message-State: AOJu0Yxcn7mxlA6WBBNc+jXpToWO14D6oYXjP5g/wfDkFQL9fBXEFkOD
	JNX46oAKy6gVJvaqPzA3lwrW7YNsURf4hy5Zj+IkT73wl/BYvrbKxUl5
X-Gm-Gg: ATEYQzysdsUHHN/c7rKafocM6KGdogr8eeCzGt6Z6PGThcK1Kcud1huoNWtwqnPGfhC
	RwMtqDfW8xabOC5A5259uz44Lfyz3I4b2VsPdcH+yBAy9gMb2ef0hPo9N11LWQ+RtCz5wCMJwZe
	FIyIrzGrPbhVOnxQDyTRTL7uNdJABgGXDWd6jlLQnCUnqFSyhRCWQhgqpuQYK7FmhDnugrxd8nh
	SetQYOtpM/8F1Q0sKHTfbm4UvCpux8kIFfPWAMIDMZpUmqBeMDsCVNuc6VsvRIB6P/TThqEN6nK
	ri7novtcMcnAC57IJqb9YCdN5+SFRKVsgoZ+Xxpc038yLTpWd2Cjq6q/KihlKObxdpqOOK8bNso
	XTELe6ew7oU3XSDTNzXjex8/SFOvfZpKeDgw2p76SdSMDufgmfHUvYUI76yUGkydID11i0azgUk
	aRV1I58Hy+3ZgIjwgctYJwo0HBA9LsoEI8Sto3AeRAceyuajS0dmcOl3gnW7/24mhmqps8txnTt
	fc=
X-Received: by 2002:a05:600c:5298:b0:479:13e9:3d64 with SMTP id 5b1f17b1804b1-4854b291dc2mr30148705e9.15.1773226058755;
        Wed, 11 Mar 2026 03:47:38 -0700 (PDT)
Received: from pumpkin (82-69-66-36.dsl.in-addr.zen.co.uk. [82.69.66.36])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-439f820a2f1sm5725154f8f.30.2026.03.11.03.47.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Mar 2026 03:47:38 -0700 (PDT)
Date: Wed, 11 Mar 2026 10:47:36 +0000
From: David Laight <david.laight.linux@gmail.com>
To: Christian Brauner <brauner@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
 linux-kernel@vger.kernel.org, linux-modules@vger.kernel.org,
 linux-nfs@vger.kernel.org, bpf@vger.kernel.org, kunit-dev@googlegroups.com,
 linux-doc@vger.kernel.org, linux-trace-kernel@vger.kernel.org,
 netfs@lists.linux.dev, io-uring@vger.kernel.org, audit@vger.kernel.org,
 rcu@vger.kernel.org, kvm@vger.kernel.org, virtualization@lists.linux.dev,
 netdev@vger.kernel.org, linux-mm@kvack.org,
 linux-security-module@vger.kernel.org, Christian Loehle
 <christian.loehle@arm.com>, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 1/2] kthread: remove kthread_exit()
Message-ID: <20260311104736.51b53405@pumpkin>
In-Reply-To: <20260310-work-kernel-exit-v2-1-30711759d87b@kernel.org>
References: <20260310-work-kernel-exit-v2-0-30711759d87b@kernel.org>
	<20260310-work-kernel-exit-v2-1-30711759d87b@kernel.org>
X-Mailer: Claws Mail 4.1.1 (GTK 3.24.38; arm-unknown-linux-gnueabihf)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Tue, 10 Mar 2026 15:56:09 +0100
Christian Brauner <brauner@kernel.org> wrote:

> In 28aaa9c39945 ("kthread: consolidate kthread exit paths to prevent use-after-free")
> we folded kthread_exit() into do_exit() when we fixed a nasty UAF bug.
> We left kthread_exit() around as an alias to do_exit(). Remove it
> completely.
...
> -#define module_put_and_kthread_exit(code) kthread_exit(code)
> +#define module_put_and_kthread_exit(code) do_exit(code)

I'm intrigued...
How does that actually know to do the module_put()?
(I know it does one - otherwise my driver wouldn't unload.)

The corresponding try_module_get(THIS_MODULE) is done before the
kthread_run() (and has to be 'put' if that fails).
So there is an explicit 'get' but an implicit 'put'.

While a loadable module that creates a kthread usually needs to give
the kthread a reference to its module and then have that reference
released as the kthread exits, I can imagine cases where that isn't true.
(Or broken code that just hopes the module won't be unloaded just
as the kthread exits.)

It actually makes me think that module_put_and_exit() ought to have
a 'module' parameter.
Or, perhaps, kthread_create() should have the module parameter and
hold a reference to that module until it exits.

	David
