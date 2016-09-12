Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1] svcauth_gss: Close connection when dropping an incoming message
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160909211822.GA25868@fieldses.org>
Date: Mon, 12 Sep 2016 11:57:13 -0400
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E19D3355-0937-4D59-AEF9-230A5DE8F28E@oracle.com>
References: <20160907202552.15084.40866.stgit@klimt.1015granger.net> <20160909211822.GA25868@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-


> On Sep 9, 2016, at 5:18 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Wed, Sep 07, 2016 at 04:36:19PM -0400, Chuck Lever wrote:
>> S5.3.3.1 of RFC 2203 requires that an incoming GSS-wrapped message
>> whose sequence number lies outside the current window is dropped.
>> The rationale is:
>>=20
>>  The reason for discarding requests silently is that the server
>>  is unable to determine if the duplicate or out of range request
>>  was due to a sequencing problem in the client, network, or the
>>  operating system, or due to some quirk in routing, or a replay
>>  attack by an intruder.  Discarding the request allows the client
>>  to recover after timing out, if indeed the duplication was
>>  unintentional or well intended.
>>=20
>> However, clients may rely on the server dropping the connection to
>> indicate that a retransmit is needed. Without a connection reset, a
>> client can wait forever without retransmitting, and the workload
>> just stops dead. I've reproduced this behavior by running xfstests
>> generic/323 on an NFSv4.0 mount with proto=3Drdma and sec=3Dkrb5i.
>>=20
>> To address this issue, have the server close the connection when it
>> silently discards an incoming message due to a GSS sequence number
>> problem.
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> Cc: Benjamin Coddington <bcodding@redhat.com>
>> ---
>> Hi-
>>=20
>> Passed testing with my reproducer: 10 runs of generic/323 with
>> proto=3Drdma and sec=3Dkrb5i, with NFSv3, NFSv4.0, and NFSv4.1.
>> generic/323 is 120 seconds or so of a heavy aio workload.
>>=20
>> I tested with that dprintk replaced with pr_warn to confirm that the
>> reproducer hits this path one or more times per test run.
>=20
> Thanks, this is useful, but before applying I'd just like to audit =
other
> uses of SVC_DROP in the server rpc code as this probably isn't the =
only
> place with this problem.

Consider this a test result, then.

So, "I'd just like to audit" means you are doing the auditing now, or
would you like me to dig into that?


> Also, this changes behavior for v2/v3 too, does that cause any =
problems?
> Is it OK for the server to just always close connections on dropping =
in
> the v2/v3 case too?

I've run the same tests with NFSv3 (NFS/RDMA + krb5i or krb5p) and did
not see a negative impact. Not much, but there it is.

What would provide more confidence that NFSv2/3 is not impacted?


> --b.
>=20
>>=20
>> net/sunrpc/auth_gss/svcauth_gss.c |    3 ++-
>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c =
b/net/sunrpc/auth_gss/svcauth_gss.c
>> index d858202..3ff52ec 100644
>> --- a/net/sunrpc/auth_gss/svcauth_gss.c
>> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
>> @@ -696,7 +696,8 @@ gss_verify_header(struct svc_rqst *rqstp, struct =
rsc *rsci,
>> 	if (!gss_check_seq_num(rsci, gc->gc_seq)) {
>> 		dprintk("RPC:       svcauth_gss: discarding request with =
"
>> 				"old sequence number %d\n", gc->gc_seq);
>> -		return SVC_DROP;
>> +		/* Signal to the client that an RPC message was lost */
>> +		return SVC_CLOSE;
>> 	}
>> 	return SVC_OK;
>> }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
