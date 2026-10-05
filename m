Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6EFF4BB7E2
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 15:03:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791212623; cv=none; b=rCnUdPe+W1ip2ddHxxU2xG5fpS7vizbHckvn/LysmT9ANUmgaOAWFUbPGCEKlJgFK4l5kgHejjhcTELaPLc+jZMjUB5kMzb7DzXkdU6SY/IyfOuHWxkopfnqx/afPJoGS/Db9nBqsmfsb+aeWxlgbWFFGno7E8TmODY6JHp24q0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791212623; c=relaxed/simple;
	bh=LaMFqjensmqi3TizAeKDhYn6Z3l8Q9gEZNmXxlU8cZo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=sasjx+QI2QHnBLjYCe4PJDgyMtYynwGRTUrKV5UtTwjZYHKl8g3pgF/Zr9V5YdG7bi1u2QCWhfzychUvRU42pDwNMgVVGohJS19FULNo3k6U/c00u/36NbjEVkNExp07/M35cJMqUDRceADZbdCoSC/GmDPcy48RdyUOfASwEoY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RKrNVX02; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RKrNVX02"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B7F2F1F00893;
	Mon,  5 Oct 2026 15:03:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791212622;
	bh=TkWUf1zYELvz/Dge4LD25J5/vy06v6WIZYq6OcCgBNs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RKrNVX02z6fB8VSND2Bb2/i1JzlDpuqd6gTWEdZXyEDIdtRSbo+GH2CNkFzjSZzs0
	 PcmBSTfs75XL3IxomoCPPIzKwcOutdpxABXt5h6m+aD4GLL2NS7hgyCw0b3B+63XXB
	 8de03D+YMkVLRHwbmnCidc78AHoe8MDTk89tKZ1AFkJYO+4USNx0GNicFW6m+T69Py
	 c3PJiyi0Fhp+SmXc1vYt7PGyJ2zfZJSzXkxU6m9kH9tw5NVgOUykxQF8I3WYyPELxn
	 ofdq7zZLMgpph12SfNTo+mNcEAHJ5KJdgolF2Vy/lDm0+vaUBaGXnIiKYDWAmRUETZ
	 k4tYlG6Re//5A==
From: Chuck Lever <cel@kernel.org>
To: linux-nfs@vger.kernel.org,
	Hyunsol Mun <muumthf@gmail.com>
Cc: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Willy Tarreau <w@1wt.eu>,
	bobtobabz@gmail.com
Subject: Re: [PATCH v2] nfsd: pin OPEN stateid referenced by LOCK stateid
Date: Mon,  5 Oct 2026 11:03:39 -0400
Message-ID: <179121261232.31073.16930730237144020715.b4-ty@b4>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260930053646.299164-1-muumthf@gmail.com>
References: <20260930053646.299164-1-muumthf@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


On Wed, 30 Sep 2026 14:36:46 +0900, Hyunsol Mun wrote:
> A LOCK stateid stores its parent OPEN stateid in st_openstp without taking
> a reference. A request can keep the child alive while a concurrent CLOSE
> unhashes the child and releases the parent's persistent reference. A READ
> using the surviving LOCK stateid then follows the freed parent in
> nfs4_check_openmode().
> 
> Take an OPEN stateid reference when initializing the LOCK stateid and
> release it from the LOCK stateid free callback. Keep the free path safe
> for partially initialized objects.
> 
> [...]

Applied, thanks!

[1/1] nfsd: pin OPEN stateid referenced by LOCK stateid
      commit: 6bc21ddb0ac56f6a040540ae62b93c064332413a

Best regards,
-- 
Chuck Lever <cel@kernel.org>
