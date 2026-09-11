Received: from mx1.manguebit.org (mx1.manguebit.org [143.255.12.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20041387345;
	Fri, 11 Sep 2026 20:19:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=143.255.12.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789157963; cv=none; b=HPkvpE00G4NuVk9aNmg6f3g040ImlJCgAJMwgqMDU6YYDo1gym+/LJQhsablAlFgYQ16nKp/Jvar9wnt0SA7RSWCGhDLKXbIVO8uV6efMWGdSJM4zRwaBlIW8KrCEPPFJJnG3Z+R+i9rpHZHhlJNy0uzODMKRCbVyUfCbkdDzRc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789157963; c=relaxed/simple;
	bh=2OyA4o0jAjZ8oNAFVmQygbD74kvzMiw03VE9SDZIK6Q=;
	h=Message-ID:From:To:Cc:Subject:In-Reply-To:References:Date:
	 MIME-Version:Content-Type; b=SOJuLr2ceiXUwA7eTlpos9eKaQYpb9y2XiGnmYpoIMegw0P7CoDDzTQT7LhVa1QrTKqOWtsZFXqVEkLiYUdEpOw4CYD+x70H43SEfGGwyvx26ZiXNdlCxGifOZgm34xfLyC8gl92rEMUPTP18ALiEfgRdjlcf4s6gax6DXLCnLk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org; spf=pass smtp.mailfrom=manguebit.org; dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b=E868JctP; arc=none smtp.client-ip=143.255.12.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=manguebit.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b="E868JctP"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=manguebit.org; s=dkim; h=Content-Type:MIME-Version:Date:References:
	In-Reply-To:Subject:Cc:To:From:Message-ID:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=2OyA4o0jAjZ8oNAFVmQygbD74kvzMiw03VE9SDZIK6Q=; b=E868JctPP9chcOT+eUCd49cS0l
	o/3fa7aaO0pLYwUJWRQZrfNHPGUI2YuxLltHwpfIUO65zai2Gv5lQMTq8Eswbmnp/yhWlgTaNotD+
	SS4i21XRwa+zheFQoVyBeWfUd6idA+sfk8GDgcgedkgY9swLxDC2FdBmdMqCePHJsBAc2SRw18+N7
	vXTS0PSFiba1rvhnYGOorLQRb57ixFiBvhrVD2zgDEgaa+MLk+F/vLo4yA/5Q1uXPq5GOrbXwUoU4
	MqnoC1Dk8eLQUoSmGLjJMcoJQIjCiMrLJvlJMTObMPY5UDyg0NkODsZVF6neff3R3eFcg2paEWS0a
	CzSIj/zA==;
Received: from pc by mx1.manguebit.org with local (Exim 4.99.5)
	id 1x57iK-00000001EwB-2foz;
	Fri, 11 Sep 2026 17:19:12 -0300
Message-ID: <4b3b1cd3937e3ee589c10db656b496b9@manguebit.org>
From: Paulo Alcantara <pc@manguebit.org>
To: David Howells <dhowells@redhat.com>, Christian Brauner
 <christian@brauner.io>
Cc: David Howells <dhowells@redhat.com>, Matthew Wilcox
 <willy@infradead.org>, Namjae Jeon <linkinjeon@kernel.org>, Marc Dionne
 <marc.dionne@auristor.com>, Stefan Metzmacher <metze@samba.org>, Eric Van
 Hensbergen <ericvh@kernel.org>, Dominique Martinet
 <asmadeus@codewreck.org>, Ilya Dryomov <idryomov@gmail.com>,
 netfs@lists.linux.dev, linux-afs@lists.infradead.org,
 linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
 ceph-devel@vger.kernel.org, v9fs@lists.linux.dev,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v12 1/5] cachefiles: Clean up cachefiles_do_prepare_read()
In-Reply-To: <20260910220242.2165023-2-dhowells@redhat.com>
References: <20260910220242.2165023-1-dhowells@redhat.com>
 <20260910220242.2165023-2-dhowells@redhat.com>
Date: Fri, 11 Sep 2026 17:19:12 -0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

David Howells <dhowells@redhat.com> writes:

> Clean up cachefiles_do_prepare_read() by merging it into
> cachefiles_prepare_read() now that the ondemand mode stuff has been removed.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Marc Dionne <marc.dionne@auristor.com>
> cc: Paulo Alcantara <pc@manguebit.org>
> cc: netfs@lists.linux.dev
> cc: linux-fsdevel@vger.kernel.org

Reviewed-by: Paulo Alcantara <pc@manguebit.org>
