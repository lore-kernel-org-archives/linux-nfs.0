Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5D9D40960B
	for <linux-nfs@vger.kernel.org>; Tue, 26 May 2026 18:33:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779820389; cv=none; b=Nx55pvXfZZLXcXan3z5Ezuoa9y+2kgurV4tP3zW5k0SHADgLECEfJ34QC9pht03hsrTy3jsx9gXV2ay9H9Yxdpa1Nb9gy+y94CE7WgvTc+2wni4s6rMkQgKao13Q/3li/Rfo30fd6f5h9EiQagODfgjxh1G+9cPHFMKwbEYF/Xo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779820389; c=relaxed/simple;
	bh=2A/VDZvxH5t6t1Mol8hbCyR6yIZs31yJbentmztRjNg=;
	h=MIME-Version:Date:From:To:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=oLREe3e0ag2nKhEq/MPc18Lx2G/MYB6cIuIPdJCMzznoTZiWjV2Avx+aXF8F05Zz1yxX8gfV8rKO6q8369rw6gmqjMgu1y+TAkTnQwQMb16Sg586AtVqmK2uNQu01iIuh5oTWP+bzX7wHAtDlPo+PsbdNG5XQeInSQS0dzvk1VA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Sic55EMy; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Sic55EMy"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8BC051F000E9
	for <linux-nfs@vger.kernel.org>; Tue, 26 May 2026 18:33:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779820388;
	bh=2A/VDZvxH5t6t1Mol8hbCyR6yIZs31yJbentmztRjNg=;
	h=Date:From:To:In-Reply-To:References:Subject;
	b=Sic55EMyDR+E3rF2XAMxpbqXwGIa9jlH/DfNzvOqRE1TX0DPk+8r3TdleL7qZMEwW
	 d50fuhFABNR6L158j7Y8aG1jm94MnqqDZafYGduh8psshg7SDNXhwV9xMqQce7i2vH
	 NDeXf80Gxy8r1vrtVPnKzO8XFjwMWKZVD5WJ8CtNM2YF9HPzhf/qSewvYYzSdeEYKW
	 y+ELKG2TbCoeGnyU5xCzHTrfvrhsDqpBWRGcGTKtFBf3D21BEa7RsZ95kmkxP9GA+8
	 PeRO0SYrw9fJL3zQlEXIPkjhPnfflcMcxaPazOAjw9rz+5Ij9zzbUyc3tS4A4QcKkU
	 8VPUaPrzwgX/g==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id DDA85F40084;
	Tue, 26 May 2026 14:33:07 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 26 May 2026 14:33:07 -0400
X-ME-Sender: <xms:Y-cVak6tUlhgdFOUI5-Sl-dsKPWxytG2IYAQ3kk7eAtfdrn-OFBPdQ>
    <xme:Y-cVaguyXiaIFAwbT76aKFPv7zCZyCHGdB9StwKp_8BKKzHHlzWlfIHAJhqC1BPj2
    htDcKXVLwxjRdk2zlRbJ0XUkBUe_bvwrkmTfV7ZhazlngCxZaJF2Ls>
X-ME-Proxy-Cause: dmFkZTEI9+WQx+U7+hjBP0EEf0Fq4TzkpeyCqGFtZxGREWS7VE8QsIGOs5gd7FxxAAcsuG
    R+k+Bxeo4jAd+CFgoCT9GelXmNnP1iemqtZflTr9Xs6ttQrOjQzSmUGyNCTDUN5eSQYws+
    5DwdqDD7bixQH4b77zUpJ99XNZqTNqKr72GkuyHIrCxab9Jbk4uzhqaHjmNhLFKvIedA6J
    vtQgjy2R1vcZ/g8uESqzWsTMrDR6TCY7ySBLV31b6hVvJRdMy1AucR7nnJdfHDUoOpF/Cy
    cIKkKo8T9hUjTK0kw9+TH1mE2R78kut05DtAZViIwMwSol/WyfM1DDdO0cvmz58vhZEFLo
    xv7PjqCaLYkoV6roYOrszBe7b4W1172FhblTWYWK0Btf6o7BURwbwIXRAgDjZq//+lAQJj
    41VNDfPKTPeW4hQ79thaMlvtn8Q+SkXn1DmhQZPSqAifK3NbSteTWGvjUdWJVOT2QNYO1H
    GMLEEsTe1dn+vQu7XxJy7Xp/FjBgPMkUkHFBpw63iKu79bM92CFbXkRbWfkVsRTRt3FbFz
    Lj+P754+bAMuOZl8gfT/HyQ5F6vi3414xMvOufU+XsoS6ET38f9X2n8+9OD81Snh3hZVU3
    Lvinv/LtNJkVUDJOt75D8d6o+ArmTRujLfX2ADIRMETW1pyd+f6kZCRONASQ
X-ME-Proxy: <xmx:Y-cVavkD-9RXrKe65RvnFoVhmEvMyPnEF4dkCNtUBF7yHUl8sIIpDg>
    <xmx:Y-cVagyw2PP2PwzEkGXcUmLkPmNiZv24GtduyvbkVVZyHizk--SNmw>
    <xmx:Y-cVatM6RB6nljpcjWbMACyV18ykgFNh47L-uuubITz1241dM-M0Jw>
    <xmx:Y-cVakSJAgIfWLxwbCx4CtHXNPRyQbLxEotKkh4Z9GMzZW8bv2_fgw>
    <xmx:Y-cVarY8rIAIsnhBqIaZ7KDgNSRsvpWDmlQuNBv_XKVn_q32L1r5aVLT>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C2181B6006F; Tue, 26 May 2026 14:33:07 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AYCzaE3bdtoV
Date: Tue, 26 May 2026 14:32:46 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Rick Macklem" <rick.macklem@gmail.com>,
 "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Message-Id: <3611cc56-680f-4665-bb86-3b79d8949009@app.fastmail.com>
In-Reply-To: 
 <CAM5tNy4OxnoqYvWhmyr7Ksk0Cc12_Zdn22fwoe+N=Z_3GYpapg@mail.gmail.com>
References: 
 <CAM5tNy4OxnoqYvWhmyr7Ksk0Cc12_Zdn22fwoe+N=Z_3GYpapg@mail.gmail.com>
Subject: Re: striped flex file client patches
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Rick,

On Fri, May 22, 2026, at 5:22 PM, Rick Macklem wrote:
> Hi,
>
> Hopefully you mind a dumb ass question..
>
> Are the patches for handling striped flex files pNFS
> for the client in a kernel on kernel.org now, or where
> is the best place to grab them from?

It looks like the patches went into Linux 6.18, so anything
after that should have them.

I hope this helps!
Anna

>
> Thanks, rick
