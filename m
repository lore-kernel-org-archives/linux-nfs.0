Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7840F32ED55;
	Tue, 28 Jul 2026 20:00:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785268818; cv=none; b=gVuoNurtMVGwpG6jcCJU4V2DZzXnLPtRSnft1S++mqS/Lui3OMccDrIas+w++916/v+U3wlUSZGKCfiGq3mJAO+szQ1msUayaOIH2gnT1tS0xxbV9E3gfJKt58nw9Gyu8Jl9CwaouANAlDmInjlpt4PzaFgq0RaSprX9HkTEPa8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785268818; c=relaxed/simple;
	bh=xQ6vmH9UZNQ+gi24EUL7os0iTnSZtO1sgbtePh0lTzI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=kgeSqTSDWr3nGWzOdJdcOAe7ZqOo9AIJAvMFUk/6puRNKxJRjMcypsLgb9Ez4wEHEcHDbmUZOrbrHzxhXtyn+gQqKwv+3cZGCCDiQpHxNUdZHI2ah9Zc/wxmF3hXveBAa7UenhGHSWdfI650uTyTYT3DlkZ9R3MGBnKPVbMxBmQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UzWj3aq/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UzWj3aq/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 36D071F000E9;
	Tue, 28 Jul 2026 20:00:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785268817;
	bh=p5kBb/lKg8PmnW3aVVkijDJH9Hwnhgzhc5fQ0j+dDoo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=UzWj3aq/wI99Kd8zPJsto8GrYZTq6v1+mFXekeL0Ye/ql7rIHXhZ4Y4a2i7LXwGTL
	 PKUqThnwSajOejjEhesc2FW95ZJDzKnpNpnEcH0pzuLtkrB6AHQZ35GGsRs20qxAVl
	 sPdqvaXumfr4SX9vyKrNatXnaAxkAgIBf9OU7cJQgEOXqJJU5EDY8ePzgf8PT7Wf7w
	 VQk3K+rrcYChyo84QSGxVQQ4cPF6nQQQGXFlYusW2m8RpqUU+pWqqIENIOSzCYUXGg
	 BxZhMir3QE9jEzWi1fWypAqGFv65m3V49BWTYhyGiIfXByk9MqSPYaiuLivEm8g3mi
	 ZaJRJTOWqlEdQ==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	Ameer Hamza <ameer.hamza@truenas.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	nicholas.wolff@truenas.com,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com
Subject: Re: [PATCH] nfsd: fix race between client_info_show() and free_client()
Date: Tue, 28 Jul 2026 16:00:13 -0400
Message-ID: <178526880789.196485.7039893911303764929.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260726124658.1715711-1-ameer.hamza@truenas.com>
References: <20260726124658.1715711-1-ameer.hamza@truenas.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Sun, 26 Jul 2026 17:46:58 +0500, Ameer Hamza wrote:
> client_info_show() renders /proc/fs/nfsd/clients/<id>/info and walks
> clp->cl_sessions under clp->cl_lock to print each session's slot
> counts.  free_client() tears down the same list without taking
> cl_lock, and is the only unlocked mutator of cl_sessions.  A reader
> can observe a client mid-teardown because get_nfsdfs_clp() pins the
> nfs4_client but not its sessions: free_client() frees every session
> before calling nfsd_client_rmdir(), so an in-flight seq_file reader
> can follow a list_del()'d node whose ->next now holds LIST_POISON1
> and take a general protection fault:
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: fix race between client_info_show() and free_client()
      commit: fe521a9894e7ffed2a2eda9383622d4533ad655f

--
Chuck Lever

