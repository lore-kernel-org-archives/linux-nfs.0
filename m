Received: from mail-ed1-f48.google.com (mail-ed1-f48.google.com [209.85.208.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F9E63ED3B2
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 08:36:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.48
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787560584; cv=pass; b=aQGL4ANIbf26MbuNEqP3AvoYhQZy7BJHxm87/oJxt1+Uqhlc/sSSpZe43tNgO1xvg74wK19iLbaCX2ed4+yevht0mmdAvoAmhX/mOqCfZOb4swhJkpKkpePTgrAvW1JJJPI/u03FQcPyyTdWP3IxdxfHCz6T6m/Kv3UW8XV3ojA=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787560584; c=relaxed/simple;
	bh=tabZVc34j8IumhCwsfaTRLF3MfP3CF3MKY2fkomDg10=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=lC9KmSMOd8PjP6chDo0JZD37Rij3NxnW/L8Hh7i33zV/wXz1AGh7zTYHFkz52eMorLW0Pb2EOwPVmtiHCj1Xpv/VqsiHcuqt8q+n3+tCfQ2r6u70x8UBmjhliKCZizqNERzYaz9a2nAGhhWjprsMrM1+QaVreeCFMniw8vBWqDs=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=UxjOxEzh; arc=pass smtp.client-ip=209.85.208.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UxjOxEzh"
Received: by mail-ed1-f48.google.com with SMTP id 4fb4d7f45d1cf-6a3efa2b38aso5766209a12.2
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 01:36:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787560580; cv=none;
        d=google.com; s=arc-20260327;
        b=hptoYURqVAXsoXIm5mgbla4LWQq9Tw0qa4HzppQ6KTiI6PPx4roiBlpoC6VHU9dmAK
         fntU2kJ6C6k+/ZvYDEAyqCLCcKLBWBgIItk4EFxE6jDmaIHdbvJgMKiiwgEw51Ek7KT3
         Ll7gdK2RQSrTN5ZsSPsL422iHOBeVDvxcHqixymgfqcW1hf1CCyyyZJcTI71EPEHDm62
         PsIvKoTJHnjw37Ho5BEH5XcKrYuMV2XR6eM5TKCXow5oNZDo3KAit0pJY3pjJoRw0oaU
         5tZdunU3lDsM2cv50Zjr9O5cB8YdiBvwDqNh2pWmgcesCKW52fbxP30f2jYQjt71SPpa
         THsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=YsrEM68gz5Ntl2SZWVPwBml/ICqiBorzNsDyRtB7G9g=;
        fh=xL869AciIwua+Iivg7xhyMPAV/T6Ykz12EvG9HEYIDU=;
        b=kKRcxDEjD0DGFtGmyhUQN+KEaFhGE56HK4k0s+/kVDQKFI/l1nJJQTYvj4N3I4D4BK
         DFOVy7AMWRW1fhKiG2c8vt1VNUdrq4hn6ZyASofnGzRzLwdR4xGOjEBZV6uiDAoI3uqw
         veswA2JqOo4x9aWYFrh8IlHWIwg//fim3vNDp9H2jjdE6Ipm3/TbAdCcBRMUa3D6Dca9
         tkBiPPJJKOfKwCclm6GqUsRfej9MHaoT3baPWxeyqpvksj5z3VLhJtE7ZAhO1M98bS2K
         nUFQot9rQgRqEvCIibPpm5xYHomfHW0SWEaseZLPdbwfpD1NGFt8Rw46ZQNhpt0+WEGf
         k/og==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787560580; x=1788165380; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=YsrEM68gz5Ntl2SZWVPwBml/ICqiBorzNsDyRtB7G9g=;
        b=UxjOxEzh7qZXH9FXfOFAMJILYY6gZdcHFjOll96505kRuCYah27cYh6X80YPDkXjPL
         u9wFFrzNW4VG2gGghYnRGxpbpfv3Xr/1kZGKXnHcL2AmjHmTYm0yjzsoNz/UkB1f+zEF
         yRsIV+tX06P4z4zkm3lETGDcm1YdunEYTssCR2DeGZrEtJnFIGphdNbz6yG3SSGn+FS+
         PhfUMncy6caHgum5IdtL3u9rszswhRpvd4kKKw7OHqUFlFhOsSFYILQgXYDWxN6aLtt5
         OHGluBvVJW+8XmNJPQrdCwL+87bn38xKTkaNkHfws5brj713+/Ve7ktwNWMuHKmPMNIo
         Pmuw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787560580; x=1788165380;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=YsrEM68gz5Ntl2SZWVPwBml/ICqiBorzNsDyRtB7G9g=;
        b=aTksjh6gJ8k7q7LXwe+6KP6sAyYOffDoHuAwNnMf1K9eDDk5T0fGJ4O1/R/CclBEGc
         S8hvC/KO8Kib8FqOesvkPBIOMao+1uW30IfU+4BvMkcCTV7gb1gn7AWclUyt+4kTpjJt
         pb1xGOCo0admffdzbhhrbPBENuTvvlCzM1mUMLgvHifTCmo+7lMqOdtS0K4KdFc2jmmS
         +uYhLpIVouhLKd4qzw7ZeUqUKPIaAleHJk4tmWTjaAY2qhtBZcI2fhmcCBrJL4mql2Bg
         E3AEtbIEEE0MWVcIdGXOOV/CD75gxoP3LtswmmoelurhGyEQFEQWZ7s3UEsRaAvdwU0K
         AzWA==
X-Forwarded-Encrypted: i=1; AHgh+RqT7C/axTWP7OxMRV6hE5sRLtn5h4beyIbXgyeQOj7MRX1b1oxEyQq/BBDOkjVybGthpdI8yIm0Zno=@vger.kernel.org
X-Gm-Message-State: AFuF++n40gwH0uxSiGabTfgq0S2om6zx3p4p4YrAywwbQIMADUBZjCPz
	eCbmWdLH+I6dodBVeOOn1m0f7tArL3AQhYIxfqMEl3Czz6esVDdK1r84IuG0/T48GwU++OdMHAN
	YLGNp2Im9ewnGof9sdK25E/4q9OKteDE=
X-Gm-Gg: AR+sD10SkOykAgeu3ZT8pmFZpMI7MXb/IJHR3YIf4iB7zClK/oQrsJxRNOa8WLbq/Cn
	LWgkrH8eoe3u1ZnuCq1/niA7IcsgeWt3OaABmA86FPwmnAggueKnYGqrD8XmHydncjFLNx9V+S9
	3BBaJk/x1ikCYXWiPdXjoaO/PjB8QsSOCN3WsDTNyOnQczQXsP0Qz+EHvSWzEpl7Y1nJS/2nxp6
	fxtYoRDJbmo1bzVfBnNazrVLrXxdqA4rGpFjIbVa9iAm58XrSYG1w0A7smaz/hSQci1oIwet491
	8jkj2f/MWNOvpZkOiq6nG9MS1ib0HeIfJ6XwW/ROfOoNrw==
X-Received: by 2002:a05:6402:21d7:b0:698:5610:76e5 with SMTP id
 4fb4d7f45d1cf-6a42f1a7996mr25338353a12.6.1787560580503; Mon, 24 Aug 2026
 01:36:20 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260818225715.572140-1-ameer.hamza@truenas.com>
 <aoVHBkmPNSRakbYW@infradead.org> <9ad95194-983d-427d-9a07-c9eb0891d1a0@app.fastmail.com>
 <CAOQ4uxgUOqFv6pVmdT_+4DjA0KQoQDCzN2Xz=xm1FyumewHZXg@mail.gmail.com> <5fb0315d-636c-44ff-8dcc-b4403e3be7c3@app.fastmail.com>
In-Reply-To: <5fb0315d-636c-44ff-8dcc-b4403e3be7c3@app.fastmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 24 Aug 2026 10:36:09 +0200
X-Gm-Features: AcwNN1WbUUrdIhE63ctkhUNUI50-KXFxOZ9whJCv-sw8tICCqnP6sVVvcLZEnP0
Message-ID: <CAOQ4uxiVHcu2BUZejjS+YPuyyFWcsMwkpd+GxoZfxE_WKumY_g@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSD: Fix duplicate fsnotify access events for
 iterator READs
To: Chuck Lever <cel@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, Ameer Hamza <ameer.hamza@truenas.com>, 
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Christian Brauner <brauner@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Aug 23, 2026 at 6:21=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
>
>
> On Sat, Aug 22, 2026, at 6:21 AM, Amir Goldstein wrote:
> > (1) In this series
> > https://lore.kernel.org/linux-fsdevel/20231122122715.2561213-1-amir73il=
@gmail.com/
> > we intentionally moved the permission hook outside
> > of the splice iterators because we wanted to avoid calling them
> > with freeze protection held and also there were some duplicate calls
> > for this work.
> >
> > At this point in time, the fsnotify_{access,modify} post hooks are
> > usually called
> > from the same context as the matching permission/security hooks.
> > It doesn't have to be this way, but it's a good mental model IMO.
> >
> > (2) emitting many READ events from an iterator instead of one event for
> > the user's READ request is more noisy and serves no purpose to users.
> > In most cases (but not always) those events could be merged, but at the
> > cost of futile CPU cycles.
> >
> > From a quick inspection of the code, it looks like:
> > - fsnotify_access() is missing in vfs_splice_read()
> > - the naming convention for splice_ do_splice_ vfs_splice_ is a horror
> > - we could make the low level splice_direct_to_actor() static and possi=
bly
> >   rename it to splice_direct_to_actor_sd() or something
> > - we could export vfs_splice_direct_to_actor() for nfsd which wraps
> >   splice_direct_to_actor() with permission hook and fsnotify_access
>
> IIUC this last bullet seems like clean layering to me. Do
> you want to propose a patch or shall I?

Be my guest.
Maybe Ameer will want to post it for v2.

Thanks,
Amir.
