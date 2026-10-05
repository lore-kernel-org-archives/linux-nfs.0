Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 78997372B58;
	Mon,  5 Oct 2026 08:21:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791188502; cv=none; b=HeFdgVluUxmpYjsHJJUGkPJ03d2EDlyt8mkGJIpCsUXsSFcd1bChjZHlbjMh9pt1+RRlsAxJbAhAs+56DbFZBtHVKrkd8xkAPxfKlLkiBTv2QOb2rPqPt+jZueef0ubCY4MAXtoMZsOYiuJAceGPAdlPjoS41hfM/+zjY7fJxNI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791188502; c=relaxed/simple;
	bh=0jhQh3rJVVaGQcjH4pVxfGlSAHHjnWGt6FjGoaYJKlY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=JjdaYAmTK3TJbcuenGS++hR4w+2/Zu7xTO65wzKKehW1mZZ78Wi+QhrSWd6qEQUZNQJi8rLygvRx2ctPqC98asowwjfgHFtvHpdtJIHt3+wI1Affiw/ZmVOGPH63sRPYfMZFT0/cD0JssB98XzIKsMuRGuDAVceAaw2VJHrsPOs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=EK7P1oU5; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EK7P1oU5"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=aZcthHFgGBzrUMqgfGcslZ6Iyog1TZ2LUofftaLjTDQ=; b=EK7P1oU5oihocO5AcKRiWEBahZ
	8U4hC3+/Il/zzIwn7a2xQdDT5ezn54Iwg3OM29L9aSw5+RsndFzp35zhDxvj0ITumI537qD4QKKCj
	Kd8+aK0qfOciZLNWFeev3AL1AS6pQAp9Fv0GT8e3Cb5tX4xYTbxzU7d6EZ+STDHRfZbm1ke+fDVF4
	oD1zXy0TvTh4oSl8ls7WlEAONUuFWMhGvShQHFrlAvXVFQ/nPEWB/yV6ERXxos8pbe6wSQU1LNU5t
	R8b9ATXgBPi/RKnMLYv1hEEF913nKG3QFRYNiq9qtm4Ynmkx/0icaqyGQWj3gDxeu0OyTDRRysHPg
	dgG5boYg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1xDdwx-0000000Fry6-2r4P;
	Mon, 05 Oct 2026 08:21:31 +0000
Date: Mon, 5 Oct 2026 01:21:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Christian Brauner <christian@brauner.io>,
	Paulo Alcantara <pc@manguebit.org>,
	Matthew Wilcox <willy@infradead.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Stefan Metzmacher <metze@samba.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>, netfs@lists.linux.dev,
	linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@infradead.org>, linux-block@vger.kernel.org
Subject: Re: [PATCH v15 01/10] Add a function to kmap one page of a multipage
 bio_vec
Message-ID: <asNeCzye-xas_Lt7@infradead.org>
References: <20261001091239.3343034-1-dhowells@redhat.com>
 <20261001091239.3343034-2-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261001091239.3343034-2-dhowells@redhat.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

I've now got 4 copies of this series in less than a week, or rather
partial copies as all of them seem to miss a cover letter.

Thus I still don't know how the core code in this series is tested or why
you've not considered using it for anything but your little corner and
thus barely tested.

Please slow down a bit and after the nth time please consider
testability.  Make sure core code regular exercised uses it, or find
a way to unit test it at least.

