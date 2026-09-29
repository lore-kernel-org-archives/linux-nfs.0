Received: from mail-qk2-f40.google.com (mail-qk2-f40.google.com [74.125.230.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0678339E9DE
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 07:30:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.230.232
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790667062; cv=pass; b=V8KNC/xOMy5KHUuJ8RBq53c+0oJQ+eVwBhjMYuDACgVBnj8X0KrEf+Sp6TRahaMwzVYQGtkYclFb5huX/QlSjgpvBihvEmb7vBcZK8ayGbVL0N2g+ndoJtC2bN1zBy+RmJSVNIJOXLh7tEe7ybUCZee2E+qQOMQV6LtEgHNJL8o=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790667062; c=relaxed/simple;
	bh=I35gDNGA4fpIsc0ElTO4/D3swmmdD1nD0eRHXQrQQRk=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=IdCLs9cXEv+UzgA2SgFG+36xpBTTnF6/P1hSb5ADKENo2vAmySKGTCa9IWbaLIscaZ/YzQWytnZCSPCGLnhrluxQr8pNU13tFbmOCdAJquG4KrUO1+LVinvAfN8tGgTTDQ1gD53m8hx7sxWhLccW9Gh53yZbK2WNAdPLuDuR8hA=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=bEz6fVnT; arc=pass smtp.client-ip=74.125.230.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bEz6fVnT"
Received: by mail-qk2-f40.google.com with SMTP id d75a77b69052e-5332a80a731so32062751cf.0
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 00:30:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790667059; cv=none;
        d=google.com; s=arc-20260327;
        b=aRt7t+1hBanIlepwO8KZ2TRIpnmFpyul/jx4pwHQnldKDHFmGHG7fYsEjLzFen3UYu
         vn4lwij+m3YIrUJwUXE2rR3HIMgCy2Q/fsV6U7tknlBCfVWRTxwmi0ag/nuE0nxs1jtO
         RjuqDQuMwj6F8FLAfWjIGxo24wd+JwAx849UlVcZUz3dS9zfoBJYsnGqVdqnRdDmh6yQ
         vDoe/8XJiUJUzFvUgAAZAvGXMfUtDDJb2V7Aca8G4Vci6gA3Pu+/M8ARx7MGBla7M7T3
         MDejRgvT3KGGwXK973bDuMVDKuan4QORmDXW8f940KllBA3jsx4/zf351qpR1265fw/J
         Vr/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=9v/Z0GcKezXBRqzYvyQ4v0b98G06dRHjg36qbCp+fss=;
        fh=Vi9CpR7ZDNbEJY/ZfyPNAo1SLWbhFJkuoFnZ2ql1an4=;
        b=bFmW0jry7PIh1YRSlV9tdGxmE7Jz/wJ3twoMl7Tzeb+YE6APsOyv57t4pqN3Ou7LjW
         ctkBrfbF9rPwVnCMKlSLVGufO4Lxhp/Qegps7EoqiFMf3CDS9xFrsYFd3ve4H7won9JE
         TBHdTRlSEvZlVSkw7C2iS279dWW7GXikVl9vBJcSC+jlI35FJC0cHvOGpIrMRr8sLbGZ
         1rt2X09o14dZkY8Jl7T1LfxrDiRiX7nnoXNpC+bBCBuw+hnI72NyxfXIalrcrDIDcZUW
         pGV7opN02cGaUT3v6wQ0Dxp8MJ82pdMjQkF76SYiOgRj9VqNBufaAXNiIkidfnoGLqYy
         Hjqg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1790667059; x=1791271859; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=9v/Z0GcKezXBRqzYvyQ4v0b98G06dRHjg36qbCp+fss=;
        b=bEz6fVnTttyL2gBz5ZoudIT1eHaMMJx80l0ZTmCNvha+RTrwZxHgvV3QMIQn8Cn8xv
         8bUrnAAi6r2V7RmxeFvFJVUF7VpyFhwU0LMs25betgMEwF5uUU6bdk0uNnrIqO8nFrev
         cCPrOjMAkVTgcX4veZuXyjiyZIdMlx/mDUCCt/3XKU2rhfkMEoZXtaOANWGfSkNhR9Cv
         eAZbKbH7uFEfLN4ldYH8J81qVTJTSqqH4AXb1q7WUHqFVg/ZG5BD8eOO7WpaebhzBNcf
         LY+0+0lShac65S9s/ZOZjxDsIou4uYvOPHBQ5aXfxRCozB9TRuowm7BOfav0d6yyoNGG
         GrpA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790667059; x=1791271859;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=9v/Z0GcKezXBRqzYvyQ4v0b98G06dRHjg36qbCp+fss=;
        b=veCrWm81iPrEmYmniDrz/jjKUzN93y9vfUBNVyTodDh5iEsk+UKitodlpgSlyqwGCb
         TeAKZ9hj7Fjo7LHsLWiK0ijmCrjv4zIoxAECrQEz26eut4pdddjZq1w1V8gkZcrW0QZ3
         dH1akt9yzoDG1drKFuyo50gQmUqov72idEU0R+PqQwzg/3Vstrw2Gow0gcb+Y8YZ0XRU
         7y16/vUGO3kQd9RF6B6drf+uD2/E724m6RhVwdGlkX5mYolf/dW5NtVg+bk9vI5fdpOR
         MNC/Rhq9xl/hJ3N0D7nq8wnt/MXde/YVjuDpeHKV3O3Ejj7eSdNi+Ktv9LUIWn9JynZS
         fN3w==
X-Forwarded-Encrypted: i=1; AKwUvBxw8d8uoZNw+O7q4Vn0yjxLgI9s9yPR6puEuwz3SB+CJTw4dKhhMKTDueXxShDKoz0o4qncTnjB53U=@vger.kernel.org
X-Gm-Message-State: AFuF++k9Pk1bTDY1FCgM7tHnrV8dNH4f3dB70FhtN1Y8qqlsmlEQqITF
	iMb5j98eKMDJu00fXBZZY51kfsbu626njXMNc9r6iUSWZpxBeTZ3CqXNOarjl8ACmcOibV4Y5ue
	C2Xoe2ScHB6wHHQCBgNpL1f3tWwdlfKgrShv+y08n
X-Gm-Gg: AYBFou3WMCk+ClCfClRH1oGlIKf3f17XGxZmbtmekN3PolXouNDfuawp5K8XCCjCpjD
	e1GehEeuwZTdfXm1M/P8crXXen+/1p5NbmtiPLpHfxz02ZOsqXIyyyFjtCyB1GACz5oyBziFfVY
	ezf/PKSuE8wFSgORBHuJ4R2e/VsUzd9Nv9dQZ9pkGA6adhaj2eWksVe6mQfq/3/eXhU3eIqmRRJ
	vEu82E/GixlZuRpFQaTlVxAYA4kwB7d4EMGrljvonzXtJyH85X+/g4ouLWdDpE7EAVtfbQBsE7u
	1BMnW5RIIzfZMq856/U/8sMzWVXnkofYW7yzrdf2ZitDtwMmm6D4TBeeVnmAl3pbMcUXbRu7PpL
	+ZK70NdrrLMOF1H1Yz7ewLwFCBT5T7Tesj4r334snbFADEf4weubzUSKlkWWUyoLLL9zM
X-Received: by 2002:a05:622a:580a:b0:532:d3c2:165c with SMTP id
 d75a77b69052e-5330dbe7682mr252226541cf.5.1790667058017; Tue, 29 Sep 2026
 00:30:58 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260929071743.23624-1-edumazet@kernel.org> <179066667444.31693.3326934466907750947@kernel.org>
In-Reply-To: <179066667444.31693.3326934466907750947@kernel.org>
From: Eric Dumazet <edumazet@google.com>
Date: Tue, 29 Sep 2026 09:30:46 +0200
X-Gm-Features: AclHuK9CAnCUx8smImHilXsTcocuUN-fbbX48CMDJnYU9QbhFatMhZFb2tpvc_0
Message-ID: <CANn89iLUKHZVrUOEtqDwuAghCRAkddigPwSWj4uS=fKyWdk86g@mail.gmail.com>
Subject: Re: [PATCH v3 net-next 0/9] tcp: avoid struct socket cache line miss
 in tcp_check_space()
To: netdev-bot+sinfo@kernel.org
Cc: Eric Dumazet <edumazet@kernel.org>, "David S . Miller" <davem@davemloft.net>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
	Neal Cardwell <ncardwell@google.com>, Kuniyuki Iwashima <kuniyu@google.com>, netdev@vger.kernel.org, 
	Alexander Aring <aahringo@redhat.com>, David Teigland <teigland@redhat.com>, gfs2@lists.linux.dev, 
	John Fastabend <john.fastabend@gmail.com>, Jakub Sitnicki <jakub@cloudflare.com>, 
	Sabrina Dubroca <sd@queasysnail.net>, Jiayuan Chen <jiayuan.chen@linux.dev>, 
	Matthieu Baerts <matttbe@kernel.org>, Mat Martineau <martineau@kernel.org>, 
	Geliang Tang <geliang@kernel.org>, mptcp@lists.linux.dev, 
	Wen Gu <guwen@linux.alibaba.com>, Dust Li <dust.li@linux.alibaba.com>, 
	"D. Wythe" <alibuda@linux.alibaba.com>, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org, 
	Allison Henderson <achender@kernel.org>, rds-devel@oss.oracle.com, 
	Philipp Reisner <philipp.reisner@linbit.com>, Lars Ellenberg <lars.ellenberg@linbit.com>, 
	=?UTF-8?Q?Christoph_B=C3=B6hmwalder?= <christoph.boehmwalder@linbit.com>, 
	Jens Axboe <axboe@kernel.dk>, drbd-dev@lists.linux.dev, Keith Busch <kbusch@kernel.org>, 
	Christoph Hellwig <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>, Chaitanya Kulkarni <kch@nvidia.com>, 
	linux-nvme@lists.infradead.org, Ilya Dryomov <idryomov@gmail.com>, 
	Alex Markuze <amarkuze@redhat.com>, Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 29, 2026 at 9:24=E2=80=AFAM <netdev-bot+sinfo@kernel.org> wrote=
:
>
> Hi!
>
> This is an automated message. This series looks like a fix, but its
> commit messages seem to be missing some information:
>
>  - Whether the issue was actually triggered, or is only theoretical
>    (e.g. found by code inspection). If it was triggered please include
>    the symptoms, like the stack trace or error messages.
>

Patch 1/9 fixes a bug found by code inspection.

Other patches are not bug fixes.

> Please do not repost the series just to address the above. Instead,
> reply to this email with the missing information, so that reviewers
> can take it into account. If the series needs another revision for
> other reasons, please include the information in the commit messages
> then.
>
> The evaluation is done by an LLM so it may be wrong, if you think
> that is the case please reply and explain.
