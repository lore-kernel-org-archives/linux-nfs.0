Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:35300 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753154AbeADTK1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jan 2018 14:10:27 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: odd TRACE_DEFINE_ENUM behavior
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180104130811.552bf2bb@gandalf.local.home>
Date: Thu, 4 Jan 2018 14:10:21 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F27A4342-42D6-49C7-94A9-E8F9B496E284@oracle.com>
References: <717BE572-2070-4C1E-9902-9F2E0FEDA4F8@oracle.com> <20180104130811.552bf2bb@gandalf.local.home>
To: Steven Rostedt <rostedt@goodmis.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 4, 2018, at 1:08 PM, Steven Rostedt <rostedt@goodmis.org> =
wrote:
>=20
> On Thu, 4 Jan 2018 11:13:03 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
>=20
>> Hi Steven-
>>=20
>> In commit 8224b2734ab1 ("NFS: Add static NFS I/O tracepoints") I =
added
>> nfs_show_stable to symbolically display the value of the NFS WRITE =
stable
>> field. However, I couldn't get the thing to work with the =
already-defined
>> enums in linux/nfs.h, and had to resort to coding numeric constants:
>>=20
>> 799 /*
>> 800  * XXX: I tried using NFS_UNSTABLE and friends in this table, but =
they
>> 801  * all evaluate to 0 for some reason, even if I include =
linux/nfs.h.
>> 802  */
>> 803 #define nfs_show_stable(stable) \
>> 804         __print_symbolic(stable, \
>> 805                         { 0, " (UNSTABLE)" }, \
>> 806                         { 1, " (DATA_SYNC)" }, \
>> 807                         { 2, " (FILE_SYNC)" })
>>=20
>> If I code this macro the way the others are written, ie:
>>=20
>> TRACE_DEFINE_ENUM(NFS_UNSTABLE);
>> TRACE_DEFINE_ENUM(NFS_DATA_SYNC);
>> TRACE_DEFINE_ENUM(NFS_FILE_SYNC);
>>=20
>> #define nfs_show_stable(stable) \
>> 	__print_symbolic(stable, \
>> 			{ NFS_UNSTABLE, " (UNSTABLE)" }, \
>> 			{ NFS_DATA_SYNC, " (DATA_SYNC)" }, \
>> 			{ NFS_FILE_SYNC, " (FILE_SYNC)" })
>>=20
>> When the field contains 0 it displays "(UNSTABLE)", and when the =
field
>> contains a non-zero value the displayed symbol is blank.
> nfs_initiate_write,
> Can you show my what is in
>=20
> /sys/kernel/debug/tracing/events/nfs/nfs_initiate_write/format

This is with current v4.15-rc6 code base:

name: nfs_initiate_write
ID: 1818
format:
	field:unsigned short common_type;	offset:0;	size:2;	=
signed:0;
	field:unsigned char common_flags;	offset:2;	size:1;	=
signed:0;
	field:unsigned char common_preempt_count;	offset:3;	=
size:1;	signed:0;
	field:int common_pid;	offset:4;	size:4;	signed:1;

	field:loff_t offset;	offset:8;	size:8;	signed:1;
	field:unsigned long count;	offset:16;	size:8;	=
signed:0;
	field:enum nfs3_stable_how stable;	offset:24;	size:4;	=
signed:1;
	field:dev_t dev;	offset:28;	size:4;	signed:0;
	field:u32 fhandle;	offset:32;	size:4;	signed:0;
	field:u64 fileid;	offset:40;	size:8;	signed:0;

print fmt: "fileid=3D%02x:%02x:%llu fhandle=3D0x%08x offset=3D%lld =
count=3D%lu stable=3D%d%s", ((unsigned int) ((REC->dev) >> 20)), =
((unsigned int) ((REC->dev) & ((1U << 20) - 1))), (unsigned long =
long)REC->fileid, REC->fhandle, REC->offset, REC->count, REC->stable, =
__print_symbolic(REC->stable, { 0, " (UNSTABLE)" }, { 1, " (DATA_SYNC)" =
}, { 2, " (FILE_SYNC)" })


>> More recently I observed a similar issue when adding static trace =
points
>> in net/sunrpc/xprtrdma/ , and with existing __print_symbolic call =
sites
>> in sunrpc.ko.
>>=20
>> There is no file /sys/kernel/debug/tracing/enum_map on my system.
>=20
> That's a debug feature. You need to enable CONFIG_TRACE_ENUM_MAP_FILE
>=20
> -- Steve
>=20
>>=20
>> Am I missing something?
>>=20
>>=20
>> --
>> Chuck Lever

--
Chuck Lever



