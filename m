Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B39947045F
	for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2026 13:39:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787233163; cv=none; b=Mzvx3i7dwYTSCoa1cnUP2g1npxR59U6q6PUvS+icFypwFQTn0U+iihFzmnNaWGDCRMX6geoTDXeJa2HFpjLOMidoZtfPnxna8Ko0cOx8BA7PqzheK6IrFMySbqajhP13HQiTrOJHlB9GTHnJYBsPketuBCnnF5q8SLTInFAQJps=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787233163; c=relaxed/simple;
	bh=c2aZTXsKotnTEQLxiQQU3f7OVBAi/23fQ8T+VGgh1Ls=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=kjozd13YQtolE5Fnkv5oRk0U+ab12yu638+rgqrr0RhDg4I/vhVLPHWR9mCd/RSSJUUu6T8yAAtHUW6eZo8rTPEq89c5Jzhvy4ZXYXtZacBVC3z/HxIw8Av8vpjIu0UH7AUR9GhIHm37LTcZ4Zlh5ImJmzPdjJdNOaJX6DYPVPo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Sici3JbO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Sici3JbO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D0D261F000E9;
	Thu, 20 Aug 2026 13:39:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787233162;
	bh=L2i2SfrrQ2kr3E4fUn58Y4XhMywnculujc8OIEZrVB8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Sici3JbOQizYFlIXggBwe7MgZeCN6TNjNk0ERw31GVUQmuZPEzQ01gpGnSWD1sMpn
	 zQFwDnofgLU864atP6/tqDBtmujiZ5idyZKRyln3sZOW43Toj6YclyZbgS+cQf4FsQ
	 0wnXzpg1K2jxJkxe3iBTUDJt5ptkFJWJ0rRUnb/KHE4tyRdxXYN7mo3PaUX7SrnqPK
	 cse1ATo/8tWIduiy2izhC/2selzKFxLdKh6OItup/8+2yZ0y8E6QOQtMzxHraaA7E8
	 I0D0kVKxwKYgSW2N3ZkA+64P85VTpqTaYA6GNTYmlZnJnLYTAWoJaPdUs07bk+zjRQ
	 sUofwGU1LGYKQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0FE5BF40066;
	Thu, 20 Aug 2026 09:39:21 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 20 Aug 2026 09:39:21 -0400
X-ME-Sender: <xms:iAOHalyG6G0dQLLCNtTw403Opb8WXevL_Isrb5Vfi7eSAFYybKdvgw>
    <xme:iAOHagGxFjWfeEJPiCYOKBZtdmy1B8Y3f9glIYMBacwEAgcahh6tJtlyYARWLvAoh
    baIweg3_NUd_JsMZHLisLaLfH--ibLgl2FP6Uc7fYlLCvWihluCtghg>
X-ME-Proxy-Cause: dmFkZTFP4FeOKf5BWVYB8+8unwx4eT974UKuXMkwt0vKrk9dVZD4SogVp7fKs1rghfP3wk
    dTtR/326e0hSsOaIRqwENRgZwqbVUQzksrt4doe6qD/sGy9sBJgTrBfl1DlOkB2ZUb6ugE
    wUFcNBWtSqdk5qvptpFMIpNInTOxSbG8voiRmZMkw6zRyvfUaEV2LTwFfLtuO7BY6h2o3T
    lERQMRhQZZ9ycKzOx0oIDSmaQWoLP71hMaeAmTYgmpifXOs7MkkeoSoFKkUnfytCjxuCl7
    AeZB28U5c9ucyN+PjpCM69GE/OP/6kaY4S3vfbxVua2kaVQBjo+NnrPPc9KkPdzQn2xNTL
    K8xD+UW9lzKTQUfyzgOsFf8lTQsQvzHN2wf7HMGLweqJs2iryTO1rOurRZpgdqO4oDBEBg
    P7YrTu0JVQRyL53bo7nBH2EWH0VQbS3587m+DvMFVPLVIxRopXennsYfT62Czo5tx9641r
    OPdfppR/DLW5BiEd1CgG8X6cqpFVxJmZxCgk7aBt24/CQQaiJPdmbL7WhF4v98JmQuBPco
    RBgyGtd6G9b/NtEebf9jCfo5svJSy5bGxuau2FPm8SdElLKSfPwsErd4i3fajfbaM0Q6zZ
    +mX8WIp7QpoteuD0ni6Pu8P99mwc0flZiPYqwqejPUhcAiKEVIRNL5pyNxSA
X-ME-Proxy: <xmx:iAOHau7aBlFVUUUFvHPjiKktd9jQGkOYF86yb59gHtHMQzgB5LMGCQ>
    <xmx:iQOHajUdTt8T2eeBjpk4vco6uHHGGpftn3-Fx3LtkIZwNrdxL4SA2Q>
    <xmx:iQOHasIzTXXVSxfH9cV0onv3Ide0BxbFi8t9HkrKylfidCuBA8eK0w>
    <xmx:iQOHaoSE2ZkeAsN-2NtBnwLdhZpYlPNgXP69jorYO39HBeQDd59bVA>
    <xmx:iQOHaohQprhurksJT9XbgRMD6m5Bqf6ebxq-dZ2KJ_XX8eDXzaVIA5nP>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id CFF8C7811F0; Thu, 20 Aug 2026 09:39:20 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AvwrKSmIynuB
Date: Thu, 20 Aug 2026 09:39:00 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>, "Ian Kent" <raven@themaw.net>,
 "Jake Edge" <jake@lwn.net>, "Ilya Dryomov" <idryomov@gmail.com>,
 "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, "Jan Harkes" <jaharkes@cs.cmu.edu>,
 coda@cs.cmu.edu, "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jan Kara" <jack@suse.cz>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Amir Goldstein" <amir73il@gmail.com>,
 "Andrew Morton" <akpm@linux-foundation.org>,
 "Miklos Szeredi" <mszeredi@redhat.com>
Cc: autofs@vger.kernel.org, linux-kernel@vger.kernel.org,
 ceph-devel@vger.kernel.org, codalist@coda.cs.cmu.edu,
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <c3cc4175-1ca3-467d-849b-22462a7514fc@app.fastmail.com>
In-Reply-To: <20260815042707.2535717-14-neilb@ownmail.net>
References: <20260815042707.2535717-1-neilb@ownmail.net>
 <20260815042707.2535717-14-neilb@ownmail.net>
Subject: Re: [PATCH v2 13/18] VFS: don't move dentries in d_sib list when they have the
 same parent
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sat, Aug 15, 2026, at 12:21 AM, NeilBrown wrote:
> From: NeilBrown <neil@brown.name>
>
> When __d_move() moves or exchanges dentries it currently always moves
> both dentries to the head of the ->d_children list of the respective
> parents.
>
> When they have the same parent, this simply moves them from where they
> are to the start in the same list.  So it achieves nothing useful.
>
> A future patch will allow d_for_each_positive_child() to drop and retake
> the parent's d_lock during the iteration.  With the current __d_move
> behaviour this would allow a dentry to be moved to the front and so
> missed, even though it is still in the same directory.  This might be
> unexpected.
>
> With this change the only dentries that d_for_each_positive_child()
> might miss are those moved out of the directory, or those moved in after
> the iteration started.  These are unavoidable and should not be
> unexpected.
>
> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  fs/dcache.c | 20 ++++++++++++++------
>  1 file changed, 14 insertions(+), 6 deletions(-)
>
> diff --git a/fs/dcache.c b/fs/dcache.c
> index ae726f3ff0cb..50fbbcceca01 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -3052,6 +3052,9 @@ static void copy_name(struct dentry *dentry, 
> struct dentry *target)
>   * entries should not be moved in this way. Caller must hold 
> rename_lock, the
>   * i_rwsem of the source and target directories (exclusively), and the 
> sb->
>   * s_vfs_rename_mutex if they differ. See lock_rename().
> + *
> + * If @dentry and @target have the same parent, then neither is
> + * moved in the d_sib list.
>   */
>  static void __d_move(struct dentry *dentry, struct dentry *target,
>  		     bool exchange)
> @@ -3119,15 +3122,20 @@ static void __d_move(struct dentry *dentry, 
> struct dentry *target,
>  	} else {
>  		target->d_parent = old_parent;
>  		swap_names(dentry, target);
> -		if (!hlist_unhashed(&target->d_sib))
> -			__hlist_del(&target->d_sib);
> -		hlist_add_head(&target->d_sib, &target->d_parent->d_children);
> +		if (target->d_parent != dentry->d_parent) {
> +			if (!hlist_unhashed(&target->d_sib))
> +				__hlist_del(&target->d_sib);
> +			hlist_add_head(&target->d_sib,
> +				       &target->d_parent->d_children);
> +		}
>  		__d_rehash(target);
>  		fsnotify_update_flags(target);
>  	}
> -	if (!hlist_unhashed(&dentry->d_sib))
> -		__hlist_del(&dentry->d_sib);
> -	hlist_add_head(&dentry->d_sib, &dentry->d_parent->d_children);
> +	if (dentry->d_parent != old_parent) {
> +		if (!hlist_unhashed(&dentry->d_sib))
> +			__hlist_del(&dentry->d_sib);
> +		hlist_add_head(&dentry->d_sib, &dentry->d_parent->d_children);
> +	}
> 
>  	/*
>  	 * Adjust parent refcounts if either d_children ended up empty.
> -- 
> 2.50.0.107.gf914562f5916.dirty

Both new guards are correct. In the exchange branch target->d_parent has
already been set to old_parent, so testing it against dentry->d_parent
asks whether the two dentries started in the same directory. In the
common branch dentry->d_parent has been set to target's parent, so
testing it against old_parent asks the same question. IS_ROOT()
still takes the move, which it needs to because a root dentry has an
unhashed d_sib, and the BUG_ON(p) above guarantees target->d_parent
is not dentry.

The opening sentence needs a qualifier. For an ordinary move only
dentry->d_sib is relocated. target->d_sib is touched only on the
exchange path, so "both dentries" describes just that case.

This patch also does more for libfs than the patch description claims.
I would like the description to say so, because it makes the patch
worth applying on its own.

offset_readdir() resolves a stale cookie with mas_find_rev() and then
walks d_children from the dentry it lands on. That is correct only
while offset order is the reverse of d_children order. d_alloc()
inserts at the head and mtree_alloc_cyclic() hands out increasing
offsets, so the two agree in a directory that is only created into.

A rename within one directory breaks the agreement today.
simple_offset_rename() gives the surviving dentry the offset of the
entry it replaced, and d_move() then sends that dentry to the head of
d_children. Create a, b and c in that order and the offsets are 3, 4
and 5, with d_children holding c, b, a. After rename("a", "b") the
dentry for a carries offset 4 and sits at the head, so d_children
holds a, c while offset order still says c, a. Stop a readdir with a
reported and c pending, remove c, and the next call resolves the
cookie to a and reports a a second time.

With this patch a stays where it is, d_children holds c, a, and the
two orders agree again. Thus this is a fix for tmpfs readdir, not
just preparation for 14/18.

Reviewed-by: Chuck Lever <cel@kernel.org>


-- 
Chuck Lever
