Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E0CD5363089;
	Sat, 19 Sep 2026 16:23:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789835005; cv=none; b=LQrAF+haoxGtetQnoQGujje92JvkGLnUuK6iZ92YUvYpaDPuc3+D7g/xd96y/TQ2wIQnfwFhOLWlOH/TG6uxjTjbt9n9L9UTmDom5SWuWACnsQuXvwwui9lpoqGmtEDWrbyxu5AFMhgz0AtSvp08k4RqlY6bKLkAHu4uGTc1FtI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789835005; c=relaxed/simple;
	bh=rCfku23NV4rHOcA4C6xP0o0XxycvahRnuUmJxepMU10=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=cDE1KA3IBfW2R0o99p8uptIX4cvz3x0BFjx+rwOVO6U/3WcSNLKpTV3Emt0ueX5Wkbfwp/w8/ugHnjVgRW5HwYWNgKYpt+d7FXBujykzTIPn7p/CB8xeafkIIh12jsSIYbeSsXSYAem8WtUwqYL9i39GZlTiGozbS/8BbdKddVI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DP6wtNOV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DP6wtNOV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0A6271F00898;
	Sat, 19 Sep 2026 16:23:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789835003;
	bh=C4lRm3RTYNV9mhdEEDcZuzTAV6oSYrE2Pr2mgjuhYUs=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=DP6wtNOViiARae2q4SCrhAyAjFH8KgPwEw8WLAjQbJOmdm/ox8AuLydIJPBO14wzF
	 HFAChnG/jXzQrTMR5ZK6knAFEquuyvHrYDZAwcFqYUvi1EjMCI+X5rzt6VY5ZL/iHG
	 0z1aQ23qMJldHrWn9H92GNf/ye+WhPPjhGW20uydqgrUskzcrrmCuDSoVhP46a2LZh
	 HHBa8M1cx6qDFj4tXSRS6F9xeEjIhmvnHd8Y27NoBO76AWVxuIK516mD/JsaprktZ3
	 MW3uhHSmeYwS9+x6syOn5B9fjrZRnMchpUbr/cu7/vdqI/FfxOlPWDC10YfPkZPNJ1
	 pADuEyXzxvOww==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3CD09F40066;
	Sat, 19 Sep 2026 12:23:22 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 19 Sep 2026 12:23:22 -0400
X-ME-Sender: <xms:-rauao4lVNwNJfYCW_uP-vocWLYXA57nbVKefMKFSueq83qGmQNR0g>
    <xme:-rauaktlCAjPoyAVKnoGlmCs-uiF8aJELr9aOxjX_GfQZ0u0oAvLRmMqOMEtIsfjr
    I6OklI6iYn2IlD3A2gCrUwiQ2TN2N5EtY9AsFQS7-M5cvesT_tPGIK1>
X-ME-Proxy-Cause: dmFkZTEthDnEnTNzGgkWQatgFds47X3LBSfUEYm0c0ZV4go8jNCGUPTrclDhUI/156RFd1
    /El8fx5I9rXFPLoY0rOdO+CyvUB20WNDyuUvNd2rs4whvxrwYkFwqFWAmZgOmYRfacooGf
    Hsno+CrK28XrP4pQiCXO6I6fHLBpX/OBZF+5vqlcEnKmpro4D07Z2TnxgKtKoOSx/EeJDk
    Glh7d3bJXB4TtCB4mrfUOOjA1WR4nLQRvqMBgn54Es+OSfZ189mocfqS/A9z+Kd5oWwiwW
    86mNzGJRzE9jVo6E5PFLeFEEOUwbtSi/ySCoXWBN2XGCZ3xIfVvCq4ajWkUJmBxFEmQimT
    yC+8CFFp++nh1Gpgkl715haFfzOTVJ/BzvU8Gx+DnRZCcTYqkgydL48eoVhKA/T5FilLjA
    Dlt7oirURHzjF0M82ZLTxtGLHyauKFB/8HnR8JfpLOvtcGwV5uM34/lP0Sq+0vVf69FBq+
    maWUY544pdxmFhCrzgofqT+an5vcltd5DUBUZMUVergbT/Ys4m587z0p2E4/sMF0MPt8Za
    GU8LWqsNyXiXI/Ds6McbcCRBFCGuIEnCV9pp+L3pjJJPEXC7iiQJrtRFC+udc9dhm+nkQa
    zbeHlIr8F7p0/KKumF2T33Ufu5AYehf5+PnQLasaD8Sbf+3/hPH8b3AkzhXA
X-ME-Proxy: <xmx:-rauakSPik5hohjS6WVR9oHq5r_BBrZPo3dvSwBB-finccobpzOMRQ>
    <xmx:-rauamrvN3Uo0LBKIxAWvTdijVNQPYe3GQ23koadj-FULtE5n7XeJg>
    <xmx:-rauaqZ07v50s4_DfQGFKTF3emwXKCRee_eK2NpO97SdwAHO-gFQiw>
    <xmx:-rauapQdYCHkzEQghnYFCbsUHPZJVlE3gM29Y4e4-3NHaZQmIXRwqQ>
    <xmx:-rauagd3AzYaAnJtbeI88yDbi6C35PSvLiLIFpVbc0bNx1vNO-i5QQpW>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 1A66E780070; Sat, 19 Sep 2026 12:23:22 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Ak1fuKNIJ_kR
Date: Sat, 19 Sep 2026 12:22:53 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Hannes Reinecke" <hare@suse.de>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "Jonathan Corbet" <corbet@lwn.net>, "Shuah Khan" <skhan@linuxfoundation.org>,
 "Randy Dunlap" <rdunlap@infradead.org>,
 "Christian Brauner" <brauner@kernel.org>,
 "David Howells" <dhowells@redhat.com>, "Sagi Grimberg" <sagi@grimberg.me>,
 linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
 linux-doc@vger.kernel.org
Message-Id: <ebaeb3c9-839c-4ad7-8573-baa68e8c64d0@slotpi15m67>
In-Reply-To: <bbc4ff6f-aa38-4862-96fe-518c3b4df4d6@suse.de>
References: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
 <20260918-nfs-mtls-identity-v1-2-197e568d78a7@kernel.org>
 <bbc4ff6f-aa38-4862-96fe-518c3b4df4d6@suse.de>
Subject: Re: [PATCH RFC 2/5] NFS: allocate the .nfs keyring per network namespace
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 9/18/26 10:44 AM, Hannes Reinecke wrote:
> Thing is, when running within a container (eg a docker one) access
> access to /proc/keys might be restricted, and from what I've
> gathered each container gets its own, _empty_ keyring.
> (certainly an empty session keyring ...).

IMO, neither one affects patch 5. The key type has its own request_key
handler, so construct_key() calls it in the requesting task's context.
There's no upcall, no /proc/keys. It reports the .nfs keyring of
current->nsproxy->net_ns, and KEY_TYPE_NET_DOMAIN keeps a key
instantiated in one netns from answering another. An empty session
keyring is a fine destination, and with no session keyring at all
look_up_user_keyrings() creates a per-user-namespace one on demand.

What does break is add_key() into the .nfs keyring from a container
with its own user namespace. Patch 2 allocates it owned by global
root with no OTH permissions, so a root mapped to a non-zero kuid
gets EACCES. A netns-only container (Docker's default) works end to
end. NFS is not FS_USERNS_MOUNT either, so whoever mounts on behalf
of a user-ns container can provision the keyring too. If a
netns-owned keyring is wanted anyway, patch 2 can allocate it with
net->user_ns->owner instead of GLOBAL_ROOT_UID. I'd like the
keyrings folks to weigh in on that, please.

Regarding the idea of letting each container create its own keyring,
the kernel still has to learn which keyring to link into tlshd for a
handshake, and the serial number in the handshake request already
carries that. The per-namespace allocation decides only who creates
the keyring and who owns it, not how it is named on the wire.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
