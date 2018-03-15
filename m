Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:34250 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbeCOBif (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Mar 2018 21:38:35 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 15/15] nfsd: Trace NFSv4 COMPOUND execution
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180314205515.GD7241@fieldses.org>
Date: Wed, 14 Mar 2018 21:29:29 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F86BA5E4-9073-4202-B2F3-005063243F38@oracle.com>
References: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
 <20180313154459.21531.606.stgit@klimt.1015granger.net>
 <20180314205515.GD7241@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Mar 14, 2018, at 4:55 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Tue, Mar 13, 2018 at 11:44:59AM -0400, Chuck Lever wrote:
>> This helps record the identity and timing of the ops in each NFSv4
>> COMPOUND, replacing dprintk calls that did much the same thing.
>=20
> Would it be better to leave it to userspace to translate an operation
> number to a name?

The tools that are used to look at these records are very generic,
like trace-cmd, which doesn't know from NFS. It's just so much nicer
to use that tool and see operation names that match wireshark displays
rather than op numbers.

However, if you'd like to additionally preserve the operation number
in the trace record, that is possible to add very easily.

Here is the difficulty with the latency event I add earlier in the
series: If we simply record the RPC procedure number there, for NFSv4
we'd see just a bunch of "proc=3D1". I added this here trace event
partially to record the latency of processing each operation in a
COMPOUND, and partially to see which operations are associated with
the latency of the whole RPC (ah, it's SEQUENCE, PUTFH, READ, GETATTR,
so this must be a READ request).


> --b.
>=20
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> fs/nfsd/nfs4proc.c |    9 +++------
>> fs/nfsd/trace.h    |   39 +++++++++++++++++++++++++++++++++++++++
>> 2 files changed, 42 insertions(+), 6 deletions(-)
>>=20
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 39016b6..0df37e0 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -1722,12 +1722,10 @@ static void svcxdr_init_encode(struct =
svc_rqst *rqstp,
>> 		goto encode_op;
>> 	}
>>=20
>> +	trace_nfsd_compound(rqstp, args->opcnt);
>> 	while (!status && resp->opcnt < args->opcnt) {
>> 		op =3D &args->ops[resp->opcnt++];
>>=20
>> -		dprintk("nfsv4 compound op #%d/%d: %d (%s)\n",
>> -			resp->opcnt, args->opcnt, op->opnum,
>> -			nfsd4_op_name(op->opnum));
>> 		/*
>> 		 * The XDR decode routines may have pre-set op->status;
>> 		 * for example, if there is a miscellaneous XDR error
>> @@ -1801,9 +1799,8 @@ static void svcxdr_init_encode(struct svc_rqst =
*rqstp,
>> 			status =3D op->status;
>> 		}
>>=20
>> -		dprintk("nfsv4 compound op %p opcnt %d #%d: %d: status =
%d\n",
>> -			args->ops, args->opcnt, resp->opcnt, op->opnum,
>> -			be32_to_cpu(status));
>> +		trace_nfsd_compound_status(args->opcnt, resp->opcnt, =
status,
>> +					   nfsd4_op_name(op->opnum));

Instead of "op=3D%u/%u" here, maybe the XID might be more useful for
the event that reports each operation in the COMPOUND. On the other
hand, it's pretty obvious which nfsd_compound event these go with:
they will all come from the same nfsd process.


>> 		nfsd4_cstate_clear_replay(cstate);
>> 		nfsd4_increment_op_stats(op->opnum);
>> diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
>> index a8bbd9d..80933e4 100644
>> --- a/fs/nfsd/trace.h
>> +++ b/fs/nfsd/trace.h
>> @@ -11,6 +11,45 @@
>> #include <linux/tracepoint.h>
>> #include "nfsfh.h"
>>=20
>> +TRACE_EVENT(nfsd_compound,
>> +	TP_PROTO(const struct svc_rqst *rqst,
>> +		 u32 args_opcnt),
>> +	TP_ARGS(rqst, args_opcnt),
>> +	TP_STRUCT__entry(
>> +		__field(u32, xid)
>> +		__field(u32, args_opcnt)
>> +	),
>> +	TP_fast_assign(
>> +		__entry->xid =3D be32_to_cpu(rqst->rq_xid);
>> +		__entry->args_opcnt =3D args_opcnt;
>> +	),
>> +	TP_printk("xid=3D0x%08x opcnt=3D%u",
>> +		__entry->xid, __entry->args_opcnt)
>> +)
>> +
>> +TRACE_EVENT(nfsd_compound_status,
>> +	TP_PROTO(u32 args_opcnt,
>> +		 u32 resp_opcnt,
>> +		 __be32 status,
>> +		 const char *name),
>> +	TP_ARGS(args_opcnt, resp_opcnt, status, name),
>> +	TP_STRUCT__entry(
>> +		__field(u32, args_opcnt)
>> +		__field(u32, resp_opcnt)
>> +		__field(int, status)
>> +		__string(name, name)
>> +	),
>> +	TP_fast_assign(
>> +		__entry->args_opcnt =3D args_opcnt;
>> +		__entry->resp_opcnt =3D resp_opcnt;
>> +		__entry->status =3D be32_to_cpu(status);
>> +		__assign_str(name, name);
>> +	),
>> +	TP_printk("op=3D%u/%u %s status=3D%d",
>> +		__entry->resp_opcnt, __entry->args_opcnt,
>> +		__get_str(name), __entry->status)
>> +)
>> +
>> DECLARE_EVENT_CLASS(nfsd_io_class,
>> 	TP_PROTO(struct svc_rqst *rqstp,
>> 		 struct svc_fh	*fhp,
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



