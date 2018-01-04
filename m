Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:34046 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753154AbeADTjy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jan 2018 14:39:54 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: odd TRACE_DEFINE_ENUM behavior
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180104143642.0b0ddea3@gandalf.local.home>
Date: Thu, 4 Jan 2018 14:39:49 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <23AEA47E-B3AA-4601-A748-260383C6088E@oracle.com>
References: <717BE572-2070-4C1E-9902-9F2E0FEDA4F8@oracle.com> <20180104130811.552bf2bb@gandalf.local.home> <F27A4342-42D6-49C7-94A9-E8F9B496E284@oracle.com> <20180104143642.0b0ddea3@gandalf.local.home>
To: Steven Rostedt <rostedt@goodmis.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 4, 2018, at 2:36 PM, Steven Rostedt <rostedt@goodmis.org> =
wrote:
>=20
> On Thu, 4 Jan 2018 14:10:21 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
>=20
>>>> #define nfs_show_stable(stable) \
>>>> 	__print_symbolic(stable, \
>>>> 			{ NFS_UNSTABLE, " (UNSTABLE)" }, \
>>>> 			{ NFS_DATA_SYNC, " (DATA_SYNC)" }, \
>>>> 			{ NFS_FILE_SYNC, " (FILE_SYNC)" })
>>>>=20
>>>> When the field contains 0 it displays "(UNSTABLE)", and when the =
field
>>>> contains a non-zero value the displayed symbol is blank. =20
>>> nfs_initiate_write,
>>> Can you show my what is in
>=20
> Are you sure that it isn't another number there?

Yes.


>>> /sys/kernel/debug/tracing/events/nfs/nfs_initiate_write/format =20
>>=20
>> This is with current v4.15-rc6 code base:
>>=20
>> name: nfs_initiate_write
>> ID: 1818
>> format:
>> 	field:unsigned short common_type;	offset:0;	size:2;	=
signed:0;
>> 	field:unsigned char common_flags;	offset:2;	size:1;	=
signed:0;
>> 	field:unsigned char common_preempt_count;	offset:3;	=
size:1;	signed:0;
>> 	field:int common_pid;	offset:4;	size:4;	signed:1;
>>=20
>> 	field:loff_t offset;	offset:8;	size:8;	signed:1;
>> 	field:unsigned long count;	offset:16;	size:8;	=
signed:0;
>> 	field:enum nfs3_stable_how stable;	offset:24;	size:4;	=
signed:1;
>> 	field:dev_t dev;	offset:28;	size:4;	signed:0;
>> 	field:u32 fhandle;	offset:32;	size:4;	signed:0;
>> 	field:u64 fileid;	offset:40;	size:8;	signed:0;
>>=20
>> print fmt: "fileid=3D%02x:%02x:%llu fhandle=3D0x%08x offset=3D%lld =
count=3D%lu stable=3D%d%s", ((unsigned int) ((REC->dev) >> 20)), =
((unsigned int) ((REC->dev) & ((1U << 20) - 1))), (unsigned long =
long)REC->fileid, REC->fhandle, REC->offset, REC->count, REC->stable, =
__print_symbolic(REC->stable, { 0, " (UNSTABLE)" }, { 1, " (DATA_SYNC)" =
}, { 2, " (FILE_SYNC)" })
>=20
> This looks like it should work fine.

This does work fine. The source code avoids using TRACE_DEFINE_ENUM.
Do you want me to wire up the "proper" way to implement nfs_show_stable
and we can experiment on that?


> Can you try this:
>=20
> 	trace-cmd record -e nfs_initiate_write
>=20
> do stuff to trigger the event, then hit Ctrl^C
>=20
> See if "trace-cmd report" shows it. If not do:
>=20
> 	trace-cmd report -R
>=20
> Which will suppress the translation of the output and show you the raw
> values. That way, you will see what is in the stable field.


--
Chuck Lever



