Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793275537;
	b=SJw4JAy5D4Hi/G5TAodVd4DzabGfUw4ZPpTiqs9KT3hJWvYI3AI4JHprGoCB7TM7W3KX
	 Hihy5/kP/ohejgwT+p/CfKz+r165c9mO4Cbwlfl37i127c+Vzg3RnQkzgWL4p/oXTIfKT
	 qJ2CuNrXckchw7a0XpaY8fFjaSE+Wpr2Ppa8YEfEA4wUsIITy4QD31QUlkBJs2oTDsjjM
	 ib8zFDecMuGHTPfzASH+aZV6+O4eom3bkxJD8IxKVVqEYV+zszY+WROWMkyIAwMc+0nJn
	 xsNqSZE2tB2c4W9CiwkUz+N8o/Um4b6F5fgjxJY2IdgRW9PEO626X9a14YaybMdk1tg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793275537;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=TpaDMjFvFmpFaSyAiNmDUKci/IgJUyuguHTbeAGhn+8=;
	b=UkCOVtkg6RGo1rp+P2GIuAzBUifxuK6C99TBt+nAcw9Fv/LenuQnGXM5UlaeJYAGpCBU
	 d6H8QWTEf57opWaPUknPCrMJoKaXuaeGZA4C/8fDVIkxCc9QFgdNB0w5iDF1PP3TaSpNd
	 CnE7aaAfdKAVcdPUnc0F7qiapT+jD2Egu/BBSlCcjNg8l2yVBM4xQF4srOnSIwo/x4qe6
	 kipl6bZOYhm33nEXssE20Z9PFIjObKnWXYbZVFPxodU2liSdLrYU9/+yM3XuyBS6qpo3a
	 6ShGGJvp0ib7gbTJ2+j0RZzi85s8XWqGNu8hLqND4KAQ8DUa+/+GTePGvtrsRHIVcsw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IjK2oSVZ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C4D09606A31A;
	Thu, 29 Oct 2026 12:05:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IjK2oSVZ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0C48A1F01825;
	Thu, 29 Oct 2026 12:05:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793275536;
	bh=TpaDMjFvFmpFaSyAiNmDUKci/IgJUyuguHTbeAGhn+8=;
	h=From:Subject:Date:To:Cc;
	b=IjK2oSVZToncojwePCorCVsGt/6UlKtzvTgxb0QGgp/JgZiVk0YTkH0MyvGgLZ+kL
	 lg78g3I0QW4p1dNBWVXXq6+J/SBpXHV1vih7LIignc63wp0jbeZWyb6g6J60oDxEq6
	 Gw5vdnOOV6i44YT1abwzyblDOQjyg6psD51lKf5+D8TuC5cH5uDenCE7SqO+pXDJwb
	 PuD6mti6bkzfdRkdsJlPI/btPZcSIeoasJ7K9mzzBaj88QBOh3siDQdqQmw4Rrutbc
	 FKJmCS01Zzqz2WCtR062TZWiHY1O8YM+dtUJVPMtC+jL1IkmXNjY+E8nrlmZgIInd7
	 AbLUCBk1quAMA==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 0/6] nfsd: add new export options for controlling
 read/write iomode
Date: Thu, 29 Oct 2026 08:05:13 -0400
Message-Id: <20261029-export-iomode-v2-0-fe8ec6251a36@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/13MQQ6CMBCF4auQWVvTDrFSV97DsEA7wkRtyZQQD
 OndrcSVy/8l71shkTAlOFUrCM2cOIYSuKvgNnShJ8W+NKBGa7SpFS1jlElxfEVPylwPlpxvXIM
 GymcUuvOyeZe29MBpivLe+Nl815+Exz9pNkortEje1djp2p4fJIGe+yg9tDnnD14NWpirAAAA
X-Change-ID: 20261013-export-iomode-1b56e9d89821
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>
Cc: Steve Dickson <steved@redhat.com>, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-doc@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3217; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=uPqT5e/nwsESq+KiZueMvDuuTI2EkgWxT+1lJL/WKEc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4zaGUgH0aIRTN/Zh61JACM0oqsSkUTv4PCGfC
 oaVyXv1Hf2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauM2hgAKCRAADmhBGVaC
 FSeGEACjMFAf49UYyKhNeH8G91NkdgQVoCjNSOROjzBGtEcuuRx5wK75xkfnVK5bP5SQj9EWj0g
 VfRjA+Br9WekU0Ss9iu5eRGyR6JgN//xVntKzQwUBODyJRaQqnMD/Koo5y3VKTrHAFGh/jzQiCc
 KIx5w8ogldzWo9cVFvMZlWrYg1L7szqVjy0ojIrzTp0oM1Z9c6dpD4WMknCl009DJPQO3gp3P30
 p7MQlMxW0I0i2B4NcM43dXBQFkNqaLuKgMRvCej14bfWETDtbk2QKFs4yrfCGavgsvYEfdxvo+C
 oiqNTPSFCahyibNu814njTCw+AtcTz8gu9rDCXEQMPBwcuO5A6I0ZKu+4f5WJZA/6QxgidNuf72
 DsgkTos957ALmP8ld+KU+YTG629bXQZyEojxZDayG3ypfdjSEHleFS3umJCG6V4J9EUgmWNsxqE
 PBciB1JpN6DFKE8mnb/JkQZaxL7SJ3Vql7RK3vCrzjVXH77iiEftgqFLMUWZPojahxlNhwGUDq3
 kiqAmsdq9aFe8goJJ+gI5IFOZcfnRf2/tXwm8Ns4vep/5IcUibAWH56ygqTCS1uGB2RdMdsRQEq
 u9jLj4yusJY1iaZUCQNFESzZZgT4angFJuts9lz4Ob4HWcf/EntUZyZks73YfdulbuBN9kBa6YR
 Jp+W2EuJod1E1NQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This version has the changes that Chuck requested. Most of it is minor
logic tweaks for saner handling of splice reads, and renaming the
options to read_io=/write_io=. I'll also be sending a v2 of the nfs-utils
patchset. Original cover letter follows:

When we originally added support for the dontcache and direct iomodes to
nfsd, we added global debugfs switches to control them. That was fine for
experimentation but the goal was always to move these controls to
something more permanent.

This patch series adds a new set of read_io= and write_io= export
options. With this, we can set the read and write iomode on a per-export
basis to either buffered, direct or dontcache.

The debugfs knobs will still stick around for now, and govern the
default iomode when it's not set on the export. Eventually these
controls should also be moved to something more permanent, but I've left
that as a future change for now.

The last patch adds new documentation that attempts to give the admin
some guidance on choosing read_io/write_io settings.

A companion nfs-utils patchset will follow that adds support for these
options to exportfs/mountd, and adds a new script to help users choose
iomode settings.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v2:
- Rename riomode=/wiomode= to read_io=/write_io=, and the netlink
  attributes to read-io/write-io (Chuck)
- io_cache_read=dontcache/direct no longer sets disable-splice-read, so
  read_io=buffered exports can still splice (Chuck)
- disable-splice-read=0 no longer resets io_cache_read to buffered
- Update the docs to match
- Rebase onto nfsd-testing
- Link to v1: https://lore.kernel.org/r/20261027-export-iomode-v1-0-262ed932a036@kernel.org

---
Jeff Layton (6):
      NFSD: Add per-export read/write I/O mode settings
      NFSD: Apply per-export I/O modes to READ and WRITE
      NFSD: Document per-export read_io= and write_io= options
      NFSD: Keep per-export statistics across export cache updates
      NFSD: Count the storage reads of each export's READs
      NFSD: Document how to choose an IO mode

 Documentation/filesystems/nfs/nfsd-io-modes.rst | 196 +++++++++++++++++
 Documentation/netlink/specs/nfsd.yaml           |  24 +++
 fs/nfsd/debugfs.c                               |  23 +-
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
 14 files changed, 605 insertions(+), 66 deletions(-)
---
base-commit: 19bbac00ad1cfa28e9127488f161ffc2ac03fad4
change-id: 20261013-export-iomode-1b56e9d89821

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

