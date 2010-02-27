From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH] sunrpc: remove unnecessary svc_xprt_put
Date: Fri, 26 Feb 2010 18:40:58 -0600
Message-ID: <4B886A1A.7060106@opengridcomputing.com>
References: <19336.19524.469529.431210@notabene.brown> <20100226225416.GF26598@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:57581 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966718Ab0B0Ak7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Feb 2010 19:40:59 -0500
In-Reply-To: <20100226225416.GF26598@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Sat, Feb 27, 2010 at 09:33:40AM +1100, Neil Brown wrote:
>   
>> [I found this while looking for the current refcount problem
>>  that triggers a warning in svc_recv.  This isn't that bug
>>  but is a different refcount bug - NB]
>>     
>
>   

I seem to recall that we added that reference for  a reason. There was 
an issue with unmount while there were deferrals pending. That's why the 
reference was added.

Tom

> And thanks very much for looking into that, I'm worried....  Seems to
> have appeared some time between v2.6.31 and v2.6.32.2.  On a quick skim
> commits in that range that struck me as worth a second look included
> 8f55f3c0a013, b0401d725334, and the 4.1 backchannel patches (3ddc8bf5f3
> and preceding).
>
> Oh, and I also have some very rough notes from when I looked at this
> before, in case there's anything useful.
>
> --b.
>
> Re: 2.6.32.2 - WARNING: at lib/kref.c:43 kref_get+0x,23/0x2b()
>
> Seen on: 2.6.32.2, 2.6.32.6, 2.6.32.8; probably was OK on 2.6.29.6 and
> 2.6.31.
>
> Is the warning actually warning about anything that's a problem, or can
> that counter by zero by design?  Yes, it's actually a problem.
>
> Is probably svc_xprt_get(xprt) in svc_recv() (only obvious kref_get I
> found on a quick glance through svc_recv).
> 	Double-check:
> 		svc_recv+0x305/0x7e6
> 		Note next bug is on putting a socket (that we probably
> 		shouldn't have!?):
> 			- BUG_ON(inode->i_state == I_CLEAR).
> 			- Implies clear_inode() was previously called on
> 			  it.
> 			- stack includes kref_put() call in
> 			  svc_xprt_release, which is indeed put of same
> 			  xpt_ref field that svc_xprt_get() gets.
>
> So, most probably explanation:
> 	- We still had a dangling reference to an xprt after putting
> 	  one.  So we ended up doing another get/put pair on it later
> 	  and trying to free the same socket twice.
>
> So, plan: look for svc_xprt_puts (after checking for other stray uses of
> xpt_ref) and verify that they're all legit.  And gets while we're at it:
>
> 	Ignore svc_rdma for now.  Those reporters that answered weren't
> 	using rdma.
>
> Most puts outside of rdma are in svc_xprt.c:
>
> 	- svc_xprt_release (unconditional): 0 to caller (put matched
> 	  	with removal from rq_xprt)
> 	- svc_check_conn_limits(): 0 to caller
> 		- takes an xprt off a sv_tempsocks list, gets it (and
> 		  sets XPT_CLOSE) before dropping sv_lock, then enqueues
> 		  and puts.  (Note: enqueue will get, and assign to
> 		  rq_xprt, if thread found.)
> 	- svc_age_temp_xprts: 0 to caller
> 		- same pattern as svc_check_conn_limits().
> 	- svc_delete_xprt: 0 to caller (put matched with removal from
> 	  xpt_list)
> 		- if test_and_set_bit of XPT_DEAD succeeds, will
> 		  svc_xprt_put(), after calling xpo_detach, then (under
> 		  sv_lock) removing xpt_list.
> 		- ALSO unconditionally puts once for each deferred
> 		  request it finds associated with this request.  Is
> 		  that right? Yup: svc_defer() gets on success, when
> 		  assigning dr->xprt.
> 	- svc_close_xprt:
> 		- sets XPT_CLOSE, then if test_and_set_bit of XPT_BUSY
> 		  succeeds, gets xprt, deletes, clears BUSY, puts.
> 	- revisit:
> 		- puts associated xprt unconditionally.
>
> 	Also some puts are in fs/nfsd/nfsctl.c, fs/nfsd/nfs4state.c,
> 	fs/lockd/svc.c:
>
> 	nfsctl.c:
> 		ifs/nfsd/nfsctl.c:__write_ports_delxprt():
> 			- svc_find_xprt() gets a reference; if found:
> 			  svc_close_xprt, svc_xprt_put.  OK.
> 	nfs4state.c:
> 		free_client: svc_xprt_put(clp->cl_cb_xprt);
> 		Looks basically correct: we take reference when we
> 		assign that in nfsd4_create_session.
>
> 		Hm.  Note we copy pointer to clp->cl_cb_xprt without
> 		taking reference?  The client holds a reference,
> 		though.  Looking at cb_xprt use in client xprt code, I
> 		can't see any references taken or dropped.  This all
> 		looks fine.
>
> 	lockd/svc.c: create_lock_listener() looks innocuous.
>   

