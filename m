Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F327743E9D2
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 20:55:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789764926; cv=none; b=a2Y/GAKacFK3Ju/5XVAkWag87WuSsjPxlgFPldXZ8xeLCFZp16DmsYYHwSgBK7v/dhF8ra9e8U9icS7e3sq5i954YAGGvXOA8Skg1h7sfs0bc20U35ITSRoXSp0K3bODPTBdAYLqykpLtyxVqIvaofa6yfh5eRnp+fAd/2UWMpk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789764926; c=relaxed/simple;
	bh=oEJ8VRD6asnvEBDdMMeAWsZHMIOiZ+SwfN6MjMjtQQI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=nHXEW1RcjlGbBrlXqK0GlpD3nWcNUWrBg4cqXp5VfSLmHqUYzdbF8yK1EQCVIX5jDtDvJFpm4SDCdbUY4sgCMZGvrSGyYWp7V4rnr9zl57QeDf+Da//wOWY/EO1KLHyPzTCdbtz5wsPVjfVLi+9wZetMO+Cu1VkYyifQDgVeWww=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HwIUlHMF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HwIUlHMF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 501C21F000FF;
	Fri, 18 Sep 2026 20:55:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789764924;
	bh=yDr7Q6E6XcLytKRKdQpyj7pk4pNyK/ZM0I7ihdHlBc4=;
	h=From:To:Cc:Subject:Date;
	b=HwIUlHMFN2yUsz2w8xef6/SfufsVMt91JX4zyLahM1CfvuW4YiopbBtbnXvisSv1s
	 TJn2G6+f2l6fAJbcDL3QdctB6+3LsOL67r8Pwm4C2tX0Sj/BIY2TiyWWIp/oeTqdSl
	 aTOr4T7G7WZH44WL2vKr9K3cy5fnph6WWtucqZfs5iMKrz1cZjVYc/AKyjd4QnPinH
	 M4Iif8tTQi1v6yOoEwGWMbEgM7E0NndAtTvtcvUGntSLZ+PIenOYLWzVGOWrDudbwn
	 6Xs6o230dezh9IqmzrQDuJ8A1SVwuFBhoDFpzZRjN11A8IAyPqamMb0gDwKov8xgbg
	 600ebNXv0HvAA==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH v4 0/4] NFS: Add client side support for CB_NOTIFY
Date: Fri, 18 Sep 2026 16:55:19 -0400
Message-ID: <20260918205523.855331-1-anna@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@hammerspace.com>

These patches add support for the CB_NOTIFY callback operation from NFS
servers. Editing directory order or placement in our caches isn't easy
or practical the way things are structured now. Instead, I use CB_NOTIFY
as an indication that the client needs to refresh its view of the
directory.

Changes in v4:
 * Properly handle negative dentries 

Changes in v3:
 * Change NOTIFY4_REMOVE to create a negative dentry

Changes in v2:
 * Fix signed / unsigned type mixups
 * Don't try to share lookup code between NOTIFY4_REMOVE and NOTIFY4_ADD
 * Add handling for the NOTIFY4_ADD 'na_have_old_entry' case

Thoughts?
Anna

Anna Schumaker (4):
  NFS: Add an outline for the CB_NOTIFY operation
  NFS: Add support for CB_NOTIFY4_REMOVE_ENTRY
  NFS: Add support for CB_NOTIFY4_ADD_ENTRY
  NFS: Add support for CB_NOTIFY4_RENAME_ENTRY

 fs/nfs/callback.h      |  51 ++++++++++++
 fs/nfs/callback_proc.c | 160 +++++++++++++++++++++++++++++++++++++
 fs/nfs/callback_xdr.c  | 175 ++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4_fs.h       |   2 +
 fs/nfs/nfs4xdr.c       |  33 +++++++-
 include/linux/nfs4.h   |   6 ++
 6 files changed, 422 insertions(+), 5 deletions(-)

-- 
2.55.0

