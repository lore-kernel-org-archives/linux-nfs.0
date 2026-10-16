Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25A0F346FA8;
	Fri, 16 Oct 2026 13:01:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792155707; cv=none; b=ToXZ+vHbgZofvCOj8tgCyAE0e9jv9TJSETrD/YKo3ZmsFkClZurMR2F3U3T7B/wqc8ybDwvhmCpH2m4gUbHKCzscIPSs6rPP/OeZXNUJnznkfbqJP4daqIxeZII7bEXqhsbEtR6cU/wb3vNs6K9tAk237NJV6Bgb8taj4Z5Wcow=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792155707; c=relaxed/simple;
	bh=5uTULoZRm2rJ56HSuY5IKkWgpwfBMRrA4qksWs5RscY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=X/tPcyPW1l2/5Alj/G2WRpXNytYUfcOPdrlt1yMiHrpZEUveL0bBvYZ+imnwxeSw9DsXHnHGQ/WIhm7V6FWAmebHhejimAbHM/7MWLxdQgObUBliF7qY9Lznypdktrlnc/cfzYIvROw5HR+8sR35uzliPjbdCUX7bb+9lnTdHRM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=3+TPIJVR; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="3+TPIJVR"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=Jn4kIZ7k8DMzWlOoO5v3gP798FxHNNxUL7cguoacKjQ=; b=3+TPIJVRZXTuFTAf4M7c8Wz2iH
	7EDbpiihqc4J866WXcD6nRBPgauHXi07HYXyeOOHacAqryGd+CHdaxibdQtJ/8GDry4/0CSx0pePe
	jyESvANi99dLPFrDP5W0ju7XwIGG9eYmQovjhbZhBkcjUxvwIFwKTuF6ZJgnW9HDxbjFpcTfFeVTl
	QdDapF9xZJAUXW6jtQz7YdQZwaETmJSbhWLzUm+lB8jcuuKWMRLRa1b3q+NAizACHbpGV7rXRsdTn
	HIOdxONsbNXoCXjyjGS5DnRLLkU2dwy/f4ufaUEyQPE1+qD0LQs0ww2V3UC40w/tzGCkbzevuvYBE
	tsGYpThg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1xHhZ3-00000002zZz-06W9;
	Fri, 16 Oct 2026 13:01:37 +0000
Date: Fri, 16 Oct 2026 06:01:37 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Liu Chao <liuc63@xiaopeng.com>
Cc: Anna Schumaker <anna@kernel.org>, Trond Myklebust <trondmy@kernel.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfs/blocklayout: reject stripe volume with zero
 chunk_size
Message-ID: <atIgMa2kTStMxe9e@infradead.org>
References: <20261016041139.2292455-1-liuc63@xiaopeng.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261016041139.2292455-1-liuc63@xiaopeng.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Fri, Oct 16, 2026 at 12:11:39PM +0800, Liu Chao wrote:
> bl_parse_stripe() copies v->stripe.chunk_size from the volume
> descriptor supplied by the server into d->chunk_size without any
> validation.  bl_map_stripe() later divides the block offset by
> d->chunk_size, so a malicious or broken server that advertises a
> stripe volume with chunk_size == 0 triggers a divide error in the
> kernel and crashes the client.
> 
> Reject the volume at parse time when chunk_size is zero, before the
> value is stored, so the deviceid node allocation fails cleanly with
> -EIO instead of faulting later.

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

