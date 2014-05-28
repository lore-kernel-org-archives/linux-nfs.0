Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37183 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751833AbaE1VZD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 May 2014 17:25:03 -0400
Message-ID: <53865423.4060905@RedHat.com>
Date: Wed, 28 May 2014 17:24:51 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] Avoid buffer overruns by allocating buffer in svcauth_gss_validate()
References: <1401304171-12231-1-git-send-email-steved@redhat.com> <B43A996B-5DB8-470B-926C-27FF30445D7D@oracle.com>
In-Reply-To: <B43A996B-5DB8-470B-926C-27FF30445D7D@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/28/2014 03:11 PM, Chuck Lever wrote:
> 
> On May 28, 2014, at 3:09 PM, Steve Dickson <steved@redhat.com> wrote:
> 
>> Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Thank you... For your time! 

steved.

> 
>> ---
>> src/svc_auth_gss.c |   14 +++++++-------
>> 1 files changed, 7 insertions(+), 7 deletions(-)
>>
>> diff --git a/src/svc_auth_gss.c b/src/svc_auth_gss.c
>> index 601a691..26c1065 100644
>> --- a/src/svc_auth_gss.c
>> +++ b/src/svc_auth_gss.c
>> @@ -286,21 +286,19 @@ svcauth_gss_validate(struct svc_rpc_gss_data *gd, struct rpc_msg *msg)
>> 	struct opaque_auth	*oa;
>> 	gss_buffer_desc		 rpcbuf, checksum;
>> 	OM_uint32		 maj_stat, min_stat, qop_state;
>> -	u_char			 rpchdr[128];
>> +	u_char			 *rpchdr;
>> 	int32_t			*buf;
>>
>> 	gss_log_debug("in svcauth_gss_validate()");
>>
>> -	memset(rpchdr, 0, sizeof(rpchdr));
>> -
>> 	/* XXX - Reconstruct RPC header for signing (from xdr_callmsg). */
>> 	oa = &msg->rm_call.cb_cred;
>> 	if (oa->oa_length > MAX_AUTH_BYTES)
>> 		return (FALSE);
>> -	
>> -	/* 8 XDR units from the IXDR macro calls. */
>> -	if (sizeof(rpchdr) < (8 * BYTES_PER_XDR_UNIT +
>> -			RNDUP(oa->oa_length)))
>> +
>> +	rpchdr = (u_char *)calloc(((8 * BYTES_PER_XDR_UNIT) + 
>> +			RNDUP(oa->oa_length)), 1);
>> +	if (rpchdr == NULL)
>> 		return (FALSE);
>>
>> 	buf = (int32_t *)rpchdr;
>> @@ -325,6 +323,8 @@ svcauth_gss_validate(struct svc_rpc_gss_data *gd, struct rpc_msg *msg)
>> 	maj_stat = gss_verify_mic(&min_stat, gd->ctx, &rpcbuf, &checksum,
>> 				  &qop_state);
>>
>> +	free(rpchdr);
>> +
>> 	if (maj_stat != GSS_S_COMPLETE) {
>> 		gss_log_status("gss_verify_mic", maj_stat, min_stat);
>> 		return (FALSE);
>> -- 
>> 1.7.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
