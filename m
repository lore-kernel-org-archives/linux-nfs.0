Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793826421;
	b=wwOyBYxCu+68B8FDm67RZJu2r4H4axE0SIlMKHkfzsX7nDiTjly2p2sGRWLyAqt/UxpI
	 rXKgXG7DJKUbhQkmxF89wXo6gVxK0dqvOvFqRAFsWoD0QtVUMxc1DEBGEcP1O06HZAZ4y
	 l/x4mQ8jRxct8EWjDQPpFL053dD/kl7s6okkeiUJ8sb5OKVnfK5SOnRG4ftZCkM03N3no
	 F21cc4Vc1115xPGY4UW7HBhOagZwamBeiZlf3SM0WSCr9r1zlmD71XVs1CFXVor5nRPcv
	 jVYmpBByPjZA3r7oT+K2E1A/7BE8h3t6ESN3ho/EbcyS+rtR7K45MTm4m95PIN5jcXA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793826421;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=O8KeNsk7VgJFfi8zo53yBLg1pu0oo/p33FgXnzr6Qcg=;
	b=B5OsTy+aBYzPw8wkT3qUW6ZIQyVC2SBz//sPYJUMcBQ4wBqf7JxP/Ly6fHa33zCQYmdV
	 z6nJvsQQk4DE4B4CD/FWjJ0kmvVv2VT/S5Q7/Ond2B2gsKhFykGNuF+ND8UXzojzcRYtR
	 QB1PQ2XMTbaQRNQP77zFBNXjRrJoDjVm6MzNxMJApFZcpCoetRV15cyNt6rr7AEJKqkHS
	 erFFv2Tv+wRSDZk92SpFMuUXWJPpVCeW5zyUXej+OP13FKLNTuOoZCBNCauWytjkIAwS+
	 MxaoV34DI603ldSzkfle1PGkUSZjl9nh9RRguE4q0BougOOrwFVMInMP7EPnq2Z6GAQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cFS8GeKV;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 43535606E822
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2026 21:07:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cFS8GeKV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9209D1F00A02;
	Wed,  4 Nov 2026 21:07:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793826420;
	bh=O8KeNsk7VgJFfi8zo53yBLg1pu0oo/p33FgXnzr6Qcg=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=cFS8GeKVfd3yMT2AyA4aIyjt8ohaFdVtJlc6N7oczY/TndxLQPA32qd/FgSBsARUQ
	 WL7+v9444rQzyLWxHU/g6L1ag02hF0ootyMC+LdAV46bEZUgIGHT8JnjEBxbBW62Yh
	 shbsJVYbnTO2aRs0iGxJU6LMPR33yzaUL8NrvLt+vwmuV7ERcHtsFjdffiaN9OSJMk
	 qlZD6HzqUGnshFXI7AJwEufjwKiZrib2TUG/ejK4cnFifDgQZnCSj9Y3o0QB5wQP2F
	 nid66TO1A20YxHtpU4Me2ulccrP3MRVtNFtbXQVuxftrQ1gRoG2VlP/Hdr8PADm9LA
	 p6tPCteVL7PEQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id C95ECF40067;
	Wed,  4 Nov 2026 16:06:59 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 04 Nov 2026 16:06:59 -0500
X-ME-Sender: <xms:c57ranc-eXy0qZA3Izz6tzGBWD74Y0LDCTUyIwuwUORxaZhaar07Bw>
    <xme:c57raoBWAZGLVYZwz4km8y4F7mC9kKpSqIIooqwPleAyk31u3kn--LbngIcGsWq5D
    YlpuBfhzhBqdsihqjdWWi4q9RMVF5oZ95wt7lFh_2WLUTR78qApNURA>
X-ME-Proxy-Cause: dmFkZTESF0Phaa4oLLTTbol4xghPJHKqjaWtNLUZJD7XevwIpjhIgVnGkmbDO1LrYtt/ks
    swepjUhAi2j0+1TNzdeuOE1t+NwGYTbjtmvyuW8bk/Hv4KQbvI6l5w0OGqQRoRpwxrT19z
    CebSFfDOnxW02geUDHrhJSBgr8BJeD7e6Aav3DSgME//ElW3N9daqdBBB3khQxNJeC4t2r
    12L5b5jyPevQnijYTRXVT0EMKke+EayYoUzH1sGMz3QgUCeP2vSx0HVJ4L22jdBZc/CPbV
    PWgfCjGimZibfYjKbMXNbYOpl4Bt9qQjh8oUjnXlgVg4SqSBgZN/zqAjtJI7t5FO1AwMM9
    J+1v/lPEOsK7NWxXgtNJBea8HRuPt+HEzzp/3C90b4OIgYt1ag6tTZAsvYEEj4Zjvz+NLC
    9UxssI0qw5c5blB583tyN1ndQ2Dtb5i0WLjw8UppgZeOJzE4ziqzMNyyLZqgL3ZHpzXXz5
    5DiJh5qXhw0c8pSxOLORbJr78iIylaBNrYmXvLWQouQzHu6eYdO47yZCfvRdkjGaXtStLJ
    ec8WWfCjJwoUQdoHcYtjkrolPVSXFgm7DDkTCjsKKeq25qsVUY6lvSesb+z+ha7R7vLsbm
    ULgVgBkc/HgDL52wYOb0XSWf3IozRqpJQdVQw9EoJkR0OkRHpG2R4mdFAPnw
X-ME-Proxy: <xmx:c57rakMqRJ2mqk88Uba9wR420alWn9PD0avkuCDUE_60JBqCnVdCcA>
    <xmx:c57ratgQdnbEgws9PeHVIZDwlZ-mgSy4hpzrQ6fvWxhTYUuFOICcGQ>
    <xmx:c57rau4QpeHJJlciMpaV-EBOY-w7CS0Jbf65ZhRiedeeR-wJENAEFg>
    <xmx:c57ras2-cm1XI_RyXutdb4D_c91oeWxKRh2Yd4PSW11QAGU55oPl4Q>
    <xmx:c57rahubw90KPwURoffZ8jhYbr-NZ2cXfCCgz4NxEAbswHydxmGXj4B8>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id ADF21782738; Wed,  4 Nov 2026 16:06:59 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: ASp0-I3zjTPw
Date: Wed, 04 Nov 2026 16:06:39 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Adolph Zeng" <coderzeng@gmail.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Alexander Viro" <viro@zeniv.linux.org.uk>,
 linux-nfs@vger.kernel.org
Message-Id: <40574671-0299-4c86-ada2-ab1f16106494@app.fastmail.com>
In-Reply-To: <20261104203213.1214721-1-coderzeng@gmail.com>
References: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
 <20261104203213.1214721-1-coderzeng@gmail.com>
Subject: Re: [PATCH 0/5] NFSD: Apply export security when a compound crosses exports
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Nov 4, 2026, at 3:32 PM, VeroFess wrote:
> Chuck,
>
> I tested the five patches on an x86-64 KASAN guest. They applied in
> order, the changed NFSD objects built with W=1, and the full bzImage
> built with Btrfs, TLS, and NFSv4.2 inter-server COPY enabled.
> The wire tests covered NFSv4.0, 4.1, and 4.2 where applicable.
>
> After a reserved-port OPEN, high-port AUTH_SYS compounds that used
> LOOKUP before READ, COPY, or CLONE stopped at LOOKUP with WRONGSEC.
> The destination was unchanged. Direct PUTFH returned WRONGSEC, while
> low-port COPY and CLONE succeeded. SECINFO and SECINFO_NO_NAME still
> succeeded on the high port. READDIR with rdattr_error omitted the
> protected filehandle.
>
> After switching the source export to root_squash, LOOKUP; READ,
> RESTOREFH; READ, and saved-source COPY/CLONE returned ACCESS with the
> old OPEN stateid. The all_squash UID/GID cases and same-export
> COPY/CLONE passed with the expected data.
>
> With krb5 or krb5i on a krb5p export, OPEN by filehandle returned
> WRONGSEC at PUTFH; OPEN by name returned it at OPEN. krb5p worked from
> a high port and over TLS. NFSv3 LOOKUP returned PERM from a high port
> and succeeded from a reserved port. I saw no KASAN report or oops in
> the guest log.
>
> Tested-by: VeroFess <coderzeng@gmail.com>

Thank you! I've tagged all 5 with your Tested-by.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
