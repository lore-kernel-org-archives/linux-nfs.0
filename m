Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86F71383C83;
	Thu, 25 Jun 2026 11:06:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.19
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782385608; cv=none; b=pTl8fZ0Sdr4+1GQY6JUIxG9ux2o6N8h3hbLAidtTi6EUb2IyeRjHpFA5NMwc+6jeYLLO8xLuIyQA0SY/7F2JquMA92t5AcHkl/uw2fBcE4ezpl3B+LXEgTaRKVUBzXUYF6WrHRVbZe0dYngKj5SKCnOeQK8DMmhw9XBC84LYbF8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782385608; c=relaxed/simple;
	bh=3mMUyu41hsUV3+8vmn2FEljozTYUkLukSLGnNifcCP4=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=Cbz7X52MNL1FaPpJw8jICrIUQKV6VCw01AVB5sLFRur7Hp2gta/wZCu+aKgTOHd2cV/r3wl4Lna5NIvQEpaYm0/lpwS9F4+vYA+O+dfrkUX1PyhaKG0jsLtvhcU1hditx2z01ZCoIuB1P4hzSLNF9vWlKwA4TyEZA/X+GnSll64=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=Js69GYC6; arc=none smtp.client-ip=192.198.163.19
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="Js69GYC6"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1782385607; x=1813921607;
  h=from:to:cc:subject:in-reply-to:references:date:
   message-id:mime-version;
  bh=3mMUyu41hsUV3+8vmn2FEljozTYUkLukSLGnNifcCP4=;
  b=Js69GYC6fPLCmm3RJpgVDxjHsPhZnw+5+6KFzihp882O06PtIoCXAo2T
   10kSV1qxrTt/iba+zaaTOIHMtN5jvHFyJQ838xzLilBO+EsNCOhbWv8XL
   L1Z50MXDL2M8HlXZaEdXmGK0GniIT/PP5gKrGhQRrMoscvEwv4GxcdzWT
   RmvsnHcNXFVALmUxxJGpVx19mpkF2eiR6YwE/JTOlTbMXta7jW7jGvBIY
   rjC4wgj/dIPHEfglrzRDeudGe7zXkP/x+EG6KqwulyOtDCAriSI/aOppp
   rbv6daJsl0jnarPW3Vdss2jWf58zbnBG4tA1hT/Cri6QX233yC7BMRxqG
   A==;
X-CSE-ConnectionGUID: vWWc4pIlSFaabSR50gPX9Q==
X-CSE-MsgGUID: fh2MkgcUTC6A4QxgfSLFaA==
X-IronPort-AV: E=McAfee;i="6800,10657,11827"; a="82144902"
X-IronPort-AV: E=Sophos;i="6.24,224,1774335600"; 
   d="scan'208";a="82144902"
Received: from orviesa006.jf.intel.com ([10.64.159.146])
  by fmvoesa113.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 25 Jun 2026 04:06:05 -0700
X-CSE-ConnectionGUID: Ff5wjq2eS3y4NEnYZUPVEg==
X-CSE-MsgGUID: /T55+aBtS92ybM5/4REhrg==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.24,224,1774335600"; 
   d="scan'208";a="249131302"
Received: from ijarvine-mobl1.ger.corp.intel.com (HELO localhost) ([10.245.245.126])
  by orviesa006-auth.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 25 Jun 2026 04:05:58 -0700
From: Jani Nikula <jani.nikula@linux.intel.com>
To: Steven Rostedt <rostedt@kernel.org>, linux-kernel@vger.kernel.org,
 linux-trace-kernel@vger.kernel.org
Cc: Masami Hiramatsu <mhiramat@kernel.org>, Mark Rutland
 <mark.rutland@arm.com>, Mathieu Desnoyers
 <mathieu.desnoyers@efficios.com>, Andrew Morton
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
Subject: Re: [PATCH v4 0/2] tracing: Move non-trace_printk prototypes into
 trace_controls.h
In-Reply-To: <20260625104007.041432666@kernel.org>
Organization: Intel Finland Oy - BIC 0357606-4 - c/o Alberga Business Park,
 6 krs Bertel Jungin Aukio 5, 02600 Espoo, Finland
References: <20260625104007.041432666@kernel.org>
Date: Thu, 25 Jun 2026 14:05:56 +0300
Message-ID: <2037b6b62264c0192d45733ec1099c3ec14085a2@intel.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On Thu, 25 Jun 2026, Steven Rostedt <rostedt@kernel.org> wrote:
> Remove trace_printk.h by creating a trace_controls.h for those places that
> need access to tracing prototypes like tracing_off() and for the places that
> need trace_printk() directly, to have it included directly.
>
> Changse since v3: https://lore.kernel.org/all/20260624081806.120105649@kernel.org/
>
> - Always include trace_controls.h in rcu.h (kernel test robot)
>
>   There are other configs that may include tracing_off() in rcu.h besides
>   the one that had the include of trace_controls.h. Just always include
>   it in that header to be safe.
>
> Steven Rostedt (2):
>       tracing: Move non-trace_printk prototypes into trace_controls.h
>       tracing: Remove trace_printk.h from kernel.h
>
> ----
>  arch/powerpc/kvm/book3s_xics.c         |  1 +
>  arch/powerpc/xmon/xmon.c               |  1 +
>  arch/s390/kernel/ipl.c                 |  1 +
>  arch/s390/kernel/machine_kexec.c       |  1 +
>  drivers/gpu/drm/i915/gt/intel_gtt.h    |  1 +
>  drivers/gpu/drm/i915/i915_gem.h        |  2 ++

For the i915 parts,

Acked-by: Jani Nikula <jani.nikula@intel.com>

for merging via whichever tree.

>  drivers/hwtracing/stm/dummy_stm.c      |  1 +
>  drivers/infiniband/hw/hfi1/trace_dbg.h |  1 +
>  drivers/tty/sysrq.c                    |  1 +
>  drivers/usb/early/xhci-dbc.c           |  1 +
>  fs/ext4/inline.c                       |  1 +
>  include/linux/ftrace.h                 |  2 ++
>  include/linux/kernel.h                 |  1 -
>  include/linux/sunrpc/debug.h           |  1 +
>  include/linux/trace_controls.h         | 54 ++++++++++++++++++++++++++++++++
>  include/linux/trace_printk.h           | 56 ++--------------------------------
>  kernel/debug/debug_core.c              |  1 +
>  kernel/panic.c                         |  1 +
>  kernel/rcu/rcu.h                       |  1 +
>  kernel/rcu/rcutorture.c                |  1 +
>  kernel/trace/ring_buffer_benchmark.c   |  1 +
>  kernel/trace/trace.h                   |  1 +
>  kernel/trace/trace_benchmark.c         |  1 +
>  lib/sys_info.c                         |  1 +
>  samples/fprobe/fprobe_example.c        |  1 +
>  samples/ftrace/ftrace-direct-too.c     |  1 -
>  samples/trace_printk/trace-printk.c    |  1 +
>  27 files changed, 82 insertions(+), 55 deletions(-)
>  create mode 100644 include/linux/trace_controls.h

-- 
Jani Nikula, Intel
