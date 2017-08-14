Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:33867 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753470AbdHNP7x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Aug 2017 11:59:53 -0400
Received: by mail-qk0-f178.google.com with SMTP id u139so52499758qka.1
        for <linux-nfs@vger.kernel.org>; Mon, 14 Aug 2017 08:59:53 -0700 (PDT)
Message-ID: <1502726389.8640.2.camel@redhat.com>
Subject: Re: [RFC 1/1] destroy_creds.2: new page documenting destroy_creds()
From: Jeff Layton <jlayton@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "dhowells@redhat.com" <dhowells@redhat.com>,
        "neilb@suse.com" <neilb@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Date: Mon, 14 Aug 2017 11:59:49 -0400
In-Reply-To: <CB7D102A-5711-4661-928F-3689895A1A5A@netapp.com>
References: <20170807212355.29127-1-kolga@netapp.com>
         <20170807212355.29127-3-kolga@netapp.com>
         <1502281848.12841.2.camel@redhat.com>
         <87378yr2sx.fsf@notabene.neil.brown.name>
         <1502450305.4950.4.camel@redhat.com>
         <E127503D-3DFC-4FD3-99F6-012D100C168B@netapp.com>
         <1502461341.4762.1.camel@redhat.com>
         <1502464329.5352.1.camel@primarydata.com>
         <1502624339.4839.4.camel@redhat.com>
         <CB7D102A-5711-4661-928F-3689895A1A5A@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-08-14 at 11:15 -0400, Olga Kornievskaia wrote:
> > On Aug 13, 2017, at 7:38 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > On Fri, 2017-08-11 at 15:12 +0000, Trond Myklebust wrote:
> > > On Fri, 2017-08-11 at 10:22 -0400, Jeff Layton wrote:
> > > > I think I wasn't clear here. I'm not proposing that you move everyone
> > > > to
> > > > KEYRING: credcaches. This would not be a visible change to userland.
> > > > We'd still use rpc.gssd to upcall for creds.
> > > > 
> > > > What I'm saying is that instead of storing the creds in a hashtable
> > > > like
> > > > we do today, we'd just stash them in one of the keyrings hanging off
> > > > of
> > > > struct cred.
> > > > 
> > > > Change all of the authgss_ops operations to do query/store from the
> > > > appropriate keyring directly. With that, the effective lifetime of
> > > > GSSAPI creds would be bounded by the lifetime of the keyrings that
> > > > hold
> > > > references to it.
> > > > 
> > > > We'd probably need a new key_type for this to ensure that this
> > > > couldn't
> > > > be manipulated directly from userland. Or...maybe you'd still want to
> > > > allow userland to destroy the creds? No need for a new syscall with
> > > > that
> > > > -- they can just do a "keyctl unlink". There are a lot of options
> > > > here.
> > > > 
> > > > It's a non-trivial amount of work though (rpcauth_lookupcred() on
> > > > down
> > > > would probably need to be reworked) and I haven't looked at it
> > > > detail.
> > > > Still, it seems like it could be a more modern and cleaner design
> > > > than
> > > > what we have today.
> > > > 
> > > 
> > > The main annoyance with going from a global to a local cache such as
> > > the keyrings is that it makes comparing credentials a lot more work.
> > > Today, because the credentials are essentially unique per server, we
> > > just do pointer comparisons. Once we have non-global caches, we would
> > > need to do more elaborate comparisons to ensure that the uid, gid, and
> > > list of groups match.
> > > That's also why we never made the leap to using 'struct cred', btw...
> > 
> > Ok, it does seem better to have a global cache from that standpoint.
> > Still, a new syscall for this doesn't seem very elegant. I also worry a
> > bit about writeback here too (like David and Neil have pointed out).
> > 
> > What about changing how we hold references on these objects instead?
> > 
> > After we look up an auth token in e.g. rpcauth_lookupcred, take a
> > reference to it and stash a pointer to it somewhere in the cred.
> > Possibly in the thread or process keyrings, but it may work better
> > elsewhere.
> > 
> > When we go to look up creds from that thread in the future, we can get
> > to it directly (which is a nice bonus). When the cred is destroyed
> > (usually on process destruction), we'd drop the reference to the object,
> > which would drop the reference to the global cache object.
> > 
> > The global cache could then be changed to have a pretty short timeout (a
> > few seconds?) and reap the object soon afterward when there are no more
> > active processes that have used it.
> 
> Wouldn’t that produce a lot of unnecessary context re-establishments. 
> 

I wouldn't think so.

As long as there is an outstanding struct cred that holds a reference to
the rpc cred, then the context will stick around and you shouldn't need
to upcall. Even if all you have is short-lived tasks, you still will
only need to upcall at the rate of the cache timeout, at the max.

Granted, timing out caches like this is a bit of a black art, and I'm
assuming that a small delay (<1 minute) between struct cred destruction
and the context destruction would be ok.

> > It's a bit more work and we might need to grow struct cred to handle it
> > (maybe give it its own keyring?), but it seems like that might be a
> > cleaner solution than giving userland knobs to manage the kernel's
> > caches.
> 
> Userland is the only place that know that kdestroy ran and is the best
> place to tell the kernel to remove its cache. Everything else is guessing.

This doesn't necessarily preclude destroying them manually. If you store
the key in a keyring you could still manually purge that reference with
a keyctl_unlink(). This approach would also mean you wouldn't need a new
syscall as well.

Regardless...I think there is a lot of mileage to be gained out of
handling cache timeouts intelligently. If for no other reason than to
have sane context timeouts for environments that can't or won't call
destroy the creds when the cache is destroyed.

-- 
Jeff Layton <jlayton@redhat.com>
