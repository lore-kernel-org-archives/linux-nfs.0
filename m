Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 922EB3D171E;
	Wed, 22 Apr 2026 12:52:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776862326; cv=none; b=HKINwhOJoyIeB7PeGpKSEsuxVlErTxkrH9BkJFnyGdtbfYOGqSFcHGHQ5WTjAWoZPnKv4kugQJhm0PbmlAdJEBMzWaLP34a0uGzJEItv5HnajHVsci9peNgGy1Z6kzmvheU1UaOXwzglgpRNTNMiP/bbyAidwZlnj6oeQit04JY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776862326; c=relaxed/simple;
	bh=37oI0AG2Nf5eY20nNmkaFmAZawkuO5BQiTOsEPbDovU=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=QgdAqua9Ha5ch1uy7PCxzGxWoHCs0r76C7vde/6EoLFxIUtGm2sQIYuX7qcMGM5jIox0UyDXBB4GKdmLCO6BYKLQ6jbn6igDpX4FK5yjStwk62JbnGB7pfjBhNf7ZbMTiKeTQ5nfdaMAis3P4tN+sQSiiYIEkLCQjUtsJCvUkIg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CbDCbnKd; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CbDCbnKd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AB366C19425;
	Wed, 22 Apr 2026 12:52:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776862326;
	bh=37oI0AG2Nf5eY20nNmkaFmAZawkuO5BQiTOsEPbDovU=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=CbDCbnKdArbA/OdkE8aiOiAZKjbQxc+MZj2PLWsLhY4ArSM4EcPQoH7k31uiCw3B/
	 cIujbdw0mXTiTQtUPv7yBAWe/gCxDtA7ib9CcAYk8e82Lht2V5hPL6E8K6xiLnnr3/
	 2QOQbv8CVN+KeO3Gqlc2BdwnHMPlOTTzJVNxfHsOKaQ8sgVxKA41fPHqHOW9qByOEl
	 lyhfHO86qSEbSq6RXfABX9IvUy96KgKxTH6SPut5RHo5SsxeKwXc0gPTstLp67bG7t
	 s9eP0pMo3eaAISsOtZR+nQ/oo+RwYFZjLmBLPfvsGmThGXIMWP/3XZmfHc+IFXVX6b
	 nZJKi2tuHtj7A==
Message-ID: <1821e8c9b3d7f5aff9447f719e6f94932b68a79d.camel@kernel.org>
Subject: Re: [PATCH v2] pNFS: deadlock in pnfs_send_layoutreturn
From: Trond Myklebust <trondmy@kernel.org>
To: Ben Roberts <ben.roberts@gsacapital.com>, Benjamin Coddington
	 <ben.coddington@hammerspace.com>
Cc: Anna Schumaker <anna@kernel.org>, "linux-nfs@vger.kernel.org"
	 <linux-nfs@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	 <linux-kernel@vger.kernel.org>
Date: Wed, 22 Apr 2026 08:52:04 -0400
In-Reply-To: <AM8PR04MB776494AB2547E8DEE4C6186D8A2D2@AM8PR04MB7764.eurprd04.prod.outlook.com>
References: <20260408122534.537816-1-ben.roberts@gsacapital.com>
	 <B8730746-9646-4416-8417-D73B24FAB79A@hammerspace.com>
	 <AM8PR04MB7764059A4CC2893C16A3180E8A202@AM8PR04MB7764.eurprd04.prod.outlook.com>
	 <14A7BAF5-7D96-4C34-9FEE-CA929267A174@hammerspace.com>
	 <AM8PR04MB776494AB2547E8DEE4C6186D8A2D2@AM8PR04MB7764.eurprd04.prod.outlook.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.58.3 (3.58.3-1.fc43) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Wed, 2026-04-22 at 10:46 +0000, Ben Roberts wrote:
> Hi Ben,
>=20
> > The kzalloc failure is definitely a rarely-used/tested path, so its
> > possible
> > there's an issue there no one has seen yet, but from what I can see
> > it looks
> > like every call to pnfs_send_layoutreturn() first calls
> > pnfs_prepare_layoutreturn(), which already clears
> > NFS_LAYOUT_RETURN_REQUESTED. I don't see how you can end up with
> > another
> > proccess seeing the flag.
>=20

I had first applied this patch, however when looking more closely, it
seems that it will also be defeated by the by the loop in
pnfs_clear_layoutreturn_info() that checks if there are any layouts
that need returning, and resets NFS_LAYOUT_RETURN_REQUESTED.

> Understood, thank you for the feedback here. I withdraw the patch
> request and
> will take this back to the drawing board. Likely removing the patch
> from local
> systems and looking to capture more useful diagnostics if/when the
> problem
> reoccurs.=20
>=20
> > There's at least one body of work in this area that your systems
> > don't yet have:
> > https://lore.kernel.org/linux-nfs/20240613050055.854323-1-trond.myklebu=
st@hammerspace.com/
>=20
> For what it's worth, I checked this patch set and the changes are
> almost
> completely present in the EL source. Patch 2 is only partially
> applied.=20
>=20
> Ben Roberts
