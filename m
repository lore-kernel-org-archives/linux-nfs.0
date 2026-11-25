Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=74.125.224.41
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795617541;
	b=uEYPtZQ5jMmdf59H5wxYMh8chKDhs+RKMmiSFB6rDhAtdUmSdWofnPg4a0R8saE6o2xq
	 niAcSET67ar6MKqzEpFAk9UMXe6Ndc55WV5bqqFWihNQ/p3ih02QiThpL02JjQoUIMPg2
	 rhKrNucmUSwAsAis6gO6GNd/RDne+OF40sMtV/eVFNIPaoqmWSklQLRP0Gc/8+pO11J1q
	 iAaCWW46N+wS3NnTFURCsT3o/RajdMLbXuumLf13MSOwe/iFkY2f9AOGizceTxFBR0NWV
	 FgLTIpLXxHGl+fhCKIY4tAtjMWwsL8YKnHzgROkfGGgHS6gddWDrQNAWJcgTvNUjiTQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795617541;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=2vBPf9O5A2N6vPyFBaBk1N1z9BatJmAjUAi4ZLhtVRI=;
	b=o+aqJc0LF1cZmdPmz9kTdUngibxrt8+FecuzGnOPfN9druL3tACIiBp06FOlhwllmNOJ
	 Q72fGH84tzmovA16hwrhaVOoNeKNw6mNAvHdzFlQGeDHpun9JgaPqSf8ucdk5FKvnujqD
	 LvyUxATlgZ1OkDJXQdx2pILL/xJW7zd2zlCxmyKQ0fCY/843Iq1Mw4Okzh2nJobgh40qs
	 o5weKPY3j2jixPXTYQfedBsorlo8FS7CC0ThCGVvTzbNqk5ZG8YZbQ5+PjsK2swdFtAgK
	 Yv5po6hmecsHcfS4NKzs4kvCh5nT1N+nLfxw9xu3THgcObSxt666yCTsUZUwG+imorw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=tNuOaU35;
	arc=pass header.oldest-pass=0 smtp.remote-ip=74.125.224.41
Received: from mail-yx1-f41.google.com (mail-yx1-f41.google.com [74.125.224.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 679D4606A323
	for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 14:39:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 679D4606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=tNuOaU35
Received: by mail-yx1-f41.google.com with SMTP id 956f58d0204a3-67df3b1ca06so6568212d50.2
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 06:39:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795617540; cv=none;
        d=google.com; s=arc-20260327;
        b=nSJQ7UJEfOVrq6SHdo1Kwj1Ha97r7QrA0J2YyfnyEZM6agJswDcrRJvXvf5+jKMzpe
         zBCAXBeKoUVAZx9St2TkTJwZNtj2TxvlMLfpzXQhIZwKe3BIbGgGAc/89mUDtNxCyxcO
         8OQd0CDa4vNgUH+JzJXy/ddPHQm9bXup+T+MRBuwdx42jrAQ3CO/Qs509gw2c0fahnId
         HtUDTPX7rAsEnBNPk/e8rhKDBgLG7+SPsuJGnRn4lFKH0bVAxcdd3HOrvNwuCGV1yZCq
         eCMo+U47aUXHJmlfm+VE4r8/ZAKmqV+pLG16r93GlkTf7CIad1wRZyPt20cm0Mymk0rs
         C58A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=2vBPf9O5A2N6vPyFBaBk1N1z9BatJmAjUAi4ZLhtVRI=;
        fh=rF6vhYPer7J3QUm8sdfE/184qOWo1x5HKkFFTTuBPcs=;
        b=TLQLvghBxQl69ye1Volid6Wms61MMYsUWE3ZOexanwJaiy55NP9EM8kKvTC1UhHug8
         0kxS1036nLTzeXHUNYOBzQEsMqzN6fEwTD67aa7Kc14Y0YacRZoyJ3d0+pHc2+8fYYLX
         CQWMxz1tqy/0OQLancU5OyRUkNRfqpG7v/f/Gq7WGnmhYdPMNqbfu8m6cmM2J9SnDx5G
         emtehmtEKhua3rV1mGf67gOGt/w+EuI8YV6cU2mwjpq3fV86T+9P27zMVvxF0Ln9BQEA
         ksMA9B62GrYhekdp1YQw/Mo+WILmQylOOhixWebw5aBJEoIM7hHkaKH2HsoUioxKIxsA
         DdUw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795617540; x=1796222340; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=2vBPf9O5A2N6vPyFBaBk1N1z9BatJmAjUAi4ZLhtVRI=;
        b=tNuOaU35BPa5VDSA86hNSc8Rt54eBqJ2xrUuX756fLosXrG5//yL4CFwlNPQj4MrT5
         n1R/T2rl9AuOAur8R+j0y6G68bH3CeubbZsCcsbuCKR2yG2Tl6hx88jYx6UJIMp6qNTV
         uRpv/n/gj/3VOUpQRXzTwkbQJ7w4HpshSh0+c8AXsRhtZzYGkAynm86mSGsId5xiay7E
         +NdiTcnh57kWQMLHJ5xXQSqbK8xa6w4vZBuCS67D3i1FwutstmDrUm+DXXcyWuyo7Ad7
         urjMnfsBlP1PIoo6xWaHK0BpL2sNtycIHd7GdQMwW6MkFa553tnw+UOfR8Qb13mQMZGQ
         5Teg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795617540; x=1796222340;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=2vBPf9O5A2N6vPyFBaBk1N1z9BatJmAjUAi4ZLhtVRI=;
        b=WhlsRKCxHN6lvGEoogmp0RquyPc6x6GrATYESwubgAcHuWwCecBJy/L/HHe/C6ZuGD
         qSapwzCHTVPS7GbPYz5iWec4Iqau/f+iFtabw0DsTJ1KIcqgVeHngDbuJZinpAKSpzZr
         AYl7ZnimS5vQksCWtJpkXO2f3J3ogDPKJRozHXqh2N323d9f5wVkD/DJMSrcGKP4TnoX
         nmaE6rW6MbQGS1zHLvpOLrsCiaoPCo+T+V36NxJmaajlyOKUbygzq73PhxwXw3pMZwpK
         kQtz09iM+3Dz39FkZP9X5bm1S45Xx1K+zMGDr3MSgSxdri8AChcIypQLi1s7BaJwqDOl
         2PKA==
X-Forwarded-Encrypted: i=1; AL+hErEUN7c57wKXIK0XAFo3FRXZsZ3yPGi/ZU7T9rhRZqGZVwCbO+ML9mOn1dWjELbejpkUmCDcsfO1tDo=@vger.kernel.org
X-Gm-Message-State: APuU4Z98SBRIDQghN3YMMwjKiyds7r0NQJ5ld/4HJH5XXV90XTlpPuCt
	eMSaBS7gIjtUCl0E2uORJDXKnvAHtloppUuLY7TZMD9pd4eaaCINS28OmMShED//bykGdAsskta
	giqkO7q2FmV5X06SNmbAViJeHU4UmX4A=
X-Gm-Gg: AZFdTZdUQN56nhjRaBggbb0ou/PnI6g5MMcCXHi6dlEFbO3gz2+K8cqt3U2sAXtfWHE
	L+q9STfHIaddAj9oDz49KXKlCxRiSN1aSoX8wok5VgZyTmB7sG/51dc30CASAdgUnQtZo2X1KPC
	4iIjXtp496Nn0aujwDmTX7v457cvz9yOgLVu6dM+XEt+q5v4md74y/oAdtbJDvirTqxiXBMU2rw
	MqM8svHzzK919POV48J3KNvWtajxrNe9QIy0TqNA/xWkaHjHqyyGcAN9UZnOc+l7DoWO89GR5j3
	DWfYWNuBUoj0k74WPgijVaXTQWsUmNrHnSPBGVqX/ilOX67Z+sS2UmlIB1Y4yF+0jxFebZlIEPG
	MERtP3+D/YU8ZHejTjiYVRJOLOIr1jRVKr+yo
X-Received: by 2002:a05:690e:a45:b0:67c:2755:712c with SMTP id
 956f58d0204a3-67df44146e1mr7854025d50.49.1795617540224; Wed, 25 Nov 2026
 06:39:00 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <CANkg2rNRVyYLYLaVnCz75nYvC0DAKrphNazX1Asacf8MuBnxAg@mail.gmail.com>
 <525d6d4a-f015-415a-a4b9-9ffdbb8966be@app.fastmail.com> <CANkg2rM7XsiVriVzDr52WcxD-xFb4qu3qxiPJNyJUYYOTLUmNg@mail.gmail.com>
 <8999aef5-c521-4a78-9137-fd82ef2dab6d@app.fastmail.com>
In-Reply-To: <8999aef5-c521-4a78-9137-fd82ef2dab6d@app.fastmail.com>
From: Rida Shamasneh <ridahani@gmail.com>
Date: Wed, 25 Nov 2026 16:38:45 +0200
X-Gm-Features: Aa3M54q8YDkT5ZTwgjV7Yi9BVbJohuUFGivkaRqzlSxk-322cFwtxjsD0zFjQa8
Message-ID: <CANkg2rNYSxGcWLhP-B3T+TUsvCNh2J4m7UUzTrWFyJrW2rpXxQ@mail.gmail.com>
Subject: Re: RFC: RPC-over-RDMA client transport for pynfs (testserver.py --rdma)
To: Chuck Lever <cel@kernel.org>
Cc: Calum Mackay <calum.mackay@cdmnet.org>, Jeff Layton <jlayton@kernel.org>, 
	linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Ok, thanks for the clarification.

On Wed, Nov 25, 2026 at 3:54=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
>
>
> On Tue, Nov 24, 2026, at 4:44 PM, Rida Shamasneh wrote:
> > I sent the patch via email "[PATCH] rpc: do not format a whole reply
> > for the debug log";
> > Do I need to open a PR as well?
>
> CONTRIBUTING explains pynfs is a project that takes patches only by
> email. No PR is needed.
>
>
> --
> Chuck Lever



--=20
--=20
Thanks,
Rida Shamasneh
