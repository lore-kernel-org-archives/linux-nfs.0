Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793824344;
	b=gMZ25zyFoiHHrNdv/bykLZOJCZhtFz/TX5dIRGj3QyQpNTXRoJrbCJiIeeLYUrLyamKM
	 wH48ebK2Iwsb1hUXKQt6mei8N/rnmA8+tooyXfVXLlhr51/2P+QeYzKSm+iHgRTcw/8l1
	 oXWW6aKMFRIS9D12b+VlGq6f8l2gzTfPEttXRmbJHf2jtRWQ+WKGqc7SsDFZABK+XY7CZ
	 3CaAf0VV/K27+Uy0qLlpA/Plt9BafCnnUl9e291CzoAKpFo04ncfX+ePfBhrgo8UM/O6C
	 eXEDLVc+hY4t/ZiovXuqiv6OTi0B+IR5taN+KG9WPlGQNMm9IjYtfaGPxex+i1K/dgg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793824344;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=vvPyObhECIqaYZATRXYy2VG26m0W8SXVp5G/EDqIdGI=;
	b=VJNDL4FGhIrSo/e28pG0vyAiwBgx/GH4tutViC7tD8QPouIbCdC1c6Bz2WRvSqxj52P0
	 BdmkPgJnl2RaVUoxHpQnK3pk3wIyoQfzhggwhN5Gx18E4TX07b1bh20uXvM9kJDqk7S+h
	 Br5+d1U8WRWmLEsZDIdlqZxdCN64jRLdHVETICW7ZbSYE/O8GiCcINr5teFPZNjzUAayT
	 QfGLFpLjFjkzTaxu7TwRDC7xkYLAYt8dQPCVvJDaAb39WhzwjwKIZ/DmO6L6Lfddi71B2
	 f2lTo0Gv5WP4lzw1w5KxoxBN4VoL9E04pz5szBMSegvbUGH4zz55j82mj530V4snskA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=msuN577Z;
	arc=none smtp.remote-ip=209.85.218.49
Received: from mail-ej1-f49.google.com (mail-ej1-f49.google.com [209.85.218.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E9B90608C992
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2026 20:32:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E9B90608C992
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=msuN577Z
Received: by mail-ej1-f49.google.com with SMTP id a640c23a62f3a-c34bff61551so203253066b.2
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2026 12:32:23 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793824342; x=1794429142; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=vvPyObhECIqaYZATRXYy2VG26m0W8SXVp5G/EDqIdGI=;
        b=msuN577Z90oNJPBzoXuD6/KKlHQB4PyXt32gCOsdNn3tSaluqhLVTSpy2yFISRWbfV
         lciDOpS9NrHGtpcOKrVyeNKKqDe6IUoMdH8JxrNyzMP4N7tnyxa/N3deJ2tcXNQGaOTW
         dF4PdOL6DITiP44JAfkRI2hhe5itSr29Se0H8xC9aeBmAgJS2f+hOw8J/nxcKQBNF2Cj
         9kXnPFHehojrnrPb/eHu6EdKkFLudQgRqS1TWfWVHxJrdMW9ZoVcx/SLVDLfrn058b+0
         Dd24++JZcDnbalb0/ZAjNz6nyD7PsN8exi92dgcipNptVqG7d1X13ucozJA0t5ev6syk
         xJIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793824342; x=1794429142;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=vvPyObhECIqaYZATRXYy2VG26m0W8SXVp5G/EDqIdGI=;
        b=gCUwKOGsDHxibAWlPT7dpHZQ/pTBcy1f4cOijDsLDKK7b6KVz/UH6ieWsThpPzyW1U
         nvbMcP9q9/05VVA6oJtVaNoPxr1V6PXySvYukEezOr+/9OfsYhhA5fGQcSlDNmFH1Ls0
         5DFKT1cJ1U6/IES5b/gQ2pxPLceVYeKCoLbeNYmMHeLQSOXX1qy5ZvxnjP+IgFh3n8Gj
         A5yyIDlhrDAFjcAyEirxMRAvcaPYGzfUmlecKnJAcTu/uMp9Lsb4YB4pQWdwuRI8OcVA
         V6L8A9LJG+XC6+quhraBZ/UtxSTO93wyMhluu2sZKKom5UxwvCn1AEwnGyJRkhUNU0R0
         PsKg==
X-Forwarded-Encrypted: i=1; AKwUvBw6Fz3Eglk4VWXmyY/dECDgLrg2iyL21Yn0yOboIL4Lmf8IqatfpwGGtpM37kIPGAJMrCYzE6fR6Ag=@vger.kernel.org
X-Gm-Message-State: APuU4Z/bGqoY6Me/drKrNmEtF42HjPIOi8FzMlqRB5pwU6HDj4SsGbWb
	DghFFQ2cRJv5DI+5JQiYe7FiI8Ov2CukoCUs299rXdNYBAK134Nny4c/IXYv/J6Q3Vc=
X-Gm-Gg: AYBFou1Z6cCYU/GPa0JWTEVZbU9pmP44hjNRn3LD54DRpZvKxlT/17Q39KP+c169S/i
	/j/b4jx+BTjBk3Dt0PdOxhuaw7FZb/qyDWwXXJhbY+iJCuRk89Cp5eRfB03FZQi+kqENSC/7e/w
	pv/EuwbLGuFAkGwLAJNcassinyaq5V6hhyhsciBtBPxgBLmf1odJR0oYvKifcQXIHRKJ3UVtTGB
	w3ii9Vt7auyn4JXsRXny9p6EGoSizDwf0AfAtt38GyFCYpFpLvKHI0SjrN3xyVDOLttCpWFT325
	92ic1sgjm1NvAmpy9Jf3H0AUWYRHudkrA+BnnGQhK3haGTT9xicnTPaHcrK5IpQe9nTL59wdXfq
	YLkSO+s9UZ47hSi0UU0nJuoMzfO1e/VWc9+rYjniuNicrCkiUoJoD1D9qYz0KmOxw5Pi497Ga9M
	T8+3ErDDBrjGCbfg0ILVvawCgfk6p5O4gOMawbhbSyBA3Zle+3oGj+vi4IuEE3rqwmXvCKYBt10
	gjeo1wFTnfo8XeeZtMJzdpSZi6MH0eyeqmvWZUiiNuosWCjaeZMuZZpw3bkooCf1gL4ONG+5Oci
	F4jjSZvM57qCeuInq+fj4HQe3iPgmeGEzL0pu+Rsk41ApTxqTUTYrLHOUNKOUuDdMJqwMHf3
X-Received: by 2002:a17:907:ea8:b0:c49:a408:f682 with SMTP id a640c23a62f3a-c4ca7ad1a46mr1465857566b.42.1793824342155;
        Wed, 04 Nov 2026 12:32:22 -0800 (PST)
Received: from localhost.localdomain (173.242.112.181.16clouds.com. [173.242.112.181])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b55ac44f0csm1187131a12.7.2026.11.04.12.32.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Nov 2026 12:32:21 -0800 (PST)
From: VeroFess <coderzeng@gmail.com>
To: cel@kernel.org
Cc: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] NFSD: Apply export security when a compound crosses exports
Date: Thu,  5 Nov 2026 04:32:13 +0800
Message-ID: <20261104203213.1214721-1-coderzeng@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
References: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
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

Chuck,

I tested the five patches on an x86-64 KASAN guest. They applied in
order, the changed NFSD objects built with W=1, and the full bzImage
built with Btrfs, TLS, and NFSv4.2 inter-server COPY enabled.
The wire tests covered NFSv4.0, 4.1, and 4.2 where applicable.

After a reserved-port OPEN, high-port AUTH_SYS compounds that used
LOOKUP before READ, COPY, or CLONE stopped at LOOKUP with WRONGSEC.
The destination was unchanged. Direct PUTFH returned WRONGSEC, while
low-port COPY and CLONE succeeded. SECINFO and SECINFO_NO_NAME still
succeeded on the high port. READDIR with rdattr_error omitted the
protected filehandle.

After switching the source export to root_squash, LOOKUP; READ,
RESTOREFH; READ, and saved-source COPY/CLONE returned ACCESS with the
old OPEN stateid. The all_squash UID/GID cases and same-export
COPY/CLONE passed with the expected data.

With krb5 or krb5i on a krb5p export, OPEN by filehandle returned
WRONGSEC at PUTFH; OPEN by name returned it at OPEN. krb5p worked from
a high port and over TLS. NFSv3 LOOKUP returned PERM from a high port
and succeeded from a reserved port. I saw no KASAN report or oops in
the guest log.

Tested-by: VeroFess <coderzeng@gmail.com>

VeroFess
