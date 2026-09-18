Received: from mail-oo2-f43.google.com (mail-oo2-f43.google.com [74.125.231.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 092AA42A165
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 17:21:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789752117; cv=none; b=r7P/Oa1xanedYgeg3I8A14lKoS06t3oYBr+si+b4VHV4w5vgXyt4+DItfHCB9GMe8mTz2S7136756ryYWIxXWS9o0/81UbJDf0Est7vzzJnhoeh/0LZmqkwz1mbLz8JqmGOCLRwHt111FzBvCfOFdjBGt07y0dXr6yUNUEeHl6Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789752117; c=relaxed/simple;
	bh=de5x0Zxo6F6d2MB0yVScP1sFcZZJFeuVMt4yQvyoVlA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=HO14Z0RACwbcG6NCNmxrVgHCoWYoQtkBDuoPk/WC4YzWeCicg0XGr+Yi5Y+8ziS1D7zh8HsLK0aKGukrxnZhDC+f3sp8iy184BXxl/462aOKueANnkwXCpHGiQSO/08RTsWJt0YhG/3nAkLj2zXbDyoluNTqB60p/9eHyYJ7GMc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=aLVCpAYL; arc=none smtp.client-ip=74.125.231.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="aLVCpAYL"
Received: by mail-oo2-f43.google.com with SMTP id 006d021491bc7-6b1ae6f5fc7so526039eaf.3
        for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 10:21:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789752099; x=1790356899; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=BBKlhw0dOEOei2lTcRYxlQw5MM/EKQhWFk5pNENBOIA=;
        b=aLVCpAYLsiWMtfVrSXcyzAKiRQIZD8WXF3wSqmprCpJtpl70Entfq7wa2yHy4+K6Uy
         tGrOa4LLvUp5X9YtZz8bhWCm6RF+LxSfIr6/+9FCWttMd10LbpJhMtuxIg1VvLmeRfcX
         WIz3tXF49p0uraQhpq5jfZhBhrOyAS13e7LmEmzTmq7OVDf79k90oQADr3CvVCWKUJQr
         pobHkxMoXRqWoGl3yEF7Huk+wTawViIXeRoFHryYGQdLpQgyQcraGu+oRg1wHVo30aB5
         vqy35MNNRxnLbRhTP+uZTRjmFly1sUTn1JbcyDYkqTH9E0wSRcJU3kTUcvRk9QqrKQqD
         iiOg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789752099; x=1790356899;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=BBKlhw0dOEOei2lTcRYxlQw5MM/EKQhWFk5pNENBOIA=;
        b=OzYu1a4/GCAGmJWvlxlVtjXW8Kwq9IB/W1pXxyC+dCqAex8vVC0lVuHh86RDeyuQ31
         XYRs/W3+jb/18a1ZYknpGOi8EfoSR8U0+lUDJDAwMymTYgiFmAjYGvwV0GekgI35aIff
         Ig/tgHRLrbRvZP+gb8+lA5FIK8j4932O77nxVVd/0MTf1ZkPHw2LjROmWbdeqYpKHdR7
         510W+7hZ4Qd+vjykm0iEWwfO4EqDV/GwAIQpTvlvhOZxKGCDXL9AKEY0jSDxiIJPuCtE
         nRsa0dqbSMWRkC0OCtLM7L6pDbSQ5VZXRtKI4UNjPn826jub4bLojbJAeBOLDOBKuO2w
         2pBQ==
X-Forwarded-Encrypted: i=1; AKwUvBx2IIiXkM9w7BLLNLMiuAnDQ+NcoyZbR5/YtpU86vUiZ/ElAUb2NFkJ7naUwwqhwUx6gl2p3YCgCaI=@vger.kernel.org
X-Gm-Message-State: AFuF++nMNoxAa0+boyiQsB0Y0OYOyP/lWdWCKmL5K+gZYkjgLYFa54Gd
	od3sXjsJd/ULbXvgBFSnSTHq28oTgHX3v0VzwkM2QyAihpkn0Hjnkueh8sqP/eQQU/Q=
X-Gm-Gg: AYBFou3TVRlf/3bUGn4lvxFaJ60j6DGVASxRFjlfLElj02CeCc+koaKaZ681imOAkK3
	pxlID1JCCXiAor+wXafZCUGRJv4jV+pSFaTeX+EdP/OgrSuDJIE4DCZEsfrhKyCDnTJxOXTvbRB
	lKRG4ZGbRbWNvPW6w3loO25tjK04EGmjFdfzdDvYseMfrvlKln/AnigKNdu+hJk9MTNF83uQ/29
	K2pOsBYk8Edon2hZPjlIUKkmbi/hcTqeao0JmFxBCSZdGre/2V7pSvNUOGlSLOB/6GyUNMcwD5I
	yFSgswyi+On3gR+PNL9tDQrWAa8l0ZScRJKO2cZEcLZVXh+ioUdWwrYLZSvBag2Ohcu09hAekFp
	BKHpLhh7oO7th6hM1Il2dF7wBr5Q/L6HRSmeUOlLQwfUh5LEFzZHJgvkuqP0hFRYXdRZXQNusyC
	Zn56VCFJTPo4eiHSVZVNW5rXqtONxKrvbn1fJSxwwJrGFs1v6lHsumLuc7zhm+tzdtlIc4C+pjO
	U62Hw9hwjzw6ZbJYLE=
X-Received: by 2002:a05:6820:a284:20b0:6cd:3fdb:fa6a with SMTP id 006d021491bc7-6cd3fdbfe8dmr158239eaf.85.1789752099254;
        Fri, 18 Sep 2026 10:21:39 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-48739852afasm1477855fac.7.2026.09.18.10.21.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 18 Sep 2026 10:21:37 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>,
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
 Simon Horman <horms@kernel.org>, Jonathan Corbet <corbet@lwn.net>,
 Shuah Khan <skhan@linuxfoundation.org>, Randy Dunlap <rdunlap@infradead.org>,
 Christian Brauner <brauner@kernel.org>, David Howells <dhowells@redhat.com>,
 Sagi Grimberg <sagi@grimberg.me>, linux-nfs@vger.kernel.org,
 keyrings@vger.kernel.org, kernel-tls-handshake@lists.linux.dev,
 netdev@vger.kernel.org, linux-doc@vger.kernel.org
Subject: Re: [PATCH RFC 0/5] NFS: isolate mTLS client credentials by network
 namespace
Date: Fri, 18 Sep 2026 13:21:34 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <2FBF57B6-FBB6-498F-A1F4-695D52EB89E9@hammerspace.com>
In-Reply-To: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
References: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 18 Sep 2026, at 10:05, Chuck Lever wrote:

> An xprtsec=mtls mount names its client certificate and private key
> by keyring serial, and tlshd reads those keys with its own
> credentials. Each key therefore has to grant user read permission,
> and any tlshd on the host that learns a serial can read it. Nothing
> separates one network namespace's credentials from another's.
>
> This series makes the network namespace the isolation domain. The
> RFC thread asked whether the user or mount namespace is the better
> binding. tlshd services the handshake socket of one network
> namespace, so that is the namespace it already lives in.
>
>   https://lore.kernel.org/linux-nfs/20260602154740.49861-1-cel@kernel.org/
>
> The keyring is held in struct nfs_net rather than found by name,
> because /proc/keys is not namespace scoped. Its serial travels with
> each handshake instead (patches 3-4), and tlshd's possession of that
> keyring is what lets a provisioned key grant no user read permission
> at all. Both ends of the link exist today, in tls_handshake_accept()
> and in tlshd. The handshake genetlink ABI and the cert_serial= and
> privkey_serial= mount options do not change.
>
> Still open is how userspace names the kernel-held keyring. Patch 5
> prototypes a request_key type handled in the kernel and tagged
> KEY_TYPE_NET_DOMAIN. A keyctl modeled on KEYCTL_GET_PERSISTENT, or a
> read-only attribute on the netns-tagged nfs_client sysfs kobject,
> would do the same job if the keyrings maintainers prefer one. Keys
> that userspace adds are quota-charged by user namespace while the
> keyring lives in nfs_net. Confirmation that this is sane when the
> two boundaries differ would be welcome.
>
> nfstlskey, the provisioning tool that consumes the key type, is
> merged in https://github.com/oracle/ktls-utils/ .
>
> Tested on one Fedora VM acting as both NFS client and NFSD, with
> tlshd from ktls-utils 1.4.0: NFSv4.2 mounts with xprtsec=tls, with
> xprtsec=mtls using the identity in tlshd.conf, and with xprtsec=mtls
> using serials that nfstlskey provisioned.

I think this is the old upcall/namespace problem that's never been generally
solved (as far as I know).  Here's a shameless plug to potentially revive
the original "key agent" concept which solves this in a general way.

The idea is - user space processes (tlshd) register themselves as key-agents
that can satisfy request-key.  A key agent represents itself as a key-type,
and the appropriate key agent is consulted for request-key if the calling
process has that agent's key in its keyrings.

Otherwise, this solution looks good - but without a general solution to this
problem, other folks building on keyrings will keep trying to solve this
problem.

Ben

