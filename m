Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D8B924E4B4;
	Fri,  6 Mar 2026 04:49:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772772583; cv=none; b=H1y7f5fD32ZG30/4i7o2ltRbfcoVXAO8hfGTCfmGjxy1pu5ngr3qSgDR2CHnhR3K4U7vyNC1IS7jUHUmBGkOCAln4jbEeRjDDMcxvH1l+hZNBKcutM0uLEHGhMm7EzJtQ1yNuAe37Kgyu209hQN2gQ8y+E+7JNX6z4ejFbQJ/RM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772772583; c=relaxed/simple;
	bh=qmkaoxpvjlnHqswForYZ+NaU3uZI0yhN3Adw0k9Zv9M=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=MEBa9oI6eEeDWBz3vD1hzCjDM1cet9vlOeR0nHjyoSpLbVgbbXKByIVVkOxIwqEeFXiDsJNnAafItytLEgGvSfhtq8Jc10UQZMKw2zQgNWzBnOEm0R95TrWrWIh2koNm1OsiGULhUYSuvXPsL6MvU/Wt6B/otUIs22/4KAK+BAU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nXq8VeKW; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nXq8VeKW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6660EC4CEF7;
	Fri,  6 Mar 2026 04:49:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772772582;
	bh=qmkaoxpvjlnHqswForYZ+NaU3uZI0yhN3Adw0k9Zv9M=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=nXq8VeKWxoMaFNoJfcAzF8ZUFpz4ZAEzSdNgsazbBg56XxQJJVm5dI4cdkF2HHyr9
	 gUFp3twaPqc8nJ9P95tr8IY8V/Rb3E2zVfCpOAOimv+nIY5JuPtE+cizqwjWfpHiJ+
	 lFJp7UN+E4OHze8k0lfcxl+m7lxoOJssN63lxCVVU3gJVYChnpJrmh2PFvFZQcUOuH
	 5CnHjTmgqefRagCLfoDxe8mXCH0M0egQ1DxMecm8ieuELCDlkS3vIjlOAUQxC+fEs9
	 65plBAZ5aYxu8nugRQ8NcbkaN1KPtfCFtyzwG4a0W7D+a9SElbYmw4HzO7zLo4E7G5
	 3DX1GdQBSpAxg==
Message-ID: <80c9ba69f1d35928ea9d21e146e60f194cff7405.camel@kernel.org>
Subject: Re: [Question]nfs: never returned delegation
From: Trond Myklebust <trondmy@kernel.org>
To: "zhangjian (CG)" <zhangjian496@huawei.com>, anna@kernel.org, Jeff Layton
	 <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 05 Mar 2026 23:49:41 -0500
In-Reply-To: <23b52d16-4b74-43e4-9fff-73ac57c9ef89@huawei.com>
References: <ff8debe9-6877-4cf7-ba29-fc98eae0ffa0@huawei.com>
	 <850dcbf562b7eb5848278937092d2d8511eb648f.camel@kernel.org>
	 <1e1eadf5-fab9-4919-a71a-864aa7109c7b@huawei.com>
	 <23b52d16-4b74-43e4-9fff-73ac57c9ef89@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.58.3 (3.58.3-1.fc43) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Fri, 2026-03-06 at 10:46 +0800, zhangjian (CG) wrote:
> Hi experts on NFS:
>=20
> Recently we meet an error:
> 1.Nfs wait for sunrpc
> 2.Sunrpc send OPEN message and hang the rpc task onto sunrpc pending
> queue.
> 3.Server never reply, and since NFS_CS_NO_RETRANS_TIMEOUT is forced
> and
> connection is ESTABLISHED, task will never be retransmitted.
> This cause procedures waiting on this file hang forever.
> I know using "umount -f " to kill rpc task works. And the key to the
> problem most likely lies in the network layer. But should nfs
> retransmit
> it after waiting for so long?
>=20
> Wish for reply. Thanks
>=20
> Zhangjian
>=20
Please read the NFSv4 spec. It very clearly states that the client
should never retransmit unless the connection breaks.

IOW: the problem here is your broken server, not the client.
--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
