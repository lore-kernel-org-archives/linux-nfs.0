Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:45902 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750924AbeADSIO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Jan 2018 13:08:14 -0500
Date: Thu, 4 Jan 2018 13:08:11 -0500
From: Steven Rostedt <rostedt@goodmis.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: odd TRACE_DEFINE_ENUM behavior
Message-ID: <20180104130811.552bf2bb@gandalf.local.home>
In-Reply-To: <717BE572-2070-4C1E-9902-9F2E0FEDA4F8@oracle.com>
References: <717BE572-2070-4C1E-9902-9F2E0FEDA4F8@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 4 Jan 2018 11:13:03 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> Hi Steven-
> 
> In commit 8224b2734ab1 ("NFS: Add static NFS I/O tracepoints") I added
> nfs_show_stable to symbolically display the value of the NFS WRITE stable
> field. However, I couldn't get the thing to work with the already-defined
> enums in linux/nfs.h, and had to resort to coding numeric constants:
> 
> 799 /*
> 800  * XXX: I tried using NFS_UNSTABLE and friends in this table, but they
> 801  * all evaluate to 0 for some reason, even if I include linux/nfs.h.
> 802  */
> 803 #define nfs_show_stable(stable) \
> 804         __print_symbolic(stable, \
> 805                         { 0, " (UNSTABLE)" }, \
> 806                         { 1, " (DATA_SYNC)" }, \
> 807                         { 2, " (FILE_SYNC)" })
> 
> If I code this macro the way the others are written, ie:
> 
> TRACE_DEFINE_ENUM(NFS_UNSTABLE);
> TRACE_DEFINE_ENUM(NFS_DATA_SYNC);
> TRACE_DEFINE_ENUM(NFS_FILE_SYNC);
> 
> #define nfs_show_stable(stable) \
> 	__print_symbolic(stable, \
> 			{ NFS_UNSTABLE, " (UNSTABLE)" }, \
> 			{ NFS_DATA_SYNC, " (DATA_SYNC)" }, \
> 			{ NFS_FILE_SYNC, " (FILE_SYNC)" })
> 
> When the field contains 0 it displays "(UNSTABLE)", and when the field
> contains a non-zero value the displayed symbol is blank.
nfs_initiate_write,
Can you show my what is in

 /sys/kernel/debug/tracing/events/nfs/nfs_initiate_write/format

> 
> More recently I observed a similar issue when adding static trace points
> in net/sunrpc/xprtrdma/ , and with existing __print_symbolic call sites
> in sunrpc.ko.
> 
> There is no file /sys/kernel/debug/tracing/enum_map on my system.

That's a debug feature. You need to enable CONFIG_TRACE_ENUM_MAP_FILE

-- Steve

> 
> Am I missing something?
> 
> 
> --
> Chuck Lever
> 
> 

