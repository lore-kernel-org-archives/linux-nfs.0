Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794597731;
	b=KHGwo2OUs7qL9NGS3q4wl4L18M4kPO9j77D1ltIeMRMGP0aGDflsaBtR4GhAW5+HKLGl
	 MY25Ew8OVQTZ5xhtQXB7nvq2oT+Xw82P8VQhFDhxs+P4iEuvgN7lRumv3dnpR0yFMvP4v
	 wACe80ItvvOZYXG8neShdNagpIzRCwk3xEJ4xZm5O4MkeVmUMH8u1L+mXjp8ewS8yoxon
	 vBDjbdI/TnGEgxWoFDUxmMGVIbew+7IVFfHXq2nguXwTs/YLwQ/0ZuphrEGY8pJH0U8HJ
	 okcEGMf6aAu8DX6dgj0FTsp9PAYT1e8yPaJWvyLb1zgGFS/JbSGXTsonA9iU27Q7dcA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794597731;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=l0oJbUY+SvzJsICg9xSRT+ZLpUvnIBdovaTpdSZ9ReU=;
	b=bXZvjqTkvX+cSBCNJ+iziBhZwEJaXaA3ERm1d3bpB7l8vCjP0hYzaqRn8oEXeUUu0dHH
	 r/y04rtGLGEYbYUxCbNhniw8gDHJd14VpeODoIQBf2DiwRbkV5Slhpd3ZsZ1T8K4Rzm9j
	 nkw4SBSx0I4/z7L59QcCHIdYtmme0UtOJDO2abt6Wp5Xq1QIevufv8E/Jwhk8tJ/GSMF8
	 7dZzrfXal9UUqRb3u9oLfuSnUC39C9ffQOPqIvIPgpKOpCn3FD42MducdAwpQfrXy8/+2
	 LnQUs8ohMW0rrDsZzQZ90YQT4O6HvA8wTu4E9e8ZA4OAgvZdTg85O6RWImy22wYVHzg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=m80YD4nW;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C972D606A327;
	Fri, 13 Nov 2026 19:22:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=m80YD4nW
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C183B1F000C7;
	Fri, 13 Nov 2026 19:22:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794597731;
	bh=l0oJbUY+SvzJsICg9xSRT+ZLpUvnIBdovaTpdSZ9ReU=;
	h=From:Subject:Date:To:Cc;
	b=m80YD4nW0fSqqaREPNFJ4niNtwZSIgriQSD6rOLebnfTHthWB9cJ8vEdL9WgYlfLp
	 IIIiK5fw7FxZ5IerKXCFawdEaQIHZkaKbC0C+e8q+UNcOGpa7G5b7qMpOUuslfweGb
	 BIED1I+1Kih1x73llSwPQ3NFhOsXg+ouJQ3i+sq8FwrJ128o3tjRL3z7k1SHNiPUlx
	 oRdM7hLhWzoGzzKwlBXR9bRryo2wZjos/Xhs3LDvTsJiOTUcJ18xkhywje/fi5OHVD
	 nFydnM/aDzhFcSW1xj+qlvroq82MnncfrnFNc4wclKGGVVIpxgfepG6wh6kI3SISQM
	 NjV5BT54CSlnQ==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH net-next v3 00/10] Deliver TLS session tags to upper-layer
 consumers (NFSD)
Date: Fri, 13 Nov 2026 14:21:58 -0500
Message-Id: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22PwVIDIRBEfyXF2YlAwE085T+sHFiY3UU3YDFIx
 UrtvwtYetFjT/e86bkzwuSR2PPuzhIWTz6GKg4PO2YXE2YE76pmkssnroWEvBIQUstBNjPByXG
 upD4eJqVYXXtPOPlbR76wgBkC3jK7fDv0Mb6izY3YsqMhhDGZYJc2+kk/Xo0PzV885Zg+e7siO
 rEXqVX+FikCOKhhdMKdlNNanmMydsW9jdd+v8hfghD/vVJkJRh9HIzmDofJnt8wBVz3Mc3ssm3
 bF4RjwGIvAQAA
X-Change-ID: 20260512-tls-session-tags-9d0042583f44
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Keith Busch <kbusch@kernel.org>, 
 Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, 
 Sagi Grimberg <sagi@grimberg.me>, Chaitanya Kulkarni <kch@nvidia.com>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Eric Dumazet <edumazet@kernel.org>
Cc: kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org, 
 Hannes Reinecke <hare@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=6024; i=cel@kernel.org;
 h=from:subject:message-id; bh=yhODJfup1xU0GU18ny4wSRFuQglH6IQosl5aTnmsIc8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92NYNOzcuW51l+zxrbh6e54OzWGAiAJw5xS32
 aqMyCu2ZlaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdjWAAKCRAzarMzb2Z/
 l3fMD/0Q0VNZKQODVjzh2EN8IOhJzJvaAekl7esbUWeQwAZuBvpgTWlsp80znfSNDRCpKCHbKBf
 fmpMu09ETTJG6iGv7EIAbnz6xkcBkpBUz9gqUNKbuoSuK9CJXOV7Yr06CqPvp7YdQiYtYY6H+Qm
 UcNhumRN7BxbX/Xzaudwh4yVVjC2SqEX6FEaVO7c4POhsGmT/OhIsSQTgfh42QWwbIZp8r/QRPL
 a97ajQkPeOzqFmpfRQ1InEXSbFRaYE0ikbTMs/18N7e+UzZli6YacEGKdtUXQ8TlPRK2jWLsIR7
 zC+LNJe5TLqkgwolQkD9ad6+wHsXa2nlVMx8G293JSwnPGwQ0J2QLw9bDvA6ZQCBj6Ve//UC8SA
 RWj69KOJmvv3Z5ia/RuTSVuqsKTC5tB0yjB7RgvUIe/BGrjgJoc3NkQ9RHPRQis185Z5pYB8LIC
 ta8h2gcix/rM76VWTC1/BQljL7yS2IIzy1qp1jQyhnAyKizn8DG3cU7UB/TZYBlpxN4vQvM4+K/
 JPzU6Cri2RUHIqz4pXNJDVNVSQnBKWBu/YNagP44CxwSctX6dC3Ec+1KPdpW/iDv5jDE7nysaHB
 sBagrSGmJKVGDTTQlBhK7XHHKDABI9JM1FBh7sYe3MnxujZ4KSwKLjRoOTj9LIMYKXh+GW/fx0h
 G5qYcT7WBop4HMg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFSD controls remote access to its exports today by IP address and
hostname. Neither of these are cryptographically secure. For
instance, a MitM can replace the response to a server's plaintext
DNS query. As a result, a malicious NFS client can pretend to be a
client whose hostname matches one that has access to exports it
would otherwise be denied access to.

So instead, we want access-control decisions to be based on
cryptographically-vetted objects such as TLS peer-certificates.
In-kernel x.509 parsing would duplicate work mature userspace
libraries already do, so let's make tlshd evaluate peer certificates
in user space.

The certificates are evaluated against admin-defined policy, such
as whether the certificate's Issuer matches a particular string.
tlshd then marks NFS TLS sessions with those policy matches. Admins
also provide a set of policy names on each NFSD export (allow_tags).
Computing the intersection with these per-export tags is quick and
completely separate from the details of parsing x.509 certificates.

A yet-to-be-posted patch series introduces tag set support to the
exportfs command in nfs-utils. tlshd 1.5.0, current as of this
writing, already implements TLS session tagging.

---
Changes in v3:
- Replace the sloppy cover letter.
- Avoid a double free in the stringset capacity KUnit case (sashiko).
- Add list markers to the stringset kernel-doc Return: lists (sashiko).
- Move the duplicate session-tag KUnit changes into patch 5 (sashiko).
- Link to v2: https://patch.msgid.link/20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org

Changes in v2:
- Drop v1's 1/9, sent ahead of the set per Jeff and now merged.
- Adopt the pinned hr_file/fput lifetime model.
- Adapt to the errno-valued handshake status (hp_done takes int).
- Rename "tagset" to "stringset" throughout (Hannes)
- Warn and return false when a query precedes stringset_finalize().
- Add a patch with KUnit tests for stringset.
- Split the hp_done session-tags argument into its own patch.
- Collect the session tags before taking the completion gate.
- Pass ownership of the tag set to handshake_finish_complete().
- Add handshake_session_tag_len(), shared with the NFSD parser.
- Add KUnit tests for session-tag collection.
- Check the file reference count in the completion-gate KUnit case.
- Rename the ACCEPT cap attribute MAX_TAGS to MAX_SESSION_TAGS.
- Publish the saved tags with smp_wmb() and test_bit_acquire().
- Deny a tagged export on the non-mTLS arms of check_xprtsec_policy().
- Extract nfsd_nl_parse_allow_tags() from the netlink export parser.
- Build stringset only when a consumer selects CONFIG_STRINGSET.
- Free the session tags as soon as hp_done() returns.
- Report a rejected session tag or allow-tag through the extack.
- Show allow_tags in /proc/fs/nfsd/exports.
- Record the client address and XID in nfsd_export_tags_denied.
- Link to v1: https://patch.msgid.link/20260605-tls-session-tags-v1-0-47bd1d94d552@oracle.com

---
Chuck Lever (10):
      handshake: Add tags to "done" downcall
      lib: Add a "stringset" data structure
      lib: Add KUnit tests for the stringset data structure
      handshake: Add a session-tags argument to the TLS done callback
      handshake: Pick up session tags passed during the DONE downcall
      handshake: Add a kunit test for the completion gate
      handshake: Advertise the session-tag cap to user space
      SUNRPC: Copy the TLS session tags when they are available
      NFSD: Implement export tagging
      NFSD: Add allow_tags to the netlink export interface

 Documentation/core-api/index.rst           |   1 +
 Documentation/core-api/stringset.rst       | 243 ++++++++++++++++++++++
 Documentation/netlink/specs/handshake.yaml |  19 ++
 Documentation/netlink/specs/nfsd.yaml      |  10 +
 Documentation/networking/tls-handshake.rst |  62 +++++-
 MAINTAINERS                                |   8 +
 drivers/nvme/host/tcp.c                    |   3 +-
 drivers/nvme/target/tcp.c                  |   3 +-
 fs/nfsd/Kconfig                            |   1 +
 fs/nfsd/export.c                           | 194 +++++++++++++++++-
 fs/nfsd/export.h                           |   9 +
 fs/nfsd/netlink.c                          |   4 +-
 fs/nfsd/netlink.h                          |   3 +-
 fs/nfsd/trace.h                            |  27 +++
 include/linux/stringset.h                  | 191 ++++++++++++++++++
 include/linux/sunrpc/svc_xprt.h            |   7 +-
 include/net/handshake.h                    |  50 ++++-
 include/uapi/linux/handshake.h             |   4 +
 include/uapi/linux/nfsd_netlink.h          |   1 +
 lib/Kconfig                                |  12 ++
 lib/Kconfig.debug                          |   6 +
 lib/Makefile                               |   1 +
 lib/stringset.c                            | 190 ++++++++++++++++++
 lib/tests/Makefile                         |   1 +
 lib/tests/stringset_kunit.c                | 311 +++++++++++++++++++++++++++++
 net/Kconfig                                |   1 +
 net/handshake/genl.c                       |   5 +-
 net/handshake/handshake-test.c             | 307 ++++++++++++++++++++++++++++
 net/handshake/handshake.h                  |   9 +
 net/handshake/netlink.c                    | 110 +++++++++-
 net/handshake/request.c                    |  61 +++++-
 net/handshake/tlshd.c                      |  10 +-
 net/sunrpc/Kconfig                         |   1 +
 net/sunrpc/svc_xprt.c                      |  11 +-
 net/sunrpc/svcauth_unix.c                  |  14 +-
 net/sunrpc/svcsock.c                       |  63 +++++-
 net/sunrpc/xprtsock.c                      |   4 +-
 tools/net/ynl/Makefile.deps                |   3 +-
 38 files changed, 1914 insertions(+), 46 deletions(-)
---
base-commit: d1f4b7c6b997c29de67ad7178ababac2328cb1b4
change-id: 20260512-tls-session-tags-9d0042583f44

Best regards,
--  
Chuck Lever <cel@kernel.org>

