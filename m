Received: from mail-pj1-f53.google.com (mail-pj1-f53.google.com [209.85.216.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A0B3377AA7
	for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2026 20:24:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.216.53
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785529460; cv=pass; b=AjU1OBSub/EWmnUPN/9V80k2JqO3sfnNbe2WVBoxGDs3+kbPgiMxq4xLuitC36tGsVLWzdF/Ddgu8Ho+RUUZvKexdeClDoBQLH0GiGCKFUq+ednQB5SsfRkTcIugdtxhGt063xTk14eqO3KSFsNmagPP9aKDN18oGZ2tC1tQlv4=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785529460; c=relaxed/simple;
	bh=Rk7oo7lnkRtvOGIsTANDyDqMivFVxyPzc8I194ixEdo=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=m5is7ekNPIlHJRtRKGVETaBtXYvnEUpQftwv8/mErsSW1gF7yXXbZbqS4SEZ9NYTnp3IuXkE485JesqLIpwkZpjoCkFy1TE4AH8R4yFpUZSLIl86sqL2LAERswytmEPUYeXAwoIOtkdiZOV1sKekFB1xqSpFGf9CHO/khol7aas=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com; spf=pass smtp.mailfrom=paul-moore.com; dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b=bcmjXypw; arc=pass smtp.client-ip=209.85.216.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b="bcmjXypw"
Received: by mail-pj1-f53.google.com with SMTP id 98e67ed59e1d1-3811f512167so1425853a91.3
        for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2026 13:24:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1785529459; cv=none;
        d=google.com; s=arc-20260327;
        b=tABXAJSvpDcs3WIRlJb9xieH4vRSeDfaki5rILiWv+HfyRGbSlsmAa5frQQQEiUmd+
         1nCv/Pn4DZc7G8W+rMs8N6GpV/528G0kJx8VowMX9XKQXVHPcAclmeKMcznxULqeNQz0
         dTlFGH6OOL8aDkeJe/0RSINKJ3HREvoVuSXYrC5VLuj0Xk81wwjEbA0R8YOJAA2Vy82T
         ZPSxRX+oZJ+Pmc49USMqg8rFzwnKaMyOpTJm14VxZQavir8QcLbrs2/tL4bLAicQpXrH
         7Jcw/jeE1RbPy/1lLXnY7ytbuY+wZVrTJCmdyOTB3VziiqN9uOVle0i2K5CiDjkpaO5b
         5nzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Rk7oo7lnkRtvOGIsTANDyDqMivFVxyPzc8I194ixEdo=;
        fh=qB5DjgQBpL96CSEbD12omF2YVcTBcHY9FkvuMDBAnaw=;
        b=M+ELQsMoD5znLfOPCEdQdFdmwlG11W6nVliLVLnmkxkjEOL/C3zWo47QQwguGRgw7j
         xDzsnXl081qSWFNXhGaotMF810BvQCib5EM6O9bM3xMgEBHKvIrNnJHFJannFDeX5R3/
         vCSt0q6YOYfQ3NL1ZIDSBD6BMI+TgA95N6f1AziP7Sy4+vZ2+rykltLj9aBITvtwIH+3
         OoJkhtNybC7L24/IpYv6+ZE5IsPV3QQb4HSYJSwO4E6j9x6QhMBowCt4VKynmpl/GEln
         i/eyf9B9eRpY8INv8lqAMmmrYNxTxAV7OeUNtoWsc959DApaj3kLyPMNMZ9KxVjPH+D6
         iM9g==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore.com; s=google; t=1785529459; x=1786134259; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=Rk7oo7lnkRtvOGIsTANDyDqMivFVxyPzc8I194ixEdo=;
        b=bcmjXypwzyHOE/x+M5GCdL+anwsAcYTJ1KUWko2Jf4ZRIuy0HHGn3X1uxM8+7n7FyU
         rlKUZSP8HC26gEXMdrwMPgbFHO22aGCv5NXsKt+ZIRGpGvSnf7UXMM1lwXiBcANJlAoh
         LU8hKTF6/s5lFum3U0n+csUmQKsO/5y40z/ixr5GKTUMLAoyj3v7herhmK1G5S7EL/2F
         CbHz9v3cj0bQKY40TRfjJ0zUbDtUm0bzvhGfn/tHGUU1zbEKE34eeQqAWUwNS9qVMLWv
         V6ysu58Bw6M4zZsQJCJUqSIX3dVMnpfbiT8SqKiUTFRBjAAKWerz1FrAvxLHqq4AFCwT
         0+qQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785529459; x=1786134259;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Rk7oo7lnkRtvOGIsTANDyDqMivFVxyPzc8I194ixEdo=;
        b=fY1BTlyDvbLzrtkg9Q4UdySPPvfGP0GlXJ3FN3wYzOXr2mLpr+yAqfzeWpZr2VbQ7B
         G+dKBO5/4s/xP++ZjA1V+f+wNFAQUYeK2ALIwIVOwlOVjFP/vtB0a/0g2dDxHRW+bjQM
         So+n1XPh14cudYTIjun4phVQxK/xkvsN7oikpI8QcLMKSxSMdk3dc6/RWtKThVoZQSmO
         81p64N047L7dmvIzs7nzUBF5ct9ma+cm/X+gj33+h5V7vz0YACPsX9CGCdR2QokgSd2b
         zfZ7VF8svJRhE86s6c7rx5MHmT45bTr9nPufpvK0YgwVY+DoEFOSRELVBxaj7r6oqvw7
         lGVg==
X-Forwarded-Encrypted: i=1; AHgh+RpchUQjCDLApyBJch8h237VYCd68+H4ZyKyM/fFCu0i8X0iGIpZI8vdnZeACYuTxKK1FDcWERLbKjA=@vger.kernel.org
X-Gm-Message-State: AOJu0YyEjVUk1zhubk88gwxzfXJSot5uAblAjVHXI10Jrb09beymH1lv
	vKbniv2S8Erh0DunKZcdaGIx7ysm/RTbZ+9BHORJe+LslrsnX714FRqiAVPZFQuyyvpTz9qgwV/
	3euICfW+jsGDJoHgd2O60B7x9Xu9f/hjpRtpnns69
X-Gm-Gg: AR+sD1208YsNYtGQbtzAV7DWFFh0ydj/gCOC7hUh9VZkXiwF4ZV+T9eu6okTO/K4ft4
	A65YTAE4IMSlxWvvXfjWvwLUwl9OZcFau6VyhovqnuuUw0KIH9O7VtfxATWk6SSmQMVp0ZE87h0
	Mrbqtv+T9OfegmHOXz0Mai8rSOkYukrh+rqjky5ifNVbfditeQmPFSEfPHkpSNF0rVvHW/rX0nv
	mbIdUhHfQFUTDgA3ucZe6JF323tYWPChfvLjvk53MAf5/k/YiAoHojPqxEXSYryyEirkqTIazf5
	w6IqlKw2+pK1ofAJTJj6S6NjgXHAoFju355zFw6/Uw0YvfAcZohsfJ0=
X-Received: by 2002:a17:90b:2248:b0:38e:8050:e63a with SMTP id
 98e67ed59e1d1-38fbc40941bmr912838a91.6.1785529458966; Fri, 31 Jul 2026
 13:24:18 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20250428195022.24587-2-stephen.smalley.work@gmail.com>
 <20260725200958.4471-1-cel@kernel.org> <CAHC9VhSGn6UQ1__HtqjKWD1KgyMOhHYYKny5HnVuPAuvqZR9aw@mail.gmail.com>
 <CAHC9VhS6B1yW+8G9Biqit5CAmcg4CwCaWbq1B+Qpo2n6a=yqnw@mail.gmail.com>
 <8df686c5-f1cd-4298-97de-14c2c4638496@app.fastmail.com> <33ba1c27-27cf-4b83-9c69-1ec40023a5d2@app.fastmail.com>
In-Reply-To: <33ba1c27-27cf-4b83-9c69-1ec40023a5d2@app.fastmail.com>
From: Paul Moore <paul@paul-moore.com>
Date: Fri, 31 Jul 2026 16:24:06 -0400
X-Gm-Features: AUfX_mwMO6Jjth8dKZRaqKSi6vQy__VpnKWqSL55ru0Ew4-Pu1uuDWVesrbZjVE
Message-ID: <CAHC9VhQh5D_Py4c0JCzRWrcHbE5QSnencD7-mzzaZNyZGGE_NA@mail.gmail.com>
Subject: Re: [PATCH v2] security,fs,nfs,net: update security_inode_listsecurity()
 interface
To: Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Trond Myklebust <trondmy@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Stephen Smalley <stephen.smalley.work@gmail.com>, 
	Achilles Gaikwad <achillesgaikwad@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>, 
	Christian Brauner <brauner@kernel.org>, linux-nfs@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 31, 2026 at 1:28=E2=80=AFPM Anna Schumaker <anna@kernel.org> wr=
ote:
>
> Looks like I did have it in a branch with other commits for testing, but =
I
> never pushed it out. I've moved it over to my public linux-next and will
> pass it along to Linus in the next few days.

Perfect, thanks Anna!

--=20
paul-moore.com
