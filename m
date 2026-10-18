Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 93DBB41BA69;
	Sun, 18 Oct 2026 21:02:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792357349; cv=none; b=uq8QTgDfEYv8Kp6iwOrfRMn2DJjVBNgCSanoA+nDcVmG8+LUA7Payxb69sT3pu+0OGt0oKqqo2oqtZmAOjSb870tOgLxl54OH3kKmuJpEUEnotR/DTRmII9ZJ77mORavRC7Pv4WwI278V+RRLRoxUNVXp2cyyXixflxDGHl6pho=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792357349; c=relaxed/simple;
	bh=+LAnEU6qsVNyQhYvAmAyc4CEOpHcSxtjMfXcgVED7n8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=DUVN60JR2DYiCHO6ckLhssgdH4rr/Mxzr5oJ24MXSXjppbWsfvbrAyC89lHLRcqve5NaEg+cGRKmMciE0HkJ0VApFb6PkZhUxVF1/uFz/2siPYk9thsLvLxOPlNmc2p/F+kBrj0NvLNG8SWtkqzGJJmmvBxHRI/0phpXxZyFjjU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EQFtakhb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EQFtakhb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E21B31F000C5;
	Sun, 18 Oct 2026 21:02:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792357348;
	bh=H7Y9ThppzfrV33D7sGdW6+UwLbobaDsHQokLbYYwjPU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=EQFtakhbCUEHbwvCm8U+Gf6OW+ckGwdIoDky03Cetc90gPjOr6UgR2pavGx/KVnby
	 renSiQ5mbKU0XzqxWuAe8OVUQgL4Q8VxvT+zuvFPPm1ZR4Ehi3fdY7jWv3zBMC127p
	 XtS09V7CNzkiFRT3pS5VhGsWPvv0lVqdxaVuqm+tB3s5wrY9LeNQOBGS+F6jiU5Kgq
	 aXpNVAgxC9DjrRwW9X549KgTC/aU1jH6Zqz2f/fasOoCkhvrBXhq+7pU7HYZY2z8R+
	 E7WJAIuT8wYl0l5e/lmWN4vxTF0FDTTQ5yGo7XhemWV7CroA4Gmfh11ldlUmVL5ZmF
	 Yb2+siOXm+0Iw==
Date: Sun, 18 Oct 2026 14:02:22 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Jan Koester <jan.koester@gmx.net>
Cc: Christian Brauner <brauner@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	"Serge E. Hallyn" <serge@hallyn.com>, Jan Kara <jack@suse.cz>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Paul Moore <paul@paul-moore.com>, Arnd Bergmann <arnd@arndb.de>,
	linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-cifs@vger.kernel.org, netdev@vger.kernel.org,
	audit@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 09/41] uidgid: let kuid_t and kgid_t hold a UUID or a
 GUID
Message-ID: <20261018210222.GA9623@quark>
References: <cover.1792346472.git.jan.koester@gmx.net>
 <9c17a1f7f82b953e6f4d9e17f4ca19d5220d7f2b.1792346472.git.jan.koester@gmx.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9c17a1f7f82b953e6f4d9e17f4ca19d5220d7f2b.1792346472.git.jan.koester@gmx.net>

On Sun, Oct 18, 2026 at 08:01:30PM +0200, Jan Koester wrote:
> Make kuid_t and kgid_t (and vfsuid_t and vfsgid_t, which share their
> layout) tagged unions: a classic 32 bit id, an RFC 9562 UUID, or a
> Microsoft GUID. KID_LEGACY is 0, so zeroed memory still holds the root
> ids, and KUIDT_INIT()/KGIDT_INIT() keep building classic ids, so the
> bulk of the kernel needs no change. The member is renamed from val to
> legacy so the compiler finds code that peeks at it directly.

Most Linux systems aren't going to want this bloat to the core uid and
gid types.  So if this is supported at all (unclear it's worth it...),
it will need to be controlled by a default-off kconfig option.

Side note: the subject line says the series contains 41 patches, but it
seems only 11 were actually sent.

- Eric
