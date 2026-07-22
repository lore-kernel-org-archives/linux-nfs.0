Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0A6935E958;
	Wed, 22 Jul 2026 14:37:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784731071; cv=none; b=GTQM2J0CSyYzhzVBAkmE9twz9nHjD4nEHxz6Vf9HVeAC09HgU2PD61KRKk/mmRo0mn1KwuZwRYWDgRF2C8zDvE5jly2aiqeuQT0tXeqvKFGwQHIn2RkQAgtEI4yCGqEv2ySJqwp5MMnyZRGnBZRoWQZnVk1rKywCrLVBFDQV8zk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784731071; c=relaxed/simple;
	bh=jxe97xdQ5U6P6rnHmb+6ocNuaeFwjzqLFGnccS2VMd8=;
	h=MIME-Version:Content-Type:Subject:From:To:Cc:In-Reply-To:
	 References:Date:Message-Id; b=E/TPAYoNIf71ghbIZ3TTmx6uRQbPMOSoazfEHq9l+DWAFo1hz3nrcNclPY7PWTUjIWC8t0MxfsdOjwKYXj23kLYJk66fLb6CiQikh83yRuqD2ps7Il3nFSV0z91SHe/tHUoy71MGs+EqjLPZ8M5MZm+JKI64WC6FjG6oQIMUj58=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Rq4F1yqh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Rq4F1yqh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BDB3E1F000E9;
	Wed, 22 Jul 2026 14:37:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784731070;
	bh=d6IBNOYXIHaaaw5xlyIPfBiwUHwiELmrQj4t5QsLZdI=;
	h=Subject:From:To:Cc:In-Reply-To:References:Date;
	b=Rq4F1yqhRcYHWAKuFBN0vELPLyeHDd4ht2Frz7e5COlBvZha9jbgNUmyMqyVdfE2S
	 +exeHlIMZT54nGwdZ0LsVbKUJwaJY5ikMtwCh4qUDRinV8CUGHx11t/ScRWGRfALg2
	 xSqyhn1x8SioFI0VDettzIrRFe5EBru6N7ereCelMLgCO5Eht9NnF4ls2vP6tZKeim
	 t2PIbg3CW+RI520oednmIoUxpWocyzH0Qv2fbo1mImpwqrcdx/YY6NghoTf4GoHxuk
	 66eWgdMkIb+bOFlJOf77MrDz7jCjJls3l4m8xCPu/iVucrjB2Wcux+9woCW7pOakOm
	 5kZcqvafPB/Mg==
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] fhandle: handle detached mounts in capable_wrt_mount()
From: Christian Brauner <brauner@kernel.org>
To: Guangshuo Li <lgs201920130244@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 Amir Goldstein <amir73il@gmail.com>, Jann Horn <jannh@google.com>, 
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org
In-Reply-To: <20260708130648.767811-1-lgs201920130244@gmail.com>
References: <20260708130648.767811-1-lgs201920130244@gmail.com>
Date: Wed, 22 Jul 2026 16:37:44 +0200
Message-Id: <20260722-linden-lehrinhalt-chorkonzert-18db330ae530@brauner>
X-Mailer: b4 0.16-dev-2f6f2
X-Developer-Signature: v=1; a=openpgp-sha256; l=929; i=brauner@kernel.org;
 h=from:subject:message-id; bh=jxe97xdQ5U6P6rnHmb+6ocNuaeFwjzqLFGnccS2VMd8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWQlXN2tVqzLtHumXRvjT/N/QoqaP1dKfJb1MXOeeOzQD
 XuJ7PXzO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACYSqM7IMMnt6Ie09S6Rtaq/
 LrFk9T09v3e2r/710//Zr1yPu7RYPp+R4dj/J3pfCqNv+n57YCinKPHoa3nvO6+/DTmqqbn+33X
 2cQMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

> The change referenced by the Fixes tag protects the lockless read of
> mount->mnt_ns in may_decode_fh() with an RCU read-side critical section.
> 
> That prevents the namespace object from being freed while it is being
> used, but it does not guarantee that mount->mnt_ns is non-NULL. A mount
> can be detached concurrently after is_mounted() has checked the field and
> before capable_wrt_mount() reads it again.
> 
> If capable_wrt_mount() observes the detached state, it currently
> dereferences the NULL namespace pointer while passing mnt_ns->user_ns to
> ns_capable().
> 
> Treat a detached mount as not capable for this permission relaxation and
> return false when the RCU-protected mnt_ns read yields NULL.
> 
> Fixes: 40ab6644b996 ("fhandle: fix UAF due to unlocked ->mnt_ns read in may_decode_fh()")
> Signed-off-by: Guangshuo Li <lgs201920130244@gmail.com>

That's already fixed upstream.

-- 

