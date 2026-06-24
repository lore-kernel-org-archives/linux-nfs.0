Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 277983016F5;
	Wed, 24 Jun 2026 17:51:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782323519; cv=none; b=scEUztrp6oVaSQpIfZw+OSLb1zZZQL1nhp424SFAlTinJWt4Iz+lXqpdywABPCwKSeTeC88klKTwPCtmln8S8DNTSiRfogVH+XFU3gY8Sl526+uPvxYSqqCzVqXBZL59FYq5JKUmEHnX8SAeQdXpIs9OmGQPrb4Y/gI09vhE3RY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782323519; c=relaxed/simple;
	bh=CA5ak3l9vTUoQLL+5bE5Qbufaf1ip6BNcZQxNtClT+k=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=Hz/Mo/M9hYVtz8Xb5xLK/I4BJ548QH29c5FCzIup9Acg7sgJbfYJPZ3dO4m5ehnsVGJfzw+jlQjOhenC8GW/oyUX5X3rDCku6+OZeaCH0Y3VGyiJ647ZOnjm0QC6FXizQeyNkBpiiIvkLU0wQVdXqCH02CDdg25Q8GMKfHcUThQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Of7NkU7J; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Of7NkU7J"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C341C1F000E9;
	Wed, 24 Jun 2026 17:51:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782323517;
	bh=QVwJSYDqcPJuGDYXzUoAYx4sLhS6CsMZH+ZEt7PmaYk=;
	h=From:Subject:Date:To:Cc;
	b=Of7NkU7J1HT5qCBHC1WLxei7GuR/cYicHMDW0KPUj999UAGbRlAMWMVlGApmCnsao
	 vWsFU6aaMSzcRZ+Bu0ARgHkYLf6cJ6WUuWKYIKiMYblN4IhQP4P/y8Ju6fGw7sN1iA
	 k4ZzIqDu6xnqc/KwJc+4KgM54344HzCX4l4ov7nvKSG/3nypu1eGIZvNIMpMWJnCuG
	 VY6lV6WqkYZjZb8zLTSMENe4ZVsFmiDr7l4NldeDNNdAVbtSgoQBVrmTziePyc6oT+
	 32eaA2K617wTMKbm2g5TdCUmaEtnBhz6u7mOTBOyHqbL1JDyMPZ0e4lRkLuI0LZBY0
	 15h+5gKGfGoOQ==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 0/3] nfsd: inter-server copy fixes
Date: Wed, 24 Jun 2026 13:51:42 -0400
Message-Id: <20260624-nfsd-testing-v1-0-b8853eb22e45@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3MTQqAIBBA4avErBP8Q6qrRIvI0WZj4UgE4t2Tl
 t/ivQqMmZBhGSpkfIjpSh1qHOA49xRRkO8GLbWTTluRAntRkAulKCZr5iCVM0Zp6MmdMdD779a
 ttQ/FPexkXgAAAA==
X-Change-ID: 20260624-nfsd-testing-8439f0163312
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Andy Adamson <andros@netapp.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=717; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=CA5ak3l9vTUoQLL+5bE5Qbufaf1ip6BNcZQxNtClT+k=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqPBk1aYFcpKj76Y1jK98tQ9485MXaF0hbs0k74
 +o8WShrn66JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCajwZNQAKCRAADmhBGVaC
 FdnxD/4rTJM3hq49vZaG8pXsiwWvcOZpBLBnfeIvIvqG83yS7NjPUbYN6jZnhHbODlNYeDLRssU
 a5hw2unDcB2yiPKcWjxQm0FzXOzqUCCMqlXxJP5hRQgL5/X0EwUqJwdzPLrRPqI8VmgIlUSQ9z9
 3/96/GoXuQK/6Xi+JTQhZfIO46ywRXWF7AxvsyTqBSeOcMHEf33vVSkz2lu5az0EPXxCsQ7ZqMN
 7lEQmtKbFGgu/s/EOkBmlOCYwBgilLDdjk2Kca+EkWiShykS4f0MtE1Y1SToEBo3eWuP/ka672e
 A4jh10xIGRhO+3mf1iq2SmllCQMC4IJqpv1NlUghvXQUd3bQP/174OHqkKW/P24aC+iySg9XDpO
 0pErdjwSJLaQnXHp41EQ3zm22tMrX2XvOtP1IsNuwL2ML9HqAyLMAn+tLNmhmhtmGZPxGu2BAO7
 Ywd9Ev4UoR2cy942Y0zfsN48li3Ss5xk8siPdkb/ZBXfvzRHiFe07cfgNMf+lnbVUTXI2vB+C8g
 YRAcIbf3GZovQ6pCH2wUZfFoxkvQezUYLADfgOQzOW31s3ItHpjc92Y9HwgZZFIHmoh3derRYBQ
 L3cRhAANeXTZ7vZLQEILV5gOnruLiaY8kdUg66TLpNu65rRafRDQTcMpmhWhoIvfDnmRELj4GkI
 2cC2BrIYD8NHWPA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

These patches fix bugs in inter-server copy offload code noticed by LLM
inspection.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Chris Mason (2):
      nfsd: fix cpntf publish race in nfs4_init_cp_state
      nfsd: fix UAF in cpntf statelist drain

Jeff Layton (1):
      nfsd: fix UAF in async copy cancel and shutdown

 fs/nfsd/nfs4proc.c  | 100 +++++++++++++++++++++++++++++++++++++++----------
 fs/nfsd/nfs4state.c | 105 +++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 164 insertions(+), 41 deletions(-)
---
base-commit: 2bb83225da8ee0383d17783b5c903589696faf90
change-id: 20260624-nfsd-testing-8439f0163312

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

