Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 693373B101C;
	Tue, 29 Sep 2026 21:24:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790717090; cv=none; b=JSYq6FyxO0bfX6fMBCp09MagGgXMFepQv448x9ftSxThFNSwghTc8J/30rH63K4eae8g71e5ZYASU5q18d9Xgg6DJTDGJyu0SuIc+TBNQc+Ewcoks/96maaIqvHQupDb5pBHHj/B9wlUoW7D97s4UfhxcEkoADYjFCHqjhT7xdk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790717090; c=relaxed/simple;
	bh=hl/GJq+lBD80Hn/PMYx2ViilH0jQaejr1LEgM8N0frA=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=nQzvRgcPfb8IbwKpjSbuaIH9zcMlJjtlZoUzXDILj9JsQehnaEsHQYmEvxWLSLvLUMxD7G0vEDh9KiFeH9bPXPxJCHGreSirB8Eb0xEYO+ytDeyo18sAWGds/qQiA1aYjtxvnBFfea241LFYtbn23j6p8GjyANveUQYgYZjhxuU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ctj7u5wo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ctj7u5wo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DF1CC1F000FF;
	Tue, 29 Sep 2026 21:24:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790717089;
	bh=xrUvbY2XS9zfmj593JZTmLqFqRTgjCWGJ4x+Rrl6zwg=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Ctj7u5woYiswL4CpuhbxlzRiM2H9NAHfrGWOvo/pDYZJI3eKOy/gqbjDnnE5gg1dh
	 FtvoR593w4HcTf8cnu6U1Os0QzZtQ5m5FfFDcPltbuLk5U2eMuvGKcJJAoD6eXW1XA
	 NkGBYNnzBYdgP1qi/R5pycy64TFPayWqegpxYkLJXrJg0vIQ/2MPmmaozAF1rdX0o9
	 oRrirBxdbebHOLS8mf5hOdy8MamP8XPQmvjOAUpDiI87+Skymf4OYGb46Hq4VKsPys
	 M/j1s7JikWKuudPv+4KrCW0uKmNntOLFvFOxIRrtvDhghKVGVjWJ3k0htZ0WiwCOt/
	 IvqTp2io4hygg==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id E7581F40066;
	Tue, 29 Sep 2026 17:24:47 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 29 Sep 2026 17:24:47 -0400
X-ME-Sender: <xms:nyy8ajUGHxxkmrO8o9Ab5bEq3_iMhsRq9bbFPsx2HPNR3N_tpx2pGA>
    <xme:nyy8amYWNGPOtlELasc3wmTEXOuWadrc_-o7Z-8ja6zSnmO8__p71FpzGsaRNFBuw
    cY-1Hu27sr2QggmSlHQPBiIHkf_XkADfyNXOcxJA28YOG6T5GKPv2xo>
X-ME-Proxy-Cause: dmFkZTEDV3/1yCe+FQo+fajx7AqOIr5Rxrx3oIgqUFxFLnj0QtPLZEH8zROozvhnMD7F/z
    bxLh2IuyMIL/XFrFtL85b172Pv70LA4koJij1gAHBougsg20/EGxhfDwp9eZHd0SewJgFV
    ut76SDPp5jQjxDbA0x9nKTNLzMdN/gk/fN/3mNXiQQcw4ID0b97l5sEsHIdqTt4UJ6wBDv
    M2OLSORoquyKzLfw2+GZwznTxEsHUpNWshe4Gfjr732LA3ChvX8lH/EySiZwG9pYRpQ6P4
    hGLLR5zvCUgZBx5CV1J7SZZxuzuYvLqirgRn4S1NL04m2EkKAEZ+fTHu68U/pJ7bSOuAVQ
    Q8RNTYYMKw/Q0G31exTYs7VIzRA8xc/g7maAD4lddSVmAUD2XDn56e/9Rz2aZNXLb/eCV6
    m8/VHDblDdbvqltGwMl2muz96Sg23FCUUAb57Nc0/CCr0Lz6g96Jwi1VdwOvK1BLJNkDnd
    7QaQX61rT6fDSDJdYVv/25/wCJ02rHxZAE7xw0l8Rldy9Vgr+bp0vq6Y26uD/J4r/jbcvY
    lYg6KQhhSQML3q5xiQ/Zcbb4sEWAQfPdmb0ZgZ9Fhq54C2v5hcqOdY9XJTcuVAInzIo9P2
    rMOYJWouMLdjzZmKkO0tIq4Ccn/RStHFmod88WxKT40cxJSg0cZ1WZDrZNbA
X-ME-Proxy: <xmx:nyy8ahhaC2jkq1l2rC5skmWScn_X9B4SYIipVuaqXfcwvws50DNvfA>
    <xmx:nyy8asBj6TagPUgqZd_ApjbzUUg3BZd2IqM6eayipYaAc6kVXyLP4Q>
    <xmx:nyy8ar5hvhkwFFpM7CP3DDo7evSaK6s10VEqFVg6wtDoWaLwjUBTuQ>
    <xmx:nyy8apFieqMq8XXqonrD-HsdwKS5xUjcz9eK23gho_H7FCa3cs-gQg>
    <xmx:nyy8auD_0LS3b8KVLuI0CjYACmMO2l_DXKfFjxiBBeq-Gkk1De2l7pwA>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id BB3D8B6006E; Tue, 29 Sep 2026 17:24:47 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AFvboQk2emfF
Date: Tue, 29 Sep 2026 17:24:15 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: NeilBrown <neil@brown.name>, "Trond Myklebust" <trondmy@kernel.org>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>, "Jan Kara" <jack@suse.cz>,
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <68919e69-d97b-47a4-8695-8021f24f119c@app.fastmail.com>
In-Reply-To: <20260929022547.1428036-1-neilb@ownmail.net>
References: <20260929022547.1428036-1-neilb@ownmail.net>
Subject: Re: [PATCH v2 0/9] nfs: prepare for VFS locking changes.
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Sep 28, 2026, at 10:21 PM, NeilBrown wrote:
> sashiko reported some problem with the previous posting.  A lot
> were false positives as it used the wrong base.  However:
> 3/9 had inverted the return code from nfs_neg_need_reval() - it returns
>     1 for "must revalidate" unlike d_revalidate which returns 0.
> 8/9 didn't handle and error from nfs_lookup() correctly - it
>     should be fatal rather than triggering a retry.
>
> Original intro below.
> Thanks,
> NeilBrown
>
> I am working on changes to directory locking.  The medium term goal is
> to lift d_alloc_parallel() locking above i_rwsem, so d_alloc_paralle()
> can be run unlocked, and consequently cannot be called when ->i_rwsem is
> held.
>
> The requires:
>  1/ the d_alloc_parallel() not be called while i_rwsem is held.  NFS does
>     this in a few places. New interfaces d_alloc_trylock() and d_duplicate()
>     are now available and can be used instead.
>
>  2/ a dentry must not be d_drop()ed while an operation is ongoing, as an
>     unlocked d_alloc_parallel() would then be able to create a new
>     dentry with the same name.  In particular d_rehash() must be phased
>     out as it won't be safe.  Various techiniques are used to avoid the
>     need for d_drop(), particularly that d_splice_alias() is now able to
>     splice a hashed alias.
>
> Further, the first two patches here fixes bugs that I found while
> developing and reviewing these changes.
>
> The patches depend on patches recently added to the vfs tree.  I would
> prefer these land in that tree too with an Acked-by or similar from NFS
> maintainers.

These look okay to me:

Acked-by: Anna Schumaker <anna.schumaker@hammerspace.com>

>
> Thanks,
> NeilBrown
>
>  [PATCH v2 1/9] nfs: fix open-blocking with d_fsdata
>  [PATCH v2 2/9] nfs: fix nfs_call_unlink()
>  [PATCH v2 3/9] nfs: remove d_drop()/d_alloc_parallel() from
>  [PATCH v2 4/9] nfs: use d_splice_alias() in nfs_link()
>  [PATCH v2 5/9] nfs: don't d_drop() before d_splice_alias()
>  [PATCH v2 6/9] nfs: don't d_drop() before d_splice_alias() in
>  [PATCH v2 7/9] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
>  [PATCH v2 8/9] nfs: use d_alloc_trylock() in silly-rename
>  [PATCH v2 9/9] nfs: use d_duplicate()
