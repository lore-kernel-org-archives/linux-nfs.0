Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E39893A1CD;
	Thu, 11 Jun 2026 00:45:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781138740; cv=none; b=DPSArAI/K+i4fBrMtx2tt8hdiHqLPwr+GUYBI6ubzEsDqpOzQVS72OHPCxtBcD9FBPJOVZj7CPN9NuRKuICShfT1pirjJrOdfLZv8qAc5YQVznrDjrsbnw6JVfDxJJXGw4OBOooWiN7tDR6YE0b/UFFXxuJyZA887TNDzEjNKlA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781138740; c=relaxed/simple;
	bh=rrrVqWgIxqpDSRFS2Jkv6kbnlvfZzuAdRDXsUMGaDVo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Eo6de/MKgAbhERNcqVBCUYAFA/V9/tfq6tCJVFDkQCtwDiYuoV78GZGbNAzLPob5NsTy8EfgapOkkfAXHgFgCcujmZ779+tFpl2dgvPTOmHeWLDczpEVVIz7MBIETvEqKTuCFQhdZ6y/1AsL15W18p2Wa7CxFokZ9zdqabx+DCs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jshs50JG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jshs50JG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 226D31F00898;
	Thu, 11 Jun 2026 00:45:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781138739;
	bh=rrrVqWgIxqpDSRFS2Jkv6kbnlvfZzuAdRDXsUMGaDVo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=jshs50JGnp6olQs/l+eLpLrBTaA+hj7YzaxsHUHJx2eSaK3tFHUy2Z9PMatEYDCAr
	 F3B+kyq60UlepPJgZAwDfO2A6lWvhHAVjKo6tG23y50ikrA3RK2U0CY6MFvcznEdlL
	 zA7v1a6ptsxZ9ldU6KCMwgygW2OhtDTkmAYIuQBG9OoZCqco9Z5e3EYtHXaX+XJiWw
	 9upMbQcaX9/Wvnug3RvMfz71GBp9QcEZ7nwjnJ8KE9+i2HozZpF43pPj0E3UlXZyzd
	 273pIKUug1/UCcNUINNQAKzXiekGJYUkCxug+qJpx9jVX82Wv8uZMs+YdgVyeoDebp
	 24KfydKOLN6CQ==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Sasha Levin <sashal@kernel.org>,
	Vladislav Nikolaev <vlad102nikolaev@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	lvc-project@linuxtesting.org,
	syzbot+e34ad04f27991521104c@syzkaller.appspotmail.com
Subject: Re: [PATCH 5.10/5.15] nfsd: don't ignore the return code of svc_proc_register()
Date: Wed, 10 Jun 2026 20:45:22 -0400
Message-ID: <20260610-stable-reply-0006@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260609172356.1887-1-vlad102nikolaev@gmail.com>
References: <20260609172356.1887-1-vlad102nikolaev@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Mon, Jun 09, 2026 at 08:23:54PM +0300, Vladislav Nikolaev wrote:
> [PATCH 5.10/5.15] nfsd: don't ignore the return code of svc_proc_register()

Queued for 5.15 and 5.10, thanks.

--
Thanks,
Sasha
