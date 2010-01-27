From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 5/5] NFSD: Create PF_INET6 listener in write_ports
Date: Wed, 27 Jan 2010 17:04:17 -0500
Message-ID: <20100127220417.GE18278@fieldses.org>
References: <20100126190214.3368.89388.stgit@localhost.localdomain> <20100126190422.3368.3981.stgit@localhost.localdomain> <20100126233019.GB806@fieldses.org> <09BF8C67-D7AA-4BBF-B310-5BBF7A4DA057@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53332 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756146Ab0A0WCm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jan 2010 17:02:42 -0500
In-Reply-To: <09BF8C67-D7AA-4BBF-B310-5BBF7A4DA057@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 27, 2010 at 04:18:45PM -0500, Chuck Lever wrote:
>
> On Jan 26, 2010, at 6:30 PM, J. Bruce Fields wrote:
>> Any objection to moving the extra error-handling to the end, as in the
>> following?  If there's no objection, I'll fold it into your last  
>> patch.
>
> I guess that's fine, but out_close: would be more succinct than  
> out_err_cleanup_inet, and somewhat more conventional.

Agreed, thanks.  Applied, with that change.

--b.

>
>> --b.
>>
>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>> index f0a614e..f4474e5 100644
>> --- a/fs/nfsd/nfsctl.c
>> +++ b/fs/nfsd/nfsctl.c
>> @@ -988,6 +988,7 @@ static ssize_t __write_ports_delfd(char *buf)
>> static ssize_t __write_ports_addxprt(char *buf)
>> {
>> 	char transport[16];
>> +	struct svc_xprt *xprt;
>> 	int port, err;
>>
>> 	if (sscanf(buf, "%15s %4u", transport, &port) != 2)
>> @@ -1007,18 +1008,15 @@ static ssize_t __write_ports_addxprt(char  
>> *buf)
>>
>> 	err = svc_create_xprt(nfsd_serv, transport,
>> 				PF_INET6, port, SVC_SOCK_ANONYMOUS);
>> -	if (err < 0 && err != -EAFNOSUPPORT) {
>> -		struct svc_xprt *xprt;
>> -		xprt = svc_find_xprt(nfsd_serv, transport, PF_INET, port);
>> -		if (xprt != NULL) {
>> -			svc_close_xprt(xprt);
>> -			svc_xprt_put(xprt);
>> -		}
>> -		goto out_err;
>> -	}
>> -
>> +	if (err < 0 && err != -EAFNOSUPPORT)
>> +		goto out_err_cleanup_inet;
>> 	return 0;
>> -
>> +out_err_cleanup_inet:
>> +	xprt = svc_find_xprt(nfsd_serv, transport, PF_INET, port);
>> +	if (xprt != NULL) {
>> +		svc_close_xprt(xprt);
>> +		svc_xprt_put(xprt);
>> +	}
>> out_err:
>> 	/* Decrease the count, but don't shut down the service */
>> 	nfsd_serv->sv_nrthreads--;
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
