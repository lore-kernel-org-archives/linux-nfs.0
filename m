Received: from mx1.manguebit.org (mx1.manguebit.org [143.255.12.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 112BE59E333;
	Fri, 11 Sep 2026 20:19:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=143.255.12.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789157977; cv=none; b=G3UR8MnwuGom+9CViZpZEZaYVkhl7tqNAKaXT6iBwdPO+131rymnuUKNooa0kjmLmlWzNy78fnZVC/aXp6MrO+lgxf43geEnBbf36MbiXPNk94K/O7Nar2uF4+o2qRlYTyiT0LXOPa1XvKInEZS9F3jhAgsvDsGwkbZyAJKE8NE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789157977; c=relaxed/simple;
	bh=cgVBb79BH5wk7OkvJeEKBAwPt1p3oSt0z9RjFiWO5r4=;
	h=Message-ID:From:To:Cc:Subject:In-Reply-To:References:Date:
	 MIME-Version:Content-Type; b=c9D0rhXWkBDixn1EEHfeo5RamvPlLforgO7gnzA41O9aLCDtJAK1SMQYvB2GjW1cuvOy2IDUu5SqMf60CDFAmg97I1B1VWc7kNUa9fe1uAh5kKv5CrHHJeBuoKzmFslT/fUErshsD1oAGcDjvxdfbAVlMukTwfkqgmGz5ODBreI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org; spf=pass smtp.mailfrom=manguebit.org; dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b=6ykxZgr1; arc=none smtp.client-ip=143.255.12.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=manguebit.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b="6ykxZgr1"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=manguebit.org; s=dkim; h=Content-Type:MIME-Version:Date:References:
	In-Reply-To:Subject:Cc:To:From:Message-ID:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=cgVBb79BH5wk7OkvJeEKBAwPt1p3oSt0z9RjFiWO5r4=; b=6ykxZgr1GPy1ghgD7ZQCmDOSp6
	q5U1T8WBOcbxAzGyX55C7sB1922iVwzrVfnIpHJ/SYIwuT2bAs/nypz85U+kO1bYMu5AEOVR7itpj
	AGGx78Lod4RLog74+H2oIhiqp03SOV7lgSdoXoWnKNXV2ZexY6butApZZXeBc1Xo3RQSigJDSWoII
	xwJDFQxpyhamAL4EwdAHIMFzjdnhw9GS+qSCmwejgJndirYepcN3e6ifef7d8Gi9tA9uZ+kJq8FH8
	Apf3/lFpRbLc/9DE2DWQT3LpTBZuGSJ0I+6RpToVtYqCAK3ZLKYq4ACtj+SKPF1l1mQA5PFxfb2Wa
	aNt1lVXg==;
Received: from pc by mx1.manguebit.org with local (Exim 4.99.5)
	id 1x57if-00000001Ewa-0gBa;
	Fri, 11 Sep 2026 17:19:33 -0300
Message-ID: <a0756b3036a53f561d2b923836c81d39@manguebit.org>
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
Subject: Re: [PATCH v12 2/5] netfs, cachefiles: Add a couple of traces for
 write failure
In-Reply-To: <20260910220242.2165023-3-dhowells@redhat.com>
References: <20260910220242.2165023-1-dhowells@redhat.com>
 <20260910220242.2165023-3-dhowells@redhat.com>
Date: Fri, 11 Sep 2026 17:19:32 -0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

David Howells <dhowells@redhat.com> writes:

> Add a couple of subrequest traces for write failure in the cache.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Marc Dionne <marc.dionne@auristor.com>
> cc: Paulo Alcantara <pc@manguebit.org>
> cc: netfs@lists.linux.dev
> cc: linux-fsdevel@vger.kernel.org

Reviewed-by: Paulo Alcantara <pc@manguebit.org>
