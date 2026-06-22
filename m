Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54A5B390998;
	Mon, 22 Jun 2026 13:08:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782133716; cv=none; b=linQzqeGsXsD2V4/LjuuITrxfcdNgEd1EO822HKE5pyXMC5xGctOcMtUUD8zQH8oO99JC4NqgOqmYJze24vED7c9EwrCrDEFBIQWZMEaDtlf8S/qZLfQNNmB41n7X0lUGTWbd9xJQFLo56wBtG5bBuPVKRgFYwKMsbAZBhO8Uz4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782133716; c=relaxed/simple;
	bh=Ao6okc9bWJbhFHg/MDFNztgFltrYBcu0addAjYys+F8=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=uA6nCqn+RKCHNpZutkp8uk1THfn0OveyY+CMRCWxgJdhSJP/aQkFsxkW3nrgVM43oNPtncljVHlrmm2kdMGvXaP280TcCPghONuNTLWeOuhqk9i9c3FCK9fzc0ZXZpOK0RrHH++yRbnAbSIPggmtm1PMcK1tWZdpsLpOucH/q6A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=a20FWXNV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="a20FWXNV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5FB651F000E9;
	Mon, 22 Jun 2026 13:08:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782133715;
	bh=Wl8mD9+xZA8nx14eIBmWbrmAKkBoa2SL0k1i5niNjQs=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=a20FWXNV5UIOVvZQK3oYlnmbhvnGanajAqGfPBzgq1mtLmcUE0p/4+x6YU7Shadgl
	 mqi/3qM8CCBEc0VEfdgQBopeHXXuKfZG+uiDCEbuCYUpTv0SvsiCbiGCb/9bB4KhEW
	 DRUlVIjPKW+wSj99mCg6leZnz6Tlv8BmEwq+uZD69jaXsaAzuDy40c4nJO/LtwTgIV
	 HkMCM8iVWaXizhCkYCbfvhIXZ4Fc2dHPUyzviYNP1yPfWv5E/7zB3cUSfjt3Sls1ya
	 Bk1Z9eNqEc0O10dh8knMYEWL3e8V2fAD+NW45w3IWR+66cvzU66jHpfTiQOKBsif7e
	 TuRZv2ou5tdjQ==
Date: Mon, 22 Jun 2026 09:08:26 -0400
From: Steven Rostedt <rostedt@kernel.org>
To: "Christophe Leroy (CS GROUP)" <chleroy@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-trace-kernel@vger.kernel.org, Masami
 Hiramatsu <mhiramat@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Andrew Morton
 <akpm@linux-foundation.org>, Linus Torvalds
 <torvalds@linux-foundation.org>, Sebastian Andrzej Siewior
 <bigeasy@linutronix.de>, John Ogness <john.ogness@linutronix.de>, Thomas
 Gleixner <tglx@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Julia
 Lawall <julia.lawall@inria.fr>, Yury Norov <yury.norov@gmail.com>,
 linux-doc@vger.kernel.org, linux-kbuild@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, dri-devel@lists.freedesktop.org,
 linux-stm32@st-md-mailman.stormreply.com,
 linux-arm-kernel@lists.infradead.org, linux-rdma@vger.kernel.org,
 linux-usb@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-nfs@vger.kernel.org, kvm@vger.kernel.org,
 intel-gfx@lists.freedesktop.org
Subject: Re: [PATCH 0/2] tracing: Move trace_printk.h out of kernel.h
Message-ID: <20260622090826.20efadb3@fedora>
In-Reply-To: <dbb5915e-6587-4de9-87f3-76bea5024da8@kernel.org>
References: <20260621093430.264983361@kernel.org>
	<dbb5915e-6587-4de9-87f3-76bea5024da8@kernel.org>
X-Mailer: Claws Mail 4.4.0 (GTK 3.24.52; x86_64-redhat-linux-gnu)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Mon, 22 Jun 2026 10:05:13 +0200
"Christophe Leroy (CS GROUP)" <chleroy@kernel.org> wrote:

> > There's been complaints about trace_printk() being defined in kernel.h as it
> > can increase the compilation time. As it is only used by some developers for
> > debugging purposes, it should not be in kernel.h causing lots of wasted CPU
> > cycles for those that do not ever care about it.  
> 
> Do we have a measurement of the increased compilation time ?

I believe Yury does.

-- Steve
