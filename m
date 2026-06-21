Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EA6A4F5E0;
	Sun, 21 Jun 2026 09:37:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782034673; cv=none; b=By5qp/xIqGLicqLfRyJK3INC9hbca/L1OwWe1AB1BCflzTEO5XMeqVNHPg3eNkA49PVBNl/ih1o9DNZwgXFLt16xe+JbTTAbjzfxH38An/VO0VmO9cwZN/mZc+msLqKDlkLa3vLdP0F/ODP6Dg0xwn3bEjS10OOONjuiWrxIhhQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782034673; c=relaxed/simple;
	bh=K+edT1yfjoinH0NS1CAtIjPlrPl3JjmRgrhZpYEvozA=;
	h=Message-ID:Date:From:To:Cc:Subject:References:MIME-Version:
	 Content-Type; b=XzHH3TQZACWeH/9nXmK+Li87FckonmW03DahTPt1CU5/9zKjjLbwVTrLM5y2m4/YKXWLB+SG3FCN7K9g3jv6iHLe8t145SxU+rSoANuNBqmevcZwGMADOzISopuCmZZlKVDE0GicT1HqJIf72zq5P4YgsjvtbKvnzxC9iSZ89Do=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kHYbAcsD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kHYbAcsD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C4931F00A3A;
	Sun, 21 Jun 2026 09:37:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782034672;
	bh=eq4Jiz0A0s0y1CCaKrigK8iMCmKO2KO/DMw+O1PS1ZY=;
	h=Date:From:To:Cc:Subject:References;
	b=kHYbAcsD3riuZyE8yw/zGyX4OGv8E29ntBrV/psMay3TNT67fA5gNBpeHGFBeZ/12
	 2Ay7PRmR+s6HdarptXq0OjoszuRK4hDjuFDr5zqy5M5pwo3OOG5Rfwzz1hG/+dQ1n8
	 CM2zwSeAYz4lQYZRNadhemupSTJhYAVEj8Z/JGBsC+uxY4TS20hXDjW9EjrTZX/Dl+
	 vMXqPLpJ/wkow6elNFJjsfNE/3ih99IbbRotQdZuC4nu/UA/y3tJKjSTogiiW5YYf5
	 87SMm3+n4xuUToS7j7SvNUKsWt0yz2IfUnDNb9wlqNTm+yoVD5272meD4iMEV5O7Pw
	 ZebFVZP2gqGBg==
Received: from rostedt by gandalf with local (Exim 4.99.3)
	(envelope-from <rostedt@kernel.org>)
	id 1wbEd1-00000001qU9-0cPr;
	Sun, 21 Jun 2026 05:38:11 -0400
Message-ID: <20260621093811.007634476@kernel.org>
User-Agent: quilt/0.69
Date: Sun, 21 Jun 2026 05:34:31 -0400
From: Steven Rostedt <rostedt@kernel.org>
To: linux-kernel@vger.kernel.org,
 linux-trace-kernel@vger.kernel.org
Cc: Masami Hiramatsu <mhiramat@kernel.org>,
 Mark Rutland <mark.rutland@arm.com>,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
 John Ogness <john.ogness@linutronix.de>,
 Thomas Gleixner <tglx@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Julia Lawall <julia.lawall@inria.fr>,
 Yury Norov <yury.norov@gmail.com>,
 linux-doc@vger.kernel.org,
 linux-kbuild@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org,
 dri-devel@lists.freedesktop.org,
 linux-stm32@st-md-mailman.stormreply.com,
 linux-arm-kernel@lists.infradead.org,
 linux-rdma@vger.kernel.org,
 linux-usb@vger.kernel.org,
 linux-ext4@vger.kernel.org,
 linux-nfs@vger.kernel.org,
 kvm@vger.kernel.org,
 intel-gfx@lists.freedesktop.org
Subject: [PATCH 1/2] tracing: Move non-trace_printk prototypes back to kernel.h
References: <20260621093430.264983361@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8

From: Steven Rostedt <rostedt@goodmis.org>

In order to remove the include to trace_printk.h from kernel.h the tracing
control prototypes need to be moved back into kernel.h. That's because
they are used in other common header files like rcu.h. There's no point in
removing trace_printk.h from kernel.h if it just gets added back to other
common headers.

Prototypes are very cheap for the compiler and should not be an issue.

Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
 include/linux/kernel.h       | 18 ++++++++++++++++++
 include/linux/trace_printk.h | 17 -----------------
 2 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index e5570a16cbb1..c3c68128827c 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -194,4 +194,22 @@ extern enum system_states system_state;
 # define REBUILD_DUE_TO_DYNAMIC_FTRACE
 #endif
 
+#ifdef CONFIG_TRACING
+void tracing_on(void);
+void tracing_off(void);
+int tracing_is_on(void);
+void tracing_snapshot(void);
+void tracing_snapshot_alloc(void);
+void tracing_start(void);
+void tracing_stop(void);
+#else
+static inline void tracing_start(void) { }
+static inline void tracing_stop(void) { }
+static inline void tracing_on(void) { }
+static inline void tracing_off(void) { }
+static inline int tracing_is_on(void) { return 0; }
+static inline void tracing_snapshot(void) { }
+static inline void tracing_snapshot_alloc(void) { }
+#endif
+
 #endif
diff --git a/include/linux/trace_printk.h b/include/linux/trace_printk.h
index 3d54f440dccf..879fed0805fd 100644
--- a/include/linux/trace_printk.h
+++ b/include/linux/trace_printk.h
@@ -35,15 +35,6 @@ enum ftrace_dump_mode {
 };
 
 #ifdef CONFIG_TRACING
-void tracing_on(void);
-void tracing_off(void);
-int tracing_is_on(void);
-void tracing_snapshot(void);
-void tracing_snapshot_alloc(void);
-
-extern void tracing_start(void);
-extern void tracing_stop(void);
-
 static inline __printf(1, 2)
 void ____trace_printk_check_format(const char *fmt, ...)
 {
@@ -176,16 +167,8 @@ __ftrace_vprintk(unsigned long ip, const char *fmt, va_list ap);
 
 extern void ftrace_dump(enum ftrace_dump_mode oops_dump_mode);
 #else
-static inline void tracing_start(void) { }
-static inline void tracing_stop(void) { }
 static inline void trace_dump_stack(int skip) { }
 
-static inline void tracing_on(void) { }
-static inline void tracing_off(void) { }
-static inline int tracing_is_on(void) { return 0; }
-static inline void tracing_snapshot(void) { }
-static inline void tracing_snapshot_alloc(void) { }
-
 static inline __printf(1, 2)
 int trace_printk(const char *fmt, ...)
 {
-- 
2.53.0


