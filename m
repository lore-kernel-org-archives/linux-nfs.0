Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43362 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751105AbeCTOt2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Mar 2018 10:49:28 -0400
Date: Tue, 20 Mar 2018 10:49:28 -0400
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "bfields@redhat.com" <bfields@redhat.com>,
        "dhowells@redhat.com" <dhowells@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 10/10] nfsd: clients don't need to break their own
 delegations
Message-ID: <20180320144928.GA4288@fieldses.org>
References: <1521470194-24840-11-git-send-email-bfields@redhat.com>
 <1521470194-24840-1-git-send-email-bfields@redhat.com>
 <29167.1521552951@warthog.procyon.org.uk>
 <1521553578.10293.4.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1521553578.10293.4.camel@primarydata.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 20, 2018 at 01:46:20PM +0000, Trond Myklebust wrote:
> On Tue, 2018-03-20 at 13:35 +0000, David Howells wrote:
> > J. Bruce Fields <bfields@redhat.com> wrote:
> > 
> > > @@ -139,6 +139,9 @@ struct cred {
> > >  	struct key	*thread_keyring; /* keyring private to
> > > this thread */
> > >  	struct key	*request_key_auth; /* assumed
> > > request_key authority */
> > >  #endif
> > > +#ifdef CONFIG_FILE_LOCKING
> > > +	void		*lease_breaker; /* identify NFS client
> > > breaking a delegation */
> > > +#endif
> > >  #ifdef CONFIG_SECURITY
> > >  	void		*security;	/* subjective LSM
> > > security */
> > >  #endif
> > 
> > Sorry, but ewww.
> > 
> > Two reasons for that comment:
> > 
> >  (1) The cred struct may get retained long past where you expect if
> > it gets
> >      attached to another process or a file descriptor.
> > 
> >  (2) The ->lease_breaker pointer needs lifetime management in
> > cred.c.  It will
> >      potentially get copied around and may need cleaning up.
> > 
> > Can you stick your breaker identity in a key struct as Jeff
> > suggested?
> > 
> 
> Bruce,
> 
> Do you really need to do more than just identify that this is a knfsd
> thread vs not a knfsd thread? I'm assuming that a knfsd thread will
> usually be in a position to recall delegations before it even initiates
> an operation on the inode in question, won't it?

I think it could.  I'm reluctant:

	- Once we support write delegations, I think we end up having to
	  do that before basically every operation on a inode.
	- I'd like this to make it easy for someone to extend delegation
	  support to userspace eventually too.  I'm not sure exactly how
	  we'd identify self-conflicts in that case (struct files?), but
	  anyway I'd rather this wasn't too nfsd-specific.

That said, I'm still curious:

> IOW: what if you were to modify the lease code to allow knfsd threads
> to return a "please ignore me, and proceed with the operation that
> triggered the lease break" reply, and then handle conflicts between NFS
> clients outside the lease callback code altogether?

So if you're a random bit of code, how would you recommend testing
whether you're running in a knfsd thread?

--b.
