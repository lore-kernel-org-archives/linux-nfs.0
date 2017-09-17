Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:46276 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750761AbdIQHZz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Sep 2017 03:25:55 -0400
Date: Sun, 17 Sep 2017 00:25:47 -0700
From: Eric Biggers <ebiggers3@gmail.com>
To: David Howells <dhowells@redhat.com>
Cc: keyrings@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-nfs@vger.kernel.org, Gwendal Grignou <gwendal@chromium.org>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Paul Crowley <paulcrowley@google.com>,
        Richard Weinberger <richard@nod.at>,
        Ryo Hashimoto <hashimoto@google.com>,
        Tyler Hicks <tyhicks@canonical.com>, stable@vger.kernel.org
Subject: Re: [PATCH v2] KEYS: make keyctl_invalidate() also require Setattr
 permission
Message-ID: <20170917072547.GC10599@zzz.localdomain>
References: <20170905183250.GA92687@gmail.com>
 <20170816211403.121920-1-ebiggers3@gmail.com>
 <13221.1504605295@warthog.procyon.org.uk>
 <610.1504885300@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <610.1504885300@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David,

On Fri, Sep 08, 2017 at 04:41:40PM +0100, David Howells wrote:
> Eric Biggers <ebiggers3@gmail.com> wrote:
> 
> > True, but Setattr permission has already been overloaded to allow several
> > different types of modifications,
> 
> Perhaps therein lies the problem.  Setattr is too overloaded and really needs
> splitting along the following lines:
> 
>  (1) Security: ownership, access, security label, restrictions.
> 
>  (2) Content: alter/update, timeout.
> 
>  (3) Revocation and invalidation.
> 
> Maybe I should create some sort of ACL for keys and map setperm onto that.
> 
> I wonder if this could also intersect with user namespaces in some way so that
> you can make an ACL that has users from multiple namespaces - might be tricky,
> though.

There would be a *lot* of changes needed to implement ACLs for keys.  Setting
them, getting them, evaluating them, updating all the LSMs to understand any new
permissions, deciding how the existing keyctl operations affect the ACL,
deciding what ACL to use by default, etc...  And it would make the keyrings
permissions system even more complicated, when people already have trouble
understanding it.  Complicated permissions systems are difficult to use
correctly.

Also I suppose that Invalidate would be implied by the old "Search" permission,
so users would need to use a new keyctl to remove Invalidate permission from the
ACL to get sane behavior?  That would be a pain, in comparison to having the bug
fixed by default.

> 
> > and it makes *much* more sense than Search permission which should not allow
> > any modifications.  And in practice I expect people care more about whether
> > modifications are permitted or not, than the details of the finer-grained
> > permissions.
> 
> I disagree still.  To allow users to invalidate a key you would *also* have to
> give them the ability to muck around with the permissions.
> 

True, though actually keyctl_setperm() also requires that the user own the key
or be root.

And while finer-grained permissions are preferable in theory, out of curiosity
do you have an example of an actual user who needs to be able to invalidate, or
perhaps in plainer language, "delete" keys without otherwise being able to
modify the keys or their containing keyring(s)?

Meanwhile, users of filesystem-level encryption need to set up keys that can be
searched by non-root users but not deleted.  This *should* be a normal, very
boring use case, since being able to grant read-only access should be a
fundamental part of any access control system.  But not with the keyrings
permission system, apparently :-)

> > Sort of, but actually keyctl_set_timeout() can be called at any time, and
> > the timeout can be set to as little as 1 second.  So I don't see how
> > keyctl_revoke() is that much different, fundamentally.
> 
> The timeout is a property of the key content and revoked is one of the states
> the key can be in.
> 
> > >  (1) I add a flag to a key to say that it can be invalidated and a keyctl to
> > >      change that flag.
> > 
> > And who would have permission to change that flag?  It seems to be the same
> > problem again.
> 
> No.  Setperm would be required to change the flag, but not to apply the
> invalidate operation if the flag is set.  Think of Invalidate as being a
> mass-unlink operation effected by the garbage collector.
> 
> Kernel-created DNS keys, for example, don't grant Setperm to anyone.
> 

Perhaps keyctl_invalidate() should by default require Setattr permission, or
perhaps owning the key --- but after a call to a new keyctl_set_invalidatable()
which would require Setattr permission, just Search permission would be
required?  It seems that would address your concern about needing to grant
Setattr permission to invalidate keys.

> 
> > What would the behavior be if ->allow_invalidation() was not supplied?
> 
> The obvious would be to check that you're the owner of the key.
> 
> > In other words, would the purpose of this be to lock down invalidation of
> > dns_resolver keys, or to restrict invalidation to *only* dns_resolver keys?
> 
> To restrict who could invalidate keys of a particular type.  Actually, it
> wants to be per-key not per-key-type.  Hmmm...
> 
> > Granted by who, and how?  And do you mean keyctl_clear(), or
> > keyctl_invalidate()?
> 
> keyctl_clear().  Empty the keyring, not render it unusable.
> 
> 
> David

If there is a "keyctl_set_invalidatable()" being added too, I don't really see
the point of adding an ->allow_invalidation() method and mucking around with
keyctl_clear() permissions as well.

Eric
