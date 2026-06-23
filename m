Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA59B29B228;
	Tue, 23 Jun 2026 13:25:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782221135; cv=none; b=c4hbcN1DjQ8uqTt3bSY8juwYd2DWwD8F5BuV6pzhtliowoZXDRuut2RY6f+LogG97Y+3crA83q0pgai+M0ptIGhchoYq/47koHVPH8+1FSsMUdqYVI6xtVYh6ZC+hlNXcNDRXlirQEsr2shDmyFms6eLFC4yhsijoC33rn8BP5w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782221135; c=relaxed/simple;
	bh=DqRRH2bTK8NM42fnFb3sgx68WbjMT5BgTbOaFDCdl4I=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=sJ8g8Djhclv7Jxv/HqpECjJrKjmjB6ZLvQmyn39DJBWmVFpx8Fv4FSn8eIGMauWlODhxip0MqwD2m40qWKCmFeAOAvFM2XhYPTZe2/DV38LLrye0T6NdZfaY+IVlUa/GX8AaoE5aVvcN9h2TgvdwCV5u8UBm1ea3EXkQIU4p7sM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cK6whyJO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cK6whyJO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E645B1F000E9;
	Tue, 23 Jun 2026 13:25:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782221134;
	bh=DqRRH2bTK8NM42fnFb3sgx68WbjMT5BgTbOaFDCdl4I=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=cK6whyJObAFlOA0Mjuwa5h2YVe0tJtsMNEG3seiUlsH5b1F/1K/X5fl5zu2ABsFlX
	 zFIQONPA80nXEIpKVogn3P9OL7PNJYuNHhAuF3OX89Ao+ey3jlyxGUgkU0m7d+lell
	 CuCvdT7gOiJoJZyGiLYW+gJGy3jCi/ShoolS2VzWX4jNtxGv4eRs29VZXXRCG35NyE
	 fyhap+HWCJGAw/CvTkRHbJEA8oa4IiQoSlL08DfE2BI+DTPb8qceHFh8O6umELOyyf
	 RvX+Xx/RLb15Z4aQ7pyQBwL95K6lX3NJHy2PyWvGXsRmN7LtTDbLkxBhb7xUwy/j1K
	 sCqabinfM73Ug==
Date: Tue, 23 Jun 2026 14:25:30 +0100
From: Mark Brown <broonie@kernel.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Jonathan Corbet <corbet@lwn.net>,
	Shuah Khan <skhan@linuxfoundation.org>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org
Subject: Re: [PATCH 1/4] nfs: store the full NFS fileid in inode->i_ino
Message-ID: <4ef293ba-2423-41e4-a1c2-e4be0d660755@sirena.org.uk>
References: <20260512-nfsino-v1-0-284720522f4c@kernel.org>
 <20260512-nfsino-v1-1-284720522f4c@kernel.org>
 <0750912a-f8dc-4714-ae11-4592d2e8eca7@sirena.org.uk>
 <655d0d2a5f8203c52c78d37462328449e49b7feb.camel@kernel.org>
 <e5ebc36c9a7e356c8d1b98ce3a9d1f3420177334.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="uTbZs+3ExMXgIXrx"
Content-Disposition: inline
In-Reply-To: <e5ebc36c9a7e356c8d1b98ce3a9d1f3420177334.camel@kernel.org>
X-Cookie: To love is good, love being difficult.


--uTbZs+3ExMXgIXrx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jun 23, 2026 at 07:04:47AM -0400, Jeff Layton wrote:
> On Mon, 2026-06-22 at 18:38 -0400, Jeff Layton wrote:

> > Note that it's trying to stuff the inode number field into an unsigned
> > long. Before this patch, the maps file would have printed the old
> > (hashed) inode number on 32-bit. Now, it prints the full 64-bit inode
> > number.

...

> > We could argue that this is a bug in the testcase. It assumes that the
> > maps file will never print a value larger than ULONG_MAX in that field,
> > and I don't see why it would make that assumption in this day and age.

It wouldn't be the first LTP test that had a bug in it.

> > Are there actual programs in the field that scrape the maps file that
> > might be affected by this change?

Not to my knowledge.

> This testcase patch should fix it. I'll plan to send this to the LTP
> list, but it would be nice if someone could confirm the fix on arm32:

I'll try to give it a spin, though my test setup for LTP makes that very
awkward (it's embedded into a rootfs image and built as part of that) so
I wouldn't wait for me.

--uTbZs+3ExMXgIXrx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAmo6iUkACgkQJNaLcl1U
h9A5cwf9Hekd7kCTtmqpWZH1v1u6jPEWUPfz6VaK2grID5e84/eJiUMz9hCXCy2v
gAHRtG8YVxQrE02k02diOI/w2jImue8e0RuCuEg3P74boYuKCNPDdOL9AjdtRKeC
E9SkUS16cTL4Gt+ud+Hbe1gsKCBLQh8fudWJs8XMWWBzMT2WmI6hWN1aX2/McgNi
PTIqM8Ev8tKWMt3pGdjJptNjV2gDlibSwHQQSSdeZJRfxvrLjsfl5StziTH8wNWc
+3610yar/+xzcnmGCxTz+MQwdU8W/i9sfPgE30WchOu4ONut5dEU8d9XflWxi65W
l88dW+LY9Rx2ihKzoM8HrLempQ5ONw==
=Yh0u
-----END PGP SIGNATURE-----

--uTbZs+3ExMXgIXrx--
