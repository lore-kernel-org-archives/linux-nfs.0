Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64312238D52;
	Mon, 22 Jun 2026 16:40:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782146452; cv=none; b=TaSOTJJ2K8BH15QgQZ+a0WtpyrNnprsNFfuAjX8ay7JzxQwZ1eP3ZQ4swrr0ZzISQABsMzXtKzcXoBDTVJcdNlZsGN9FJFJ56rliV+A/L/7S6VZ6qcTTNsJFE2fjh1x3Kj2HYGIuxyOMfN+lu2K8qP/RnRDzjqlPEFdg6HYgdJw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782146452; c=relaxed/simple;
	bh=VlfRDc9QQZP3OTb4meK3W37YOlAqyrnZGvqyxn7MT0w=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=kCP5UK+Oe6zuu9WEdqREnyk4CLmh6yw6/5xOC6WfVGItJwLfFEKMZ03qD8D3bXSVdYKfbHwcFCmoxYHXBtx0RX/8aV/H7GSI23pTauMYmOmkhdawX59Z3m6LPg/J8pS+8eXJqIMd1G89J02WUIb51ipbKT29tG/i+VbYO5zkd1c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=wSEig2tX; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="wSEig2tX"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:From:References:Cc:To:Subject:MIME-Version:Date:
	Message-ID:Sender:Reply-To:Content-ID:Content-Description;
	bh=c5UMhYqzW3FXITWipN5SHhAQOB1P9YUKBIDy0r3xPQw=; b=wSEig2tXNqqYlMi+DO0fVntY5n
	xOHolZZKA+fIDoV0P9vbcZYk+nTw3ZO3neQaPzi4xv2gcxwSzlDonXdcprWpDH2QVuSHb1XstdPJW
	SDJunku4cTdk3jGABXOOirk4qvdvStLyf+TSspP6lyyvSkgzI8foJ7iUHjAWC1KMbyOnlr8Bk2/AC
	kSmplFs4mh7vU8qt6mUcBWozaXfZYbjxcaOPfxhFG3Z95uao/bptRNf0v9TlnvAPmJRfMGZZ11YUj
	Kd2cOw4Cnm3blaF1fkpC/rbtuwYhawbpOJtgBO9UdgKUgdoYUd8ev6TfDb5XWKvISvKwTYP33Ug+E
	awdU0f0A==;
Received: from [50.53.43.113] (helo=[192.168.254.34])
	by bombadil.infradead.org with esmtpsa (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wbhhW-00000005CFj-0vuV;
	Mon, 22 Jun 2026 16:40:46 +0000
Message-ID: <08b3c961-18bb-43d9-8d7f-8a87bcad0afa@infradead.org>
Date: Mon, 22 Jun 2026 09:40:45 -0700
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 0/2] tracing: Move trace_printk.h out of kernel.h
To: Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-trace-kernel@vger.kernel.org,
 Masami Hiramatsu <mhiramat@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
 John Ogness <john.ogness@linutronix.de>, Thomas Gleixner <tglx@kernel.org>,
 Julia Lawall <julia.lawall@inria.fr>, Yury Norov <yury.norov@gmail.com>,
 linux-doc@vger.kernel.org, linux-kbuild@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, dri-devel@lists.freedesktop.org,
 linux-stm32@st-md-mailman.stormreply.com,
 linux-arm-kernel@lists.infradead.org, linux-rdma@vger.kernel.org,
 linux-usb@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-nfs@vger.kernel.org, kvm@vger.kernel.org,
 intel-gfx@lists.freedesktop.org
References: <20260621093430.264983361@kernel.org>
 <20260622083440.GX49951@noisy.programming.kicks-ass.net>
Content-Language: en-US
From: Randy Dunlap <rdunlap@infradead.org>
In-Reply-To: <20260622083440.GX49951@noisy.programming.kicks-ass.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit



On 6/22/26 1:34 AM, Peter Zijlstra wrote:
> On Sun, Jun 21, 2026 at 05:34:30AM -0400, Steven Rostedt wrote:
>> There's been complaints about trace_printk() being defined in kernel.h as it
>> can increase the compilation time. As it is only used by some developers for
>> debugging purposes, it should not be in kernel.h causing lots of wasted CPU
>> cycles for those that do not ever care about it.
>>
>> Instead, add a CONFIG_TRACE_PRINTK_DEBUGGING option that developers that do
>> use it can set and not have to always remember to add #include <linux/trace_printk.h>
>> to the files they add trace_printk() while debugging. It also means that
>> those that do not have that config set will not have to worry about wasted
>> CPU cycles as it is only include in the CFLAGS when the option is set, and
>> its completely ignored otherwise.
> 
> Did you forget your C 101 class? If you use a function, you gotta
> include the relevant header.

Also item #1 in Documentation/process/submit-checklist.rst.

> You don't see userspace saying: 'Hey, you know what, perhaps we should
> add stdio.h to every other header, just in case someone wants to
> printf()' either.
> 
> I really don't understand your argument. Yes, maybe someone will forget
> and then either their editor (if they have a halfway modern setup with
> LSP enabled) or their build will complain, but so what? This is all
> trivial stuff, surely we have more pressing matters to concern outselves
> with?



-- 
~Randy

