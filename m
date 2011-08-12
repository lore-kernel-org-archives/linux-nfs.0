Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:65287 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847Ab1HLOIE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Aug 2011 10:08:04 -0400
Received: by mail-pz0-f42.google.com with SMTP id 37so1212454pzk.1
        for <linux-nfs@vger.kernel.org>; Fri, 12 Aug 2011 07:08:03 -0700 (PDT)
In-Reply-To: <20110812021556.GD9761@pad.fieldses.org>
References: <4E44790A.8000106@panasas.com>
	<4E447EEB.501@panasas.com>
	<4E4481F0.2050806@panasas.com>
	<20110812021556.GD9761@pad.fieldses.org>
Date: Fri, 12 Aug 2011 10:08:03 -0400
Message-ID: <CAMeBU_28VPCtExvU1gr3oTbLLyqp=qFwFjxehoea64Xqi=_ncQ@mail.gmail.com>
Subject: Re: Grace period NEVER ends
From: Casey Bodley <cbodley@citi.umich.edu>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 11, 2011 at 10:15 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> On Thu, Aug 11, 2011 at 06:29:20PM -0700, Boaz Harrosh wrote:
>> With this patch I'm back to the previous behavior. That is
>> wait your grace period then continue.
>
> Is it true for some reason that the client never sends RECLAIM_COMPLETE?

I tested this yesterday with the windows client and saw the same
never-ending grace period on OPEN.  We do send RECLAIM_COMPLETE, and
it completes successfully.  Other operations like CREATE and REMOVE
succeed as well.

>
> --b.
>
>>
>> ---
>> NFSD: Remove a wrong check in nfs4_open
>>
>> We are already doing the proper grace period checking
>> farther down in nfs4_open. This check was just checking
>> nothing and was totally unrelated to the comment about
>> "RECLAIM_COMPLETE". It was a bug because if an open was
>> coming before the grace period end, it would then never
>> pass the condition of not being cl_firststate.
>>
>> Boaz
>>
>> ---
>> @@ -295,15 +295,6 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>       if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
>>               return nfserr_inval;
>>
>> -     /*
>> -      * RFC5661 18.51.3
>> -      * Before RECLAIM_COMPLETE done, server should deny new lock
>> -      */
>> -     if (nfsd4_has_session(cstate) &&
>> -         !cstate->session->se_client->cl_firststate &&
>> -         open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
>> -             return nfserr_grace;
>> -
>>       if (nfsd4_has_session(cstate))
>>               copy_clientid(&open->op_clientid, cstate->session);
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
