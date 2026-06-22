Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BD7739182F;
	Mon, 22 Jun 2026 08:53:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782118437; cv=none; b=IdSceP4L7kYyFYSmzh7StveBvNro1VgoNBqihgbyKbhkiBeToQPjRMi/bRhWyGaZQgmDdNEeTqxayOrVCGrHYJvMOMeHIrc0rCheY3SvlqHFgTuy4aUPE9M0V8YHSgBqwLnvmIkCJvfsOP8WIPy4pl57ioUs2K/xF/M3QB6YnHA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782118437; c=relaxed/simple;
	bh=F0QDbKzbwJL5X7qHqHx3lNvTzGz2HWk2gVQO8+kpuo4=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=obFM555zHDAoSGr+Mlk7ecHjbRMgPjzsMIDqxRXaaQu9coC4BCJ/7uBI790EOmrof0jAcjUEyZJQUawMZdpNdhkH05YN0nkfa6Ni/qnJ9Xwi8N2hIZ4Uvb/x1/KtwGo2LKcoGf5qBg0gBxTTHBAlUMLz6Zg0Lxj6u8w5c+rfIzs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ajlI+5u/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ajlI+5u/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9AC2D1F000E9;
	Mon, 22 Jun 2026 08:53:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782118436;
	bh=F0QDbKzbwJL5X7qHqHx3lNvTzGz2HWk2gVQO8+kpuo4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=ajlI+5u/5Lj2pViAZ/RRrobaBRBiwWG66TcLSclH6VgEiCX3pzDLlq48vZSrLl/X8
	 83z3ruboQqIDbVazIhHwx5JGip9lf+VbpxcPHWDw4gUbR2Bw69RzekHFOjw35JGN9n
	 l49gtrdtrrpSxrgPKnZ20Ihao2CfoXdAXnGeH046LsVIeNBgYuAr6j2Bl9nhTwMRH1
	 NVF5eY3swwkEMDcbxo+5cJInP+bkLasG/LJYc3V14JQcH8mspffB7CU3PNR9GftU3u
	 4KuHvQ9gz+PnSNbgojMjSyDZOSgzPCMpMUPB3eHzmTZ5JEKCdN/SpRFdTGAODdPinY
	 wPF/FF/evMf3Q==
Date: Mon, 22 Jun 2026 04:53:48 -0400
From: Steven Rostedt <rostedt@kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-trace-kernel@vger.kernel.org, Masami
 Hiramatsu <mhiramat@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Andrew Morton
 <akpm@linux-foundation.org>, Linus Torvalds
 <torvalds@linux-foundation.org>, Sebastian Andrzej Siewior
 <bigeasy@linutronix.de>, John Ogness <john.ogness@linutronix.de>, Thomas
 Gleixner <tglx@kernel.org>, Julia Lawall <julia.lawall@inria.fr>, Yury
 Norov <yury.norov@gmail.com>, linux-doc@vger.kernel.org,
 linux-kbuild@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 dri-devel@lists.freedesktop.org, linux-stm32@st-md-mailman.stormreply.com,
 linux-arm-kernel@lists.infradead.org, linux-rdma@vger.kernel.org,
 linux-usb@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-nfs@vger.kernel.org, kvm@vger.kernel.org,
 intel-gfx@lists.freedesktop.org
Subject: Re: [PATCH 0/2] tracing: Move trace_printk.h out of kernel.h
Message-ID: <20260622045348.3e1a7833@fedora>
In-Reply-To: <20260622083440.GX49951@noisy.programming.kicks-ass.net>
References: <20260621093430.264983361@kernel.org>
	<20260622083440.GX49951@noisy.programming.kicks-ass.net>
X-Mailer: Claws Mail 4.4.0 (GTK 3.24.52; x86_64-redhat-linux-gnu)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Mon, 22 Jun 2026 10:34:40 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> Did you forget your C 101 class? If you use a function, you gotta
> include the relevant header.

If this was the way it was back in 2009, yeah sure. But the header
wasn't need for 17 years. Now it suddenly will be.

-- Steve
