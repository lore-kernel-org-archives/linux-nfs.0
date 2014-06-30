Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:39555 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbaF3K7Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 06:59:16 -0400
Received: by mail-qg0-f45.google.com with SMTP id a108so1763578qge.32
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 03:59:15 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 30 Jun 2014 06:59:13 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 022/117] nfsd: Cache the client that was looked up in
 lookup_clientid()
Message-ID: <20140630065913.2fe89c25@f20.localdomain>
In-Reply-To: <20140630103453.GB22010@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<1403810017-16062-23-git-send-email-jlayton@primarydata.com>
	<20140629121419.GC16150@infradead.org>
	<20140629105702.2ca9e6ee@f20.localdomain>
	<20140630103453.GB22010@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Jun 2014 03:34:53 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Sun, Jun 29, 2014 at 10:57:02AM -0400, Jeff Layton wrote:
> > Depends on what you mean by "normal case". For v4.0 we do look it up at
> > least once for each call into here. For v4.1 we get the pointer to the
> > client "for free" by virtue of looking up the session in the SEQUENCE
> > op. So, I think we are doing a bit more than just verifying the
> > clientid here. The name seems appropriate to me.
> 
> So everything but the first call for 4.0 is just a small verification.
> I'm not going to hold up the series for something as trivial, but the
> name still smells a little..
> 

Fair enough. The "verify" name smells to me a little since we aren't
guaranteed to have one when the function is called. "lookup" seems
reasonable since we are looking it up, it's just that once this patch
goes in we'll usually have it cached in the cstate.

> > > While it doesn't belong into this patch:  why don't we cache the
> > > nfsd_net in the nfsd4_compound_state
> > > 
> > 
> > I'll go further and say that it doesn't really belong in this
> > series.
> 
> Anything we can keep out of this series is good, agreed..
> 
> > There are certain calls that don't require a SEQUENCE operation:
> > 
> >     BIND_CONN_TO_SESSION
> >     EXCHANGE_ID
> >     CREATE_SESSION
> >     DESTROY_SESSION
> > 
> > Granted, for those we don't use lookup_clientid but the "Usually"
> > still applies, in general. That said, if it bothers you I'll remove
> > it.
> 
> my major issue is the combination of the usually with this:
> 
> > > > +		 * if we don't have one cached already then we
> > > > know this is for
> > > > +		 * is for v4.0 and "sessions" will be false.
> 
> so we can have a case where we are 4.1 but don't have a cached
> session. This is getting into deep nitpick land, but comments that
> aren't entirely coherent always confuse me.
> 

Ok, that's understandable. How about this?

+       /*
+        * For v4.1+ we get the client in the SEQUENCE op. If we don't have one
+        * cached already then we know this is for is for v4.0 and "sessions"
+        * will be false.
+        */
+       found = find_confirmed_client(clid, false, nn);

FWIW, the main reason for the comment is to explain why we're
hardcoding the "session" arg to false here instead of using
cstate->session.

-- 
Jeff Layton <jlayton@primarydata.com>
