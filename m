Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792673275;
	b=LQMqQWbbUYcmacHJOtfAzRJp/MfDo44NVZyF6wZVg6qlk5SRwwkbVI3kVLUd2BDm/x3I
	 aBewX0mMeSO1B84AukcbvDNkPXCyRStqE48HYSbcteRtBYBeR1U3MqK3HcvAA8BEe6tSa
	 +UEw06+Junt2SV1nLmEanDhLoRCeNHrzPXwUp7BTpULf1kCK02xWpm7cVheG1N0/vJN4Z
	 D1n098mXUATH409s03JR7sef9MVt2dDO94Eh4fFm/059Ypvrh9jGEVRdm44iWN23Rg+HI
	 mY1sJ2TDOghWSe5lR+RE57DfpSQzJtycYH//c4GakvCOLMRJZworcEBsnd4v6agLo2g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792673275;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=H44omwwK3lb/BN9U2vv/UuziAk2eqYKNvI4mmjizaks=;
	b=xUnTPdv/FLMsqovsgBVZRc5E++Y5g/40n6IQLdINH7hNcZqoDD30bwzqAqcrzeiY7oc1
	 /MPvX1c6NbS58OuaziMcvJNpizd0NcXNCr3+4zCVA/lu3FoWu2AUpqrJjT0rUu0TfXvQy
	 Y/Y+euXyqKKueEdoZOTkItQfTpOHOMoyzqFQqRHBtGTDQU+XaT8wu97XGs1BrgSTi2pEa
	 OAJ2/7hQxZHnh8F1gJCHQ95vBcx24Q52cviMKhNW/rHVEEN2cnVVhAnKgjhS0MXRxLcdn
	 K35D0YS4CEmWEDs/NDAYTp9kD85YzUGjFmKxQNUDOu5B/XAGtsJLu2Qctt5CN6C0t5w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=f9rG4GGq;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 85DA3606A319;
	Thu, 22 Oct 2026 12:47:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=f9rG4GGq
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 433C51F000C1;
	Thu, 22 Oct 2026 12:47:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792673275;
	bh=H44omwwK3lb/BN9U2vv/UuziAk2eqYKNvI4mmjizaks=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=f9rG4GGqxaNQOUF0C72yOLZ5gj+TZEtxbIq0Vcy8I+Zn5ZChbInjMqU66I/1tpdqQ
	 ewlaNmIVgbDNT+BEDLNyXdZpxE0QKeqQAgJxfyu3hRn/jba5W2rDKOf26aIaLjF1zl
	 O7Om5hrlXkiLNhTsJFW6lcczXxEyN5kTBbjoZBBwDzlmagIi3MjIJKlDsWQ/26O7vt
	 mnsA581LNLrKdjFKLSrGNemYJBKybzq+iUBPBdDoQ+gckhNclfnRnJjJcqG5PJDSrg
	 +C7gFlbesKX/aPtGDg4f08sfdxSOENZfhdVqX+emNz+ZIuYUgFIvvI0TIT8zoNhD+P
	 zZef+SpjBLZJw==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Hyunsol Mun <muumthf@gmail.com>
Cc: linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	bobtobabz@gmail.com,
	stable@vger.kernel.org
Subject: Re: [PATCH] svcrdma: silently discard undersized messages
Date: Thu, 22 Oct 2026 08:47:50 -0400
Message-ID: <179267326422.2409795.16633003264114396479.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261022034629.430954-1-muumthf@gmail.com>
References: <20261022034629.430954-1-muumthf@gmail.com>
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

On Thu, 22 Oct 2026 12:46:29 +0900, Hyunsol Mun wrote:
> RFC 8166 requires an RPC-over-RDMA message shorter than the 28-byte
> minimum header to be silently discarded because its XID cannot be
> trusted.
> 
> svc_rdma_xdr_decode_req() instead returns -EINVAL when the fixed header
> cannot be decoded. svc_rdma_recvfrom() turns that into an RDMA_ERROR,
> whose encoder copies the first two words from rc_recv_buf without
> checking rc_byte_len. A zero- to seven-byte SEND can therefore return
> up to eight bytes that were not supplied by the peer.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] svcrdma: silently discard undersized messages
      commit: 667147c17f15824c00a5b2fcfdb66283c3f4cad6

--
Chuck Lever

