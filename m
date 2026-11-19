Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.180
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795082461;
	b=Kf8Wr20Dxx/0qEkH3W/OvxR76V5Hb5v+KRD1bTGhP14Jzn4jMkNgwhE4y0c1niwOMXy4
	 AviBUSmWSbdTV0UU5i98CX41psKv1TUJEQWb/HzlN9+vCQKWmaLwjIW8sGXMe6n8BgV/L
	 O9SWrBaAiuaq+bc/TGgXwY/Tk3jDCvCX3CzrpmdO25gUl24Ck0WCi8CUJtmy9QtGp24nv
	 asXKmnc2AP9X0qR0xYS0zHcqwwwnXb+fq0TgzGDJ3F6kboRentW1SkYTXdzJoXetsBn4U
	 I5s1au+VyoYOSbHTHPoDfwmqhppn6JlNLEjn6KWMKlx5YmM46KhGFhYLUsJyJ0NZFKQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795082461;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=bQXf7a2tchZd0sm6ejvBeIAXUJshrV4kEWj9Zx7JZ6o=;
	b=hOQXldtAXudYicoJGw6BhuKM/tU0CLhluT0rD7q2ESiA+dTLdKdV6uFH9wPrzv9NUUjC
	 4annKb5kDK79qA1Kl+ldDh3+SPWASqLtJW0aVDqvn7IhqapL9RhTbzVSLcX2rC+vY7Luj
	 0/z8O2pAe3ZsJbUQ1xgbrPZkrLt1IBVCyL2JOyVljiGypuLcOTihYMOCGHl6b2Ogb6Dvh
	 sHj2RfT6/jWa5VAtM/gw8DIJ5dEtA4hrPj6afRtusKcw+lWMRIbCJYhfap2Nf4V4sAM32
	 2TLx60u5GqA5ekMG+Nmicbaf/gdEQHmr13owJJB0SX8c7rLhwFirfXDJ0ROidy+8alw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=qQtx8HcI;
	arc=none smtp.remote-ip=209.85.208.180
Received: from mail-lj1-f180.google.com (mail-lj1-f180.google.com [209.85.208.180])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 36CA860A260B
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 10:01:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 36CA860A260B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=qQtx8HcI
Received: by mail-lj1-f180.google.com with SMTP id 38308e7fff4ca-3acc7a0b558so18867391fa.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 02:01:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795082459; x=1795687259; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=bQXf7a2tchZd0sm6ejvBeIAXUJshrV4kEWj9Zx7JZ6o=;
        b=qQtx8HcI9xOYAewqsC1qeKXYpNZYkorGxO+WUf8GNlozJTjTfjp6RYu0ME9dnQS7SU
         QlKY2a5rrUaalMRM2QkFx1q2fMNmh0+6Kx9oHBLriNElluMZgw2IJqtD+3DSP2pgxNzk
         2TmsS6xkE/qzDTWdZfTpZ+KAbD1lTDxAfFCzr6drsaxvmeBYV8fzzvm70Eui4lhqXTnh
         HgbHImFNfpvHwHXydOauwOfe17ING4Q6TVfyd4rcZEWzKr9mr4fzMJ+Vemn7/3JBMyOg
         1EBPQX8TZZCNUbaVOuHs0Ki+dm4jvN/9bSy06FQShgIIqQcy0wSxBtWSC2/KV4f07jNA
         MUdw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795082459; x=1795687259;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=bQXf7a2tchZd0sm6ejvBeIAXUJshrV4kEWj9Zx7JZ6o=;
        b=B0yWyOaWJf67bGND4NuEs21lCHS54v0rqPN0g46RzonsfOoHGjbeKz4cGH0+Qw83V5
         hsaQ3Kn5NDeyZ1PDxd7+UZGkSq9ZXs5FHbWPz1b1aDYgpLOsNXwMWQ0LyE6Ar+j2aNoN
         Oh1UOJZzFSQodi4y67uYTusL402Z/Clkmd66BJ4FrOBD1biTBf/OVaLmowYP/k+HmyIq
         oyGFq/5AeFnIs8hX9RU0YBHz8Xl5f+9UzBuyPFTqYkrKCJT/wvQlLH3AnCIKak+Z27hB
         xZeaFoxtSZslRsUfWtoI5Fho5eZlB3cT4A4AJ9li13fYlcI2Tuyc1XJOVVnmTWX4C3LR
         yvsw==
X-Forwarded-Encrypted: i=1; AL+hErExmVlDZP4+rlG4bPPLKUkxugtePpD7nIAX0vlVkIasHrekLfCKD9ebeKtEi8xjS940L0B790UhxmI=@vger.kernel.org
X-Gm-Message-State: APuU4Z+wYTcCKT5FXs40bEaKh4V28S2PT/FvM3r7AjwSoSeXeCDfpMsi
	9CHWZ9HOCyGWetDxJofnA//vbzSEsGT+B9ME2qFcTJTj5E+16eHfa8b3
X-Gm-Gg: AYBFou1rD/ZVMiu0Ca4jbq5TKXRwqgyk2wMnQNAOiL8KecM4IeGtfXjKx5MeYpLf/pO
	lvS6UzNsZD11HpRjtURMin0ncRfowOqSPH83Eql2dD7aEVe0lxabI4Ne1nG0r+qkk9c6CG690Av
	afKo0p3sqFZ4PPhm9KR2mMyOa418jT0Zvi+C+rKA054zhVC75xuEpGQbKqYRxQStgFjzvW9RlV5
	bM7LsHOJtnFQmk2HTTTTp5wR4dqbkcpiBsc48dI4avMRV15B8I+zJck0/iRyg0nKH+H3R4SEgAx
	X70EE1EMuqgg2uinpKfhxsO7FEcXdZSTNuWBGHcmMBQ4yYU/iUtBcfDNscSBU119aTuetnSggCy
	OChURsezEKBaqvoeZg6MeHhq63dvM9pdVjJAld5MnRi02T19dM28EOrYVscHrRYdjZ3OTe0BlPL
	og5RYVfomBwbyU7Tu52uBefVTLw7+hFVU7PVbh4onqNF2g6Ztm6Hu6aYWADdek1k2Wedq3YuEbr
	udCxacWvA71PaO7xSejYH8cT65o4gKY/lZvedln2yozhvOwaXgModz9yDPoVWzLn5ZX3OWv1wFy
	Y/covn4SbsO5RD/GXMEjcOmElflcTiJLJkuvec55ql5vEzS17rNsGvKB1WsmGNZc0CaBHjR0qCr
	Q2iPH95EhjWZN+oLO9a7UK47rA+4IvjXn+3y//x8yBRQOowu39uHn/ZVj2mo=
X-Received: by 2002:a05:651c:1987:b0:3ac:7ad6:2003 with SMTP id 38308e7fff4ca-3ae670dda79mr17356091fa.6.1795082459145;
        Thu, 19 Nov 2026 02:00:59 -0800 (PST)
Received: from Lauri-G-Pro-14-M4.intra.lakuz.com (n2vuxeervp7z67jbft6-1.v6.elisa-laajakaista.fi. [2001:99a:2ab:bb00:352b:8deb:4901:b3ca])
        by smtp.gmail.com with ESMTPSA id 38308e7fff4ca-3ae6ea7c798sm8419451fa.11.2026.11.19.02.00.56
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Thu, 19 Nov 2026 02:00:57 -0800 (PST)
From: Lauri Gates <lauri.gates@gmail.com>
To: Dave Chinner <dgc@kernel.org>
Cc: Christian Brauner <brauner@kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-xfs@vger.kernel.org,
	Carlos Maiolino <cem@kernel.org>,
	Christian Brauner <christian@brauner.io>,
	"Darrick J. Wong" <djwong@kernel.org>,
	linux-api@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	ocfs2-devel@lists.linux.dev,
	linux-nfs@vger.kernel.org,
	linux-cifs@vger.kernel.org
Subject: Re: Concurrent FIEMAP on reflinked files serialises on the AGF buffer lock
Date: Thu, 19 Nov 2026 11:59:43 +0200
Message-ID: <20261119095943.85048-1-lauri.gates@gmail.com>
X-Mailer: git-send-email 2.56.1
In-Reply-To: <av4Hn9u80fs8iHZ6@dread>
References: <av4Hn9u80fs8iHZ6@dread>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Wed, Nov 18, 2026 at 10:16PM +0200, Dave Chinner wrote:
> I really don't care if it is exposed by statx or file_attr; checking
> the flag through either interface will be orders of magnitude faster
> than using FIEMAP to iterate extents on every file to find shared
> extents. My concern with statx is coherency - it runs completely
> unlocked and so can race with operations that add/remove the reflink
> flag...

Thanks, Dave and Christian. Given Christian's preference and the
coherency point, I'll write the RFC against file_attr, once the
question at the end is settled. xfs_fileattr_get() already reads the
flags under XFS_ILOCK_SHARED, so the new flag gets that without extra
work. The answer can still go stale right after the call, as with any
stat result: a clone that lands after the read is missed, just as one
that lands after FIEMAP returns is missed today.

As I suggested on the 6th, the flag would take the inverted meaning,
so that an unset flag stays the safe answer: say FS_XFLAG_NOSHARED
("no extents shared with another file"), read-only, in
FS_XFLAG_RDONLY_MASK next to the case-folding flags. XFS would set it
when XFS_DIFLAG2_REFLINK is clear, and ocfs2 when
OCFS2_HAS_REFCOUNT_FL is clear. btrfs keeps no per-inode record and
would leave it unset, as would nfs and cifs, so their files read as
"may share" and a du tool falls back to FIEMAP there, as it does
today.

overlayfs needs care: ovl_fileattr_get() reads the upper inode, which
for a metacopy file has no data extents. The overlayfs patch would
take the flag from the lower data inode, and leave it unset ("may
share") while that inode is not yet known (the lazy lookup on
data-only lower layers).

Christian, one question on the shape within file_attr: would you take
the inverted flag, or would you rather keep a plain "may share" flag
and add a mask to struct file_attr that says which xflags the
filesystem reports?
