Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.48
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795023477;
	b=pBTM3B1eCUuaiAMlEpx/yYxFeuubugU0brAQv9KdyVzCeka0zPN8ml6tex2F+zQK62H5
	 YcEywcGvNG8de19fJVzYIjQw7DJEIJtu7nCJ7jEuImzE5KQXcPCMggM9eoib/2yHQMRYU
	 HOVt7fNYOpbSC9OE4Bx37PEXgHZm1sT32BnFKZEOf7Xom9wjNmsEL7o0cQgyfVyfsrbsX
	 rVag+Mb/Jw07zlUChGzn34OlI0HrnVfkQ6b1V8jRuFSnyN2N6zM4uerTK20rDLKf/mm44
	 +3P1CPoP3N8vpLqJZ+YgTs0AE50BrjXT9862OJtmqyDvP9NxLwrlFx+utXSC8nQzNxw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795023477;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=R67yuyz8qBaN7OEJjW4cC9fhK33d87+KjfsWBVWkcBA=;
	b=pZZscMENIY8B4cI9++SAftOcj8Ht6JTcNZaWcPK27OXFasrNgMr97T2FAizO981JKffn
	 R1giQr6X6HMyJejU8VRfWxy4exGWgHrix4HOkj7dMvOH+UbFbyCv8JzLth+qub+SuQ27j
	 3alaEuNJyun1258rqK+jYX3dmhBOgZaJoKKL5q+2SEGaLXHviUBmRxQrxjfqCuvXMRiTX
	 e4Mh+lg9B45jA/b42RrWtrx/PsPfhL12d6s/8XSiluT0ZNgZvkjKbIjvxy/qXf4wdUM9m
	 RxUbbauf/7gLq9xbIatazUM/phzkzp9viscauFttMq1M/0v2/OQu2HLn1LEIQJUCKRw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=B4Fx1cvZ;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.48
Received: from mail-ej1-f48.google.com (mail-ej1-f48.google.com [209.85.218.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D2F1C606A32A
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 17:37:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D2F1C606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=B4Fx1cvZ
Received: by mail-ej1-f48.google.com with SMTP id a640c23a62f3a-c50d3ac6b51so8951866b.1
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 09:37:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795023475; cv=none;
        d=google.com; s=arc-20260327;
        b=JHGF0k+qsV4nkzJi8MnziTS70bbsm26wEJgFSMY6CfmtVUJ0Yi+XAnHmLbs9FGKJzp
         LxSjl9pEJKKryxCTRiZ4lIYZJ8w/fHBo4J1v9Kd/2CpabqsMrXq+JDrKjdo2NEpR+632
         Pp33o3qxFelVqxFhATPNw6MkHNJrtm3OoQeKzLHZLwGBGh7wcmtDrNUZH5dB9egEN9Hs
         j0FJah9sDh8IPC098TGEARe5ucehensZJ6vOVBZrglpRkqkUdWbPn+KUEuR3Op0nffY3
         SzrPHAfe6W6CrxOaR+uT3gNML58jQe84itHrCvwf7hwg0r4sDr5jXvfEaFqaFq3VAzgn
         ZLJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=R67yuyz8qBaN7OEJjW4cC9fhK33d87+KjfsWBVWkcBA=;
        fh=sG1phBloBk5B9DxyZ64EjogHq0A/sA2ionNAqso9t4Y=;
        b=QxUQ2egPLBwch9V8DTXfzt6gAMMMIQrOiFbDTMv8uUXPK77WwQxa1ULSlzNYvrTkxq
         QL5nQWsN2H+3EAjWz+KMGBCjnwS4UR7llVdhuf/oyOT9LCutucEsLvGCQUfdFx7MRise
         Gx44fn9kA/3Ff49UivGwDqGmwojWpF1DSfm4VbIF80m/rdaWV/a76P1XgE/Tsc5ElQPs
         yGA5uZu6/nrT0WzQoTcMkyy0KY9e6EkxJH2F39TRF4Lmgk8OTRgr6g8rqCz24B9H/oO9
         HMdeN3eF2VTUc1h9PxbPAGSf+Zc5hy4HSh2o8sMnHuXB++4NO0GoyAzcKVwejYa5jZeN
         wjug==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795023475; x=1795628275; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=R67yuyz8qBaN7OEJjW4cC9fhK33d87+KjfsWBVWkcBA=;
        b=B4Fx1cvZRSB70oxXa7PXzsQOiKHd8kick7ujHIg5sKZfXngwM/J3md0QrwQw4limgc
         gzD04fGPnUdH4vsdPqK10mZdRL8XnpJIKSo8akWEM5mP1fwpa3D6R1ZVi3kB4ftkkRYT
         t3eglWK1B2yIv1p5oKl1PvLjjuez6SSOZkvKdegYNTew2mBmZIppnHMoZW7XAD514J2T
         Wkz+jc4JDJW+IYh3dYSMGjOQlspp4IYbioQrh478oLfKYgEeEOCfp3zOdH8mfHNwLEAs
         a87jaYO1D21yfJt0MK/CqLT0XQY2LPKrrUvneOLh7WazFrteu6Qq14s3DdjdZZ4eW7Xb
         Uy7Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795023475; x=1795628275;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=R67yuyz8qBaN7OEJjW4cC9fhK33d87+KjfsWBVWkcBA=;
        b=1wWz5K0vGUSHO60MKDZGMcipKBlixBLeYKs/vG4C1XrK27EElRtCqSu0T4jpeOsukV
         tFjNh9qkU/FntIyszWTgVuVM4zq0JEkOW2KUUtSe4Y6fXEgd0XPzmG2Tw87/x12LzqeQ
         ke1LFQ84xuxOchKrAsvogaQfRlLaMlxj739ZjItbEd8Od9Q9d9ygeu39HuolJFCYaMBr
         /1oAGcjt4+Du0YUtuZI6irtFJ8SrYJ2p4D+YT8j6wlAwDY+ETUdncSwTT5mGQj5I4sP9
         pcTAJ0H1L+WMQgW/WElReGXd+q8Eb/+6TbU+nTDt93xXjSKRABR6WUgBfv8hBe1QD20F
         gZiA==
X-Forwarded-Encrypted: i=1; AL+hErFa8lVVXQGkwoJUDJ6pK176901EEJNUB0neShypeBW15D2R5SFL9UiaRjd8tRMhStdeQbLKT5ahJ6o=@vger.kernel.org
X-Gm-Message-State: APuU4Z/hFxMl4ZwYArQnV6TruoiHeE64TrWCCsCg+B8/ksWaN3cFbvry
	dLkdzdFDPqMaj7zx1n7J+9JDvuHvNjK8oNzd+ii3BRH/WnOgpWIHG2hxjdQVVbAmsiGzXcpdFX2
	ACPXm7UgsYuyefxi35iP9/JWzOvrJ4zU=
X-Gm-Gg: AYBFou0cQuByn2BCYbs9JjW0z72UBhTsxlZwfAzmCt9OKi+JFjoe3C7TazrzVpsYeDc
	1hHPoB4ZO9N29xmpvSqkV15zxMW76SMtWczhi+/Nb24+px3tkJzxXa3gSR2iV65LrDWk2MHneSN
	75W+Bh8PVCtoB6lTtqA2k8oZcPKhJM5qrVSU22HQTB4kBcFjTCcbZ5RpA8a5AVvRqSYEJYwL6ca
	0wLMC3UqCqjR3cAlYrOV8j78iqJXU5LGmsXfSooLie6bNcZlArYYyd/KxE2Wq44LmGFIzCRo3bA
	LAn11gP6JiRR84Bimghdtp2URSfI9+gdUMU05UhcIrXs21/4C2i63Am1UlwNnDqasmnAeftMk1U
	qHxdZW6G4Mec2CnrzjJq5i66x2/B2JPs4Dm+8zty6weVZVkui6ZCBKpCFsqQ/k43G7s/99g==
X-Received: by 2002:a17:907:da1:b0:c49:b6db:1 with SMTP id a640c23a62f3a-c5126364307mr15604866b.12.1795023474965;
 Wed, 18 Nov 2026 09:37:54 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261115180343.576773-1-koray.fra@gmail.com> <20261115180343.576773-8-koray.fra@gmail.com>
 <f297d9ea-ebd7-47f4-ab7b-de5c45980000@app.fastmail.com> <CAOQ4uxhpMARO_ZMJDeoa044BwufLVnS0o4Fv0abBF=tjaZmtWQ@mail.gmail.com>
 <cd49ce48-58d7-4341-b4fc-34e63daf3c52@app.fastmail.com> <CAOQ4uxjme9sJ5LGNDnP6rEKZLTJzX_ZdcMohgu2iLULK96GPOA@mail.gmail.com>
 <9c4a509c-b6af-4da1-8a64-9d5c26c74bff@app.fastmail.com>
In-Reply-To: <9c4a509c-b6af-4da1-8a64-9d5c26c74bff@app.fastmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 18 Nov 2026 18:37:42 +0100
X-Gm-Features: AclHuK9j8na9qQXXbOgij3n-j2Bo4JySgielhO0fgIJ-weX9anWXgtr5UxF7Q-Y
Message-ID: <CAOQ4uxguPD+PWEUZtAzSdA-15d_C5cn=34ZmCm0v_b0MWK_sfw@mail.gmail.com>
Subject: Re: [RFC PATCH v4 07/10] nfsd: add provenance time (ptime) via FATTR4_TIME_CREATE
To: Chuck Lever <cel@kernel.org>
Cc: koraynilay <koray.fra@gmail.com>, David Sterba <dsterba@suse.com>, 
	Namjae Jeon <linkinjeon@kernel.org>, Sungjong Seo <sj1557.seo@samsung.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Konstantin Komarov <almaz.alexandrovich@paragon-software.com>, 
	Paulo Alcantara <pc@manguebit.org>, Chris Mason <mason@kernel.org>, Yuezhang Mo <yuezhang.mo@sony.com>, 
	Jan Kara <jack@suse.cz>, NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Ronnie Sahlberg <ronniesahlberg@gmail.com>, Shyam Prasad N <sprasad@microsoft.com>, 
	Bharath SM <bharathsm@microsoft.com>, Sergey Senozhatsky <senozhatsky@chromium.org>, 
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>, "Darrick J. Wong" <djwong@kernel.org>, 
	Sean Smith <defendthedisabled@gmail.com>, Andrey Albershteyn <aalbersh@kernel.org>, 
	Pedro Falcato <pfalcato@suse.de>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, exfat@lists.linux.dev, ntfs3@lists.linux.dev, 
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 18, 2026 at 6:14=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
>
>
> On Wed, Nov 18, 2026, at 11:36 AM, Amir Goldstein wrote:
> > Can't an NFS client be connected to another NFS server
> > implementation which does allow this?
> >
> > I can't wrap my head around the problem.
>
> You already named the problem in a previous email: What happens
> when the NFS server's kernel is upgraded from an NFSD that exposes
> only btime to one that picks either ptime or btime?
>
> Clients will see a file's btime before the server restart, and
> afterwards, they will see a changed TIME_CREATE but the file's
> NFSv4 change attribute will be unchanged.
>
>

Indeed I have.

My newish proposal (on cover letter thread) is that we
abolish the ptime/btime duality and make mutability of btime
a pre-fs decision which is advertised via the get_fileattr() API.
So from the user POV or nfsd POV the values will never diverge.

Thanks,
Amir.
