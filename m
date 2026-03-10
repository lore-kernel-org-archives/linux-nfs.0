Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A60B940DFC2
	for <linux-nfs@vger.kernel.org>; Tue, 10 Mar 2026 13:26:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773149171; cv=none; b=VmntGZM9Mk+j1VUOCJqPtss41/iwq6kE83YaqY95UHVKYcOfkAOZhafwNK31FlyyjsJjI20EbZEseRVUSLHduWlsHQwQDwqk8BDif+W3iL3zMSuKYS1+WgCZAlCt41XLgxxijO7RhuD9DM8OjKCVSC29ptdfSZJ+pbNrQ16kR5Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773149171; c=relaxed/simple;
	bh=e8EtFbgjfSITYOVYzoxC+uQ2Io0HqB7zmiF3HKRPcPg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=CHzlRIzL2g1IMVkZ5W+Pwt3WH2AXdOVdPD05Mbr5/RNl9Wtn1U3j/CsSIMb+N9ACtYPjFM5mwue5t0wr4EBjxTGPupQaxvn6pehT2QZmYnC/G4j3uCLyPwQ7GNUkNvD8ISPvHJtDdXbu7hmnI57fTP3WDMg9q7Yv2wBo4/D+fuE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=C5igvwGG; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="C5igvwGG"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=U3IOCJJlNVaWrgXXqQT8mEstr+D2BAUnc3Cg01MN6AU=; b=C5igvwGGu2X1Eug3uV+cxygegk
	La343pXVFA/sxgrsOkwubXubZs+U0KsvGvNqSNoL7mbKM9fIpWg/LhE/hINdxZ33KNxJ9hb13rhWV
	D7nmumKBvf+V7EWlb5N77pvoEX8HwkVRTJUTCbmY3oOh6Uq8GBmMFQWn/JmuJDPPnBviHQbZ3lHQd
	2VHqaolXsuJJG7OapPILdVPaR0Ns3R01GVkBqcvex25HA2nrUP+qeJ1MXg9tSVS9E6xtoFv9Vm0NQ
	KlH6aGZ1j71xjG9FMJFDBNMiFv7relnofd7v4lzvrMcwl0S+UkU/ORoioOWOeggwqe78AN+q0OSMb
	ysi2ipSg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.98.2 #2 (Red Hat Linux))
	id 1vzx69-00000009b5c-02SA;
	Tue, 10 Mar 2026 13:26:09 +0000
Date: Tue, 10 Mar 2026 06:26:08 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@oracle.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH v2 00/11] NFS/NFSD: nfs4_acl passthru for NFSv4
 reexport
Message-ID: <abAb8NYJECfXkRLg@infradead.org>
References: <20260224192438.25351-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260224192438.25351-1-snitzer@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

NAK on this whole thing.  Linux does not support NFSv4 ACLs for pretty
good reasons.  If you want to add it you'd have to do it properly (even
if that is a bad idea in my opinion).  But adding a weird special case
for passthrough is a no-go.  To be honest I really don't understand why
your (as in Hammerspae, not you personally) want to abuse the kernel
nfsd and nfs client for that.  If you want to pass in the protocol do
it in userspace without burdening the kernel with it.

