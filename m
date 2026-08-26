Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE71A29C328
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 01:45:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787708729; cv=none; b=k6RuMyPJmGOKoQi4sg1Y7T/FarrtjDj14ty9FuW+sKcv0Ry0SF6Di0x4OTG3fw/ZaovRKC46TQGXypO0J5uTA2sFqQC0DCl4KytsUotu3YaUdFC3qmhnGtNhKq72wOBl7iV7R5t1HOo8WtqaI8JmOadWrQqczj0ffrws+hLNQSc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787708729; c=relaxed/simple;
	bh=k78afwVXWljxmfWyY62nNAbWlVUIilUIUP1+NWqxF7o=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=K+h00kYjAJdpUC5CC9XrunhF2mOsEFMz0Iaf0D/CrotMa7FB2AJe0cvCPZsI7/p1JICBXjHTs/bVZ3ZlKH4W+H32Fox1eoUy5kBZqs1a69YZUA3zM5YEkI21jNQkmX1hyYh+7pjKMmFtFybm1NQl3iiwja9uWoo4YgMpL3V/VgQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fNF9JeWc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fNF9JeWc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F274A1F00A3D;
	Wed, 26 Aug 2026 01:45:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787708727;
	bh=2vy5h8IRL/9drb7aiod0XEpXAp/FkZKCcWuNQsPmc2U=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=fNF9JeWcX657yjv1NgSGAUda0cHEUF2IYVcG+NEg3pCEIoqy6IQ6uXvDdWwjAw9YG
	 8K+HK04YFfIt0nQEmvzquKSCe02Wi9JRAO6VsQtQNAzE+Hf03VCCLMbMSaaO7iLPmS
	 +VPnO1R7hmHeKHL/mil/6QxG/GMYMNLDgMqp214TZwgP8sLi/MhuzLtXrZ7zzjNtwq
	 IocDdKHst/JMenRNl+nYaze8Y/BYV8F0GurWC0iUJSRU3G8rmtjE8stMpDgm4r2MsX
	 PZvaMB54kcGlc5SU1D5+NEk3dNK8adNKWEgL0fwfPGoUc2X7DPU8dvT2ZwuRT+tS8u
	 IadlAZtDCwuug==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 1EABFF40066;
	Tue, 25 Aug 2026 21:45:26 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 25 Aug 2026 21:45:26 -0400
X-ME-Sender: <xms:NkWOajMb-sus_H7aNy1nvOdmGMnSgkvpAXAk8KCtZ8kBZpMtZ6qxtQ>
    <xme:NkWOaow6gLYwADX9_oCk2s5iRt0-3PrXfMj074JolwrvzQnFkPTI2ucJAFlBQK_Bh
    tPq-wXGPR_j9QrWrrSTXKjE8drQiadoYcn_fCxgZBjxoOjYiPfQ>
X-ME-Proxy-Cause: dmFkZTEVoTDRoSHmD44CVmkhH4Y8ASOktCIL50roejKVJZIr3nwD95sLhpGfQ38COMrkbe
    erGvCZ+L8qjD+2qplldoIelzYSPmdxHb60bWxf4iOyRmAZnwour7YvCdd7JbOsFCXpCje1
    5cVs3VIcdVitDvfZcG18HRLpiqJ4Hk0siGcGJloYyFT4AdorQ6HykIJ7AHgXO54+O6CrrX
    dXrTzVUDmku/D1RwZx60Eo9R/UtRPPn9xLzIp01H/n5gR+9VunuFXB5fhqxXJYmk01ttNy
    Eu/QMfPiQLQ3nGLDg9GjAaEVbyxlg2KtdOU17zP0FK8JhyauBcH2JOrlNBZ8klc3d7fIYl
    sUrSSF3D5LrInRkjt8qSUxEvLu6Y2xvHBvF3tE1ZsSmWUuNkmFPMuec82RBP1paPVmJIC0
    JHLjWlyR+8ZezBcBjb7exkrfDA64vCcEljnyFqwJhWY0bPh5dGV/OqppRGdPX6ciOMvy4x
    ghEUJHccYb+70u12RzGT3nN3yJgX/R8leneuu1h2VygsIcM69mLjTCa4ZHQy09mQf8nTjZ
    oH4yvhZuSIFNxCK8M0kZ0wZsWKyyHJ0gy66T4FrMIixhxzeBvEPAFWg4ilhqk0V+r/OtEk
    rI8EXRfF8C99amS/cZQoMvN9A0/bgwmv5ZSjtt+dbJiLFn/Fcnf0asce9JDw
X-ME-Proxy: <xmx:NkWOapAjKKiUkbmo9K8Vi8l8m30UzO9OwilVwLvYEyrmX6sJRmLxDA>
    <xmx:NkWOaoGqu6GJtIhi3Wm8T8ysw-GjdPjZRE56D7NJ9gye19sIm9MFDQ>
    <xmx:NkWOatetpd38kT_eQJif1y7rvWXGpybLbhGfEWa3J-8Ryt9TtrZ65Q>
    <xmx:NkWOat96OBaF718IM3ivVUDtR_Kxjx7-gvKCLLyG3gM83tFLmkhgmA>
    <xmx:NkWOajZGYW8ukeLt5Zsy4LxY1hin93DTC8A2Ocb-04ql6znKiG2bVBny>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E9AEB7811F0; Tue, 25 Aug 2026 21:45:25 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Tue, 25 Aug 2026 21:45:03 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
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
Message-Id: <0c46ce23-5a78-40af-8acd-3fcc4504242d@app.fastmail.com>
In-Reply-To: <178769497289.3510150.1755559233711012616@noble.neil.brown.name>
References: <20260815042707.2535717-1-neilb@ownmail.net>
 <20260815042707.2535717-14-neilb@ownmail.net>
 <c3cc4175-1ca3-467d-849b-22462a7514fc@app.fastmail.com>
 <178769497289.3510150.1755559233711012616@noble.neil.brown.name>
Subject: Re: [PATCH v2 13/18] VFS: don't move dentries in d_sib list when they have the
 same parent
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Aug 25, 2026, at 5:56 PM, NeilBrown wrote:
> On Thu, 20 Aug 2026, Chuck Lever wrote:
>> 
>> On Sat, Aug 15, 2026, at 12:21 AM, NeilBrown wrote:
>> > From: NeilBrown <neil@brown.name>
>> >
>> > When __d_move() moves or exchanges dentries it currently always moves
>> > both dentries to the head of the ->d_children list of the respective
>> > parents.
>> >
>> > When they have the same parent, this simply moves them from where they
>> > are to the start in the same list.  So it achieves nothing useful.
>> >
>> > A future patch will allow d_for_each_positive_child() to drop and retake
>> > the parent's d_lock during the iteration.  With the current __d_move
>> > behaviour this would allow a dentry to be moved to the front and so
>> > missed, even though it is still in the same directory.  This might be
>> > unexpected.
>> >
>> > With this change the only dentries that d_for_each_positive_child()
>> > might miss are those moved out of the directory, or those moved in after
>> > the iteration started.  These are unavoidable and should not be
>> > unexpected.
>> >
>> > Signed-off-by: NeilBrown <neil@brown.name>
>> > ---
>> >  fs/dcache.c | 20 ++++++++++++++------
>> >  1 file changed, 14 insertions(+), 6 deletions(-)
>> >
>> > diff --git a/fs/dcache.c b/fs/dcache.c
>> > index ae726f3ff0cb..50fbbcceca01 100644
>> > --- a/fs/dcache.c
>> > +++ b/fs/dcache.c
>> > @@ -3052,6 +3052,9 @@ static void copy_name(struct dentry *dentry, 
>> > struct dentry *target)
>> >   * entries should not be moved in this way. Caller must hold 
>> > rename_lock, the
>> >   * i_rwsem of the source and target directories (exclusively), and the 
>> > sb->
>> >   * s_vfs_rename_mutex if they differ. See lock_rename().
>> > + *
>> > + * If @dentry and @target have the same parent, then neither is
>> > + * moved in the d_sib list.
>> >   */
>> >  static void __d_move(struct dentry *dentry, struct dentry *target,
>> >  		     bool exchange)
>> > @@ -3119,15 +3122,20 @@ static void __d_move(struct dentry *dentry, 
>> > struct dentry *target,
>> >  	} else {
>> >  		target->d_parent = old_parent;
>> >  		swap_names(dentry, target);
>> > -		if (!hlist_unhashed(&target->d_sib))
>> > -			__hlist_del(&target->d_sib);
>> > -		hlist_add_head(&target->d_sib, &target->d_parent->d_children);
>> > +		if (target->d_parent != dentry->d_parent) {
>> > +			if (!hlist_unhashed(&target->d_sib))
>> > +				__hlist_del(&target->d_sib);
>> > +			hlist_add_head(&target->d_sib,
>> > +				       &target->d_parent->d_children);
>> > +		}
>> >  		__d_rehash(target);
>> >  		fsnotify_update_flags(target);
>> >  	}
>> > -	if (!hlist_unhashed(&dentry->d_sib))
>> > -		__hlist_del(&dentry->d_sib);
>> > -	hlist_add_head(&dentry->d_sib, &dentry->d_parent->d_children);
>> > +	if (dentry->d_parent != old_parent) {
>> > +		if (!hlist_unhashed(&dentry->d_sib))
>> > +			__hlist_del(&dentry->d_sib);
>> > +		hlist_add_head(&dentry->d_sib, &dentry->d_parent->d_children);
>> > +	}
>> > 
>> >  	/*
>> >  	 * Adjust parent refcounts if either d_children ended up empty.
>> > -- 
>> > 2.50.0.107.gf914562f5916.dirty
>> 
>> Both new guards are correct. In the exchange branch target->d_parent has
>> already been set to old_parent, so testing it against dentry->d_parent
>> asks whether the two dentries started in the same directory. In the
>> common branch dentry->d_parent has been set to target's parent, so
>> testing it against old_parent asks the same question. IS_ROOT()
>> still takes the move, which it needs to because a root dentry has an
>> unhashed d_sib, and the BUG_ON(p) above guarantees target->d_parent
>> is not dentry.
>> 
>> The opening sentence needs a qualifier. For an ordinary move only
>> dentry->d_sib is relocated. target->d_sib is touched only on the
>> exchange path, so "both dentries" describes just that case.
>
> Thanks, I'll adjust that.
>
>> 
>> This patch also does more for libfs than the patch description claims.
>> I would like the description to say so, because it makes the patch
>> worth applying on its own.
>> 
>> offset_readdir() resolves a stale cookie with mas_find_rev() and then
>> walks d_children from the dentry it lands on. That is correct only
>> while offset order is the reverse of d_children order. d_alloc()
>> inserts at the head and mtree_alloc_cyclic() hands out increasing
>> offsets, so the two agree in a directory that is only created into.
>> 
>> A rename within one directory breaks the agreement today.
>> simple_offset_rename() gives the surviving dentry the offset of the
>> entry it replaced, and d_move() then sends that dentry to the head of
>> d_children. Create a, b and c in that order and the offsets are 3, 4
>> and 5, with d_children holding c, b, a. After rename("a", "b") the
>> dentry for a carries offset 4 and sits at the head, so d_children
>> holds a, c while offset order still says c, a. Stop a readdir with a
>> reported and c pending, remove c, and the next call resolves the
>> cookie to a and reports a a second time.
>> 
>> With this patch a stays where it is, d_children holds c, a, and the
>> two orders agree again. Thus this is a fix for tmpfs readdir, not
>> just preparation for 14/18.
>
> Thanks for the review, but I think the above is a false hope.
> In that particular case my patch helps, but in a different case it
> doesn't.
> Suppose instead of rename("a", "b"), I did rename("a", "c").
> Before the renames d_children holds (name,offset) pairs of
>
>  ("c", 5), ("b",4"), ("a",3)
>
> after the rename which with my patch doesn't move dentries but does
> still copy the name and offset from "c" to "a", and unhashes the
> original "c" - which we can show with [] - we have
>
>  ["c", -], ("b",4), ("c", 5)
>
> which has the wrong ordering.

I have a fix for that, I believe, that applies on top of this one.
I can post it if interested.


> Thanks,
> NeilBrown
>
>
>> 
>> Reviewed-by: Chuck Lever <cel@kernel.org>
>> 
>> 
>> -- 
>> Chuck Lever
>> 
>>

-- 
Chuck Lever
