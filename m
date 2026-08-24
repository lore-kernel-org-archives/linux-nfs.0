Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A3834302FC
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 14:04:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787580294; cv=none; b=JNfwyqphIVPGSDR5orDQQvOuY1fhVs5ZndOX2noJmzrmSW1r8EIy2ickv/4v1f9I8KW8vb4VG3VjAJpL1WFA4Bki5+oPip8cS6F8rDrk7u+TfhddQhIW5BOHsnoptGR8Yvfyaq5HBChIWT9Y4HaEoY3fte4t8/rm7F5tgVW4VBo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787580294; c=relaxed/simple;
	bh=mNk99gFLo92/ixC/ateQE1izZtkBpzktnLO9HAT5RS0=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=QV+0FUzYlQGmQRBVtfMzvrZiBZ9mAhcFtqgz4ytV8iE5tkbPD4IiSrMtjIU3L8us89DfsdZLwOrstJalgEhZD3uWJzqz9D7bQfQRF3zIolfRUzWdbdBzIkK/PehhADMM1j3M/Z7kH2yksCBHpdTGQ2sdDRj95CctcNwsbFkGICg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eb9M9F4Y; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eb9M9F4Y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D082E1F00A3A;
	Mon, 24 Aug 2026 14:04:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787580292;
	bh=l6ZUjnYnh/UuMrsMSqz21tTMuJ+guaB5Arf0wxfg/ZE=;
	h=From:Subject:Date:To:Cc;
	b=eb9M9F4Y/YjP6jcKobSiMBSzo0IZpfqKK3jGi298PUpsHvBgtLmo90WmWJoHniRiW
	 /mV+x1CbrXSW+kJpvGjfuKL/jKpSeVFYLrJSHOMQ3Wkmkur+wOA/mqoebRMBxFbjeR
	 TGps27B/2j08KOfdD16BFBcgYJzYXx8kUEi6G5udpwJV/oBslygK/+NCMlXaadRJnb
	 cyk9kh8Oyn2Q2nBQLPzBe6jVytiBrXHFwc7mh7dC6uSbwMklQmlsuKnpM6Z+p5Zp3C
	 W+a4smgmvVc50Qet9zsYIxGbvTs0v9dGodwucALQ6xdgklvgBEpeKMRwqKyJmjnACi
	 lagiKwEU0tb0Q==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/2] NFSD: Fixes for NFSv4 COMPOUND argument teardown
Date: Mon, 24 Aug 2026 10:04:39 -0400
Message-Id: <20260824-nfsd-posix-acl-ownership-v1-0-090fffc608ec@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMQQrDIBBFrxJm3YHEhFB6ldKFmjFOKSqObQMhd
 6+my/f57+0glJkEbt0OmT4sHEOF4dKB9TqshLxUBtWrub+qCYOTBVMU3lDbF8ZvoCyeE47GjM7
 SNJvBQtVTJsfbmb4//ixv8yRbWq89jBZCk3Wwvk1nuZAUDiscxw/RY5mDmwAAAA==
X-Change-ID: 20260824-nfsd-posix-acl-ownership-3bb3fce46b1c
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Lorenzo Bianconi <lorenzo@kernel.org>, 
 Rick Macklem <rmacklem@uoguelph.ca>
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>, stable+noautosel@kernel.org
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1450; i=cel@kernel.org;
 h=from:subject:message-id; bh=mNk99gFLo92/ixC/ateQE1izZtkBpzktnLO9HAT5RS0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqjE975kE+2n/b+CNUFIu2DUpNOF5PNYDCMKoXy
 R+3QRlFPpCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoxPewAKCRAzarMzb2Z/
 l7zyEACmIIiFZxRxSZllVOblAb+QdvOBCRQSfAkfgcGhPD1HJetsNJAkucHC5H6YQ57+Y5f/R9I
 LjQmRTqJ9Tfn6xEERIqPbVmodC6YVAwpODIKBbRSMqOa/Hf+d0uNUhVAp4/Gby290YLDZB7XPS1
 IKRDvbI0ZFVBMlQvq1wbbHXsoATDzA20kgE9AMcHFtIY/sF/GruzPzVy6TPPksp4zqe9oiYmO4C
 LsDnUb6DoRD1vbqOkptghK+SbFjsHBsM/xUar2gXbQ19ZpwjPSnmi1/9RFUqlLT8fg31vHRPTgw
 iYjbZdf2kEJ1XZ9pxX26yHN9gsYT15UErEJcyJjiiqc51Xz+KwSltBHHbIjGqL0EHv1reugrPwC
 ejEJ/BpqJjPd7cRU20WiRKdaWZjs2Zm3neRXFfZMBtrg8lvtMWO3vs1oacay3bToLNCJxxbtl4f
 gqfWGcqASOFrjOUaS1XPnu4gIaIF+M/LDBdo4IA2cNSEd/dYCEJsNX6REd4H+fZ9K6wijj5VY8h
 6QmO4tY1K1XEHdlGiLcIh9OOruoSH7ZyWZvOEw5XLRZIp40J/AXI1Dyk9r4WdUFANJ7239ZPS+t
 RJWopxI/R5h+vMjGItqgG12g7wqHm1Dj0JwmuEYQ4SyWoGRPtcfUyGfSCr92gTUwsnNZsrDpKDG
 gEEHAm3gnTrVbeg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Prabhakar Pujeri reported both of these defects in a single patch:

  https://lore.kernel.org/linux-nfs/20260823113255.3417-1-prabhakar.pujeri@dell.com/

They are split here because they need different LTS routing. The
rpc_status dump requires no privilege and is present in a default
build. NFSv4 POSIX ACL support is experimental and disabled by
default, so the ACL-related fix is mainline-only.

In the original proposed fix, the decoder leaves the only reference
to a decoded ACL in the operation's argument structure, and the
executing operation transfers that reference to struct nfsd_attrs.
This is the root cause of leak, so my proposal is to address that
instead.

After close review, I determined that the argp->opcnt assignments
address a problem that is currently unreachable. Instead, my fix
is to block the OOB buffer read during the rpc_status dump.

---
Chuck Lever (2):
      NFSD: Fix out-of-bounds read in the rpc_status dump
      NFSD: Fix POSIX ACL leak in unexecuted NFSv4 COMPOUND operations

 fs/nfsd/nfs4proc.c | 30 ++++++------------------------
 fs/nfsd/nfs4xdr.c  | 41 +++++++++++++++++++++++++++--------------
 fs/nfsd/nfsctl.c   | 21 ++++++++++++++++++---
 fs/nfsd/xdr4.h     |  1 +
 4 files changed, 52 insertions(+), 41 deletions(-)
---
base-commit: 565f77e5882a39bb2b70b9ed580d24e246c49737
change-id: 20260824-nfsd-posix-acl-ownership-3bb3fce46b1c

Best regards,
--  
Chuck Lever

