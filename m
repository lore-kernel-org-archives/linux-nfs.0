Received: from mail-ot1-f41.google.com (mail-ot1-f41.google.com [209.85.210.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF18E3AD518
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 22:29:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791498546; cv=none; b=MRo/eSSljixSbh6pOyJFM518g9XNkgIqMj2IrA5MPymcHX0pxBIu25Wdj8V7+D7lwaBrqTX4Bs9m/tet4ZwiJYA68XDb88WPp8SrMY3sEBl3zPxJ9ln6wj5rFndvELRrTKi1RJFhgkrnzSNpxR1FY98/Yj2L7Sv1DdO54ztqcR8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791498546; c=relaxed/simple;
	bh=08iAQ1NU8toDQBLWXlTBGn/yQou5e+EnUIVLcAaUiQQ=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=DRUIwoCjEa54cmGR24YzonbvTC81diEdV75drKYtFZ9LeTqx0fZUhyX9+j1qJuHc7UMnyGQNK5oJfJN6kkUu4FxxpBnfuUF/I0vQsKUtGFQq6MVR2qyZYqrnwPi6LLVXkWtOhuz52WSFdqvrkZ/q2DSqKoi3++WNQtovXyWSLaU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=YVb8RkRA; arc=none smtp.client-ip=209.85.210.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="YVb8RkRA"
Received: by mail-ot1-f41.google.com with SMTP id 46e09a7af769-823e4047037so3406809a34.2
        for <linux-nfs@vger.kernel.org>; Thu, 08 Oct 2026 15:29:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1791498544; x=1792103344; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=QxSGMpvroH+VbKAG80pzIKfnlDbTN+IfxcUyNKtQ1bg=;
        b=YVb8RkRAW3/74Q0/+7dZLMnpQZMyiwu0KCDZDLmrC+nrb0PQ1pL9xZVnjdtAd6+PfN
         uQgpbl/Ml+hEFZkbVEai2nniLiTpASDvOm/J1e8koMbTdMppaWWoSfhZbenDRMrBrIIB
         kk162OxWpl8cb7Mpqf32/qOtLDD5nuCn8bU4iMqMUykBTmYAe3u8/Q5DQ8MmKl7Ceyix
         G1S5lNmcmVLTSrcOXBbCrVPQaBpY1LX8O82TTRgdFNtQQKCv+aXmIRnFnJ/nG5ioUBeq
         mWx0ZA+JxPMS/Ku4oCFcaN4z7NAanvn1BoG+hMLuOui47P4VltwYoPyn6mquGWNPuL9h
         E+CA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791498544; x=1792103344;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=QxSGMpvroH+VbKAG80pzIKfnlDbTN+IfxcUyNKtQ1bg=;
        b=0glf9cjzNlr6bxw7K/IXWpdDEMWhdNRKPD+3asa0SiP/tJXYZZyDX93QwgltqW6r03
         g+BxLff/4xVU5SaeNlvR6phDmiQhnT66TB2VDjqASYlltpCy5v9QzA0q9OFdV55VRqNT
         LKlhzmCFQxCHz+8xT/YmF8kqi9ebcMQumNBmCsy7OBb/pxUwaVB5NmqzSF/reSGlmwfj
         2wGpgZMuanNan8j3lswjFW01S2HmrByIWIpVDHWw4sjazk97PfSRqSt7vsArSdB96VDe
         5lM6CNMBKWn5IBBB/75fXboYWoggSJ+HTxAFyteJDBbzuzfuzS0g4361/ZhiFO9fHFcr
         JyWQ==
X-Gm-Message-State: AFuF++mBiTwBGzZt5mtDVXfzzgAQaNh5MkytsF96vFXsFLrhXGKO63sn
	sJfUB9SBRl+FR/wm5w/UPFBXX4Q9PSgJdiQwym+NJZ3IBO6ohiPb8NJeB57qcK0JHzsPAoDiSov
	M1nWJ2pI0acQqTr1ZTCp2wAe+cjRG9Kcd23g45olqToKN34ncAsTFb8jYZkmhWUFc8GRAXXoeth
	wIldxQZptRZCNbPrmXFZjF/XOtFk7n3zwSldSDnCQHxBzv+zWcJQ==
X-Gm-Gg: AYBFou2k+7QuEndwXcU2gNDdvgpmYXHvTA3ynG/FGUkGYyUAc7N6tkx+xSpVoXYRYxE
	/aAliY4UDW2DMRk6nZQp9xMTTLgGOcUZLMncVnZO9CoQK1IKFd/j61LJ+iB5WKFVp+FRbJx8FJz
	2JFBWkpqxdD5zC9fM6kSHjwubGmSijjeL0c7pH8s1/IYo35l0hvfHQ60s7tOv6MkkN2NpVuVcD2
	xsbQbAt389kR7vtg541vmyxItNrB+lMMNtOTw2MyeBKpLvJwdBwjVBo8Vu7xLmE9t9BE1jpzZmR
	W9OhMf8/tmr8VmWBPtxSAAZpr8sg9zcFWHAdpypJ5xhzLlxWTELPD9nLqW6zZ60CCaliBiEwkGi
	pEBPCNkmcQrS8Bg+590RYMqOy66k5TczEjwV2nEMnNgnQeZvb07Zm3GCkDg3aKMqw7+u2JSlvrF
	DvVlmN0WtpYcMCXxNvR/o4E1QsijsCFhv4QAAjdv0EldoGhYWUb5qeEW3Sd/sOtd6pvHJYFW1S/
	95NNvAYC6mbTnSf6U1FV6NfoA==
X-Received: by 2002:a05:6830:2b10:b0:822:27d6:c2ae with SMTP id 46e09a7af769-83023703e35mr463286a34.3.1791498543607;
        Thu, 08 Oct 2026 15:29:03 -0700 (PDT)
Received: from irdv-lubao.dev.purestorage.com ([208.88.158.129])
        by smtp.googlemail.com with ESMTPSA id 46e09a7af769-83038f82468sm278874a34.11.2026.10.08.15.29.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 08 Oct 2026 15:29:02 -0700 (PDT)
From: Lucheng Bao <lubao@everpuredata.com>
To: linux-nfs@vger.kernel.org,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	tmenninger@everpuredata.com,
	jcurley@everpuredata.com,
	Lucheng Bao <lubao@everpuredata.com>
Subject: [PATCH 0/2] NFSv4/pNFS: don't trust inode size from MDS while LAYOUTCOMMIT is outstanding
Date: Thu,  8 Oct 2026 22:28:41 +0000
Message-Id: <20261008222843.63319-1-lubao@everpuredata.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When a layout requires LAYOUTCOMMIT, the size reported by the MDS may stay
stale until the commit is processed. The client already keeps i_size
from shrinking while writes are outstanding. This series extends that
protection to an outstanding LAYOUTCOMMIT.

Patch 1 rejects smaller sizes while a LAYOUTCOMMIT is pending or in
flight.

Patch 2 defers a LAYOUTRETURN whose OLD_STATEID refresh fails because a
newer segment is busy. Today that return is treated as complete and the
pending LAYOUTCOMMIT is discarded.

Without this series, a stale OPEN or CLOSE reply can lower i_size, and
the next O_APPEND write then lands at the old offset.

Lucheng Bao (2):
  NFSv4/pNFS: prevent i_size regression while layoutcommit is outstanding
  NFSv4/pNFS: defer LAYOUTRETURN after an unsuccessful OLD_STATEID refresh

 fs/nfs/inode.c    | 8 ++++++--
 fs/nfs/nfs4proc.c | 3 ++-
 2 files changed, 8 insertions(+), 3 deletions(-)

-- 
2.34.1

