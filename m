Received: from mail-ej1-f53.google.com (mail-ej1-f53.google.com [209.85.218.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3077042E8CB
	for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 13:27:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.53
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786973264; cv=pass; b=FdUciahS9F/ejTOzlAilDVkOnNjp38nsM9p/j3Eg5vrcEvDGdIo36oYtuRv14/ySRZK865FUX/dSE9uwKBtiX9L1hyRjYg7cJKpqWbMTkaTna7fWqL5hAr26aXT0H81CtxR7msfkWRQkPRgjxzOEqh1EfeyPvqmiXCiImB7QRjk=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786973264; c=relaxed/simple;
	bh=1DlLwTW104OszDT/1II5RPaSBCaItMuBX3O6KwNsB5w=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=sBRKMng+UGTzLoPLlkTuo4TgtkGoQu27ynQaEMEyGva/gQwsUy3W17lFB1qw0uxEvs5sLd2OD6erIoWbtim/p3ErIQiTnjkTZrvmIVUt9xnXYz1/SGKhtMXrodERuf2Op+ULFg+85m82uYC5+Hu6377KvhD4nK8lu6zNvaHLN5M=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=aFjYFU1t; arc=pass smtp.client-ip=209.85.218.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aFjYFU1t"
Received: by mail-ej1-f53.google.com with SMTP id a640c23a62f3a-c2020421077so557063666b.3
        for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 06:27:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1786973260; cv=none;
        d=google.com; s=arc-20260327;
        b=RGvFV+ZvY0cPhy8KBO48Rwfr2LH7ErX5GyVtupb1a/55mlvDFI33q3gQs9BaLZqZT+
         ybPZvuOk0cxytgxbpz0+CACtk+hSAFDxBhQa0gGsTiwsZMyswnbG2i4FiGdrSIXJtTV+
         OzXdP5f09vaTGGoPecCAz6GFcMs09Un8H1QE3q71tTpJ5aAe8mFuq8nNBTfoeo/40P+4
         29nKS7uaWOxPTT6zsE2A8G05cDjCtd8yonHfyKfdR2K6C5tsFrX+xt+YPebRoYvcWj+X
         mifqxoiO6ZV2iZsJPBXAMw2trBTgnkVZ0f3gr6vwG3VVVPTRYlnkFE9MSWCCAq6IS/F4
         CRng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=5PImzGjw1as2Qy3XGkcxUdLAPTNoN5hAmeBUTq6U/L8=;
        fh=0GWXJUnoVyfn8G8ZWyGXK/AnUAdzjZwhYuxC4H5hGM8=;
        b=EHqn0nCwFmga53VwG11tEaYIhCamwJQA2nLKHVSxSuThCCSET2cPsc2QDxASdb8FDp
         ZoLfLx8bAGX2ynJSLzT2JyzhnGgvCUb6SELHt4TI/D4v1gcBpbwKOktZqO++yUZwmyiX
         fW9MObMz4m2N7uEdag1fpfxOnbAIdCFdFnvncMo+UPNESdVUusN/rh7rhuAHOddyVil6
         ot15K/za+qIIYy3WKK8NYTnIRlPqW9DTDQp62SMmAxggv2EscV0vbWf1b3uPDzGqFt4a
         tZsh04DQ9s5xoiRTORUBjeaK6J0Hbp5z/NzZ+oxH8RQN5V6YrjsTDYDbZTuYj0Dh9W78
         XtGw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1786973260; x=1787578060; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=5PImzGjw1as2Qy3XGkcxUdLAPTNoN5hAmeBUTq6U/L8=;
        b=aFjYFU1tlLPMRER4pipHl3ANVxgkOpp+ndm/NLf7Pq83xOKblowW91NietJHufVnaU
         mG6fHdWFmqeqE7Za+MQqPL6w4geucj6kn1XHrsbXH9fB5A51lgvvXUgpWIP+3Pf/Kr/6
         E3yOuOXV2xWiDnVOHp+WQEOghMjyssS26hPeiD6oTng8zPUYOFghMQwJWe0lRL0POps+
         SuzQa+NquXQZJGM9fqIgYAOg6FkJKEnN6kYmTkEj7Mdz7+EuQF2GKfaT1P53L8FxYxdF
         9+WaDR8hgyKro9QERMbIB8mymp8IjIl17/FmueYmhk4/X5idZLePC/Umu/42+ULghIi/
         1Zjg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786973260; x=1787578060;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=5PImzGjw1as2Qy3XGkcxUdLAPTNoN5hAmeBUTq6U/L8=;
        b=BJhW69NfzjiNuWiYrCkh2WGGWxY5DmKLdy+chOdOoJLYJoIApA9rGIXy/SuCNVljZE
         m9K4UKNnY0VaOXOt1u2yK2EVtUbHw8bsm8AXTt+bTSJspvhQYuEJym//zC3YCCUHLtIH
         /DywJs0hL0/5LTgMujw6ccn3B9SLsseDzt1Vd12+6bv4OzFr31i7riLX+1m8rR7mcWAs
         RnSD6JrXfoR6UbTOqcmNs71FqzaEE2ts/VhQkKFyyhY4mwzwy4Rt3aFsqzuR0NxJXrbM
         bpth96a44KOKzFxf8Er/+MSWIHGM12U/hsbZP3vuf3iHxTMmMwj8s4Moca8mSdE2SGCA
         gQJA==
X-Forwarded-Encrypted: i=1; AHgh+RqKiBlqdRM2ZvM+Vnt2n/6mHWCcaU0d0f4GaQmE55PBR+xrJBmNrdBmgq9e9C+axpPDOaG0DtiePMI=@vger.kernel.org
X-Gm-Message-State: AOJu0Yy/Rth12C5JeGEXwK42aNkOUaG2wQUWWsQLZRtYdHthC+YQ4hCV
	ineyMHoflKJ+wsaxB1nS9sBm0hi9HOvhWFPjLmf1gz0/7S5tnB3QHxJAOAmO7RdXhNphKAx0fyB
	sj4OrvO+swzKOw7ygA61NV/2oZ3/6fFQ=
X-Gm-Gg: AR+sD136Kx64KCF13vvpo3fj0+hxo7ikUOrvH9jRjw/paFLZpzgULxeezVR4po0UuWB
	VUDydmfukpYUZK+OXsqPdXwJkRr/CHTq+XA/QjwE5FAz1xMiF2/qQBwJyBMgdZAEpCYKBZfgbY0
	lhHHcKNUFN8ml5iDPXLIng7b0OfVxNAN/bBfv4QKaWtvZ+bS3b2Co2cEXR4/cr4SrakQKOHf3TH
	qbBFSNFvb1Z7iqxdHod5pBbQxskAoiFaZhaZqlZt9t+upQL0oofKE5TbddQfY/lkSK5KWrhosPX
	HV1BYNBWKB92CeOX6niXHNFzne8DpBseHHAVGWV4nxjuJQ==
X-Received: by 2002:a17:907:5c2:b0:c16:1227:e3d8 with SMTP id
 a640c23a62f3a-c2129c1bd00mr1250866166b.13.1786973259962; Mon, 17 Aug 2026
 06:27:39 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260803012648.2195405-1-neilb@ownmail.net> <20260803012648.2195405-4-neilb@ownmail.net>
 <CAJfpegs-k3skRGiwZvQLzD7OrAK4KL8zwmpmJKyjRHSQ-rqX+Q@mail.gmail.com>
 <178642552869.2852630.11443303758249822243@noble.neil.brown.name>
 <178675372176.2852630.1305553887009521382@noble.neil.brown.name> <oh2lg2agqxwqopecacq6sfdnky5faxidwsybkvbwbq24r6tw6o@4swfog5ocwwb>
In-Reply-To: <oh2lg2agqxwqopecacq6sfdnky5faxidwsybkvbwbq24r6tw6o@4swfog5ocwwb>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 17 Aug 2026 15:27:28 +0200
X-Gm-Features: AcwNN1XGT7C9D5visKW_eW7eV24-4iD41ayTDyPPniVL030x1LtgVNaa9P7WcV8
Message-ID: <CAOQ4uxgtKvKmPaK8rPAZDSwu0Hr9JAmqJi0a1VX_Rg7jDo8HrQ@mail.gmail.com>
Subject: Re: [PATCH v1 03/12] fsnotify: don't hold a spin_lock across
 fsnotify_recalc_mask() calls.
To: Jan Kara <jack@suse.cz>
Cc: NeilBrown <neil@brown.name>, Miklos Szeredi <miklos@szeredi.hu>, Ian Kent <raven@themaw.net>, 
	Chuck Lever <cel@kernel.org>, Jake Edge <jake@lwn.net>, Ilya Dryomov <idryomov@gmail.com>, 
	Alex Markuze <amarkuze@redhat.com>, Viacheslav Dubeyko <slava@dubeyko.com>, 
	Jan Harkes <jaharkes@cs.cmu.edu>, coda@cs.cmu.edu, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <mszeredi@redhat.com>, autofs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org, 
	codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org, 
	linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 17, 2026 at 1:03=E2=80=AFPM Jan Kara <jack@suse.cz> wrote:
>
> On Sat 15-08-26 10:28:41, NeilBrown wrote:
> > On Tue, 11 Aug 2026, NeilBrown wrote:
> > > On Tue, 11 Aug 2026, Miklos Szeredi wrote:
> > > > On Mon, 3 Aug 2026 at 03:39, NeilBrown <neilb@ownmail.net> wrote:
> > > >
> > > > > @@ -116,11 +117,15 @@ static int dnotify_handle_event(struct fsno=
tify_mark *inode_mark, u32 mask,
> > > > >                 else {
> > > > >                         *prev =3D dn->dn_next;
> > > > >                         kmem_cache_free(dnotify_struct_cache, dn)=
;
> > > > > -                       dnotify_recalc_inode_mask(inode_mark);
> > > > > +                       need_recalc =3D true;
> > > > >                 }
> > > > >         }
> > > > >
> > > > > +       if (need_recalc)
> > > > > +               need_recalc =3D dnotify_recalc_inode_mask(inode_m=
ark);
> > > > >         spin_unlock(&inode_mark->lock);
> > > > > +       if (need_recalc)
> > > > > +               fsnotify_recalc_mask(inode_mark->connector);
> > > >
> > > > Is the fsnotify_group_lock() held in this case?   I don't see it.
> > >
> > > It isn't held.  Doesn't it need to be...
> > > It seems to protect marks, so maybe it does.
> > >
> > > srcu seems to be used to protect this section, so maybe we can rely o=
n
> > > that.
> >
> > I dug into this some more, and we do rely on srcu, but don't need the
> > extra code below.
> > inode_mark->lock doesn't protect inode_mark->connector, so moving the
> > dereference out of the lock has no effect.
> > srcu_read_lock is taken before we get the ref to the mark, so the mark
> > and the connector cannot disappear underneath us.
> > A race could result in inode_mark->connector reading as NULL, but
> > fsnotify_recalc_mask() checks for NULL, so there is no risk for harm.
> >
> > Thanks for encouraging me to dig into this.
>
> Sorry for not replying earlier but I was on vacation. The lifetime rules
> around marks & connectors are subtle so we have to be really careful and
> dnotify with its single shot marks is peculiar which makes things even
> harder. fsnotify_recalc_mask() has a comment about locking in front of it=
:
>
> /*
>  * Calculate mask of events for a list of marks. The caller must make sur=
e
>  * connector and connector->obj cannot disappear under us.  Callers achie=
ve
>  * this by holding a mark->lock or mark->group->mark_mutex for a mark on =
this
>  * list.
>  */
>
> and you very obviously start violating these rules with your changes. Now=
 I
> admit I've forgotten all the details why I did it like this so let me
> reconstruct it :).
>
> Connector stays alive as long as there's any mark in its list. Both marks
> and connectors are protected by the srcu. Mark also has
> FSNOTIFY_MARK_FLAG_ATTACHED flag which is set iff the connector->obj is
> pointing to valid inode/mount/... FSNOTIFY_MARK_FLAG_ATTACHED changes onl=
y
> under mark_mutex so that's why mark_mutex is stabilizing the connector (a=
nd
> also connector->obj). This is what is used by most places calling
> fsnotify_recalc_mask(). But dnotify needs to mess with notification mark
> mask from event handling and there we cannot take mark_mutex due to lock
> ordering constraints. That's where the mark->lock rule comes into play
> because mark->lock also needs to be acquired to clear
> FSNOTIFY_MARK_FLAG_ATTACHED. That being said this dnotify use of
> fsnotify_recalc_mask() still looks somewhat racy because
> dnotify_handle_event() can get called after FSNOTIFY_MARK_FLAG_ATTACHED i=
s
> cleared.
>
> Anyway if you move fsnotify_recalc_mask() call outside of mark->lock, you
> seem to make the race with dnotify clearing the mark from
> fcntl_dirnotify() easier to hit. Now in the notification path the inode
> itself is guaranteed to stay alive and the rest is protected by the SRCU =
so
> there's no direct UAF. But fsnotify_recalc_mask() simply isn't prepared f=
or
> the connector changing under it due to object getting detached and so we
> could end up doing weird things like NULL ptr derefs or similar stuff.
>
> So this call to fsnotify_recalc_mask() from dnotify needs a more careful
> handling. Which is sad because I doubt anybody still uses dnotify...

Maybe this is the way out.

dnotify_recalc_inode_mask() can only remove bits from i_fsnotify_mask,
so it is an optimization.

If we just remove fsnotify_recalc_mask() call from
dnotify_recalc_inode_mask(), then i_fsnotify_mask will be updated when
dnotify_mask gets removed eventually.

If nobody uses dnotify, noone is likely to notice the loss of the optimizat=
ion.

Thanks,
Amir.
