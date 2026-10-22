Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=66.163.187.152
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792688426;
	b=eZXwSPsUR7dRnltGDVxNiz1WW42sWoGygBKZqnhcV7e33kUDMmKaHqYDxiKaZBfNWs3z
	 NvSS+oePKQkv3/pmnVVmwC57vWyts3JTm4F5VCTBQrhnJWg4/ihqTJiROn9VF2zzEXU3t
	 VIFCEr4SnpFPSqETq1MI2VQaDrKNs78ahxJd4klS0heB2uVTvEb7lcgwHvycp+Pex7Uqr
	 w65ZBc1lP8rUO53HYarUPI2H1CkgSMyUJCfyktBdWVg9Oz9+V7hdSPRiQnq/qOOEL7E6m
	 BTL3tni3C5cVpdsEyp6AZ70z3Nn/Hw1YT6nqzkPw674WgLA/HvtpC6F00Bu1Uquv6pA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792688426;
	h=DMARC-Filter:DKIM-Signature:X-SONIC-DKIM-SIGN:X-YMail-OSG:X-Sonic-MF:
	 X-Sonic-ID:Received:Received:Message-ID:Date:MIME-Version:User-Agent:
	 Subject:To:Cc:References:Content-Language:From:In-Reply-To:
	 Content-Type:Content-Transfer-Encoding:X-Mailer;
	bh=RLhaJlQZZNoYg6hcgIAk04w24uGo5Qnp+frkN1FOTxs=;
	b=hvmrLAiaW0hGOttVotyYqx6bYniFJ1YY+QnazFMJ/5m58+x15Wio2LNgEQh1sEVv+1zb
	 EzjBxIi7KuVZUv3VyRYDMuiU14ea5o8uELztdSOubJsjwFB/8rkvUeQHsFfz2X1smech7
	 yLDTnvXz370xEXnBhyA/+NROWpEqaT16eGjpKRHnqRkIQtTXAVlxfPRZ1fFiG7oZOaDX1
	 VDO66cdEM2Y/jbtFMNuO7eZkOWj4keTMLgeDr/bTLTX7wpHHYgd3X6QB3w7ZUqYnpVbuR
	 relyS/q1S4X19+hk4IS3Je043Ak7fneXk3lrVfaSB7D/mXIde/OFX3xhlgzh1ikUZyg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=schaufler-ca.com;
	spf=pass smtp.mailfrom=schaufler-ca.com;
	dkim=pass header.d=yahoo.com header.i=@yahoo.com header.a=rsa-sha256 header.s=s2048 header.b=EPxXXTv2;
	arc=none smtp.remote-ip=66.163.187.152
Received: from sonic316-26.consmr.mail.ne1.yahoo.com (sonic316-26.consmr.mail.ne1.yahoo.com [66.163.187.152])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C6F1606A31B
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 17:00:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8C6F1606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=schaufler-ca.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=schaufler-ca.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=yahoo.com header.i=@yahoo.com header.a=rsa-sha256 header.s=s2048 header.b=EPxXXTv2
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1792688424; bh=RLhaJlQZZNoYg6hcgIAk04w24uGo5Qnp+frkN1FOTxs=; h=Date:Subject:To:Cc:References:From:In-Reply-To:From:Subject:Reply-To; b=EPxXXTv2yOAfkDeBVlGeldcmNKyITO49k9DX4W1JG3YiE2Z74mj7AwH3HL1ng4JuL4XxI3I2isrYof/PHPDdpVN996WJqCpMr0pkAFvfwFV5SZwp46MjvTMeRQ1GAR9zWWRo2FJCRnFND+/SktiTxIiWFnlf6zJXk7OnBYGNhvJQAnPIKH2weZ2rIVCG114sIM4XTNPZeFllAM6QUMRqMiXedWD6b/nwKU/1Rawon/5NquZ9uPQA/EwsDnXni/1UMKx8zZ7u+NlrBG67+RD4mNZntTeEcqw1rJ1tjqkse2NY9afIeqwb598x3ZMaZSUOdkg6HOr+ubgMCK5VFGysJw==
X-SONIC-DKIM-SIGN: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1792688424; bh=NrkW7Nzc52jx8owV4g5TQ09TCsBPGhlT5UFiu1qUhoH=; h=X-Sonic-MF:Date:Subject:To:From:From:Subject; b=J0fJxifRcTTaKtm1kfx9ZO5CcKbTJMtfN18e9pWizD1uERM7sGK7bnuACDtqKSMxG+tL6Hy+iXDn0i1QM11uB/3ZiH1zb5BWyuvJEiQF6uL57etcG/GTtwLmHKIA+ra+3JKSOYo5rJhod2/xvS/4gu84qPKamy1shn0r662FSD191d0r/Qu1oFRHYOknkPo5Ccfe4FICXhvLChyIseUzh8oIbLwWdcePDbYO5UpdZ7QZq8Y0+NhQVvkbZXPIiiYqa7eA3FNVN/+AQ1OYqhzlYBqmx1/R+Vo+oOZzbU+xmNaDpfS3LG5AZNq72SvA21YMSlBfdqfJ9BRQXY53D/eSfA==
X-YMail-OSG: xRD30LcVM1l1oAWUFc3wSEmkOWJMjiD2Jw1_JGIU9Bdii66XxC5fX401cOGqfnB
 W4hkfMQKIcRII8bT.rM1fo.855tYR0AsXM5AG5UG6WzBitDsVK2h7Wjx0s37e1372WH_8mlt7JX6
 _6jRINfXlTnxTR_21HJwSLhWQThvcWhBT2zsXPC5LYdjE4N7Gj4br9VVpYumqpUgjIlBOj6p5krK
 aNHtytIbJ..6O2nnRC1PmkkfILLQ62ZGoPtM1uhFCc3Xjwg7am7Era7juk2bFyI9FSTboGets_zm
 AhhfffgPfIr.RiYkKOZM3sG2W0sovPZPZwgb_DHu1pvsAbsJN119nN8dlJ3XlGc7X4uZT2d4oKZK
 F0aRM0Z7zXFfG2S_5iib_3a9_s3ptZi.K0Zy35ekZh_rDQICVey1vlANnUpuIV8WibgDK06yPdno
 ap29UZlv7P.xsaYVTWU4_AGVX1fHV0cXuiqYZE.zLonqzqnQM..e38uwxx9OCyMi8A4PdyyBY.Dl
 Zs9k.G69vmbM6oJqYPnQ5AsNDS.kdW.IuhxIdW.7DrsP_PHBGZBGmxr3dCeBNHpKQBM1I5dQK.WT
 VuI3c_4lX.Vbej9sn9BNpMMPf4P2djGeKXOFjib_d9G1KXuU2VUEpCWTpnGAKWN.P72xQLPNtRso
 yYN2svrh4sPjWXhnH1g6GauSpLPf64jyzs86EtT_Wea0htZ_180xUpFJ.dOtcxv6a7BjQ6wW.USw
 enbtthrK0owLhL2HWC0.z1I.MBapxkZM7d41Djh7hiRZHyULXOp5AhqWVNk.RauEQGMYXwyOzHq3
 LRuDUZxNE_BbMfol99ddoBDvLyNk0qONeuU0qT0GGBPwJu4J6t.9Jy6ZReHksf3C5pse8IcnUWpJ
 oiVak20A8O0z82cBUMMPCq5mrJhaopEEjAtomXD8asxCgmOwbLDwMNpaTPMw_pGsi_VdIs6_28RL
 TuA8CaMXHGMSRA71Ic4aOGUXqECu0PudSoQs.uqjXnNnLHnypRxns6kbJUHBWVdoFTxFFo5hQR0N
 JCvfRnIwGfZ2hDFMNLSp2c.zRJ2HjBCGtLayGcFM3rD9.rP3uTQ6GCuKe_7pQgfCbVNbxjRzxsgS
 Obo3VPPf0GtkxoO40P.33d5dMb116c.0y2HIIzG4b_0mVAZmhr8ECM8_oL_74oDzXHgkNIcRuGMw
 ADNkAH4KfWAI1xaSFM3PUM0xA8wK24KEeOG6GbGHKg6nE2R4eSAEwKhme3rwMdP4kv3qpLnWr4GH
 eaM3ZtVYjDlXjMQHOS2JfWYHn8oNto9ZV6NCcZPc2sEOhIHp9cyudxIDTgiTpFRj1V54Bi_eai4Z
 HBxTUzS7tmHZ72ylhKjwgJrSbpJogTzD9BFKYDvFlWmLAd213iaHFTAX5Mz47ywgusMAqmLhwHV0
 jV5YJZcSSQnVap5iiecEXGI_1NigxWNhtYR7fDNHw0QZz3IEWh01sI8SHI4yibnh.YuTSR5qecoC
 2O6q4yD0Gki77xehQHLlekwqIiOuKNZVEWvg4PqGxLW6NwnMor9q0WTpleTQhMZWBFCTxQRub9XG
 PVGsC0w4bAqIz55qdZDgRM9vwy801Bhe0nb52zQqoOBH0KX0sOmwCLSLaycKTzwWdMTOsW8u9sPI
 QCWyQJ3A5aUCDmMG6bLwmidewITkoRGE.1JH6er9_3gzJtrh02TOjUYsZQbKY_ECIs6MA8vOZ0Nb
 veczfcbR9IMqtdArlPM9Vnq4COpIpnlDjd7lNDodwAokDwCqTmzF6lKaDI4coWoaVzc84axARzS7
 lpmxdvAhDwr_unQu_3UAAD4bzArovBsOBvvjB.J5pWDQyKMPh0u0DwfoiJhO_pEPlRYGIlVHGbyW
 _DNJ.C00e4RhbKOnLWG5HjNzDpuaMXqg.YQXDb8H49fOCq0LbXwgtISGQzL0KRTsjCEmuT279hfK
 WRgWseJ3cTB.XuCCb4v54PgI6L19VIVuD1WHvDuelGQX3_j0_gFiRcUpW_Gzr35PJAsnyvD6IrAP
 xjDKCMLU611h1cfL2Y2Zp8VcB_M1tga3Fn5y1tRIcyNO0xJYATmHWwk3wNBW9SAwBTvFttcbSUH7
 _0H0_Dnx_YrIZN4whokDOFEzjGbKb5sMjH9W2wcuAsUpAlqfMboL2WcZZa2vgR_AlJSOGt1DffQm
 sxr1vQZe1ZsTq3yVIoz7hsl..S6bA2N2bLevEq7L4IM8zaRmvlQd6SuI3NGEdQde4sUeuvoQDh7d
 pa00D8_nGDTxFDWGfGA61OH6654zf.YQIVLkRaa1bB2LtWAsAipxG1Tq1pZqHpQVXqxG_eQ--
X-Sonic-MF: <casey@schaufler-ca.com>
X-Sonic-ID: f4d52385-1c22-46e9-a768-7fe9b7b03ed3
Received: from sonic.gate.mail.ne1.yahoo.com by sonic316.consmr.mail.ne1.yahoo.com with HTTP; Thu, 22 Oct 2026 17:00:24 +0000
Received: by hermes--production-gq1-fd7994565-wwgbc (Yahoo Inc. Hermes SMTP Server) with ESMTPA ID b52a058941d94202e488719cef4d9678;
          Thu, 22 Oct 2026 17:00:19 +0000 (UTC)
Message-ID: <018ca365-ce9b-424c-b600-bd9c8aefc9a1@schaufler-ca.com>
Date: Thu, 22 Oct 2026 10:00:16 -0700
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [RFC PATCH v2 00/41] UUID and GUID user and group ids (*_r system
 calls)
To: Jan Koester <jan.koester@tuxist.de>,
 Christian Brauner <brauner@kernel.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, "Serge E. Hallyn"
 <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>, "Theodore Y. Ts'o" <tytso@mit.edu>,
 Paul Moore <paul@paul-moore.com>, Arnd Bergmann <arnd@arndb.de>,
 linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
 linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-cifs@vger.kernel.org, netdev@vger.kernel.org, audit@vger.kernel.org,
 keyrings@vger.kernel.org, linux-kernel@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>
References: <cover.1792552161.git.jan.koester@tuxist.de>
Content-Language: en-US
From: Casey Schaufler <casey@schaufler-ca.com>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-Mailer: WebService/1.1.26740 mail.backend.jedi.jws.acl:role.jedi.acl.token.atz.jws.hermes.yahoo

On 10/20/2026 8:15 PM, Jan Koester wrote:
> Hi,
>
> this RFC series lets a user or group id be a UUID (RFC 9562, version 4)
> or a Microsoft GUID as well as a classic 32-bit number. Processes can run
> as such a user, files can be owned by one, and credentials, ACLs, keys,
> System V IPC, sockets, signals, audit and procfs carry the whole id.

I can't see this being acceptable for a variety of reasons, including
but not limited to performance and configuration complexity. It's a
general solution for a special case or two, and the impact is significant.

If you're willing to use a UUID and/or GUID in addition to a UID/GID
instead of in place of it you could consider implementing this as an
LSM. There are a number of issues you'd still run into there (e.g. UDS
attributes) and I can't say if the resulting behavior would be what
you're looking for. I also can't say that the security community would
necessarily be any happier with it than the general population, but if
you really want this it might be worth a shot.

