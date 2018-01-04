Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57262 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751952AbeADTgo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Jan 2018 14:36:44 -0500
Date: Thu, 4 Jan 2018 14:36:42 -0500
From: Steven Rostedt <rostedt@goodmis.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: odd TRACE_DEFINE_ENUM behavior
Message-ID: <20180104143642.0b0ddea3@gandalf.local.home>
In-Reply-To: <F27A4342-42D6-49C7-94A9-E8F9B496E284@oracle.com>
References: <717BE572-2070-4C1E-9902-9F2E0FEDA4F8@oracle.com>
        <20180104130811.552bf2bb@gandalf.local.home>
        <F27A4342-42D6-49C7-94A9-E8F9B496E284@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 4 Jan 2018 14:10:21 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> >> #define nfs_show_stable(stable) \
> >> 	__print_symbolic(stable, \
> >> 			{ NFS_UNSTABLE, " (UNSTABLE)" }, \
> >> 			{ NFS_DATA_SYNC, " (DATA_SYNC)" }, \
> >> 			{ NFS_FILE_SYNC, " (FILE_SYNC)" })
> >> 
> >> When the field contains 0 it displays "(UNSTABLE)", and when the field
> >> contains a non-zero value the displayed symbol is blank.  
> > nfs_initiate_write,
> > Can you show my what is in

Are you sure that it isn't another number there?

> > 
> > /sys/kernel/debug/tracing/events/nfs/nfs_initiate_write/format  
> 
> This is with current v4.15-rc6 code base:
> 
> name: nfs_initiate_write
> ID: 1818
> format:
> 	field:unsigned short common_type;	offset:0;	size:2;	signed:0;
> 	field:unsigned char common_flags;	offset:2;	size:1;	signed:0;
> 	field:unsigned char common_preempt_count;	offset:3;	size:1;	signed:0;
> 	field:int common_pid;	offset:4;	size:4;	signed:1;
> 
> 	field:loff_t offset;	offset:8;	size:8;	signed:1;
> 	field:unsigned long count;	offset:16;	size:8;	signed:0;
> 	field:enum nfs3_stable_how stable;	offset:24;	size:4;	signed:1;
> 	field:dev_t dev;	offset:28;	size:4;	signed:0;
> 	field:u32 fhandle;	offset:32;	size:4;	signed:0;
> 	field:u64 fileid;	offset:40;	size:8;	signed:0;
> 
> print fmt: "fileid=%02x:%02x:%llu fhandle=0x%08x offset=%lld count=%lu stable=%d%s", ((unsigned int) ((REC->dev) >> 20)), ((unsigned int) ((REC->dev) & ((1U << 20) - 1))), (unsigned long long)REC->fileid, REC->fhandle, REC->offset, REC->count, REC->stable, __print_symbolic(REC->stable, { 0, " (UNSTABLE)" }, { 1, " (DATA_SYNC)" }, { 2, " (FILE_SYNC)" })

This looks like it should work fine.

Can you try this:

	trace-cmd record -e nfs_initiate_write

do stuff to trigger the event, then hit Ctrl^C

See if "trace-cmd report" shows it. If not do:

	trace-cmd report -R

Which will suppress the translation of the output and show you the raw
values. That way, you will see what is in the stable field.

-- Steve

