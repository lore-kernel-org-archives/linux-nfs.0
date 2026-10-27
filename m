Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793119841;
	b=n3Q2JQAzdzAsxijJuMzH9ycwMwp6gi+roBzJPVR5pp/p4f5yp+16ZUg7kkD67g1ruUzB
	 6bhNYHOg2a0vPCuUlfVKf080kXbGjARMZeEisNbqZ7i1Vlhh9P/h5QQNZwqgs3zC6uITO
	 punR/95bIB8Hu5b1PjzaZ7uTmTUwW9vL+XS3LbnbYt6x7PuzlD1qEtPsCvynBV5wYh86J
	 aNSHEJUVh2lbgS4a+CZMPaJPmz+SaNljrIz2W9Ku4yPwf0YXyULx5LbVOFNr+F15nzDH2
	 yo9ToHQLn7WjmSJ0jW41P1ED+WrtU/hDgL80mSWoQpbHdBOXuSO4nOyU8UME6osQDZQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793119841;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=PiNiZlyIn6rnyx/Vojjxwk7USrBsVZHQWvpWZuR4mr8=;
	b=h3dg1JBhKDMdJHoipxB0CvbnY5aZAou5EJhgINVuQR0sL2AOu11txpm0DmSCKCYTDwVN
	 k+2EQn3+DMerRpMroSE4h6mI59mqUDU5zPFsn5Kf/PVqKQ8/C6fFvyBtFKNEK432ZLouj
	 vuq0jqEZy6R78iRiLDNLX8zdQyW4iPB/NI2KYXh2XOVzxqImFV7vfMp5ItjXbxCkDZsmk
	 7bOcInjL1v4Rc9Lc8De1MpC0Dlemw7ul1jkHxJX2Dxu4IAsRHR6mTZLOD8lsGxffmkwz/
	 mup8qRVXfduMLQmTxpqCThzkzDN9qDOAJlPiteKx3ThqWFe4/KlquFywcEPmIxJtB9Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nA9X2TIb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0BA20606A31A
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 16:50:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nA9X2TIb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B76381F01825;
	Tue, 27 Oct 2026 16:50:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793119840;
	bh=PiNiZlyIn6rnyx/Vojjxwk7USrBsVZHQWvpWZuR4mr8=;
	h=From:Subject:Date:To:Cc;
	b=nA9X2TIbfL9VxYmElnGRES2rMl0UkBXjWnOmN+P4Nvvusnq9huG/4h6uoebuBlwjC
	 pTfbHJ7jmkRNIeW7WLtq5flKp4HmDjzy1bx6y7SjxWDkpGsgZfoKp2OFJHgwUFftrC
	 9WqnpcgOoYSUgDLszZbEi7VOt9Y4j+pchtiEreubiWxq90r5CZBLlukZI2whLAMldL
	 2PIjwrvtg8Juuuq7XawJf4QqW5P8sTRfHFstCxtqL7+4J84LhX7ICuW5/kFlgPTDSW
	 aQ5qePcMoAmB9ialq6QCFvraI/aN3sWUZ9VMVNLdss+yt9gTArgF3bD1uHmv/amGk5
	 KrQk0AjXlbX1w==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH nfs-utils 0/4] exports: add support for new riomode= and
 wiomode= export options
Date: Tue, 27 Oct 2026 12:50:22 -0400
Message-Id: <20261027-master-v1-0-6f1f7a35a83b@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3MTQqAIBBA4avErBPSfqSuEi2sxhooC8ciCO+et
 Pzg8V5g9IQMXfaCx5uYDpcg8wym1bgFBc3JoArVyEJWYjcc0IuxNnZuWiy1VpDi06Ol5x/14Cy
 LK9DGMMT4AScjTgJjAAAA
X-Change-ID: 20261014-master-b5afd69e3772
To: Steve Dickson <steved@redhat.com>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1963; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=GrUcURDl/WMPdhMBLOK2RPJChSvIJiNwePslf0wRJOw=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4NZe4ofHnv2JI4+YJNqag9ATX6Ie3VdOCUeeu
 2/g4dOsmfqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauDWXgAKCRAADmhBGVaC
 FdX+EAChVCYFzMYb/MTck3f1rNGTpJdntTb1wJpTlGoTCae/N4ZYAUeVQgR2TbPOoRRKtWxIaS9
 c2QwCerdvLUt5ghra2nx3SeN/mNIktQRzB+nO2g/cGAH2LiBbeplGUtbMfbbnZYtAyvTbRmPWFM
 GPmyUOA/8hl1t7AoSAerCFPkeQ0lcR/f9KkiMAhDH5dh0HqGWKw0/9YJ/vEpwD9eh/F8BnakJih
 uGOdy+MMsOO/9RQPgaDjlR4IQRcj2Q36Y4Ed9bcf4pURm+EJLCdjaqz6p5Xe7kHqc58kgrsEZWk
 q0E4PcbsIlORwNRtnrDEw0EGL0ijI6Bkd/lb35pOr8gbXGTEgdbSBNrUAub8ZpXTVWP0u6X+wXs
 F8gcf3rtNVWJbib0wN6IWbU9FrUzLQo7uW0Bxpac6lCRUeLuoENc0r4FCHeLz8ZArswzCSMayIU
 qRyUtmEMsje4FoDqDfFon4FlBXeP7aqvZF7inudADPfFjcz7bxK9r6vfjA3AoAW1+2AJjFWPOKn
 /e8d6c8u4XVkitSvhuEdh4HfbT4egH3BdG8kMRjsTPUX1iLZPPbD+MCm+5uJRu+UiYAIJU8kNe/
 X8CQvR2wh+l2dAq/L8qaasws63MI70GuGx2heT35RArnI/uTlYPdUWa/VgusnbAsfwDCUg77x2E
 hMSbxPWp3r+lYIA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This patchset adds support for riomode= and wiomode= export options to
exportd and mountd. This is the companion patchset to [1].

The last patch in this adds a new nfsd-iomode-advisor script that
watches various stats on the server and advises the admin what mode to
use.

I consider the advisor optional as it was largely vibe-coded. I'm not
sure I'd trust its advice that far, but it's probably better than
guessing.

[1]: https://lore.kernel.org/linux-nfs/20261027-export-iomode-v1-0-262ed932a036@kernel.org/

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (4):
      exportfs/mountd/exportd: track the svc_export policy highest attribute
      exports: Add riomode= and wiomode= export options
      exportfs: Display and document riomode= and wiomode=
      nfsd-iomode-advisor: recommend riomode= and wiomode= for an export

 configure.ac                                      |    3 +-
 support/export/cache.c                            |   59 +-
 support/export/export_policy.c                    |   29 +-
 support/export/v4root.c                           |    2 +
 support/include/exportfs.h                        |    3 +
 support/include/nfsd_netlink.h                    |   12 +
 support/include/nfslib.h                          |   14 +
 support/nfs/exports.c                             |   51 +
 tools/Makefile.am                                 |    2 +-
 tools/nfsd-iomode-advisor/Makefile.am             |   14 +
 tools/nfsd-iomode-advisor/nfsd-iomode-advisor.man |  232 ++++
 tools/nfsd-iomode-advisor/nfsd-iomode-advisor.py  | 1198 +++++++++++++++++++++
 utils/exportfs/exportfs.c                         |   34 +
 utils/exportfs/exports.man                        |   22 +
 14 files changed, 1671 insertions(+), 4 deletions(-)
---
base-commit: 0ed4324cbbb8020039d338d597c1422a980f7085
change-id: 20261014-master-b5afd69e3772

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

