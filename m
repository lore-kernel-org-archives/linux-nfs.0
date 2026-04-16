Received: from ewsoutbound.kpnmail.nl (ewsoutbound.kpnmail.nl [195.121.94.185])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7166370D62
	for <linux-nfs@vger.kernel.org>; Thu, 16 Apr 2026 21:42:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.121.94.185
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776375766; cv=none; b=SIwRewFjYGoz8P+1LkSKmlZj/o+7IXP04KVLfw5I0HvtAg24sSu/CkaZpOJ/JVHLYy83ii/KwObzJCOgs7z4+CEKk5RZ3beFPv7A8US0p4rn1vG2UV8yliaOWzTvfjK/PGZBcXi0FAiViXvUoyIFhCVkfD3sX87RPlclk5kq9zk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776375766; c=relaxed/simple;
	bh=IwAI1eaHkbzl2q25/fu93jl9Wz9VGjZ9ldalur0MsOw=;
	h=Date:From:To:Cc:Message-ID:In-Reply-To:References:Subject:
	 MIME-Version:Content-Type; b=LaFsVhyyKUxCX01xb0UIprpvHjEodOcZzav47zZxdO/4YGWCWoD78jy5XAJ058OVRZt7jRZ4IarWdUwxx5TVZ92CUr3VakCagx+cl0Y8OWjVStjkDYF7liYMA9C8pKuH5cCCzl8A5F6GWWz1dDQWf3QJNrO+03sfX/SOKoWiBng=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl; spf=pass smtp.mailfrom=xs4all.nl; dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b=MUYIXaJy; arc=none smtp.client-ip=195.121.94.185
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b="MUYIXaJy"
X-KPN-MessageId: 32e0422c-39dd-11f1-8ff3-005056999439
Received: from mta.kpnmail.nl (unknown [10.31.161.188])
	by ewsoutbound.so.kpn.org (Halon) with ESMTPS
	id 32e0422c-39dd-11f1-8ff3-005056999439;
	Thu, 16 Apr 2026 23:42:42 +0200 (CEST)
Received: from mtaoutbound.kpnmail.nl (unknown [10.128.135.189])
	by mta.kpnmail.nl (Halon) with ESMTP
	id 32e07e84-39dd-11f1-80f0-00505699693e;
	Thu, 16 Apr 2026 23:42:42 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=xs4all.nl; s=xs4all01;
	h=content-type:mime-version:subject:message-id:to:from:date;
	bh=FAFUNkukKmRTaQDP/ma8ntJhtsdj1vX5Rro9/2jNENo=;
	b=MUYIXaJyQI/z3eS8we80k6cReqZOrGcNyJH+eOsM0PptZLrLaRasoV7obwF6je4Oo1F2Q53g1dTaC
	 IqUymC6DxzUPabRDzcTQxVCljJljWBkrMoSqBMJL+mujYUqHhSNcOaF+OlB+O2yQFWLbNkbwkM62Zj
	 QTFjvEiZvQSp9l9vCH5z1nOjxZEzUkv8SgpuJrFLYZVB8+8Amvb8f8a7CHidJFr9KB/0c/jl2Ro+YJ
	 3EAFYuqHM0s2N/vB0gIaxS+hlOwiX48TqlzjMMe7LhmYtAcQfa4fDPkuGVhYzQgAYbekHDwRYfhrmB
	 F5Mm/8EXhFl5j2TfObuqEdb6zzgWXLg==
X-KPN-MID: 33|cxvwz6XIh+mQ5m5d80I6DfGs94zM1K2dlrRj5bchq6IoGGsUJF3RLVRm5g9uaXO
 0Y2LlUpPPKVH+u9Ml0x0eZDNcQV0BtHa3qhSktN2o5wg=
X-CMASSUN: 33|g5BgIBUMSqbIpNgwKf2oxyuAmj7HBGNP8+CYku9NjRFoxoUsKfnp9wSbpLST/jO
 DqmCC/FRLwMqigt+cG6u52A==
X-KPN-VerifiedSender: Yes
Received: from cpxoxapps-mh02 (cpxoxapps-mh02.personalcloud.so.kpn.org [10.128.135.208])
	by mtaoutbound.kpnmail.nl (Halon) with ESMTPSA
	id 32d2c916-39dd-11f1-94b1-00505699eff2;
	Thu, 16 Apr 2026 23:42:42 +0200 (CEST)
Date: Thu, 16 Apr 2026 23:42:42 +0200 (CEST)
From: Jori Koolstra <jkoolstra@xs4all.nl>
To: Aleksa Sarai <cyphar@cyphar.com>,
	Dorjoy Chowdhury <dorjoychy111@gmail.com>, brauner@kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org, ceph-devel@vger.kernel.org,
	gfs2@lists.linux.dev, linux-nfs@vger.kernel.org,
	linux-cifs@vger.kernel.org, v9fs@lists.linux.dev,
	linux-kselftest@vger.kernel.org, viro@zeniv.linux.org.uk,
	jack@suse.cz, jlayton@kernel.org, chuck.lever@oracle.com,
	alex.aring@gmail.com, arnd@arndb.de, adilger@dilger.ca,
	mjguzik@gmail.com, smfrench@gmail.com, richard.henderson@linaro.org,
	mattst88@gmail.com, linmag7@gmail.com, tsbogend@alpha.franken.de,
	James.Bottomley@hansenpartnership.com, deller@gmx.de,
	davem@davemloft.net, andreas@gaisler.com, idryomov@gmail.com,
	amarkuze@redhat.com, slava@dubeyko.com, agruenba@redhat.com,
	trondmy@kernel.org, anna@kernel.org, sfrench@samba.org,
	pc@manguebit.org, ronniesahlberg@gmail.com, sprasad@microsoft.com,
	tom@talpey.com, bharathsm@microsoft.com, shuah@kernel.org,
	miklos@szeredi.hu, hansg@kernel.org
Message-ID: <2059025134.378522.1776375762839@kpc.webmail.kpnmail.nl>
In-Reply-To: <2026-04-16-upstate-capable-deacon-petals-0l25lH@cyphar.com>
References: <20260328172314.45807-1-dorjoychy111@gmail.com>
 <20260328172314.45807-2-dorjoychy111@gmail.com>
 <aeDpIgfDaIKEaBcL@lt-jori.localdomain>
 <CAFfO_h6pkyX=uN5uoXda6toTtT6KsahfBNBLom9i21HdZ7JOmQ@mail.gmail.com>
 <2026-04-16-upstate-capable-deacon-petals-0l25lH@cyphar.com>
Subject: Re: [PATCH v6 1/4] openat2: new OPENAT2_REGULAR flag support
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-Priority: 3
Importance: Normal


> Op 16-04-2026 17:15 CEST schreef Aleksa Sarai <cyphar@cyphar.com>:
> 
> 
> Oh, I didn't notice that this wasn't mentioned here, we had a separate
> discussion about it in a thread with Jori and I must've assumed we
> discussed it in both. (My brain is also really not wired up to read
> large octal values easily.)
> 
> While it is hard to add new O_* flags (hence OPENAT2_REGULAR), it's not
> /impossible/ (Jori has a patch for OPENAT2_EMPTY_PATH that is safe to
> add to O_* flags because of some fun historical coincidences).

But it would change userspace, at least in theory, right? If anyone for
some reason decided to set whatever the bit will be for O_EMPTYPATH
in a call to openat(), and pass an empty string, relying on this to fail,
that will no longer be the case. But that is just really silly. Or are you
hinting on something else?

Thanks,
Jori.
