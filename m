Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762AbbDBSyg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2015 14:54:36 -0400
Message-ID: <1428000873.2973.12.camel@deneb.redhat.com>
Subject: Re: userspace breakage in linux/nfsd/debug.h
From: Mark Salter <msalter@redhat.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Jeff Layton <jlayton@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 02 Apr 2015 14:54:33 -0400
In-Reply-To: <20150402135323.18416d48@tlielax.poochiereds.net>
References: <1427985766.2973.11.camel@deneb.redhat.com>
	 <20150402115813.6abf5596@tlielax.poochiereds.net>
	 <20150402135323.18416d48@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2015-04-02 at 13:53 -0400, Jeff Layton wrote:
> On Thu, 2 Apr 2015 11:58:13 -0400
> Jeff Layton <jeff.layton@primarydata.com> wrote:
> 
> > On Thu, 02 Apr 2015 10:42:46 -0400
> > Mark Salter <msalter@redhat.com> wrote:
> > 
> > > This patch:
> > > 
> > >   commit f895b252d4edf66b2895fb5a7b17a638665f3e1f
> > >   Author: Jeff Layton <jlayton@primarydata.com>
> > >   Date:   Mon Nov 17 16:58:04 2014 -0500
> > > 
> > >     sunrpc: eliminate RPC_DEBUG
> > >     
> > >     It's always set to whatever CONFIG_SUNRPC_DEBUG is, so just use that.
> > >     
> > >     Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > >     Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > > 
> > > breaks userspace use of linux/nfsd/debug.h because of:
> > > 
> > >   diff --git a/include/uapi/linux/nfsd/debug.h b/include/uapi/linux/nfsd/debug.h
> > >   index a6f453c..1fdc95b 100644
> > >   --- a/include/uapi/linux/nfsd/debug.h
> > >   +++ b/include/uapi/linux/nfsd/debug.h
> > >   @@ -15,7 +15,7 @@
> > >     * Enable debugging for nfsd.
> > >     * Requires RPC_DEBUG.
> > >     */
> > >   -#ifdef RPC_DEBUG
> > >   +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> > >    # define NFSD_DEBUG		1
> > >    #endif
> > >  
> > > IS_ENABLED() is not available outside the kernel and causes a compile
> > > time failure:
> > > 
> > >   /usr/include/linux/nfsd/debug.h:18:15: error: missing binary operator before token "("
> > >  #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> > > 
> > > 
> > > 
> > 
> > Huh, ok. Probably the right solution is to just get rid of NFSD_DEBUG
> > and convert all of the "#ifdef NFSD_DEBUG" statements into 
> > "#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)".
> > 
> > Then we can just remove that whole block from nfsd/debug.h altogether. Mike,
> > care to spin up a patch for that or shall I?
> > 
> 
> Uhh, sorry...I meant to say "Mark" there.
> 
> Mark, would you mind spinning up a patch for this or would you rather I
> do it?
> 
> Thanks,

I was wondering who Mike was. :)
Yeah, I can put a patch together.


