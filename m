Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34898 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750855AbdDCIUc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Apr 2017 04:20:32 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170329220101.26067-1-ebiggers@google.com>
References: <20170329220101.26067-1-ebiggers@google.com>
To: Eric Biggers <ebiggers@google.com>
Cc: dhowells@redhat.com, keyrings@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, linux-nfs@vger.kernel.org,
        Gwendal Grignou <gwendal@chromium.org>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Richard Weinberger <richard@nod.at>,
        Theodore Ts'o <tytso@mit.edu>, stable@vger.kernel.org
Subject: Re: [PATCH] KEYS: make keyctl_invalidate() also require Setattr permission
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 03 Apr 2017 09:20:29 +0100
Message-ID: <10049.1491207629@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eric Biggers <ebiggers@google.com> wrote:

> Currently, a process only needs Search permission on a key to invalidate
> it with keyctl_invalidate(), which has an effect similar to unlinking it
> from all keyrings.  Unfortunately, this significantly compromises the
> keys permission system because as a result, there is no way to grant
> read-only access to keys without also granting de-facto "delete" access.
> Even worse, processes may invalidate entire _keyrings_, given only
> permission to "search" them.
> 
> Key invalidation seems to have intended for cases where keyrings are
> used as caches, and keys can be re-requested at any time by an upcall to
> /sbin/request-key.  However, keyrings are not always used in this way.
> For example, users of ext4, f2fs, and ubifs encryption may wish to grant
> many differently-privileged processes access to the same keys, set up in
> a shared keyring ahead of time.  Permitting everyone to invalidate keys
> in this scenario enables a trivial denial-of-service.  And even users of
> keyrings as "just caches" may wish to restrict invalidation because it
> may require significant work or user interaction to regenerate keys.
> 
> This patch fixes the flaw by requiring both Search and Setattr
> permission to invalidate a key rather than just Search permission.
> Requiring Setattr permission is appropriate because Setattr permission
> also allows revoking (via keyctl_revoke()) or expiring (via
> keyctl_set_timeout()) the key, which also make the key inaccessible
> regardless of how many keyrings it is in.  Continuing to require Search
> permission ensures we do not decrease the level of permissions required.

I'm not sure this is the right method either.  It might be better to allocate
one of the remaining two permissions bits for this and/or mark keys that are
invalidateable.

David
