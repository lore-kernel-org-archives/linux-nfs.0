Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58687 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755288Ab1HRQnL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Aug 2011 12:43:11 -0400
Date: Thu, 18 Aug 2011 12:43:07 -0400
To: NeilBrown <neilb@suse.de>
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: Problems with kerberos auth - possibly against ADS - since
 nfs-utils-1.2.3
Message-ID: <20110818164307.GA24533@fieldses.org>
References: <20110804092141.3461c9ce@notabene.brown>
 <CAKnQG+cs4SLD-YmLwpnXU_gDWrjfmx9+z-E=7J-SUcsP=KhfSg@mail.gmail.com>
 <20110804111357.0d0a6e85@notabene.brown>
 <CAKnQG+dViSmrjhZV1cFZHj98kM0ixyKRLek9OWkJjFUS6YO3cw@mail.gmail.com>
 <20110811154239.322dee1d@notabene.brown>
 <CAKnQG+eV_OCk60wN6E2ub-TxA+6NoALYn8C+1PD51fWUZTpcGQ@mail.gmail.com>
 <20110818191906.13a6261f@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110818191906.13a6261f@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 18, 2011 at 07:19:06PM +1000, NeilBrown wrote:
> I think that does exactly describes what we were seeing.
> We ended up working around it by adding 
> 
>   default_tkt_enctypes = des-cbc-md5 des-cbc-crc des3-cbc-sha1
> 
> to the client config, and recommending a server upgrade.
> 
> 
> BTW I've been trying to track down why a successful kerberos negotiation
> sends a corrupted RPCSEC_GSS_DESTROY request just before closing the
> connection.

(No useful comment here, just: thanks!  That was driving me crazy, till
it just stopped happening for no apparent reason, before I got a chance
to look any closer...)

--b.

> 
> There are two issues here.
> 1/ Why is it trying to send a DESTROY request
> 2/ Why is it corrupted.
> 
> It is just as well that it is corrupted else the server would forget the
> session that has just been negotiated.
> 
> It is sending a DESTROY request because that is what AUTH_DESTROY called in
> gssd_proc does.  But it shouldn't.  After a call to
> authgss_get_private_data() the context is owned by someone else so
> AUTH_DESTROY should free the memory, but not DESTROY anything on the server.
> 
> I think authgss_get_private_data should clear gd->established or possibly 
> gd->gc.gc_ctx.length so there is no attempt to use or destroy the auth internally
> any more.
> 
> But why is it corrupted?  This is because the internal_ctx_id in the gssglue
> layer has been zeroed by the call to authgss_get_private_data.  I couldn't
> easily see in the code where this is happening, but tracing confirms that it
> does.  A NULL internal_ctx_id doesn't stop authgss_destroy_context from
> trying to destroy the context, but it does stop it from succeeding.
> 
> So I suspect all we need to do to address this is change
> authgss_get_private_data to set gd->gc.gc_ctx.length to zero.
> 
> Does that seem reasonable to you?
> 
> 
> Thanks,
> NeilBrown
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
