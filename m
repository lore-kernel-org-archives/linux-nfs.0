Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793684385;
	b=IGBzvDmmInYhO+1yCV5jAY+mWpXQQKvqdGByIwlSGV6TsLMUfTIuW2sa8WdvCqrbCOfs
	 er8OJNY0/9ZfG9KnZDwv2+0xh88s/+H7vBw8OfS+AznF1tfhRO6uPwn5wMr4fb++lkk/A
	 mLzKIAKLvF7AiD0AciAqYNh0YjxNyhIaCqho4KaBmuEj43lW/D5lFIc9c3q189uwzpxuH
	 xfRTh80lAe1COPbcbSazDa8jzSMH07MYRGi/75y7rKUSjbhnrPexcOjAJQc/uRU15Zc7h
	 L3jQCxWOW0zWliZf4zeucRAJreTL7odDzds/9bP1R9Jith+oBjEX5EcaSDHwL71N03A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793684385;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	b=I50khH68aiIMLQcZidAOE8hxEji/XpkXKZrj3kVYolM4NByHIMwfHoee2oQAw6X3Pq2W
	 vV+/P/sqXdDwVBQykWOrkI/k4NBZkPO+bsNkA2l9Vtap5vXzZ0eiHtOeebbSBagzXBRv1
	 RY7zS+R5RqtbopUQKAh0LNxB3zlm9UVU17EnaG3PAVSRbaKu3UBPMphBYXVnBrbbmboXu
	 oXbl+7KkPdR4BLoIEZUd0d6mEDZuh6+On7c47wqP2C8cvme1JxJH+8tqEVRMIWfma8gQ5
	 WndV6OwnkbGSJH3oo4rrsohIXwqXiB+9br+IUwZicaSOQjXwf3yZLyPC7qjzACGOjvw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5E0C606A324
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 05:39:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B5E0C606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 8063D68AFE; Tue,  3 Nov 2026 06:39:41 +0100 (CET)
Date: Tue, 3 Nov 2026 06:39:41 +0100
From: Christoph Hellwig <hch@lst.de>
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, Daejun Park <daejun7.park@samsung.com>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3 2/2] pnfs/blocklayout: report data lost to a failed
 LAYOUTCOMMIT
Message-ID: <20261103053941.GB1526@lst.de>
References: <cover.1793302358.git.bcodding@hammerspace.com> <054f354ecaa596514da593698461206e356004ac.1793302358.git.bcodding@hammerspace.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <054f354ecaa596514da593698461206e356004ac.1793302358.git.bcodding@hammerspace.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

