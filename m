Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:36982 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754170AbeART37 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jan 2018 14:29:59 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: odd TRACE_DEFINE_ENUM behavior
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180117220108.3650f737@vmware.local.home>
Date: Thu, 18 Jan 2018 14:29:54 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <77CFE919-09B7-4CCC-B2C5-458E9939E20A@oracle.com>
References: <717BE572-2070-4C1E-9902-9F2E0FEDA4F8@oracle.com>
 <20180104130811.552bf2bb@gandalf.local.home>
 <F27A4342-42D6-49C7-94A9-E8F9B496E284@oracle.com>
 <20180104143642.0b0ddea3@gandalf.local.home>
 <81A1ACAC-45E5-4C46-B1C9-7686C85219DE@oracle.com>
 <2B54C608-6435-4779-906F-DA0775A83D7F@oracle.com>
 <20180117220108.3650f737@vmware.local.home>
To: Steven Rostedt <rostedt@goodmis.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jan 17, 2018, at 10:01 PM, Steven Rostedt <rostedt@goodmis.org> =
wrote:
>=20
> On Wed, 17 Jan 2018 16:13:27 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
>=20
>>=20
>> The problem is in this function (kernel/trace/trace_events.c):
>>=20
>> 2212 void trace_event_eval_update(struct trace_eval_map **map, int =
len)
>> 2213 {
>> 2214         struct trace_event_call *call, *p;
>> 2215         const char *last_system =3D NULL;
>> 2216         int last_i;
>> 2217         int i;
>> 2218=20
>> 2219         down_write(&trace_event_sem);
>> 2220         list_for_each_entry_safe(call, p, &ftrace_events, list) =
{
>> 2221                 /* events are usually grouped together with =
systems */
>> 2222                 if (!last_system || call->class->system !=3D =
last_system) {
>> 2223                         last_i =3D 0;
>> 2224                         last_system =3D call->class->system;
>> 2225                 }
>> 2226=20
>> 2227                 for (i =3D last_i; i < len; i++) {
>> 2228                         if (call->class->system =3D=3D =
map[i]->system) {
>> 2229                                 /* Save the first system if need =
be */
>> 2230                                 if (!last_i)
>> 2231                                         last_i =3D i;
>> 2232                                 update_event_printk(call, =
map[i]);
>> 2233                         }
>> 2234                 }
>> 2235         }
>> 2236         up_write(&trace_event_sem);
>> 2237 }
>>=20
>> Loading the nfs.ko module adds an eval map consisting of three =
entries:
>>=20
>> entry 0 is NFS_FILE_SYNC with a value of 2
>> entry 1 is NFS_DATA_SYNC with a value of 1
>> entry 2 is NFS_UNSTABLE with a value of 0
>>=20
>> The nfs.ko trace point print_fmt strings are updated by
>> trace_event_eval_update.
>>=20
>> For the first trace point in nfs.ko, the first iteration of the inner
>> loop visits all three of these map entries, but it's print_fmt does
>> not contain any of these enum symbols, so nothing changes.
>>=20
>> Now thanks to the "last_i" logic above, entry 0 (NFS_FILE_SYNC) is
>> skipped over for other trace points in the module.
>>=20
>> Thus when the print_fmt strings for "nfs_initiate_write" and
>> "nfs_writeback_done" are updated, they are only partially converted,
>> hence:
>>=20
>>> "fileid=3D%02x:%02x:%llu fhandle=3D0x%08x offset=3D%lld count=3D%lu =
stable=3D%d (%s)", ((unsigned int) ((REC->dev) >> 20)), ((unsigned int) =
((REC->dev) & ((1U << 20) - 1))), (unsigned long long)REC->fileid, =
REC->fhandle, REC->offset, REC->count, REC->stable, =
__print_symbolic(REC->stable, { 0, "NFS_UNSTABLE" }, { 1, =
"NFS_DATA_SYNC" }, { NFS_FILE_SYNC, "NFS_FILE_SYNC" }) =20
>>=20
>>=20
>> The updated string contains integers for the first two items in the
>> symbol table, and has an unconverted third item, which cannot be used
>> by "trace-cmd report".
>>=20
>> Adding another TRACE_DEFINE_ENUM in fs/nfs/nfstrace.h works around
>> this issue. I added
>>=20
>> TRACE_DEFINE_ENUM(NFS_INVALID_STABLE_HOW);
>>=20
>> _after_ the first three, and that became entry 0 in the nfs system
>> eval_map. That entry is unusable due to this bug, but I didn't add
>> it to any trace points. The updated print_fmt strings are now 100%
>> correct. "trace-cmd report" works exactly as intended.
>>=20
>> My inclination is to remove the last_i logic from this function, but
>> I don't understand what the last_system/last_i logic is attempting
>> accomplish. Do you have any suggestions?
>=20
> Nice detective work. I see the bug.
>=20
> The last_i is an optimization to not have to search the entire map
> array for the first matching map[i].system every time. But the bug is,
> if the match is on the first hit (i=3D=3D0) then we set last_i to 0, =
and on
> the next iteration we set it (incorrectly) to 1. That's the bug.
>=20
> Can you try this patch?
>=20
> I'll have to add comments to that function, as it took me too long to
> figure out WTF I was thinking when I wrote it.
>=20
> -- Steve
>=20
> diff --git a/kernel/trace/trace_events.c b/kernel/trace/trace_events.c
> index ec0f9aa4e151..9b5b8a362690 100644
> --- a/kernel/trace/trace_events.c
> +++ b/kernel/trace/trace_events.c
> @@ -2213,6 +2213,7 @@ void trace_event_eval_update(struct =
trace_eval_map **map, int len)
> {
> 	struct trace_event_call *call, *p;
> 	const char *last_system =3D NULL;
> +	bool first =3D false;
> 	int last_i;
> 	int i;
>=20
> @@ -2220,6 +2221,7 @@ void trace_event_eval_update(struct =
trace_eval_map **map, int len)
> 	list_for_each_entry_safe(call, p, &ftrace_events, list) {
> 		/* events are usually grouped together with systems */
> 		if (!last_system || call->class->system !=3D =
last_system) {
> +			first =3D true;
> 			last_i =3D 0;
> 			last_system =3D call->class->system;
> 		}
> @@ -2227,8 +2229,10 @@ void trace_event_eval_update(struct =
trace_eval_map **map, int len)
> 		for (i =3D last_i; i < len; i++) {
> 			if (call->class->system =3D=3D map[i]->system) {
> 				/* Save the first system if need be */
> -				if (!last_i)
> +				if (first) {
> 					last_i =3D i;
> +					first =3D false;
> +				}
> 				update_event_printk(call, map[i]);
> 			}
> 		}

Thanks for the patch! I removed the workaround:

  TRACE_DEFINE_ENUM(NFS_INVALID_STABLE_HOW);

and applied the above patch. I'd say the fix passes the test:

[root@manet ~]# cat =
/sys/kernel/debug/tracing/events/nfs/nfs_initiate_write/format
name: nfs_initiate_write
ID: 1819
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
count=3D%lu stable=3D%s", ((unsigned int) ((REC->dev) >> 20)), =
((unsigned int) ((REC->dev) & ((1U << 20) - 1))), (unsigned long =
long)REC->fileid, REC->fhandle, REC->offset, REC->count, =
__print_symbolic(REC->stable, { 0, "UNSTABLE" }, { 1, "DATA_SYNC" }, { =
2, "FILE_SYNC" })
[root@manet ~]#=20

And "trace-cmd report" output appears as expected.

Tested-by: Chuck Lever <chuck.lever@oracle.com>


--
Chuck Lever



