Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DFBD0336886
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 16:00:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789401653; cv=none; b=lX09uD5JWoU+FfCMvsJy85a8sX7TqT7b5kKuKTY8tQyUV16dQBahMRIhr1QJXVrPB0eIswvzMsLQwCVcALkoKi/RHPYZqUjQjkkhGLgYiCzIO6/0czmN1mY3ATvV16A2DuBg9HbjNwZKzfjSRdHJyRPS0YfmPyvuHeKRiyMS0j4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789401653; c=relaxed/simple;
	bh=QpD8bgxXNUK9nlPPZRUICLZcvBtd9UDD22LpZjeMIVU=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=GJ6Q9UI/LTgXhUsCse4ct0jp28+uHslOfsvhF/GDkyN+FIkcqyNh24VSAVXv0rKkYphbkxvFPpp1/xmuxxHjc5zD/GafS+qqMUfjypzgs7BPl//PZCfi6wugM9dQ9THvTwKRP4WPjHdXruDBjtBovAgyCPVe1ngzGI/2QLiQ5IY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ct/z7gaZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ct/z7gaZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C72181F00893;
	Mon, 14 Sep 2026 16:00:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789401651;
	bh=6TZxjFIW5qlM40207kGxiNqawqid3uu07x4a6D4Ism0=;
	h=From:Subject:Date:To:Cc;
	b=ct/z7gaZZ0+7axgqTmtNpNBsBymruEO7W3qoPSWzjbFP+WsGLXun4s9mvWlbrVHuP
	 TvUsnvxRNwcyp0HvwttE8E5wYXWR80O5HeYaMB0cZM6gcH5PB8E5yek8/sjKuSaNKA
	 GmiXIYc9r/fh4qEVyK6GFtEoW1Ne68s4aV1YA1CEpLO+4avbVlbIhU1Cr448JasQB7
	 8zPfZ/JqC35EkNxGiCiy+p0GCapq7keqH8vrV/n3tHAaTdd7Oqt4HabFyr73t8zIt/
	 /EdWHoMLV6M6XNPEnMyX+cVo8a7TawK3sVw/w/7fa1btBbL47aG9pIzrYHoJcH8rrv
	 B4pBtfOizvmNw==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH RFC nfs-utils v2 00/10] nfsdctl: allow it to handle rpcbind
 registration and deregistration
Date: Mon, 14 Sep 2026 12:00:28 -0400
Message-Id: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/1WNzQqDMBCEX0X23C2J2t9TodAH6LV4SOKqS0OUj
 ZUW8d0b7KnH4Zv5ZoZIwhThnM0gNHHkPqSQbzJwnQktIdcpQ67yvTqpI4Ym1m70KIOzaGq3M7p
 xiVhIk0Go4feqe8D9ds1SG18j+whVwh3HsZfPejbptfTzavXvnTQqLK01mg6mMGVxeZIE8tteW
 qiWZfkC5WacIbgAAAA=
X-Change-ID: 20260908-nfsdctl-rpcb-adc5a1fc090b
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3002; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=QpD8bgxXNUK9nlPPZRUICLZcvBtd9UDD22LpZjeMIVU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBor65RYbbVRCcuOsLRrNIqDRG3lGgRLvLsxU
 ST+4Ow0qY6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgaKwAKCRAADmhBGVaC
 FYwvD/0ao2ULX1LUHR16Y6Zqy+f0XRU61+ggOEA4SQqQUS2NyyJEOwt4mZaehHwqePT+UhdeyQC
 lAENzIfxZPKm7RAS5fZYJSs4IaNsvKlp14LNqD0kvVPPQu9UPpABnZKduHM1FM88DbLL1btrb0B
 2GC/kRjI8xaJuCfTkifgQWNDBOugmk879geAiIIlyNGQWnIOlZZzwtl74+fN6Uh8zVizq9rgiG2
 A+CqA0H8eHulDMxm6dfaH2jrH9ZEW2wENL5BK9Ug+/x/s6f9mrh0H5G5VYwhDM/5+ZBw7vdn2Ic
 guGHdmZoifuR3pN2nigcWLUv5yCiWdV7KTFsf/9TgO5HZC4dJ5yxHrii5YCEx5WVAKFfeXtf4IB
 2b82Q4bsapYbN15ix1hJHd6r8iPz253OLVvG/A+JQNBlepJN1suboTqwSiY3y8gmfNsHcr8OH9s
 zYo5SgjYcwOGRFEaf5LB9mPFTzRGi6S1c5jdPsorn6Hi5MRitHG15cy5TUtqbBw5WUNnCtXbeH5
 3YU/bb13rgwzVVRCVEMq2K7YNG4VwmhH0iG6U0l5X9gvxtsL38pjMWpqDTLAuh+j3dcNnj13XUB
 m025OTHATJW2LJ535qVasSFIuxJ3fc2RV1MWGE45Py/KN5Pi1i6J02i7z3qGUrXkTiJJ6lY36kK
 pYVAFAHu+h59PBA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This version fixes some problems that Sashiko flagged in review.

This patchset adds support for NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND,
which tells the kernel to not do rpcbind registration and to instead
allow userland to handle it. After setting listeners, nfsdctl will then
call out to rpcbind using the normal libtirpc client interfaces.

This is a companion set to the kernel set I recently posted (and which
also should have been marked RFC).

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v2:
- Fixes for bugs v1 introduced are folded into the patches that
  introduced them. Three pre-existing bugs found along the way are
  separate patches at the end, so the set is 10 patches instead of 7.
- "register nfsd listeners with rpcbind": register only once the
  listener_set reply has been parsed. On a reply carrying no rpcbind
  attributes the sweep cleared every NFS and NFSACL entry and put
  nothing back, leaving a running server advertising nothing. Also
  abort rather than send a listener_set that lost the ownership flag.
- "clear rpcbind entries when the serv is torn down" (was "... when the
  last thread stops"): also sweep on the autostart teardown path.
- New, pre-existing: fix a heap overflow in autostart_func(). A failed
  listener set zeroed the pool count before the thread array was sized,
  but the array is filled from the nfs.conf list, so any [nfsd] threads
  setting wrote past the allocation.
- New, pre-existing: reject a listener insertion when the table is full,
  instead of writing one element past nfsd_sockets[].
- New, pre-existing: check the nla_put() calls in set_listeners().
- Link to v1: https://lore.kernel.org/r/20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org

---
Jeff Layton (10):
      nfsdctl: sync nfsd_netlink.h with the kernel
      nfsdctl: probe the policy of any command
      nfsdctl: share the listener nest parser
      nfsdctl: add rpcbind registration helpers
      nfsdctl: register nfsd listeners with rpcbind
      nfsdctl: clear rpcbind entries when the serv is torn down
      nfsdctl: add missing break in update_listeners()
      nfsdctl: fix heap overflow in autostart_func() listener cleanup
      nfsdctl: reject a listener insertion when the table is full
      nfsdctl: check the netlink attribute puts in set_listeners()

 configure.ac                   |   2 +-
 support/include/nfsd_netlink.h |  18 +++
 utils/nfsdctl/Makefile.am      |  10 +-
 utils/nfsdctl/nfsdctl.8        |  16 +++
 utils/nfsdctl/nfsdctl.adoc     |  17 +++
 utils/nfsdctl/nfsdctl.c        | 256 +++++++++++++++++++++++++++++++++--------
 utils/nfsdctl/rpcbind.c        | 251 ++++++++++++++++++++++++++++++++++++++++
 utils/nfsdctl/rpcbind.h        |  42 +++++++
 8 files changed, 562 insertions(+), 50 deletions(-)
---
base-commit: 630393e9c73667b3fda6a7507cb5171ec0ec38dc
change-id: 20260908-nfsdctl-rpcb-adc5a1fc090b

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

