Received: from mail-qt1-f170.google.com (mail-qt1-f170.google.com [209.85.160.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0221E3019CB
	for <linux-nfs@vger.kernel.org>; Mon,  9 Feb 2026 12:27:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.160.170
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770640028; cv=pass; b=N18uSd0r3CQYIC1EW4AMYN1F2h7FmOwyItzdxNsUI0PUmZUBVUVDl/SnhuSTP0ivz6oXgezcfq+OPE9qvNduFBZ+442tnCmaJIB3n6SIdflNyndCNBiMctgn6Ub/1r7FDEY/nbKLHPr7MXYV6AwirkBIc4gJ20PrliFyZqsHLkg=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770640028; c=relaxed/simple;
	bh=jmJSIAHjW/ZE3aK860YMveWUZJCZq7MQeEOdmveoq18=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=osLa+gC1b6FjqMQ5fR0eW5xjfIsACo2Bc3E2k4v22bfpsrowQ20d58pEsg9tzvW1joCMihTBKtLGr2J4KKpqHT1XW5c/zO6j00/+ZtnM7kmzaVOsat+zrFS143hwNDUgH0zghdQQXaNIl8vHQEB3AlpVrSK91hQpc6VmJj/pX7k=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu; spf=pass smtp.mailfrom=szeredi.hu; dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b=ASg7GNXk; arc=pass smtp.client-ip=209.85.160.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="ASg7GNXk"
Received: by mail-qt1-f170.google.com with SMTP id d75a77b69052e-5032e951106so38223531cf.0
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2026 04:27:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1770640027; cv=none;
        d=google.com; s=arc-20240605;
        b=FwtHn/ET+I+INeSJBYS+bjPSlH8sOYUiXXAQEC9zwSsNemCDo++hIa55kbaMn5m+84
         ieXLSy2ScpAMnUIYcXbOH/KWji4pTJ/a8zq6K8CryXq97O4qaysRaGY8xB51TtRggASY
         d75fM2+kFpwn5dWkH9cy8wyylHqPiTUT2uwZFRQ9DtvvR0K2NhvESQaHyDFXIuZWwO3E
         ENzvWKYV+l8M3rFnb7Yr3QCofeSzZ/q6IdvxO+9J5Q+dfsemD4IMG+XaYujRG5vQ4ewV
         J0IbjG7supUuil6+I4BkFero69dNs8l4z+Od+E26dx4AepoMHDiLTLWHbInyWWujPNfG
         Uzww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0jDR9Z9XZFkuvZsBRmesOdlnfns+s15FYa5ik6TAHNs=;
        fh=Ae0Xeu2s8Koxny2/ypZ5ITGZff6fOLNPAzGt40ToKas=;
        b=OF/Yf71IZOwEQLHS4NX+F49t1J8zgyidvT0vnPvnzZ5OwseJY8EHEFAOuuuRqJYCX5
         CJvcZQijbJkCkK39tlRhlvan93Tx2dSERIw9B1NFG9REqpFXYC0QsKyyF7C/3tJH0e/c
         0lJZeqX5dJRe79QHKMBfDy8K0lPsFZXX5fwjfZNad7FtFWUcdTfyb1xqT83V8DH1ibVD
         NLvkPfFzh7GdTx4AFm4vfcvUwo1I4T6Gzsv0wcYpofxh3q13hzMJdxj/gWLDN6QHkuR5
         PWZjIEDFWSvr9XBbLK893ggQqzFA9u577pRlvbzrrtQxq7gZHD0JF7GoJmg0x5f2i7l0
         GU1A==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google; t=1770640027; x=1771244827; darn=vger.kernel.org;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=0jDR9Z9XZFkuvZsBRmesOdlnfns+s15FYa5ik6TAHNs=;
        b=ASg7GNXk/9yTmliatiEHtrXq+ggMYlMjdqyR5lWqNPXKJd5+mW44ERvhP0cjBQvXq8
         vrkt31wabjOgjPqNEk3+ipXeHMnPu+vd7rb4C5xHBKP9tHR4MKMQdcv4xqhXUsZnCfLx
         QI+FWEur+t0blWzmyUcNIci3laYk+tnHqfNHk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1770640027; x=1771244827;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=0jDR9Z9XZFkuvZsBRmesOdlnfns+s15FYa5ik6TAHNs=;
        b=eC2KHyWwQyn/m7RhUiN/UdNqDbNljcwVRDoeMWvPbNX+FYYtVDzeGvBRXLCt7zJ7wy
         GTJNQgFo9F8502lx9+Qjs/OFA8RJGz9FnFH7lOKMxfoldKWUwLBXEO+/Id4Gmy+V2unc
         2f4FduMjrXpncVUzyE9r4YZMEX1/qPPdYc81Ytp5JuUEjrschn2jbxSMp1VIUnpBvxpf
         XEspbcjhLLA+4hNlmTIMqpOE0h0smENFUQh01HrrsxM1a0/y+JDvIWLHX74DMg+ACIge
         C/WBdNswRuKwRM+Ib6ovRo6+BKx0c9hLl8nF9AGhv/nezIe6vC0ixAeaf8gOjG+NOiv2
         2lWg==
X-Forwarded-Encrypted: i=1; AJvYcCXL3dV0KX/TW2xG/7gi78d/wlNbByckOEU+OcYfPd6Us+Jflqkhsk4W+9aqb+sO5gKbNhRZ8092dPE=@vger.kernel.org
X-Gm-Message-State: AOJu0Yx/mzzuC0aB7QrVG2ZpmkXzskQgloxyzv0VqZdH3CFFf/U616Fs
	MWPSfwZrE5KNzhgn3FMbmYJ1wsvxryxmin+0RFIdRoFTEPBWYJqAseVgxfLV3IVhlEjHyAtFG9y
	hsfLv9K46p6aJc7MBnRVg0qRSntSMS1VBWRZDB6pVV7hrN7MD8N/748Y=
X-Gm-Gg: AZuq6aIH8rfhRtz6X6Ngs8nzbASWJfjnSb4vFlm1Hc8wasfeBPBdozCTJB/S1j6cN3q
	C0MGquZ7qiTtrm6Sh4iVLpRHdTDR7f+DUfl268/atzzQTYpK9lbQO3Va1X+NWcpAnT5N7thHLQN
	3Dt1G88KDvYymOTpwlUj71enMugtDzMDeRvuMF13hnq9Vvts0h8idMsb+SdJS4irDfOGC8Mywkl
	BdBoMShb1Fb8Pr93wVUeo6Da3EzYUZYksYiXncBM9tA2uUp5KIkdba1p45zgV9+99C3rg==
X-Received: by 2002:a05:622a:13ca:b0:501:147a:a215 with SMTP id
 d75a77b69052e-506399af94emr141986801cf.73.1770640026918; Mon, 09 Feb 2026
 04:27:06 -0800 (PST)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CAJfpegu0PrfCemFdimcvDfw6BZ2R5=kaZ=Zrt6U5T37W=mfEAw@mail.gmail.com>
 <z24xrtha2ha4ppxomzcqzdkevgtpoiazwb2aehfocyfqwnhkoe@clrijunqda67>
In-Reply-To: <z24xrtha2ha4ppxomzcqzdkevgtpoiazwb2aehfocyfqwnhkoe@clrijunqda67>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 9 Feb 2026 13:26:54 +0100
X-Gm-Features: AZwV_QjlWYoFVM5VksJebwYdDgN2oeT-5JhqsKgKntThwhk0fQay5xVYrVKDbIE
Message-ID: <CAJfpegvjEzu_mgDaKgNQcnpES8vNu0d+UniS65UFQMsKcaH55w@mail.gmail.com>
Subject: Re: [LSF/MM/BPF TOPIC] xattr caching
To: Jan Kara <jack@suse.cz>
Cc: lsf-pc <lsf-pc@lists.linux-foundation.org>, linux-fsdevel@vger.kernel.org, 
	Linux NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

On Mon, 9 Feb 2026 at 12:28, Jan Kara <jack@suse.cz> wrote:

> As you write below, accessing xattrs is relatively rare.

I was referring to large xattrs.   Small (<1k) sized xattrs are quite
common I think.

> Also frequently
> accessed information stored in xattrs (such as ACLs) are generally cached
> in the layer handling them.

Yes, that's true of most system.* xattrs.  But user (and trusted)
xattrs are generally not cached.

> Finally, e.g. ext4 ends up caching xattrs in
> the buffer cache / page cache as any other metadata. So I guess the
> practical gains from such layer won't be generally big?

For network fs and userspace fs caching would be a clear win.,

For local fs I guess it depends on a number of factors.  I'll do an
xattr benchmark.

> As I wrote above, I'm just not sure about the load that would measurably
> benefit from this. Otherwise it sounds as a fine idea.

I'm not saying all fs should be converted.  But NFS already has an
xattr cache, and fuse definitely would benefit from one, while tmpfs
"lives in the cache".  So there'd be at least three users and possibly
more.

Thanks,
Miklos
