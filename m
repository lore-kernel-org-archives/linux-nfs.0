Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:37682 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754605Ab0ECNx2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 May 2010 09:53:28 -0400
Date: Mon, 3 May 2010 15:47:36 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] use negative cache for Kerberos credentials
Message-ID: <20100503134736.GA18765@ics.muni.cz>
References: <20100316115439.GX19154@ics.muni.cz>
 <1268745962.3155.25.camel@localhost.localdomain>
 <20100316162738.GD19154@ics.muni.cz>
 <1268758702.3098.8.camel@localhost.localdomain>
 <20100322094731.GO18907@ics.muni.cz>
 <1269271124.3496.4.camel@localhost.localdomain>
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <1269271124.3496.4.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

On Mon, Mar 22, 2010 at 11:18:44AM -0400, Trond Myklebust wrote:
> We already have code in nfs4proc.c for handling EKEYEXPIRED, and that
> delays the request before allowing it to retry. What I was proposing was
> negative caching, so that if some other process comes along and tries to
> do an upcall, the RPC code just immediately returns EKEYEXPIRED instead
> of asking gssd again.
> 
> Something like the following (still untested) patch.

we tested the patch and found the following.

Assume, we mounted NFS volume somewhere, we are non root user and we have
valid kerberos ticket. We access the volume. 

The following sequence of procedures is called:

gss_lookup_cred - search, whether we have the ticket
gss_cred_init - create a new ticket into cache (according to
gss_pipe_downcall)
gss_pip_downcall - calls rpc.gssd
gss_marchal
gss_wrap_req
gss_validate
gss_unwrap_resp
nfs4_handle_exception: 0 - OK, we got the ticket

If the ticket is valid and has been found in cache:
gss_lookup_cred
gss_match
gss_wrap_req
gss_validate
gss_unwrap_resp
nfs4_handle_exception: 0 - OK, we got the ticket

Now, the ticket expired.

gss_lookup_cred
gss_match
gss_marshal
gss_wrap_req
gss_refresh
gss_renew_cred
gss_lookup_cred
gss_match
gss_match
gss_destroy_cred
gss_pipe_downcall
gss_destroy_cred
nfs4_handle_exeption: ticket expired

second try to access NFS with an expired ticket

gss_lookup_cred
gss_cred_init
gss-pipe_downcall
gss_destroy_cred
nfs4_handle_exception: ticket expired

another try, no gss_refresh is called until a new ticket is available.

Your patch seems the gss_refresh to be called to work properly.

So, the first process accessing the NFS volume without ticket gets stopped.
But the others are not. 

And there is no difference how many times the application tried to access the
NFS4 volume.

I think, it is useful if you do:
ls /mnt/nfs4
return immediately if you don't have a ticket or the ticked is expired.

But if the application spin fast, stop it. 

What is your opinion how to solve this?

We are thinking about to move the negative cache into another function, i.e.,
the function that gets called. Or create different negative cache for this
purpose. Or fill fake tickets into cache and catch them.

What's your idea? We can develop it but we are not about to develop something
that would be refused as our previous work.

-- 
Luká¹ Hejtmánek
