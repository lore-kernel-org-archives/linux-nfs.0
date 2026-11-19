Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795125091;
	b=15Q8uOtew+vTNGx44hxf0inG8CYIPWtDfvi6MNrXCReaOMYeJU9yUf0SAIwPDr3y+XLs
	 tUGizlm1E9dAreNQE7orlsLoT8/O0QNN3e7tVkKRmcrX/BCXAw9zmcZbqeWXa8RMNkYmC
	 xLD195csqShg3jEmuBukzEL4LpQ1haTXoiS5LIg0ie9gO5e41DEIYxza07tMmmQDa1u4h
	 Tgsq60rPab+SyaP5NLaxii69btFSwfZJEXJJ1mKpW7f9djkil40PUhoiX0LR5jsOod84Q
	 xFo/lW5oYSd7DlVQ95LOUj7bVpifxWZTngxjU8hVjh3JVOfQfxyMRlbCyqi+7KHfAYg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795125091;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=Ny3Sl9Bn6sHIvah8OWFokkLcjHbV6BwIAehQvpJWiOM=;
	b=t0NiDGabIAwwQ6p2N+lVVYTRvoBoNicvwTPXqb1HpzFLpoA/UzcPmBWPnOh8oQ3hnb4X
	 eyoAeR9jW2vK2YGi/ZIxUXeXSQkS080Ibmx0MefsCe7Kp3j0NRzHBUQb38cHxnqj1BpR9
	 2d/ee6tyac/qS1jNtSB1hHE91utI7kOkMDFrpPcKtumPEZ0w9ZeR0874tHUkdDAyAYMaD
	 CRfeMLiX2Bj1e6BcBTuSGKrvE+KVzEFz/7Po4N3dIzIN2r3EdI7T4NALjl8EHypOfXmvz
	 VYTay74dMqyrBZgJDo9NWWls4MbUYVzXnM5VWsPQeWgAeM/qH7mGCz1N7q2zrraAXRA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=IlZfXAdV;
	arc=none smtp.remote-ip=209.85.128.42
Received: from mail-wm1-f42.google.com (mail-wm1-f42.google.com [209.85.128.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F3FE2606A325
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 21:51:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F3FE2606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=IlZfXAdV
Received: by mail-wm1-f42.google.com with SMTP id 5b1f17b1804b1-4a2000d5fb1so1142625e9.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 13:51:30 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795125089; x=1795729889; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=Ny3Sl9Bn6sHIvah8OWFokkLcjHbV6BwIAehQvpJWiOM=;
        b=IlZfXAdVqjbuXw7jCUzgBXdPvunc6N0Mgo0wFLsi18PRIXDg8h5ImWiXqqG9r5Z3nz
         mMCiHUUIjL1nanBAy+gmMMgf3P/DYPfNI/EhxL6VmuCltURwD+QgSpN5wH9Ap5okdiWa
         y1/JXPn/JLNw5xRoGTUzFUnMvRCF7c7CMfNmwx5ikxXdmn96ekaYhxXTtb8MRXhNYeaS
         5grEbe59oWK77G5W0OdmQ9pOUNCM7ixvwCJgXOuUiJiLHN4zyLRjXQj9XiUl5nqIEgCk
         mpXfVFfEyeVkldYSBLUdPMoMK3O4rNrOnb4CWeh8R4q5zrhhEuhtuEtenWRCvjHT14FL
         k9gg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795125089; x=1795729889;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=Ny3Sl9Bn6sHIvah8OWFokkLcjHbV6BwIAehQvpJWiOM=;
        b=IJiAeKlFppxQd3iwmlOaIQDrjNcgZaU/57EicyiBB1V3kK3ktOSlAfUVfla10JX4vJ
         HPmo6b0p4Vs5dZrIKuFObWpgi2sJbw0NglwwZ0WTCMl4Xo5GxToI5w0JTIs5Qr38eZ6F
         Xdpam6m9ELbYznchNEcwywofu84VCKb/ObBlo85bzzOPjvW/NlObFOwe1H9/abFCzJP1
         NGKBFSsK8Ihf0XX/yQLg3b8Zhb2NmR7yuWmnzo1uu8KiSC3c8hCt0oUJH2N+DrkkXNoV
         Dj2N30AcpkQh5Nkc1VKh2hrzRb5skWUHRpIbqQ2vsU6TDViTK40y3CpVtQbiuhOoKnQ2
         rCcA==
X-Forwarded-Encrypted: i=1; AL+hErEFleAV+ykKno9PhAUapihNQ0lhBFejQzKaEap6HDAAkltzoLutKfjGWNuXOF5c+Npk7Zr/3PUAv/0=@vger.kernel.org
X-Gm-Message-State: APuU4Z/wlTjODz78LTr/B1CM7tW5zgPXqXjVC/ktZD4tSjLE74f9utoi
	JvJxS3a7fFiAy31hqQHB/+az6vh7ZTUXMmQX4sJY/21kuHK8iokw3uSp
X-Gm-Gg: AYBFou2oDSnq3bqiHcyF3YAwJWyYeSDW4BEaIrdhdlgxYrgHFnlPLElP/F4ZGwLc08H
	n3+PLZ+d5SlPzXwFB84RJkO6Fg+0S/Rf9p8CU4WVIzXUyEuF1cVp2oMZ64oVFnu8jeOhCA/5iDl
	4zVWNKXCmbGzHs0sz7qV4fAld5eGCKo1YwfBlX7gXMY/Rha4YmOKZsvJcEyxLPWtKh5DXQF8Qt9
	nMRaz0uHJ91OjIvO180FnL/SpiJHDzKLL9ueeloSXvcd0ldhKKP4AXGdMGM6lsMhucfj8Qbnfjb
	/ZK2Zqps9RqitDMpL2X9TS4BrZHync7+mtg4WGICirrwGbMZcTVWENtDtJA5ryL0mvez887gkNg
	hdZaIc7DbyCuYz30FiKiQaSFXeFGO2QBkLwtw0ExkDvQ6wi8UEDLRR3Mzvnv7pc1QdqJqVvKzNB
	EIf/1vhDXN/yn2b01X/OcBlNZXPrHqSFRMZ1oEjZfQ1Vzzg69x/nAFn/Y3JPWsO450i21PPkubF
	GyVCW74m9YjJ8Rt66KlDgw9p4sRYKUmWtd/7BYa37aMV+UgKP59rNczyZLkk0B9KfQYsfVfY988
	vqsG+Eu1XPk8+iEeyVmMOJRM7rn6y/vkpjqfSR8M09mCI9Y=
X-Received: by 2002:a05:600c:4f48:b0:4a6:44b:2593 with SMTP id 5b1f17b1804b1-4bb8893ab9cmr20069015e9.29.1795125089289;
        Thu, 19 Nov 2026 13:51:29 -0800 (PST)
Received: from localhost ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb884a3a3dsm24821245e9.10.2026.11.19.13.51.26
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 19 Nov 2026 13:51:28 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
Content-Type: multipart/signed;
 boundary=305c4db69b4b7682b4927e5c7245ccd497c3eba9918a22ec95937c8c862e;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Thu, 19 Nov 2026 22:51:26 +0100
Message-Id: <DMZIQG4U1NTH.2IN0S2YIWEYTG@gmail.com>
Cc: "David Sterba" <dsterba@suse.com>, "Namjae Jeon"
 <linkinjeon@kernel.org>, "Sungjong Seo" <sj1557.seo@samsung.com>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>, "Christian Brauner"
 <brauner@kernel.org>, "Trond Myklebust" <trondmy@kernel.org>, "Anna
 Schumaker" <anna@kernel.org>, "Chuck Lever" <cel@kernel.org>, "Jeff Layton"
 <jlayton@kernel.org>, "Konstantin Komarov"
 <almaz.alexandrovich@paragon-software.com>, "Paulo Alcantara"
 <pc@manguebit.org>, "Chris Mason" <mason@kernel.org>, "Yuezhang Mo"
 <yuezhang.mo@sony.com>, "Jan Kara" <jack@suse.cz>, "NeilBrown"
 <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo"
 <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>, "Ronnie Sahlberg"
 <ronniesahlberg@gmail.com>, "Shyam Prasad N" <sprasad@microsoft.com>,
 "Bharath SM" <bharathsm@microsoft.com>, "Sergey Senozhatsky"
 <senozhatsky@chromium.org>, "ChenXiaoSong" <chenxiaosong@chenxiaosong.com>,
 "Darrick J . Wong" <djwong@kernel.org>, "Sean Smith"
 <defendthedisabled@gmail.com>, "Andrey Albershteyn" <aalbersh@kernel.org>,
 "Pedro Falcato" <pfalcato@suse.de>, =?utf-8?q?Pali_Roh=C3=A1r?=
 <pali@kernel.org>, <linux-btrfs@vger.kernel.org>,
 <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
 <exfat@lists.linux.dev>, <ntfs3@lists.linux.dev>,
 <linux-cifs@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
 <linux-api@vger.kernel.org>
Subject: Re: [RFC PATCH v4 09/10] ksmbd: add provenance time (ptime) and map
 it to CreationTime
From: "koraynilay" <koray.fra@gmail.com>
To: "Amir Goldstein" <amir73il@gmail.com>, "koraynilay"
 <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261115180343.576773-10-koray.fra@gmail.com>
 <CAOQ4uxhjxp5sxYphWoB=8sgX3XHOv9zLVYf+8ZjYbS_gQDxO3w@mail.gmail.com>
In-Reply-To: <CAOQ4uxhjxp5sxYphWoB=8sgX3XHOv9zLVYf+8ZjYbS_gQDxO3w@mail.gmail.com>

--305c4db69b4b7682b4927e5c7245ccd497c3eba9918a22ec95937c8c862e
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Thu Nov 19, 2026 at 6:34 PM CET, Amir Goldstein wrote:
> On Sun, Nov 15, 2026 at 7:04=E2=80=AFPM koraynilay <koray.fra@gmail.com> =
wrote:
>>
>> Implement provenance time (ptime) in ksmbd, as introduced in a
>> previous commit ("vfs: add provenance time (ptime)").
>>
>> Map it to SMB's CreationTime, making it settable by SMB clients. When
>> reporting CreationTime to clients, prioritize ptime over da.create_time
>> memorized in the user.DOSATTRIB xattr.
>
> That doesn't sound like the right thing to do.
>
> If the server stored a CreationTime that client had set, you cannot
> override this.

Ah, yes, but how would we handle older files which get a custom
CreationTime both before (in the xattr) and after (in ptime) a kernel
upgrade?

> When the client sets CreationTime, the server can decide if it can and wa=
nts
> (may be a policy decision) to store CreationTime in PTIME and not store
> it in user.DOSATTRIB.

To fix the above problem we should probably keep storing it in both
ptime and the xattr though.

> Fun fact: the user.DOSATTRIB format also has a mask so storing the
> creation time inside it is also optional.

With my current patch series applied, when CreationTime gets set by a
client, ksmbd writes it to ptime and fixes/heals the xattr (=3D removing
the CREATE_TIME flag created by older kernels, see the other fun fact
below).

And another fun fact: until [1] ksmbd ignored the flags and just
read/wrote the attribs every time :) so that can only be honored for
files that have been written to/updated with newer kernels.
(That's why there is the ((flags & CREATE_TIME) || da.create_time > 0)
in my patch, and not just the flag check)

Thanks,
koraynilay

[1]: https://lore.kernel.org/linux-cifs/20261115155308.415734-1-koray.fra@g=
mail.com/

> Thanks,
> Amir.



--305c4db69b4b7682b4927e5c7245ccd497c3eba9918a22ec95937c8c862e
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQSgVimKafU5DQMcjcDmj22qf5IGXAUCav9vXgAKCRDmj22qf5IG
XM7AAPsG6qghsrCfCEnMzpWg6QyG3mDtqVzO2LuI2Jbx+5MdmwEAqDTU6SUvXvP1
4H1OcrcMro3Ek7i+OVcH9ZQ2xF4lngw=
=LZNw
-----END PGP SIGNATURE-----

--305c4db69b4b7682b4927e5c7245ccd497c3eba9918a22ec95937c8c862e--
