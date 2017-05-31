Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34310 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751053AbdEaTTd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 May 2017 15:19:33 -0400
Date: Wed, 31 May 2017 12:19:30 -0700
From: Eric Biggers <ebiggers3@gmail.com>
To: David Howells <dhowells@redhat.com>
Cc: Eric Biggers <ebiggers@google.com>, keyrings@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, linux-nfs@vger.kernel.org,
        Gwendal Grignou <gwendal@chromium.org>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Richard Weinberger <richard@nod.at>,
        Theodore Ts'o <tytso@mit.edu>, stable@vger.kernel.org
Subject: Re: [PATCH] KEYS: make keyctl_invalidate() also require Setattr
 permission
Message-ID: <20170531191930.GC72735@gmail.com>
References: <20170329220101.26067-1-ebiggers@google.com>
 <10049.1491207629@warthog.procyon.org.uk>
 <20170404184433.GA46469@gmail.com>
 <20170516214957.GA113464@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170516214957.GA113464@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 16, 2017 at 02:49:57PM -0700, Eric Biggers wrote:
> Hi David,
> 
> On Tue, Apr 04, 2017 at 11:44:33AM -0700, Eric Biggers wrote:
> > On Mon, Apr 03, 2017 at 09:20:29AM +0100, David Howells wrote:
> > > Eric Biggers <ebiggers@google.com> wrote:
> > > 
> > > > Currently, a process only needs Search permission on a key to invalidate
> > > > it with keyctl_invalidate(), which has an effect similar to unlinking it
> > > > from all keyrings.  Unfortunately, this significantly compromises the
> > > > keys permission system because as a result, there is no way to grant
> > > > read-only access to keys without also granting de-facto "delete" access.
> > > > Even worse, processes may invalidate entire _keyrings_, given only
> > > > permission to "search" them.
> > > > 
> > > > Key invalidation seems to have intended for cases where keyrings are
> > > > used as caches, and keys can be re-requested at any time by an upcall to
> > > > /sbin/request-key.  However, keyrings are not always used in this way.
> > > > For example, users of ext4, f2fs, and ubifs encryption may wish to grant
> > > > many differently-privileged processes access to the same keys, set up in
> > > > a shared keyring ahead of time.  Permitting everyone to invalidate keys
> > > > in this scenario enables a trivial denial-of-service.  And even users of
> > > > keyrings as "just caches" may wish to restrict invalidation because it
> > > > may require significant work or user interaction to regenerate keys.
> > > > 
> > > > This patch fixes the flaw by requiring both Search and Setattr
> > > > permission to invalidate a key rather than just Search permission.
> > > > Requiring Setattr permission is appropriate because Setattr permission
> > > > also allows revoking (via keyctl_revoke()) or expiring (via
> > > > keyctl_set_timeout()) the key, which also make the key inaccessible
> > > > regardless of how many keyrings it is in.  Continuing to require Search
> > > > permission ensures we do not decrease the level of permissions required.
> > > 
> > > I'm not sure this is the right method either.  It might be better to allocate
> > > one of the remaining two permissions bits for this and/or mark keys that are
> > > invalidateable.
> > > 
> > 
> > What do you think is the right solution?  We really need to do _something_.  Can
> > you elaborate on what the use case(s) for "invalidate" were intended to be, and
> > what users of it are known?
> > 
> > As I noted in the commit message I was hesistant to create a new Invalidate
> > permission because that would require that users of keyctl_setperm +
> > keyctl_invalidate to start including a new permission which never existed
> > before.  Note that the new permission would be rejected with EINVAL by old
> > kernels, so applications might even need to try it both ways.
> > 
> > However perhaps no one cares and doing that would be a non-issue.
> > 
> > If furthermore the only users of "invalidate" are nfsidmap and the in-kernel
> > dns_resolver, then it may be fine to rename the KEY_FLAG_ROOT_CAN_INVAL flag to
> > something like "KEY_FLAG_INVALIDATABLE" and making it so only those keys can be
> > invalidated.  That would be much better, but I don't know for sure that there
> > aren't other users of keyctl_invalidate() (you may know more).
> > 
> 
> I'm still thinking my proposed fix to require Setattr permission is the best
> solution.  Allocating a new permission bit breaks everyone calling
> keyctl_setperm() along with keyctl_invalidate(), while marking only certain keys
> as invalidatable breaks everyone using keyctl_invalidate() for some "unintended"
> key.
> 
> Personally, I've now seen keyctl_invalidate() used in two different places for
> removing ext4 encryption keys: in Chrome OS userspace, and in a test script.
> The fact is that almost everyone using the keyrings API gets confused about the
> difference between revocation, invalidation, expiration, and unlinking, so they
> may end up doing "invalidate" when maybe they were "supposed" to do something
> else.  And it may not be a good idea to break the people who happened to choose
> "invalidate", beyond what we have to do to close the security hole.
> 
> What do you say?
> 
> - Eric

David, any update on this?  This really needs to be fixed, as users actually
rely on keyring permissions to work sanely, and not have a gaping security hole.

Eric
