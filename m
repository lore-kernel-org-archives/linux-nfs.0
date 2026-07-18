Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60EC51A0728
	for <linux-nfs@vger.kernel.org>; Sat, 18 Jul 2026 18:39:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784399964; cv=none; b=boZTMns4tGz72d1OnNyfsbKBFz1fYZLgSzVcBTDbraPxNc0BB+Sc732wirg4la85vBOPhYcUJ9p5DgSfkYTf3FJVVaC5QsahGmejPXFfabskGNNXL19lszPkqJG3ib3Iq7HU6TfNz3olZi3l6zwS/NOj9vG7fpGoSpeiMxkutHs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784399964; c=relaxed/simple;
	bh=9sAd6/Ec10SyApDxG31nVZ8QeT3QE6GQ0ktT+AZUkDw=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=J5Yn0MHoqZIU5p1kiZIlLhrINC2bGsruO4vVUEVH9lIj4cG413TK+xu45054w28okbmxB07rsoO/IxURmAjFjxamqDo8kxBIqWg1D6/9nqHn88z52keV953zHh6LOXtTqKniWrCVe8jGyCgminctMTOJ8f3pEvTzTSnAgI+kVkw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=oZ3BMQsj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="oZ3BMQsj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5B5051F000E9;
	Sat, 18 Jul 2026 18:39:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784399963;
	bh=9sAd6/Ec10SyApDxG31nVZ8QeT3QE6GQ0ktT+AZUkDw=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=oZ3BMQsjoWDvMok6o7gKLNh2sy6XrJc+wyqlC0LHnK03jJb5UpT41g/7uzuaAMLsB
	 WN3U1yu+Z3IDpBs2lE4245MgjadeTsyQ7/Q7ne4+F7kqhoiH8ieIxTqrLNFC/pHiOb
	 VpfbW2FOTTvF97irnYeAFWuyM3DRahk9YnyFcbYhqacECAhRHSePuKvVcafMR53PkF
	 EyKoz0ADLrRYo/Ss+TyLsZ+KjcZId7CAZNMzykV322ijUPnkhwngkLl+OvME/gYhRO
	 XaNE0XGnxCLrwUtuOTw9S9JhHgpXwfmkukELUtShgKlmiiQLxv4zmuQ/h1oQ/Z3nLF
	 lHx2J/nVRQFGA==
Message-ID: <e12340598024349c232f455cfcff420c71450e82.camel@kernel.org>
Subject: Re: NFS mount option rdirplus
From: Trond Myklebust <trondmy@kernel.org>
To: "Mora, Jorge" <Jorge.Mora@netapp.com>, "linux-nfs@vger.kernel.org"
	 <linux-nfs@vger.kernel.org>
Cc: "Williams, Keith" <Keith.Williams@netapp.com>, 
 "ben.coddington@hammerspace.com"	 <ben.coddington@hammerspace.com>,
 "sabbene@nvidia.com" <sabbene@nvidia.com>,  "pyoo@nvidia.com"	
 <pyoo@nvidia.com>
Date: Sat, 18 Jul 2026 14:39:21 -0400
In-Reply-To: <SA1PR06MB11353323AA28FA09C4EC56163E1C62@SA1PR06MB11353.namprd06.prod.outlook.com>
References: 
	<SA1PR06MB1135309B2E478CE0323EF04BCE1FF2@SA1PR06MB11353.namprd06.prod.outlook.com>
	 <SA1PR06MB11353323AA28FA09C4EC56163E1C62@SA1PR06MB11353.namprd06.prod.outlook.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Hi Jorge

On Fri, 2026-07-17 at 16:35 +0000, Mora, Jorge wrote:
> +Stephen Abbene
> +Peter Yoo
>=20
> --Jorge
> ________________________________________
> From: Mora, Jorge
> Sent: Wednesday, July 8, 2026 2:59 PM
> To: linux-nfs@vger.kernel.org; Trond Myklebust
> Cc: Williams, Keith
> Subject: NFS mount option rdirplus
>=20
> Hello Trond,
>=20
> A customer is experiencing significant performance degradation after
> switching from Rocky Linux 8.7 clients to a 6.12 upstream kernel. The
> clients with the newer kernel are seeing a dramatic increase in
> GETATTR/LOOKUP operations. Their workload primarily involves
> traversing a read-only directory tree and reading or retrieving file
> attributes.
>=20
> This issue is related to changes made to add heuristics to
> READDIRPLUS. We have been testing on RHEL 9.7 using the mount option
> 'rdirplus=3Dforce' to reduce the number of GETATTR/LOOKUP operations.
> However, this option introduces other issues.
>=20
> Is it possible to add a mount option to completely bypass the readdir
> heuristics, such as 'rdirplus=3Dlegacy'? Alternatively, could a mount
> option be added to make the client less aggressive in sending
> READDIRPLUS requests, such as 'rdirplus=3Deager'?

We already have 3 different modes for readdirplus: the default
heuristic based rdirplus, off (nordirplus/rdirplus=3Dnone) and always on
(rdirplus=3Dforce). I'm violently opposed to adding yet another, and
particularly if it is just tagging a slightly different heuristic.

So if you're seeing problems with a read-only directory, then I suggest
you use the tracepoints that are already in the code to show what is
going wrong, and determine why. We can then have an informed discussion
as to whether or not we need to have another round of changes for the
current default heuristics.

That said, if the directory contents are also read-only and not
expected to change, then why can't your customer use statx() with the
AT_STATX_DONT_SYNC flag to just retrieve whatever is currently in the
cache?

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
