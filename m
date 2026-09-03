Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 30B719463;
	Thu,  3 Sep 2026 00:04:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788393856; cv=none; b=DjNUL9Cgae9LaY7suIv0dxoBTxr36qUuQyjCKm6hZduwBkphhfsQiZz4tn38lhcN6Fx1umj2To5n8XlwF55zJz8Gfaj+fnMdF1lMLtOyrC2DYcxjybtQkBrd5cvES0G1mDy6f2xaVRXXa1pUziWMsjSjvOQWhs4MI4fSDYvtpDg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788393856; c=relaxed/simple;
	bh=FnKqod29qrbfyQNawdcqOhtqmUfCU92hzzvSmOC6DP4=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=r2sAHRkQoq9nTowXjOxJ9sLzv1rjkruHNPK+e+TyRMQOQODgheoqNuURCxa9jjpY243x0Zvs8uGKrefsNkFWBzojIzVhaE7/WieeCiQHcA4oKuCp+E+gVysEVS0yXV1DCCWlEBnblZhviiPtFMzxTi0Pz2LcwdFdFepzWub3gkw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PU4tdwXE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PU4tdwXE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 74F3A1F00A3D;
	Thu,  3 Sep 2026 00:04:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788393854;
	bh=k1T1mSQt9nXndvTD3GdJspqSLb02WDkXBhGjPz0MRvU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=PU4tdwXEWnj1QSsf0DRmxII7S1wHxWNSJ5LRgOE4heiXa4ZQ4AQUP3KXipmTztYYv
	 4mspDdQHkmHsd/deGUztpi1yo9zfroG8blYZ+ausMy/WqGRWV45ntkq5ODC7W3utNn
	 nEB76oJUgM5i6tsbERunWUrLcTj3i601meY0mSNG3R30F3vGuCKBOVMS080svlOyuF
	 dx2NYkxO31v5a/v608acribWuWQFnFDERyJCGIoyOIW66X9rs4XRltX85l3yxAL+0P
	 C8rPohjb3HH1IFb/UkOm7y8c3gmlRGMxzYWbCwZY27AyVFc0xJ3dWsY+70cfgE/K1D
	 Go19iBIIZrtFw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 7AD79F40066;
	Wed,  2 Sep 2026 20:04:13 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 02 Sep 2026 20:04:13 -0400
X-ME-Sender: <xms:fbmYauQv33tcZIBeNS3WSChoYiYWc5aLSQguQUFnZSW0Riv1H8MVrg>
    <xme:fbmYaukPzfzIHYbp4kCf3toxUMO2dvVmx4N1aK4wZt0lsnGG1tzbGj9rcrrRFYVhQ
    P9bViIh2OA8BHBU4lhHy_JgMItlYDiJ_uWUOxgfqYEBOv-RqSvT_h8>
X-ME-Proxy-Cause: dmFkZTErUHh5BuRVNpnhm4wFZdzcU6Gbef16hK1rlwjUGzG1b1RbSQ89W9JMf+dKlZA/Wv
    reby9HkzPvy/+Kk0QW3WafCg2myqasjn5Yw/IeZxkREKi4I/Csd/ERpzaGq+wnGJbq32nc
    BPO+lrtos2qFL4QqKVPsjb/OwoGeAGKh6Xa9h0GLSgSyciUs2aZOYn/CDBddxzXBY0hiod
    JBmg0dxR0HlPdWYAKm2XUSXGAWVr6wGoIcLlEVPHOVNFfShMWUlnUE3oPfu9qBg0YJaYHC
    76qQ7dMqwd1kFrMLXU5QrlUERuA6vBd0XqRZfCTeUOKNziSQxuVXDWwtxJF+3SroNcV7Io
    66BCRzmVnHoI4XWSL4V57optk336x4nKfzxBQYshtqifqQysqM34YD2tj900hWbtRb0OZw
    ZThpCBev8KeX+F+cCLyK5EvaND7q3nl7Xdw2W85rAiSkC0nB0qIOveshuxiWro34QEtXcd
    jRT9tBECHBYD9kHZomPsABT6YoMUJrm4YlOJhgOoLIFIVIQ8JORyLwCTP6J7ygE9cOaAZQ
    PB0r3prLRaEP0HmxYvxuUsIR/rRzxkXp4h71/t1SUO0mC0GccElBeFvikOZSph9cwPJL6g
    kX9h0GU3flsH19uiJkPRotH8Mrv1t0Jz18GmNVGPaFI7l86fgZLl/F6nxRsw
X-ME-Proxy: <xmx:fbmYajFZpbR4thcbLHSkL1DJ_sywKHeRiJFGTHx4vIoY-Y-iKoyuag>
    <xmx:fbmYatBLXz3fBXL6sRJfAAYtLSMc6R8pMAqOBgaSDGr4txpwoHAZLQ>
    <xmx:fbmYapAKXn1IEP4tkk8ZSIUjvDUWxZqF3nUSkQqA48JDZwzkCmodaA>
    <xmx:fbmYarPSDRl8dBaq9UUWUWY843JuKvXc73F-que28L6z0eHVrpppdA>
    <xmx:fbmYatPVqlQsTcX-nM7BruVi5BCu6kYUyEAvoMPdDLa0C8cgSKLroJcn>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 535147811F0; Wed,  2 Sep 2026 20:04:13 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Wed, 02 Sep 2026 20:03:53 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jan Kara" <jack@suse.cz>
Cc: "Thomas Haynes" <loghyr@gmail.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Message-Id: <3caef4ff-9f01-4b09-8e83-12bcb0a1ee17@app.fastmail.com>
In-Reply-To: <20260902-delegts-v2-0-383cb289ce88@kernel.org>
References: <20260902-delegts-v2-0-383cb289ce88@kernel.org>
Subject: Re: [PATCH v2 0/3] fs/nfsd: accept a backdated timestamp from a delegation
 holder
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Sep 2, 2026, at 2:54 PM, Jeff Layton wrote:
> The main problem is that an attribute delegation has strict rules about
> updates can be done, and that prevents applications that backdate
> timestamps on files after writing them, (e.g. tar -x, cp -p, etc.) from
> setting them properly.
>
> We could fix this on the client by making it always issue an RPC for the
> SETATTR, but that would harm performance in these common use-cases.
> This set allows the server to accept some of these backdated mtime
> updates, by changing how the ctime is handled.
>
> It'd be nice to see this in v7.4.
>
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
> Changes in v2:
> - Split the change into three patches
> - Stamp now in inode_set_ctime_deleg() for a stale update, so nfsd need
>   not compare
> - Drop a SETATTR report that matches the inode, so an untouched file
>   keeps its change attribute
> - Set dl_setattr only on the branch that carries a c/mtime update
> - Compare against the inode, not the grant-time snapshots (Chuck)
> - Set the ctime whenever a CB_GETATTR moves the mtime
> - Take i_rwsem before the CB_GETATTR comparison
> - Drop the unused dl_atime, dl_mtime and dl_ctime, and make
>   nfsd4_vet_deleg_time() static
> - Link to v1: 
> https://lore.kernel.org/r/20260901-delegts-v1-1-9937f7ee4370@kernel.org
>
> ---
> Jeff Layton (3):
>       fs: stamp the current time for a stale delegated ctime update
>       nfsd: accept a backdated timestamp from a delegation holder
>       nfsd: compare CB_GETATTR times against the inode
>
>  fs/inode.c          | 17 +++++++++++----
>  fs/nfsd/nfs4proc.c  | 63 +++++++++++++++++++++++++++++++++++++++++++----------
>  fs/nfsd/nfs4state.c | 49 ++++++++++++++++++++++++++---------------
>  fs/nfsd/state.h     |  8 -------
>  4 files changed, 95 insertions(+), 42 deletions(-)
> ---
> base-commit: ac579868af0c900d8fd9c8cfe9e10db46ccc5a75
> change-id: 20260901-delegts-e91a648f1427
>
> Best regards,
> -- 
> Jeff Layton <jlayton@kernel.org>

Since the series modifies fs/inode.c, Christian will want to take it
through the VFS tree.

Acked-by: Chuck Lever <cel@kernel.org>


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
