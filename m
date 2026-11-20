Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.43
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795188083;
	b=CyVHpz5IDQTO/EiGGlWRa3bKqeU0QRMD/VpkdpAex97Cu2UB7QHR9RVA8PNabBv/4lWi
	 IN7BeskGyMaHIJm0JJBaSlHbNeIuRvVNRlpp5Iagxj0/65+qhmu7FaT+m5a29d292D90U
	 qUuFD0brlCgKHkBBsYgFwBeZcOi3PpuQJaVqVLSs9bjvAmiP6pKDGkxkGkuxRsEZ7QGb/
	 jGukBkiKgxJ4mMEV5Ux3UChFXFiWVKH+HmdLAF+GhaY657mVt/JE0YcOUPYOeO6nMtqdZ
	 9w5EppPJhRnd91hkupiDWIeapPWhCHgo0E4l4br6yZZrYHhR30IyVcXqiTPwmHw0eSg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795188083;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=EOuNUplOgjccByi+i7DuzKPwQryobm9GZBpfnMCMmUY=;
	b=xcVAsrImi6vl4OIpZQltYHo1fxK1/gDMpDhcbOXaNzMDt9P0mSB2pJgffZWUXa41lDBW
	 MmsqCsrylkcEW8te4i4/OMUqR+ZCkQ9M63ndokaerkKK9dQ15/WFbO2hJTmiZbsITnlSt
	 nX2iWohcr2FqdI1oIVMH3w/bA1ALOSs2B3ocy0HJnrc603LYQE1hCWSo0BYL42YIgN81p
	 FobS2ZpUmk5ElLtC2J5j/hKRpjqtpiDyoHejyCmdIgfAxfAND/PSYzePlNBWxLABUuO26
	 oPLAWDRiaPDICUuOO5VeGLsLSmevMNIgVoYt1g2WcX+brHcMohX92u+FKxwztqWQbpg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=NS4+0sJS;
	arc=none smtp.remote-ip=209.85.218.43
Received: from mail-ej1-f43.google.com (mail-ej1-f43.google.com [209.85.218.43])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5B22606A331
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 15:21:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C5B22606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=NS4+0sJS
Received: by mail-ej1-f43.google.com with SMTP id a640c23a62f3a-c5126505cb3so147449666b.0
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 07:21:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795188081; x=1795792881; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=EOuNUplOgjccByi+i7DuzKPwQryobm9GZBpfnMCMmUY=;
        b=NS4+0sJSs9ZY/390/dC7VLJUTfAcS54lqeieQtRl8eH5yHWeiW5ytJUQmodv4DKhEJ
         Piyk+uvIFd6cA17v/LQ32rQmteQ4JvXR1QZozak/uFldjGBchuAxoES2PNfUGoBgDTv2
         RbPBJZsdPY1/23IPeY0lzOgNMKQtBhaW79XKJ+OjgBo5KzxR2zORITcFzh48Lc61B/4G
         IpmH+hgmspro/l5uz2hxwnp5j764NrCPcIIHRgzCs3xPLWQwu9A3hyD4S+1gyNKuURVe
         ByXWj6Mlvb+BbN3iPRxqpawWP9jlY2TCk6M4RWxqsGJ9tZX/mW7dUMoA+Kuqk7L/DFfH
         KAPg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795188081; x=1795792881;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=EOuNUplOgjccByi+i7DuzKPwQryobm9GZBpfnMCMmUY=;
        b=bo+18AOmgu5bQDx0f+X7FpLQfDL93T9N3rAaWPn98qKcoqYx8W6/xF0VaLMWpO2Ocj
         /T2eudfrMdqAEhCSCkbEd/sXubLYp+wa1Qs1TLgsidvtLFhH32MJfFxj2ddog+/jrViZ
         qGFIyIcsTOnew+d8i0lRAtNuW3Hb/XYBEoQ5z4U8tzl4g9uzg+3I1vlmCmeBqDF3w3jG
         NendJD6yQ+F9+Li5yvj2krnMbWLPv2qaSdzKaqhVxSTv6lbvuMNaHbqqYrC0qLMyBjc1
         6uhd2Quqc/9yhmG2PXW8+5rj61aOTFt7BLM39IAhUOItHX0MrjFzs02FfRoODpM5M+3i
         dDFA==
X-Forwarded-Encrypted: i=1; AL+hErE1T84s2wDb93DvL7UtELQaB3TdALYgQ612rMnmyxUheMYwbPUPCOH4Bry2C4IpRU5o9eeKGkG9Zb0=@vger.kernel.org
X-Gm-Message-State: APuU4Z/oawZGTo/kgAw/fS7OM9AJ7jWAIslE29Dtq+RwbxC3Ce9jw0YK
	5GMFezi3u8/HQkl914kSGYX5tjR+9V09be5BDh3c5jB1J8tekMglGAqL
X-Gm-Gg: AZFdTZd4h4ols79OiRxTsGTLjeNQhH+YkusuJ/BRj7zSN4fPDo9GsMvkHd3rZnDEYQS
	YgoESkwdfStbvFnYruKLfU882OO6OLJIWSqU1iJNXNH0+vZqOa9F6ZTD2GBib/pCKJNkPriAOoz
	zBqR46JFkiuQpDiDt4/Zyq2sX93z5cMjNP2YmFltZogaMK42TBU2/QoIzLd+9zfhoctMjAUROGC
	wpnA3hsdAhgkDJ9S8Tpx0NndzlW0oB2c5aRTRVUP0T1/aA2SS7p9NVkpUGNDf367UCANF0R8FXf
	BCW/Mf39Iz/C3MHcCeOQu8zLX5y8hrwdRZc5ucgJKbGOFyAldIZOgjoUs0vMNZytoURLelUpqUw
	UGey0HYKvMdZVlv6Dckjiv+Ol9UUnCWl6xdoko16YugLu79k7Puc7ioJ9hg0jmUW+RXjYP5xrll
	j2RLe+sa78ZXDjXPqkCKUMTYQLp0LjBMIjTxSdbjD+VgVOxHeNt4ZoA9rJWM7s9f1nOts155Re8
	Hnjg6E26YoBa4QhqgStC0twi940nA7tnKy4BCRXoNhmr4IKNROGfceGWhqh9NJh9WRuhWcvVYmv
	lNPSiwYl0iBYlAIzO+vfaBcNJuTnsBSB9oV9YEbBWF9V17zG
X-Received: by 2002:a17:907:9903:b0:c49:cdc8:10cf with SMTP id a640c23a62f3a-c513ac754cbmr269557266b.40.1795188080773;
        Fri, 20 Nov 2026 07:21:20 -0800 (PST)
Received: from localhost ([130.192.98.149])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4ab6c340df4sm7100009f8f.55.2026.11.20.07.21.18
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 20 Nov 2026 07:21:19 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
Content-Type: multipart/signed;
 boundary=f7e29ba536d1e92db179b4c7b2dcf417c13b9e676632060f29334f2a5d8b;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Fri, 20 Nov 2026 16:21:11 +0100
Message-Id: <DN0526U5C1RT.3AQRIHXPB86NS@gmail.com>
Cc: "David Sterba" <dsterba@suse.com>, "Namjae Jeon"
 <linkinjeon@kernel.org>, "Sungjong Seo" <sj1557.seo@samsung.com>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>, "Christian Brauner"
 <brauner@kernel.org>, "Trond Myklebust" <trondmy@kernel.org>, "Anna
 Schumaker" <anna@kernel.org>, "Chuck Lever" <cel@kernel.org>, "Jeff Layton"
 <jlayton@kernel.org>, "Konstantin Komarov"
 <almaz.alexandrovich@paragon-software.com>, "Paulo Alcantara"
 <pc@manguebit.org>, "Chris Mason" <mason@kernel.org>, "Yuezhang Mo"
 <yuezhang.mo@sony.com>, "Jan Kara" <jack@suse.cz>, "NeilBrown"
 <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo"
 <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>, "Ronnie Sahlberg"
 <ronniesahlberg@gmail.com>, "Shyam Prasad N" <sprasad@microsoft.com>,
 "Bharath SM" <bharathsm@microsoft.com>, "Sergey Senozhatsky"
 <senozhatsky@chromium.org>, "ChenXiaoSong" <chenxiaosong@chenxiaosong.com>,
 "Darrick J . Wong" <djwong@kernel.org>, "Sean Smith"
 <defendthedisabled@gmail.com>, "Andrey Albershteyn" <aalbersh@kernel.org>,
 "Pedro Falcato" <pfalcato@suse.de>, =?utf-8?q?Pali_Roh=C3=A1r?=
 <pali@kernel.org>, <linux-btrfs@vger.kernel.org>,
 <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
 <exfat@lists.linux.dev>, <ntfs3@lists.linux.dev>,
 <linux-cifs@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
 <linux-api@vger.kernel.org>, "Theodore Tso" <tytso@mit.edu>
Subject: Re: [RFC PATCH v4 08/10] nfs: add provenance time (ptime) via
 FATTR4_TIME_CREATE
From: "koraynilay" <koray.fra@gmail.com>
To: "Amir Goldstein" <amir73il@gmail.com>, "koraynilay"
 <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261115180343.576773-9-koray.fra@gmail.com>
 <CAOQ4uxgoNsOH82FyrCxc+qSoid_CFmbmpL0qgWFw-e8E689fFA@mail.gmail.com>
 <DMZJ4PL1JVA4.2YEB7EPYJR5Q7@gmail.com>
 <CAOQ4uxi6h9BBP7pf4sR+gc2+4XtkEgbxXZha45iZzdB_wGFVgQ@mail.gmail.com>
 <DN02S2XNGRZD.1KNOZJ0GGDJNG@gmail.com>
 <CAOQ4uxh+d-wNC0aWLEexPFz7zj=TZjLyu61kaEmwBx9_hKn2gg@mail.gmail.com>
In-Reply-To: <CAOQ4uxh+d-wNC0aWLEexPFz7zj=TZjLyu61kaEmwBx9_hKn2gg@mail.gmail.com>

--f7e29ba536d1e92db179b4c7b2dcf417c13b9e676632060f29334f2a5d8b
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Fri Nov 20, 2026 at 3:55 PM CET, Amir Goldstein wrote:
> On Fri, Nov 20, 2026 at 2:34=E2=80=AFPM koraynilay <koray.fra@gmail.com> =
wrote:
>>
>> On Fri Nov 20, 2026 at 7:45 AM CET, Amir Goldstein wrote:
>> > On Thu, Nov 19, 2026 at 11:10=E2=80=AFPM koraynilay <koray.fra@gmail.c=
om> wrote:
>
>> >> >                    fa->fsx_xflags |=3D FS_XFLAG_CASENONPRESERVING;
>> >> > +                 fa->fsx_xflags_mask |=3D FS_XFLAG_CASENONPRESERVI=
NG;
>> >> > +                 fa->fsx_xflags_ro_mask |=3D FS_XFLAG_CASENONPRESE=
RVING;
>> >> Uhm, why both in _mask and _ro_mask? If it's a RDONLY flag shouldn't
>> >> it *only* be in _ro_mask? (same for CASEFOLD)
>> >>
>> >
>> > Good question. Maybe
>> > I guess if you want to follow some percent
>> > FS_FL_USER_MODIFIABLE is a subset of FS_FL_USER_VISIBLE
>> > but I think that exporting ro_mask and _mask is going to be easier and
>> > cleaner than rw_mask but not sure.
>>
>> Hmm I asked that also because you said in the xfs shared extent thread:
>>
>> > The advantage being that it makes the interface symmetric.
>> > User can alway setattr() with the buffer they got from getattr()
>> > and instead of randomly ignoring flags in set, the fsx_ro_mask
>> > along with fsx_mask defines the behavior exactly.
>>
>> But by putting the ro flags in _mask too, a user would have to clean
>> them out or vfs will reject the call with -EINVAL/something else, since
>> in that case the vfs would see the user say "I want to change this [ro]
>> flag".
>>
>
> That's just a matter of interpretation.
>
> You could say that if flag FS_XFLAG_CASENONPRESERVING
> is in ro_mask then its value may not be modified and fs needs to
> fail the set

Yes, that's what I was thinking.

> if the user given value is not a match to the current
> kernel's value.

Since this is a new API, I think it's fine to -EINVAL if it's in _mask
anyway, even if the value is the same, no?

> Could be used for an "atomic flag set" operation, but I think
> this is taking this too far.
>
> I am fine with xflags_ro_mask and xflags_rw_mask I guess this
> is the less ambiguous option.

Yeah I think this is the better approach here, I'll work using that.

Thanks,
koraynilay

> Thanks,
> Amir.



--f7e29ba536d1e92db179b4c7b2dcf417c13b9e676632060f29334f2a5d8b
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQRJ2XvJtXGwULYEerQ0bnTtJTDoOAUCawBlZwAKCRA0bnTtJTDo
ODe1AQCh/kbA9HU+8r+s0ju3A1YAvNO0gdrrV7t8u43sPfGVSwD5AdqpmBpPOV/5
L+Tc9hTqkeeZYhiO4l4Sy3W9VwznRwk=
=IwFj
-----END PGP SIGNATURE-----

--f7e29ba536d1e92db179b4c7b2dcf417c13b9e676632060f29334f2a5d8b--
