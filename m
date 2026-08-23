Received: from flow-b7-smtp.messagingengine.com (flow-b7-smtp.messagingengine.com [202.12.124.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 918792F9D85;
	Sun, 23 Aug 2026 01:21:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787448098; cv=none; b=LEhgxjZmRY2hOu+z2/9aih1TT5czDv2tNwFv6HXU4EnHOntvoET9XczA8ir/+vgTmG1ar0xhTS0Y6W7tnWtBKjtpmDrDMIW7YY8sOLAGh1uJKpbjf5NqObMnQq/2JaRZ92NpQL7c5IJWXDoPU/A/eIR9rUQKA8hiD/JzT89iluI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787448098; c=relaxed/simple;
	bh=vNDsmTJS3b+TDa+FCuTOZT6UlErVgF6OPwGcWRSVXtU=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=CFT0gE75eT/4eOCPcCn+6uLZ7cteF/t1GzQYrm69xuNBI/SfvQtfwWsdtIz1X6G5b/rzMb7XmRy1Z7Kx3E+PfV0zdpeZ2oJmXPeseRP7dYD8mIJ+T85BynXx8rUpF/Ckts3B3NCXVhkLsqOiL9Muhc+dx/v2plrt4nqunAGlfe4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=UkkHuzsR; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=NBQFZQpS; arc=none smtp.client-ip=202.12.124.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="UkkHuzsR";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="NBQFZQpS"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailflow.stl.internal (Postfix) with ESMTP id EF557130008D;
	Sat, 22 Aug 2026 21:21:34 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Sat, 22 Aug 2026 21:21:35 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1787448094; x=1787455294; bh=Cb3hPU9JgV1SMJwig5J+Lg9o0SACLjG3CRI
	meMjyW7k=; b=UkkHuzsRr1fQWBIath5b/mbCN5jIAowX9SHNVR6MpqT2gx4feoX
	jICMixIhbr01wGq9J7P1y4383Epbnxt92kZVx2qRmYTXRMv6tQKh3oNicpdHTkwy
	ZZnJKcY/n8hXRyo2F9lGbsoVn06NqriDj3mv2+n+2duxHM7/S04qEeNeqOcEwLul
	n664tnwT5Fe8rmT6kTjEMzisq+O0L8cG1ZVd0IkQl9DB/c02k6iHQU3921u5dB05
	RLaUTr0p09cBP89xjTmogyubD/8Ha8B13gAGVeTlWnQnZ3EGuyQg6U7fSleJwgFK
	wSB1jQSjCgYh49OcAGQeX7m6Useal9I6fKQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787448094; x=
	1787455294; bh=Cb3hPU9JgV1SMJwig5J+Lg9o0SACLjG3CRImeMjyW7k=; b=N
	BQFZQpSHXjPMy7Zut8IxuT9yKy2E3WmQCkSpSycmW06uho7oi0JEnGqGRG9dWxRm
	dn/jp5xoX5kV+fSBuxhi1/8mAgAGmChzMVCJWbB0iYmMYOKB17w/afXckOCkTH3p
	nIivAPabbVtcucVmmFKrRoDpzUkqicJQnVhrfiiLWPJMHrzz8Bg9OEP4+R6B/a2W
	catoQO238l44RZK4lrKv/rjkYwBEOvR7aCx75elOP2kb0Nnkq9L/Xo4MFcEzduIK
	h7zfnCgjxXzXuU53XzsJYLT1Qa/oQ+GymmGLp6eT6K5MLYELKh/wobdnq78cVzgg
	qwxGh2SjwZU15CGdbPN4Q==
X-ME-Sender: <xms:HUuKahL1slkUMJQSuwEaTj2RLoPSZ8poxXl4N4ORbIq-wV-rWuFT_A>
    <xme:HUuKau0fVRX_F3V2cPIuR4KNvdQRy34L-8g4C7w92d8RrCsQh3nKnxZVH9HyrX91y
    n44uzolZ-q1EYyvtORjClgmMvurdTewjwqoJjyr-971KELBOQ>
X-ME-Received: <xmr:HUuKatI2aIF3Kg4-diVjg6KrZVsBNjMMeprO9uMjtX7EZyEYWZa_AEjbTb868XRX5mXapUPuPoe9nNJK6AgxoIuSzxgcvDA>
X-ME-Proxy-Cause: dmFkZTF28I7HEt3WBN6c6IzEpKsBN9AQLSnyMJtLuM3+uMUc3zO+tGnPoXT8ipzNMcGmpD
    Nh/EQugbA8LMCcQc4rst0xaoqvW3m5KoxKY+S7+S2t2lFXv76tUZJtAWkvG13eRXWL66ge
    L/YB4HSGqfsIbZdin/KVl2tu+7iQ5Z5mZ44UZXkZRfZ0b/Ux6b8HYB3uDDKLlUItXBM7wz
    ybHDq9Ox6fpSUGhtUtIAqB7zBfKWbuvF++J39sA44KKBKyeJexGhCWVA2hf2FyxThWQHk5
    PLdEQ+i8dSxgxUgESgr+9Eproy/1gvB1AJtRDtOn1BKOXhxDvSwn4yYIy4dHuI6P4IWYp5
    FcpwvaOTN8qPk+8H0jf9ytdO/plO0vQsbXdotgsfOpq5qKOLRE9cqCgN3+bXIAf/xvwLl3
    iqEbKZNXaLyi76lNdfCr641+Ef73L9NKF4wCJ0fHw2b3tcaiABea1z2+TZ/8Hp0HIEVNX9
    92nqRejiVnmveSeHna0lAh7mN7HBln/z0r3QghIJOjDgzGHiL8a/b9CJufrlVZ2JScw7Qw
    c61Bawx4Rk60YkE94sHAQASOL1f0WBrP1f/ro8Voj8dgqDNlZqHANoyxru4U40YQ2sa/CF
    mwikD+ZQZFs7UFzgFkQEzc4zl3wHvkQ8xFqasOGSknOO+hlGD5uXLDUjvLdg
X-ME-Proxy: <xmx:HUuKaiP5prlKmoaUvMz4ni0kEiVYLxAoWOfXwFr0AQm53XaHvh1HHA>
    <xmx:HUuKauzinRrfvQ2pm_k8oQo3UKFUe3ElnMHojs5aDLNohNd1PKWpEg>
    <xmx:HUuKaqIljCmqlsa_-R8Nsxx_955hQ3DOiTZgBfmznh6yoV8bzvoDvQ>
    <xmx:HUuKatqYqx6nK9vm0JfErJblqkK1zlWHPyp1zbqvZrTwkRzQVFiuug>
    <xmx:HkuKarHipHWOlhdO-MgJnmZ3QDCOCwFVrpUxLzirXt69eWpmJHgY3-9e>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 22 Aug 2026 21:21:27 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Amir Goldstein" <amir73il@gmail.com>
Cc: "Jan Kara" <jack@suse.cz>, "Miklos Szeredi" <miklos@szeredi.hu>,
 "Ian Kent" <raven@themaw.net>, "Chuck Lever" <cel@kernel.org>,
 "Jake Edge" <jake@lwn.net>, "Ilya Dryomov" <idryomov@gmail.com>,
 "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, "Jan Harkes" <jaharkes@cs.cmu.edu>,
 coda@cs.cmu.edu, "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Andrew Morton" <akpm@linux-foundation.org>,
 "Miklos Szeredi" <mszeredi@redhat.com>, autofs@vger.kernel.org,
 linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
 codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 03/12] fsnotify: don't hold a spin_lock across
 fsnotify_recalc_mask() calls.
In-reply-to:
 <CAOQ4uxj6O8Ukbn-vWU-o+zOAYyofokCTAGnSifSDh9-PACCTdg@mail.gmail.com>
References: <20260803012648.2195405-1-neilb@ownmail.net>
  <20260803012648.2195405-4-neilb@ownmail.net>
  <CAJfpegs-k3skRGiwZvQLzD7OrAK4KL8zwmpmJKyjRHSQ-rqX+Q@mail.gmail.com>
  <178642552869.2852630.11443303758249822243@noble.neil.brown.name>
  <178675372176.2852630.1305553887009521382@noble.neil.brown.name>
  <oh2lg2agqxwqopecacq6sfdnky5faxidwsybkvbwbq24r6tw6o@4swfog5ocwwb>
  <CAOQ4uxgtKvKmPaK8rPAZDSwu0Hr9JAmqJi0a1VX_Rg7jDo8HrQ@mail.gmail.com>
  <178709583480.2852630.4575326968116183366@noble.neil.brown.name>
  <CAOQ4uxj6O8Ukbn-vWU-o+zOAYyofokCTAGnSifSDh9-PACCTdg@mail.gmail.com>
Date: Sun, 23 Aug 2026 11:21:23 +1000
Message-id: <178744808383.3510150.4744569341920131567@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 19 Aug 2026, Amir Goldstein wrote:
> On Wed, Aug 19, 2026 at 1:30=E2=80=AFAM NeilBrown <neilb@ownmail.net> wrote:
> > --- a/fs/notify/dnotify/dnotify.c
> > +++ b/fs/notify/dnotify/dnotify.c
> > @@ -75,7 +75,7 @@ static void dnotify_recalc_inode_mask(struct fsnotify_m=
ark *fsn_mark)
> >                 return;
> >         fsn_mark->mask =3D new_mask;
> >
> > -       fsnotify_recalc_mask(fsn_mark->connector);
> > +       fsnotify_recalc_mask_inatomic(fsn_mark->connector);
>=20
> I don't think skipping update_children is correct when called
> from fcntl_dirnotify().

Thanks for catching that.
I agree we shouldn't skip here, but also we mustn't call
fsnotify_conn_set_children_dentry_flags() at this point because
a spinlock is held.
In fcntl_dirnotify() is it safe to delay that call until after the
lock is dropped because fsnotify_group_lock() is still held.

So I would like to keep that part of my patch - the part where
fsnotify_recalc_mask() (and dnotify_recalc_inode_mask()) returns the
"update_children" flag and the caller is responsible for calling
fsnotify_conn_set_children_dentry_flags().

Some callers call fsnotify_conn_set_children_dentry_flags() immediately,
some wait until a spinlock is dropped, dnotify_handle_event() wouldn't
call it at all.

Your patch might be a good addition but it doesn't block the d_children
walk in all cases where a spinlock is held, so it doesn't help my
immediate need.

Thanks,
NeilBrown
