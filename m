Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795192820;
	b=zeNoIulsevLN8CGBcE6qM0K4PbNz96JD586lwgpg78zybbJ49uTQT3yOtFmB9m0Z5doD
	 nNdvE3y/iM8A17g+EuC+me8kjSiRCnMSwbqs/5HzmLR9Uw2hc51kJuVH342iVsp15qDuP
	 qJZf/1VDHFPQo+ARonDia4X2Uh6tYZ0vXnCQUX6I4Ndm/4OwuL36hOhU7NWm8wZt5jyNL
	 fiIUYdgwlzzelpC9tSoEIR6nxd8Onj4uhSQKtji7WkTf0oySjL72zJo4nAUFJyJVtcO1n
	 28C+UNryh2+8LDZyhGG93e+26gvwjLb2O6aOFQIpfmVgk9Sv8HfimeiFBzd9czzWXkg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795192820;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=xesCvcOfHmixpYoK/84G84NGmb2HuocgOZAE/mmf3OE=;
	b=syOL2TztXXbud3UowR+lMxhkrwA9azP4sm/yJOAlO96OpUMJM6vkgB44YpdMlMhGq/oM
	 GCONj4zfhGyihaGp7iNj0Jmca5T9j1UmpRdPDLU6hvwcSpM9apLGr6mRWvNY7S6wMf8T5
	 UVFbAQKPpKZLPcPwPQYhS7KGqMONQe3dJbt4s41UuH3TtFCiB6G7WuuUaH1RVETSfff1/
	 c3CcPLyzDQvAXMN3+CBWGVnE/wWvCoyNf7G+7bw0ffHHhun5HB1krAh3Sq/lOgWC9nJ3v
	 clxPS9KE+nWKTnKZq+aFo9mXg6TD7WbgrGCa6btQR90FVTvGTPygGkcp5K8p3vEcsFQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="GPoJp/7I";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5971960A2619;
	Fri, 20 Nov 2026 16:40:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GPoJp/7I
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3FE3D1F000C4;
	Fri, 20 Nov 2026 16:40:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795192819;
	bh=xesCvcOfHmixpYoK/84G84NGmb2HuocgOZAE/mmf3OE=;
	h=From:Subject:Date:To:Cc;
	b=GPoJp/7InDSFz3goEHmwEk7hWJRkmcw5UCTMQS2smGQhNBIxy3NI2bw6FN3SbNxj0
	 QirXvk/NJB5WhYVli0/kvOJ8o1dymH+8E028s7gEVqWjob+E0O++r9WqsEubnxAUuY
	 9+B2fG5xEjPoATwhblfBeSWODozXe8vHYYOK7O19331dvkC7gJjj3VNLLCZ0iP9dlN
	 V2E1dLfcyLqKhEUXyQSTjpoieuHcqHxlvSl1mNdd6FCAHcQ5BTxV+FQD90XTc1cZxu
	 QHihiM2LIU0oB3YDFSv5QtbE6+5hRlgieOCqsoNm5DRutdyrVACLd2en4wV7qVxJ4a
	 9YaGZLQPw7AhA==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 00/11] nfsd: various delegated timestamp fixes
Date: Fri, 20 Nov 2026 08:40:06 -0800
Message-Id: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3LQQqAMAwAwa9IzhZMC2r9ingQm2pAqjQigvTvB
 o/Dsi8IZSaBoXoh083CR1JgXcGyzWklw0ENtrEtom1MoJ3WS0zkh8R0vncOg8fQR9DnzPQHXca
 plA8ns+2DXwAAAA==
X-Change-ID: 20261120-delegts-fixes-798331d91d8f
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1762; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=1sEtxVu0mZF98M1vBhgeeuAJBFYhgx/F3jfGnMDxkD0=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrAHfq/DLk/wSbthPXIdMlB+gWYfQsKUF+h6EyW
 JR4H/EEajmJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawB36gAKCRAADmhBGVaC
 FR9ID/sFmkinlN53S8m+ST3viIbQKz51MYKQKTnuYfndtEW7jyui5UZ76az2ueLF+EIPh6doVpv
 Nw6Utboj/7WzikoS7vCmlhMLZeEnPnc3vn/+VduowdV2huGiCxvAsTgWmZzF+3qRz5J3PYcRZwS
 1qv2bg+52b43Xtgqy4mJxk59mYMFCsZ+VKC6opFMaq+WG0nc93ku1ja1sSzNig0AbqaOtC96SDj
 IhHwFj80fe8u39+HPYPA38Ute8OkQGbqrRb++f5au9sbDJ+hKQnxwCVyDUWStaZAsB8BET8p/N8
 3eR42XHEY8Xv7+yQrepNVb7wwPnDGQW7eLLTB7+QFmtkaTsMrxZpSw31Jy9B+OhtlVb4hjCpw/W
 55qMN5OGY4mfsBTyLIuPn+xDNmeMh3uNverozZ9UvGJ6PBtPDvGpHqAJ5Ceu4EyA1I9JTII18am
 LIgIEwltZIwPbcle1w5sOiOzIwiJTWyjiJXYxVC4nmTi9h0Jplmw0YbfnkblZqapwTRBaCrm43d
 xMm/q9ZljSM8e1mz1EVXvgTqdmCnstUz7MDYVAdXiwY+GakiZ7Zf3qKIcfiWMDHT0ULFeUVQOpl
 GedcgzyPUdj4rmNn2+uZqTcjQrwPHblaKmsbj09icez18jxv+MVpQ90RaA8xlsdmqTBe+bKUk5s
 G51HzKYM5YAY2kg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

While working on a rework of knfsd's delegated timestamp support, LLM
review pointed out a few bugs in the existing code. This patchset
is a pile of fixes for those issues.

The rework of the delegated timestamps is still a WIP, but these should
be able to go in ahead of that.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (11):
      nfsd: don't hold inode_lock while waiting for a delegation in nfsd_setattr()
      nfsd: take freeze protection before updating delegation timestamps
      nfsd: count a delegation in cl_delegs_in_recall only once
      nfsd: don't grant write delegations to NFSv4.0 clients on CLAIM_PREVIOUS
      nfsd: set ctime when a SETATTR with delegated times changes other attributes
      nfsd: pin the client while a GETATTR holds a conflicting delegation
      nfsd: recall when a CB_GETATTR reply omits the size
      nfsd: apply delegated times in a separate times-only setattr
      nfsd: grant a plain read delegation when timestamps are wanted on a read open
      nfsd: check fi_had_conflict under deleg_lock before hashing a delegation
      nfsd: take the write delegation grant stat before hashing

 fs/nfsd/nfs4callback.c |   1 +
 fs/nfsd/nfs4proc.c     | 165 +++++++++++++++++++++-----------
 fs/nfsd/nfs4state.c    | 249 +++++++++++++++++++++++++++++++++++++------------
 fs/nfsd/nfs4xdr.c      |  55 +++++------
 fs/nfsd/state.h        |   2 +
 fs/nfsd/vfs.c          |  56 +++++------
 fs/nfsd/vfs.h          |   1 +
 fs/nfsd/xdr4.h         |   3 +
 8 files changed, 365 insertions(+), 167 deletions(-)
---
base-commit: 8489270d1cb9568fc88f3cda4626a19807300d77
change-id: 20261120-delegts-fixes-798331d91d8f

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

