Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39202 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754926AbcJMNuU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Oct 2016 09:50:20 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: audit of the use of SVC_DROP in server reply path
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20161007212816.GA27509@fieldses.org>
Date: Thu, 13 Oct 2016 09:50:07 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D9C0069A-36F9-4021-A692-BFF3312286C9@oracle.com>
References: <B5EAA4EA-81E3-4F57-9899-951F2A8180B3@oracle.com> <20161007212816.GA27509@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 7, 2016, at 5:28 PM, Bruce Fields <bfields@fieldses.org> wrote:
> 
> Apologies for the delayed response:
> 
> On Tue, Sep 13, 2016 at 11:42:37AM -0400, Chuck Lever wrote:
>> I think the two interesting cases are svc_set_client and svc_authorise.
>> 
>> Who does a "goto dropit;" inside svc_process_common?
>> 
>> 	• svc_set_client returns SVC_DROP
>> 		• When svcauth_gss_set_client calls svc_unix_set_client, which can return SVC_DROP
>> 			• When svc_unix_set_client calls cache_check, and it returns -EAGAIN
>> 			• When svc_unix_set_client calls unix_gid_find, and it returns -EAGAIN
> 
> These should still result in a silent drop, since in these places we're
> still planning to reply--only after deferring and then revisiting the
> request later.  (Though it might be worth verifying that there aren't
> any weird subcases where that isn't the case.)
> 
>> 		• svcauth_gss_accept
>> 			• when gc_proc == RPC_GSS_PROC_DATA or RPC_GSS_PROC_DESTROY, and gss_check_seq_num fails
> 
> This is the case that was causing us trouble.  Should be a close.

My original patch makes this change.


>> 			• when gc_proc == RPC_GSS_PROC_DESTROY and the result length is larger than a page
> 
> We're never going to reply, so close.

Add a hunk to make a similar change here?


>> 	• pc_func returns rpc_drop_reply - only used by NLM
> 
> Looks like this might happen in some cases on open?  (Delegation
> conflict, or export lookup?  I'm not sure.)  In any case, this is NLM,
> which I'm guessing can deal with us either closing or not.  Or in
> asynchronous lock case, where I think a reply will be sent later.
> 
>> 	• vs_dispatch returns 0
>> 		• When nfsd_cache_lookup returns RC_DROPIT (the RPC is already in progress, or the client has retransmitted too soon): the server is going to reply anyway, safe to drop
> 
> Agreed.
> 
>> 		• pc_func returns nfserr_dropit (NFSv2's JUKEBOX)
> 
> I assume as in the NLM case that either behavior's OK; do we have a
> reason to prefer one or the other?
> 
>> 		• RQ_DROPME is set (deferred requests?)
> 
> Yes.  So, drop and don't close.
> 
>> 	• pc_encode is NULL - probably rare and inconsequential
>> 	• svc_authorise returns non-zero
>> 		• svcauth_gss_release returns a negative errno when integrity or privacy reply wrapping fails; i think this needs a connection reset

Another hunk to change this case to SVC_CLOSE?


>> 	• incoming RPC header is shorter than 24 bytes - connection reset would be better here anyway, IMO
> 
> Agreed.

And one more for this one?


>> The question I have is what does SVC_CLOSE mean for a UDP transport?
> 
> Hm.  svc_close_xprt->svc_delete_xprt->
> 		xpo_detach->svc_sock_detach->release_sk()
> 
> Uh, I don't know what exactly that does in the udp case.
> 
> Anyway, I guess a pretty good rule is that we want to close whenever
> there's not a reply pending, so basically whenever we're not doing the
> deferred request thing.  Might be simpler to make that logic explicit by
> returning one error in both cases and letting svc_process_common decide
> which case we're in by checking whether there's a deferred request.
> (Haven't checked how to do that.)

That seems like a more risky change.


--
Chuck Lever



