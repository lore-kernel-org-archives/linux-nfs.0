Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2EB58353EF7;
	Sun, 21 Jun 2026 13:04:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782047044; cv=none; b=JFML1jEjjqCthm8wRrMNbjqBdZ+U7nZ08Rww2S+PMUsn58GOY1C3mz/YvW9UWoricHpHymiAOFrCf2hGhdL6mf0+0VFPDwHvX8Kq+fbOv0Xka2kFA1ibEO1FyWQJlvTzcMc3bRrHBFvtd13hu3/AzPSGZ0FqAR5YFGRzPKg4v40=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782047044; c=relaxed/simple;
	bh=XZ3QL+ViFIRQLIm9wDhWdL0BX/Xy+P2cyftFjHpTXuA=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=PqRq1doZBelpHlgMvrHNJcJ27i330RbGyxSJedTLGtO3VO1kd+V7QE1TJyu9qAfhtGz6FYqxPkfAjXJLjBihClKx7VzwMJY1FR+LxvW2rEQ5uOq5JMwLYi3aQE0ftyZE9VsQ8BnDNP/5jlXngRL6vgTfrVlSvg4Usz0DaX6Pxd4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Fov1mXvD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Fov1mXvD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 436C81F000E9;
	Sun, 21 Jun 2026 13:03:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782047042;
	bh=XZ3QL+ViFIRQLIm9wDhWdL0BX/Xy+P2cyftFjHpTXuA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=Fov1mXvDuGCK2T8sN6e2OfQHKCECHfbpGXRBBqt0mJumjJ/lQbWWgN+HJ+/A1VLw+
	 e5YBQ183dvuJj8bkhkLpBwxFrOxwQLVALwfGN8E1vAdvSrax2YUe76xVCjK7uPwOFi
	 8L8TB9EiAaEyP+6x5OTgJet8aZiHBkKPALBPE4+VYsqKVHMeJsBx9VwREe4epBtPeP
	 n9K1YBwfMVRT70tbP5fJHUITXTsn/07OQJHxOY03KDzngCMaGRvGI98OxNWNIGSt1/
	 pUwueEV4G7f1R4ZCP/PbFKS6BI+0tZTyLgw9UhMTaK5YsTglkNBetTBg7DaYsXC78p
	 S9lKpmXhld3Cw==
Date: Sun, 21 Jun 2026 09:03:53 -0400
From: Steven Rostedt <rostedt@kernel.org>
To: David Laight <david.laight.linux@gmail.com>
Cc: Thomas Gleixner <tglx@kernel.org>, linux-kernel@vger.kernel.org,
 linux-trace-kernel@vger.kernel.org, Masami Hiramatsu <mhiramat@kernel.org>,
 Mark Rutland <mark.rutland@arm.com>, Mathieu Desnoyers
 <mathieu.desnoyers@efficios.com>, Andrew Morton
 <akpm@linux-foundation.org>, Linus Torvalds
 <torvalds@linux-foundation.org>, Sebastian Andrzej Siewior
 <bigeasy@linutronix.de>, John Ogness <john.ogness@linutronix.de>, Peter
 Zijlstra <peterz@infradead.org>, Julia Lawall <julia.lawall@inria.fr>, Yury
 Norov <yury.norov@gmail.com>, linux-doc@vger.kernel.org,
 linux-kbuild@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 dri-devel@lists.freedesktop.org, linux-stm32@st-md-mailman.stormreply.com,
 linux-arm-kernel@lists.infradead.org, linux-rdma@vger.kernel.org,
 linux-usb@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-nfs@vger.kernel.org, kvm@vger.kernel.org,
 intel-gfx@lists.freedesktop.org
Subject: Re: [PATCH 2/2] tracing: Add CONFIG_TRACE_PRINTK_DEBUGGING to clean
 up kernel.h
Message-ID: <20260621090353.24772584@fedora>
In-Reply-To: <20260621135531.243375d9@pumpkin>
References: <20260621093430.264983361@kernel.org>
	<20260621093811.168514984@kernel.org>
	<87ik7cmcb7.ffs@fw13>
	<20260621135531.243375d9@pumpkin>
X-Mailer: Claws Mail 4.4.0 (GTK 3.24.52; x86_64-redhat-linux-gnu)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Sun, 21 Jun 2026 13:55:31 +0100
David Laight <david.laight.linux@gmail.com> wrote:

> Indeed...
> Isn't trace_printk() just an extern?
> Having it defined somewhere isn't going to make any difference to build times.

No it is not. It is a macro to cut as many nanoseconds as possible as
trace_printk() was created to debug tight race conditions and any added
latency can make the race go away.

-- Steve
