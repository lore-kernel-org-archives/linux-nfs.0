Received: from mta-101a.earthlink-vadesecure.net (mta-101b.earthlink-vadesecure.net [51.81.61.61])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 43CB93C198A
	for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2026 18:01:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=51.81.61.61
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790359314; cv=none; b=m6ouqSDGA82mI19aLAQIzFFMIBXAViJCAwqwt19UwMdc1ScXR9xPON/frXFFefc/ZfghWHd0R9hLIV/5EjZaUk+h6z8jbxgy5g7RBcW/h71aWs8eAPbxHHQdxmhTFCTfBLvidHuzzYt8gyOpwfkB9XU5esFXE101H6avmvpPNhk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790359314; c=relaxed/simple;
	bh=7vvvHuQHEg2DlxS2fPh1H2c+AAuIpmseTD+GNOB9vFc=;
	h=From:To:Cc:References:In-Reply-To:Subject:Date:Message-ID:
	 MIME-Version:Content-Type; b=fiMIlu1UPsT8MjNL0UXHa4M6789RFo4XyWSX8/pgZW10RQlQ0j5cixpuZAdTgUnOfWnCy674ubYdHYi74B2yxGZPXcGPY5IqTlNN3+5ndGtHRrgzR9R072oQBYaHVtwS0GzOhp44XvolqaYzZS27Krhh0zAwl3HVS0WubZlCRXw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=mindspring.com; spf=pass smtp.mailfrom=mindspring.com; dkim=pass (2048-bit key) header.d=earthlink.net header.i=@earthlink.net header.b=axWKJa5M; arc=none smtp.client-ip=51.81.61.61
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=mindspring.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mindspring.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=earthlink.net header.i=@earthlink.net header.b="axWKJa5M"
DKIM-Signature: v=1; a=rsa-sha256; bh=7vvvHuQHEg2DlxS2fPh1H2c+AAuIpmseTD+GNO
 B9vFc=; c=relaxed/relaxed; d=earthlink.net; h=from:reply-to:subject:
 date:to:cc:resent-date:resent-from:resent-to:resent-cc:in-reply-to:
 references:list-id:list-help:list-unsubscribe:list-unsubscribe-post:
 list-subscribe:list-post:list-owner:list-archive; q=dns/txt;
 s=dk12062016; t=1790359311; x=1790964111; b=axWKJa5M3Chn1AMieAYg+BlmXv4
 JJ1fiUMy3SIP4ZybnUzUl83xIWIoKZKZvAVaDhrGak8880aGUYPHnh/+RG7cZOsh4qheBtU
 Y+dZXUn8KXKXcxcpawAyt6O6ZozkCodndeR+M92rmGCJ0kn8Ubvhds5VwZMfdNzAOAryCmL
 CmL9mZk8uasJ7h4o51pH8+o5GlYte/49wCTFWUpRm3t+BxGjj2Bg7KC0jt9kN3XP7CEadCv
 hGGJqrAChLAiuozQCG22Z4RItxHtoeB4xeHCoWYqElpSKq2jfk4ryRfO5T/uyZfSL5g87Ff
 2fw6oJj/1SyE947Y9pSpZvHbcVSM2cw==
Received: from FranksP16 ([24.21.95.216])
 by vsel1nmtao01p.internal.vadesecure.com with ngmta
 id b5cd0838-18d8a24db2788d9f; Fri, 25 Sep 2026 18:01:50 +0000
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Jeff Layton'" <jlayton@kernel.org>,
	"'Roberto Bergantinos Corpas'" <rbergant@redhat.com>,
	<trondmy@kernel.org>,
	<anna@kernel.org>
Cc: <neil@brown.name>,
	<prabhakar.pujeri@dell.com>,
	<linux-nfs@vger.kernel.org>
References: <20260917104905.669983-1-rbergant@redhat.com> <fdb976f6e9b78e2618de70bcf6595e9f484fc30f.camel@kernel.org>
In-Reply-To: <fdb976f6e9b78e2618de70bcf6595e9f484fc30f.camel@kernel.org>
Subject: RE: [PATCH v2] NFS: return DENIED in decode_lock_denied if we cannot decode owner
Date: Fri, 25 Sep 2026 11:01:45 -0700
Message-ID: <015401dd4d17$f0df5e60$d29e1b20$@mindspring.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-Mailer: Microsoft Outlook 15.0
Thread-Index: AQHB9Y/jnHQz6XYWEYK7WYAvKYx+5AK/P54XtwBJDcA=
Content-Language: en-us

The thing is, it may not be a server bug. The protocol specifies a limit =
of 1024 bytes for the owner opaque. The owner may come from something =
other than another Linux client.

In fact, as has been pointed out by someone else, Ganesha returns a 21 =
byte "ganesha_unknown_owner" when the lock owner is not another NFS =
owner. Obviously we could (and probably will) shorten this, but the =
owner could just as well come from another client, or be some =
representation of a local owner. Nothing in the protocol even gives a =
hint that the owner should be limited to something as small as 20 bytes.

Personally I have wondered of the conflicting lock owner is really =
useful to anyone anyway. Obviously the Linux client does nothing with it =
(which really is reasonable since the POSIX fcntl call only allows for =
returning a pid). I guess there might be some use in a tcpdump trace =
(but even there, one might argue it would be nice to see the IP address =
of the client holding the conflicting lock along with its [probably 20 =
byte] lock owner).

Frank

-----Original Message-----
From: Jeff Layton [mailto:jlayton@kernel.org]=20
Sent: Thursday, September 17, 2026 5:24 AM
To: Roberto Bergantinos Corpas <rbergant@redhat.com>; =
trondmy@kernel.org; anna@kernel.org
Cc: neil@brown.name; prabhakar.pujeri@dell.com; =
linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFS: return DENIED in decode_lock_denied if we =
cannot decode owner

... =20

Typically, we don't work around server bugs in the client (and vice =
versa), but I think this is a reasonable thing to do in this case since =
we don't use remote lockowner information anywhere in the kernel.

Reviewed-by: Jeff Layton <jlayton@kernel.org>

