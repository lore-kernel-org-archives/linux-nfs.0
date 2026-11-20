Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.47
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795185362;
	b=KPgUfkFA6D3QOmM+Hqjyoy9Umv0yTDw+H5uO7vAljUcfjMb0oI0q3+BWzBwldAt/9m+A
	 o+kmB/sXxfnD54RjfkqSgpK3FXWzJNb68FE7SpMIsZ82k5BZ1JdGQwRqD0Q/7M/y4RqdE
	 S8UfjsN0wHkmkz/Kmr2H+IfhaIM3qfiApxTu6ig50tCsBfR4FwWmNuOHpBQuD5V15Czxd
	 uv1jE4o9Her3+L9Aaat/wcTjQ3fAmmzTv6UW6fEANG7N4qcr/Fn2mmfxw8SXdg+NlldDt
	 Zox3sZAN/nzyYSGuXawqNYi//uEubDAns9LiTzb5uhBSi4siC32te8DDqmHfVRrg9EQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795185362;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=5uzUR4nNL6/gBE9a0npJTMPxychcKuNTT6IfVRtsMA4=;
	b=SlJZZst7QD0JLMxBMoltXC4IbeGdOuTklJRtkjakhMUNYicTFZGfIDqcppQdUfMSOqV+
	 GwuqLF9RUFpm2aNBoH2vqhc0RbSvAE01L1awSmn4a9XHvGI+qN7DbBYBeKlXJr4NDwubV
	 ehGF6101X5/3yOY+CignNospGc7XBUf1m8pghyrGyakHXL8FJzSOy4NxFqhV4iNwRRHk/
	 EFBM9Ok+6Dh5Cg86Lnp/K9gxDqRKlgxZWSj9/ZPXVsWVY+yVXs3OTVHkIlUDPI2Gij/ie
	 UXqWGrJiSu2OHotd4FMmwfCiMgA1IxMLjpDCs01oijnPihCPRXmqGnA8dZkDSWOR6vg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=ZmlktTxO;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.47
Received: from mail-ed1-f47.google.com (mail-ed1-f47.google.com [209.85.208.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D82F606A320
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 14:36:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9D82F606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=ZmlktTxO
Received: by mail-ed1-f47.google.com with SMTP id 4fb4d7f45d1cf-6ae305e3bd9so1691249a12.0
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 06:36:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795185360; cv=none;
        d=google.com; s=arc-20260327;
        b=MAZLGUn7YyLNO19t2admOt6vkgzpNuQQtp/dEuR2mn78uO+Xp/5RH0QCnqamh0rXXF
         IJOC/4ggmBndOp29YF5wkkCei+vCueDMl6FQvjgGc8tsRpFVbpDkMT9MViekhFXBgJzc
         ztnyxm3HZwmSS7GvniVwD7QC4uA3ssQw+3/9vCjHyDjikCHyR7Y0y4v/Ax0GigAokqFc
         E7YouRzGkJlQeylU4c6vxOmmXJT14OkxPsc52fUWxGjtjS2a9QAABnlqgnIIK5gsdnfK
         oR6z+Nqfr4ydomCYAM6SiQCFMul92as7IqbfveoLOMFDiBOu9Y2hDBs7UnilSji5gggh
         n4IQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=5uzUR4nNL6/gBE9a0npJTMPxychcKuNTT6IfVRtsMA4=;
        fh=Fen8ud87R8EbrWOmpXV7IT5L8h94eLCprNDvvBaK9Jw=;
        b=DJFdPUd76uMqgbFO+wKak13wq07NVxLxRakn4U+YFomvbvIskT5MNMR/I7Kxyh06Bk
         IfhtIrg1PWUdCGgwCFxcz8VawF0p/VS4pyGWaQ4HpSJd5Zc842eEBcnVrpvyfP20ZQuY
         nFJ/EyzMPSSsbLqpb4bRz6uMG14w/V5wKzjK3qKxfhhMSWtjPlaZp1HfqxG4yvVZMJEK
         +L46UKMagecdCDoAwunO2CQ/uhM6HrRcEJaUF9JNtmNs5iA+sP4b+UCuIGEj5/wmW4CY
         nQsfG+8fpNoOzfnPjr5umU7p9x14sFpCfUF4laqsOZ3M5i4G9RJwxjZNTzcjTQ+AGWW9
         RxVQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795185360; x=1795790160; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=5uzUR4nNL6/gBE9a0npJTMPxychcKuNTT6IfVRtsMA4=;
        b=ZmlktTxOJqc0gUgZkQM8tVXb/Y0XP5vIjBlg31tczPuc6Q95f4xzDo/jLK66eDcTRR
         yQXNy421kiJhT7oH9vLVwxVroKGeg4J9z03nrEStYvsVMA3xboXgWcwA2+JIMTGITaZ1
         038E81NLDLzYcW4o0qQ4SonrTGr0vzYZ8MzGW8HkM5d16we7L+/rT4b4KMUSsfEHVibx
         uS8nmmaGxZ1wTgmldg9y07wcPtmMKFly5bIu+HgpUAR6RPvU1IG7Ma4/oDa4cuosYPJr
         k7UPz9VVFyx4nQjmDqMOy5HZQrVCpdYWfBCELvWA6ZL08iBITG0L9mhiTPT1o4IF12kK
         cWyQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795185360; x=1795790160;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=5uzUR4nNL6/gBE9a0npJTMPxychcKuNTT6IfVRtsMA4=;
        b=sMOYuqD4Z+ZpOuMY8eRLJ7hx5j9sl6Yl5cVSkUpWeVNoOIqwo5mDES9SyuXKhw9OFE
         F0OsWgSjCqLO+EnTA6ubrF80A0o1fBVgrvJ+EMfHHcZRxw6JmM6smKgWjXJObF99tt6G
         J3LtFyp0JTHDcAAN4c19oQU5I86b+Eavaw7oKqOV/FUxKC1zcbAsU4ew9PTccUcNRd17
         i+vna06LCD326Uq5mNyAdIMgFbUz9IJzuuQrEetwuVmcqqf/lrBbD0NzIXCpjTZqZ2lX
         qt3ZECRfgxZmrRks2i7Bq5vKlPpfMctW1JGkedi7YZ4ctiu527nCaOgzKTv+EWAnxxEs
         I7Wg==
X-Forwarded-Encrypted: i=1; AL+hErEj0K9LqPEa67q4bwgx082JzbYkTkERYs+m+Y2e+S6MrcX+H0eSG+gTHtzwTBTKfoNq9MMayz/QT3I=@vger.kernel.org
X-Gm-Message-State: APuU4Z8HmhW7btVsMKNX6rp6bj8bPq1RRoUzUzaF5DSrK/qfdXVkoyLV
	uf0sGlXwqRv5ZVCUFlOIJvBd3zFZ/xlpZn2AsakGtMOGsPhz/6fE3/oqPr5X+OPaA7GYgsPvyOZ
	B9nLnwJADGBUXmnOdSPBfZxdch0p2JNI=
X-Gm-Gg: AZFdTZftHpSe2VX8pqKtH0SC+B15dipiyJYAY0fqX2pEKyTiDpCSzHpeYC+r70jbYtF
	V8K2UPn4q/ekAMVGbjaHzvr52A/Oq9gBxSCNZIdY9WqRq2pz5TwzIRIb7D5hGR+S75nKd/Lgd6D
	Da7Ds/CElEPTQZAziv3g5nxc+UyZvKXyaOug+bXLY6/Gby1EoKSNl2/tLj+HWIhaH39KGZW5nsq
	/tjd4HooH7UPn0TOQa0tCQpLV8TYzn4JVLo8fBDxEvM7qVZ5NVrBt+2amFo2pMOLwaqAT4uaz/h
	7zokUGcMBMwDDX8LMsAoyGESbd8Ha6mDzLMOVngRimx2kgYohalEer1mgQ/oTUJynCFpGauFpOz
	AfOFTuMSr9ksRYvqStQlM1CHlRUE4IVkW6rzBrDPGmHlsLjOYOPB7j3DyDR1Em+EjKgSlqw==
X-Received: by 2002:a05:6402:448e:b0:6b8:7769:ffea with SMTP id
 4fb4d7f45d1cf-6ba37ece3efmr2475801a12.45.1795185359456; Fri, 20 Nov 2026
 06:35:59 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <av4Hn9u80fs8iHZ6@dread> <20261119095943.85048-1-lauri.gates@gmail.com>
 <DMZ4VQ7SZ07T.29WMPQ0BQZGSS@gmail.com> <CAOQ4uximow25oc=3XEN1ATgQvonQaTXtDPmQufxo75tJ=e355A@mail.gmail.com>
 <DMZJDGMJ1RVF.32ES391JKNFGP@gmail.com> <CAOQ4uxjVQ9cjV=_jBjQtNg9zCuWUEJT9KNYMKV+1jwBkHen5OA@mail.gmail.com>
 <DN03LWNSDYP5.11FTQ5KCWU2X7@gmail.com>
In-Reply-To: <DN03LWNSDYP5.11FTQ5KCWU2X7@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 20 Nov 2026 15:35:47 +0100
X-Gm-Features: Aa3M54oxXjJW5NIYEP5VP8q0nzSYgFKLfJAws7Wa7snJYDGBmmJmUUUXbQQ7PSo
Message-ID: <CAOQ4uxg0oq7VjhSQ0h8dBucdPfON2Q6tJQQqUy05sCaE10QRoQ@mail.gmail.com>
Subject: Re: Concurrent FIEMAP on reflinked files serialises on the AGF buffer lock
To: koraynilay <koray.fra@gmail.com>
Cc: Lauri Gates <lauri.gates@gmail.com>, Dave Chinner <dgc@kernel.org>, 
	Christian Brauner <brauner@kernel.org>, Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, 
	Carlos Maiolino <cem@kernel.org>, Christian Brauner <christian@brauner.io>, 
	"Darrick J. Wong" <djwong@kernel.org>, linux-api@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, 
	ocfs2-devel@lists.linux.dev, linux-nfs@vger.kernel.org, 
	linux-cifs@vger.kernel.org, Theodore Tso <tytso@mit.edu>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 20, 2026 at 3:12=E2=80=AFPM koraynilay <koray.fra@gmail.com> wr=
ote:
> > With non-zero xflags_mask, internal contact masks
> > can be used for -EINVAL not for silent ignoring.
>
> What do you mean by "internal contact masks"?
>

I mean that users do file_setattr() with a bunch of flags
some of them are just ignored randomly without any any way
for user to know about it, because this logic is some internal kernel const=
ant,
which cannot and should not be documented in the API.

Thanks,
Amir.
