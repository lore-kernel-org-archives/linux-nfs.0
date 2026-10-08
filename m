Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id B256E3EC830;
	Thu,  8 Oct 2026 22:54:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.140.110.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791500099; cv=none; b=iPIyBIcSTKxBUtnRpa9uNzbmRYLdxDqkTOkbJGKB3L1gN8+dKhidxfBLM1jxSVp3ptej7w2hbzp4fIIWSPd/ET//Ag49Vt9TZUuwcNNj48TgY0QYNPONhQuaoty5IpzyjOmzSWufJntYN1CQS4KojVvSXr79Wkd2Y/EWWVieLwQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791500099; c=relaxed/simple;
	bh=HB7WbcF/KbhEe+oqV92vnMKSNr+Myc+CjLAgihUmXyc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LhNanmKjbyVEHw2CIr65DIH2e7/CpEbtDbNWUvfiCv+FBz2qxnsOQs4uwP1fmCZOo3YjEDm67FIV5QkSe9RlKLMvPrI/5AOE36UeNNVOXVIC+Zh//QKC4WtrkuJVmscNe9RhZUMg/9HJVCRVTybE1D+mGhqoBOLUBNfNU9hTc04=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com; spf=pass smtp.mailfrom=arm.com; dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b=bA7gHsDH; arc=none smtp.client-ip=217.140.110.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b="bA7gHsDH"
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8DA9B1692;
	Thu,  8 Oct 2026 15:54:54 -0700 (PDT)
Received: from e132076.cambridge.arm.com (e132076.arm.com [10.2.197.107])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 567ED3F66F;
	Thu,  8 Oct 2026 15:54:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=arm.com; s=foss;
	t=1791500097; bh=HB7WbcF/KbhEe+oqV92vnMKSNr+Myc+CjLAgihUmXyc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=bA7gHsDHLZqYLapgLPI2AIlgWxt8AoaPKdXD8UxPCTOUukkZCtcKegpNifs8gao9h
	 uq6lICntN0lNJ2N/DNOF1GHV0/O1cNqVxbX+/z3BYzrT16ptaQ+aRaDarewTA32B/W
	 jURjdVrcOWyXFbHrhsWWtdcQP4eBytUu2+9u5bdc=
From: J Louis Kaplan <Louis.Kaplan@arm.com>
To: cel@kernel.org,
	dai.ngo@oracle.com,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	tom@talpey.com
Cc: anna@kernel.org,
	jgg@ziepe.ca,
	leon@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	trondmy@kernel.org
Subject: Re: [RFC PATCH 3/6] svcrdma: Coalesce contiguous pages when mapping replies
Date: Thu,  8 Oct 2026 23:54:50 +0100
Message-ID: <20261008225450.664642-1-Louis.Kaplan@arm.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <59261d53-53fc-4195-a7f4-d9f117bb0150@app.fastmail.com>
References: <59261d53-53fc-4195-a7f4-d9f117bb0150@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> There are some interesting infrastructural changes in this series.
> Using bvecs through the svcrdma code has been on my to-do list
> for quite some time.

Glad to hear that. I'm happy to split out smaller parts of work from
this patch series if helpful.
