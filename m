Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 80E1A40DB55;
	Wed, 23 Sep 2026 16:14:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790180089; cv=none; b=trveiirqTdJm4/YvUdwNKOM7hjPdUO7YK18LACe0pAjfTO8s5Du350SwcoCJdomdG4vz3igoyLtO2x++FtNHit4H1VUFB6lIyTYxLSgczoP4LJitow/I3NwFpMdqu8pdafDdxEGrwIatQG2JjDPmNZnwDco5/yOpqgLD6x4sF0E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790180089; c=relaxed/simple;
	bh=cndWfwoSO2dumUg57vmJGRg0X7umYnrcK1+KIP5oPG4=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=Gau6sDMmuCxYlRzLWMgMHccu3w/dS9kQzQ6TQ3w6qx4LwssZYpGhoqjjmo4cOErNw1oL8/Q8SUd33kE7PEEiYfqDhmk4T3A1mL/WwRqNsmNm0207zKHfbZA5jaWfMgcM0YvHyfEA6fP7rk12VIFMAHkiyQFUnv2B3gh8JYlL55Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Wib39Kyn; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Wib39Kyn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6C6A21F000FF;
	Wed, 23 Sep 2026 16:14:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790180088;
	bh=FctwbAHOLbymAJriGAB3HO5W1e7gR/iPiJxGhefcPtw=;
	h=From:Subject:Date:To:Cc;
	b=Wib39Kyn+muj7j8P/jEReyzSmYt+XluY5PaRdCSL9IeJQeKNf2FIojLQsk7TSI/9c
	 +/MyyQMitM7FyqBG0kTX2u3APPqfgBVP9BkXX0/I5Kd10GYYyuHtPpHUf/DdX+RLXL
	 LbhuKwc2akG1xexGfqO+h3xR9tJwSqunwFRVVzSJFIvLXd13Jc+7/KEpTwvu4YqrJU
	 tkBXEDoYxzG41nf8sXr7jiOZEV2dbgxpu7FmIxkajYgollTpozTuL4/QRnnp0Mo1lw
	 V/GfB3+RBk/jjNEhXqFJ6YrVdS9efJWQhDrXFJTCsiZFieK5g1SUJJtiv5BJt10ypZ
	 h8vgBDRGC4XHw==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 0/2] nfsd: remove legacy tracking methods
Date: Wed, 23 Sep 2026 12:14:20 -0400
Message-Id: <20260923-nfsd-legacy-v1-0-8490c0c12ea5@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDSyNj3by04hTdnNT0xORKXRMzi6RUk9RUc3NzYyWgjoKi1LTMCrBp0bG
 1tQCRPcpQXQAAAA==
X-Change-ID: 20260923-nfsd-legacy-468be4ee7773
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1499; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=cndWfwoSO2dumUg57vmJGRg0X7umYnrcK1+KIP5oPG4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqs/rxkmsDZJGkWNG8KbXihyNrKYk3ryBY0AXmL
 11dfZSafFOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarP68QAKCRAADmhBGVaC
 FWZwD/9ugojX1b8ojwN7Zn3+4p3AbSh0sIPKXYD7sK+G07/ZMQCFUWs75rEJz7DxEeuBkb3P6l+
 dzNgvGTtmNKm6zfUfi7AFIg/iF6IuwxLtBG5axuLqeZv4W4uw8EVlk6dQx19LAicGE6lO8LxTGI
 6no1JWegJtwGiNbKf+q9wIosIaal05oiTreNwNpz1RwTO1Fo/4d4m1O22qLgHxv2TEDgiekuUqk
 nsUlMejtuTcAUhNeQgMK6nBLjjhW7EbPjtauI8P4hYi/ZjTq9QIpmDNEiTdf5oXcYp/vycP8cuA
 fHE6cIHZ3f/vuvvy7qTM9+DQfXBRDECp/NQdfrEsyYWmRFdEduiIH9MoneXx5ookobt8lFSu1tg
 fb+/Dqu0xLYsU/ZTMeYR+QE6AFZ7iidUAOmg7t67/bu98Eh7QUlz/4kIQP+HgoFEqpUbn3Jw8l2
 yA1NONDZYOYHwVZ9EKRfmNGMG7l86v2Bmh9+XCx6OBbTYjmYBjsWR0O16m2SpKbE3+IbJVRLnvE
 wuGjrM6ImUXwr0uxz96DwRlwnrY+Jv3rk3fT+M76e0OvDkALFsk3d3jppKCKf7sj5TkfdD3QFAi
 Xpb/DGZRmZdC6R21S5zWoxy1Oy0OMNXg+qC23+3bMgy5xg68r4WSyaZeQZ1L/4gH+FPxhBgm/qR
 kfaR672g8ZQyfQg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Around three years ago, we added CONFIG_NFSD_LEGACY_CLIENT_TRACKING with
the intent to eventually remove the code that it compiles in when
enabled. A little over a year ago, we switched the default for it to
"n".

All of the major distros now disable this option, so finish the job by
finally removing the config option altogether. With this, nfsdcld
becomes the sole way to do v4 recovery tracking.

This also finally gets rid of the dependency on MD5 hashing that the
legacy recdir method used, which will mean that FIPS auditors will stop
dinging us too.

I think we should shoot for putting this in v7.5. Anyone have
objections?

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (2):
      nfsd: remove the nfsdcltrack usermodehelper tracking backend
      nfsd: remove CONFIG_NFSD_LEGACY_CLIENT_TRACKING

 arch/s390/configs/debug_defconfig |   1 -
 arch/s390/configs/defconfig       |   1 -
 fs/nfsd/Kconfig                   |  17 -
 fs/nfsd/netns.h                   |   1 -
 fs/nfsd/nfs4ctl.h                 |   8 +-
 fs/nfsd/nfs4recover.c             | 998 +-------------------------------------
 fs/nfsd/nfsctl.c                  |  79 ---
 fs/nfsd/state.h                   |   4 -
 fs/nfsd/trace.h                   |  19 -
 9 files changed, 3 insertions(+), 1125 deletions(-)
---
base-commit: cab95e6be3ba82bcf4c8be27c2eb20e55238aa41
change-id: 20260923-nfsd-legacy-468be4ee7773

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

