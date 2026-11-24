Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795553161;
	b=njBUh8LH0oqRY9XUxAuKqgmev0+JSLBku20G8YuQM3GCulU+5xXavg02eDHc2BbuHeit
	 l0ZOPHk1VLDhPua8mf6f02ZYNIPlT36fKR/5vq1R3o46JjaSt/hZzBIfVLpd4c3IyzD8O
	 rcDc+bLrTWb5CHNdYV0DgB+446e1XQ+7h6SWgnHy6Hio2udr/67jFUQ9/+er7e1nyjZP2
	 PcHb+Gg3Pto6tO+Xoa+yIRJmFNSCqV3evwICKNtxx1x4peynEaK868AND2V5OYYclTiT3
	 NyH1hMLXHLbjJvsuZ2/dksQzn3iZ1DW8HYalZAW0i/ts9uOTShi1QlXUU1jYLeK5lSg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795553161;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Sender:Received:Date:From:To:Subject:Message-ID:MIME-Version:
	 Content-Type:Content-Disposition;
	bh=38lJDMT5xRWk4p8F4X2n0yQXFrty7LmyO2WrdJ2Nx5s=;
	b=S54vW6pPBNEx6S+8kQI/6RTq7VeJW4CJHCuOzF1a8ZP/R6FbCeZn6Sof4ArHNP0wnGfZ
	 KUsW3dxl2uSiJgm7NCnp0MINoEQNTpwpSQ6KSBOomigGlfgplzJuMxjNqxopFFrURlv6u
	 PfXgm07kj7/PGbhPiYjwGb5CLclWNxj/N1HKYJR5EMHrTFIIOrnF1LTI8JXodH113hgUC
	 4yNKzVwZoeX0iFENu+yHHjJCJvXiiYJHc4UuRZnVLwuxGfuHg3dEORYufQpkBbXv8kMGA
	 ZW5uPUtPnPpkQTKlBZKpzmJTSgKc/rnO+nDTjjCA4cKRTdM5cyck26pPsPmxpuxAUmg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=fail header.from=debian.org;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=E3lcZmXI;
	arc=none smtp.remote-ip=209.85.128.45
Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 09050606A31E
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 20:46:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 09050606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=E3lcZmXI
Received: by mail-wm1-f45.google.com with SMTP id 5b1f17b1804b1-4a35ac4475dso37310425e9.2
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 12:46:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795553159; x=1796157959; darn=vger.kernel.org;
        h=content-disposition:content-type:mime-version:message-id:subject:to
         :from:date:sender:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=38lJDMT5xRWk4p8F4X2n0yQXFrty7LmyO2WrdJ2Nx5s=;
        b=E3lcZmXIVMY1gQ173GgrXmgQ1gKE1EEXaL0tjgOC0jyPguEUQA8CM26dRRTEPOk1zZ
         LHyWjk+4UAN6SrFT19bn9hDJygR859f4O7hPFfl2yw2Bj8Ye5TcQxyI5JqDDrrl4+v1w
         XPLtyfzVPmeOgn5EWtLQW7SOfCr6uyNUBLJF+3LMpgbcOW8yhgPJ6Iz38s2lBk0d3xJN
         IrdrfRqiSqxPPBP8YMy4wG+P82Jp9K5FQ1W9skp/Hdg+wNO/8uIhz+LS7YczuvmezeBt
         sRoOsheyScw9srQB/dyBpL+fn83rABkun9zWD1zcl9qWtBHn8oBHFWZhXC1bKUhNGlbS
         WZ1A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795553159; x=1796157959;
        h=content-disposition:content-type:mime-version:message-id:subject:to
         :from:date:sender:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=38lJDMT5xRWk4p8F4X2n0yQXFrty7LmyO2WrdJ2Nx5s=;
        b=CfHvUOXRNKTeLj2H58eo4xWWP/G3A0nDHqsBDZTW0fTaZzd3YvhlJ9uyIp6/wTHMLa
         BRcYpPKtuGT8cWgviL0WYR9Lul96yJLs3dTOQovZUA8obE18FG3R+faAmOZYnP7cKzw+
         hKJNdIzCXQlw/phqYN3bI3gkOIYagrrLFzTHQvChK0CoQtMWqf2pE4kATfXW0mxc7EYl
         eJfBNsvnET/TCvdtbZOFpA3agAQo9LdmguqgUb9ZWX87AA92+JoyUNRNLRDfxI/tK8ob
         GvzKh138pFNKU4SjTnDepGJrzuD3Ok+eWxSJMn9b8qnWptpJ7RvtlUJxSsTO92ATQ11W
         NYEQ==
X-Forwarded-Encrypted: i=1; AL+hErGi1XrdpbNcxCfhFPQ3Afz7MiDql/57ux9a8qfw1fnnTCWcgdCY68oG4HuA7c6CNIR/saGF9VF94w8=@vger.kernel.org
X-Gm-Message-State: APuU4Z9Ksf3KBoEZ0KQOzMvRcGxTBgn/5HpY4UKHvu30j9fROxcH+4SZ
	mI68XQGDaX4JyDXsuL/lrmgd/4/sODmtK7Z+a+y06hk6KiiT8BRBhyQe
X-Gm-Gg: AZFdTZfqmLX1T0FClrdGNbuL1a2elGLVEX79lGxZgwiJEs/NdvVDsoQOk7ujNYoURsF
	xmwMArylFxdLO7bATwcwMTpjO1mF8SuMPUQsM/zMoB0IkxtDSP/VJuHM3xr7bBzaPMvf9xhteBr
	m0DMl9BHDz55pCZA+sES5vY/5uuKktpIWTP7uUWoTdy16WynkTKgi6LtRgtmVdBA8SGtSyOh1CH
	V8ta5rSFgq9BJqcZaw0rIznkR7YnKNE6NaXnqkrMldHq1NjfZHMpc8JuO5vMG3aVQDPx3+zScWG
	rXyUN8ffAT9SM7OFB+XKT5J+CVrjjLHCxH4idp7VbJ3eHdp4NvRfVLH6qHBqgg0DaCE0KNvSIDn
	PXSZZiwKvdX5Pw/rhFHLioPOXvhR42L3KHo41X81FB+osBZzn3jzt9mdLL63XGzrhg9KCj90ryD
	mlr5KJzFTrI/xmK4ztWwBL9lODVX5Y5nyusX17xj57j9DfI5i+bVTf9O19uAIsDoAFsKJmb0qW9
	KeGpxD3MM9Od8aaUksvT4AsNhwxKjrL4Uma59wjzCTwb4Hh/RTJvO6cJ9xVLLFeVaDuOvyPCIsP
	F3fQLssuhorILNI1VpxJSuEZOt0xel0U7Rb5ccR19zTrhpo6ebWiWbmezis+Zs9D
X-Received: by 2002:a05:600c:64c6:b0:4bb:6fd3:5aaa with SMTP id 5b1f17b1804b1-4bb887c30fbmr284311285e9.3.1795553159121;
        Tue, 24 Nov 2026 12:45:59 -0800 (PST)
Received: from eldamar.lan (c-82-192-247-196.customer.ggaweb.ch. [82.192.247.196])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb9067846esm294729145e9.4.2026.11.24.12.45.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 24 Nov 2026 12:45:57 -0800 (PST)
Sender: Salvatore Bonaccorso <salvatore.bonaccorso@gmail.com>
Received: by eldamar.lan (Postfix, from userid 1000)
	id 17328DC04E1; Tue, 24 Nov 2026 21:45:57 +0100 (CET)
Date: Tue, 24 Nov 2026 21:45:57 +0100
From: Salvatore Bonaccorso <carnil@debian.org>
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org,
	Benjamin Coddington <bcodding@hammerspace.com>
Subject: [nfs-utils] 65ac44e831ca ("nfs-fh-verify: add tool to validate kNFSD
 filehandle signatures") added binary file to nfs-utils repository
Message-ID: <awX3hTLvX3tNkdyy@eldamar.lan>
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

Hi Steve, Benjamin,

While rebasing nfs-utils in Debian, I noticed that 65ac44e831ca
("nfs-fh-verify: add tool to validate kNFSD filehandle signatures")
adds as well a compiled tools/nfs-fh-verify/nfs-fh-verify  to the
repository.

I assume this was not intentional and it can be dropped?

Regards,
Salvatore
