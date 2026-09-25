Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C439133D6E6;
	Fri, 25 Sep 2026 21:49:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790372992; cv=none; b=FqIo8oz8dyvW0Hn8jWnb2UOURZTbrdRjKcG3fQqzperuGz0XaNLWOl/F4+wAkLV0Bqada+/BDeWkG7DA5w0XZpb0UH7jt9JWf6FX9OHphfn2abgEjYPbtMUegwuNjFrvTgRxsmA2GcZFPSdggWTPzAJun55DSG2tF2vWJSC5J0s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790372992; c=relaxed/simple;
	bh=ayu4Hcg/6WpBXPA4uGsEFgPTj+HZfH7v4xymNyztXPo=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=a/l/FvNtlDjg5Xir9vCCovlr5kO6hOhCwk9K7hPs2sP6s6Bcf/wEUc0x/+XJ5n/vQTw2G00pkfU7SCWV1onKpQ6lkNHwtoQGJV4yqE75K78QAd5P6RsmkLaik8motwATJQCa829e6Gk2OjJ7AWF6kk+KAAivkbHxCvGUPOzZehw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=ODEQ1r3H; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=eX/2N/Ik; arc=none smtp.client-ip=202.12.124.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="ODEQ1r3H";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="eX/2N/Ik"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.stl.internal (Postfix) with ESMTP id 7ACC31D000CB;
	Fri, 25 Sep 2026 17:49:49 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Fri, 25 Sep 2026 17:49:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790372989; x=1790459389; bh=Fl99L74aSVo3lpHjg0LcF5o/zXW8b0/0JCU
	ZnYQejAU=; b=ODEQ1r3H/Bhi956K/Ns/bq8Zn4Q1no1zcPAmYJLKNDUT5qrgHMT
	Sxkz8VwRlzZmI1+VoMD3Q9uC3CM/VAwBjyyWjeSuH/C43b1mDsADnlHfo2xxFzrk
	QIVQ9/f7gS4eux0uE813k4piXObaZQO98yr9c8Vg9b6W8i1IkBdaQC+raoX3C/hv
	LGIW7sN7NJcNEFpU1xoLvcfcY6zgFqM+/wRDNj8PCLRS/fCtCo4wy02vwHU2ePAx
	09cTlAD3VNPyxOTbRGgmVAnm5RMlIX6UChERpniAM6EJEj1WWI5n+c7JTk+bQD24
	elV7ANSlHEJ9BzpxqE11HbSRqf/nItaicaQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790372989; x=
	1790459389; bh=Fl99L74aSVo3lpHjg0LcF5o/zXW8b0/0JCUZnYQejAU=; b=e
	X/2N/IkXcd7HeoS4F36Yn0MU0EB1pmtj0gVNxZ6jvhrxU7osMejdy46Nj9+w/HZ3
	ddqjMuZ2gnO+egS1K/PldnCI+zf4aiLh3+enLV0ToSSbWvKbbRan0urpYKBbq1Xa
	QyyL4/soZrBxgvqAaSfbGAxivFvNtqb+MqyuOqMwG1nZftlrlAKt0WYIDr7k1iek
	LClB7WFumO7NTGwFUpN6wVaPCjJwrd7TaLxe279srD6BRwP62oJOMbgNgkGmPxzh
	/BQsB4qF54XmjNDTma7u1HVdQ7jYiuDt3qBCHHQmsk90AejYkgHaIHD3qy6WIDSR
	D0xx0eAoeWZxj/3i+YNyg==
X-ME-Sender: <xms:fOy2ameB71hhibbHM-yRoO5ax-RjOVk5yT-dqVDFGn3Hdyirn0lLhA>
    <xme:fOy2aglXP3O8UoaXg7l2EEJLp41amCKEr7c2LvHL57MkigD-mPUI9VemYk74axfU3
    qsU6UqK_Wxn-a8bQXGpAoheqcU3QGLfG3Ms1b2_gGGlHSeIDw>
X-ME-Received: <xmr:fOy2aooyMIOZhEcoixxaVZYsMRIaugssKDTLgI3GBcvGVT6OAC8rSG9omQi522uoHCKwJJbWnA0Z5qnMujmtQNGEHwyaDw8>
X-ME-Proxy-Cause: dmFkZTGVU49mqyTays27zMayX0aGyFPBkK6jYscejpagkfBGl0SHfK5fAeXyIKq0WbjMOP
    BBwmHQJvDHuEbi74FnO63wSleOTLyB/2OpP5bMawWC2zchjnaa77G20fzmF2XHaS0pT42O
    O9R1Q/tmFsGUZ7bm7TENrI9tQgmWg2WJoF564og5Tg3Pfe24AERV+ikrZlHQdLtqXDpc9K
    MYqMhaW4JNGKL6orrMru1J6rq42R6PPmiEk3yPz0kG2cKVB24dZuKnEV3ADgq313wPp5ts
    WzMoY38Jmh1UZa+/7n5NcAaY1Tq/ACYJrQPZiaLYrU7zQPx3DQ6i2VVY9uiV4JJOT57SlW
    5oCxx/PZg34nVpt9NTya6D5FQqwxYxLTiQZyD5agn/0lXWT9Q6HBh2NUS2rT0XSSwmZH3F
    7eQ68SV3wYF5Ulf7vLc3GuB0RhnBZK9RQZtXYwJKIwcmVZ2a1X0eiDLfK4vO/bbJI0vDdB
    VF5vQWvTREZCPwZzEFGgSvdblHaHhFtbqN1/p8p0HGsE6lN/dj8gvE+QIYF44ygxTL0f0p
    C8tJqjU5//RoBwEPAQi3nG0YwQ4syuh3dNos2GJpoJ8hTp3+iSXYQ4wbh4Emx62Elh7ELt
    7tTx/3SrNAl/QmfJkJJmG8kmXWLdF7A1HPJx9s7w3owTn6DcNk8vBIgkzv7Q
X-ME-Proxy: <xmx:fOy2av8x9wlsI-k47MXUGd5t6vdoqAZxe6B5D8x3sd2hz-oSKLqrjA>
    <xmx:fOy2ah1obinVKoEKExEq44i-T4mukIgis1amzE58_fp_zA3rx0Lxxw>
    <xmx:fOy2aikKBKGAB71Y_BDn1gRujQT7zba_WaiI_uiNtvOPRKVpJL8_vg>
    <xmx:fOy2au3GymG_u50eJGTdMfg4GbU7Sb3xESjox16DalRjGZGMKBkajQ>
    <xmx:fey2asACya2AFZD6KK9Aa_iGHrFYF9fmiGkVX_FpXPcosnC04yFGhodL>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 17:49:43 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Chuck Lever" <cel@kernel.org>,
 "Jori Koolstra" <jkoolstra@xs4all.nl>, "Mateusz Guzik" <mjguzik@gmail.com>,
 "Dorjoy Chowdhury" <dorjoychy111@gmail.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Andreas Gruenbacher" <agruenba@redhat.com>, gfs2@lists.linux.dev,
 "Ilya Dryomov" <idryomov@gmail.com>, "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
 "Paulo Alcantara" <pc@manguebit.org>, "Namjae Jeon" <linkinjeon@kernel.org>,
 linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject:
 Re: [PATCH v2 04/14] ceph: simplify atomic_open to use finish_no_open()
In-reply-to: <ca31c1deadab1bbe5c2f9040f1ccee17266d8027.camel@kernel.org>
References: <20260919022441.3305170-1-neilb@ownmail.net>
  <20260919022441.3305170-5-neilb@ownmail.net>
  <ca31c1deadab1bbe5c2f9040f1ccee17266d8027.camel@kernel.org>
Date: Sat, 26 Sep 2026 07:49:40 +1000
Message-id: <179037298028.37859.3168205779174130691@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Thu, 24 Sep 2026, Jeff Layton wrote:
> Another LLM review:
>=20
> > diff --git a/fs/ceph/file.c b/fs/ceph/file.c
> > index bd3e3f5c269e..83ceb2906f85 100644
> > --- a/fs/ceph/file.c
> > +++ b/fs/ceph/file.c
>=20
> [ ... ]
>=20
> > @@ -977,33 +976,25 @@ int ceph_atomic_open(struct inode *dir, struct dent=
ry *dentry,
> >  	}
> >  	if (err)
> >  		goto out_req;
> > -	if (dn || d_really_is_negative(dentry) || d_is_symlink(dentry)) {
> > -		/* make vfs retry on splice, ENOENT, or symlink */
> > -		doutc(cl, "finish_no_open on dn %p\n", dn);
> > -		err =3D finish_no_open(file, dn);
> > -	} else {
> > -		if (IS_ENCRYPTED(dir) &&
> > -		    !fscrypt_has_permitted_context(dir, d_inode(dentry))) {
> > -			pr_warn_client(cl,
> > -					"Inconsistent encryption context (parent %llx:%llx child %llx:%llx)=
\n",
> > -					ceph_vinop(dir), ceph_vinop(d_inode(dentry)));
> > -			goto out_req;
> > -		}
> > +	if (IS_ENCRYPTED(dir) &&
> > +	    !fscrypt_has_permitted_context(dir, d_inode(dentry))) {
> > +		pr_warn_client(cl,
> > +			       "Inconsistent encryption context (parent %llx:%llx child %llx:=
%llx)\n",
> > +			       ceph_vinop(dir), ceph_vinop(d_inode(dentry)));
> > +		goto out_req;
> > +	}
>=20
> The fscrypt check used to run only when the dentry was positive, not
> a symlink, and had no alias. Now it runs unconditionally, but
> d_inode() can still be NULL here: a lookup that found nothing leaves
> a negative dentry with err =3D=3D 0, and when the MDS reply splices an
> alias the original dentry is never instantiated.
>=20
> fscrypt_has_permitted_context() dereferences its child argument
> without checking for NULL:
>=20
> fs/crypto/policy.c:fscrypt_has_permitted_context() {
> 	...
> 	if (!S_ISREG(child->i_mode) && !S_ISDIR(child->i_mode) &&
> 	    !S_ISLNK(child->i_mode))
> 		return 1;
> 	...
> }
>=20
> Every other in-tree caller passes a known inode, while this one can
> pass NULL. An open of a name that does not exist in an encrypted
> directory reaches this through lookup_open() -> atomic_open() ->
> ceph_atomic_open().
>=20
> Could the fscrypt check stay behind the positive-dentry test, as
> before?

Alternately: can we simply remove the fscrypt check?  I don't know a
whole lot about fscrypt, but it seems that ceph_open() does all
necessary fscrypt checks, and we already didn't need this one before
calling ceph_open().

You added this in
  Commit: 94af0470924c ("ceph: add some fscrypt guardrails")
but the commit doesn't explain why ceph_atomic_open() needed more that
ceph_open() needed.

Thanks,
NeilBrown
