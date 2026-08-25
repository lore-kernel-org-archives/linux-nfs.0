Received: from flow-b8-smtp.messagingengine.com (flow-b8-smtp.messagingengine.com [202.12.124.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 726F3231C91;
	Tue, 25 Aug 2026 21:56:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787694987; cv=none; b=PyfPwjmUlPnF2qkJnCXbt7dVD/QBXe3v7oEcK1KqtvKrIxy/zivlYNlOoRiKQn79FK4ZrImrPDwCervAg8NSKy9kFe6QlGOe+N1RECU7vvA4RqZ6smQlRq3EThhjBz54LX49B7/5unN9RE9g8rDA+7eLUBb2jahWRazABuzHZrY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787694987; c=relaxed/simple;
	bh=dm0QyT7++VWdHaVpCIpFW9MRS1FV5qyVd8f9Z3zLu0I=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=iTIn24QOCqA326IhFFsSxQTHg0e01NdBTM3V8mkq4JULwM2Tpur6LU/lf2DJ89jy+zcjY2RC1VCenlI7BtduZ9snwTwWxAFEm5tORmqyKojit5aHUwKftaoz2TbwFlbgaGcoBz+T9Hy/Jq6KsWFuxMp4FQ0xoWOQVlYSNqJxpeM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=W1zOJXtT; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=F6ZZ5DJl; arc=none smtp.client-ip=202.12.124.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="W1zOJXtT";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="F6ZZ5DJl"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.stl.internal (Postfix) with ESMTP id C451913002CE;
	Tue, 25 Aug 2026 17:56:23 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Tue, 25 Aug 2026 17:56:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1787694983; x=1787702183; bh=K05G7A12ZirkV0S62vCINyB8k2uIdpaSt2c
	/l5Svrv0=; b=W1zOJXtTY7krqUbI/e2926xA2AI0aonKJm93t8Efmm3sTv4C/55
	Xlh0fnezDWIjnFiWDsI5KehWguDiDPvz24PomDV6c0NxVOuFjEi7DeJwPqkm1sdU
	wESvCwK90Is87jd8TJknWHlz9D67gS7ovqI22ibngAABV5+ZXqhsOobu/Od4l2C9
	OKHgTaFh/ouDlqrlUDzzgtEosWgI9MF3+t10kC83kerjkwEVmMxZWA5f8sVxyiHa
	BcqPO/XxblPiXDiV5O4V7V5LeiRVYQudbW+85Pt4Sf+NO32s28RIC/XH9+7KAVDc
	DzfVbZOp1u4yloVE7vfG9SUZ/lzztqTocWw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787694983; x=
	1787702183; bh=K05G7A12ZirkV0S62vCINyB8k2uIdpaSt2c/l5Svrv0=; b=F
	6ZZ5DJl4wrVIGsuat3al6SyTvH3msQ3BCM9jddMk0KsQI7NB2roPOzeyYPEIe8Hf
	jDIBVTrPqTsVuKwZ7mGq8zeLH0Mj06EtFNS2DFkqtpQfc0gcHkHh3lrvK0NPNSlx
	TOhuUzE0UT4roBtnrngh+RFxjyIiqY2M13+28jErxmrIqhDUZ51D/h+3Pg7JW7Le
	yX0wrSbsyI7wDuu9MaMkpGX+HJWPY07KCgsgYVB0Cm1B4623SLA5TwQHou2rBZtS
	T8vJzKN4gwmq00/PC6XdPghRI/zVegG9MknPqbU1TOimsDFPA/vWHOI6UTsOe6/s
	X1rmchbkL0elUvZyDLUog==
X-ME-Sender: <xms:hg-Oam7wzMJUAHNHVmS3kaNBFaCfuHPtUMsyZw21EnOHipVe_AZm_w>
    <xme:hg-OaoGFdekNRuJqe6y_VfQI7BzoD4yhwwqkeMslmaZTq7JQZ8J9rSPgNzlBnDN5z
    319Un-MfJPjIT9I3vuNi3CEVD4R142ZMqRKYI9N-RWqei0hiw>
X-ME-Received: <xmr:hg-OaszPMO38XBb9bOiFudtkeX90c-XU8Hutb5_SqVQG6jRqXJVKADYlzEku_0s73wq752YmdN8gpwO5S-sbToIA03BvXFw>
X-ME-Proxy-Cause: dmFkZTEinfM2rX6LCiisMyfFt6nycDgH63ScsQwlmXkpkDSM52GqJt93CfJAFgJHAs8+0d
    YVonLtc/8GUWKH+1AqRTJMeyvQC01F9hFs5SPWJnCnyj38ZpPlB87JP8Y/NZJIPumB7Th5
    XBNUzkKkK91KeAd2GzBFSUi7z3seDx1P3Vii8PN8s8Z6BMei2iIXjmfJdTVcYdLS79IEIT
    Cw3VX6P02LXMKO4gRAZUuH6UmBx9aIuViCOWHYgk0fd/RafbHOJLPEzuukpNUD61HJGNhr
    setVMgw9EzoDFIcT0227/8DIP+AvONFUKeIuMRfMgjYsaqxmdUqsol8Qj1yAguLwwrvNM9
    9yV/8A6sPKRFqWMEF6fFHNSKYNW+tIOl+6Guhmts0E3A0jF+27ZNJ0NIW7KehybzykK4bb
    hdeLdKpwVTbvEcLzZn3/KXLa9e0jFLfNli8I+AcoQf7bbkz8Sdkwgs/RVovVHfg0N7P9LJ
    2V3YIir6Z88Tvm1EkjmQYJ7DOg/vOwaHSFD6XGsEdZWUl14viQUPWcpDylDH4DuaYT9C6i
    BmfBmlAI2/HTWjSq3i+ch8uDc9JdNk/1YHEzPsku1rJKcfO4iHT7hhkFDY+pOT2L6SfOhw
    MciJOHiSvlmllnGy3G5MhYpkdwQgaag4obfbyPF5+tbkNzwIoASU7QgxNaVg
X-ME-Proxy: <xmx:hg-Oag3oeqAdMvo4kL_VpxUf31WN5V3OGquTQ1q1q__0QGJ7g5IdYQ>
    <xmx:hg-OanOqbkvAVCBKAb0NleNuqMDQ4N2Ck6MEQwjdGrWdreXhxING5Q>
    <xmx:hg-OaksxkI-BOW8yZuRcrpqE8yFm3DpOVJiKyNdOZddSqOTY4Vby0w>
    <xmx:hg-OajL6Lrtjz4k8Rq-wTkznr36PQiG7SdA-ovLNqZiiq_fyUxmkog>
    <xmx:hw-OahS4kme2FlPtj7lTXPgXETDY-0mEaw-zcfQPIdM9nJxHdUJzDJI3>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 17:56:16 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Ian Kent" <raven@themaw.net>, "Jake Edge" <jake@lwn.net>,
 "Ilya Dryomov" <idryomov@gmail.com>, "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, "Jan Harkes" <jaharkes@cs.cmu.edu>,
 coda@cs.cmu.edu, "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jan Kara" <jack@suse.cz>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Amir Goldstein" <amir73il@gmail.com>,
 "Andrew Morton" <akpm@linux-foundation.org>,
 "Miklos Szeredi" <mszeredi@redhat.com>, autofs@vger.kernel.org,
 linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
 codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 13/18] VFS: don't move dentries in d_sib list when they
 have the same parent
In-reply-to: <c3cc4175-1ca3-467d-849b-22462a7514fc@app.fastmail.com>
References: <20260815042707.2535717-1-neilb@ownmail.net>
  <20260815042707.2535717-14-neilb@ownmail.net>
  <c3cc4175-1ca3-467d-849b-22462a7514fc@app.fastmail.com>
Date: Wed, 26 Aug 2026 07:56:12 +1000
Message-id: <178769497289.3510150.1755559233711012616@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Thu, 20 Aug 2026, Chuck Lever wrote:
> 
> On Sat, Aug 15, 2026, at 12:21 AM, NeilBrown wrote:
> > From: NeilBrown <neil@brown.name>
> >
> > When __d_move() moves or exchanges dentries it currently always moves
> > both dentries to the head of the ->d_children list of the respective
> > parents.
> >
> > When they have the same parent, this simply moves them from where they
> > are to the start in the same list.  So it achieves nothing useful.
> >
> > A future patch will allow d_for_each_positive_child() to drop and retake
> > the parent's d_lock during the iteration.  With the current __d_move
> > behaviour this would allow a dentry to be moved to the front and so
> > missed, even though it is still in the same directory.  This might be
> > unexpected.
> >
> > With this change the only dentries that d_for_each_positive_child()
> > might miss are those moved out of the directory, or those moved in after
> > the iteration started.  These are unavoidable and should not be
> > unexpected.
> >
> > Signed-off-by: NeilBrown <neil@brown.name>
> > ---
> >  fs/dcache.c | 20 ++++++++++++++------
> >  1 file changed, 14 insertions(+), 6 deletions(-)
> >
> > diff --git a/fs/dcache.c b/fs/dcache.c
> > index ae726f3ff0cb..50fbbcceca01 100644
> > --- a/fs/dcache.c
> > +++ b/fs/dcache.c
> > @@ -3052,6 +3052,9 @@ static void copy_name(struct dentry *dentry, 
> > struct dentry *target)
> >   * entries should not be moved in this way. Caller must hold 
> > rename_lock, the
> >   * i_rwsem of the source and target directories (exclusively), and the 
> > sb->
> >   * s_vfs_rename_mutex if they differ. See lock_rename().
> > + *
> > + * If @dentry and @target have the same parent, then neither is
> > + * moved in the d_sib list.
> >   */
> >  static void __d_move(struct dentry *dentry, struct dentry *target,
> >  		     bool exchange)
> > @@ -3119,15 +3122,20 @@ static void __d_move(struct dentry *dentry, 
> > struct dentry *target,
> >  	} else {
> >  		target->d_parent = old_parent;
> >  		swap_names(dentry, target);
> > -		if (!hlist_unhashed(&target->d_sib))
> > -			__hlist_del(&target->d_sib);
> > -		hlist_add_head(&target->d_sib, &target->d_parent->d_children);
> > +		if (target->d_parent != dentry->d_parent) {
> > +			if (!hlist_unhashed(&target->d_sib))
> > +				__hlist_del(&target->d_sib);
> > +			hlist_add_head(&target->d_sib,
> > +				       &target->d_parent->d_children);
> > +		}
> >  		__d_rehash(target);
> >  		fsnotify_update_flags(target);
> >  	}
> > -	if (!hlist_unhashed(&dentry->d_sib))
> > -		__hlist_del(&dentry->d_sib);
> > -	hlist_add_head(&dentry->d_sib, &dentry->d_parent->d_children);
> > +	if (dentry->d_parent != old_parent) {
> > +		if (!hlist_unhashed(&dentry->d_sib))
> > +			__hlist_del(&dentry->d_sib);
> > +		hlist_add_head(&dentry->d_sib, &dentry->d_parent->d_children);
> > +	}
> > 
> >  	/*
> >  	 * Adjust parent refcounts if either d_children ended up empty.
> > -- 
> > 2.50.0.107.gf914562f5916.dirty
> 
> Both new guards are correct. In the exchange branch target->d_parent has
> already been set to old_parent, so testing it against dentry->d_parent
> asks whether the two dentries started in the same directory. In the
> common branch dentry->d_parent has been set to target's parent, so
> testing it against old_parent asks the same question. IS_ROOT()
> still takes the move, which it needs to because a root dentry has an
> unhashed d_sib, and the BUG_ON(p) above guarantees target->d_parent
> is not dentry.
> 
> The opening sentence needs a qualifier. For an ordinary move only
> dentry->d_sib is relocated. target->d_sib is touched only on the
> exchange path, so "both dentries" describes just that case.

Thanks, I'll adjust that.

> 
> This patch also does more for libfs than the patch description claims.
> I would like the description to say so, because it makes the patch
> worth applying on its own.
> 
> offset_readdir() resolves a stale cookie with mas_find_rev() and then
> walks d_children from the dentry it lands on. That is correct only
> while offset order is the reverse of d_children order. d_alloc()
> inserts at the head and mtree_alloc_cyclic() hands out increasing
> offsets, so the two agree in a directory that is only created into.
> 
> A rename within one directory breaks the agreement today.
> simple_offset_rename() gives the surviving dentry the offset of the
> entry it replaced, and d_move() then sends that dentry to the head of
> d_children. Create a, b and c in that order and the offsets are 3, 4
> and 5, with d_children holding c, b, a. After rename("a", "b") the
> dentry for a carries offset 4 and sits at the head, so d_children
> holds a, c while offset order still says c, a. Stop a readdir with a
> reported and c pending, remove c, and the next call resolves the
> cookie to a and reports a a second time.
> 
> With this patch a stays where it is, d_children holds c, a, and the
> two orders agree again. Thus this is a fix for tmpfs readdir, not
> just preparation for 14/18.

Thanks for the review, but I think the above is a false hope.
In that particular case my patch helps, but in a different case it
doesn't.
Suppose instead of rename("a", "b"), I did rename("a", "c").
Before the renames d_children holds (name,offset) pairs of

 ("c", 5), ("b",4"), ("a",3)

after the rename which with my patch doesn't move dentries but does
still copy the name and offset from "c" to "a", and unhashes the
original "c" - which we can show with [] - we have

 ["c", -], ("b",4), ("c", 5)

which has the wrong ordering.

Thanks,
NeilBrown


> 
> Reviewed-by: Chuck Lever <cel@kernel.org>
> 
> 
> -- 
> Chuck Lever
> 
> 

