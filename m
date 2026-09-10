Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 53E01394792;
	Thu, 10 Sep 2026 18:00:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789063252; cv=none; b=k0HYZiYXlN8mCfwz/CgODPIkD2hEQbxhf6GDLyG1Guyjs66tat25cgKOCv+TxNKUckSl735s0dk0D/JNFtDl8F/j+usRuUJ5YCKpH0Rt6Btwa68dL1RWjUGmY2A9Yb++xlsqSjhfFClK2iKkP8Xujb9aaK2dV/pLHTgc13wPBEw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789063252; c=relaxed/simple;
	bh=8UC0CkBNjafrJPcTHBQj2MqP8b0QuEgbmc8WHbKF+Do=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=l3ZMTXYXgwnu5TsT0CwaeUNIKaF69ck4kw7dzJRbrrDKYWDJl6JuA/lO524eUgC9PHseqkzKKjmfIdNkeJ1XxFXgptyF0nkJbnBEI7Mq6c5gqWjl5cJTycAmYMPpBUqg2trwg8B/x8X/H1Tmy+ZaTDmwHrdA4KvhWXVQMptLFoM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RnQ6Ooqo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RnQ6Ooqo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8C0801F000FF;
	Thu, 10 Sep 2026 18:00:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789063251;
	bh=RUTXF9dZNGxbZbWpwOQ9Nbi4adwOm0AD8t1g768npec=;
	h=From:Subject:Date:To:Cc;
	b=RnQ6OoqoRRC+J5NTaxNO43FOnbwW1Sg56lkK1Peyli8X+0fXHPau4tV1GysIU6sjx
	 d9+zZM2q5Gf3qcNxTCREIL5sqhjudTUCUom5yEIm7av48jzL12R2aZEmxGjq2NkzAR
	 ITTKzAP4n0HO6ctuUTvgh3r5kI8Ul+QupmyQnwrfTu7rhfntoU9HzSnyR3SAORa/zO
	 mx3eC/1nRKCn8ITxoUbL5pbWb5cE3pjENfCzhWw6+a1zTyzcXvHFMgcCMoa+gQJNSb
	 OPQwz6/EBEKyzwD9iM+dyrnRwO5PFjfaaYpRMkxwSr5f7KBq67RH/UC4wSubUGJGTa
	 7cJMudSd+c4MQ==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 0/5] nfsd/sunrpc: allow userland to handle rpcbind
 registration
Date: Thu, 10 Sep 2026 14:00:33 -0400
Message-Id: <20260910-nfsd-norpcb-v1-0-b4d5182d634c@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDSwNj3by04hTdvPyiguQkXSPD5JTkxDQjE7OkJCWgjoKi1LTMCrBp0bG
 1tQDV1PmHXQAAAA==
X-Change-ID: 20260903-nfsd-norpcb-21cdcaf246bb
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Donald Hunter <donald.hunter@gmail.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1885; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=8UC0CkBNjafrJPcTHBQj2MqP8b0QuEgbmc8WHbKF+Do=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqovBKwARa897UznPbSsK+i2JmWSwfgLCyE5ent
 bEYmwpcs3+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqLwSgAKCRAADmhBGVaC
 FeBXD/0YNtA+6ipUbh1JusvkWw76thJfHigPDSCtyLRbw3lrP6qJjB0XOjPhD9HZKUdVoZdwKkz
 yCqU3PrMrle5DhLj9U+QR+oystSlrAfBwumvT8bicKJhxBleaMkvrzF3nfE+G78RcziRiIqsd+E
 zIz8ETU4Q2mN2URRDJCUDrwvp/3ggrn/7yPAB+ECeiPYMruqwmSpd33nEvWgokapGxTJFdRZtGO
 ste4Fucly3jRPY4CZVEWOh8etlAY2ilcHzpAKXDPvhyn9muwkQhbhc7HWyyYNuYv4sgSe83rwuC
 4YayLUEo/To5v5qn+pPWwRqOtbWvYGlrRvIYSknYdKhGbfG+d1bUgjsZQvF7KdlJrEnqEnQUMHC
 bzheIqBresdWWP7bvtcmpVqx04zgJjjdoaLIGJA/eY0gz+ndcNmf4p2PQa899IZ7KludiE00QfH
 /sRkEd17HqnNrROnsnQsaSZzvBOuyAAvnsRunHzTtk6Bj4Xgm8J6iXIK5HZj8n9d7kxmzOhBbT3
 4bqCxq/tUhtFG2IOU7JNCwQEqlU1w9tSL56Goeitk8bbyifP9CiyT8dULTAAvbX+i+3/o0xaD+s
 /18z8mm9/g3wSxONPDvvuZMe6MCDPQaQKt7rF7vu7xYNn31SbxHAQ5TAGdpfKPDHNfhc4KySYnC
 3CX+P34UgVAhB9A==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Consider this series an RFC. While working on the recent hardening
patches for the nfsd listener netlink interface, Chuck mentioned that we
could allow userland to handle rpcbind registation itself.

This adds such a mechanism to the netlink listener set interface. The
main idea is to add a new optional flag to the netlink downcall that
tells the kernel to skip rpcbind registration altogether for the nfsd
listeners.

Note that NLM registration is not affected and is still handled by the
kernel.  Handling that is trickier since it can be started by the
client.

Patches to nfsdctl will follow.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (5):
      SUNRPC: allow a service to opt out of rpcbind registration
      NFSD: add a userspace-rpcbind flag to listener_set
      NFSD: honour the userspace-rpcbind flag in listener_set
      NFSD: report registerable programs in the listener_set reply
      selftests/nfsd: exercise the userspace-rpcbind listener_set flag

 Documentation/netlink/specs/nfsd.yaml              |  55 +++-
 fs/nfsd/netlink.c                                  |   5 +-
 fs/nfsd/nfsctl.c                                   | 162 +++++++++++-
 fs/nfsd/nfsd.h                                     |   4 +-
 fs/nfsd/nfssvc.c                                   |  67 +++--
 include/linux/sunrpc/svc.h                         |   2 +
 include/uapi/linux/nfsd_netlink.h                  |  20 ++
 net/sunrpc/svc.c                                   |   5 +
 net/sunrpc/svc_xprt.c                              |   2 +-
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 284 ++++++++++++++++++++-
 10 files changed, 571 insertions(+), 35 deletions(-)
---
base-commit: 5965280c53faff01983ccf89de70a5d48318f035
change-id: 20260903-nfsd-norpcb-21cdcaf246bb

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

