Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:58966 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753879AbeARDBL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Jan 2018 22:01:11 -0500
Date: Wed, 17 Jan 2018 22:01:08 -0500
From: Steven Rostedt <rostedt@goodmis.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: odd TRACE_DEFINE_ENUM behavior
Message-ID: <20180117220108.3650f737@vmware.local.home>
In-Reply-To: <2B54C608-6435-4779-906F-DA0775A83D7F@oracle.com>
References: <717BE572-2070-4C1E-9902-9F2E0FEDA4F8@oracle.com>
        <20180104130811.552bf2bb@gandalf.local.home>
        <F27A4342-42D6-49C7-94A9-E8F9B496E284@oracle.com>
        <20180104143642.0b0ddea3@gandalf.local.home>
        <81A1ACAC-45E5-4C46-B1C9-7686C85219DE@oracle.com>
        <2B54C608-6435-4779-906F-DA0775A83D7F@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 17 Jan 2018 16:13:27 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> The problem is in this function (kernel/trace/trace_events.c):
> 
> 2212 void trace_event_eval_update(struct trace_eval_map **map, int len)
> 2213 {
> 2214         struct trace_event_call *call, *p;
> 2215         const char *last_system = NULL;
> 2216         int last_i;
> 2217         int i;
> 2218 
> 2219         down_write(&trace_event_sem);
> 2220         list_for_each_entry_safe(call, p, &ftrace_events, list) {
> 2221                 /* events are usually grouped together with systems */
> 2222                 if (!last_system || call->class->system != last_system) {
> 2223                         last_i = 0;
> 2224                         last_system = call->class->system;
> 2225                 }
> 2226 
> 2227                 for (i = last_i; i < len; i++) {
> 2228                         if (call->class->system == map[i]->system) {
> 2229                                 /* Save the first system if need be */
> 2230                                 if (!last_i)
> 2231                                         last_i = i;
> 2232                                 update_event_printk(call, map[i]);
> 2233                         }
> 2234                 }
> 2235         }
> 2236         up_write(&trace_event_sem);
> 2237 }
> 
> Loading the nfs.ko module adds an eval map consisting of three entries:
> 
> entry 0 is NFS_FILE_SYNC with a value of 2
> entry 1 is NFS_DATA_SYNC with a value of 1
> entry 2 is NFS_UNSTABLE with a value of 0
> 
> The nfs.ko trace point print_fmt strings are updated by
> trace_event_eval_update.
> 
> For the first trace point in nfs.ko, the first iteration of the inner
> loop visits all three of these map entries, but it's print_fmt does
> not contain any of these enum symbols, so nothing changes.
> 
> Now thanks to the "last_i" logic above, entry 0 (NFS_FILE_SYNC) is
> skipped over for other trace points in the module.
> 
> Thus when the print_fmt strings for "nfs_initiate_write" and
> "nfs_writeback_done" are updated, they are only partially converted,
> hence:
> 
> > "fileid=%02x:%02x:%llu fhandle=0x%08x offset=%lld count=%lu stable=%d (%s)", ((unsigned int) ((REC->dev) >> 20)), ((unsigned int) ((REC->dev) & ((1U << 20) - 1))), (unsigned long long)REC->fileid, REC->fhandle, REC->offset, REC->count, REC->stable, __print_symbolic(REC->stable, { 0, "NFS_UNSTABLE" }, { 1, "NFS_DATA_SYNC" }, { NFS_FILE_SYNC, "NFS_FILE_SYNC" })  
> 
> 
> The updated string contains integers for the first two items in the
> symbol table, and has an unconverted third item, which cannot be used
> by "trace-cmd report".
> 
> Adding another TRACE_DEFINE_ENUM in fs/nfs/nfstrace.h works around
> this issue. I added
> 
> TRACE_DEFINE_ENUM(NFS_INVALID_STABLE_HOW);
> 
> _after_ the first three, and that became entry 0 in the nfs system
> eval_map. That entry is unusable due to this bug, but I didn't add
> it to any trace points. The updated print_fmt strings are now 100%
> correct. "trace-cmd report" works exactly as intended.
> 
> My inclination is to remove the last_i logic from this function, but
> I don't understand what the last_system/last_i logic is attempting
> accomplish. Do you have any suggestions?

Nice detective work. I see the bug.

The last_i is an optimization to not have to search the entire map
array for the first matching map[i].system every time. But the bug is,
if the match is on the first hit (i==0) then we set last_i to 0, and on
the next iteration we set it (incorrectly) to 1. That's the bug.

Can you try this patch?

I'll have to add comments to that function, as it took me too long to
figure out WTF I was thinking when I wrote it.

-- Steve

diff --git a/kernel/trace/trace_events.c b/kernel/trace/trace_events.c
index ec0f9aa4e151..9b5b8a362690 100644
--- a/kernel/trace/trace_events.c
+++ b/kernel/trace/trace_events.c
@@ -2213,6 +2213,7 @@ void trace_event_eval_update(struct trace_eval_map **map, int len)
 {
 	struct trace_event_call *call, *p;
 	const char *last_system = NULL;
+	bool first = false;
 	int last_i;
 	int i;
 
@@ -2220,6 +2221,7 @@ void trace_event_eval_update(struct trace_eval_map **map, int len)
 	list_for_each_entry_safe(call, p, &ftrace_events, list) {
 		/* events are usually grouped together with systems */
 		if (!last_system || call->class->system != last_system) {
+			first = true;
 			last_i = 0;
 			last_system = call->class->system;
 		}
@@ -2227,8 +2229,10 @@ void trace_event_eval_update(struct trace_eval_map **map, int len)
 		for (i = last_i; i < len; i++) {
 			if (call->class->system == map[i]->system) {
 				/* Save the first system if need be */
-				if (!last_i)
+				if (first) {
 					last_i = i;
+					first = false;
+				}
 				update_event_printk(call, map[i]);
 			}
 		}
