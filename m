Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20D3B368D51;
	Sun, 13 Sep 2026 16:05:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789315558; cv=none; b=FHjChH2c+WiVEVA/CAqrTqI5rWAfp1x/c+G2u2l6ux7iPs/Y5yQahv2w4/bpCSgoWqIocNg5d4AroLqfhToRLsvr5/v04rUL3i0+KYGp88CjkT92cN5LeOmkdmeAg8WUSTXnEfxjo/1JyjRVvgr6WQI7UxFxtcYJItoue208SPY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789315558; c=relaxed/simple;
	bh=9MnzZ5c/GPTeMPuSywpbP4+Si4gXx+i7tnpD+xDMoRU=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Y0Q879Oqja3WIMnJD7Pod8/KGMLElGEwrz3prarsO6KOjH4mtqVrp0mlGA5pfwNMgnfWDVUoXiI4ydm1s34JK5e5GRK5c+ShaBtN0OMjDmU1+CjcckdUpWXIw2KpO4rzf6Vz/ClShEehjqLyQ7Ee+8LqESyrRBcRhv+xin0U/0M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TFyF4wg8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TFyF4wg8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 720651F00893;
	Sun, 13 Sep 2026 16:05:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789315555;
	bh=5YCpCgr7wN6BRngUrHQuusuhHt9EZlKC0MCMR65I/Wk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=TFyF4wg8t1JVUlkOZtO5/xJjB6918d1JKyW0zLDhhrHy8L5A7spT7wKHu/A8D+pKa
	 Oexy/7syyAHdliF2NYFzCFyozozVipJuqGnBXq0RNF0UHOZWT+dMAm/16U1r0gxoaX
	 wQgJGyp2oyX6uB99O5OLlrnWUMWaEhGA1pOnjvQxxS+dEFr7LRfICNYnpCrCx7G0Mx
	 f4RWRrRtyxljJROYOcZIGErq0NWCHzt8BwfR6eKStKZMhzL3ajP6av2VCTjYq0toBe
	 Pxj8nzZVFeiaVf3SR2kNWUR8ruuMm5Z6i4eZlx/2ep9lxni+oF6Xfv7BQv/W1qmOVx
	 UYJBojTjgRcLw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 83650F40066;
	Sun, 13 Sep 2026 12:05:54 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 13 Sep 2026 12:05:54 -0400
X-ME-Sender: <xms:4smmal1B8TFbjoWMJrfJ5FhRf8BSKoXx-jo-mnyHgeLV6pZ86fhsJQ>
    <xme:4smmam42vccNsHlMdMphoub0O9Mt6SBLGSdJAqR0B7Q4mBQmIfZ4aR1zcpnD4pZeQ
    aCW82fJ6xaX4NSHKVHSiyP6kCrHz9au6jfWs54SSNnyB4IPTF6K1zrZ>
X-ME-Proxy-Cause: dmFkZTEuqnInwcZIkp3LZsOKtysl7pel0EoEBfW5y/sKAQwXh8kf6FPGOaVTkGtuxdR5/h
    ZGAYoQdVo1yKWRzC8fkocQNj1y2i9F/PUs93rVn5UsXeFWGMglFjiCNx7lEm5RdcmEceY/
    U2En6IgIKw6P+/TAqV7JGISUxgDWrjNyemNEFnokNDHC34LKB7sUZquBqOU1uQk9jU04I2
    D8wgimrXmhbhirlb4990OPurrA7zdrV9t2Yu4XohTmGeP9loP5fgWa9G7IG1wkLC0thrnU
    caz3D2RzkyB4bstm/zqDyEodkkbYPjxEw7m/xFpknoRehRrC66QFtPGZs7PWi3iPO2JuO8
    3bqDcl/niTrOt9fypPTFRg1DNqvnrj6NZQiMp4GgrStpzxyuMAqTXE62NkzpzaPtetoEAu
    bTG7grwrfh5iemoTClsDhnUo/ThXRqJ4ZD65LnkjscpP8QDEdn3x14DICEmcMGurUhvvGo
    xESXAocLzoLXRw5cMyLG2o3CY+he8QNkzMMZD4elgLM8ORKR0A5a8ZAvwYVwjNi3MEnjV6
    3AoGONWflhPGf90eVn4obalU+CoS89vKt00uTnHRL1iUrZGgHqFxG3wPeD7pWy+n5w4fhP
    JiGOv897ElJBvTxs2rkXZRVYOUvF3J4qRQa8Aouti1l5T4TsnGqgXcBDjbNQ
X-ME-Proxy: <xmx:4smmatYUSxOOxVRfDNKBwj3YJk6lBCqmROiE-DepGz1EAqhRtlI5xA>
    <xmx:4smmal9gpqdvZVSLreJsYibhKRSeJYBA-skBXLO7wRavRIxd3xAmDQ>
    <xmx:4smmavP4ilzY9sverMsE3g46lL6oi4GbHaAsXjBnO-LESvhQu68CrA>
    <xmx:4smmaiEj2adrdRz-E8fKny65h2Wol5BH1ClFKZw8aEB0nkiliF-hOQ>
    <xmx:4smmatyoCFcbCvS-JOQ4RN43Qu6tQZJ-mo5jSLKe4ZBhXTE-MKpGGd1H>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5A64A780070; Sun, 13 Sep 2026 12:05:54 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AAPZyXKTxCYB
Date: Sun, 13 Sep 2026 12:05:30 -0400
From: "Chuck Lever" <cel@kernel.org>
To: linux-nfs@vger.kernel.org, "Sagi Grimberg" <sagi@grimberg.me>
Cc: keyrings@vger.kernel.org, kernel-tls-handshake@lists.linux.dev,
 netdev@vger.kernel.org, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Christoph Hellwig" <hch@lst.de>,
 "Hannes Reinecke" <hare@suse.de>, "David Howells" <dhowells@redhat.com>,
 "Jarkko Sakkinen" <jarkko@kernel.org>
Message-Id: <8ddb29a7-28e7-4c90-8d6c-5ab2976fa53a@app.fastmail.com>
In-Reply-To: <20260602154740.49861-1-cel@kernel.org>
References: <20260602154740.49861-1-cel@kernel.org>
Subject: Re: [RFC] NFS: named client identities for mTLS mounts and a per-namespace
 .nfs keyring
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Jun 2, 2026, at 11:47 AM, Chuck Lever wrote:

> Userspace front end
> ===================
>
> With the keyring in place the front end is straightforward and follows
> the nvme-cli / cifscreds pattern.
>
> A new nfs-utils tool -- working name nfstlskey, fitting the nfsidmap /
> nfsconf family -- manages x.509 client identities:
>
>     nfstlskey add  <identity> --cert cert.pem --key key.pem
>     nfstlskey list
>     nfstlskey remove <identity>
>
> The add subcommand reads the PEM cert and key, converts each to DER,
> and creates two "user" keys on the netns .nfs keyring ("user" because
> tlshd consumes raw DER via keyctl_read_alloc()), with possessor-only
> read. Description convention:
>
>     nfs:x509:<identity>:cert
>     nfs:x509:<identity>:privkey
>
> The mount command names the identity:
>
>     mount -o xprtsec=mtls,tls_identity=<identity> server:/export /mnt
>
> mount.nfs runs in the caller's namespace, searches the .nfs keyring for
> the two descriptions, and passes the existing cert_serial= and
> privkey_serial= options to the kernel. tls_identity= is purely a
> userspace convenience that resolves a name to the serials the kernel
> already accepts; the raw serial options remain as a documented escape
> hatch. Both get documented in nfs(5), with a new nfstlskey(8) page.
>
> tlshd changes are minimal: confirm the per-handshake link of the passed
> keyring happens before the cert and privkey serials are read, and
> retire the now-unnecessary .nfs entry in the keyrings= startup path.

I've created an nfstlskey tool and pushed it to the nfs-mtls-identity
branch of https://github.com/oracle/ktls-utils/ . It compiles, but I
haven't otherwise tested it. There is a nfstlskey(8) man page.

There is a change to tlshd so that the handshake children processes
pick up the .nfs keyring instead of picking .nfs up at tlshd start-up
time. This avoids the ordering problem of starting tlshd before the
NFS client module is loaded.

I'm hoping this new tool can be used with current kernels, though
all of this is missing proper namespace support at the moment, so
it should work in the init net-ns only. Kernel patches for namespace
support are in the works.

Please kick the tires. Is this the kind of administrative UX you
expect?


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
