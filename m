Received: from mail-ua1-f49.google.com (mail-ua1-f49.google.com [209.85.222.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6FA55332601
	for <linux-nfs@vger.kernel.org>; Fri, 19 Jun 2026 14:20:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781878849; cv=none; b=gFLRm5MECkp24YNTKaJZT0mRR0Nz80viO9RMiqXWW3mcG3Sh0C5TYTkjC4xL4Qb20jusfgnSODnfy5EWUdMqSAS3a77LnkOUrC5i4yO0Azhj5X9QfIkesS2j15qV5yNsDB8yYNECoWbKw/2TSnKs8KbV7xEZsE4qQ+NMAI0Pnvc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781878849; c=relaxed/simple;
	bh=2FQMD8bu684nEsU/UXL7vfxW6vXPsGHz9C/bJbOPhZo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=VMkGlaqb6/zwfAYyZk4cBPbfasWQMcwjdyQ3+rqNbC7H1nj4V1Xm9vASM22UJQB8fVIhpqkOKtdjyVWJQScx6kbxGMiZI9jeDTUpqL/qTRxmY064CFkoIuiU9xdBkvy0b0Cis3rIgQWdylAPF1dUYACFATV2pfEhZKbmo/3Owcc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=s033ai/8; arc=none smtp.client-ip=209.85.222.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="s033ai/8"
Received: by mail-ua1-f49.google.com with SMTP id a1e0cc1a2514c-966eabad303so440471241.1
        for <linux-nfs@vger.kernel.org>; Fri, 19 Jun 2026 07:20:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1781878847; x=1782483647; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=oTK64FZoF89IvutywaKW9AaCpbwlqYnBXZ0qeFcwR1o=;
        b=s033ai/8du0j6leIbHuLlxOJYI5xeNG9hgYq8qaqXALedHj9kq+2u84lFNV81s2FLb
         JGk4wDATGcvd2XJ8469i5AwpgkVWmTBplg8AeidwO9d6huH7E90+kVmMOTawpBItmApb
         ubiAMSET6AadVvA8COufajVZcqVJoVp4EdSpwHIWp0hkyE5ak//9sA7XrVD6STFMOmh3
         IRFXIdecBegaManci/OK/RDYHlQc4WKZDYo77oO9gQ9mJA8QUJnvVBR/GdEFA04p83ht
         qQtkkyFkvJU6oXHei2lkHzj+l+9Rfk5Bek6cheHLBxLpvzV4DxBe1ipn9184lDYAH1+M
         8VtA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1781878847; x=1782483647;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=oTK64FZoF89IvutywaKW9AaCpbwlqYnBXZ0qeFcwR1o=;
        b=BHNxQhzGcJ8b7W4UF4kAG9hOnvdETAmpqL/qJpRxzq/7PJ7ivJSIGzzLwrTuwexKlk
         nnlfZbZmbzadSxqYQnulPQfqbMbS/41mUBVVRbXjlNj6fbpmNSwOpCZCJ88uSDy8cwba
         AGnF0UxRQcPFxUTHNSkvCuz7BJEl7CQJ8a5wh637eOMmoZ5FPIrqD39CW6B8EZw1pNwm
         Gv/oElX7BKa//Xw6RjtPMkdRvVUaoM+jyCJzzYEN0qfEEwuR3o96LKCi7rSJQU8xyQdb
         pmfm1ip8HX61bYYO/R9h5yiYPqvpk1EdnK8qD5qimPF9pREbbes0ZaxyZkahcR0N5V+p
         BlbQ==
X-Gm-Message-State: AOJu0YxzMWAysO8eSB1MzwrgCmNzxRVSERcT6Q+xHynOyW/TkbBGtAPn
	pKn/4vbTZ5STVG6ETq1rBe9+qqkmjBLTbKrduxxPB+MNHlzEPm+ZZbBh8EKPfSSMJg3D/g==
X-Gm-Gg: AfdE7ckIHa6T3t9Ofj0YnHwNH92RxWztBdKEm/YVXSk7TKQUIwn1NeDyKF2ntm1IoK3
	FtAR8IcW0zo4/KnR2knRFGE1+Xc4mMKmSYVF+XdBE9FPf/hp24LPOzS7nITkFrof393cE+AmYEZ
	6p5E0CXldkp4ZoDsiJlgx4QqI59BJB8TZ4ZvGrFUnh3u9zwP24vg816d/C1Gzdbxy/reZQLMcYc
	Nv65d8MrUrgYJacuRdk569kqn0aAOuWpuGS5h+G+uHPUobdVzg0t7cbC8Q5+PvKDvliIIBwRhLK
	vXmXH9O8rKmD+OgNjTXZcTCz+bLhNwGhygE4KkqBmYrPE/pomAJxpCmMHct5fEqf3l6+C6Gbrie
	RipEJ8mHdpi9n6DqI7Ifn44tIDaR1tlhMhisnpUvV8XjIfGFzJultAPzaV6+YIRONQy2eSbuI3O
	TSG6w=
X-Received: by 2002:a05:6102:5491:b0:720:81d5:92dd with SMTP id ada2fe7eead31-72a78a86867mr1255462137.22.1781878847023;
        Fri, 19 Jun 2026 07:20:47 -0700 (PDT)
Received: from houminxi ([101.90.5.50])
        by smtp.gmail.com with ESMTPSA id ada2fe7eead31-72a34712e0fsm1689034137.4.2026.06.19.07.20.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 19 Jun 2026 07:20:46 -0700 (PDT)
From: Minxi Hou <houminxi@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: trondmy@kernel.org,
	anna@kernel.org,
	cel@kernel.org,
	jlayton@kernel.org,
	linux-doc@vger.kernel.org,
	Minxi Hou <houminxi@gmail.com>
Subject: [PATCH] NFS: pnfs: fix stale references in pnfs.rst
Date: Fri, 19 Jun 2026 22:20:40 +0800
Message-ID: <20260619142040.3970345-1-houminxi@gmail.com>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The layout header list was moved from struct nfs_client (cl_layouts) to
struct nfs_server (layouts) in commit 6382a44138e7 ("NFS: move pnfs
layouts to nfs_server structure"), but the documentation was not updated.

Also update the layout driver description to reflect that the objects
layout driver was removed in commit 6d22323b2e9f ("nfs: remove the
objlayout driver"), leaving 3 layout types implemented in the kernel
client: files, blocks, and flexfiles.

Signed-off-by: Minxi Hou <houminxi@gmail.com>
---
 Documentation/filesystems/nfs/pnfs.rst | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/nfs/pnfs.rst b/Documentation/filesystems/nfs/pnfs.rst
index 7c470ecdc3a9..ea3d15cc4549 100644
--- a/Documentation/filesystems/nfs/pnfs.rst
+++ b/Documentation/filesystems/nfs/pnfs.rst
@@ -22,7 +22,7 @@ outstanding RPC call that references it (LAYOUTGET, LAYOUTRETURN,
 LAYOUTCOMMIT), and for each lseg held within.
 
 Each header is also (when non-empty) put on a list associated with
-struct nfs_client (cl_layouts).  Being put on this list does not bump
+struct nfs_server (layouts).  Being put on this list does not bump
 the reference count, as the layout is kept around by the lseg that
 keeps it in the list.
 
@@ -62,8 +62,8 @@ bit is set, preventing any new lsegs from being added.
 layout drivers
 ==============
 
-PNFS utilizes what is called layout drivers. The STD defines 4 basic
-layout types: "files", "objects", "blocks", and "flexfiles". For each
+PNFS utilizes what is called layout drivers. The Linux NFS client
+implements 3 layout types: "files", "blocks", and "flexfiles". For each
 of these types there is a layout-driver with a common function-vectors
 table which are called by the nfs-client pnfs-core to implement the
 different layout types.
-- 
2.54.0

