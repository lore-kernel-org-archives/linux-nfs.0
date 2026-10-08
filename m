Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 4BF323C10AD;
	Thu,  8 Oct 2026 22:45:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.140.110.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791499513; cv=none; b=ZSS9Z7MZJ2BDklzdHqM9ISzKyeJvwFDI9KHwubaQL+t2P1g2/lckL25pkdOF+17/Sybmek8gr5xuRPYyx+lNzqPa1AUhwyGnJM/gK4+79AhhZ0Lei90ktQSsjfQFRs1qmB9nSAkHbxvH27kaviRBbS/2i9FS3Z47Ix9eH+uQLiY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791499513; c=relaxed/simple;
	bh=leBlUYbWqfZKNQIiXsiihXNjgI3akGeH7VdSE1og7C4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WYxqI0GEEKYS7reEdAEDBuyat1lBzESatvPMR4hRgHSZPO7DBCStnwz2grqAuokKgIgeehWB7jZ2/IYunfirSgCYSO/rRUZp6wI8fDJ8M0ohb+5U/e/1/5c5itmfmOZrROjw+Tu3jRd2olim+pkrTQkvSzMwP3iUa6l3+c5v1+Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com; spf=pass smtp.mailfrom=arm.com; dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b=rWJFhYh+; arc=none smtp.client-ip=217.140.110.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b="rWJFhYh+"
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 003E6175D;
	Thu,  8 Oct 2026 15:45:06 -0700 (PDT)
Received: from e132076.cambridge.arm.com (e132076.arm.com [10.2.197.107])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BA54D3F66F;
	Thu,  8 Oct 2026 15:45:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=arm.com; s=foss;
	t=1791499509; bh=leBlUYbWqfZKNQIiXsiihXNjgI3akGeH7VdSE1og7C4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=rWJFhYh+6IfmNcexeJYDv577KxSTrTG39rllIeZe9ztMPwrczM/ghmTJC/sMm/FDz
	 fkHwdC4HTAOXJ/+RK3SnH4YTgp8JKPsYzAlBltJ4hOqYOfSAg/4wJH1lje4JPNEK8Q
	 z/+HE5nyzcwmu8aXcrjLHwZyDnyb94nA/nbW21Jg=
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
Subject: Re: [RFC PATCH 1/6] sunrpc: Add helpers to build bvecs from contiguous pages
Date: Thu,  8 Oct 2026 23:44:55 +0100
Message-ID: <20261008224455.614922-1-Louis.Kaplan@arm.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <4c1f4d35-4c30-49b9-85c7-de6be58fdf81@app.fastmail.com>
References: <4c1f4d35-4c30-49b9-85c7-de6be58fdf81@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> Generally any function larger than two or three lines is to be kept
> out of line.

Thanks for explaining that, Chuck. I will fix as suggested in any
subsequent patch series.
