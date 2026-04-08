Received: from mail-pf1-f172.google.com (mail-pf1-f172.google.com [209.85.210.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7295134B1A5
	for <linux-nfs@vger.kernel.org>; Wed,  8 Apr 2026 16:14:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775664883; cv=none; b=FntxbnEZEbhAHs85Wf15uswBepJjDIOpqVyV3N0YMWOA8FCpP1RrvuQURXrfgnG6kW8mshVZV9le5XKIcBoqI9MYTIVJ4FM+vyWkM3YSZgAVk5XIU9IbzX4UTGVH9Srw10rhQe6ezsXziaLztm74y6Vpel3Op873yweDUj34ysc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775664883; c=relaxed/simple;
	bh=hrzd+GmO9+V9vslOEwr2nzakIqVoXWQdh/xFkl0AyMY=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=MCtgsi/cGeEHIugFnJMlPLcrGzMBNEY8DDKVt7q531sF8nVVi3Nu8JSjw6uYpZI5Qmhmvo/NRMFbDhENiv4GyH+2i0btbKK7Nv7sF2FyuDmWHYgvMzNog2/AgUzQJcBodKdO/UXq7wLTmgB9zV5epFh68zHAaaescVp9WVwJRd4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=nhHL9iZd; arc=none smtp.client-ip=209.85.210.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nhHL9iZd"
Received: by mail-pf1-f172.google.com with SMTP id d2e1a72fcca58-82cdb4ab547so3201835b3a.2
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2026 09:14:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1775664880; x=1776269680; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=lylBcWgPmUDMKSnya1KPBYbC3nXyUSQY85ueLb+HzH0=;
        b=nhHL9iZdYsxZf9cSnRVukw0EZcfQGd4+uNFtNbD62mxQrBZxfSo7vjDsYDKod7M65N
         9O8Jy7bxcZ4P/H52FP6erY4Sn6wZ1ph29Xp/S7oEm1pyy5RS2AH6h4GVSphhNjhBzmmO
         KqpU72W4dFnmuRm/dmuaFC//uBl2dgxVk98pD7yc34+aKlebBZJp65nq/FAWtONll1X2
         3vu99RAuK1sfAH02Sag5Z7g6UMK3ZOZLpY0tVjYEogQSFgAcHtvb/yF+/z5FtiUuEzz5
         LzcCV5C7Oa4kOER/WND1wCoroYKd+s0OsuW46IcvCbqoEQ6y5UOmh12fqkIo5gQZ/zDP
         /wTQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1775664880; x=1776269680;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=lylBcWgPmUDMKSnya1KPBYbC3nXyUSQY85ueLb+HzH0=;
        b=YuiyfpYVVijz939mqt65UtA37k3Jcy8w3PN0g6C0ro19l370cyUf1qMrKYdpyz4y8I
         gzkfiFzlLK3Q/kP9XGoi1Hejyg4kIa3Xadcz7WTUwSZWiWwnlMeBTqtZprCC1lVixAuF
         KGzstuf3hBK71gFSOeimCwjfBEUC878GJUqDKaGjV2PbcPw7Wl7o8Zx0uHuAJtTWOQRo
         6+E1ttLVjYCAhnZ8GBhRPwLXFovU1+olBw2StBM171MUU+kHppkIl5JYS6dSvfn5qGeG
         qYsXSzFRHsP7IdmewOz5tPKYSgC7S/jMEgebrMELCafDtTOhubBb5i7/oCyWgiMvv5hl
         +/Ig==
X-Gm-Message-State: AOJu0Yyi9IcFk+SwC+9MVc0LU+8liQjX9XBZt346seAgekWDe/IbEdPc
	/HP7Xaoqi+1NY53gE3cuk7H6xE7k7+4YskchG0Jn9MIf0huwDjvLuqAF
X-Gm-Gg: AeBDievpLIfF2JPLsM7RUnMSgpk0d2iPm+dsAvvjsruovljp8CubIHb9zgOerhK3DN1
	Fyw9SbYU7fZcBtrY85NdhOs89jL7NqZ6zTbjewlIoOLlPMgNH8RkfPOqbk/t+ztOuIJ5kRD4lPU
	GnD1IiPRXT6QNIEbdVCJfth397LohqMfImurMQ8qK5OW9XRVFJbh2HZCmtemj2UOWewOaOUZuTX
	7mEndSicT5yiLD6bAdLhyuVGtvg46R3G20fPCo5oKcrn9BgdHVNGdh+1Id8FC9gRURkloTaz4hD
	HXAdea1iQKAY63VltHWV4sDZAvCsMv7V2ls3o9mSO4B7Rsz34o/5ya882ijlqH8/lZiZIhgrMg4
	bnzzlxfAey9Sdf3BiHUVwfNGu39h/YXrcmkDgnlXoFJfUJ5zywPc+wIVmc3QQn7ZzSncHND2ijT
	p/pRj3Hwf+KPUWlq8lBJyoeONcNm0H4NLyvcAK3KJBrabi4QRUkEKkPLPOpBVC8+sJSOhxT3XWT
	w==
X-Received: by 2002:a05:6a00:9509:b0:82c:e1a0:3453 with SMTP id d2e1a72fcca58-82dd8a92047mr94386b3a.26.1775664879781;
        Wed, 08 Apr 2026 09:14:39 -0700 (PDT)
Received: from sean-All-Series.. (59-115-195-252.dynamic-ip.hinet.net. [59.115.195.252])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-82cf9ca4efesm21916840b3a.61.2026.04.08.09.14.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 08 Apr 2026 09:14:39 -0700 (PDT)
From: Sean Chang <seanwascoding@gmail.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sean Chang <seanwascoding@gmail.com>
Subject: [PATCH v1 0/2] NFS: fix RCU and tracing pointer safety
Date: Thu,  9 Apr 2026 00:14:26 +0800
Message-Id: <20260408161428.155169-1-seanwascoding@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This series addresses two Sparse static analysis warnings in the NFS 
client. 

The first patch fixes an RCU-unsafe dereference when comparing 
superblock addresses by adding the necessary RCU read lock and 
dereference wrappers.

The second patch resolves a "noderef" warning in the tracing 
infrastructure by changing a pointer field to an unsigned long, 
ensuring we aren't incorrectly marking private trace-buffer 
pointers as dereferenceable.

Sean Chang (2):
  NFS: fix RCU safety in nfs_compare_super_address
  NFS: use unsigned long for req field in nfs_page_class

 fs/nfs/nfstrace.h |  6 +++---
 fs/nfs/super.c    | 32 ++++++++++++++++++++++----------
 2 files changed, 25 insertions(+), 13 deletions(-)

-- 
2.34.1

