Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D83BC3E49EE;
	Fri, 18 Sep 2026 18:00:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789754462; cv=none; b=llx2VLncML3fW6lHybkNVJq99Hz9X/hKieHbS6P1rdOT3NscwPopvQEHGrQ/EBeYiAJns4s+lSRLd7QiFirBU/5HH5rdNP1VHuQXHaZRApLf5nuH681CQ+aFNoJqxv073itMneMpQerTCL5jazrIFIurnriOpKTJCqSpzBL6mvQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789754462; c=relaxed/simple;
	bh=rJyMtUJox/zyLLceCJ+E/9zig5jRcd6wrkw+gkeFTVk=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=N1fS3SIA/uh+U/zW18qcMjjMHHpq0LUCqH1j2fqqzd08UYL274rYMddUYLDBsomjnd6H97Ae/KTcOj/wSQvTRN7oIpe42iP9LZ9+ezoCrcE0kiz6PmPsg2TvWrAR332ZVRJp44ixjwXc1gD/B3l2tb/K6Cj+ciVb1l0KcAhXiYA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=ah27XptP; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ah27XptP"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:From:References:Cc:To:Subject:MIME-Version:Date:
	Message-ID:Sender:Reply-To:Content-ID:Content-Description;
	bh=uW1VwXS9fnIR2k80j0oeOq/Eg+v68xwf0YIr/GHAino=; b=ah27XptPg/UpFLncJ2jfdOhvuY
	S8VC3yxm6tvsaUu3uqutjN+mHpnnpZdDkT/s9QKcz64kM72p+CAXPI8QCZonnwxcAi7B8D/YHq8O0
	dv0L36H9PSG2i56YRA0v7O9vjGO3079Q3N7CNBreE6vqJdeGgUkfSDhGXHWIcbjl84DqZZ2GWt8Uj
	H2Zer9PzYvCDoVUqGoTHlk0AEF85SWrm8L/3yEXl4YxO5pFXFGEhPimv7YYy0lpjgafUJpmxBttTo
	cJTsJW/LbtjM1OTB9lRQG5bTECs38ILBvqqOZSqnRvqXdnJbK1TvB2w1aq0XgmeVNpIsd6g8ezrN1
	qbGffjlw==;
Received: from [50.53.43.113] (helo=[192.168.254.34])
	by bombadil.infradead.org with esmtpsa (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x7ctK-0000000FF51-2Tyj;
	Fri, 18 Sep 2026 18:00:54 +0000
Message-ID: <8d635404-f85f-48fa-817a-88d3c1ecd344@infradead.org>
Date: Fri, 18 Sep 2026 11:00:52 -0700
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC 5/5] NFS: add a key type that reveals the namespace
 .nfs keyring serial
To: Chuck Lever <cel@kernel.org>, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>,
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>,
 Christian Brauner <brauner@kernel.org>, David Howells <dhowells@redhat.com>,
 Sagi Grimberg <sagi@grimberg.me>
Cc: linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
 linux-doc@vger.kernel.org
References: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
 <20260918-nfs-mtls-identity-v1-5-197e568d78a7@kernel.org>
Content-Language: en-US
From: Randy Dunlap <rdunlap@infradead.org>
In-Reply-To: <20260918-nfs-mtls-identity-v1-5-197e568d78a7@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hi,

On 9/18/26 7:05 AM, Chuck Lever wrote:
> The per-namespace .nfs keyring is linked into no keyring that
> userspace possesses, so a tool that provisions x509 credentials, or a
> mount helper that searches for them, cannot reach it. Every keyring
> operation from userspace takes a serial, and nothing hands this one
> out.
> 
> Register an "nfs_keyring" key type whose request_key handler runs in
> the caller's context, without an upcall, and instantiates the key
> with the serial of the caller's namespace .nfs keyring. Userspace
> reads the serial with one request_key() and one keyctl_read().
> 
> A keyring search runs before the handler does, and a task keeps its
> session keyring across setns(). The type carries KEY_TYPE_NET_DOMAIN
> so a key instantiated in one namespace does not answer a request from
> another. Its preparse accepts no payload but the caller's own serial,
> so a key planted by add_key() cannot misdirect a later request.
> 
> Register the type after register_pernet_subsys() has installed
> nfs_net_id, and unregister it before the per-namespace state goes
> away. unregister_key_type() waits for in-flight request_key() calls
> to drain, so the handler never runs against a freed struct nfs_net.
> 
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  Documentation/filesystems/nfs/index.rst   |  1 +
>  Documentation/filesystems/nfs/keyring.rst | 67 ++++++++++++++++++++++
>  fs/nfs/inode.c                            | 94 ++++++++++++++++++++++++++++++-
>  3 files changed, 161 insertions(+), 1 deletion(-)
> 

This might be a locale thing, but using serial as a noun here seems
awkward to me.  Is this like "serial number" with the "number" omitted?

Serial as a noun usually means a publication in a series (TV, comics, etc.).

Or is this some special security-related usage of the word serial?

> diff --git a/Documentation/filesystems/nfs/keyring.rst b/Documentation/filesystems/nfs/keyring.rst
> new file mode 100644
> index 000000000000..5b3d3d0f5f91
> --- /dev/null
> +++ b/Documentation/filesystems/nfs/keyring.rst
> @@ -0,0 +1,67 @@
> +.. SPDX-License-Identifier: GPL-2.0
> +
> +====================================
> +The per-namespace NFS client keyring
> +====================================
> +
> +The NFS client holds one keyring, named ".nfs", per network
> +namespace. An xprtsec=mtls mount presents the client certificate and
> +private key named by its cert_serial= and privkey_serial= mount
> +options, and the handshake links the mount's namespace .nfs keyring
> +into tlshd before tlshd reads those keys. Keys placed on the .nfs
> +keyring therefore need not grant user read permission: tlshd reaches
> +them as a possessor, and a tlshd in another network namespace never
> +possesses them.
> +
> +The keyring is owned by global root, with KEY_POS_ALL and KEY_USR_ALL
> +less SETATTR. It is not charged to any quota. Keys added to it by
> +userspace are charged to the user that adds them.
> +
> +Finding the keyring serial
> +==========================
> +
> +The .nfs keyring is not linked into any keyring that userspace
> +possesses, so a serial is the only way to name it. The NFS client
> +registers a key type, "nfs_keyring", whose sole purpose is to hand
> +that serial out. Its request_key handler runs in the caller's context
> +and does not upcall to /sbin/request-key.
> +
> +To obtain the serial, request a key of type "nfs_keyring" with the
> +description ".nfs" and read its payload::
> +
> +	id=$(keyctl request2 nfs_keyring .nfs "" @s)
> +	serial=$(keyctl print $id)
> +
> +The contract of the key type is:
> +
> + * The description is the string ".nfs". Any other description is
> +   rejected with EINVAL before a key is allocated.
> +
> + * The callout info must be present. request_key() with a NULL
> +   callout_info never invokes a handler and returns ENOKEY when no
> +   matching key exists, so use request_key() with an empty string, or
> +   ``keyctl request2`` rather than ``keyctl request``. The content of
> +   the callout info is ignored.
> +
> + * The payload is the keyring serial as decimal ASCII digits with no
> +   terminating NUL. The return value of keyctl_read() gives the
> +   length; a buffer of 12 bytes is sufficient.
> +
> + * add_key() with this type accepts only that payload. A key carrying
> +   any other value is rejected with EINVAL, so a key found in the
> +   caller's keyrings always holds the serial of the caller's namespace.
> +
> + * The key type carries KEY_TYPE_NET_DOMAIN. A key instantiated in one
> +   network namespace does not answer a request made in another, so a
> +   process that keeps its session keyring across setns() receives the
> +   serial of the namespace it is in at the time of the request.
> +
> +The serial is not a secret. The keyring's own permissions decide what
> +a caller can do with it.
> +
> +Provisioning credentials
> +========================
> +
> +Add the client certificate and private key to the .nfs keyring as
> +keys that grant no user read permission, then pass their serials as
> +cert_serial= and privkey_serial= mount options.

thanks.
-- 
~Randy

