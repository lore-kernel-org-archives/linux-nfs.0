Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:53720 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751829AbeADUFo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jan 2018 15:05:44 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: odd TRACE_DEFINE_ENUM behavior
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <23AEA47E-B3AA-4601-A748-260383C6088E@oracle.com>
Date: Thu, 4 Jan 2018 15:05:40 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9003861A-74E0-42B6-9FEF-DBB6C67BC18E@oracle.com>
References: <717BE572-2070-4C1E-9902-9F2E0FEDA4F8@oracle.com> <20180104130811.552bf2bb@gandalf.local.home> <F27A4342-42D6-49C7-94A9-E8F9B496E284@oracle.com> <20180104143642.0b0ddea3@gandalf.local.home> <23AEA47E-B3AA-4601-A748-260383C6088E@oracle.com>
To: Steven Rostedt <rostedt@goodmis.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 4, 2018, at 2:39 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
>>=20
>> On Jan 4, 2018, at 2:36 PM, Steven Rostedt <rostedt@goodmis.org> =
wrote:
>>=20
>> On Thu, 4 Jan 2018 14:10:21 -0500
>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>=20
>>>>> #define nfs_show_stable(stable) \
>>>>> 	__print_symbolic(stable, \
>>>>> 			{ NFS_UNSTABLE, " (UNSTABLE)" }, \
>>>>> 			{ NFS_DATA_SYNC, " (DATA_SYNC)" }, \
>>>>> 			{ NFS_FILE_SYNC, " (FILE_SYNC)" })
>>>>>=20
>>>>> When the field contains 0 it displays "(UNSTABLE)", and when the =
field
>>>>> contains a non-zero value the displayed symbol is blank. =20
>>>> nfs_initiate_write,
>>>> Can you show my what is in
>>=20
>> Are you sure that it isn't another number there?
>=20
> Yes.
>=20
>=20
>>>> /sys/kernel/debug/tracing/events/nfs/nfs_initiate_write/format =20
>>>=20
>>> This is with current v4.15-rc6 code base:
>>>=20
>>> name: nfs_initiate_write
>>> ID: 1818
>>> format:
>>> 	field:unsigned short common_type;	offset:0;	size:2;	=
signed:0;
>>> 	field:unsigned char common_flags;	offset:2;	size:1;	=
signed:0;
>>> 	field:unsigned char common_preempt_count;	offset:3;	=
size:1;	signed:0;
>>> 	field:int common_pid;	offset:4;	size:4;	signed:1;
>>>=20
>>> 	field:loff_t offset;	offset:8;	size:8;	signed:1;
>>> 	field:unsigned long count;	offset:16;	size:8;	=
signed:0;
>>> 	field:enum nfs3_stable_how stable;	offset:24;	size:4;	=
signed:1;
>>> 	field:dev_t dev;	offset:28;	size:4;	signed:0;
>>> 	field:u32 fhandle;	offset:32;	size:4;	signed:0;
>>> 	field:u64 fileid;	offset:40;	size:8;	signed:0;
>>>=20
>>> print fmt: "fileid=3D%02x:%02x:%llu fhandle=3D0x%08x offset=3D%lld =
count=3D%lu stable=3D%d%s", ((unsigned int) ((REC->dev) >> 20)), =
((unsigned int) ((REC->dev) & ((1U << 20) - 1))), (unsigned long =
long)REC->fileid, REC->fhandle, REC->offset, REC->count, REC->stable, =
__print_symbolic(REC->stable, { 0, " (UNSTABLE)" }, { 1, " (DATA_SYNC)" =
}, { 2, " (FILE_SYNC)" })
>>=20
>> This looks like it should work fine.
>=20
> This does work fine. The source code avoids using TRACE_DEFINE_ENUM.
> Do you want me to wire up the "proper" way to implement =
nfs_show_stable
> and we can experiment on that?

include/linux/nfs.h has:

 47 enum nfs3_stable_how {
 48         NFS_UNSTABLE =3D 0,
 49         NFS_DATA_SYNC =3D 1,
 50         NFS_FILE_SYNC =3D 2,
 51=20
 52         /* used by direct.c to mark verf as invalid */
 53         NFS_INVALID_STABLE_HOW =3D -1
 54 };

I applied this patch to v4.15-rc6:

diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index 093290c..94d4f2e 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -796,15 +796,15 @@
                )
 );
=20
-/*
- * XXX: I tried using NFS_UNSTABLE and friends in this table, but they
- * all evaluate to 0 for some reason, even if I include linux/nfs.h.
- */
+TRACE_DEFINE_ENUM(NFS_UNSTABLE);
+TRACE_DEFINE_ENUM(NFS_DATA_SYNC);
+TRACE_DEFINE_ENUM(NFS_FILE_SYNC);
+
 #define nfs_show_stable(stable) \
        __print_symbolic(stable, \
-                       { 0, " (UNSTABLE)" }, \
-                       { 1, " (DATA_SYNC)" }, \
-                       { 2, " (FILE_SYNC)" })
+                       { NFS_UNSTABLE, " (UNSTABLE)" }, \
+                       { NFS_DATA_SYNC, " (DATA_SYNC)" }, \
+                       { NFS_FILE_SYNC, " (FILE_SYNC)" })
=20
 TRACE_EVENT(nfs_initiate_write,
                TP_PROTO(


eval_map now has this:

NFS_FILE_SYNC 2 (nfs)
NFS_DATA_SYNC 1 (nfs)
NFS_UNSTABLE 0 (nfs)

but nfs_initiate_write/format has this:

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
}, { NFS_FILE_SYNC, " (FILE_SYNC)" })

Which is a little screwy.


>> Can you try this:
>>=20
>> 	trace-cmd record -e nfs_initiate_write
>>=20
>> do stuff to trigger the event, then hit Ctrl^C
>>=20
>> See if "trace-cmd report" shows it. If not do:
>>=20
>> 	trace-cmd report -R
>>=20
>> Which will suppress the translation of the output and show you the =
raw
>> values. That way, you will see what is in the stable field.
>=20
>=20
> --
> Chuck Lever
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



