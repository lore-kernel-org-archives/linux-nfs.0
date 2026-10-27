Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793119535;
	b=IufDODw5+lpTHbCVZD0fDpdqzSs016pPKkrGgUkEbEmg1py4y0gHFXNdKpRc9YFIEz1N
	 Uvc3Je4wFIh+utNOJEBl9OX3HaGhiEhJDxqvhZMktqwBg0hL/3e+FahA1ns9de+15zIxl
	 7Iw/r1bEQ/jjNQDwmGNNHPGYp+rM+Q3DgHXMNb0109L+sbmmMH3XRLzlobCnageRYzDg8
	 y6n6Tsjh2hVFL+NZNAPWsErvE0UVPIPoBJnIg0k4N0q3S2wYBPn8e/+eQHVh8Apb8ZRky
	 gP89a2RkmBVKknm+Ysk0M2MSvYBkSkODhgwsTdHwM65wi8wifXnSC5qqYOy5Myu1Liw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793119535;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=PGsZM7u08kBDzsq3JsRau31sMD5eNroObYlAR6vvhvc=;
	b=ihpA8vyI1ovWJLtdEnRQcgKSPW8pvObW/Kg145ktYNpFnR4j3UpAFI3Q67H4S29jqK29
	 CD8s4e+A8/yi6iqMUWAvxX0vF3k4u3Kal6Jj6iadUv02swhgomEobgBgOqQjw+Qbzo7qV
	 o3I4Q8HzFJmNAgH7xAf1AdrovAtlDCNFANngJNeVu6CxctN8UoHTH7GimIh0tqfMNwkbz
	 ERwbgR0fIDgz7cmuWcQJvgKPYRzpSqTKMg6ZkdlpAEV9S6RbpH8UrS+Q6OJ/fm+pC0HE5
	 BWKrQoSgXpnQQ3sY310r/6C/89H4czT/x516Ju0kW6U85VXMmn9o3M1j/ld0sSg6/Bw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aeGTj+fy;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDF4E606A31A;
	Tue, 27 Oct 2026 16:45:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aeGTj+fy
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C01B51F01825;
	Tue, 27 Oct 2026 16:45:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793119534;
	bh=PGsZM7u08kBDzsq3JsRau31sMD5eNroObYlAR6vvhvc=;
	h=From:Subject:Date:To:Cc;
	b=aeGTj+fyDl4hV/f5XtV27vuCzdz+p6/moVu6zPnO5SslTX7EvASDhIlPoJN6FyfAh
	 YxLEOLGdIevDAD9flchLImGUDOf/frCgvaoBCNy/r4nk5nN251Yc9EymOlIWkQqGxC
	 72yxVG8k8hxfdul7jkH8yqgevzo+C58al1nn2ylQEtVbam9dFRiJ4L+iweEqfa7sXH
	 iu/15qRrwX7+Z3Z2wyVwt98OS+izrcLN48Uyu5rtEu6HqATBYrmWpRrLfYSk4c/nPv
	 OSl4/NW5MnjXLJ9RNXRrj9F/CksUSRm5Q7nX9ZUNYZEBibzCpRz/zMaNR8iEnuBrhF
	 QxCgqt5TmqRwA==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 0/6] nfsd: add new export options for controlling
 read/write iomode
Date: Tue, 27 Oct 2026 12:45:23 -0400
Message-Id: <20261027-export-iomode-v1-0-262ed932a036@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3MQQqAIBBA0avErBMcI9GuEi0qp5pFGRohiHdPW
 r7F/xkiBaYIQ5Mh0MuR/VWBbQPrMV87CXbVoKTSKLETlG4fHsH+9I4ELr0m64w1CqE2d6CN0/8
 bp1I+haqgyl8AAAA=
X-Change-ID: 20261013-export-iomode-1b56e9d89821
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>, Mike Snitzer <snitzer@kernel.org>, 
 Donald Hunter <donald.hunter@gmail.com>, Jakub Kicinski <kuba@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>
Cc: Steve Dickson <steved@redhat.com>, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-doc@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2474; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=BqM1sCZZyL9Y1KM+SrCA16ZGFxzt0cs/vuqpxotswZk=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4NUqw4XsvML0QysKFUNy1jr5ilH2gCvGydELq
 79euJX3S8SJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauDVKgAKCRAADmhBGVaC
 FSq/D/9ahPYNnHFC04PHIlvDgTI/gL3psd3jVQXtCsAYkauGUU27tIYoA0zqPUM+5AkeFxWsBYf
 HZNWNKNHgQyQnzHzEpLw9XAncVxpLmu16fSXGDy0IDuht5HlVjvEJHyrmSSTVlA9Nh81G/FVQef
 RGA1Y84RZG2eiV7Jwam7OEeWg1o7/bXgfPg8Aw23rmV0ERgA8wRDPScyGhB1McGOug3mRVj0Pes
 igi28376ACw29mYBMtikYd4pK38VegPQB6VBXtfEdj/sz0DQ1H6HL9LuitMDjuTBg30LZZctGtM
 9n1i0EgGAwCJrliScNLP8wrGAPICfMTnE6rbekjI2K8bm9UCTLHsLKcGmZVRjcoaB1jTgs+QXLM
 JObVhEHV+B8CyMeBO0I6UaE3FhoM4CIMRvOCZh8EFEFL+USfkAO6IGJ108C7NFZJfTqZw6RRyDG
 8poGt0DB96xuydpPc1hMz+HEfJUrY79TAaTjDpOUDkU9t6cGaZylZgA7sanFbRXgfThX5irEKBx
 BL8wHwgWL2sbMQEXihJsJhCAynnUq+pZ6yiR3ARCHUEe7senxKgx8oaw8e21Z4vNiNivyK+ywj0
 CCQZTzT/auHeHBU1emZ1FWT8aro9M4ZZR0h4qh6lp8c7KpTD9Wx4aKiDHYU3s7X1O+SBPXMqzJ3
 XcNPE6u4Y04Y5YA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

When we originally added support for the dontcache and direct iomodes to
nfsd, we added global debugfs switches to control them. That was fine for
experimentation but the goal was always to move these controls to
something more permanent.

This patch series adds a new set of riomode= and wiomode= export
options. With this, we can set the read and write iomode on a per-export
basis to either buffered, direct or dontcache.

The debugfs knobs stick around and govern the default iomode when it's
not set on the export. Eventually these controls should also be moved to
something more permanent (or maybe just be removed), but I've left that
as a future change.

The last patch adds new documentation that attempts to give the admin
some guidance on choosing r/wiomode settings.

A companion nfs-utils patchset will follow that adds support for these
options to exportfs/mountd, and adds a new script to help users choose
iomode settings.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (6):
      NFSD: Add per-export read/write I/O mode settings
      NFSD: Apply per-export I/O modes to READ and WRITE
      NFSD: Document per-export riomode= and wiomode= options
      NFSD: Keep per-export statistics across export cache updates
      NFSD: Count the storage reads of each export's READs
      NFSD: Document how to choose an IO mode

 Documentation/filesystems/nfs/nfsd-io-modes.rst | 194 +++++++++++++++++
 Documentation/netlink/specs/nfsd.yaml           |  24 +++
 fs/nfsd/debugfs.c                               |   6 +-
 fs/nfsd/export.c                                | 268 +++++++++++++++++++++---
 fs/nfsd/export.h                                |  19 ++
 fs/nfsd/netlink.c                               |   4 +-
 fs/nfsd/netlink.h                               |   2 +-
 fs/nfsd/netns.h                                 |   6 +
 fs/nfsd/nfs4xdr.c                               |   6 +-
 fs/nfsd/nfsd.h                                  |  17 +-
 fs/nfsd/stats.h                                 |  33 +++
 fs/nfsd/vfs.c                                   |  59 +++++-
 fs/nfsd/vfs.h                                   |   2 +
 include/uapi/linux/nfsd_netlink.h               |  12 ++
 14 files changed, 599 insertions(+), 53 deletions(-)
---
base-commit: fa65fd6d503d4e965ae27b1a75969e097569390a
change-id: 20261013-export-iomode-1b56e9d89821

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

