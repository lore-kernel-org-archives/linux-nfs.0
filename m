Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932144AbcGAXov (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 19:44:51 -0400
From: Daniel Bristot de Oliveira <bristot@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] tracing, RAS: Cleanup on __get_str() usage
Date: Fri,  1 Jul 2016 20:44:35 -0300
Message-Id: <6f2db5be7705da2cb483923320c91283d7c712a7.1467407618.git.bristot@redhat.com>
In-Reply-To: <cover.1467407618.git.bristot@redhat.com>
References: <cover.1467407618.git.bristot@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

__get_str(msg) does not need (char *) operator overloading to access
mgs's elements anymore. This patch substitutes
((char *)__get_str(msg))[0] usage to __get_str(msg)[0].

It is just a code cleanup, no changes on tracepoint ABI.

Signed-off-by: Daniel Bristot de Oliveira <bristot@redhat.com>
Reviewed-by: Steven Rostedt <rostedt@goodmis.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org
---
 include/ras/ras_event.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/ras/ras_event.h b/include/ras/ras_event.h
index 1443d79..1791a12 100644
--- a/include/ras/ras_event.h
+++ b/include/ras/ras_event.h
@@ -147,7 +147,7 @@ TRACE_EVENT(mc_event,
 		  __entry->error_count,
 		  mc_event_error_type(__entry->error_type),
 		  __entry->error_count > 1 ? "s" : "",
-		  ((char *)__get_str(msg))[0] ? " " : "",
+		  __get_str(msg)[0] ? " " : "",
 		  __get_str(msg),
 		  __get_str(label),
 		  __entry->mc_index,
@@ -157,7 +157,7 @@ TRACE_EVENT(mc_event,
 		  __entry->address,
 		  1 << __entry->grain_bits,
 		  __entry->syndrome,
-		  ((char *)__get_str(driver_detail))[0] ? " " : "",
+		  __get_str(driver_detail)[0] ? " " : "",
 		  __get_str(driver_detail))
 );
 
-- 
2.7.4

