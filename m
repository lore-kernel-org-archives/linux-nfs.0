Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F168C2AD00;
	Thu, 10 Sep 2026 00:29:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789000189; cv=none; b=XJFECNqDGSZPoMRGXRpe5hcXzBvESDQrS4bPwAewkhqzdGUdeS5HCHYdL4ZcHlg1osgQmybHgUNRcRKWBEk7IgwiS1sIIl3eW/HRe4I8hV+VOC39JD8CkPBcH1yXwU2QyNU/aN1UJOow9myuvEX4C5h1vJ37bYNrOvHg0zEiwpk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789000189; c=relaxed/simple;
	bh=aPjjTcqF2XeYLTM41nA3YHEPSk3Ah9fEOqrE6jzMgUY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ownjad+ELTK39W12vXQ0KwJlSVdBBU1yYvQES56ec+iHsKUDV3gVDoc+XFgNxWdvKhyhRhxTE3VbvQDzsRCjpcdeGNJQDy2yNbQb8PlbOD42jUkCAzTf13eP3G35EivUqzE5Q7+wyOq10TeHaigJ9LviNUbDGJ0/edlOg13rKQg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=U+2JYhu+; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Fy8D1O/I; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="U+2JYhu+";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Fy8D1O/I"
Received: from phl-compute-07.internal (phl-compute-07.internal [10.202.2.47])
	by mailfout.stl.internal (Postfix) with ESMTP id E808B1D00091;
	Wed,  9 Sep 2026 20:29:46 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-07.internal (MEProxy); Wed, 09 Sep 2026 20:29:47 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to; s=fm1; t=1789000186; x=1789086586; bh=2lQ2pka3FW
	U4UnyW8EvfdzmcWknbIDD+gKd/6rbH00Q=; b=U+2JYhu+QuDOU3iNolY89E0Jmy
	yWazQrwJdqWkfEckpAqOOvFChZHbTDlcKzTeL/KIGgsHDXV1rzr9v4XlsxOCnZv0
	7d8vD2Vhfy19ow7Q36MJ2nOHL0wmz30GwYleKGLtCCIGZ1xfqSIXTuiSUo6Y+TRY
	xwC6WP9GfiC1s2hoBB8+ShYSpB1EjD4HUDAfEWI+wA6/8FG0AA5dG9okvCUtCV+s
	67GeEk+2S3+AyTq/kJMR4Ow7XACMXlEcb0u6mvue3earXBm5wGEzPNJjLmgtaRje
	ERatuArm3FITL0gZ69qdpwgeD6zfLai5q8dlzoaXXr8lQx+W1hCuet8P/q6Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm1; t=1789000186; x=1789086586; bh=2lQ2pka3FWU4UnyW8EvfdzmcWknb
	IDD+gKd/6rbH00Q=; b=Fy8D1O/IrrozSvLaAPWJYkLvgtRpAJJLBwraxUpjlWmE
	yM+SjxgwvVeRAXcMWF+2mHUAlKdQlF4Ah+vlzX+R+qgJ6QWzCPWz+Oztlj3go+RC
	+5eyNajgnBmodHlSmBhndbGG1FJdkj/hbCBaSQ94jJZoNkWqp5B94yEt/36C0KhN
	NTJeTRwX/vEsP3+fJEpI8RO3Y6lAeyAlu8KRrm9nvBdzGjHgv3weEdXCUC2wrb6f
	LJw7u9UPaNv+2IbnP2Ru8RRf6xULra/CnwUa028IN80OU8XzdtaWWuVzId1FS09x
	fYi2t0AMSLY3cFQTt9IgfZUF8ZJtRuGEUgrFXr25BA==
X-ME-Sender: <xms:-vmhamYx-s9u6sg629eSlS4-TXfFqFrTeio5o-GDBN1kcBL_Frk2HA>
    <xme:-vmharqwvlKHSZjB2GkXyfQTCQmjg4MgDHqs94Z9W4z6kSf0Ai2LeHYp1mP31Q3Pn
    2sBxo1_Qi2jfLAQFicimQIPAG-vp-atvPAkpbn1h5VYS3clZA>
X-ME-Received: <xmr:-vmhajM3tLDiKXZ7CrfcR6zUzxV6WMbm5jmckgsDEsGN_Gdazhe2DpEkjNt77qtAXoZ9LFCevMkllETj7sGmGVDhwXtKq8c>
X-ME-Proxy-Cause: dmFkZTGeZS4Tz1kwsfzPjKE2MC0aSlZicXXI3+baH1XMHVs4sUVRzBIYjnndtn/0+ifDxl
    pir+10r4WsWsobcPoZcStx9jeKonSKGYWhx5h0hW3Japu/x3w404MWl8A6hgXkW472G/zZ
    w8+lYz+G2nFurdh/pQU7wCDvOeD3sBiizp4+7JMbdltNs1GJoCm2yBtoTJEUYSxWKGSYvs
    9lQIUFQNKZkK6dJrCgr5PfJ27d61bjeqfZwImhizn4nHm5UgrkuxodVav6Erqicbn05aAr
    L3FonvXPUSFkUfSJzXVaOeloV9igILnJAQ15t0InvGPmafRRschsQhAB0aoPoJz3Rkeztl
    V3mVrANoYQ2OR1QP3mkoGdhcLYAaNJxdmr5DZro0hEks1qW8L2W9L/H1q72Z8f1RdSahnC
    moHTH3guca52EAM0nqgB5fUXBFyVKNgN3TRR87AJksaqtPugunJMBOndA3nzqDmHbxaipY
    UPRKwfifev1KhJgkYE5FXjl2+oD1Oj3JjG3Andwr7hJOHSF6oFW9TwT6SbT+L+EIUrRBtu
    C9DvShoh1jtEPoPkxOllOKOMn/CGCbXiIQFb7f1SQ2iD32dxO9WJgcCBPkbvFlhzVQGqzt
    aHJKMW4dHRvWLmHe6BR1p0TEmHnYgeGeiJQQgzW1rVoxtRAahDSwVOdXJKhg
X-ME-Proxy: <xmx:-vmhaurABtLvRkaxWH8i9qOBAPOW8Xpe9FeAthLJrLlra2SinVETmg>
    <xmx:-vmhagc0n4nO1O4FtNXHaso0Eg0Lv5GHoh7tFFnth2qttG0t1QWmpw>
    <xmx:-vmhasTQSPzVi1YLJFPW-qGSQfTcw48uER2YZmYgVnCLkbZ3_XGEmg>
    <xmx:-vmhahZXG7f1IgEo5RfDoX4D7c-dOs2er0fD_zwp2R2qasyYcBjN3w>
    <xmx:-vmhaulLZgh_o8fnjvELHcntoPbq4Vc78FtY2xY7RI7SwyyE_IeVCx3o>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 9 Sep 2026 20:29:44 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 0/7 RFC] fixes for vfs_lookup_open, and integration with nfsd
Date: Thu, 10 Sep 2026 10:20:46 +1000
Message-ID: <20260910002934.192979-1-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

I've been looking at the problems Chuck and Jeff found with my
vfs_lookup_open() work for opening files in nfsd and think the following
patches address the issues.

I have labeled this an RFC because:
1/ Patch 2/7 changes user-visible behaviour - in a good way I think.
   Currently O_NONBLOCK avoids waiting for a leases but doesn't
   avoid waiting for a directory delegation.  I think it should do both. 
2/ vfs_lookup_open() is changed to update the 'dentry' in the path arg
   to report what was found.  On success this is identical to the
   returned file->f_path.dentry. On -EFTYPE failure it is useful
   to report the actual type to the NFS client as required.

As an aside - what would people think of changing ->atomic_open
functions to *not* return -EFTYPE.  If they find a non-regular file they
should use finish_no_open() and let the caller decide if a non-regular
is an error.  ->atomic_open can still honour O_DIRECTORY if a network
filesystem does that some special way, but if it find a non-regular when
O_DIRECTORY wasn't requested, it is best to report what it found and let
others deal with it.  As it is we need an extra d_lookup() in
vfs_lookup_open() to find the dentry that ->atomic_open refused to
return.

Or maybe we shouldn't pass __O_REGULAR because that only affects "open",
and lookup_open() doesn't even try to open non-regular files.

I'm keen to read your thoughts on the above.

Thanks,
NeilBrown


 [PATCH 1/7] vfs: add some allowed open flags to vfs_lookup_open()
 [PATCH 2/7] vfs: O_NONBLOCK|O_CREAT open shouldn't wait for directory
 [PATCH 3/7] vfs: vfs_lookup_open() should only return -EFTYPE for
 [PATCH 4/7] vfs: change vfs_lookup_open() to return found dentry in
 [PATCH 5/7] nfsd: switch NFS4 OPEN to use vfs_lookup_open()
 [PATCH 6/7] nfsd: nfsd_check_obj_isreg() to use nfs error codes.
 [PATCH 7/7] nfsd: use vfs_lookup_open() for non-creating open
