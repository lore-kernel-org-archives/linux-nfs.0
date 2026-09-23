Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4EDEB352C52
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 08:13:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790151201; cv=none; b=beZgJoBcrPxRYn/ntkXY59QCAXbo4YNkIKvF5tNzyy2FzYgRrdjmWavyKy8svL5KG78QjGcCKs50srOgMJwa7obvzLDVYvB91HhDfG5PVw7SSY3Vvt2x7WdQsnPV4O8sZ23YZFidmWmDXI6B61Laepv4t+RTNzCJTPOBPEruKvQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790151201; c=relaxed/simple;
	bh=BD6Yc4Awp5mXwTtTdoGGtvbdsAJKf9tOOFNNk3RqMwo=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=gFSRGCsN+U9O/UgcYl+6yUYFL79UqbbE8/Xq4eJd1+lN+5D4TxkWM7THPQCJSpfCFEqlZJsJbmz7t7cYT6kCyPNbaC4bxCy0jhK3Cy+Aid6WLH578u6m4r/XIl1Q3h/7xh4vrbMBgPoK2DmSe7nAnELXKPUZI+XZoWs9coWf42A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DJBmVc2i; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DJBmVc2i"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2FB8C1F0089D
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 08:13:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790151200;
	bh=vs6i4s6cZE2SzhYO9unvM1fDGvN8xO/nW1L12Au3yl8=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc;
	b=DJBmVc2iCWZlbQqynxRdaSplBcDQMpvrfKhmcDtZUpUsHpT+0lFFCAyU8JqcvMFr2
	 uIeAgzoH2ux6fVrG4smmKxl0zo1UjKoeeRiHS8Dq8aJifZBwmiaf5/M7h1Rehujufd
	 LnO01bqLSanFEc5iS8ViKc7UldWX9RgEaQeDpu0Iiw62m6uTY6I5/RsBKbA+urVlpk
	 Lz67+6XHhWSAKiLf+6LEFAbeDTiuI8V/DU6VR0jWZcvPU50kf9pdZ/WZk2lOrHO1Kr
	 LGD0PmDrnrZynfQURrVB4fjKMNaMt0Iy8i1lJQPazvBDBYZ+uNqhq+vygVxw8mGtGL
	 0qyV3PaoS3rUQ==
Received: by mail-ej2-f12.google.com with SMTP id a640c23a62f3a-c254f56039dso87210866b.3
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 01:13:20 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AKwUvBwiCBzZ0vOErDyx4cBiUlTPoVwKY1ue5V2b/DAb6R6scc+nVdzQfMUBG3Ff/zozX3eJbX0jVeQEI9E=@vger.kernel.org
X-Gm-Message-State: AFuF++mtsQSShGDkYiKOLo0dEus4IHlXldQqiJ6XvviAMHa5kAwnBudP
	JgkbI4uk2wvzmX/1DF+VVIUoIx7HTxq0nO8hXjw2oxr9uigQRCUt5Nco/GkG2hTgDLxuqtKzIyz
	k8t0/CeOvDIv9/mObOF8n135+zLYiEqc=
X-Received: by 2002:a17:907:1c94:b0:c2a:6a12:6fb3 with SMTP id
 a640c23a62f3a-c2aae272d7bmr136115466b.23.1790151198825; Wed, 23 Sep 2026
 01:13:18 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260919022441.3305170-1-neilb@ownmail.net> <20260919022441.3305170-6-neilb@ownmail.net>
In-Reply-To: <20260919022441.3305170-6-neilb@ownmail.net>
From: Namjae Jeon <linkinjeon@kernel.org>
Date: Wed, 23 Sep 2026 17:13:06 +0900
X-Gmail-Original-Message-ID: <CAKYAXd9S4x4ghqFOf1J0FO7vDq61mMZWaxnBihQU799jnASZ4Q@mail.gmail.com>
X-Gm-Features: AclHuK_-E_IUYXE5Xo_ebb9zx21UxugXhFsUxDAnoFldZXoIK8bk30DS2iEwx5w
Message-ID: <CAKYAXd9S4x4ghqFOf1J0FO7vDq61mMZWaxnBihQU799jnASZ4Q@mail.gmail.com>
Subject: Re: [PATCH v2 05/14] cifs: allow -EISDIR precedence over -EFTYPE in __cifs_do_create()
To: NeilBrown <neil@brown.name>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, Jori Koolstra <jkoolstra@xs4all.nl>, 
	Mateusz Guzik <mjguzik@gmail.com>, Dorjoy Chowdhury <dorjoychy111@gmail.com>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Andreas Gruenbacher <agruenba@redhat.com>, gfs2@lists.linux.dev, 
	Ilya Dryomov <idryomov@gmail.com>, Alex Markuze <amarkuze@redhat.com>, 
	Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org, 
	Paulo Alcantara <pc@manguebit.org>, linux-cifs@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 19, 2026 at 11:25=E2=80=AFAM NeilBrown <neilb@ownmail.net> wrot=
e:
>
> From: NeilBrown <neil@brown.name>
>
> If atomic_open is given __O_REGULAR, we now would prefer -EISDIR
> if a directory was found.  So move the S_ISDIR() tests earlier.
>
> Also don't return -EFTYPE for S_ISLNK() - that should get -ELOOP and only
> if O_NOFOLLOW.
>
> Signed-off-by: NeilBrown <neil@brown.name>
Reviewed-by: Namjae Jeon <linkinjeon@kernel.org>
Thanks!
