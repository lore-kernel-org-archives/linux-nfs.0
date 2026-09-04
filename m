Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 965AB3C8719;
	Fri,  4 Sep 2026 17:47:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788544077; cv=none; b=TUDIbQKgddFwymDvllG4EKuakl2jBZMWJHzkmHT5ST2Nqh6R2PvvdehBaKoihm7lckA9Er/jB8f5eXsTQbNPjuh1SeNMrpWdMjcnojQ8iANa9xjWacShz9OvfTtt9/jomdEVxUQSwecNngOBj4bdm2xTKwJU7AX3mt83dTRByGM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788544077; c=relaxed/simple;
	bh=7CGlBFrkJV7Za8cMjyPRGvKG0GyochKTvwRvno9uAIs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=aGwTPicI/k8/54wNZCI/iQOOwoveIkUfnVsgzsTA8ukIXwI/3hZsCewSfSEmlPV0XfLoSFd1rFGft5jsuV8AnMXPncZJau10Z53Y5uxpHZOO0wVorpYKxMc2Z/CmoPHMxi4it9d4flBS1pZrUteHA4OAu6e6OuylPvz7kV7Vkoo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=g4Sbt986; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="g4Sbt986"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 49CD31F00A3D;
	Fri,  4 Sep 2026 17:47:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788544075;
	bh=TlEsbsSlG7EPflY6X1BGZc0DiD8dObMNUStx1cG9V90=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=g4Sbt986ZF4jVbhL6U2lZIivfWm0dayRFPZ0trvTxa9+rMTnQwfePkpceUd9DObkS
	 4UzL4Zp8t89qkuB9L9UxCtrW2436ScoZNWnF5s/0GwJvC7F+0AT+I8ttsLiF8dZuGl
	 xX52sozc0lcA+uC5ANYgtF0ks3fc2ejV/nhnVELYRbtMtb3svz/ySmu9+ybn5p+2zm
	 Of4+UeK3Xihh3a+ESHUiSPAcUISxMVu+XtZB61r7xGrMctbeFShjJ/2oQFoV8WP/bn
	 CdXqiG6Il+DWFX8pGDWiKae+TwzL4Bu9BGg28zXcE+Ev1eh36YGMDcUcdAyhuGbnkb
	 oTmF0EjVXORBg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Tom Haynes <thomas.haynes@hammerspace.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Benji Wiebe <itsme@benjiwiebe.com>
Subject: Re: [PATCH] nfsd: don't offer flexfiles layouts when NFSv3 isn't being served
Date: Fri,  4 Sep 2026 13:47:50 -0400
Message-ID: <178854404483.3085896.11467546432248071819.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260904-pnfs-ff-v1-1-5f502cf25401@kernel.org>
References: <20260904-pnfs-ff-v1-1-5f502cf25401@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Fri, 04 Sep 2026 12:11:37 -0400, Jeff Layton wrote:
> The flexfiles layout driver hands out a deviceinfo that names this server
> as an NFSv3 DS (flexfilelayout.c hardcodes da->version = 3). With v3
> disabled, the client can't talk to the DS: it loops on v3 NULL calls that
> the server answers with PROG_MISMATCH, and I/O hangs in D state.
> 
> Skip LAYOUT_FLEX_FILES in nfsd4_setup_layout_type() unless v3 is enabled.
> 
> [...]

Applied to nfsd-testing, thanks! I can drop this one if you find a
better solution.

[1/1] nfsd: don't offer flexfiles layouts when NFSv3 isn't being served
      commit: c1efd0d304fb61af95f4919936dc11a94845532d

--
Chuck Lever

