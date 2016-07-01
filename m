Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752457AbcGAXor (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 19:44:47 -0400
From: Daniel Bristot de Oliveira <bristot@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] tracing: printk:console fix and __get_str() cleanup
Date: Fri,  1 Jul 2016 20:44:33 -0300
Message-Id: <cover.1467407618.git.bristot@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series fixes a problem on printk:console tracepoint
that prints a blank line in the trace output after each printk
message that finishes with '\n'.

It also does some cleanup on __get_str() usage, that
was found while fixing the printk:console tracepoint.

Daniel Bristot de Oliveira (4):
  tracing: Use outer () on __get_str() definition
  tracing, RAS: Cleanup on __get_str() usage
  tracing: Use __get_str() when manipulating strings
  printk, tracing: Avoiding unneeded blank lines

 fs/nfs/nfs4trace.h            |  4 ++--
 fs/nfs/nfstrace.h             |  4 ++--
 include/ras/ras_event.h       |  4 ++--
 include/trace/events/printk.h | 12 ++++++++++--
 include/trace/perf.h          |  2 +-
 include/trace/trace_events.h  |  2 +-
 6 files changed, 18 insertions(+), 10 deletions(-)

-- 
2.7.4

