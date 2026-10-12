Received: from mail-ej1-f45.google.com (mail-ej1-f45.google.com [209.85.218.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54A633932D9
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 08:54:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.45
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791795250; cv=pass; b=CmFVpaGZ7jWs9rtTW3PA+tR9y3ymsZFEGsG7xK2+9hx2sIF4ovCcnlxv4gw05FMhSaMrUpG/CZ50NmCENRbnisCjlxOGYJ2l3OL1uqPs0qUrwaDhaQ77pJzwcpLDopgnX+xoQXyGkMeqh6bPG6s9hIPk/yVGzwNRDGh5QMFbMEM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791795250; c=relaxed/simple;
	bh=U8KYa+GKF1C9UPsHeY4iAeTE7Otjx/lQH7oCwai2CbM=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=SVPq2+UzeVWyixOsUr1D3roZn0ISFBtspS6VR3zYQ3XEWbz0MGNBclGeM1CSpR/6uxo44+uHj/QfoTq8haI9MVJYl/yeCbXmpLqXu+w2arNS5T3U8bxNTF6tt1AJJBGBUih8usUQNVoVLDHExRJOVbyL2nvzT5tXJeoOHwLvt2U=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=p2P0Fe77; arc=pass smtp.client-ip=209.85.218.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p2P0Fe77"
Received: by mail-ej1-f45.google.com with SMTP id a640c23a62f3a-c33bb2f3e6cso172032666b.0
        for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 01:54:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1791795247; cv=none;
        d=google.com; s=arc-20260327;
        b=rJI1ZDla16x/ey4G/QApZvazsmyMCfFtqMWC0ncVh5w/MqdlwmHNDOJb3QnPw1Hgu2
         yXRPpoh458rcBeMprQ57BSsZ7r8B/rRbLNInxOHKVp7CDsid7Ax9vZgah+HgoHNCHYlq
         g1QMI8Bz/AyEwNF1EwtDjpG9ip+0NInGkB/A/LNpZFi/E/0duWjSl73yuayA/q4hx2EO
         iA0U3qL+u2qPB7HVVGHEB2LQprWBte/heNcff6LCJI0EH78el9OEwDZcLP8GbYaREZ5y
         rY9R8dL+6ZLmv3OiM7+raleJr4mSHy2Z8g93TmV2QpSgdodIve68zYAj12Scx4Sp9cNe
         MupQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=GDzP0JK6B/UuY91fBbPuJqjAvfJtNTVXfMNUf1kMpGU=;
        fh=ET8c9hnAQChGO8NqyY3Eve4oz63UDHRTTVtsGOpL090=;
        b=Jq3CKcafl1yJzpV0uSTvucxnqG4P0AXjfM2DkI9wRWWrhhQoN9Usnw/aOOcDKAuZtE
         TM+YnZbkTeQNjhsse9p/g+o8mqtjqOYkD9IY/6HTSTyy2xIPZRJwUrKACDJmgyx2Kk8p
         +1yczjL4H+c51bfMUi92w0KwOGoXGnBAwQIVPjK+HiYbElV/iKPVx5tOf/KHH76ZEx3O
         ujAVkEKfQ9k+AGjpYduy+fcO4GrFzrW3V0Saf0nCC4bkMbVZUqYPRpn2JmbXZo9uet05
         a8WvhHzNa5XYoRpml8BuMDYmed859Ji+Ll3LZZkUlXso486t70isk5fDEBzLWvN7geR9
         Ch6g==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791795247; x=1792400047; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=GDzP0JK6B/UuY91fBbPuJqjAvfJtNTVXfMNUf1kMpGU=;
        b=p2P0Fe77MEiUEQC5rGopAucqgDmzL1y27C0A/VSFYhV07YThgEtEuklJO4WzKedWU1
         YHwajZ7hGUywPzh0/nT1OiQPVsMgZ7waukszcRd5fccGfcsbUQaAgKyhXjfXYwx+8t+i
         dEmTMZUqqK5M8CkmNrTyNGG7xLHuVBLQCPjVTt4ZwpSxe4OeW3KxgIyzGy47+1JUgD5+
         wlEx1H41ThFBJI1X5CDNPLn4b3fctXFiHgTyJ1dYk69Xwq9Ic4QvbGGpnapZCkuOdmdX
         qp/Ju27iUIAhgWe3o+7r2pgIYlFX6gRhQbz3c1WNIQnwQdSgLrfBNYsCV/5MpGDCeq3G
         UXHw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791795247; x=1792400047;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=GDzP0JK6B/UuY91fBbPuJqjAvfJtNTVXfMNUf1kMpGU=;
        b=g8hyDphaAxbEvJ8EEzvdiJTRFi1X3xiXipfnP0F7sdg1bvy104wMM8camfCF3M+go4
         FbVTaPvuCeNLU7IJlZExSIeXrpbkSUQwiDAtDcwbpof6YJBDjORTuhtDCjuiQHCI+dT+
         LPRSFiHUrONaCbY4eW16y1NE/+G+MOaUNAOECfwVcCUOQTPlNNffgY4J2iZQVBkkFCLQ
         997So+15S3f0lYPgdGyZRXhJ2AQZq5L19aLCkyylza2gMHcbiY4bJfcnOGJ35mBif1tV
         BzD3Mr909r0KQlp++krXt/19QWdYbHQUgzP8a5JtuoeXU1lLCm8bl2o+h+vBXvcoUa+Q
         Ucog==
X-Gm-Message-State: AFq9FYIGShllpnyPAPbCIH8C12CYH5a245xYWuG3uPBfngptdd53XhQA
	qLf5kTBwpVa7HmiHRfJaulIQblAGwgC3RQKrmz5GgDInfBTsyJGHiNXzVeJKKyuJ9vRXgoL82lV
	yW72mzU/DQ5K8XwfwZol0tiLRt1chT/s=
X-Gm-Gg: AYBFou3SApKHgvsoj24NGowqET6gNbwuSV/rqUE3aU2xDOUzeoMGVhKzuZxm/1yFP0I
	oR4HDuSZ9LSWlb3HX6ZOXkOb3HMcU8KIab4QfzTEMCGY/drjxJeJGj0xG3BNyDO6CGhnbui4LqH
	ydnSwollPIm+PAPJiwEaKCna35kpYnsdWZ/8Q8PGpWSV9eDJ0Xn3yhfe/viCBl64j7zg5DPWCHJ
	rhQjeE33wMkXB9El0pxpFDt1k2AoBf8N0Xt/nUJFQjW11kbAiVVMI3+gmEHBXMCtk6P5I6iMvol
	hDnM5nADW4QcaTi6DdwOZGPbP3d+yyzAHKYbvAlvGHXeoX1UfFUpV4w=
X-Received: by 2002:a17:907:d10:b0:c2e:49b4:ab8b with SMTP id
 a640c23a62f3a-c31a9fcead1mr928654066b.8.1791795247308; Mon, 12 Oct 2026
 01:54:07 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260928083739.643010-1-bint4b13@gmail.com> <438f1a46-ed0f-470c-ab1a-347941e07570@slotpi15m67>
In-Reply-To: <438f1a46-ed0f-470c-ab1a-347941e07570@slotpi15m67>
From: Jinpyo Lee <bint4b13@gmail.com>
Date: Mon, 12 Oct 2026 17:53:55 +0900
X-Gm-Features: AclHuK_TWkezfrYh0JkaCjAgtE3MfHL2EUA1XhUFH25C9PlJLfipKtOWUQpvWZo
Message-ID: <CAAC4NB=M2zdG_Z=5nU5jFd6mAH00c3ACJAzjM360XdKDBZDQ9A@mail.gmail.com>
Subject: Re: [PATCH v2] nfsd: drain pNFS fence work during state teardown
To: Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>, 
	NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
	Tom Talpey <tom@talpey.com>, bobtobabz@gmail.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Chuck,

Thanks for pointing this out.

I prepared and posted the separate stateid lifetime fix you suggested:

  [PATCH] nfsd: prevent a double put of revoked layout stateids
  https://lore.kernel.org/linux-nfs/20261012084722.5168-1-bint4b13@gmail.co=
m/T/#u

It marks the revoked layout stateid CLOSED under cl_lock and ls_lock,
takes a temporary stateid reference before dropping cl_lock, and
serializes layout segment draining with in-flight layout operations.

The patch was rebased and validated on nfsd-testing
d918c664efd5ec6a7309e98f567fb018bcde0e11.

Regards,
Jinpyo

On Wed, Sep 30, 2026 at 9:45=E2=80=AFAM Chuck Lever <cel@kernel.org> wrote:
>
> I'm passing along a sashiko review finding here. It was confirmed
> with Claude Fable 5.
>
> ----
>
> commit ba79c2d330cd7f4c60c83de92ba0d54184b97c08
> Author: Jinpyo Lee <bint4b13@gmail.com>
>
> nfsd: drain pNFS fence work during state teardown
>
> Stop the layout fence worker from being scheduled once teardown starts,
> and synchronously cancel or drain it before the layout's client
> association is released, so the worker cannot use a freed nfs4_client.
>
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index f487ef0916d9..3d5792b6e997 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
>
> > @@ -5870,6 +5871,7 @@ static void nfsd4_drop_revoked_stid(struct nfs4_s=
tid *s)
> >               ls =3D layoutstateid(s);
> >               list_del_init(&ls->ls_perclnt);
> >               spin_unlock(&cl->cl_lock);
> > +             nfsd4_stop_layout_fence(ls);
> >               nfs4_put_stid(s);
> >               break;
>
> Which reference keeps ls alive across nfsd4_stop_layout_fence() here?
> nfsd4_free_stateid() reaches this case through find_stateid_locked(),
> which takes no reference of its own, and the only status it tests first
> is SC_STATUS_CLOSED, which the layout case never sets. So two
> FREE_STATEID operations for the same admin-revoked layout stateid can
> both arrive here, and the nfs4_put_stid() below drops the same hash
> reference in each. nfsd40_drop_revoked_stid() has the same shape.
>
> Before this patch that race is a double put. With ls_fence_mutex in
> front of the put, the second caller sleeps in mutex_lock() until the
> first caller's nfs4_put_stid() frees the stateid, then wakes on the
> freed ls_fence_mutex and takes the freed ls_lock in
> nfsd4_stop_layout_fence(). Can that be reached from two slots of the
> same session?
>
> The SC_TYPE_DELEG case of revoke_one_stid() takes an extra reference to
> guard against a concurrent FREE_STATEID, and the delegation recall path
> sets SC_STATUS_CLOSED under cl_lock for the same reason. Would setting
> SC_STATUS_CLOSED under cl_lock in this case, before the unlock, close
> the window? Since the race predates this patch, that guard probably
> wants its own patch ahead of this one, with its own Fixes: tag.
>
> --
> Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
