Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.54
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795154626;
	b=JkaYEXpvtyWZEEe/oT357VHEjkRPAVszDiLzmO3f0DBHv+QOuqrkz8+blXaTytrCJf5h
	 ii9v5UVHbL624iz0g0K93wxALw47pImLctRZNyVy+HBkRuutCtp+ZvrCm3SkLmEWAfuZO
	 WQyMskbrKUnMT7esXsRAuZ+Ajra/1PzvQP2F3ZhO7fbZPITUGSd8rBvoX6Fm+86w03LDT
	 cmhzKQyC6J+C/5MteOtVP+PYPbiNLDnmoXJ82SJboRamcjC9sK9mEqYBsYV0Qd7lRzwkN
	 IKmEnTKrq1CS9FjPBuKfhfXcLYxAFjGX/hVAtAacJ8spkITXu9V95PputmwPKIOT7Kw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795154626;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=pGOGVjzDtRAIxks4mvGvAXFdrHYvYvSfhVh3EqISUwM=;
	b=ARcoWpQ0elJj3ao+htFLLWbvP4yED9VMguyhCPilZ++kcVnG5aKVwV/m0LGJB20jEUnm
	 49QTtIppjaYpfw5C4QAAvKxkUkxyVqsy6T05TgN8gDX+0MpGnzFRr18O6zcUXAyO8qZjX
	 btYLThymslVRYg5EFKef7sEAuJ36ZR33E5mE+POdaWcrMm/Anhq7T9wTi9f4nDVMIpBwZ
	 uF0NkuczrE80E6J5ChiiHnu/Jliq4jvFQbjXHRXvQqyFCvj6EzcAVOm+X2OQvm/DPknQU
	 JMJ/u/2rEtcldi5RJJDGbjzfowgDWZ440Hlj/BXprSS/peIrF1spK1/l+2qj1W44BDg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=twd3LSyP;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.54
Received: from mail-ed1-f54.google.com (mail-ed1-f54.google.com [209.85.208.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F12460A260B
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 06:03:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8F12460A260B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=twd3LSyP
Received: by mail-ed1-f54.google.com with SMTP id 4fb4d7f45d1cf-6b4bd3d98bfso620598a12.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 22:03:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795154624; cv=none;
        d=google.com; s=arc-20260327;
        b=T3u7pX50og0b+ULZB3A5+VmqpOJ5i8Lgd+m1yOtkVOAiKs38PSbF+psXndqhP3iUdw
         c0PpPyzuyQb3YYIlQv/z5tWTautBKwlZZ2ycgW51P9Fu6h0wyqBm0ubSgsdywEvXtGbh
         XEySf3pLI6AdrBg7E2e3Dt1x/R3DAxWvYGIgJFpNQcbECiSIpEvUMJ4Q3DHOxgPyGVGN
         dBAT7n3c86FmAwoA7YDwzoeFxSa8KB1t1JKqP0Ht6NGYaPpVxoxQGDWSxn2SyZfo8IzC
         4jNWUhe7iYy+SD21TJlx5umM6nhHT7fs9O70/fB4Kk6vAenU2/fKcDR/z6Qdn09wVk+F
         uz/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=pGOGVjzDtRAIxks4mvGvAXFdrHYvYvSfhVh3EqISUwM=;
        fh=+sCvjlbyut6ZonGOsnSRAwFen+Z3lFx1qiDKDSnfOgc=;
        b=HQegi6V/wYUK3EuMN33nKK3vOxM46IkdbqpY12vzOzcvdRd2iQI8Rj2+6FwTq1Y2m8
         QQCeUgVzbX7LuRLdHUMB380ilaAX3Dy1jWyqAy7BdtUkCtPuSzv4uac6uzEO1agKKxJn
         dqiODqjM/Iig8RoKiuODQfGmQW9o6qY1qcD1U8n2nQMgZM77p0BDc9tU5CIHXvolBO75
         oja5TKi8Q9oFiTeibdlxEckxMynM4Uv1chQl0Jp8C4jPyEkUJW+eC402qGdwDc6CDPNX
         5fO1XqScsbg67FXYtm3f03EpoLcTU4tX6EFz53JYscyeTzU+tReffVGNo6GRePWJsf94
         /aew==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795154624; x=1795759424; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=pGOGVjzDtRAIxks4mvGvAXFdrHYvYvSfhVh3EqISUwM=;
        b=twd3LSyPhh/xqGTUhGQCUkwTgPz0ozSKLDTUdzWfuC88iwf9vuQaz4Cbapmx3zwlEj
         zlPpp5xjkBRG0SDqC55ar8nBqU+85ZN/BbmT34kWJ4vxhbdyZbdyEQy2606KHlPpAcFA
         JFJXbHJDQWbyltdYp5JJ76dGIZsXzMVaFFB2lWR6MIffBbfdMhvs931PsHwOVCxf6WxW
         wy21QWjJiN1/vrK+nMRXh+VMOYDU0hoTkIxn3m45nhUC91hezeDKP97nETUPcHv6eNo8
         2LkA2JYHzh73ui1UQni7id0o3aSMFPuYuUQVmp+IzjGqkrZikwiCYxOEdafgsA18VMyB
         JQzQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795154624; x=1795759424;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=pGOGVjzDtRAIxks4mvGvAXFdrHYvYvSfhVh3EqISUwM=;
        b=WikiCMqGqfWbExjR8QdSCoM734ZYTcn1jJFGDWBs4b64meqjJNqzeE9xu4kHVPAJRD
         LnYw6izWzV2lrpYyfH+LOxGQV4lEtL2biCJNDr4A8kEhsoVm64Ok9cHrQ91ENdEZAVL6
         3p75vJF/9cMLj0XSXQ7Zvxl80mnP0FWWJExmq7Bbg6g7TyJLVzLgNg43xf7uOhjXBtke
         DBRdc5TfyQKVpCIOA+mtVl3nejvrWt277DstyesKqJz6i1yJfm3w99UvstBwIiX0R0CI
         RSza/8+02xSOb2PW0TtccSjSpyM6iVoKvtOzbZY8XOXgoMXdwGGYu6i5OrITzoN0jdUG
         8GUQ==
X-Forwarded-Encrypted: i=1; AL+hErEbNr5IKnp6KjbqNxWy1YpWA4SjyjvlniDRWCaWrxasWZ3AAQxmySrk4afFkixqMIxC5Xw7b/YJk3c=@vger.kernel.org
X-Gm-Message-State: APuU4Z8XtGOP/lzqfZTvYfMFpzNsvxUgTHANzhKlLCKPO81QY2AOflkm
	K7QeziaOlNudlmr4vwjRgSCATrmpHZZ2bJ4Z2XVqJQEy9+hdXchQNKoCUyzN2m2SOoZFwpkq4/5
	//mzjz8POJ5pma+VjS+xh3ouWh8b+lN8=
X-Gm-Gg: AZFdTZcZIwDT4ODsHDrsjorAyBfEzY3LSAtIjiBikwFSrhKvXmFhcSXo8Fd69siyNG/
	uvRLHoWabcaCbPiRayiQSlOfap9xLE09WhlQ8VNru2jCNdH0g39/WJivtKLzTTk8Ryqgx2Qyvl2
	shpKjpwqIQhfXdSzP7rcWp+dT52TmYjMW39xl5VwpArZb1NdK2vyXkFXHRwp+9mDzhfAC5JwSxX
	VFW8O0qhnGGTE+nW37VrDuwxRM8Y2C/zfSdbw4EDxh48n+3kb+tHNxQrboP+ecJpuv37vLWvG/+
	nF0EnDokEP5IXEBv/fGodR/o1jjJZ7ca0Nbh3FNSWSy4VFutn6ukfnxCQabpZmVCr0tRe4vHipW
	kyOSS8tYYPGKks+c71DLKnf6P97ZmUZRPsjHBtSTz4jgB7rLgtyvepwwt8O4awcFkf8bbITVd6W
	3GHkbbCJhaeFkIG3A=
X-Received: by 2002:a05:6402:e06:b0:6b5:4f5c:cb2 with SMTP id
 4fb4d7f45d1cf-6ba37ec320fmr1108851a12.34.1795154623771; Thu, 19 Nov 2026
 22:03:43 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261115180343.576773-1-koray.fra@gmail.com> <20261115180343.576773-10-koray.fra@gmail.com>
 <CAOQ4uxhjxp5sxYphWoB=8sgX3XHOv9zLVYf+8ZjYbS_gQDxO3w@mail.gmail.com>
 <DMZIQG4U1NTH.2IN0S2YIWEYTG@gmail.com> <20261119220936.mssmaixcorn2gzli@pali> <DMZJGB07CO56.IZ20OCGGH6C@gmail.com>
In-Reply-To: <DMZJGB07CO56.IZ20OCGGH6C@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 20 Nov 2026 07:03:31 +0100
X-Gm-Features: Aa3M54rvTAbJYlhFUqobPAqFrpuIqbxGTrlnaPynQQoE0nz09X_6dT10Gv8Q47Y
Message-ID: <CAOQ4uxhqgsh9ahJsX7C4YyZH2n_r8VwOe9X9jZwsKALCoYvyag@mail.gmail.com>
Subject: Re: [RFC PATCH v4 09/10] ksmbd: add provenance time (ptime) and map
 it to CreationTime
To: koraynilay <koray.fra@gmail.com>
Cc: =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	David Sterba <dsterba@suse.com>, Namjae Jeon <linkinjeon@kernel.org>, 
	Sungjong Seo <sj1557.seo@samsung.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Konstantin Komarov <almaz.alexandrovich@paragon-software.com>, 
	Paulo Alcantara <pc@manguebit.org>, Chris Mason <mason@kernel.org>, Yuezhang Mo <yuezhang.mo@sony.com>, 
	Jan Kara <jack@suse.cz>, NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Ronnie Sahlberg <ronniesahlberg@gmail.com>, Shyam Prasad N <sprasad@microsoft.com>, 
	Bharath SM <bharathsm@microsoft.com>, Sergey Senozhatsky <senozhatsky@chromium.org>, 
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>, "Darrick J . Wong" <djwong@kernel.org>, 
	Sean Smith <defendthedisabled@gmail.com>, Andrey Albershteyn <aalbersh@kernel.org>, 
	Pedro Falcato <pfalcato@suse.de>, linux-btrfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	exfat@lists.linux.dev, ntfs3@lists.linux.dev, linux-cifs@vger.kernel.org, 
	linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 19, 2026 at 11:25=E2=80=AFPM koraynilay <koray.fra@gmail.com> w=
rote:
>
> On Thu Nov 19, 2026 at 11:09 PM CET, Pali Roh=C3=A1r wrote:
> > On Thursday 19 November 2026 22:51:26 koraynilay wrote:
> >> On Thu Nov 19, 2026 at 6:34 PM CET, Amir Goldstein wrote:
> >> > On Sun, Nov 15, 2026 at 7:04=E2=80=AFPM koraynilay <koray.fra@gmail.=
com> wrote:
> >> >>
> >> >> Implement provenance time (ptime) in ksmbd, as introduced in a
> >> >> previous commit ("vfs: add provenance time (ptime)").
> >> >>
> >> >> Map it to SMB's CreationTime, making it settable by SMB clients. Wh=
en
> >> >> reporting CreationTime to clients, prioritize ptime over da.create_=
time
> >> >> memorized in the user.DOSATTRIB xattr.
> >> >
> >> > That doesn't sound like the right thing to do.
> >> >
> >> > If the server stored a CreationTime that client had set, you cannot
> >> > override this.
> >>
> >> Ah, yes, but how would we handle older files which get a custom
> >> CreationTime both before (in the xattr) and after (in ptime) a kernel
> >> upgrade?
> >
> > Just to note that this problem is already there. ksmbd can export for
> > example ntfs filesystem on removable disk. And this removable disk can
> > be connected to Windows machine which will always only touch
> > CreationTime and ignores xattr DOSATTRIB.
> >
> >> > When the client sets CreationTime, the server can decide if it can a=
nd wants
> >> > (may be a policy decision) to store CreationTime in PTIME and not st=
ore
> >> > it in user.DOSATTRIB.
> >>
> >> To fix the above problem we should probably keep storing it in both
> >> ptime and the xattr though.
> >
> > IMHO for a long term solution it is better to not have duplicated
> > information in xattr. Because duplicated information are going to be
> > out-of-sync. Windows NTFS driver will not update xattr DOSATTRIB.
>
> Yeah, to avoid out-of-sync issues is why I made ksmbd prefer ptime over
> the xattr's CreationTime.
>
> >
> > For me it looks like that this needs some policy / configuration
> > decision done by user. We do not know if the user will replug that disk
> > also to Windows NTFS driver (and then those xattr DOSATTRIB could cause
> > out-of-sync issues) or will only use it from Linux or Samba and then
> > xattr DOSATTRIB is probably fine.
>
> I'm not sure if this is the best solution, it doesn't feel too right
> to me, but maybe there isn't a better one.
>

If you ask me, this is not your problem and I agree with Pali that
this is a policy decision.

I would not include this patch at all in the series if I were you.
Maybe as a demo user, but you could just as well include a demo
user application.

The nfsd user is a simpler demo, so as long as the nfsd maintainers
are on the same page wrt the mutable btime plan, you could include
it in your series.

The problem you raise with DOSATTRIB xattr is similar to the problems
that Chuck raised for ptime vs. btime as the source of FATTR4_TIME_CREATE

Thanks,
Amir.
