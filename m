Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795551223;
	b=fkNsK1kW/6UPMMfhLxiKr7d1LXtpyNrWKIzkH3Eh+22K5STLdwCAvjIjK0/HjqoyfjmB
	 hCsIx8TYtm7Ih4uBs7IeT/Cy/Ts/cbuNRx93HdU5/K6+nnh195E7k7zt8OhQ2FnYhzEES
	 bArK1lcRkJtMR7M1aQIjjOCg6rHiByfHJXufUxHI54/V7r+sFeDHUeN/9r6h6wEEfUG66
	 F6g81hApwJTEaSZCOcLhuhI6vXitt28IalEqopYFT3ZymRFOE7e3achxJfNac4eaqnXyt
	 WjwCCbVevmlvWQXvYvuJg2v3OXjpv0NFR1FUOVhUo88iFWwdaEw4+0oYe+Ca0R6WZmw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795551223;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=8WKbn4TeqqYmpHwpZgCuGW4cCB31ueQLaWCo1miFO6w=;
	b=J6gDW2yXadoDr4CJHVplmkMk3tC1Tjv19vGNfc2E8/K4vZY1lJWFPwwGzltP+9mC1l29
	 p2jMeC/J6WDm/Tta2YYOkQMAR34NYGLQF5h7GbQo3fClBdOJbxKog029JcHh+jzmSGThE
	 Y8c3TJT5vJVxI4Rd8P97juWw4TTm9NiU18greMUsvfYBncp7bepxbiEexnGrjID2SvQfz
	 BlbC3DsPlSIKMpt/VvDSwILbMSgmoymTD0bjcCX4L5GmxZnymC07Jhbtz8cwNOufh+B1e
	 L1NhU00d8fQAm0SfUs5e6L58alBDnQ0nx18M5BHMaE5jXWqU2tu3yehRjkYadIc4GFA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LFjxjvZ4;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF671606A31E;
	Tue, 24 Nov 2026 20:13:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LFjxjvZ4
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BADB21F000ED;
	Tue, 24 Nov 2026 20:13:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795551222;
	bh=8WKbn4TeqqYmpHwpZgCuGW4cCB31ueQLaWCo1miFO6w=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LFjxjvZ4Q60U6mgcpBjDltcgaiZ3AU/a0WKDiA+gWTPD1r/iRk97+9N+SbsIEnpC0
	 dfDCiAufmmnUEROgAzJv3HFqUu6y7OGx99aYjjWpgAfdSj9WHS11zU9bOIX9gYuhbE
	 /mYQnCBUVYU7RixvacgEFcfJ3aMzlF3Zfd9dyffxFux5ZrFgXkF5huVrlD6HlODpf2
	 C3i2Egc3rN0DILgQ47sB47QaHy8QRZjmxjT8P69MGZU30xkcHeR2kmhvrPxT9rIYru
	 1sdwX+fcPgeEl6B+hpk0fN81a/GZ0FKvxgdV2D2bL8VvnOVV1/w1tzv+QPg1di/ut8
	 0xCkxsgpdT6Zw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christian Brauner <brauner@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: =?UTF-8?q?Aur=C3=A9lien=20Couderc?= <aurelien.couderc2002@gmail.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 00/12] nfsd: various delegated timestamp fixes
Date: Tue, 24 Nov 2026 15:13:38 -0500
Message-ID: <179555119841.1515463.4777099034111650338.b4-ty@b4>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
References: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 24 Nov 2026 14:48:39 -0500, Jeff Layton wrote:
> v3 fixes two problems in the v2 freeze protection and SETATTR ctime
> patches, and adds a patch for the same ctime bug in CB_GETATTR.
> 
> While I was reworking NFSD's delegated timestamp support, LLM review
> found several bugs in the existing code. This series fixes them.
> 
> The timestamp rework is still a work in progress. These fixes can go in
> ahead of it.
> 
> [...]

Applied to nfsd-testing, thanks!

[01/12] nfsd: don't hold inode_lock while waiting for a delegation in nfsd_setattr()
        commit: 6f51f933294bbcff53fb6c7231f356ae8f1a6467
[02/12] nfsd: take freeze protection before updating delegation timestamps
        commit: e65caea9feff1cce8a270b518e2f4475d6167423
[03/12] nfsd: count a delegation in cl_delegs_in_recall only once
        commit: 266f9a2a591f084149e58e1143374a4d1638a230
[04/12] nfsd: don't grant write delegations to NFSv4.0 clients on CLAIM_PREVIOUS
        commit: d4445ca4e442dc09f4eab20afdafb9d8337860ef
[05/12] nfsd: set ctime when a SETATTR with delegated times changes other attributes
        commit: 1baa7cda2fba4238c193a5262a97f1dfdbf8d099
[06/12] nfsd: pin the client while a GETATTR holds a conflicting delegation
        commit: aa8a7d572d5b9788784038e6a3b7d0bc805e0acf
[07/12] nfsd: recall when a CB_GETATTR reply omits the size
        commit: 2b67daa277211096e5c3dbab460b09df89f74f32
[08/12] nfsd: apply delegated times in a separate times-only setattr
        commit: 74ca288461569f71b86028e72120f8f2fbabff41
[09/12] nfsd: grant a plain read delegation when timestamps are wanted on a read open
        commit: 92a3bf098f0738080cb7869427510364ab6a4d0f
[10/12] nfsd: check fi_had_conflict under deleg_lock before hashing a delegation
        commit: 971425a24fe5961611060799392fff93e8c10804
[11/12] nfsd: take the write delegation grant stat before hashing
        commit: 68c7e0626beace91513d74c0407264a51a127740
[12/12] nfsd: move ctime when CB_GETATTR applies a delegated mtime
        commit: 6f174a0eca19e69a14c34b0ed56b60d484f22fd6

--
Chuck Lever

