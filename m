Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 91E5D3E3D90;
	Fri, 11 Sep 2026 19:20:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789154449; cv=none; b=s39qnJs8gp39woTpQQXZ1bp+Y7RnGMENM9OxIxXjULfk1h4hlreZrJ2OY+F/kwMEP6QY8z/x1GbsONeDk+B0nxUgvTx3/vsumHeRGEAzCiAUqgbYNHF4nCthicPKhpwRLsZPDgYCDot0xjeb4FxM7Xjse54iorh8IGcOQmHDw3M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789154449; c=relaxed/simple;
	bh=yefhN7ALNAdmFE1+pt89DVZcY/uhZRYBgm1cECQbHC4=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=VuWXZHliftpXn08M+xuN1L1MaYEwNanB3XoQtJmCpgW0OUabjITyKOJA9k0/Z6dggz2r0abEmGAI5cVTfdFcYyd3l0xMIUDb9NY3lclS4tFyOuLKVsNV0b3ZlbDf3ikZZiXOKPiJb4ecjSH0p50+Uy4y3d/JqJgy0mBz3clcjso=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aUCb4uXg; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aUCb4uXg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 63F191F000FF;
	Fri, 11 Sep 2026 19:20:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789154437;
	bh=45vQuW3fEnS+Twcp9KK28/woSlfpJBVSqnWEQe4/344=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=aUCb4uXgH/yV1/Imu7s3tNnnNjxxh/ONdpnfXF1pjq0s28Pl4dSSZs1bz6Q5hjCax
	 YDHwyLzJrEDrr5h+giMwJ6MKCLLgLXYX1V4hImcxCNRtPVuLBFscliRXYuSHa1mADO
	 P4wwFJzt/Sr8C0oPPBj8WAtkbvb8UOTo2kvjreWkfN+IyR6QWf3p7ERxOJbODDgEwc
	 k2naaK4D4tXlKeHe0DXN7qipgWaGHpVuQlepdJl+au1SiWlWhXZFnCyyr7kvETfmGP
	 GUI32TpfSimhPtdu3WhsXHUUqOGb/Ca5pjOquoyGl96kyIwFnKlC1f4S0Lkti8AYZl
	 tHe59hzRvnwTw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 8FA92F40066;
	Fri, 11 Sep 2026 15:20:36 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 11 Sep 2026 15:20:36 -0400
X-ME-Sender: <xms:hFSkanBzVQR8-HXGmo_RtKhNK01uLBxfbz3o41Pc8w9DjQGqj7L0dg>
    <xme:hFSkaoWa5wQtRkAths7DKImqZigQkiSpGCF81KxcjIsW0v5NRyhYkEPbSGlKGTw-5
    ggt4wGgnL9vNRbZukc8pVvGbXvN8_gnG6111mWmrkqp593Yn4X8sw>
X-ME-Proxy-Cause: dmFkZTEpEUe4YXurW9eP1e3ccFausWbjIwRHxX7YDsLWBp0FZ6TfMLJv0AorTlnkGuJyfL
    JRhJ9FVOTLJdQNylA3LQ8kBHs/xPD+lnbSaJ8JZImnnxr+GucaShA8hPI9NBAjm9gQlPN7
    5C1WZesEzQ0/C6x06PHapwSZqMFGoCbF6OA5Qpxgdb9c4xcLfE8ZfOKU9t3LFdfUIoScin
    dBo9PJRAQD4N4URHe0ZhzPJnIl5UJTLKIW7wbvrp0GpcGsiYjiOErXfcHqwtED+S7SphiZ
    Gu9/OrRUjvNVPOHUauGfm4mUcgJH3LNvs9CNZ5XLEIMSn6AU8z+o5EbOwEX7R8xX1Xekmw
    ALRAkb07R+DrTfDzMQbZAX8o+dxjid5+5xEpelbb9JgGvKSyT9SnlwNMhJRneZmLcUckUQ
    EztpL9M9Dg+cESHSd6Z1uAR3J/vIHyvoDbj2//Lm5Oz6OmshPqtrwWAfqlmobQloM/os+d
    UIjY1RrXSeX0i4pVDIW3Wv9BF2EEOxP6P+TnKpQd8g6oSEufbBSU7Z4HdTLfHD/FV05Qnb
    dyXAEPMnwql5AjhU4JPTvUcZsmMtNVZ1CXbPz4Vqlnc5V7zWqIiFuHVjR2zHhKGAxVzhGX
    ypz8H0SHz7ns6N5KC+/srBoYBs+BMiWw5orN1BGbVCNvbwkT7OU5OYP+UnOg
X-ME-Proxy: <xmx:hFSkasRFh5oC1BQxgZUssni22QBqECc01hBalai8E4GCLjPopKktwg>
    <xmx:hFSkagRsZAKgK7OpzTFAbu3Sz01AOZAuC95rWYp9NicxQtinF-iWOw>
    <xmx:hFSkan2gZ-KaubyrF9FwalFYKQTiAoCnzdaTm6NmMCPOvriTxAs2Ig>
    <xmx:hFSkaizvNeedtwcZqMIoskBwh2Q4_HuQr0tspabIwqcKnGP9F0odog>
    <xmx:hFSkarxAVgVJ34_UnIpGis94UCPISEb5dBjxhjr1QWRS20rrXQ8J6nQY>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 6CF647811F0; Fri, 11 Sep 2026 15:20:36 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AAPZyXKTxCYB
Date: Fri, 11 Sep 2026 15:20:13 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Hannes Reinecke" <hare@suse.de>, "Christian Brauner" <brauner@kernel.org>
Cc: keyrings@vger.kernel.org, kernel-tls-handshake@lists.linux.dev,
 netdev@vger.kernel.org, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Christoph Hellwig" <hch@lst.de>,
 "David Howells" <dhowells@redhat.com>, "Jarkko Sakkinen" <jarkko@kernel.org>,
 "Sagi Grimberg" <sagi@grimberg.me>, linux-nfs@vger.kernel.org
Message-Id: <4ff29ed1-e963-4010-a7a1-73b229cc8bd0@app.fastmail.com>
In-Reply-To: <bb9a872a-d4aa-467a-b4c9-7bca174a6bbc@suse.de>
References: <20260602154740.49861-1-cel@kernel.org>
 <bb9a872a-d4aa-467a-b4c9-7bca174a6bbc@suse.de>
Subject: Re: [RFC] NFS: named client identities for mTLS mounts and a per-namespace
 .nfs keyring
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Christian, we're interested in the question below about user-ns
versus net-ns for keyring ownership.


On Tue, Jun 2, 2026, at 9:39 PM, Hannes Reinecke wrote:
> On 6/2/26 17:47, Chuck Lever wrote:
>> Today, exactly one x.509 certificate and private key pair can be
>> used at a time for all NFS mounts. The location of that pair is
>> set in /etc/tlshd/config.
>>=20
>> We currently have an awkward experimental mechanism for specifying
>> an alternative x.509 certificate and private key for an xprtsec=3Dmtls
>> NFS mount, but it needs to be completed so it can be documented and
>> advertised for use.
>>=20
>> I asked Claude to write a rough draft of a design document that
>> outlines what needs to be done to finish the work. I would like
>> input on the kernel-side mechanism in particular for the
>> per-network-namespace keyring and the way userspace reaches it.
>>=20
>>=20
>> Problem
>> =3D=3D=3D=3D=3D=3D=3D
>>=20
>> NFS mutual-TLS mounts (xprtsec=3Dmtls) need the client to present an
>> x.509 certificate and prove possession of its private key. The
>> handshake runs in userspace in tlshd; the kernel hands tlshd the
>> credentials by keyring serial number over the handshake genetlink
>> upcall.
>>=20
>> The only front end today is two undocumented integer mount options:
>>=20
>>      mount -o xprtsec=3Dmtls,cert_serial=3D723847,privkey_serial=3D72=
3848 \
>>            server:/export /mnt
>>=20
>> The administrator must load the cert and key into the keyring out of
>> band, discover the integer serials, and paste them onto the command
>> line. Serials are opaque, non-reproducible across boots, and easy to
>> transpose. There is also no isolation: nfs_tls_key_verify() does a
>> global key_lookup() on the serial, and the .nfs keyring created in
>> fs/nfs/inode.c is module-global and never referenced again -- any tls=
hd
>> that learns a serial can read the key.
>>=20
>> This RFC proposes a named, per-mount client-identity interface backed
>> by a provisioning CLI, and fixes the keyring to isolate credentials p=
er
>> network namespace. The kernel handshake ABI (integer serials over
>> genetlink) does not change.
>>=20
>>=20
>> The cross-subsystem ask: a per-netns .nfs keyring
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
>>=20
>> Network namespace is the correct isolation domain. tlshd is bound to a
>> network namespace, not a user namespace: it services sockets passed up
>> from the kernel over the per-netns handshake genetlink socket, and one
>> tlshd runs per network namespace that needs TLS-protected mounts.
>>=20
>>    - Replace the dead module-global .nfs keyring with one keyring per
>>      network namespace, held in struct nfs_net (fs/nfs/netns.h) and
>>      allocated at nfs_net_init(). The keys subsystem otherwise
>>      namespaces on user_namespace, so this is a kernel-held object
>>      referenced from nfs_net (like today's global keyring, but one per
>>      netns). The DNS resolver's per-netns key scoping (net->key_domai=
n,
>>      request_key_net()) is precedent that netns-scoped key handling is
>>      acceptable.
>>=20
>>    - tlshd attaches at handshake time, not at launch. This matters: t=
he
>>      keyring may be empty or freshly created when tlshd starts, so
>>      linking it by name at startup is the wrong model. Instead NFS se=
ts
>>      ta_keyring to the netns .nfs keyring serial in
>>      xs_tls_handshake_sync(), the kernel sends it as
>>      HANDSHAKE_A_ACCEPT_KEYRING, and tlshd links that serial into its
>>      session keyring per handshake -- the path tlshd already implemen=
ts.
>>      Linking grants tlshd possession of the keyring and, through it, =
of
>>      the possessor-scoped cert and privkey keys.
>>=20
>>    - Credential keys are created possessor-readable only (no
>>      KEY_USR_READ). That is what makes isolation enforceable rather
>>      than advisory: a key provisioned in namespace A is absent from B=
's
>>      keyring and unreadable by B's tlshd even if its serial leaks.
>>=20
>> Open question, and where I most want input: userspace -- the
>> provisioning CLI and mount.nfs -- needs to name the kernel-held netns
>> keyring in order to add and search keys. Candidates, modeled on
>> KEYCTL_GET_PERSISTENT (security/keys/persistent.c):
>>=20
>>    (a) a new keyctl command that links the caller's netns .nfs keyring
>>        into a destination keyring and returns its serial;
>>    (b) an NFS-specific request_key key type the module instantiates to
>>        point at the netns keyring;
>>    (c) a per-netns serial exported via procfs or netlink.
>>=20
>> The per-netns keyring decision itself I consider settled; the retriev=
al
>> primitive is the open one. There is also a user_namespace accounting
>> nuance: keys added by userspace are quota-charged against a key_user
>> keyed by user_namespace even though the keyring lives in nfs_net. I
>> would like the keyrings folks to confirm the quota and ownership
>> interaction is sane when the user_ns and net_ns boundaries do not
>> coincide.
>>
>
> I am all for making keyrings namespace-aware. Logically I _think_ they
> should be tagged per user-namespace, as this really is about the=20
> filesystem (and as such would warrant to be tagged per mount ns).
> Tagging it per net-namespace is not a great fit (well, for me, at=20
> least), as also block devices might require keys to present the
> bdev (eg nvme authentication)
>
> I might be okay to have it tagged per net-namespace, though, as all
> current users are in some shape or form being network related.
> But I'm not sure if that stays that way, so I am worried if we're
> not restricting ourselves to much by that choice.
> As really, the question is: what is the driving the namespace selectio=
n?
> Is it the _requesting_ layer, ie the layer issuing the mount() call?
> Or is it the _providing_ layer, ie the layer providing the=20
> devices/interfaces where the mount() call is operating on?
> If it's the former, then we need to tag is as
> net-namespace. If it's the latter, then we need to tag it as a
> user-namespace / mount-ns.
>
> We should probably ask Christian ...
>
> Cheers,
>
> Hannes
> --=20
> Dr. Hannes Reinecke                  Kernel Storage Architect
> hare@suse.de                                +49 911 74053 688
> SUSE Software Solutions GmbH, Frankenstr. 146, 90461 N=C3=BCrnberg
> HRB 36809 (AG N=C3=BCrnberg), GF: I. Totev, A. McDonald, W. Knoblich

--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
