Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.50
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795109669;
	b=Vu5YpmJaQ4CM1y7QUJQpoULmUp/IRmrR2GjH7k+0jxy0hdatvbUOyMJBAuERnVuhsZ8b
	 R651bE6iHKlp6O0vb2tDKovMEgYmfRAsk5JCaWaFoxY3oOY0VPbQo1tZ9HtxI1UCVjhVc
	 pQWxWFuR5NEEZHSmIaGBAbItTyk44A5o2QCD8oUtvvXzxCCn7Y5ukbNyYYaJOg5KyyEhD
	 1fD29ODBO9xURjrIlnI4nXK/y3TSwyUUi7JB55vn2w1+qRpsorsHBhTARron+vG3fSmZ3
	 3OuOLMGtdy7Hrhd6T/Kv9ALgsom8JED5v9JtpdBLAvlUVL6954w87TGkKbixhxh6M0w==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795109669;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=m1EYDKjHcJ1IGh49gGW/JeuREp9e8GQDYfzpAeI0szc=;
	b=g6F6m5QGaLXWWIeU2IbGWTQ3Uj7DKkx7wFL1cikGqYqVB5/ac8ckBDeL8iFsOAOVTzHO
	 uwPewn643jV/G7y1EMiOcP3Kqr2pl3Tm1YeABE7stdBa0x7fP9AJsRVo3XAdX//MXAW0Z
	 tlfgM3IPvR6D8pv8DHRZ9B+km8JHziMJqs4D3TuJ8lQdKgOaWVAnyNoGvKLE917yNsXvT
	 fAO7ZkomDMn4OirmJfHMsxYEeXqWYPPy5SoR4bxAe2+AYuFDbjQzr7iHkYyy6hQwvrBKb
	 rucxBw5tY9DBV53RVpa/o2EWUQ+rWmxJ4RU502+52IHOLUnWg3PjqrCgwLopwmHTVsw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=nGC6aRIF;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.50
Received: from mail-ed1-f50.google.com (mail-ed1-f50.google.com [209.85.208.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA153606A332
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 17:34:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AA153606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=nGC6aRIF
Received: by mail-ed1-f50.google.com with SMTP id 4fb4d7f45d1cf-6b8815693e2so1783a12.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 09:34:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795109667; cv=none;
        d=google.com; s=arc-20260327;
        b=V6a3K+Hi61lN3j2gdlrtg2Z9b3cJxfmHzYoitp9nABa1DQXCt1shcOYQf+TTCh7FdH
         nsDi1v4gAudABNzasHNMRNmkfQ37Pqi1VX99efLMfC1QbXpDA3kTzgJiDKReUDwK+LsL
         rcvx0icEMuEmp8PKZD/3GQ+UZB6GfiGZKptlDMFmvECtcH2gPYDH8nUvovT+PEE4fW8k
         gC772T3o0pFjNxrCQKjv4z/BIE51RQnXKek0r10imskFe/BI/CN+J3mfCLqyP3khRhv8
         OHsosFQ9C85yJzOYim36sMHgGY97KlDP4nzpsd2SWSfPySlHeWCRucQYRh9Ga5H3iS/q
         yoEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=m1EYDKjHcJ1IGh49gGW/JeuREp9e8GQDYfzpAeI0szc=;
        fh=Kw83pBmglSrrI6Ad4XgkmOI78mHvnr6PP4bKQzIc9IQ=;
        b=FIE44vYtT2glLSMOUihD8iCkJS7FhyT2QZUikFTFwUK0E9l6UhSIHFo0duiRzkX738
         COUcyaA8gzBJ25vMjcNf7vWnUZyOq/cg45CbEEAiiQu+ZdnWw7Vwidf+OCBmdOU9qLyj
         b9hvWYtMTKhEPeyIxwH3qNmwvUtJNqBjdrBX+Ov6AJRYeePjH3AigT8qDT4Z+KQeQJD6
         F5aLushJbzslUILooQzxR56RndMrnq5C2FpfOlnUEeI1q6vGZuej3jbTF7be4XWUSEpl
         J85bGg1Joa/W/mIElz+oqLYfzA9/efXnOh+Qqhxn7sAFQdUQ3Wg+MxyP/LAWGW0h7Z35
         RUpA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795109667; x=1795714467; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=m1EYDKjHcJ1IGh49gGW/JeuREp9e8GQDYfzpAeI0szc=;
        b=nGC6aRIFchP5t8lwJ/zVTOI/bLa8AV4FvgJg6w8MF9wmm1yRU1tUTokZFa/paaDJ8e
         5PUOtHahetL7iiRPD9uRZGlho38PnlwqF01pD+GRX36RYtqopRY+6tUdIUx/3qzL/D90
         5amQJu0ziL+hdep3ub8xpqOFUa0Nq+K1582CqDJ7KCIXsfa6geIe36gqovNyjbgAUMjf
         2HpGIgyOw12DPpv97GDYb45yfSyQVjodaas6oDy6hcvHkFleTSnYO0ogudCUxCFaFMOW
         LleZntAPokivShBafvD/8UUAi5Gk0sYRA3rFd7SRoFsU1qI4IwU8icU0s6XL5OAjoNTc
         ilJQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795109667; x=1795714467;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=m1EYDKjHcJ1IGh49gGW/JeuREp9e8GQDYfzpAeI0szc=;
        b=A20bI7SzMKm9elba493i0mJssCGXWkCfbeRefxAMdOrR+ja/MGcK56DaIF1/vjmvdB
         sCm8MCZc9fF6WtcXlXMYzirbliYPxAZroTYpLDUNZMxd/b7FyTOE8EXLtLAXnjj52PIV
         +/o7Y1ruPFfucldYDd3az6BUm82v/Ickfoj7Q9BV6bHciUw3Wjlxzxqx/QsiwyChIiLc
         akF2hdLktYdE7prnM3w0tTdExpXuzeug86L7W8nWwu1nmMFsElNGRMwr1lunhssewVf2
         SGajtUdSPx1fioGxvxOrRpYH+hbIWKGsnqkU5QUwzDp9FCEFeN2DmSuQYZhJPsxVN15Z
         echw==
X-Forwarded-Encrypted: i=1; AL+hErERspqgJlU9cMhEd+pkptAh7NXmCORVmoesvS5n9FjDDEOBGcT7epEldEk5cOBYE2II/vUnyiqF5PI=@vger.kernel.org
X-Gm-Message-State: APuU4Z9139Q8S7vP+lk0YeCaS1nT/at5YYmaP3RrtywnyudnsZjpG/DM
	+UNmWcs4nZNfT/aKLeAFpuSkX53sq2Sry6JJpGUC4RG2Io7MNav7SlpOs8HCMrzcOPxnYGKQbpw
	rDqyqY50ILIrndtmoLf2l4LNggUNxeHI=
X-Gm-Gg: AYBFou1SOZhLOIwu87DGdTR66cCtp3tPN/h5v32TyQEs148iMxKTZ8AHbnUENTaoFDj
	1DdnLQeD6mYldS9lFENQ0kEU3c2jjq5oRp4AzDIxdm58D8gWAD6nypIQ5vet3p0aNJ03RPI5+y6
	lW06MXdObJynBYJ+EiQIYCiGeRSvLKFsD/3lez/Y0tIptkPsE7lEM8+5Ub/un929aXjXeWAnZPD
	Stt9TiHOIA198XjsPgw+0gUktafWz7LFZiYxXNsTcaw1/tM+VNsgUWBihagYrrunQxjSqv8Jj7A
	plqE9cT/UGW/M654tkiIGhq+6fIGV4AITJ+T6VFFGPsewqV/Gr/fsRCn+pNV6teGuzw/zeampSf
	URewxBrnkglPqS+I1AvMUWp8B9tlbqskqVHJZGLPEphITN7/Hc2gBQBSU2GjXUXL+hsWTpQ==
X-Received: by 2002:a05:6402:70c:b0:6b8:7d98:4826 with SMTP id
 4fb4d7f45d1cf-6ba37d5bf0amr50117a12.11.1795109666761; Thu, 19 Nov 2026
 09:34:26 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261115180343.576773-1-koray.fra@gmail.com> <20261115180343.576773-10-koray.fra@gmail.com>
In-Reply-To: <20261115180343.576773-10-koray.fra@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Thu, 19 Nov 2026 18:34:14 +0100
X-Gm-Features: Aa3M54rix9St5Car4447U2IPLFR0HdY95bNJiBlGTi0-FAZstJdvxSGCP5IQDxw
Message-ID: <CAOQ4uxhjxp5sxYphWoB=8sgX3XHOv9zLVYf+8ZjYbS_gQDxO3w@mail.gmail.com>
Subject: Re: [RFC PATCH v4 09/10] ksmbd: add provenance time (ptime) and map
 it to CreationTime
To: koraynilay <koray.fra@gmail.com>
Cc: David Sterba <dsterba@suse.com>, Namjae Jeon <linkinjeon@kernel.org>, 
	Sungjong Seo <sj1557.seo@samsung.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Konstantin Komarov <almaz.alexandrovich@paragon-software.com>, 
	Paulo Alcantara <pc@manguebit.org>, Chris Mason <mason@kernel.org>, Yuezhang Mo <yuezhang.mo@sony.com>, 
	Jan Kara <jack@suse.cz>, NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Ronnie Sahlberg <ronniesahlberg@gmail.com>, Shyam Prasad N <sprasad@microsoft.com>, 
	Bharath SM <bharathsm@microsoft.com>, Sergey Senozhatsky <senozhatsky@chromium.org>, 
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>, "Darrick J . Wong" <djwong@kernel.org>, 
	Sean Smith <defendthedisabled@gmail.com>, Andrey Albershteyn <aalbersh@kernel.org>, 
	Pedro Falcato <pfalcato@suse.de>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, exfat@lists.linux.dev, ntfs3@lists.linux.dev, 
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Nov 15, 2026 at 7:04=E2=80=AFPM koraynilay <koray.fra@gmail.com> wr=
ote:
>
> Implement provenance time (ptime) in ksmbd, as introduced in a
> previous commit ("vfs: add provenance time (ptime)").
>
> Map it to SMB's CreationTime, making it settable by SMB clients. When
> reporting CreationTime to clients, prioritize ptime over da.create_time
> memorized in the user.DOSATTRIB xattr.

That doesn't sound like the right thing to do.

If the server stored a CreationTime that client had set, you cannot
override this.

When the client sets CreationTime, the server can decide if it can and want=
s
(may be a policy decision) to store CreationTime in PTIME and not store
it in user.DOSATTRIB.

Fun fact: the user.DOSATTRIB format also has a mask so storing the
creation time inside it is also optional.

Thanks,
Amir.
