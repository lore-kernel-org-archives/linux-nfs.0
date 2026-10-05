Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CDE6E4BEE3C
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 15:08:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791212895; cv=none; b=LSc7qObQQXGSJ2K9cQdT7AeNa+tGHDuEY5FIpSZLG1LCjq29lK6/2W+22MUqaEMSm8ddppm77/kF60OM/W6erawXuR/7fYlbiGYQHgbWsx91fqmHDRgR7EwfFdT/uGpdrrjsuaTcFcIBZLE7MFmt15CbrhlAO1SR7FaMif71VSs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791212895; c=relaxed/simple;
	bh=zkzTZC2xtehpp5MTbUL0ZW6z/upJZx0A2xrXZxrM46A=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=rNes6XFKRHt85N5ZQ5zI/vrYFSNZAod46KJ0gGsPIWC5TMn4ImYSgJXcGjgURBPhH92RhZ3sYHtIYh5feaXSXqoIFNysTXOs4Sx4V+Wm9GgLgYkU268jpQyEZMbT4hVyd6oIUUhBpF/AEcO35ACsZT2CisRScCPmkWoNxnMfMOY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hKijUcvO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hKijUcvO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 371191F00898;
	Mon,  5 Oct 2026 15:08:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791212894;
	bh=02rYpLAe36EtI19G0JBzkuurGpAzCLy7Gh75lLgee+s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hKijUcvOE6XZi4SWeJqaVMtJzY0+HIBrrXYaAuVunEnMSyaWbd3r5ZSisM7HQUyBv
	 o5+MgpSJwtC8C+Da+qxKZmdfoZ/HBlZvy63WAzS91499Ao2aV0xIXJOPtga08mk4oE
	 eQ9AfOo2/YpBu9rANLG+SoilrWHwuCKp7TKm0aQKRAUFp3bDqVtomBcUCtlIm22aoB
	 GcVR0HPi0+N+b85R9ZFNinzHvEMNLM+uNx31+3cFDX1C+uTRx+lWSKZiJGUa+M2uGu
	 7kccfHNRBElpn6WrjR/aRqkLhMoAj7LcUo2Vgvi0OdGreLMX9v28ZwvKhKZ0w1e03U
	 qo1KLOcco6Ssw==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] SUNRPC: wake a thread after re-queueing transports in svc_clean_up_xprts()
Date: Mon,  5 Oct 2026 11:08:11 -0400
Message-ID: <179121288072.1503704.6561754720829356067.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <53a88892df121e5dfd0d046c2ce58df43bbf93b9.1790963561.git.bcodding@hammerspace.com>
References: <53a88892df121e5dfd0d046c2ce58df43bbf93b9.1790963561.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Mon, 05 Oct 2026 09:42:16 -0400, Benjamin Coddington wrote:
> svc_clean_up_xprts() takes every ready transport off the pool's queue,
> deletes those belonging to the network namespace being shut down, and
> puts the rest back with lwq_enqueue_batch().  No thread is woken.  A
> thread that tested the queue while it was drained has gone to sleep,
> and the re-queued transports still carry XPT_BUSY, so the data they
> receive next cannot enqueue them either.  They wait until an unrelated
> transport wakes a thread.  lockd and the NFSv4 callback service share
> one service across network namespaces and wait in svc_recv() without a
> timeout, so nothing bounds that wait.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] SUNRPC: wake a thread after re-queueing transports in svc_clean_up_xprts()
      commit: 5bf64b6b9099be94627be83231ed705d7ed35b1f

--
Chuck Lever

