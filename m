Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2CBD157981A
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 18:22:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789064531; cv=none; b=qT7UAtUlMkia8cSn6NQQMRN8sm5kbvFua7Y2DfWeFTN+w3rVxwhIRwbtiYIIiJXdLi3tXl9HgPwtCoLUtYGLS+cTZxMoYCL8pxESOJu3ChROKFLGVc8CE6ZZXViykqGwr7ma2sW7NfEsf3+fMK6ValX1ZFU7LGEFewGrT+9cHWw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789064531; c=relaxed/simple;
	bh=ckqggx6H/f+0tDxpRpkezlF28bjTwU+ugWPNOVc9Wso=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=RJjOXTcuUG3Rzd8YhPrNM62dnjk6iotXqSY2yPzw2uIPT7iMvkh//8vGs551F2lEg2AfNbMtHWYJXykNwoYNhVPkzZi0VT8GI2IQWvZN3y6rC5wHkV9cP6GnnPY/4bKq4jpcvS6HA+NrNhSg4DjZjd1P5ZZO7IwG5JVtltmPEuI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=T5C2SWIK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="T5C2SWIK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 42A7E1F000FF;
	Thu, 10 Sep 2026 18:22:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789064530;
	bh=zyCP8GKCer+IhLH8h+9b/eKyLEInmXbvsP3Yhgmjo1s=;
	h=From:Subject:Date:To:Cc;
	b=T5C2SWIKIOvAuk0HOwLmjrXzxtp+6VFIjDhVa/19OnYXcy8ZZL0547GcJQyc+XZHJ
	 aYhU8PQNbDTGjxO2BJAMmDDEFynNcDVyAzeppNMoeufUwk5OSkzTxyMMNRO/Sx9XJ+
	 WYK1BTNJsQ6xgzUJG2+MQ19vc9rGUfiY1Id+pJ2LnSasendC3KtiFCWWek1a5/+FTE
	 7c43OGZLU08YJpt8Y3uQvltxyMH25aFK5BbHgMgtSwrmB9QuJqz5974Zn7e/gjSW28
	 lLTlxd9K5OIhzx0Rog/eoVNwSpGB3Rv7ABjiXEcZH9FN2TeFBtsGvKuEYEzb5KX5EF
	 0o7JqgATFNGRw==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH RFC nfs-utils 0/7] nfsdctl: allow it to handle rpcbind
 registration and deregistration
Date: Thu, 10 Sep 2026 14:22:01 -0400
Message-Id: <20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDSwML3by04pTkkhzdooLkJN3ElGTTRMO0ZKBMkhJQS0FRalpmBdi4aKU
 gN2cFoGrd0pLMnGKl2NpaAHXKk/VtAAAA
X-Change-ID: 20260908-nfsdctl-rpcb-adc5a1fc090b
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1464; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ckqggx6H/f+0tDxpRpkezlF28bjTwU+ugWPNOVc9Wso=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqovVPpmnItxjSrlyPRxRhnkpZKPA1UsUZhmfnz
 kgo6R1e7A2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqL1TwAKCRAADmhBGVaC
 FZtOD/9Rg69TVEJLAjH4cimZMujmlAxRUwCGIhwicF2sURkmDSOb53aHjmeHXxb75TxgiXJNZyv
 bZxoOAP3RvmfQyiZ79YD+VobAPIpB9LRASQJzFJey8LX/QG+f5MayCJLu2/vZ+C6MmnpACOLv5G
 0ARlK/RNNyCUkbez4dI2WDqZ2NYI2lISSENeM88PiYI/oso7cLD9OLayYKVrqqci9+hNOjmoZTe
 6d14/SBil4sRH2gcgbBoBtquKiBEDt3hqyNqW02Vn/kpIMGuhR85BnYJe9RraBDCRqE1he16L3D
 rNHZe1Y4KcDgnJxkuF0tExG0oTA9QyzhpLIu0uV9K9dbqDbQpXJCOeTAq+y1SLF4myaRUS3HlgC
 TiYG8/VIUC29FiIjNYVOOeFQMy262Gc++S3OgWXIWuvmZ+9gMleNO+pjUQi2wEGePfJ5/f7B5UW
 eLhy1yYXdZkFSVv6+7ldMvcEdh/LOMtNnGEuk764oCOhrwMSO2Pfl/INqAivpd9oId6V0/wxK6M
 rqyfIFC0OZ3/7hUlZEw91MAVEdeJxdDYGMDddMjWDycfTsGZ3lKeS/H24qqBn+VBvtcMoW2/DM3
 MXWynwXsJ/L45sZVzfUKll84vrKS9G7MA4Is7SNJDLsVOqJCbjwkphPcOilNaO6uLVtEiSaxIDR
 5pkxYr4431Ohlog==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This patchset adds support for NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND,
which tells the kernel to not do rpcbind registration and to instead
allow userland to handle it. After setting listeners, nfsdctl will then
call out to rpcbind using the normal libtirpc client interfaces.

This is a companion set to the kernel set I recently posted (and which
also should have been marked RFC).

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (7):
      nfsdctl: sync nfsd_netlink.h with the kernel
      nfsdctl: probe the policy of any command
      nfsdctl: share the listener nest parser
      nfsdctl: add rpcbind registration helpers
      nfsdctl: register nfsd listeners with rpcbind
      nfsdctl: clear rpcbind entries when the last thread stops
      nfsdctl: add missing break in update_listeners()

 configure.ac                   |   2 +-
 support/include/nfsd_netlink.h |  18 +++
 utils/nfsdctl/Makefile.am      |  10 +-
 utils/nfsdctl/nfsdctl.8        |  16 +++
 utils/nfsdctl/nfsdctl.adoc     |  17 +++
 utils/nfsdctl/nfsdctl.c        | 194 +++++++++++++++++++++++++------
 utils/nfsdctl/rpcbind.c        | 251 +++++++++++++++++++++++++++++++++++++++++
 utils/nfsdctl/rpcbind.h        |  42 +++++++
 8 files changed, 510 insertions(+), 40 deletions(-)
---
base-commit: 630393e9c73667b3fda6a7507cb5171ec0ec38dc
change-id: 20260908-nfsdctl-rpcb-adc5a1fc090b

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

