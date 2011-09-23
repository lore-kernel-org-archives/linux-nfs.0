Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59326 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122Ab1IWQfz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 12:35:55 -0400
Received: by wwf22 with SMTP id 22so3893402wwf.1
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 09:35:54 -0700 (PDT)
In-Reply-To: <20110923162451.13574.33960.stgit@warthog.procyon.org.uk>
References: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk> <20110923162451.13574.33960.stgit@warthog.procyon.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 23 Sep 2011 09:35:34 -0700
Message-ID: <CA+55aFwt96i3k_UJREQU18xq=tRqRZGP8NhRJfbOaipqiVKnGQ@mail.gmail.com>
Subject: Re: [PATCH 1/7] NFS4: Revert commit to make the automount code ignore LOOKUP_FOLLOW
To: David Howells <dhowells@redhat.com>
Cc: miklos@szeredi.hu, raven@themaw.net, viro@zeniv.linux.org.uk,
        jlayton@redhat.com, gregkh@suse.de, linux-nfs@vger.kernel.org,
        leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 23, 2011 at 9:24 AM, David Howells <dhowells@redhat.com> wrote:
>
> The problem with this is that this breaks nfs_follow_remote_path() used by NFS4
> to find the root object to mount for the mount() syscall.

The above message is basically dishonest.

That's not AT ALL the problem.

That problem could have been fixed with a one-liner patch that already exists.

This whole patch-series looks like just excuses for doing stupid things.

Afaik, LOOKUP_OPEN and LOOKUP_DIRECTORY already force the auto-mount.
You can use either or both to force it.

Why are people so deep in denial about this?

                        Linus
