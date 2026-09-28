Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64837381EAB;
	Mon, 28 Sep 2026 18:18:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790619499; cv=none; b=fcsrZVoP33y7F1rWj1xHeRCYIRizvKKjvq/h0hgMU67e3BggOIFxmQm2VIkD+klg1X8xjGddCJ8ujmXK0avgOn+3o9GzjPDjM7W4tS+Wb0E8yQcw2VfGGZ1kN0uTGQLJy3naAKpa/sHnKUVwm2Gr7jiHlwGmnKG5D4VWnY5uuNU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790619499; c=relaxed/simple;
	bh=oKRUTW5pmzhVUOKB+aDYelAGP4LU7bGPiiH1Cdn7NpY=;
	h=Date:Message-ID:From:To:Cc:Subject:In-Reply-To:References; b=aXKyIJxL6iKKli4StIxaZDDssYHKFkEbFBs05478lYqFUVqBSiVEgn/oQLL5BGU4RaMBLCeG9sfUScgwTp3gMoT6vDYwHvCTSt67NcfQCKpA1o4X2rukBUmBL6XzaZtqpmrVZhbgohVg9YM/z3M4esCLL2E1nAio4CKYePaZHP4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DZkZSvvf; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DZkZSvvf"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D7DFF1F000FF;
	Mon, 28 Sep 2026 18:18:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790619498;
	bh=oKRUTW5pmzhVUOKB+aDYelAGP4LU7bGPiiH1Cdn7NpY=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=DZkZSvvfFawE6n9y+sPZvsexhoAmqgjew+Gi6hOE1CG2FpjUyuptcp7BjjAtTMzKb
	 NVgrKq4Vsro5sO4Z5hBp6m2mwZOYBON4zsmRFQyH0QMPuUcfKexGZSWfJg5ttLioDD
	 Gha5pn2k/xo8kpLHIyaVhN3WY1c9pbDfafnJnlOlCj1EWjE40R+EGZeb6vdJUse7Gr
	 rid0N6B2lnTrXa3b+CUypbmQ0/rh+p1xEelwy85kCUuzxiuz1SFjACSyNdz4waTv7v
	 dJreM02Ej1RAQQ8JLaUf1ilrqx42rqVCyMbwga/RQIF14audbeJogieFDqjSj4XeWn
	 Qyk4PQ9MgW7TA==
Date: Mon, 28 Sep 2026 08:18:17 -1000
Message-ID: <0f2c83b1f2f7ee28c0f479ca53bccc84@kernel.org>
From: Tejun Heo <tj@kernel.org>
To: Pavankumar Kondeti <pavan.kondeti@oss.qualcomm.com>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna@kernel.org>,
	Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] workqueue: Fix NULL current_pwq deref in mem-reclaim
 helper
In-Reply-To: <20260928-wq_mem_reclaim_fix-v1-1-0dd37125cf47@oss.qualcomm.com>
References: <20260928-wq_mem_reclaim_fix-v1-1-0dd37125cf47@oss.qualcomm.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

current_is_workqueue_mem_reclaim() came in through the NFS tree with
da729ddd4a1b ("NFS/localio: issue IO inline when not in a memory-reclaim
context"). Can you please take this fix through the NFS tree too?

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

--
tejun
