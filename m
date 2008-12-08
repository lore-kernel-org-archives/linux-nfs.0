From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: possible module refcount leak with auth_gss
Date: Mon, 8 Dec 2008 12:37:06 -0500
Message-ID: <20081208173706.GE16628@fieldses.org>
References: <20081208102855.30081708@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42741 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865AbYLHRhH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2008 12:37:07 -0500
In-Reply-To: <20081208102855.30081708-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 08, 2008 at 10:28:55AM -0500, Jeff Layton wrote:
> We had someone report a bug against Fedora that they were seeing very
> high module reference counts for some krb5 related modules on his nfs
> server. For instance:
> 
> # lsmod
> Module                  Size  Used by
> des_generic            25216  52736 
> cbc                    12160  52736 
> rpcsec_gss_krb5        15632  26370 
> 
> ...the cbc and des_generic each have roughly 2 module references per
> rpcsec_gss_krb5 refcount so I'm assuming that the "lynchpin" here is
> the rpcsec_gss_krb5 refcount which seems to be increasing w/o bound.

You may want to see this discussion:

	http://marc.info/?t=122819524700001&r=1&w=2

And these patches:

	http://marc.info/?l=linux-nfs&m=122843371318602&w=2

In addition to increasing the timeouts on those cache entries, perhaps
we could flush the contexts on rmmod?  Or change the reference counting
somehow--e.g., take a reference only in the presence of export cache
entries that mention krb5, and destroy contexts when the last such goes
away?

Also to check: a recent client should be sending destroy_ctx calls on
unmount, and a recent server should be acting on them.  Perhaps there's
a bug there.  I'd do an unmount, watch the wire to make sure the
destroy_ctx calls are really going across (they'll look like NFSv4 NULL
calls, with the interesting fields in the cred in the rpc header).  Then
take a close look at the destroy_ctx code (see the second occurence of
RPC_GSS_PROC_DESTROY in svcauth_gss_accept(), around line 1126).

--b.

> 
> I've been able to reproduce this fairly easily by setting up a nfs
> server with a krb5 authenticated export. If I then mount that and
> immediately unmount it from a client, the refcount on rpcsec_gss_krb5 on
> the server increases by 1. For instance:
> 
> First mount and unmount:
> Module                  Size  Used by
> cbc                    12288  2 
> rpcsec_gss_krb5        19208  1 
> des_generic            25344  2 
> 
> Second mount and unmount:
> Module                  Size  Used by
> cbc                    12288  4 
> rpcsec_gss_krb5        19208  2 
> des_generic            25344  4 
> 
> Third mount and unmount:
> Module                  Size  Used by
> cbc                    12288  6 
> rpcsec_gss_krb5        19208  3 
> des_generic            25344  6 
> 
> ...while that's an easy way to reproduce it, there may be other ways to
> make it grow.
> 
> Some printk debugging shows that the references are increased as a
> result of rsc_parse(). From my (rather naive) look at this code, it
> looks like each entry in the rsc_cache holds a module reference.
> 
> I'm guessing that when these cache entries are released that the module
> references also get released, but I haven't been successful in making
> that occur. It seems like the module references are never put, so either
> the entries are never getting flushed out of the cache or the module
> references aren't being properly released by this code. There's no
> "content" file for this cache though, so it's hard to tell whether the
> cache is populated at any given time.
> 
> Either way, this seems likely to be a bug. There doesn't seem to be a
> way to make the refcounts go down again once they've been increased. Can
> anyone confirm whether this is working as intended? If not, do you have
> any idea where the problem may be, or how to approach tracking this
> down? Unfortunately, I'm finding this code to be very hard to follow.
> 
> Any help or suggestions appreciated...
> 
> Thanks,
> -- 
> Jeff Layton <jlayton@redhat.com>
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
