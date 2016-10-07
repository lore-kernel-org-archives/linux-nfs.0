Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33360 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753988AbcJGV2R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Oct 2016 17:28:17 -0400
Date: Fri, 7 Oct 2016 17:28:16 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: audit of the use of SVC_DROP in server reply path
Message-ID: <20161007212816.GA27509@fieldses.org>
References: <B5EAA4EA-81E3-4F57-9899-951F2A8180B3@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <B5EAA4EA-81E3-4F57-9899-951F2A8180B3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apologies for the delayed response:

On Tue, Sep 13, 2016 at 11:42:37AM -0400, Chuck Lever wrote:
> I think the two interesting cases are svc_set_client and svc_authorise.
> 
> Who does a "goto dropit;" inside svc_process_common?
> 
> 	• svc_set_client returns SVC_DROP
> 		• When svcauth_gss_set_client calls svc_unix_set_client, which can return SVC_DROP
> 			• When svc_unix_set_client calls cache_check, and it returns -EAGAIN
> 			• When svc_unix_set_client calls unix_gid_find, and it returns -EAGAIN

These should still result in a silent drop, since in these places we're
still planning to reply--only after deferring and then revisiting the
request later.  (Though it might be worth verifying that there aren't
any weird subcases where that isn't the case.)

> 		• svcauth_gss_accept
> 			• when gc_proc == RPC_GSS_PROC_DATA or RPC_GSS_PROC_DESTROY, and gss_check_seq_num fails

This is the case that was causing us trouble.  Should be a close.

> 			• when gc_proc == RPC_GSS_PROC_DESTROY and the result length is larger than a page

We're never going to reply, so close.

> 	• pc_func returns rpc_drop_reply - only used by NLM

Looks like this might happen in some cases on open?  (Delegation
conflict, or export lookup?  I'm not sure.)  In any case, this is NLM,
which I'm guessing can deal with us either closing or not.  Or in
asynchronous lock case, where I think a reply will be sent later.

> 	• vs_dispatch returns 0
> 		• When nfsd_cache_lookup returns RC_DROPIT (the RPC is already in progress, or the client has retransmitted too soon): the server is going to reply anyway, safe to drop

Agreed.

> 		• pc_func returns nfserr_dropit (NFSv2's JUKEBOX)

I assume as in the NLM case that either behavior's OK; do we have a
reason to prefer one or the other?

> 		• RQ_DROPME is set (deferred requests?)

Yes.  So, drop and don't close.

> 	• pc_encode is NULL - probably rare and inconsequential
> 	• svc_authorise returns non-zero
> 		• svcauth_gss_release returns a negative errno when integrity or privacy reply wrapping fails; i think this needs a connection reset
> 	• incoming RPC header is shorter than 24 bytes - connection reset would be better here anyway, IMO

Agreed.

> The question I have is what does SVC_CLOSE mean for a UDP transport?

Hm.  svc_close_xprt->svc_delete_xprt->
		xpo_detach->svc_sock_detach->release_sk()

Uh, I don't know what exactly that does in the udp case.

Anyway, I guess a pretty good rule is that we want to close whenever
there's not a reply pending, so basically whenever we're not doing the
deferred request thing.  Might be simpler to make that logic explicit by
returning one error in both cases and letting svc_process_common decide
which case we're in by checking whether there's a deferred request.
(Haven't checked how to do that.)

--b.
