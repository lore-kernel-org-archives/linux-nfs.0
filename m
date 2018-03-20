Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43484 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751269AbeCTQC6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Mar 2018 12:02:58 -0400
Date: Tue, 20 Mar 2018 12:02:57 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dhowells@redhat.com" <dhowells@redhat.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 10/10] nfsd: clients don't need to break their own
 delegations
Message-ID: <20180320160257.GC4288@fieldses.org>
References: <1521470194-24840-11-git-send-email-bfields@redhat.com>
 <1521470194-24840-1-git-send-email-bfields@redhat.com>
 <29167.1521552951@warthog.procyon.org.uk>
 <1521553578.10293.4.camel@primarydata.com>
 <20180320144928.GA4288@fieldses.org>
 <1521558822.15893.12.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1521558822.15893.12.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 20, 2018 at 03:13:47PM +0000, Trond Myklebust wrote:
> On Tue, 2018-03-20 at 10:49 -0400, J. Bruce Fields wrote:
> > On Tue, Mar 20, 2018 at 01:46:20PM +0000, Trond Myklebust wrote:
> > > On Tue, 2018-03-20 at 13:35 +0000, David Howells wrote:
> > > > J. Bruce Fields <bfields@redhat.com> wrote:
> > > > 
> > > > > @@ -139,6 +139,9 @@ struct cred {
> > > > >  	struct key	*thread_keyring; /* keyring private
> > > > > to
> > > > > this thread */
> > > > >  	struct key	*request_key_auth; /* assumed
> > > > > request_key authority */
> > > > >  #endif
> > > > > +#ifdef CONFIG_FILE_LOCKING
> > > > > +	void		*lease_breaker; /* identify NFS
> > > > > client
> > > > > breaking a delegation */
> > > > > +#endif
> > > > >  #ifdef CONFIG_SECURITY
> > > > >  	void		*security;	/* subjective
> > > > > LSM
> > > > > security */
> > > > >  #endif
> > > > 
> > > > Sorry, but ewww.
> > > > 
> > > > Two reasons for that comment:
> > > > 
> > > >  (1) The cred struct may get retained long past where you expect
> > > > if
> > > > it gets
> > > >      attached to another process or a file descriptor.
> > > > 
> > > >  (2) The ->lease_breaker pointer needs lifetime management in
> > > > cred.c.  It will
> > > >      potentially get copied around and may need cleaning up.
> > > > 
> > > > Can you stick your breaker identity in a key struct as Jeff
> > > > suggested?
> > > > 
> > > 
> > > Bruce,
> > > 
> > > Do you really need to do more than just identify that this is a
> > > knfsd
> > > thread vs not a knfsd thread? I'm assuming that a knfsd thread will
> > > usually be in a position to recall delegations before it even
> > > initiates
> > > an operation on the inode in question, won't it?
> > 
> > I think it could.  I'm reluctant:
> > 
> > 	- Once we support write delegations, I think we end up having
> > to
> > 	  do that before basically every operation on a inode.
> > 	- I'd like this to make it easy for someone to extend
> > delegation
> > 	  support to userspace eventually too.  I'm not sure exactly
> > how
> > 	  we'd identify self-conflicts in that case (struct files?),
> > but
> > 	  anyway I'd rather this wasn't too nfsd-specific.
> 
> That's my point. A userspace application is going to have to do
> something like this anyway. It cannot install hooks in the kernel to
> perform elaborate tests, so it is going to have to rely on something
> like the struct file_lock 'fl_nspid' field in order to determine
> whether or not to apply a lease break.
> 
> i.e.: the userspace rule should be to break the lease if and only if it
> is not owned by my process.

I was thinking of using struct file (whoops, not "struct files", sorry
for the typo above) to avoid assuming too much about any userspace
server's threading model.

> > That said, I'm still curious:
> > 
> > > IOW: what if you were to modify the lease code to allow knfsd
> > > threads
> > > to return a "please ignore me, and proceed with the operation that
> > > triggered the lease break" reply, and then handle conflicts between
> > > NFS
> > > clients outside the lease callback code altogether?
> > 
> > So if you're a random bit of code, how would you recommend testing
> > whether you're running in a knfsd thread?
> 
> Right now, the knfsd threads are regular kernel threads, with each
> thread appearing to userspace to be a process in its own right.
> Is there any reason why we could not assign them a group pid that would
> allow the fl_nspid mechanism to work (i.e. set task->group_leader)?

Huh, OK, I hadn't thought about that.

--b.
