Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794237375;
	b=uDvc7yHoni8OjAn+ICyzO1JCmVOXxY/bn96DiCV+/UsdKB8mfqzf9Hnf1ztWGiu5spWM
	 3tawC4ztWDNEFLrgyHPOKojVaCo9Naiws1UUvVXa5SWOfIYIyLQDT08EHDVy8BJD+HZxi
	 zkNQcm+i6+xb3sxyXP4wPJRkWgaz5cjd5J7sO6loSEl0B7u4Hi0TyoV1S+9s1RwFkimEY
	 soODaB4Hu+ZNKnPw93wC7B9439DFnjBnp46bvvIpME5V+Bjl8Cn+F1TH5oCRK0eiaHlV+
	 qWeoBezbQaWTC1pKElF/meg2JZ0SOuP52A7VaN9+skWWSekYroDOX5m4STMqMTzZHtA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794237375;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=ILLwKIY1l8/2C2M3tEMK5/2Wk4x1T0msHL+198Sb7AA=;
	b=vtByuf/G9fMJKnPGQwkxJ4yN0q7Y6uZChp88BqLNWRPoeA96YDoFFgL59MXSzy56Lpwn
	 DJjmCZ1z+TEpDbzDSssGgf1Yk6LZngNcjEZc+QXFByaymivEXgKH7RxcXMBoeY3mLnZcP
	 SUhTms/IBqsec9MsBe0RQrXVITffN3LnBy5SNstLE/M7M9Nt26GuPc/z7JtMOtof9MNMg
	 siDrAn7RLrXGTu5xJcXdEeniH0js+NukDpqTDp3Ig+6TgSltExJXtPBhmE7Vn6CNI5LQU
	 aoKo7W6gtVJaEQtL85bXynxHLhGAbvoiVCb1YJVDFNMhOo0bDpTwlxWE8G7yKVhbTPQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DE7b8BP7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 6C7FB606A31C;
	Mon,  9 Nov 2026 15:16:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DE7b8BP7
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 5444D1F0089F;
	Mon,  9 Nov 2026 15:16:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794237375;
	bh=ILLwKIY1l8/2C2M3tEMK5/2Wk4x1T0msHL+198Sb7AA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=DE7b8BP7Cij3P//t/Vui28Z7jAeD71euvurnOgD5m2eGnFpoJ8cX8Ct+Xn/n+h/Vr
	 /vfXa0aZBFB80IYdROdppGXAgmseq3YTH7vkDkH9e6IzF24cUT45prMu20v30XQVa3
	 bJ68sHIanl12vGG+3QWFuX9ngSrv3KDgBbbmSH2CCHNL45Dwx60FpbXNWdcJ4zBIxy
	 GmHDKnbSG/R8/ZYHoGqE6PIk6ep1OdEFThID70rausnaalZsFsdr/JbqOkh1z2jcqs
	 wk09RE9oz7EcbZFL8pDOaKfc50mzyvWQqqxmPdjeZwG/u8kOK23oyHmN12jmNg+VRx
	 xpKODiRtpF+gg==
Date: Mon, 9 Nov 2026 17:16:11 +0200
From: Jarkko Sakkinen <jarkko@kernel.org>
To: Sumit Garg <sumit.garg@kernel.org>
Cc: David Howells <dhowells@redhat.com>, keyrings@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
	linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-s390@vger.kernel.org,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Gordeev <agordeev@linux.ibm.com>,
	Anna Schumaker <anna@kernel.org>,
	Bharath SM <bharathsm@microsoft.com>,
	Christian Borntraeger <borntraeger@linux.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Biggers <ebiggers@kernel.org>,
	Eric Dumazet <edumazet@kernel.org>,
	Heiko Carstens <hca@linux.ibm.com>,
	Jakub Kicinski <kuba@kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	James Morris <jmorris@namei.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Mimi Zohar <zohar@linux.ibm.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>, Paul Moore <paul@paul-moore.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Simon Horman <horms@kernel.org>,
	Sven Schnelle <svens@linux.ibm.com>, Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Vasily Gorbik <gor@linux.ibm.com>
Subject: Re: [PATCH v5 07/12] KEYS: trusted: TEE: Disable sysfs bind
 attributes
Message-ID: <avHju9kZBiNHhhTu@kernel.org>
References: <20261108222719.304712-1-jarkko@kernel.org>
 <20261108222719.304712-8-jarkko@kernel.org>
 <avF19RckYZWu_3FD@sumit-xelite>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <avF19RckYZWu_3FD@sumit-xelite>

On Mon, Nov 09, 2026 at 12:57:49PM +0530, Sumit Garg wrote:
> On Mon, 09 Nov 2026 at 00:27:13 +0200, Jarkko Sakkinen wrote:
> > Suppress sysfs bind and unbind attributes on trusted_key_driver so that
> > userspace cannot unbind the driver and unregister key_type_trusted while
> > the trusted module remains loaded.
> > 
> > Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
> > ---
> > security/keys/trusted-keys/trusted_tee.c | 3 ++-
> > 1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> 
> Sounds reasonable to me, FWIW:
> 
> Reviewed-by: Sumit Garg <sumit.garg@oss.qualcomm.com>

Thank you (for both).

Br, Jarkko
