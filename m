From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 02/11] nfsd4: move callback setup into session init code
Date: Wed, 27 Oct 2010 20:03:01 +0200
Message-ID: <4CC86955.9080209@panasas.com>
References: <1287678018-9266-1-git-send-email-bfields@redhat.com> <1287678018-9266-3-git-send-email-bfields@redhat.com> <4CC860C2.2050101@panasas.com> <4CC8654D.7050003@panasas.com> <20101027175951.GB18974@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og108.obsmtp.com ([64.18.0.186]:56520 "HELO
	exprod5og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753837Ab0J0SDG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 14:03:06 -0400
In-Reply-To: <20101027175951.GB18974@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-10-27 19:59, J. Bruce Fields wrote:
> On Wed, Oct 27, 2010 at 07:45:49PM +0200, Benny Halevy wrote:
>> On 2010-10-27 19:26, Benny Halevy wrote:
>>> On 2010-10-21 18:20, J. Bruce Fields wrote:
>>>> From: J. Bruce Fields <bfields@citi.umich.edu>
>>>>
>>>> The backchannel should  be associated with a session, it isn't really
>>>> global to the client.
>>>>
>>>> We do, however, want a pointer global to the client which tracks which
>>>> session we're currently using for client-based callbacks.
>>>>
>>>> This is a first step in that direction; for now, just reshuffling of
>>>> code with no significant change in behavior.
>>>>
>>>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>>>> ---
>>>>  fs/nfsd/nfs4state.c |   29 ++++++++++++++---------------
>>>>  fs/nfsd/state.h     |    1 +
>>>>  2 files changed, 15 insertions(+), 15 deletions(-)
>>>>
>>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>>> index 7f12828..db5d8c8 100644
>>>> --- a/fs/nfsd/nfs4state.c
>>>> +++ b/fs/nfsd/nfs4state.c
>>>> @@ -771,6 +771,19 @@ static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp
>>>>  		free_session(&new->se_ref);
>>>>  		return nfserr_jukebox;
>>>>  	}
>>>> +	if (!clp->cl_cb_session && (cses->flags & SESSION4_BACK_CHAN)) {
>>>> +		struct sockaddr *sa = svc_addr(rqstp);
>>>> +
>>>> +		clp->cl_cb_session = new;
>>>> +		clp->cl_cb_conn.cb_xprt = rqstp->rq_xprt;
>>>> +		svc_xprt_get(rqstp->rq_xprt);
>>>> +		rpc_copy_addr((struct sockaddr *)&clp->cl_cb_conn.cb_addr, sa);
>>>> +		clp->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
>>>> +		clp->cl_cb_conn.cb_minorversion = 1;
>>>> +		clp->cl_cb_conn.cb_prog = cses->callback_prog;
>>>> +		clp->cl_cb_seq_nr = 1;
>>>> +		nfsd4_probe_callback(clp, &clp->cl_cb_conn);
>>>> +	}
>>>
>>> 	else
>>> 		cses->flags &= ~SESSION4_BACK_CHAN;
>>>
>>> We need that for returning the right value in csr_flags
>>
>> Though after "nfsd4: track backchannel connections",
>> we mark the connection correctly.
>> Too late to worry about bisectibility now :)
> 
> Erp, yes.  We should try to coordinate review better, apologies if I
> haven't been leaving enough time.  Let me know if you catch anything
> else.

My bad.  Sorry for being so slow in my response.

Benny

> 
> --b.
