Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752457AbcGAXos (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 19:44:48 -0400
From: Daniel Bristot de Oliveira <bristot@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] tracing: Use outer () on __get_str() definition
Date: Fri,  1 Jul 2016 20:44:34 -0300
Message-Id: <20ac1a10c2ec4ccd23e4a8ef34101fb6e4157d37.1467407618.git.bristot@redhat.com>
In-Reply-To: <cover.1467407618.git.bristot@redhat.com>
References: <cover.1467407618.git.bristot@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

__get_str(str)'s definition includes a (char *) operator
overloading that is not protected with outer ().

This patch adds () around __get_str()'s definition, enabling
some code cleanup.

Suggested-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Daniel Bristot de Oliveira <bristot@redhat.com>
Reviewed-by: Steven Rostedt <rostedt@goodmis.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org
---
 include/trace/perf.h         | 2 +-
 include/trace/trace_events.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/trace/perf.h b/include/trace/perf.h
index 26486fc..7144550 100644
--- a/include/trace/perf.h
+++ b/include/trace/perf.h
@@ -15,7 +15,7 @@
 		((__entry->__data_loc_##field >> 16) & 0xffff)
 
 #undef __get_str
-#define __get_str(field) (char *)__get_dynamic_array(field)
+#define __get_str(field) ((char *)__get_dynamic_array(field))
 
 #undef __get_bitmask
 #define __get_bitmask(field) (char *)__get_dynamic_array(field)
diff --git a/include/trace/trace_events.h b/include/trace/trace_events.h
index 170c93b..427e4aa 100644
--- a/include/trace/trace_events.h
+++ b/include/trace/trace_events.h
@@ -256,7 +256,7 @@ TRACE_MAKE_SYSTEM_STR();
 		((__entry->__data_loc_##field >> 16) & 0xffff)
 
 #undef __get_str
-#define __get_str(field) (char *)__get_dynamic_array(field)
+#define __get_str(field) ((char *)__get_dynamic_array(field))
 
 #undef __get_bitmask
 #define __get_bitmask(field)						\
-- 
2.7.4

