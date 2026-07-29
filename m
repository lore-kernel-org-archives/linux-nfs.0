Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D42E02BEC43
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jul 2026 02:51:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785293513; cv=none; b=gmWn60QQHgS7tdPDG0CCLtXCxb2koYroWah8LNlX+bvvqYVzVLrpd0IP+mI6JL2sg+TEXaJLOcL5MB4OHS5bpN66nTpN2BJ50C8blP6B873eNXafnoOxVFhmgkBuZjeryMZRpZ5J+o7zssiJ63eNfNo4mXxtmmhmb5vW+lBF/14=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785293513; c=relaxed/simple;
	bh=vBqwU6/WsXbnVuqp2QQo4t9KFk3yL5vd96Y3Iee5+hY=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Y8C6nhaYn+r+zK1SKYD6BZKjMw3Xu913uI05agu+lMPO1ul13t4Tnvmn1RtqzdIAu/wI2h9NeanzNhmZClHiay3HEBg/VZddXg3Gfu7i6Xg4aJLrrmpdv0KAaBv0r7o+5k859XN1H5LfTyj3TLdoAOB2cCyiq8JQdNhoXCqiUXA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=h3BTQ2rD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="h3BTQ2rD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 40D461F00A3A;
	Wed, 29 Jul 2026 02:51:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785293512;
	bh=vBqwU6/WsXbnVuqp2QQo4t9KFk3yL5vd96Y3Iee5+hY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=h3BTQ2rDVTRCtUgFyt0q8Lwn2hMsogcVUWtijTHFYhx/qoVpjmSzZzC65hZsqQhCN
	 TiAcusmJ+UI7X3wjMeZtFT27W//O/h3lXl5xb3lO9pdJRWN2Uij4MADnTc1zLnHL3o
	 MQAt+QZ+pDAcM1qO6pG5YMw9haGne7J7UGUIP458ZwHoOAdHHDvYaab7Zp3VoLD0f5
	 lBfurS1Qen8VBN1dh5D8qcUFVISTBW9Y1gAU3y0hyw8jutwZmugthyNGGPBvd3eteD
	 TgkFjiC1cbHO6ZxsXcnamjg0aO7/7CninBt5VsUaFLHGGHL8jxioPHMJKnqRmeHZeC
	 ASXnlcgULPYEg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 2BC09F4006B;
	Tue, 28 Jul 2026 22:51:51 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 28 Jul 2026 22:51:51 -0400
X-ME-Sender: <xms:x2ppan4ULTyHBBezREfGNlNtWqX1wm1f_rZA8QoZNv4AylUaCWQ-zg>
    <xme:x2ppanvBUSPX9p7RcKnQmXIeFnzP-C68boN0AVcva8Xmv_ccY6untYOOiOZtXo4c6
    8nG9MuWVbZVB1uOBsvEc385a41pFvWqnofaBP4LHx12XOCD99U_L4A>
X-ME-Proxy-Cause: dmFkZTEYwGJI7q4GAvJLJTlFPooOFbb40vE5f4whMe+cCHmEaYajs+PkWwAnoBIMXv2QGy
    tLOcFy1/949Lj4zOu1Oh2XKEyYOgTXP/jiHkO8SVc0Uav5DDDQ32xflQqeqmSBNkOzh7Wy
    xTLrb/SuDbaDeX8tbVRrR0CN84M4TqD7fA75xd2U9jHz7JkxDlzvfdBxepoZiFfAnIqonr
    BFRQnDH6+tMKvUmXjBjArr91pfa1FplLS4qsG6an7NL9nI/XkShWFq8/OKcRJ/vBY/GPRd
    AmiecsirVQHmmaooBRJQu+czUgWQCfID/9Y17wCiZD2UwDhlscxgZ/tK2Z039p4n+U5Mi1
    1KCC7JTOqynQ5xbFWheYeQLqw/owELncSse+LzpNmmzM/96MbhLliR1cJDOgoW4e3KwgP9
    2IT8BlgCu4p8AockFHeJlgup7Ka8+0IYgasaoVDo8wSY/Divao+KeHUiDINgZlZyRBMlqJ
    I6sBoKd7UowzVcE9bTyRLuZhtnLnOWqj/m2HR0Cp8PARIaSasA/syqha5ag040SbeeD9mK
    GagGqPoSwHGHeai81pnfNaCAg8AzWQ0BnBIg/Jb5cDp1fioAISPQsaWTqUJBtdHIr3wguy
    Wx0OW9hUSgQnD9+jKpQeYzb1PdlGFFOv/LQ0kqLLNVsVjOlZPkU56QmYMEvA
X-ME-Proxy: <xmx:x2ppapxSSDXtiywKjmuBk0sNaQR3ZjgAAv29O_hxjwzFjzwX5nks6A>
    <xmx:x2ppag0kZXDAEyxnnWOTgsNXUwy9UHcdM-HAsnunl7uVhT8wD1xQ2A>
    <xmx:x2ppai8SG1Zf0RmyLJdkqGLNpNFr00QG3IkMppE3wAtDOi9NTSOVAA>
    <xmx:x2ppaoRX5DSJcGFvAV90nmysgY3AfAtC_Oq9vkeGJTTW627uHA_taQ>
    <xmx:x2ppahlj2-XpROuW8q7EbyI7D8T5Qcv34UjX4XNmvzxdfKXL3DmAAhST>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0C900780075; Tue, 28 Jul 2026 22:51:51 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Tue, 28 Jul 2026 22:51:30 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jakub Kicinski" <kuba@kernel.org>
Cc: "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "John Fastabend" <john.fastabend@gmail.com>,
 "Sabrina Dubroca" <sd@queasysnail.net>, "Shuah Khan" <shuah@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Message-Id: <a6fb364d-8344-408e-bcd5-0cee4ffabdc3@app.fastmail.com>
In-Reply-To: <20260728193058.7f6b453b@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
 <20260728185124.72e421c8@kernel.org>
 <480a8337-a91e-40e5-8dbd-d165599fba4b@app.fastmail.com>
 <20260728193058.7f6b453b@kernel.org>
Subject: Re: [PATCH net-next v2 2/6] net: Introduce read_sock_rectype proto_ops for
 control record delivery
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Tue, Jul 28, 2026, at 10:30 PM, Jakub Kicinski wrote:
> On Tue, 28 Jul 2026 21:57:21 -0400 Chuck Lever wrote:
>> > To me this is an ugly one-off workaround that doesn't fit into=20
>> > the proto_ops (only TLS will use it). And you seem to net out
>> > to the same LOC on SUNRPC side with and without this? =20
>>=20
>> It=E2=80=99s not about LOC. It=E2=80=99s about not cluttering the nor=
mal I/O
>> path with a lot of exception processing to handle TLS Alert
>> records. The CMSG API is very difficult to use and leaks the
>> alert messages into I/O buffers (which for in-kernel consumers
>> are page cache pages). It=E2=80=99s piss-poor API design.
>
> I'm not arguing that it's amazing. Doesn't mean we will YOLO
> a special proto callback for every protocol stacking :/

No-one is asking you to roll over. Review means you get to steer
us in the right direction, and I promise to do the leg work. Terse
rejection doesn=E2=80=99t move the discussion forward. It stops it cold.

Complaining about slop also does not tell me where you need this
to go. I use AI to go from blank page to RFC/v1. Where we go next
is up to human taste, as always.


>> > There needs to be a very strong reason for us to add APIs for
>> > in kernel consumers. =20
>>=20
>> This is not a helpful position. Your objection is the same
>> every time, treating the in-kernel users as second-class
>> citizens.
>
> No, it's not a second class citizen. But kernel consumers have a
> tendency to break all abstractions and insert hacks all over the place
> just because they are not forced to go via uAPI boundary which forces
> people to think about the API design.

Granted that user space self-tests can=E2=80=99t reach kernel-only APIs.
But that is what Kunit is for.


> You just need to try a little harder to produce a better solution.
> Rework or augment existing callbacks to let your achieve the behavior
> you want.

My original approach was to add a new read_sock variant because I
suspected you wouldn=E2=80=99t want read_sock itself to grow another arg=
ument.

I thought the RFC series cover letter made it clear that we are
looking for input and direction, not to sell a completely formed idea.


--=20
Chuck Lever
