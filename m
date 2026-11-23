Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795456001;
	b=t7mczSO+jYEtJm/u6aYrsHedxqsMNwAphA5B0Dainn7TT2P76OYZatQX5/zMN1BgMULG
	 8oosOho5gbsmZPGm7WExBjNhFC/H+aEBHL/XfSgBKPWtDBlQ+LJFBLammgyJs3uvmzALQ
	 2fBG+O9b+LYy2wrteGRMEsxyeWKbdiT+dM0vcEoLcKnPbwz0/eWYQSsuqWj7r6ZA8tiC1
	 J1yeoSCNd0LIMIZg6lyBr+/FLTo+Epcfp1fz8YONEPIKgaffDCbiZIZZ6/K/futGjE5bQ
	 +gUxN+f2YOivaRHWmcOKqcLPyxe8RgZURrm+FoDuMVHseY05RRu9a4A6pW36ITBWxaw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795456001;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=4nLP39eq4bHx3bOXA1PI54TRX3Ud7vwzTs+mgeRzazU=;
	b=SKSKS+n1qUMb3c3eU5UrbUJx/N0VMHBxN3RixkgJ0K7YA9Lsgdcz2xZAqfR7UGAJYk1a
	 traDHifneUWbl6f1Jk5aIerQaO878nfzimReYF7j8EBZRsDT4pGbl2tR0SjztnYt/u2AI
	 72m1/pxj1BMm3VHIrs92cJU+Ra6qRTIHWdrQKN8I4cb+FtwwL0m6wJWEAT5DmGlHSxKun
	 CkcCtw+FRktLU87GlscxRKMihoYm+Nub4BopW73RSeXT+AYH20ikYIn1d5RYVBW6NI0o2
	 AdePVMmYkZMVLv2kHxmm78Qivq7fhUcdLkmgmv1WYXAYl14Q2EreoFf29181lc3LmjA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KkM0EjlE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE530606A31A
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 17:46:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KkM0EjlE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 07CC61F000E1;
	Mon, 23 Nov 2026 17:46:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795456000;
	bh=4nLP39eq4bHx3bOXA1PI54TRX3Ud7vwzTs+mgeRzazU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=KkM0EjlESvm+Edyzj7LJoeMpi9b6WHYmhMjbtTbfsQI3dlZFyer49WsMtFyxgEUsV
	 TNuZUSkGEmrF/wjd4thR4wBgPs8oVzM/2CkIisynYDm8wkYzE4DRnH62V3f4C2YagY
	 8SpfyIL1BjQ3/hUEsfZivxqwdQNsNLLhrs8KVWGwnsIKboBAtV2yDikrPVVLh9K0nB
	 hml9pvdNa/hmtCesWtYtJxPc74l1mdoILo2WLq98MfHPe4BoS8vsXEuB0W8zoJtffE
	 wQpkx3nzEldnhiDZ2vpNkvSexFYvJZiJZDX7xGMLAIumtcaBJhChSbSudp14rsq50U
	 HPU5J9NoA1uiA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 292C5F40066;
	Mon, 23 Nov 2026 12:46:39 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 23 Nov 2026 12:46:39 -0500
X-ME-Sender: <xms:_3sEa26y3Zom9JuTHz2MTxX8x5SlwRb62v0snfdckuWZgvUbU2fSJQ>
    <xme:_3sEa6ugqtvQ3r6ngz2D00xoRTxQToXlkXOC3bu8o_jIfSpul_UFIYfQJI-htm8Fc
    aLwPLkFRrYuf0WXfmVyfqBvUCfy-G5hWDs250wdZPsspJ8WVwZfbPM>
X-ME-Proxy-Cause: dmFkZTGhIDTy2XP9c312iEESSIo05vch7kJHk91EQe1UDP4iT00cyg4D7Cj4y5mWJswrwB
    vRlQ0BteOaimzucih9X7eTQuu43Z86w/hIyHk5Vg5tSGJlbRYdkcMLoO5OeYqDjdHRyl5s
    VpRu3QQXtE/nscjIwz/+09uQsbWr8H/JWMENtPeOGzDW2KrILfHoOIupFm9O8XQ78qVViD
    N0F+Dzl5VZQk4u+KYuKFJDNo9HbX2Ute50EF5fgDrWTMQqKw/4geE/YqA26oyWXSct3AfR
    K8srqs/j9pRo8f1L3Cfjf9Q3ikjdSsJgiTDemy1bjfV3y5L0gUBRgGXorP5izrEj9LefpB
    AObQkgY7331g/HqTP3d9kbJfQnaFRWOCiUrPBKdQO16g3CYbhNMNzFGb0lJbN22uytcyTk
    1nFbb6Ny87IVVB9P0/bJvp+yMJV9f027uwgxBMEnCEUC8q7CO+IIiM+KKdC1CaGO6DMUDI
    8bXAK9kc6ELAVEyiMjZNRJQ0G5ahQXQjkfUuWmQnCZFYC7lzfMr99JmkF/QarKaENjwtJb
    T0JvVGPGSng9cmgDPdxa720D3yMakadNEPWw2pOSF7aqNcXJRJ4AOmBVIuaKSmzwgtmrlG
    frPIzPedQjk1fcVeqGKxgA6Qg3HH/iJIPfml/ZZUHvgj9cocPewW4Y0eUZQA
X-ME-Proxy: <xmx:_3sEa6IsjHi9_VkssvT_bCzO7Opc3LeZgioEboW1Y_VHY3z5RK1olg>
    <xmx:_3sEaylDwvaxZEWY9x7-3py-qZSY1gRFrK7MWLochbMlbMA6zUITAA>
    <xmx:_3sEa7Zq4NlneI502smGvFhvWFw7lUGJw4ihv-Gm0hy6lVscxVcNgA>
    <xmx:_3sEa2_aABBRZOY4Ccs_gSvbKiZhEwj4rzDSeVBfXmmv0v3Vbqzhfg>
    <xmx:_3sEayb0lqgTQHlwdu5Isv8MINPnCRkplzD8WiHO37RFVX_33YtGTmVM>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0B43B780070; Mon, 23 Nov 2026 12:46:39 -0500 (EST)
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
X-ThreadId: AkB0n0PsGghc
Date: Mon, 23 Nov 2026 12:46:17 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Christian Brauner" <brauner@kernel.org>,
 =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <73ca8e61-2943-4780-9e6e-dc8c70c8401a@slotpi15m67>
In-Reply-To: <20261123-delegts-fixes-v2-2-960ce0fb2fed@kernel.org>
References: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
 <20261123-delegts-fixes-v2-2-960ce0fb2fed@kernel.org>
Subject: Re: [PATCH v2 02/11] nfsd: take freeze protection before updating delegation
 timestamps
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, Nov 23, 2026, Jeff Layton wrote:
> +	/*
> +	 * This function also runs from the laundromat and from NFSD
> +	 * shutdown. Neither path may wait for a frozen filesystem to
> +	 * thaw, so leave the times alone while the filesystem is frozen.
> +	 */
> +	if (!file_start_write_trylock(f)) {
> +		nfsd_cmtime_notice(file_inode(f), -EBUSY);
> +		return;
> +	}

DELEGRETURN reaches this trylock too, through destroy_delegation().
FMODE_NOCMTIME is already clear by then, so nothing sets mtime and
ctime afterward. A client that writes under a WRITE_ATTRS_DELEG and
returns it without a SETATTR of the delegated times, while the
filesystem is frozen, leaves the file with its pre-delegation times
after the thaw.

The laundromat and shutdown can't wait, but DELEGRETURN runs in an
nfsd thread, and the WRITEs that dirtied the file already block in
file_start_write(). Can DELEGRETURN wait for the thaw as well, or
might it be OK to return NFS4ERR_DELAY in this case?


--
Chuck Lever
