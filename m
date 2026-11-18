Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795018176;
	b=x2Gt8jee8gqd4PNCoiS4zAtqUpyAo3GB0hdHyO/AuBaQRUvyLzdjTsdqssATq6ikCrBq
	 c/fSgiyyTnrW9yGa7LwxfEl9Jyhz5DAG1oRWVyGaPcnZg/ygnyjG4tBg63l+dCFnA4aH2
	 AvRUqlWPWCS98zI6Dyqq8ol8Qa8O2T6jwznb8Cf1SQg/gP5IKJe2N+YPvp9F3Dq2xMH95
	 MttpXV/AeScM72Pbs2NYuUCi2KjMkv/TZfNTL7RnhQ4Hgn7Fi1X0GRzpZ6XDt/Zg6Htvj
	 YmekxP3Kx1hKl0dR/VQdM2BVjdbUFAPabvQu0485nk3neztlbkah7/tvtBjNWqopTnQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795018176;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=riDyBArp9/R4k4xMR6VvRZbF1SaPkOMeMV0JssuNRRY=;
	b=wP/Px+F8gVGtvP6nnvtH0ecc9jhQkcNXF/iwxPXJ6GuKMUWkl4DTbUVZtK6tTaEc59Q6
	 DPYxwT1igpXYC4VERz+rwlzfEoxZvRqn0plYcnzuapzGmEoMLQM13syYC6zNVPpsWurlx
	 7R8yDu8R2SA8y6nOd59tacaayofxr08lcHfuGx62FJmIDRmlvaOBw638tFNJl8bDxgWpv
	 Nz2o/EvWkDBmPTDx+dHXI7CMjuV46dCKskpKor7Fcs+1vKS0Bu9O8r0miC26L1lkeZVqK
	 GLHNQdBaL3p7zHEoqDzxXVvNMtTMwHggOFKVZMmxqOwsrGwyieSeHltEAlWVBcq0h8Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WQVxeFt0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 69C64606A33A
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 16:09:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WQVxeFt0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3678A1F000C4;
	Wed, 18 Nov 2026 16:09:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795018176;
	bh=riDyBArp9/R4k4xMR6VvRZbF1SaPkOMeMV0JssuNRRY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=WQVxeFt0TuWWJ9rDqOBsEyHmT4klUDdkp1++L1TljGKUvp7Mr7chURu3wq5DWbTX3
	 0OM34AhLvrmw3qqd/nUxxFb2uF30FQQ2aFNlZVLgekk5RKxNyIpgVMQ40vfSG8yFCt
	 f7vZBEyoGzi3CLzjFGz9BaGiYIxxjsKatx1dCeqcS5fj+u11nd29n/2HAFxi2ruUQk
	 yWLcE74YYblOC91Jgx3lx5GPbMC3e1AdJG0dflKPAOXcj9wnW0jd0F6ZoGfNh0R5o1
	 F4OA9YZ7Chzrv/L26XVu37jk0I5h4MprHyr1KZI0M3XXwa0PEgG7Nei18SZX+m5sE5
	 Wy9P0omD4oiIw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 73AB8F40068;
	Wed, 18 Nov 2026 11:09:34 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 18 Nov 2026 11:09:34 -0500
X-ME-Sender: <xms:vs39aqitLc6ckqgYZwXr4Lwqcr4Vx8ZaY7-YBes86xXVIjD8A2UWTQ>
    <xme:vs39al205nX5FAAqgXdjrEs05ZwOlH8bCwq5I4vNMQ2_8dPZNXCgS_WzUtfcf8AQt
    2BzfTlfc25b5ZYpgXkrCi18B9eclEpog9jTLB6rTcBpq84V2ypF_olR>
X-ME-Proxy-Cause: dmFkZTESUkvVxGxEelyPcREnb7FTBl+UYPIp7kZlTs72pQocBlCkEEimyKkotd47ihAmoh
    uecK+1S/fABU3BrzfC8q5W1uCGdb4LxtQoMuMXIaPkFqGd1XcHXo6pEeilExT6pmOTt/3E
    1GVoI3rbDFlwK3sYGrEvea8o84sGaquV0aFEAiCAlN62NbofXs8wlGPAtYVe0YgEOAVsxV
    Ngus07KK4lFsjvesmRVvXA+wR6ECHlKvWO5ILiNo3JdflMMErbbFjAVGsaj0pmRuVrvitH
    FPDpEQ4DEi9oMm0O2lBSlKI3njxEl8QvtcHDP4ymsT5M05agaSVdqZxx6cnn42B6G6bnN9
    7TM5Pkdw2kmVEBOvWp1Sh2zIj0ahJZXfXzJyGcwj+XTWMgvwqGlZB70C7g51BJzO5yQGdL
    4fntT1oJ4vyhDyFif+DHIXFxPDUEO35PUkg8hFsSUn6d01HQ38vyncE0cZAC2/iRQrBOgk
    rZww8+XoNJr41UQoz6gHgSu/qpkiC3eWtw0yelptYC9roOgJF4EPWzCE9iQ2gIZhbhEGes
    s/T+jcY+Of9RNHsFuJ+lltD8iKko7YFVNliqcEGD0TaPRQWdaNL6jH3jbR6holEPvIZo88
    pM01Es80WOsZj037bg+Nz8Y9JYgNACUwMr2yVAWroWu9uMEjaUNKtUABUYsw
X-ME-Proxy: <xmx:vs39amB-U1tskQG2wHlCReZacLqb-wiExlxaTcSsCvBNxLhv0gV17w>
    <xmx:vs39aj1TcPsDF_L9gh8TRQmS0Yd083OZ_Xyc_0oF_rPmRduTU7FwPg>
    <xmx:vs39alYtapLFlkZ7C1oSkn2XlL6OgZunlDpQrKCxLUAgfrLt7o2tKg>
    <xmx:vs39an87cCm_UOcBfyI-8OiDZuikMstn8hTADRMUflsvlT4Ha-mcYw>
    <xmx:vs39avO4IKoor5lhcIMOAbl4zt_ITGJraIIsJ1sKAu7VYukRKaleKAWz>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 43C78780070; Wed, 18 Nov 2026 11:09:34 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AgKvhXN-CN1w
Date: Wed, 18 Nov 2026 11:09:14 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Amir Goldstein" <amir73il@gmail.com>
Cc: koraynilay <koray.fra@gmail.com>, "David Sterba" <dsterba@suse.com>,
 "Namjae Jeon" <linkinjeon@kernel.org>,
 "Sungjong Seo" <sj1557.seo@samsung.com>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>,
 "Konstantin Komarov" <almaz.alexandrovich@paragon-software.com>,
 "Paulo Alcantara" <pc@manguebit.org>, "Chris Mason" <mason@kernel.org>,
 "Yuezhang Mo" <yuezhang.mo@sony.com>, "Jan Kara" <jack@suse.cz>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Ronnie Sahlberg" <ronniesahlberg@gmail.com>,
 "Shyam Prasad N" <sprasad@microsoft.com>,
 "Bharath SM" <bharathsm@microsoft.com>,
 "Sergey Senozhatsky" <senozhatsky@chromium.org>,
 ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
 "Darrick J. Wong" <djwong@kernel.org>,
 "Sean Smith" <defendthedisabled@gmail.com>,
 "Andrey Albershteyn" <aalbersh@kernel.org>,
 "Pedro Falcato" <pfalcato@suse.de>,
 =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, linux-btrfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 exfat@lists.linux.dev, ntfs3@lists.linux.dev, linux-cifs@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Message-Id: <cd49ce48-58d7-4341-b4fc-34e63daf3c52@app.fastmail.com>
In-Reply-To: 
 <CAOQ4uxhpMARO_ZMJDeoa044BwufLVnS0o4Fv0abBF=tjaZmtWQ@mail.gmail.com>
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261115180343.576773-8-koray.fra@gmail.com>
 <f297d9ea-ebd7-47f4-ab7b-de5c45980000@app.fastmail.com>
 <CAOQ4uxhpMARO_ZMJDeoa044BwufLVnS0o4Fv0abBF=tjaZmtWQ@mail.gmail.com>
Subject: Re: [RFC PATCH v4 07/10] nfsd: add provenance time (ptime) via
 FATTR4_TIME_CREATE
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Wed, Nov 18, 2026, at 2:44 AM, Amir Goldstein wrote:
> On Tue, Nov 17, 2026 at 11:02=E2=80=AFPM Chuck Lever <cel@kernel.org> =
wrote:
>>
>>
>>
>> On Sun, Nov 15, 2026, at 1:03 PM, koraynilay wrote:
>> > Implement provenance time (ptime) in NFSD, as introduced in a
>> > previous commit ("vfs: add provenance time (ptime)").
>> >
>> > Map ptime to FATTR4_TIME_CREATE, allowing clients to set it across
>> > CREATE, OPEN and SETATTR compounds.
>> >
>> > If the underlying filesystem supports it, use __vfs_fileattr_set_lo=
cked()
>> > to set it, returning -EOPNOTSUPP in case it's not supported (i.e. w=
hen
>> > __vfs_fileattr_set_locked() returns -ENOIOCTLCMD).
>> >
>> > When querying FATTR4_TIME_CREATE, request both STATX_PTIME and
>> > STATX_BTIME, preferring ptime over btime if available, and advertise
>> > FATTR4_TIME_CREATE support if either ptime or btime is available.
>> >
>> > Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
>> > Signed-off-by: koraynilay <koray.fra@gmail.com>
>>
>> > @@ -3646,7 +3649,14 @@ static __be32
>> > nfsd4_encode_fattr4_time_access(struct xdr_stream *xdr,
>> >  static __be32 nfsd4_encode_fattr4_time_create(struct xdr_stream *x=
dr,
>> >                                             const struct nfsd4_fatt=
r_args *args)
>> >  {
>> > -     return nfsd4_encode_nfstime4(xdr, &args->stat.btime);
>> > +     const struct timespec64 *ts;
>> > +
>> > +     if (args->stat.result_mask & STATX_PTIME)
>> > +             ts =3D &args->stat.ptime;
>> > +     else
>> > +             ts =3D &args->stat.btime;
>> > +
>> > +     return nfsd4_encode_nfstime4(xdr, ts);
>> >  }
>>
>> I have trouble with this approach.
>>
>> We've already established that, for the Linux in-kernel NFS server
>> implementation, FATTR4_TIME_CREATE reports a file's birth time and
>> does not permit NFS clients to modify that.
>>
>> After this patch is applied, the server reports the ptime instead
>> of the btime on some filesystems but not others.
>
> In other words, for some server filesystems FATTR4_TIME_CREATE is
> settable and for others it is not.
>
> Isn't the NFSv4 protocol equipt to deal with this complexity?

Not a question of whether NFSv4 _can_ do it. It's whether it _should_
and whether opaquely choosing a settable vs. an immutable timestamp
on the server is the right design.


>> Essentially this changes the semantics of existing files that have
>> a btime set -- technically that's a regression.
>
> I fail to see in what situation this is a regression. Please explain.

Any consumer that depends on btime being read-only is now screwed.


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
