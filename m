Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:34524 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753438AbeADQU3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jan 2018 11:20:29 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: odd TRACE_DEFINE_ENUM behavior
Date: Thu, 4 Jan 2018 11:13:03 -0500
Message-Id: <717BE572-2070-4C1E-9902-9F2E0FEDA4F8@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steven Rostedt <rostedt@goodmis.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steven-

In commit 8224b2734ab1 ("NFS: Add static NFS I/O tracepoints") I added
nfs_show_stable to symbolically display the value of the NFS WRITE stable
field. However, I couldn't get the thing to work with the already-defined
enums in linux/nfs.h, and had to resort to coding numeric constants:

799 /*
800  * XXX: I tried using NFS_UNSTABLE and friends in this table, but they
801  * all evaluate to 0 for some reason, even if I include linux/nfs.h.
802  */
803 #define nfs_show_stable(stable) \
804         __print_symbolic(stable, \
805                         { 0, " (UNSTABLE)" }, \
806                         { 1, " (DATA_SYNC)" }, \
807                         { 2, " (FILE_SYNC)" })

If I code this macro the way the others are written, ie:

TRACE_DEFINE_ENUM(NFS_UNSTABLE);
TRACE_DEFINE_ENUM(NFS_DATA_SYNC);
TRACE_DEFINE_ENUM(NFS_FILE_SYNC);

#define nfs_show_stable(stable) \
	__print_symbolic(stable, \
			{ NFS_UNSTABLE, " (UNSTABLE)" }, \
			{ NFS_DATA_SYNC, " (DATA_SYNC)" }, \
			{ NFS_FILE_SYNC, " (FILE_SYNC)" })

When the field contains 0 it displays "(UNSTABLE)", and when the field
contains a non-zero value the displayed symbol is blank.

More recently I observed a similar issue when adding static trace points
in net/sunrpc/xprtrdma/ , and with existing __print_symbolic call sites
in sunrpc.ko.

There is no file /sys/kernel/debug/tracing/enum_map on my system.

Am I missing something?


--
Chuck Lever



