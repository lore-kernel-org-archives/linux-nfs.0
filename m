Received: from outbound.st.icloud.com (st-2005a-snip4-2.eps.apple.com [57.103.79.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 922D943FD21
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 09:15:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=57.103.79.5
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790241343; cv=none; b=Se+p/3bg1kqh7GwRXIHX5zxIv0QOlfGyZtRUTGdjQWVqbnyXprp90uohfMMhbLVaOEfrvR8t6cUI9sdGsO5+h2wyhKjCH12dW2vzCH3qEGO6iVWf3z/SSLKdtyeUPbEl4i8m429pDTzA/0tPbYSERrQJNdx1gqiVq21tkcYxR5Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790241343; c=relaxed/simple;
	bh=14ALabbbOP9GXqf6RTeOJdOBb4z5LNlRu7KNnki25+s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dBIWd5mEsv+kAlKb9Opsq5AnY1FzuzaNtX6b4VjHj0UTbic6RKxq6ALEsGaqAGLvTYuAAcVRZy6S1d1/mBWfiCyABjP8zS8jObiRQVvvOpZeOezEHQl13VGtnNAVP+bpwTBt1gbTc7KrWzDbI5WvNuhovbHSeZKtMkkZQhBjZ2Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=dabasinskas.net; spf=pass smtp.mailfrom=dabasinskas.net; dkim=pass (2048-bit key) header.d=dabasinskas.net header.i=@dabasinskas.net header.b=Zz1R20vg; arc=none smtp.client-ip=57.103.79.5
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=dabasinskas.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dabasinskas.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dabasinskas.net header.i=@dabasinskas.net header.b="Zz1R20vg"
Received: from outbound.st.icloud.com (unknown [127.0.0.2])
	by p00-icloudmta-asmtp-us-east-1a-60-percent-10 (Postfix) with ESMTPS id 573111800174;
	Thu, 24 Sep 2026 09:15:38 +0000 (UTC)
X-ICL-RepId: 01a0d2b2-f39b-7711-b008-0abf84a49746
X-ICL-Out-Info: HUtFAUMHWwJACUgATUQeDx5WFlZNRAJCTQtJBUMGWQpeCFYKTVIPDwRWFVIedw9TElgLWgNEAFMDFxZWGRcNVk1dGVEMRAJcA1IZQENZDkZQSxsOVRcDVxxWRVwYQwldBVccHR5DRVsTVRdGCRkIXR0ZCEcfCjADQg5WA0MHRQAtGRxXUFMKUBFKEV0eXApBXlcdR01aAlZNBUoDXwFbC0INSApcAlkBXg9BBlgBRgNdTRdeDEQrVhFbGUAEWRhZEUpWXQhDVRIEQAhWUFQeQQRWFWwJWAZTGVc=
Dkim-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dabasinskas.net; s=sig1; t=1790241340; x=1792833340; bh=YNha2tnc+p52KTqs7NXJ1fZ3/H/1Ts4hZ4nZuoBQktM=; h=From:To:Subject:Date:Message-ID:MIME-Version:x-icloud-hme; b=Zz1R20vgGsULtPogRAKtAPDEEMHxyUHISiSx9l7tINV5syFMll9yqrHhHkTeUBYiVgUEn1AhHAOdNlNwK8dE/qRMnwnmmiihP1hSs49tRvOfDATbLqU+oDcd8IiE8nrvFlZFA+Wd1rH9kKTAK6XlbAOoVWrzbdz10kqsqIgvE6CmwfG1pzNN6zd6u55hSfKtslMQJkHzRQlziFH3hQ3N4BeIi/TLEGfQd7/vUsYDC1fXBHCzScDG0sUPpvwsQ6hDhwJGWdI9NXAvwU3bCTFXBozml7yToMGmC4yo2SXoXuaU/kebiY0th5RoIyss1nlnAz7CEkZx64QrldGFONT9bg==
mail-alias-created-date: 1477328645000
Received: from localhost.localdomain (unknown [17.156.216.30])
	by p00-icloudmta-asmtp-us-east-1a-60-percent-10 (Postfix) with ESMTPSA id 2F8B91800169;
	Thu, 24 Sep 2026 09:15:36 +0000 (UTC)
From: Tomas Dabasinskas <tomas@dabasinskas.net>
To: rbergant@redhat.com
Cc: linux-nfs@vger.kernel.org,
	trondmy@kernel.org,
	anna@kernel.org,
	neil@brown.name,
	prabhakar.pujeri@dell.com,
	stable@vger.kernel.org,
	Tomas Dabasinskas <tomas@dabasinskas.net>
Subject: Re: [PATCH v2] NFS: return DENIED in decode_lock_denied if we cannot decode owner
Date: Thu, 24 Sep 2026 12:15:19 +0300
Message-ID: <20260924091523.69556-1-tomas@dabasinskas.net>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260917104905.669983-1-rbergant@redhat.com>
References: <20260917104905.669983-1-rbergant@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Authority-Info-Out: v=2.4 cv=NLPYOk6g c=1 sm=1 tr=0 ts=6ab4ea3a
 cx=c_apl:c_pps:t_out a=oyWFxbOnq+dmhQrAPgaJYA==:117
 a=oyWFxbOnq+dmhQrAPgaJYA==:17 a=VdqzKS8jKosA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=NEAV23lmAAAA:8 a=Yc9LJkcKBAbQym8JMEsA:9
X-Proofpoint-ORIG-GUID: o7J5vrKgdtpHic3sbXZ55IOgtSt17obH
X-Proofpoint-GUID: o7J5vrKgdtpHic3sbXZ55IOgtSt17obH
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwOTI0MDAzOCBTYWx0ZWRfX48Lr2SM0XQhp
 O3RLaMJW9XLyR8tt0teMfhkTOF7b/v0TsyhRWv24j3hqfnNKXOdXx+LmjKhg359+00MFQs1Xg4t
 zrcU10BtMedPPCcKvTcsYiJbyJ4xW3+7dcFqJpTOafCjftf6KwblH7cgkpLr8SpPs12Vc3N0mV6
 wXf2ToSbyy14GebTZpbFuK96JWlbjyi05otde4rK1orZoO0Bc2VPHnhvHeBTBYrnqcbsz2vSCZZ
 /+41AgQMO342qJQHpX2o7ih3Pu4cuNHVTUKylz+5PBpG1DLbBL9vx/y3Y9OKY5hQ0sS5CIa777q
 xkgi5U+clNbZvqLXn/+Dxxduth64NGl1+lLUbgGvoL0ml5/H/ndn9u2EwwuIaQ=
X-JNJ: AAAAAAABd4m8lSK6g3Q9zE6xL+BosVimPsXgk80c2AHYnu5QOzxg5j/uvpoX+tb7KxvhnO9hQAedWnYXKzo8ElykdJWhEaRbLU7quGQoL5fkiT4Bpnq0ftD0fUWtZJDg3eA0IheQk1tEobO8QMDrXbdisguPxBg22MzKC2e08+TlUeM7wKjhhHxukNLYJqDtShIOysbm3dg+NYScafqYe4W7DFjWdwgwryc6N1YC4/+k3Zeha6giWDjkr6TsPTz2dsLhni62jl7nbsMcuu+sU2H23XIMRH5p1DfO9PN+ur7WfEDUgdL18eZtabslOeYENuFHNsr0RluYBJJvr954uIMKj9l7KP2qzjGz+9zXXwozO4rjIfcJGEnp7bfSGzizdMfxFf4xep+Mh0LJugA4XjJQFGUbAbD05Fce9Aic/DdqVifk0t5T2zmvAErzmBhl/Kn7gzG41KnW4774Xwocee+DVbuMtb1vlJv6YfYuVe29R0MTvYsKpYnXzMEqK2XC5Kl30r+iASTyYqyT9FDDl77FGhcA6UEgfzD30PVn7sjr3lRO2H7+gUYW4Ms6A2nG+BByCgjinvhb45JONhZJGw44nAO0GB4NiywuMyrzQmZSZ2avoFKEUodhmltQYg6NRLUrsMrpl71u8c3U5NORH+g13FMJDZBhp+kNXJmCxrfY9RmQGmB1jyO4AL2KGBcRD7LRQg9afA4J/Aak36YHxU1qSoH4wXiDNMWx/0FFhrOTZ34S0YWJdry1UQufOzkUOT7r2eBUgjW+wp6kNFxmrjlA7n0K1QxXTJQLzMman0awcsZ+mXwX6IcCeA0GDtNPXOvKIrmyDiERTPMw1HApSx75Zg9MduLKzcTht0g9stOu9nQxYfvh+MBfYbc++PMKIUyHU0byaCGzrJd4EQ8iFHb0NZ0YUYdomXI3gO/qYkqP0IQ89fIFTh3UKy4dlb9ag0JhamnK+NS1B6nR+A5QCEhUdz4Dsgk
 jB3gpoPeBrs5ReQDol3SgEfNUzqPgj/sUHvHrGLEFEk9icpUjMOWvmhjzWgm/U65at6tlWFVjzBLeI7boY0zB/2nG1QbM2A0XiOWZWMHmAFk3j2oiZHL5sxg8cKVLJc30K2tlviQOXoC94iwBxSk0s6RxfoPLBbL/2bUBK6bTcubxbaV1sWMhv2YGbLpDkbAd/omy99t0dP/85dXFhNLW6iIOAFTFiFiuWVrR7jmD0ocFfxF6K6KO1IwREoA8FRaNwC49k6KldEHwQIUcaNEvvqZ2njOyX40FmNzobQdmgv/XbVhQmdL81fRQoyuilNnmmPIi1WGBJRzOlNaJvnQRJg==

On Wed, 2026-09-17, Roberto Bergantinos Corpas wrote:
> a buggy NFS server that sent oversized denied responses which led to
> us returning EIO instead of DENIED

We hit this in production last week and spent a while tracking it down
before finding your patch, so here is an independent data point, plus a
request to consider it for stable.

The server is Google Cloud Filestore (NFSv4.1, zonal tier), which is
nfs-ganesha based. When a blocking lock conflicts, it reports the
conflicting owner as the 21 byte placeholder "ganesha_unknown_owner".
With decode_lock_denied_maxsz now budgeting 52 bytes, which allows a 20
byte owner, decode_lock_denied() cannot decode it, and userspace gets
EIO from a plain F_SETLKW instead of waiting. I confirmed the same
behaviour against upstream nfs-ganesha 6.5 on a plain VM, so it is not
specific to Google's build.

Reproducer, two processes on one client, one file on an NFSv4.1 mount:

  import fcntl, time
  for i in range(20):
      f = open('/mnt/share/lockfile', 'a+b')
      fcntl.lockf(f, fcntl.LOCK_EX)   # EIO here instead of blocking
      time.sleep(0.05)
      fcntl.lockf(f, fcntl.LOCK_UN)
      f.close()

Run two of them at once. A single process never fails, since nothing
has to be reported as denied.

Results, same server and same mount options throughout
(vers=4.1,retrans=2,timeo=30), 8 processes x 40 iterations:

  6.1.0-53       320 locks OK, 0 EIO
  6.8.0-1069     320 locks OK, 0 EIO
  6.11.0-1013    320 locks OK, 0 EIO
  6.12.107       1 lock OK, 319 EIO
  7.0.0-1011     same failure

Tracepoint on the failing kernels:

  nfs4_set_lock: error=-5 (EIO) cmd=SETLKW:WRLCK

The capture shows the server replying NFS4ERR_DENIED with a 21 byte
owner, and no CB_NOTIFY_LOCK is ever requested, because the client
never reaches the wait path. The same client against a Linux knfsd
export shows no failures at all.

The practical impact is wider than one filer: every GKE node image on
6.12 or later hits this against Filestore, and anything taking file
locks on such a share stops working. For us it was OpenTofu's shared
provider cache, which takes one blocking lock per provider and treats
EIO as fatal. That is also why a stable backport would help, since
cloud node images follow the stable trees rather than mainline.

I reported the placeholder owner to nfs-ganesha as well, since
returning the real owner, or at least a shorter placeholder, would help
clients that are already deployed:

  https://github.com/nfs-ganesha/nfs-ganesha/issues/1420

Thanks for the fix.

Tomas
