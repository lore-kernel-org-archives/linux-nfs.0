Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:36276 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752724AbdHKOWY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Aug 2017 10:22:24 -0400
Received: by mail-qt0-f178.google.com with SMTP id v29so21777755qtv.3
        for <linux-nfs@vger.kernel.org>; Fri, 11 Aug 2017 07:22:24 -0700 (PDT)
Message-ID: <1502461341.4762.1.camel@redhat.com>
Subject: Re: [RFC 1/1] destroy_creds.2: new page documenting destroy_creds()
From: Jeff Layton <jlayton@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: NeilBrown <neilb@suse.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        David Howells <dhowells@redhat.com>
Date: Fri, 11 Aug 2017 10:22:21 -0400
In-Reply-To: <E127503D-3DFC-4FD3-99F6-012D100C168B@netapp.com>
References: <20170807212355.29127-1-kolga@netapp.com>
         <20170807212355.29127-3-kolga@netapp.com>
         <1502281848.12841.2.camel@redhat.com>
         <87378yr2sx.fsf@notabene.neil.brown.name>
         <1502450305.4950.4.camel@redhat.com>
         <E127503D-3DFC-4FD3-99F6-012D100C168B@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-08-11 at 09:49 -0400, Olga Kornievskaia wrote:
> > On Aug 11, 2017, at 7:18 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > On Fri, 2017-08-11 at 17:17 +1000, NeilBrown wrote:
> > > On Wed, Aug 09 2017, Jeff Layton wrote:
> > > ....
> > > > Thanks, that helps a bit. I'm less clear on what the higher-level
> > > > vision is here though:
> > > > 
> > > > Are we all going to be running scripts on logout that scrape
> > > > /proc/mounts and run fslogout on each? Will this be added to kdestroy?
> > > > 
> > > > Or are you aiming to have KCM do this on some trigger? (see:
> > > > https://fedoraproject.org/wiki/Changes/KerberosKCMCache)
> > > > 
> > > > Also, doing this per-mount seems wrong to me. Shouldn't this be done on
> > > > a per-net-namespace basis or maybe even globally?
> > > 
> > > Having looked at the code, I think this is invalidating cached
> > > credentials globally -- or at least, globally for all filesystems that
> > > use sunrpc.
> > > 
> > > I actually question the premise for wanting to do this.  Tickets have a
> > > timeout and will expire.  Any code that is allowed to get a ticket, can
> > > hold on to it as long as it likes - but it will cease to work after the
> > > expiry time.  Hunting out all the places that a key might be cached, and
> > > invalidating them, seems to deviate from the model.  If you are concerned
> > > about leaving credentials around where they can theoretically be
> > > misused, then set a smaller expiry time.
> > > 
> > > What is the threat-model that this change is supposed to guard against?
> > > 
> > > Looking that the syscall itself:
> > > 1/ why restrict the call to directories only?
> > > 2/ Every new syscall should have a 'flags' argument, because you never
> > >    know when you'll need one.
> > > 
> > 
> > I have some of the same concerns. For instance, we don't kill off ssh
> > sessions that were established with krb5 just because the credcache was
> > destroyed. RPC is a bit different since we authenticate every call, but
> > is this fundamentally different from keeping an ssh session around that
> > was established before the credcache was destroyed?
> 
> Probably because fundamentally, it’s the same user that keeps using it.
> If the same ssh connection was shared by multiple users that were inserting
> and deleting their credentials then it would be as problematic.
> 
> > Are we just getting tickets with too long a lifetime here? Maybe we just
> > need to be more cavalier about destroying cached creds on some event or
> > on a more timely basis?
> > 
> > Also, the whole gssapi credcache in the kernel is showing its age a bit.
> > struct auth_cred has had this over it for about as long as I've been
> > doing kernel work:
> > 
> >    /* Work around the lack of a VFS credential */
> > 
> > We've had struct cred for ages now.
> > 
> > David and I were chatting about this the other day and were wondering if
> > we could change the RPC gssapi code to cache credentials in one of the
> > keyrings in struct cred. Then, once the struct cred goes away, the key
> > would go away as well. It wouldn't be destroyed on kdestroy, but once
> > the last process with those creds exits, they would go away.
> 
> One argument against it: Kerberos has changed their storage location 
> over the years (FILES … to keyring). What if they change again? Then NFS 
> would have to change their implementation as well.
> 
> Having said that: outside of the fs-mailing list, I have asked Trond that
> if VFS decides to reject the syscall idea, what would be an alternative 
> and one of the choices is the keyring. Of course there are variations of 
> how the keyring would be used. One option would be to totally switch to 
> storing credentials in the keyring. To what what Andy had originally 
> proposed of introducing a gss key type and storing the gss context in 
> the keyring.
> 
> 

I think I wasn't clear here. I'm not proposing that you move everyone to
KEYRING: credcaches. This would not be a visible change to userland.
We'd still use rpc.gssd to upcall for creds.

What I'm saying is that instead of storing the creds in a hashtable like
we do today, we'd just stash them in one of the keyrings hanging off of
struct cred.

Change all of the authgss_ops operations to do query/store from the
appropriate keyring directly. With that, the effective lifetime of
GSSAPI creds would be bounded by the lifetime of the keyrings that hold
references to it.

We'd probably need a new key_type for this to ensure that this couldn't
be manipulated directly from userland. Or...maybe you'd still want to
allow userland to destroy the creds? No need for a new syscall with that
-- they can just do a "keyctl unlink". There are a lot of options here.

It's a non-trivial amount of work though (rpcauth_lookupcred() on down
would probably need to be reworked) and I haven't looked at it detail.
Still, it seems like it could be a more modern and cleaner design than
what we have today.

-- 
Jeff Layton <jlayton@redhat.com>
