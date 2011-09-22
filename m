Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52373 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195Ab1IVOeE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 10:34:04 -0400
Received: by wyg34 with SMTP id 34so3048515wyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 07:34:03 -0700 (PDT)
In-Reply-To: <20110922124608.7739.27750.stgit@warthog.procyon.org.uk>
References: <20110922124608.7739.27750.stgit@warthog.procyon.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 22 Sep 2011 07:33:43 -0700
Message-ID: <CA+55aFzoH2VxTvf3Q1Lp_GAqDNAbsSOa=ATFXYSmmM=K8Fhuew@mail.gmail.com>
Subject: Re: [PATCH] NFS4: Revert commit to make the automount code ignore LOOKUP_FOLLOW
To: David Howells <dhowells@redhat.com>
Cc: miklos@szeredi.hu, raven@themaw.net, viro@zeniv.linux.org.uk,
        jlayton@redhat.com, gregkh@suse.de, linux-nfs@vger.kernel.org,
        leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 22, 2011 at 5:46 AM, David Howells <dhowells@redhat.com> wrote:
>
>  (4) Add a new flag, say LOOKUP_GETTING_ATTRS, to indicate that we're doing a
>     stat() or a getxattr() and suppress automounting on that basis.

I'd prefer this one. Except I'd just call it LOOKUP_STAT to make it
less cumbersome.

And then just have lstat/stat/xattr set that bit, and make it clear
that that bit means "no automount".

                      Linus
