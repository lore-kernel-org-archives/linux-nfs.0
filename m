Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:37327 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751891AbdHKLS2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Aug 2017 07:18:28 -0400
Received: by mail-qt0-f181.google.com with SMTP id 16so19103296qtz.4
        for <linux-nfs@vger.kernel.org>; Fri, 11 Aug 2017 04:18:28 -0700 (PDT)
Message-ID: <1502450305.4950.4.camel@redhat.com>
Subject: Re: [RFC 1/1] destroy_creds.2: new page documenting destroy_creds()
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>, Olga Kornievskaia <kolga@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>
Date: Fri, 11 Aug 2017 07:18:25 -0400
In-Reply-To: <87378yr2sx.fsf@notabene.neil.brown.name>
References: <20170807212355.29127-1-kolga@netapp.com>
         <20170807212355.29127-3-kolga@netapp.com>
         <1502281848.12841.2.camel@redhat.com>
         <87378yr2sx.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-08-11 at 17:17 +1000, NeilBrown wrote:
> On Wed, Aug 09 2017, Jeff Layton wrote:
> ....
> > 
> > Thanks, that helps a bit. I'm less clear on what the higher-level
> > vision is here though:
> > 
> > Are we all going to be running scripts on logout that scrape
> > /proc/mounts and run fslogout on each? Will this be added to kdestroy?
> > 
> > Or are you aiming to have KCM do this on some trigger? (see:
> > https://fedoraproject.org/wiki/Changes/KerberosKCMCache)
> > 
> > Also, doing this per-mount seems wrong to me. Shouldn't this be done on
> > a per-net-namespace basis or maybe even globally?
> 
> Having looked at the code, I think this is invalidating cached
> credentials globally -- or at least, globally for all filesystems that
> use sunrpc.
> 
> I actually question the premise for wanting to do this.  Tickets have a
> timeout and will expire.  Any code that is allowed to get a ticket, can
> hold on to it as long as it likes - but it will cease to work after the
> expiry time.  Hunting out all the places that a key might be cached, and
> invalidating them, seems to deviate from the model.  If you are concerned
> about leaving credentials around where they can theoretically be
> misused, then set a smaller expiry time.
> 
> What is the threat-model that this change is supposed to guard against?
> 
> Looking that the syscall itself:
>  1/ why restrict the call to directories only?
>  2/ Every new syscall should have a 'flags' argument, because you never
>     know when you'll need one.
> 

I have some of the same concerns. For instance, we don't kill off ssh
sessions that were established with krb5 just because the credcache was
destroyed. RPC is a bit different since we authenticate every call, but
is this fundamentally different from keeping an ssh session around that
was established before the credcache was destroyed?

Are we just getting tickets with too long a lifetime here? Maybe we just
need to be more cavalier about destroying cached creds on some event or
on a more timely basis?

Also, the whole gssapi credcache in the kernel is showing its age a bit.
struct auth_cred has had this over it for about as long as I've been
doing kernel work:

    /* Work around the lack of a VFS credential */

We've had struct cred for ages now.

David and I were chatting about this the other day and were wondering if
we could change the RPC gssapi code to cache credentials in one of the
keyrings in struct cred. Then, once the struct cred goes away, the key
would go away as well. It wouldn't be destroyed on kdestroy, but once
the last process with those creds exits, they would go away.

-- 
Jeff Layton <jlayton@redhat.com>
