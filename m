Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793669566;
	b=YvUa0TeRvE0GnExyGb3Xt8byhUcryWNvM1c5RKqJ8iLwFltNKQzKHA4npA8X+CNz4KqT
	 wFY3ZVWdGk9f+yS1+cF6mFJSaE7UqKcq6YhI8THfgaQAzwRx2VUeMmNBoKFLbOFm5W3t1
	 6DfnC8PtwZaipiGRcA1QbO/6+yHWCS5Ah3Y5WcnSi8ThnsZzBhHwjQguIS8ccfmca/JkH
	 n1it3Jd3b3ds0lUfFPU/pmzh7YCaDHnHbN8jAQ4rUwy+kbTswGqqixbZqwFEXruwtPDMd
	 vVY+kG60ard7JTWUPY+xdqEOHDB57XV8VDZxrMHLWT1YDkqhCZGh1gVwLesz85yC32w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793669566;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=GFf3MD21PXZ/TYBwUre518FDQK3YR25kr23kQ8uiUWk=;
	b=Z2c6QEwyObAOuqNR20bIInePZ0RibB84Qo4mKfXnLVT0BYNEpX/CHW02RCFT/C6kFI/i
	 ykxK1hSsyCVw7x1CuNmoAUKXr9Zg9rTcRr7xSBOKV157z4AQsjqrj7c+0H8IiugdhL0oV
	 YQgvrn3SOc0793yVDSnE8jiRGAGS9mDOj6z/DUsrxBoCqcdCsigHY+1GCmF110JtsZ2DM
	 4fPlB6/fIxYl5bSHcVncRwoAcZs14SvmrJvG/syiX5BJ6ZbJ1N9wUbcXEeY6ufMyVizAl
	 Aqi/mqAa8h3bwlgAj/zVnL0F4HbXKBwMvyqT0oEIe0aBSSlLX82ABR0n8ftav97/fkw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=NmvpgwCp;
	arc=none smtp.remote-ip=209.85.208.44
Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D725606A324
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 01:32:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8D725606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=NmvpgwCp
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-6b203527bceso4891890a12.0
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 17:32:45 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793669564; x=1794274364; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=GFf3MD21PXZ/TYBwUre518FDQK3YR25kr23kQ8uiUWk=;
        b=NmvpgwCpcbpbjvC7YX+7WXNndm40m2Lu3mYNFXRcQPuRKUUTprbIlbQjDqqKyFf7Fc
         4EuIW9rtodSk1gjQBS6WdVHXZz8KOQtES28BhSAY9ldgaomU6fphvYKlQU0fmNgKpTV4
         1+4wIKbZ28F4vTYLzJq4gBifRVFt300MQIY1qNuuP1lKLYx0L+Y5w50irGQTuAwLpeRb
         sZu3IETlu1RR7QcvM9Zp/Y+DW5o0TEXkVLBwerGMY2ImG7Kaa2ymIj4CpUbl4YzZrg6d
         SGy1d03itjun2BvnLaH6I47is5Mr/il3e1IagIVBpVXtuqfQqoqDjNcvBbL5QGXtY6ZS
         aBrg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793669564; x=1794274364;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=GFf3MD21PXZ/TYBwUre518FDQK3YR25kr23kQ8uiUWk=;
        b=Aat8EAM8uq/aOt170mvUfuPfWgMGevhx16QlTbvijW39zkF7LBa/eFQ4J2r2e53q0R
         4FVEFt+6LEyHRRBE//g3q3jsMl/xhPJgC2izjW/xY5FABBS/CaL+yAEG/Cfo+No/85JZ
         oYGi4scmsUhLw2uzskukEAObbNIDsK/Efr+wFljLFFUhCkRjCZQVjZR1Pk3K5lCs/wE6
         I3ZDczh+QPbapfs5XKjwdBBgbA/Fjh3TTLLNk52zxPtcUxtecShpJzaHDGANWIgaSdt1
         RQyset3RmjV0CosiZqTCkCWNvkj2sVTYY6YAKgaiu3s+7S4zvmAXWyDv6L5vzAmk0PFI
         RjeA==
X-Gm-Message-State: APuU4Z+154mDECkdmGUYi4+7A3g27T+vDIO9UdSxVm9vVijWtfqnb8Ss
	iQ3tdsTtpiLpkxT+YcBDl0sNNdtX8g51oVdkzStbPnaWCeleO09Lj8xJuqrEpQtfofM=
X-Gm-Gg: AYBFou1bL0QVgXbYDXukvmXQDaJxqGI6shQ0mrhNRThGpv29u61q/Ugsa/8exVGUwOc
	SnWaEC45qTyHqb/lIzZb1s1PQ8ShIZlhnkqoFt45t5/IfEBobFd5PTS4mbY7ol4V1ot18hUFiet
	BunRaCqmFtUn/kQkycyrVRqr7ts8dzQ5DXWhmJRGc9cImNjtmt2ihh5RhciRC+YrTCmf9sK77cL
	UHvJ8hh+tGE2z2i1gWDDazDyH9AftwjPFGKiU21AzgUsYl+zNDPjZyxICGyeFlIzOpfGGm76Lcl
	eg7uHKYI+IkzJhQlKwd9vn70ILv4LX0y71LaOSADw1GLJdNbWrKv+7H2wxkDzI976v3vFES4W53
	eMN7Iq2B/9R8T6r5yzaZ/1hjh91+FE6gwy/ovBljvAzIFX77r1KQfbgH9bsDhheS+olSkcPd/Zo
	c/DCmWuWmpDG1o1Lf8waIp24MjugRenR+WHyWZ/LJ7uBUSNE4cWyGQccJh9scwFi+U+hYYVtcbj
	NQzSyn/sJWZWg3O6pPriqUQDor/mWsrqiAsVUSU2AJj2Sv9cDxcx2V4tjKjrMmt/S0PS5TwPGj2
	BKJpRsIXeb/Lc4QtKj3p+nXSt3NojA94FMKLe9gE+HY2DswOoFgA+OF1uyf7kQ9bCSTFQ2CT
X-Received: by 2002:a05:6402:a40d:b0:6b3:e575:f4ed with SMTP id 4fb4d7f45d1cf-6b4d4c76d2fmr5558341a12.21.1793669563841;
        Mon, 02 Nov 2026 17:32:43 -0800 (PST)
Received: from localhost.localdomain (173.242.112.181.16clouds.com. [173.242.112.181])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b4ec91e2f2sm3776583a12.0.2026.11.02.17.32.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 17:32:43 -0800 (PST)
From: VeroFess <coderzeng@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: cel@kernel.org,
	jlayton@kernel.org
Subject: [PATCH 0/3] NFSD: Apply all export checks when a compound changes exports
Date: Tue,  3 Nov 2026 09:32:34 +0800
Message-ID: <20261103013237.1174538-1-coderzeng@gmail.com>
X-Mailer: git-send-email 2.43.0
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

When a compound moves the current filehandle into another export,
NFSD does not always apply all of that export's checks. These patches
fix three such paths: LOOKUP entering an export, RESTOREFH, and COPY
and CLONE with a source and destination in different exports. They
apply to nfsd-testing at 08f97dfc517b.

In each case, the requester must already hold an OPEN stateid that
NFSD granted after a full export check.

Patch 1 checks the secure-port setting of an export entered by LOOKUP.
An AUTH_SYS request from an unreserved port can no longer enter a
secure export that PUTFH of the same filehandle would reject.

Patch 2 applies the entered export's credentials after LOOKUP crosses
into another export and after RESTOREFH, so root_squash and all_squash
follow the export that owns the current filehandle.

Patch 3 verifies the COPY and CLONE source and destination
filehandles, so each stateid is checked with the credentials of its
own export.

The combined tree was built for x86-64 with KASAN, kernel TLS and
NFSD_V4_2_INTER_SSC, and tested in a guest on NFSv4.0, v4.1 and v4.2.
The test results are below the --- line of each patch. The guest log
showed no KASAN report or oops. Each patch also applies and builds
with W=1 on its own.

VeroFess (3):
  NFSD: Check the secure-port policy when entering an export
  NFSD: Apply the entered export's credentials after LOOKUP and
    RESTOREFH
  NFSD: Verify COPY and CLONE source and destination filehandles

 fs/nfsd/export.c   |  8 ++++++--
 fs/nfsd/nfs4proc.c | 18 +++++++++++++++---
 fs/nfsd/nfsfh.c    | 26 ++++++++++++++++++++++----
 fs/nfsd/nfsfh.h    |  2 ++
 fs/nfsd/vfs.c      | 26 ++++++++++++++++++++------
 5 files changed, 65 insertions(+), 15 deletions(-)

base-commit: 08f97dfc517b50a00a41ce99f5af7b6ce2814592

-- 
2.43.0

