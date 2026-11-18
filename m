Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795012667;
	b=TOpHp0B01jp3NDinsU1hUJ+xbHzp48/+HJvNECf1mKiWLUcfRJS4TwksN5nNwd12lVbY
	 xrsr9Nv1u6jQsH5gBYXQ9KyUouniyrm4l+DvD9YEy5HdCMxeuWfYNUhz2Olrx19bXyDrV
	 XwE1YiANurh+42cpjd/SzJoBFL22n0EiWs6KJWxDM4NsUmZtIgzZiaSuiagTpgHindUaJ
	 okCjl9QbXAwi2EkdNDtRT30542wP5gwRQmgDhoeQLDErm8q9toBlBe1sxlYIPushUK4C0
	 6wB7t4jeZetsolqsRvSCjXDeLKkbW7dHRfof7YviOSg1ZtSOAjPklTuNaVFLtpAzJYw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795012667;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=TGCJR4zjTobiyQoKxWsb3iZGFyjLJLrqRE8qO4niVBM=;
	b=GFzga564wFX4Uhi/oeojPR76z4wydXkAt0SfjCs1GY6d7/pB+RGI3TUNNbWZx8cZbxPC
	 p+VEHHNxB02eJyq2yHK24DuCxzyedWVJfBMKMETkqXOZS1szN7mEwfH96ETiKfHYDOr0J
	 afSBhlzCymy0pfOqOjDQNT4Zvq5uFc4Bf/qHn88WqWJ5P4Z6M7Wk9TmqwlEcJMUq1Qeo+
	 KG9s6ovUPMM6hTvuSmruCGw4/s1xuhQ1hi8KZQeTOXBBnVN4YDAoEJ7SvTMqGC+uIdPQd
	 KdwO+9kP4lXGTs562LaJ6l1FIKlfBtVF7GxXrCcibzhC5Y5HkP2GsdwV9TgvWGmga6A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oDYEomrR;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 466C2606A33A;
	Wed, 18 Nov 2026 14:37:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oDYEomrR
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C93221F000C5;
	Wed, 18 Nov 2026 14:37:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795012667;
	bh=TGCJR4zjTobiyQoKxWsb3iZGFyjLJLrqRE8qO4niVBM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=oDYEomrR5K3bZcWLm0BHnYdfLDrjEtOk4qUHQdu5CunnSlo0oFC3UsTYO8jE6lSD9
	 F76UQG9vImqYqTbWD4XFluTG9540X3UfSEV7J1IT64rV791qG1V2aqHWpj2eEEXC80
	 iFydZyWoqcURurJ29XPW1uomDD2wxiQwUKBkJ5jfol0bPu8oLrFNC363+LZZX2JFlu
	 0lXrP6f+PZS9e0YXf/Q420vdQpjiKNUXdG+Xv74ttt6RcsPu1J2bvoCEeueGIWZQCF
	 tlV858zc2JvxAAm2a7OE3YiHHYM8K2EvdjxcZ3zacFENgUmwAKsSqNYpQkGHkF2c4l
	 yOe5ZJiJNSy0g==
Date: Wed, 18 Nov 2026 15:37:40 +0100
From: Christian Brauner <brauner@kernel.org>
To: Jan Koester <jan.koester@tuxist.de>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Paul Moore <paul@paul-moore.com>, Arnd Bergmann <arnd@arndb.de>, linux-fsdevel@vger.kernel.org, 
	linux-api@vger.kernel.org, linux-security-module@vger.kernel.org, 
	linux-arch@vger.kernel.org, linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-cifs@vger.kernel.org, netdev@vger.kernel.org, audit@vger.kernel.org, 
	keyrings@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v2 00/41] UUID and GUID user and group ids (*_r
 system calls)
Message-ID: <20261118-erleuchten-mitmischen-vorrecht-254c957863e1@brauner>
References: <cover.1792552161.git.jan.koester@tuxist.de>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>

On Wed, Oct 21, 2026 at 05:15:20AM +0200, Jan Koester wrote:
> - kuid_t and kgid_t become a tagged union (legacy number, UUID, GUID)
>   instead of a u32.

Oh boy, I'm not sure this is going to happen.

We are going to extend kuid_t to 64 bit for cells and isolated
idmappings. But it stays a plain integer type though. Turning kuid_t and
kgid_t into 20-byte tagged unions, adding a parallel *_r syscall family,
a new POSIX ACL xattr format and new procfs fields seems very very
unlikely.
