Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37988 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751457AbdIEJzG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Sep 2017 05:55:06 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170816211403.121920-1-ebiggers3@gmail.com>
References: <20170816211403.121920-1-ebiggers3@gmail.com>
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
Date: Tue, 05 Sep 2017 10:54:55 +0100
Message-ID: <13221.1504605295@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eric Biggers <ebiggers3@gmail.com> wrote:

> This patch fixes the flaw by requiring both Search and Setattr permission to
> invalidate a key rather than just Search permission.

I'm not sure I agree.  The problem is that you then have to grant someone
Setattr permission for them to be able to do this, which then opens up a whole
host of other things they can also do.

> Requiring Setattr permission is appropriate because Setattr permission also
> allows revoking (via keyctl_revoke()) or expiring (via keyctl_set_timeout())
> the key, which also make the key inaccessible regardless of how many
> keyrings it is in.

Note that setting the expiry time is not really equivalent to revokation in
this regard as setting the expiry time is something you do when setting up a
key, whereas revokation is something you do later to kill a key off.

> Alternatively, the problem could be solved by requiring Write permission.

That's not really a viable solution as things stand.  You can't turn Write
permission on on a key whose type doesn't have an ->update() method (though
this could be changed) and it also opens up a key to being modified.

How about another solution:

 (1) I add a flag to a key to say that it can be invalidated and a keyctl to
     change that flag.

 (2) I add a new key type op called ->allow_invalidation() that allows key
     types to govern separately who is allowed to invalidate keys of that
     type.

     So, for instance, DNS record invalidation would require CAP_NET_ADMIN.

 (3) Allow keyrings to be cleared by users who don't have Write permission but
     do have other permission, such as CAP_NET_ADMIN.  This would need to be
     granted on a per-keyring basis.

David
