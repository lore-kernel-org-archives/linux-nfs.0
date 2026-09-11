Received: from mx1.manguebit.org (mx1.manguebit.org [143.255.12.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B06985678ED;
	Fri, 11 Sep 2026 20:19:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=143.255.12.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789157994; cv=none; b=Bus24mwAkNSIChmKito9xXxsycqdbuRpYPJPi03n6yA3u3EH5ikVH9AptDF8WYFPVk14afM9efCpNNiQo5GIVTU6JhraGvverRoaypv879/jGHbrA2T/0Srf/IbtbZTvy38SjV3G4cCNDY/aBwKsihUy3KobRuDyqjZGAkLjfHY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789157994; c=relaxed/simple;
	bh=WujUq1eMM5pvnZolInHG5G25Q2BM0wYJXW0ABAD7rVk=;
	h=Message-ID:From:To:Cc:Subject:In-Reply-To:References:Date:
	 MIME-Version:Content-Type; b=EgfGIW4l/KJlHrl2K51UoSR7MyIAc/8Xk/zyu1QktvBKyPiyujmcjQcNE3tGHxGy8qJ28MnB+DQwnY8ZnL59/2l1iJy9VbwAlMAdhmnffHq0WXqwdN/NYw7Jr34wfOA36bzP5EKIx+Kdrj+2sQeAfzmjIXrKvrgOEUWxlYNRp1A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org; spf=pass smtp.mailfrom=manguebit.org; dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b=DAf+gd96; arc=none smtp.client-ip=143.255.12.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=manguebit.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b="DAf+gd96"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=manguebit.org; s=dkim; h=Content-Type:MIME-Version:Date:References:
	In-Reply-To:Subject:Cc:To:From:Message-ID:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=WujUq1eMM5pvnZolInHG5G25Q2BM0wYJXW0ABAD7rVk=; b=DAf+gd96cgJJp290OQ/Fxe+ooO
	DX2Qjqvy4Iwp6U1CaNCTgPzj+7EWpFqy6H0267ppXfYp43Pufrt9tFE4o+/sxnM3MK9oits5NcK/z
	Oh0ZOLJyfqtvCGEdhsNIzsUQ2Vyeg4fQRNIq+WKie3iVY6n9tez930wo5ib2fCVwVkdwTqlptGgJ2
	5rDN1TwrwOqnIaB4GCXQmD1HEGsdoY04Q67b3ZYa0THsPBB8K8wWLO5LOssTmCcQ33Fnva5REL/36
	EWVv3pme55BaZkUzVbjj0mBCayX4d/uQJT+TEnLJUrK7qhnaydGuaDRoNPDeTTqlImsssAAXUPz6J
	OK78JnOQ==;
Received: from pc by mx1.manguebit.org with local (Exim 4.99.5)
	id 1x57iw-00000001Ewy-1al8;
	Fri, 11 Sep 2026 17:19:50 -0300
Message-ID: <3a64b5fb25930d52bf57ccd9cec468ad@manguebit.org>
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
Subject: Re: [PATCH v12 3/5] cachefiles: Add a tracepoint to log
 insufficient space errors
In-Reply-To: <20260910220242.2165023-4-dhowells@redhat.com>
References: <20260910220242.2165023-1-dhowells@redhat.com>
 <20260910220242.2165023-4-dhowells@redhat.com>
Date: Fri, 11 Sep 2026 17:19:50 -0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

David Howells <dhowells@redhat.com> writes:

> Add a tracepoint to log insufficient space errors.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Marc Dionne <marc.dionne@auristor.com>
> cc: Paulo Alcantara <pc@manguebit.org>
> cc: netfs@lists.linux.dev
> cc: linux-fsdevel@vger.kernel.org

Reviewed-by: Paulo Alcantara <pc@manguebit.org>
