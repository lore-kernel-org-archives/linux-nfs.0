Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65534 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756174AbdIHPlo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Sep 2017 11:41:44 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170905183250.GA92687@gmail.com>
References: <20170905183250.GA92687@gmail.com> <20170816211403.121920-1-ebiggers3@gmail.com> <13221.1504605295@warthog.procyon.org.uk>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: dhowells@redhat.com, keyrings@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, linux-nfs@vger.kernel.org,
        Gwendal Grignou <gwendal@chromium.org>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Paul Crowley <paulcrowley@google.com>,
        Richard Weinberger <richard@nod.at>,
        Ryo Hashimoto <hashimoto@google.com>,
        Tyler Hicks <tyhicks@canonical.com>, stable@vger.kernel.org
Subject: Re: [PATCH v2] KEYS: make keyctl_invalidate() also require Setattr permission
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 08 Sep 2017 16:41:40 +0100
Message-ID: <610.1504885300@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eric Biggers <ebiggers3@gmail.com> wrote:

> True, but Setattr permission has already been overloaded to allow several
> different types of modifications,

Perhaps therein lies the problem.  Setattr is too overloaded and really needs
splitting along the following lines:

 (1) Security: ownership, access, security label, restrictions.

 (2) Content: alter/update, timeout.

 (3) Revocation and invalidation.

Maybe I should create some sort of ACL for keys and map setperm onto that.

I wonder if this could also intersect with user namespaces in some way so that
you can make an ACL that has users from multiple namespaces - might be tricky,
though.

> and it makes *much* more sense than Search permission which should not allow
> any modifications.  And in practice I expect people care more about whether
> modifications are permitted or not, than the details of the finer-grained
> permissions.

I disagree still.  To allow users to invalidate a key you would *also* have to
give them the ability to muck around with the permissions.

> Sort of, but actually keyctl_set_timeout() can be called at any time, and
> the timeout can be set to as little as 1 second.  So I don't see how
> keyctl_revoke() is that much different, fundamentally.

The timeout is a property of the key content and revoked is one of the states
the key can be in.

> >  (1) I add a flag to a key to say that it can be invalidated and a keyctl to
> >      change that flag.
> 
> And who would have permission to change that flag?  It seems to be the same
> problem again.

No.  Setperm would be required to change the flag, but not to apply the
invalidate operation if the flag is set.  Think of Invalidate as being a
mass-unlink operation effected by the garbage collector.

Kernel-created DNS keys, for example, don't grant Setperm to anyone.

> What would the behavior be if ->allow_invalidation() was not supplied?

The obvious would be to check that you're the owner of the key.

> In other words, would the purpose of this be to lock down invalidation of
> dns_resolver keys, or to restrict invalidation to *only* dns_resolver keys?

To restrict who could invalidate keys of a particular type.  Actually, it
wants to be per-key not per-key-type.  Hmmm...

> Granted by who, and how?  And do you mean keyctl_clear(), or
> keyctl_invalidate()?

keyctl_clear().  Empty the keyring, not render it unusable.


David
