Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 059A7C10F02
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 21:46:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BD8BA21B18
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 21:46:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550267178;
	bh=Q8wAvpeI5CabGUoVRawEgGha0WyAygxfrYODODFX4Uw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=gzOdixOU8K8iJPXhR+aeomGHHLlDxJzJE2LTOJABrUwAHX12ajgjMgXxepd5+Dvu5
	 zWTHEX6ai7yVBpVUivdFYGhSOYaUEq3+iyROrW2OZo5Yf/sKuwbdk3Xpi0dRW/xiQA
	 GJg6sH93ALP5wc/tPi2NUHVZAyobWMIUv93HPvkA=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392542AbfBOVqN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 16:46:13 -0500
Received: from mail.kernel.org ([198.145.29.99]:57314 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387436AbfBOVqN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 16:46:13 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 06702222DD;
        Fri, 15 Feb 2019 21:46:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1550267171;
        bh=Q8wAvpeI5CabGUoVRawEgGha0WyAygxfrYODODFX4Uw=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=ByxIT5918R/vmNXChNRO+0asNFcC+3W7rzp2thNJBSFZu/WWQdhZGEbtlvvHn3x6P
         lHChsYGwGMPA6Fu/TwQFYGgBkaPxm3gCFjEF3Tm+ULrNmuOjk7Yo0GLPzBWFT1OjLy
         nO4Sp2vd+oz7YuEd8d3+xWtQ2lBKHzfJCPdlfs/w=
Date:   Fri, 15 Feb 2019 13:46:09 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     David Howells <dhowells@redhat.com>
Cc:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org, linux-security-module@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, rgb@redhat.com,
        linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
Subject: Re: [RFC PATCH 20/27] container, keys: Add a container keyring
Message-ID: <20190215214608.GC12909@gmail.com>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
 <155024704568.21651.12664692449080180818.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155024704568.21651.12664692449080180818.stgit@warthog.procyon.org.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

[+Cc linux-fscrypt]

Hi David,

On Fri, Feb 15, 2019 at 04:10:45PM +0000, David Howells wrote:
> Allow a container manager to attach keyrings to a container such that the
> keys contained therein are searched by request_key() in addition to a
> process's normal keyrings.  This allows the manager to install keys to
> support filesystem decryption and authentication for superblocks inside the
> container without requiring any active role being played by processes
> inside of the container.
> 
> So, for example, a container could be created, a keyring added and then an
> rxrpc-type key added to the keyring such that a container's root filesystem
> and data filesystems can be brought in from secure AFS volumes.  It would
> also be possible to put filesystem crypto keys in there such that Ext4
> encrypted files could be decrypted - without the need to share the key
> between other containers or let the key leak into the container.

For fscrypt (aka ext4/f2fs/ubifs encryption), rather than a "container keyring",
I think it's much better served by ioctls to add/remove keys directly to/from
the filesystem, as I'm proposing here:
https://patchwork.kernel.org/cover/10806425/.  My proposed API implements all
the semantics people actually need for fscrypt, including:

- Making the filesystem's ability to use keys match the locked/unlocked state of
  encrypted files, which is a filesystem-wide thing not a per-process thing.

- Allowing a key to be removed and wiped, *and* the corresponding encrypted
  files locked efficiently.

- Still permitting non-root users to use fscrypt, subject to limitations; e.g.
  keys are identified by cryptographic hash, users are limited by the keys
  quotas, and a user can't directly remove a key another user has added or
  create a new encrypted directory without proving they know/knew the key.

A "container keyring" would only address the first problem.

I don't think it's the right semantics to have the kernel's ability to use
fscrypt keys be conditional on which process is doing the filesystem access --
even if the processes are divided into different sessions, users, or containers.
Doing so may sound good, but it plays into common misconceptions about the
purpose of storage encryption.  It would actually be an OS-level access control
policy that has nothing to do with the encryption itself.  The kernel already
has a wide variety of file access control mechanisms to choose from: file mode
bits, ACLs, SELinux, mount namespaces, etc...

The purpose of fscrypt is actually very different.  It's designed to protect
data locally stored on-disk from two classes of attackers: (1) attackers who can
read directly from disk, and (2) attackers who fully compromise the system
on-line including all memory, provided that the key isn't currently added.

In these cases, the notion of a "container" is meaningless as the operating
system is already out of the picture...

I also don't see much benefit to namespacing fscrypt keys for container
isolation purposes.  If it's at all computationally feasible for keys to
collide, then the encryption has already been massively screwed up.

Also, I don't think that fscrypt should have a de-facto dependency on
CONFIG_CONTAINERS in order to have sane semantics.  fscrypt is used on many
systems where containers support would be unnecessary bloat and attack surface.

So while there probably are still good arguments for adding a container keyring,
I don't think it's the best way forward for fscrypt.

- Eric

> 
> Because the container manager retains control of the keyring, it can update
> the contained keys as necessary to prevent expiration.  Note that the
> keyring and keys in the keyring must grant Search permission directly to
> the container object.
> 
> [!] Note that NFS, CIFS and other filesystems wishing to make use of this
>     would have to get the token to use by calling request_key() on entry to
>     its VFS methods and retain it in its file struct.
> 
> [!] Note that request_key() called from userspace does not look in the
>     container keyring.
> 
> [!] Note that keys are now tagged with a tag that identifies the network
>     namespace (or other domain of operation).  This allows keys to be
>     provided in one keyring that allow the same thing but in different
>     network namespaces.
> 
> The keyring should be created by the container manager and then set using:
> 
> 	keyctl(KEYCTL_SET_CONTAINER_KEYRING, int containerfd,
> 	       key_serial_t keyring);
> 
> With this, request_key() inside the kernel searches:
> 
> 	thread-keyring, process-keyring, session-keyring, container-keyring
> 
> [!] It may be worth setting a flag on a mountpoint to indicate whether to
>     search the container keyring first or last.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
