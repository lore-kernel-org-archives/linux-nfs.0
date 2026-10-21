Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792594582;
	b=agZT2kNI2fK8ytDEMsej+rJDXV/miUVYszTsqNIaBiTujOCrTBnQJMRqyndGMTfxg2eF
	 u+zPedIQQkBPvAkPE9zA9Czc6aR1uQf3/88owOqovx27TgeDcA//TymyoGZWhCzPA77Jy
	 l3zOGAOfnNnuz6xhNXS56OzmtoMYxXfMtslL9FWO8NZh6v4wFUABQq4zV41QqJkzIUQgd
	 gdX47xrnGu/Z+UPeSw13JbyQqvVB/bB/FUHR2lp/P2qb8jls6fadnNwPyxNDagUquq9SQ
	 ZDwR8ypIQK7ncHaucvSb//BJgJlAVew/ykWmHh4U49TqP0n/RClsMrN5kaKQ5xRk7fw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792594582;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=XPxX1ueeD3Jomtv7ZENlQRwts9r+sA3WMJLGgPgB3KE=;
	b=PEm0loBxvbMFYpRxXZnP4GDy+MBKl33jYuMiIp7R0IjwhMMhT+p92+rUJ8/9gN1NwIF9
	 ytXZ+fstZs3WRYbUSAllu5sjAT9XqCppBLQm12xR/4//HxBydaSC0V0tMiSJjxBunhrOm
	 +JEMG6lfv62nlkrsCXmRofmXwusqedg5/SJNre29AqMiOc172jSfj5VMpvSzcwKXIj1XX
	 DXWc+UriWTs198RolWqsN1zz2cqg3YGb2cSA2mqCblRZTL9ntEWJwab6KVJ9yQp39oKMb
	 tK2LS1nZCe69VOFTGQsTh7CTIaLOGT5gC+9N4grVvUPMgS64FTYmuoMBaVHQEVBesdw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=frCB5nSx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8AE5A606A323;
	Wed, 21 Oct 2026 14:56:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=frCB5nSx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7AC091F000C1;
	Wed, 21 Oct 2026 14:56:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792594582;
	bh=XPxX1ueeD3Jomtv7ZENlQRwts9r+sA3WMJLGgPgB3KE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=frCB5nSxCd42MpfvZ7YhB+YoFiX2CFK/SHTM3orkZaPyMBLQeX13zOxMnrPkRRtcT
	 O5iuBHd4jUWHtnoHNdGk+dnJE17AwXjjOgLPTZm141hmwartC5uQZGEZJV28JSnP2G
	 eq5GFcweVEgBlQ8/Z3XAe1YWFQQw4otl/Q0K4fRqpYZL5mQr4Wtw08EmtanB4iP9jJ
	 dCsNKY+oQjp5FsKBYFINTBVqas6RhyzQ1RbeE35p4Xs/NsVB/LCURtnWs4JzboTzec
	 m3FmSUaxdopIsu4jbTGxz5MxAapjyUClTfymVWTqGtozJH/X7mbeKju5k6VzV9J9w+
	 F+e2vPsDv2LdQ==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Hyunsol Mun <muumthf@gmail.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	bobtobabz@gmail.com
Subject: Re: [PATCH] nfsd: truncate LISTXATTRS replies on error
Date: Wed, 21 Oct 2026 10:56:18 -0400
Message-ID: <179259457039.1631710.2834472700881549771.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261021023715.315727-1-muumthf@gmail.com>
References: <20261021023715.315727-1-muumthf@gmail.com>
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

On Wed, 21 Oct 2026 11:37:15 +0900, Hyunsol Mun wrote:
> nfsd4_encode_listxattrs() reserves 12 bytes for the reply cookie and
> array count before it starts encoding attribute names. If the first user
> attribute name does not fit in the client's maxcount, the encoder returns
> NFS4ERR_TOOSMALL without initializing the reservation.
> 
> The generic COMPOUND encoder does not truncate replies for this error, so
> the reserved bytes are transmitted after the operation status and can
> disclose stale reply-buffer contents.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: truncate LISTXATTRS replies on error
      commit: cab30e6ab042c665e54bc9408e9c7b7550417845

--
Chuck Lever

