Received: from relay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 405B153E0B;
	Sun, 21 Jun 2026 09:47:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=216.40.44.11
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782035263; cv=none; b=kAdRIjhjSTiZNX0uZAeB672CEuV7irCxz8XrB2GW/uV2tvnH17HtanALJR7h1uzr/qRJYhOf3tBlU/KPLg+Z4Tk+MCEROZyGiw468qt/IsrA1GJBEOqZWGCXEOelIFN80GAezXv//ZzsfULNzc3zRv1kgOd+BK2eeoLf2M0m3kU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782035263; c=relaxed/simple;
	bh=bDDdiLLNjwpRAIM1Pb4P4IMGb/RTUM1UfOJfvWRzG4s=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=nau868sgpEizBX7Hjooz9UN0RfldP10X5oTxaA12PnRu+G1FDSxiiv5z4qTI3XhDztwgpQTduJNNVxqYUC/ouBYM0Wycvd2zdsa4fXw+JacSHYBa7ohsRAHeZrZJf3nnOAikNWdowKYvLtCFMSH00g/o2hYQZ4oLTXUagBOJjq4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=goodmis.org; spf=pass smtp.mailfrom=goodmis.org; arc=none smtp.client-ip=216.40.44.11
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=goodmis.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=goodmis.org
Received: from omf17.hostedemail.com (lb01a-stub [10.200.18.249])
	by unirelay07.hostedemail.com (Postfix) with ESMTP id 5F2911669C9;
	Sun, 21 Jun 2026 09:47:31 +0000 (UTC)
Received: from [HIDDEN] (Authenticated sender: rostedt@goodmis.org) by omf17.hostedemail.com (Postfix) with ESMTPA id 423E619;
	Sun, 21 Jun 2026 09:47:24 +0000 (UTC)
Date: Sun, 21 Jun 2026 05:47:21 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: linux-kernel@vger.kernel.org, linux-trace-kernel@vger.kernel.org
Cc: Masami Hiramatsu <mhiramat@kernel.org>, Mark Rutland
 <mark.rutland@arm.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds
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
Subject: Re: [PATCH 2/2] tracing: Add CONFIG_TRACE_PRINTK_DEBUGGING to clean
 up kernel.h
Message-ID: <20260621054721.7cde38f0@fedora>
In-Reply-To: <20260621093811.168514984@kernel.org>
References: <20260621093430.264983361@kernel.org>
	<20260621093811.168514984@kernel.org>
X-Mailer: Claws Mail 4.4.0 (GTK 3.24.52; x86_64-redhat-linux-gnu)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Rspamd-Server: rspamout04
X-Rspamd-Queue-Id: 423E619
X-Stat-Signature: fmj3ggtdgzonpf7zkcaz1xu59knp7xib
X-Session-Marker: 726F737465647440676F6F646D69732E6F7267
X-Session-ID: U2FsdGVkX1/c1xrYJCl0ydW3HbIGCPludPRhKvEu6LQ=
X-HE-Tag: 1782035244-818315
X-HE-Meta: U2FsdGVkX18+OnZrvpIyWt/RWyUKQSX5PXFpTHJVo4PwVmZ7eZdT47ziWR0MyYlIDY1fqyBrJQ7Sk8k5g0+2jmXTLK3lUwRTI0f5QPWBoSBJkbuT1sPD257mlKV1a7d0s3ZNeXJGyaSPBFFVvXt1+Qf+cUBFPUoqGZ0yMtfaXjw3YaFrUe3XLns/TKPMVLkkLwAcJDTciB1Xe3NH/20RSxO90n0HLC/gAJL0U4ehyKGkMZazF4mztUQ3rNuBe2ykFgmEtFv/v9YSeGsstUMosrvQssX7vVaGO3wWKdHlxvzC3LFqWs5SWRpkx5HfojuQQ6b/YNA/zDIqUKZELcAtaTTF9olXpSEl

On Sun, 21 Jun 2026 05:34:32 -0400
Steven Rostedt <rostedt@kernel.org> wrote:

> Instead of having trace_printk.h included in kernel.h, create a config
> TRACE_PRINTK_DEBUGGING that when set will update the CFLAGS in the
> Makefile to allow developers to add trace_printk() without the need to add
> the include for it. Having it included in the Makefile keeps it from being
> in the dependency chain and it will not waste extra CPU cycles for those
> building the kernel without using trace_printk.

Bah, I only tested with the config option enabled, and missed some
dependencies with it disabled.

For instance, rcu.h also uses ftrace_dump() so that too needs to go
into kernel.h. I also need to add a few more includes to trace_printk.h.

OK, I need to run this through all my tests to find where else I missed
adding the includes. But the idea should hopefully satisfy everyone.

-- Steve
