Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:45522 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754483AbeAIWfr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jan 2018 17:35:47 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: odd TRACE_DEFINE_ENUM behavior
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180104143642.0b0ddea3@gandalf.local.home>
Date: Tue, 9 Jan 2018 17:35:44 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <81A1ACAC-45E5-4C46-B1C9-7686C85219DE@oracle.com>
References: <717BE572-2070-4C1E-9902-9F2E0FEDA4F8@oracle.com>
 <20180104130811.552bf2bb@gandalf.local.home>
 <F27A4342-42D6-49C7-94A9-E8F9B496E284@oracle.com>
 <20180104143642.0b0ddea3@gandalf.local.home>
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
>=20
>>>=20
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
>=20
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

This is with:

TRACE_DEFINE_ENUM(NFS_UNSTABLE);
TRACE_DEFINE_ENUM(NFS_DATA_SYNC);
TRACE_DEFINE_ENUM(NFS_FILE_SYNC);

#define nfs_show_stable(stable) \
       __print_symbolic(stable, \
                        { NFS_UNSTABLE, "NFS_UNSTABLE" }, \
                        { NFS_DATA_SYNC, "NFS_DATA_SYNC" }, \
                        { NFS_FILE_SYNC, "NFS_FILE_SYNC" })

Here's "cat =
/sys/kernel/debug/events/tracing/nfs/nfs_initiate_write/format" :

print_fmt: "fileid=3D%02x:%02x:%llu fhandle=3D0x%08x offset=3D%lld =
count=3D%lu stable=3D%d (%s)", ((unsigned int) ((REC->dev) >> 20)), =
((unsigned int) ((REC->dev) & ((1U << 20) - 1))), (unsigned long =
long)REC->fileid, REC->fhandle, REC->offset, REC->count, REC->stable, =
__print_symbolic(REC->stable, { 0, "NFS_UNSTABLE" }, { 1, =
"NFS_DATA_SYNC" }, { NFS_FILE_SYNC, "NFS_FILE_SYNC" })

The last element in the __print_symbolic table is wrong. For comparison,
here's an excerpt of "strings nfs.ko | grep NFS_FILE_SYNC" :

"fileid=3D%02x:%02x:%llu fhandle=3D0x%08x offset=3D%lld count=3D%lu =
stable=3D%d (%s)", ((unsigned int) ((REC->dev) >> 20)), ((unsigned int) =
((REC->dev) & ((1U << 20) - 1))), (unsigned long long)REC->fileid, =
REC->fhandle, REC->offset, REC->count, REC->stable, =
__print_symbolic(REC->stable, { NFS_UNSTABLE, "NFS_UNSTABLE" }, { =
NFS_DATA_SYNC, "NFS_DATA_SYNC" }, { NFS_FILE_SYNC, "NFS_FILE_SYNC" })

Note this copy of the table contains three symbolic names. I haven't =
been
able to find the code that adjusts the print_fmt string to understand =
the
difference with the output from "cat /sys/kernel ..." . But that code
doesn't seem to adjust the last element in the __print_symbolic table.


trace-cmd report

           <...>-11353 [001]  6211.728494: nfs_initiate_write:   =
fileid=3D00:2a:301409 fhandle=3D0x820b4b2e offset=3D0 count=3D601 =
stable=3D2 ()
           <...>-11353 [004]  6211.728783: nfs_initiate_write:   =
fileid=3D00:2a:301410 fhandle=3D0x0c844ccd offset=3D0 count=3D738 =
stable=3D2 ()
           <...>-11353 [001]  6211.729023: nfs_initiate_write:   =
fileid=3D00:2a:301411 fhandle=3D0xc02e4c53 offset=3D0 count=3D4015 =
stable=3D2 ()
           <...>-11353 [005]  6211.729351: nfs_initiate_write:   =
fileid=3D00:2a:301412 fhandle=3D0xcaeb454a offset=3D0 count=3D282 =
stable=3D2 ()
           <...>-11353 [003]  6211.729651: nfs_initiate_write:   =
fileid=3D00:2a:301413 fhandle=3D0x064145d4 offset=3D0 count=3D7688 =
stable=3D2 ()

trace-cmd report -R

           <...>-11353 [001]  6211.728494: nfs_initiate_write:    =
offset=3D0 count=3D0x259 stable=3D2 dev=3D42 fhandle=3D2181778222 =
fileid=3D301409
           <...>-11353 [004]  6211.728783: nfs_initiate_write:    =
offset=3D0 count=3D0x2e2 stable=3D2 dev=3D42 fhandle=3D209997005 =
fileid=3D301410
           <...>-11353 [001]  6211.729023: nfs_initiate_write:    =
offset=3D0 count=3D0xfaf stable=3D2 dev=3D42 fhandle=3D3224259667 =
fileid=3D301411
           <...>-11353 [005]  6211.729351: nfs_initiate_write:    =
offset=3D0 count=3D0x11a stable=3D2 dev=3D42 fhandle=3D3404416330 =
fileid=3D301412
           <...>-11353 [003]  6211.729651: nfs_initiate_write:    =
offset=3D0 count=3D0x1e08 stable=3D2 dev=3D42 fhandle=3D104941012 =
fileid=3D301413

Thanks for your advice!


--
Chuck Lever



