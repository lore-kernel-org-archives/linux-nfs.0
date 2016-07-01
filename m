Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47115 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932144AbcGAXpA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 19:45:00 -0400
From: Daniel Bristot de Oliveira <bristot@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] printk, tracing: Avoiding unneeded blank lines
Date: Fri,  1 Jul 2016 20:44:37 -0300
Message-Id: <c350fb2521baaf681a1b4d67981ca0e900108e8e.1467407618.git.bristot@redhat.com>
In-Reply-To: <cover.1467407618.git.bristot@redhat.com>
References: <cover.1467407618.git.bristot@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Printk messages often finish with '\n' to cause a new line.
But as each tracepoint is already printed in a new line,
printk messages that finish with '\n' ends up adding a blank
line to the trace output. For example:

     kworker/0:1-86    [000] d...    46.006949: console: [   46.006946] usb 1-3: USB disconnect, device number 3

     kworker/2:2-374   [002] d...    48.699342: console: [   48.699339] usb 1-3: new high-speed USB device number 4 using ehci-pci

     kworker/2:2-374   [002] d...    49.041450: console: [   49.041448] usb 1-3: New USB device found, idVendor=5986, idProduct=0

To avoid unneeded blank lines, this patch checks if the printk
message finishes with '\n', if so, it cut is off the '\n' to
avoid blank lines.

In a patched kernel, the same messages are printed without
extra blank lines. For example:

     kworker/0:4-185   [000] d...    23.641738: console: [   23.641736] usb 1-3: USB disconnect, device number 3
     kworker/0:4-185   [000] d...    24.918703: console: [   24.918700] usb 1-3: new high-speed USB device number 4 using ehci-pci
     kworker/0:4-185   [000] d...    25.228308: console: [   25.228306] usb 1-3: New USB device found, idVendor=5986, idProduct=02d5


Signed-off-by: Daniel Bristot de Oliveira <bristot@redhat.com>
Reviewed-by: Steven Rostedt <rostedt@goodmis.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org
---
 include/trace/events/printk.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/trace/events/printk.h b/include/trace/events/printk.h
index 542a755..bc9139d29 100644
--- a/include/trace/events/printk.h
+++ b/include/trace/events/printk.h
@@ -16,6 +16,14 @@ TRACE_EVENT(console,
 	),
 
 	TP_fast_assign(
+		/*
+		 * Each trace entry is printed in a new line.
+		 * If the msg finishes with '\n', cut it off
+		 * to avoid blank lines in the trace.
+		 */
+		if ((len > 0) && (text[len-1] == '\n'))
+			len -= 1;
+
 		memcpy(__get_str(msg), text, len);
 		__get_str(msg)[len] = 0;
 	),
-- 
2.7.4

